# Data Layer Patterns — Repository, AppContainer, ModelContainer, SwiftData

Patrones de la capa de datos de Forma.

---

## 1. Repository — patrón completo

### Protocolo (Domain/Repositories/)

```swift
// Sendable → puede cruzar actor boundaries sin problemas de concurrencia
protocol MesocycleRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [Mesocycle]
    func fetchActive() async throws -> Mesocycle?
    func save(_ mesocycle: Mesocycle) async throws
    func delete(_ mesocycle: Mesocycle) async throws
}
```

### Implementación concreta (Data/Repositories/)

```swift
final class MesocycleRepository: MesocycleRepositoryProtocol {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() async throws -> [Mesocycle] {
        let descriptor = FetchDescriptor<Mesocycle>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchActive() async throws -> Mesocycle? {
        var descriptor = FetchDescriptor<Mesocycle>(
            predicate: #Predicate { $0.isActive == true }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    func save(_ mesocycle: Mesocycle) async throws {
        modelContext.insert(mesocycle)
        try modelContext.save()
    }

    func delete(_ mesocycle: Mesocycle) async throws {
        modelContext.delete(mesocycle)
        try modelContext.save()
    }
}
```

### Mock — para Previews y Tests (Data/Repositories/)

```swift
final class MockMesocycleRepository: MesocycleRepositoryProtocol {

    var mesocyclesToReturn: [Mesocycle]
    var shouldThrowError = false

    // Tracking básico (para tests sin Spy completo)
    private(set) var fetchAllWasCalled = false
    private(set) var savedMesocycles: [Mesocycle] = []

    init(empty: Bool = false, shouldThrowError: Bool = false) {
        self.mesocyclesToReturn = empty ? [] : Mesocycle.previewData
        self.shouldThrowError = shouldThrowError
    }

    func fetchAll() async throws -> [Mesocycle] {
        fetchAllWasCalled = true
        if shouldThrowError { throw RepositoryError.unknown }
        return mesocyclesToReturn
    }

    func fetchActive() async throws -> Mesocycle? {
        if shouldThrowError { throw RepositoryError.unknown }
        return mesocyclesToReturn.first { $0.isActive }
    }

    func save(_ mesocycle: Mesocycle) async throws {
        if shouldThrowError { throw RepositoryError.unknown }
        savedMesocycles.append(mesocycle)
    }

    func delete(_ mesocycle: Mesocycle) async throws {
        if shouldThrowError { throw RepositoryError.unknown }
        mesocyclesToReturn.removeAll { $0.id == mesocycle.id }
    }

    func reset() {
        fetchAllWasCalled = false
        savedMesocycles = []
    }
}
```

**Mock vs Spy:**

| | Mock | Spy |
|---|---|---|
| Ubicación | `Data/Repositories/` | `FormaTests/Shared/Spies/` |
| Propósito | Previews + tests básicos | Tests con assertions detalladas |
| Tracking | Mínimo | Completo (`wasCalled`, `last*`) |
| Import | Sin imports de test | `import Testing`, `@testable` |
| Sendable | Normal | `@unchecked Sendable` |

En Forma usamos un solo Mock con tracking básico — es suficiente. Si los tests crecen, separar en Spy es la decisión correcta.

---

## 2. AppContainer — inyección de dependencias

```swift
// App/AppContainer.swift
@Observable
final class AppContainer {

    // MARK: - Repositories
    let mesocycleRepository: MesocycleRepositoryProtocol
    let workoutSessionRepository: WorkoutSessionRepositoryProtocol
    let bodyMeasurementRepository: BodyMeasurementRepositoryProtocol
    let nutritionPlanRepository: NutritionPlanRepositoryProtocol
    let userProfileRepository: UserProfileRepositoryProtocol

    // MARK: - Services
    let healthKitService: HealthKitService
    let volumeCalculatorService: VolumeCalculatorService
    let bodyMetricsService: BodyMetricsService

    // MARK: - Initializers
    init(modelContext: ModelContext) {
        self.mesocycleRepository = MesocycleRepository(modelContext: modelContext)
        // ... resto de repositorios
        self.healthKitService = HealthKitService()
        self.volumeCalculatorService = VolumeCalculatorService()
        self.bodyMetricsService = BodyMetricsService()
    }
}

extension AppContainer {
    static var preview: AppContainer {
        // init alternativo con mocks
    }
}
```

```swift
// App/FormaApp.swift
@main
struct FormaApp: App {

    // MARK: - States
    @State private var container: AppContainer?

    var body: some Scene {
        WindowGroup {
            if let container {
                MainTabView()
                    .environment(container)
            } else {
                ProgressView()
            }
        }
        .modelContainer(for: FormaSchema.models) { result in
            switch result {
            case .success(let modelContainer):
                container = AppContainer(modelContext: modelContainer.mainContext)
            case .failure(let error):
                Logger.core.error("ModelContainer failed: \(error, privacy: .public)")
            }
        }
    }
}
```

**Por qué `@State` opcional:** el `ModelContainer` puede fallar (corrupción, migración). Si falla, no se crea el AppContainer y se muestra error en lugar de crashear.

---

## 3. ModelContainer — App Group obligatorio desde el primer commit

Widget y app son **dos procesos distintos** y no pueden compartir el mismo SQLite. Migrar a App Group después de tener datos implica migración explícita → es doloroso.

**Configurar el App Group desde el primer commit, aunque el widget sea V1.1.**

```swift
// App/FormaModelContainer.swift
enum FormaModelContainer {

    static let appGroupIdentifier = "group.com.armando.forma"
    private static let databaseFilename = "Forma.sqlite"

    static func makeContainer() throws -> ModelContainer {
        let schema = Schema(FormaSchema.models)
        let configuration = makeConfiguration(for: schema)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    private static func makeConfiguration(for schema: Schema) -> ModelConfiguration {
        if let storeURL = appGroupStoreURL() {
            return ModelConfiguration(
                schema: schema,
                url: storeURL,
                cloudKitDatabase: .private("iCloud.com.armando.forma")
            )
        }
        // Fallback — simulator sin entitlements configurados
        return ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    }

    private static func appGroupStoreURL() -> URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)?
            .appendingPathComponent(databaseFilename)
    }
}
```

---

## 4. Modelos SwiftData

```swift
@Model
final class Mesocycle {

    // MARK: - Identity
    var id: UUID

    // MARK: - Properties
    var name: String
    var startDate: Date
    var weekCount: Int
    var isActive: Bool

    // MARK: - Relationships
    @Relationship(deleteRule: .cascade)
    var workoutDays: [WorkoutDay] = []

    // MARK: - Computed (NUNCA persistir valores derivados)
    @Transient
    var durationLabel: String {
        "\(weekCount) semanas"
    }

    // MARK: - Timestamps
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initializers
    init(name: String, weekCount: Int) {
        self.id = UUID()
        self.name = name
        self.weekCount = weekCount
        self.isActive = false
        self.createdAt = .now
        self.updatedAt = .now
    }
}

// MARK: - Preview Data
extension Mesocycle {
    static var previewData: [Mesocycle] {
        let meso = Mesocycle(name: "Hipertrofia — Bloque 1", weekCount: 6)
        meso.isActive = true
        return [meso]
    }
}
```

**Reglas SwiftData:**
- `@Model` + `final class` siempre
- `@Relationship(deleteRule: .cascade)` donde proceda — evitar orphans
- `@Transient` para valores calculados (`bodyFatPercent`, `bmi`) — nunca persistirlos
- `previewData` como `static var` en extension
- `createdAt` / `updatedAt` en todos los modelos que sincroniza CloudKit
