# Data Layer Patterns — Repository, Interactor, AppContainer, ModelContainer, SwiftData

Patrones de la capa de datos de Forma. Flujo completo: View → ViewModel → Interactor → Repository/Service → SwiftData / HealthKit / CloudKit.

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
    func setActive(_ mesocycle: Mesocycle) async throws
    func pause(_ mesocycle: Mesocycle) async throws
    func resume(_ mesocycle: Mesocycle) async throws
    func addWorkoutDay(_ day: WorkoutDay, to mesocycle: Mesocycle) async throws
    func addPlannedExercise(_ planned: PlannedExercise, exercise: Exercise, to day: WorkoutDay) async throws
    func updatePlannedExercise(_ planned: PlannedExercise, name: String, muscle: MuscleGroup, sets: Int, repsMin: Int, repsMax: Int, rir: Int, restSeconds: Int) async throws
    func deletePlannedExercise(_ planned: PlannedExercise) async throws
}
```

Las 7 protocolos del repositorio (`UserProfileRepositoryProtocol`, `MesocycleRepositoryProtocol`, `WorkoutSessionRepositoryProtocol`, `BodyMeasurementRepositoryProtocol`, `ProgressPhotoRepositoryProtocol`, `NutritionRepositoryProtocol`, `FoodItemRepositoryProtocol`) declaran `: Sendable` y todos sus métodos son `async throws`. No existe `NutritionPlanRepositoryProtocol` — el protocolo de nutrición se llama `NutritionRepositoryProtocol` y cubre `NutritionPlan`, `Meal`, `MealOption`, `MealOptionItem`, `DailyNutritionLog` y `MealLog`.

### Implementación concreta (Data/Repositories/)

Cada repositorio lanza su propio error tipado (`TrainingError`, `SettingsError`, `NutritionError`, `ProgressError` según el módulo), nunca un `RepositoryError` genérico:

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
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            throw TrainingError.loadFailed
        }
    }

    func save(_ mesocycle: Mesocycle) async throws {
        modelContext.insert(mesocycle)
        do {
            try modelContext.save()
        } catch {
            throw TrainingError.saveFailed
        }
    }

    func delete(_ mesocycle: Mesocycle) async throws {
        modelContext.delete(mesocycle)
        do {
            try modelContext.save()
        } catch {
            throw TrainingError.deleteFailed
        }
    }

    // setActive, pause, resume, addWorkoutDay, addPlannedExercise,
    // updatePlannedExercise, deletePlannedExercise siguen el mismo patrón:
    // mutar el @Model, try modelContext.save(), catch → error tipado del módulo
}
```

