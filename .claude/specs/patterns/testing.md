# Testing — Swift Testing Framework

Patrones de testing para Forma. Framework: Swift Testing (nunca XCTest en código nuevo).

---

## Estructura de ficheros

Verificada contra `FormaTests/` actual (2026-07-01) — 75 ficheros, 207 funciones `@Test` en total.

```
FormaTests/
├── Features/
│   └── Training/
│       ├── MesocycleListTests.swift              ← Suite vacío (solo lo define)
│       ├── MesocycleListTests+ViewModel.swift    ← sub-suite ViewModel
│       └── MesocycleListTests+Interactor.swift   ← sub-suite Interactor
├── Data/
│   └── Repositories/
│       └── MesocycleRepositoryTests.swift        ← Suite propio, independiente de Features/
└── Shared/
    └── Spies/
        └── SpyMesocycleListInteractor.swift      ← Spy con tracking completo
        └── SpyMesocycleRepository.swift
```

Dos correcciones sobre versiones anteriores de este documento:
- El sufijo de sub-suite es `+ViewModel` / `+Interactor` — **no existe** un sub-suite `+Repository` colgando de la feature. Los tests de repositorio viven en `FormaTests/Data/Repositories/{Entity}RepositoryTests.swift`, como `@Suite` de nivel superior independiente.
- El nombre de la feature en los ficheros es el nombre real de la pantalla (`MesocycleList`, no `Mesocycle` a secas).

**Features con tests hoy:** las 15 features con ViewModel+Interactor, con ViewModel + Interactor testeados en los 15 casos (`Dashboard` es la única excepción — tiene `SpyDashboardInteractor.swift` huérfano en `Shared/Spies/`, sin ningún test que lo consuma todavía). `BodyChartsView`/`PostWorkoutSummaryView` no tienen ViewModel, así que no aplica.

**Repositorios con Spy:** BodyMeasurement, Mesocycle, Nutrition, WorkoutSession (con tests de repositorio SwiftData-en-memoria además, ver sección "Repository tests" más abajo), FoodItem, ProgressPhoto, UserProfile (con Spy para tests de Interactor, pero **sin** test de repositorio SwiftData-en-memoria propio todavía — pendiente).
**Services con Spy:** HealthKitService, RestTimerActivityService, WorkoutSessionService (solo para tests de Interactor — `WorkoutSessionService` en sí no tiene test propio de servicio todavía).

---

## Suite principal

```swift
import Testing
@testable import Forma

@Suite("Mesocycle List Feature")
struct MesocycleListTests { }
```

## Sub-suite en extensión

```swift
import Testing
@testable import Forma

extension MesocycleListTests {

    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {

        let sut: MesocycleListViewModel
        let spy: SpyMesocycleListInteractor

        init() {
            spy = SpyMesocycleListInteractor()
            sut = MesocycleListViewModel(interactor: spy)
        }

        @Test("load() calls fetchMesocycles and populates mesocycles")
        func loadSuccess() async {
            spy.stubbedMesocycles = Self.sampleMesocycles
            await sut.load()
            #expect(spy.fetchMesocyclesWasCalled == true)
            #expect(sut.mesocycles.count == Self.sampleMesocycles.count)
            #expect(sut.isLoading == false)
            #expect(sut.errorMessage == nil)
        }

        @Test("load() sets errorMessage on failure")
        func loadFailure() async {
            spy.shouldThrowError = true
            spy.errorToThrow = TrainingError.loadFailed
            await sut.load()
            #expect(sut.errorMessage == TrainingError.loadFailed.errorDescription)
            #expect(sut.mesocycles.isEmpty)
            #expect(sut.isLoading == false)
        }
    }
}

// MARK: - Test Data
private extension MesocycleListTests.ViewModelTests {
    static let sampleMesocycles: [Mesocycle] = [
        Mesocycle(name: "Strength Block", durationWeeks: 4),
        Mesocycle(name: "Hypertrophy", durationWeeks: 6)
    ]
}
```

El Interactor se testea igual, pero con un Spy de repositorio/servicio en vez de un Spy de interactor — ver `MesocycleListTests+Interactor.swift`. **Esto es una regla universal, no una opción**: el `sut` de cada sub-suite `+Interactor` es siempre la clase Interactor real (`{Feature}Interactor`), nunca su propio Spy — el mismo patrón que usa Inku (SDP26/Apple Coding Academy, ver `.claude/specs/analysis/`). Verificado 2026-07-01: un audit encontró que 13 de las 15 sub-suites `+Interactor` (todas menos `MesocycleList` y `ProgressOverview`) probaban su propio `Spy{Feature}Interactor` en vez del Interactor real — dejando las 13 clases Interactor de producción sin cobertura. Se corrigieron las 13, creando Spies de repositorio/servicio donde faltaban (`SpyFoodItemRepository`, `SpyUserProfileRepository`, `SpyProgressPhotoRepository`, `SpyHealthKitService`, `SpyRestTimerActivityService`, `SpyWorkoutSessionService`) y extendiendo con tracking real los que tenían métodos como no-op (`SpyNutritionRepository`, `SpyBodyMeasurementRepository`, `SpyMesocycleRepository`).

Los `Spy{Feature}Interactor` (en `Shared/Spies/`) **no desaparecen** — siguen siendo el doble que usa la sub-suite `+ViewModel` de la misma feature, exactamente como en Inku (`ViewModelTests` usa `Spy{Feature}Interactor`, `InteractorTests` usa `Spy{Entity}Repository`/`Spy{Service}`). Cada capa se testea contra el doble de la capa inmediatamente inferior, nunca contra un doble de sí misma.