Son `final class` planas — no hay `@ModelActor` ni anotaciones de aislamiento propias; el `ModelContext` que reciben en el `init` ya vive en main actor (viene de `AppRootView`'s `@Environment(\.modelContext)` vía `AppContainer`).

### No existen Mocks de repositorio

A diferencia de versiones anteriores de este documento: **no hay `MockMesocycleRepository` ni ningún otro mock de repositorio en `Data/Repositories/`** — confirmado, no existe ningún fichero `Mock*Repository.swift` en el proyecto, y no hay `previewData` estático en ningún modelo. Los dos mecanismos reales para sustituir un repositorio son:

| | Mock de Interactor | Spy de Repository |
|---|---|---|
| Ubicación | `Features/{Feature}/Interactor/Mock{Feature}Interactor.swift` | `FormaTests/Shared/Spies/Spy{Entity}Repository.swift` |
| Propósito | Previews y tests de ViewModel en las 5 features con `ViewModelProtocol` | Tests de Interactor y de Repository, con tracking detallado |
| Conforma a | `{Feature}InteractorProtocol` | `{Entity}RepositoryProtocol` |
| Tracking | Mínimo (`shouldThrowOnLoad`) | Completo (`*WasCalled`, `last*`, `reset()`) |
| Import | Sin imports de test — vive en el target de la app | `import Testing` / `@testable import Forma` |
| Sendable | Normal | `@unchecked Sendable` |

Las Previews que necesitan datos reales en SwiftData usan `PreviewContainer` (ver sección 5), no mocks de repositorio.

---

## 2. Interactor — orquestación entre ViewModel y Repository/Service

El Interactor recibe los repositorios/servicios que necesita en su `init` y expone un método de alto nivel que el ViewModel llama. Es `final class`, conforma a un protocolo `Sendable`, y **no** lleva `@MainActor` — solo el ViewModel y su protocolo lo llevan.

```swift
// Features/Dashboard/Interactor/DashboardInteractorProtocol.swift
struct DashboardSnapshot: Sendable {
    let activeMesocycle: Mesocycle?
    let todayWorkoutDay: WorkoutDay?
    let inProgressSession: WorkoutSession?
    let isTodaySessionCompleted: Bool
    let weeklyCompletedSessions: Int
    let weeklyPlannedDays: Int
    let macroSummary: DailyMacroSummary?
    let hasActivePlan: Bool
    let showMeasurementReminder: Bool
}

protocol DashboardInteractorProtocol: Sendable {
    var isHealthKitAvailable: Bool { get }
    func loadDashboardData() async throws -> DashboardSnapshot
    func requestHealthKitAccess() async throws
    func refreshHealthData() async -> HealthSnapshot
}
```

```swift
// Features/Dashboard/Interactor/DashboardInteractor.swift
final class DashboardInteractor: DashboardInteractorProtocol {

    private let mesocycleRepo: MesocycleRepositoryProtocol
    private let sessionRepo: WorkoutSessionRepositoryProtocol
    private let nutritionRepo: NutritionRepositoryProtocol
    private let measurementRepo: BodyMeasurementRepositoryProtocol
    private let macroService: MacroTrackingServiceProtocol
    private let healthKitService: HealthKitServiceProtocol

    init(
        mesocycleRepo: MesocycleRepositoryProtocol,
        sessionRepo: WorkoutSessionRepositoryProtocol,
        nutritionRepo: NutritionRepositoryProtocol,
        measurementRepo: BodyMeasurementRepositoryProtocol,
        macroService: MacroTrackingServiceProtocol,
        healthKitService: HealthKitServiceProtocol
    ) {
        self.mesocycleRepo = mesocycleRepo
        // ...
    }

    func loadDashboardData() async throws -> DashboardSnapshot {
        let mesocycle = try await mesocycleRepo.fetchActive()
        let inProgress = try await sessionRepo.fetchInProgress()
        let measurement = try await measurementRepo.fetchLatest()
        let plan = try await nutritionRepo.fetchActivePlan()
        // ... combina y deriva el resto de campos del snapshot
        return DashboardSnapshot(/* ... */)
    }

    func refreshHealthData() async -> HealthSnapshot {
        async let steps = healthKitService.fetchTodaySteps()
        async let calories = healthKitService.fetchTodayActiveCalories()
        async let minutes = healthKitService.fetchTodayExerciseMinutes()
        let (s, c, m) = await (steps, calories, minutes)
        return HealthSnapshot(steps: s, activeCalories: c, exerciseMinutes: m)
    }
}
```

El ViewModel **nunca** llama a un repositorio o servicio directamente — solo al Interactor:

```swift
@Observable
@MainActor
final class DashboardViewModel: DashboardViewModelProtocol {

    @ObservationIgnored private let interactor: DashboardInteractorProtocol

    var activeMesocycle: Mesocycle?
    // ...

    init(interactor: DashboardInteractorProtocol) {
        self.interactor = interactor
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let snapshot = try await interactor.loadDashboardData()
            activeMesocycle = snapshot.activeMesocycle
            // ... mapea el resto de campos del snapshot a propiedades observables
        } catch {
            handleError(error)
        }
    }

    private func handleError(_ error: Error) {
        Logger.core.error("Error: \(error, privacy: .private)")
        if let trainingError = error as? TrainingError {
            errorMessage = trainingError.errorDescription
        } else if let nutritionError = error as? NutritionError {
            errorMessage = nutritionError.errorDescription
        } else if let progressError = error as? ProgressError {
            errorMessage = progressError.errorDescription
        } else {
            errorMessage = L10n.Error.generic
        }
    }
}
```

`handleError` no está abstraído en una clase base — cada ViewModel reimplementa su propia versión, normalmente comprobando solo el(los) tipo(s) de error de su propio módulo (algunos, como Dashboard, combinan varios módulos y comprueban varios tipos).

**Cobertura del patrón:** las 15 features con ViewModel tienen su Interactor. 5 (Dashboard, MesocycleList, PlanOverview, ProgressOverview, ActiveSession) añaden además `{Feature}ViewModelProtocol` + `Mock{Feature}ViewModel`, pero solo las 4 tab-root inyectan el ViewModel completo por `@Environment`/`@Entry` — `ActiveSession` tiene protocolo+mock pero construye el ViewModel directamente vía `@State` en el `init` de la View. El resto construye ViewModel+Interactor directamente en el `init` de la View, sin protocolo. `BodyChartsView` y `PostWorkoutSummaryView` no tienen ni ViewModel ni Interactor.

---

## 2.5 AppContainer — inyección de dependencias

```swift
// App/AppContainer.swift
@Observable
final class AppContainer {

    // MARK: - Repositories

    let userProfileRepository: UserProfileRepositoryProtocol
    let mesocycleRepository: MesocycleRepositoryProtocol
    let workoutSessionRepository: WorkoutSessionRepositoryProtocol
    let bodyMeasurementRepository: BodyMeasurementRepositoryProtocol
    let progressPhotoRepository: ProgressPhotoRepositoryProtocol
    let nutritionRepository: NutritionRepositoryProtocol
    let foodItemRepository: FoodItemRepositoryProtocol

    // MARK: - Services

    let workoutSessionService: WorkoutSessionServiceProtocol
    let volumeCalculatorService: VolumeCalculatorServiceProtocol
    let restTimerActivityService: RestTimerActivityServiceProtocol
    let macroTrackingService: MacroTrackingServiceProtocol
    let bodyMetricsService: BodyMetricsServiceProtocol
    let healthKitService: HealthKitServiceProtocol

    // MARK: - Initializers

    init(modelContext: ModelContext) {
        self.userProfileRepository = UserProfileRepository(modelContext: modelContext)
        self.mesocycleRepository = MesocycleRepository(modelContext: modelContext)
        let sessionRepo = WorkoutSessionRepository(modelContext: modelContext)
        self.workoutSessionRepository = sessionRepo
        // ... resto de repositorios
        self.workoutSessionService = WorkoutSessionService(sessionRepository: sessionRepo)
        self.volumeCalculatorService = VolumeCalculatorService()
        // ... resto de servicios

        // Seed del catálogo de alimentos, una sola vez (flag en UserDefaults)
    }
}
```

**Todas** las propiedades son tipos protocolo — nunca tipos concretos. No hay `static var preview` en `AppContainer`: el `init(modelContext:)` es el único inicializador; las Previews construyen un `AppContainer` real apuntando a un `ModelContext` en memoria (ver sección 5), no una variante "preview" especial.

```swift
// FormaApp.swift (no está dentro de App/)
@main
struct FormaApp: App {
    var body: some Scene {
        WindowGroup {
            if let modelContainer = FormaModelContainer.shared {
                AppRootView()
                    .modelContainer(modelContainer)
            } else {
                ContentUnavailableView(
                    "Unable to load Forma",
                    systemImage: "exclamationmark.triangle",
                    description: Text("Restart the app. If the problem persists, reinstall Forma.")
                )
            }
        }
    }
}
```

No se usa la API `.modelContainer(for:) { result in ... }` de SwiftUI. En su lugar, `FormaModelContainer.shared` es un `ModelContainer?` precalculado (ver sección 3) que ya intentó CloudKit, luego local-only, y solo es `nil` si todo falló — en ese caso se muestra un `ContentUnavailableView` en vez de crashear. `AppContainer` se construye dentro de `AppRootView` a partir de `@Environment(\.modelContext)`, no dentro de `FormaApp`.

---

## 3. ModelContainer — App Group obligatorio desde el primer commit

Widget y app son **dos procesos distintos** y no pueden compartir el mismo SQLite. Migrar a App Group después de tener datos implica migración explícita → es doloroso.

```swift
// App/FormaModelContainer.swift
enum FormaModelContainer {

    static let appGroupIdentifier = "group.com.armando.forma"
    private static let databaseFilename = "Forma.sqlite"
    private static let cloudKitIdentifier = "iCloud.com.armando.forma"

    static let shared: ModelContainer? = {
        let schema = Schema(FormaSchema.models)
        // Intenta CloudKit primero; si el entitlement no está provisionado, cae a local-only
        if let container = makeContainer(schema: schema, useCloudKit: true) {
            return container
        }
        Logger.core.warning("CloudKit unavailable — running in local-only mode")
        return makeContainer(schema: schema, useCloudKit: false)
    }()

    private static func makeContainer(schema: Schema, useCloudKit: Bool) -> ModelContainer? {
        let configuration = makeConfiguration(for: schema, useCloudKit: useCloudKit)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            Logger.core.error("ModelContainer init failed (cloudKit=\(useCloudKit)): \(error, privacy: .public)")
            if useCloudKit { return nil }
            return recoverContainer(schema: schema)  // borra el store corrupto y reintenta limpio
        }
    }

    private static func makeConfiguration(for schema: Schema, useCloudKit: Bool) -> ModelConfiguration {
        let cloudKit: ModelConfiguration.CloudKitDatabase = useCloudKit ? cloudKitDatabase : .none
        guard let storeURL = appGroupStoreURL() else {
            return ModelConfiguration(schema: schema, cloudKitDatabase: cloudKit)
        }
        return ModelConfiguration(schema: schema, url: storeURL, cloudKitDatabase: cloudKit)
    }

    private static var cloudKitDatabase: ModelConfiguration.CloudKitDatabase {
        #if targetEnvironment(simulator)
        .none   // el simulador no tiene entitlements de CloudKit
        #else
        .private(cloudKitIdentifier)
        #endif
    }

    private static func appGroupStoreURL() -> URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)?
            .appendingPathComponent(databaseFilename)
    }
}
```

Si la apertura del store falla por corrupción, `recoverContainer` borra `Forma.sqlite`/`-shm`/`-wal` y reintenta con un store limpio antes de devolver `nil`.

**Configurar el App Group desde el primer commit, aunque el widget sea V1.1.**

---

## 4. Modelos SwiftData

```swift
@Model
final class Mesocycle {

    var id: UUID
    var name: String
    var startDate: Date
    var durationWeeks: Int
    var useFixedDays: Bool
    var isActive: Bool
    var pausedAt: Date?
    var resumedAt: Date?
    var notes: String

    @Relationship(deleteRule: .cascade)
    var workoutDays: [WorkoutDay]

    @Relationship(deleteRule: .cascade)
    var sessions: [WorkoutSession]

    init(
        id: UUID = UUID(),
        name: String,
        startDate: Date = .now,
        durationWeeks: Int = 6,
        useFixedDays: Bool = true,
        isActive: Bool = false,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.durationWeeks = durationWeeks
        self.useFixedDays = useFixedDays
        self.isActive = isActive
        self.notes = notes
        self.workoutDays = []
        self.sessions = []
    }

    var isPaused: Bool { pausedAt != nil && resumedAt == nil }

    var endDate: Date {
        Calendar.current.date(byAdding: .weekOfYear, value: durationWeeks, to: startDate) ?? startDate
    }

    var currentWeek: Int {
        guard !isPaused else { return 0 }
        let weeks = Calendar.current.dateComponents([.weekOfYear], from: startDate, to: .now).weekOfYear ?? 0
        return min(weeks + 1, durationWeeks)
    }
}
```

**Reglas SwiftData — verificadas contra el código actual:**
- `@Model` + `final class` siempre
- `@Relationship(deleteRule: .cascade)` donde proceda — evitar orphans (ej. `workoutDays`, `sessions` en `Mesocycle`)
- Métricas calculadas como propiedades computadas normales (ej. `bodyFatPercent`/`bmi` en `BodyMeasurement`, `currentWeek`/`endDate`/`isPaused` en `Mesocycle`) — nunca persistirlas. SwiftData ya las excluye al no tener storage; no hace falta `@Transient` explícito
- **Los modelos de Forma no usan `// MARK: -` ni una extensión `previewData` estática** — a diferencia de lo que documentaban versiones anteriores de este fichero. Los datos de ejemplo para Previews viven centralizados en `PreviewSeedData` (sección 5), no en cada modelo

---

## 5. Datos de ejemplo en Previews — `PreviewContainer` + `PreviewSeedData`

No hay `previewData` por modelo ni mocks de repositorio para Previews. En su lugar, `Shared/Preview/PreviewContainer.swift` define un `PreviewModifier` que crea un `ModelContainer` en memoria, opcionalmente lo siembra con `PreviewSeedData`, y construye un `AppContainer` real apuntando a ese contexto:

```swift
struct PreviewContainer: PreviewModifier {
    enum DataContent { case empty, withData }
    static var dataContent: DataContent = .empty

    static func makeSharedContext() async throws -> ModelContainer {
        let schema = Schema(FormaSchema.models)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        if case .withData = dataContent {
            PreviewSeedData.insert(into: container.mainContext)
        }
        return container
    }

    func body(content: Content, context: ModelContainer) -> some View {
        content
            .modelContainer(context)
            .environment(AppContainer(modelContext: context.mainContext))
    }
}

// Uso en un #Preview:
#Preview(traits: .previewContainer(.withData)) {
    DashboardView()
}
```

Los tests de Repository (`FormaTests/Data/Repositories/`) no usan `PreviewContainer` — cada test crea su propio `ModelContainer` en memoria con solo los `@Model` que necesita (ver `.claude/specs/patterns/testing.md`).