---

## Tests parametrizados

```swift
@Test(
    "handleError maps domain errors correctly",
    arguments: [
        ErrorCase(error: TrainingError.loadFailed,      expected: TrainingError.loadFailed.errorDescription ?? ""),
        ErrorCase(error: TrainingError.deleteFailed,    expected: TrainingError.deleteFailed.errorDescription ?? ""),
        ErrorCase(error: TrainingError.setActiveFailed, expected: TrainingError.setActiveFailed.errorDescription ?? "")
    ]
)
private func handleErrorTypes(errorCase: ErrorCase) async {
    spy.shouldThrowError = true
    spy.errorToThrow = errorCase.error
    await sut.load()
    #expect(sut.errorMessage == errorCase.expected)
}

private extension MesocycleListTests.ViewModelTests {
    struct ErrorCase: CustomTestStringConvertible {
        let error: TrainingError
        let expected: String
        var testDescription: String { "\(error) → \(expected)" }
    }
}
```

---

## Assertions modernas

```swift
#expect(sut.mesocycles.count == 3)
#expect(sut.errorMessage == nil)
#expect(!sut.isLoading)
#expect(spy.fetchMesocyclesWasCalled)

// Con #require para desempaquetar de forma segura dentro de un test
let target = try #require(sut.mesocycles.first)

// Llamadas concurrentes (ej. comprobar que un guard evita doble carga)
async let first: Void = sut.load()
async let second: Void = sut.load()
_ = await (first, second)
```

---

## Spy — para tests con tracking completo

```swift
// FormaTests/Shared/Spies/SpyMesocycleListInteractor.swift — solo en el test target
final class SpyMesocycleListInteractor: MesocycleListInteractorProtocol, @unchecked Sendable {

    // MARK: - Spy Tracking
    private(set) var fetchMesocyclesWasCalled = false
    private(set) var deleteMesocycleWasCalled = false
    private(set) var setActiveMesocycleWasCalled = false
    private(set) var lastDeletedMesocycle: Mesocycle?
    private(set) var lastActivatedMesocycle: Mesocycle?

    // MARK: - Stub Data
    var stubbedMesocycles: [Mesocycle] = []
    var shouldThrowError = false
    var errorToThrow: Error = TrainingError.loadFailed

    // MARK: - Functions
    func reset() {
        fetchMesocyclesWasCalled = false
        deleteMesocycleWasCalled = false
        setActiveMesocycleWasCalled = false
        lastDeletedMesocycle = nil
        lastActivatedMesocycle = nil
    }

    func fetchMesocycles() async throws -> [Mesocycle] {
        fetchMesocyclesWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedMesocycles
    }

    func deleteMesocycle(_ mesocycle: Mesocycle) async throws {
        deleteMesocycleWasCalled = true
        lastDeletedMesocycle = mesocycle
        if shouldThrowError { throw errorToThrow }
    }

    func setActiveMesocycle(_ mesocycle: Mesocycle) async throws {
        setActiveMesocycleWasCalled = true
        lastActivatedMesocycle = mesocycle
        if shouldThrowError { throw errorToThrow }
    }
}
```

Convenciones del Spy, verificadas: tracking `private(set)` con sufijo `WasCalled` + `last*` para capturar argumentos; stub mutable con prefijo `stubbed*`; `shouldThrowError` + `errorToThrow: Error` configurable (no un único `RepositoryError.unknown` fijo — se le asigna el error tipado del módulo que se quiera probar); `reset()` solo limpia el tracking, no los stubs.

**`@unchecked Sendable`** — necesario porque los Spies guardan estado mutable y se usan desde contextos async. Apropiado porque los tests son secuenciales y cada test crea su propio Spy en el `init` de la suite (no se comparte estado entre tests).

**No existen mocks de repositorio en `Data/Repositories/`** (ver `.claude/specs/patterns/data-patterns.md`, sección 1) — para Previews se usa `PreviewContainer` + `PreviewSeedData` con SwiftData real en memoria, no mocks.

---

## Repository tests — SwiftData en memoria

```swift
@Suite("Mesocycle Repository Tests")
@MainActor
struct MesocycleRepositoryTests {

    let sut: MesocycleRepository
    let modelContainer: ModelContainer

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: Mesocycle.self, WorkoutDay.self, WorkoutSession.self,
            PlannedExercise.self, Exercise.self, LoggedSet.self,
            configurations: config
        )
        sut = MesocycleRepository(modelContext: modelContainer.mainContext)
    }

    @Test("save and fetchAll round-trip preserves name and durationWeeks")
    func saveAndFetch() async throws {
        let mesocycle = Mesocycle(name: "Test", durationWeeks: 4)
        try await sut.save(mesocycle)
        let result = try await sut.fetchAll()
        #expect(result.count == 1)
        #expect(result.first?.name == "Test")
    }
}
```

`ModelConfiguration(isStoredInMemoryOnly: true)` con solo los `@Model` que necesita ese repositorio (no el `Schema` completo de `FormaSchema`) — confirmado en los 4 ficheros de `FormaTests/Data/Repositories/`.

---

## Tags

**No usados todavía.** `grep -rn "@Tag" FormaTests/` no devuelve ningún resultado — no hay ninguna suite ni test marcado con tags hoy. Si se necesitan en el futuro:

```swift
extension Tag {
    @Tag static var viewModel: Self
    @Tag static var interactor: Self
    @Tag static var repository: Self
}

@Test("Carga datos", .tags(.viewModel))
func loadData() async { }
```
