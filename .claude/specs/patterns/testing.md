# Testing — Swift Testing Framework

Patrones de testing para Forma. Framework: Swift Testing (nunca XCTest en código nuevo).

---

## Estructura de ficheros

```
FormaTests/
└── Features/
    └── Mesocycle/
        ├── MesocycleTests.swift              ← Suite vacío (solo lo define)
        ├── MesocycleTests+ViewModel.swift    ← sub-suite ViewModel
        └── MesocycleTests+Repository.swift   ← sub-suite Repository
└── Shared/
    └── Spies/
        └── SpyMesocycleRepository.swift      ← Spy con tracking completo
```

---

## Suite principal

```swift
import Testing
@testable import Forma

@Suite("Mesocycle Feature")
struct MesocycleTests { }
```

## Sub-suite en extensión

```swift
import Testing
@testable import Forma

extension MesocycleTests {

    @Suite("ViewModel")
    @MainActor
    struct ViewModelTests {

        // MARK: - Subject Under Test
        let sut: MesocycleListViewModel
        let spyRepository: SpyMesocycleRepository

        // MARK: - Initializers
        init() {
            spyRepository = SpyMesocycleRepository()
            sut = MesocycleListViewModel(repository: spyRepository)
        }

        // MARK: - Tests
        @Test("Carga mesociclos correctamente")
        func loadMesocyclesSuccess() async {
            spyRepository.mesocyclesToReturn = Mesocycle.previewData

            await sut.loadMesocycles()

            #expect(sut.mesocycles.count == Mesocycle.previewData.count)
            #expect(sut.errorMessage == nil)
            #expect(!sut.isLoading)
            #expect(spyRepository.fetchAllWasCalled)
        }

        @Test("Error establece errorMessage")
        func loadMesocyclesFailure() async {
            spyRepository.shouldThrowError = true

            await sut.loadMesocycles()

            #expect(sut.mesocycles.isEmpty)
            #expect(sut.errorMessage != nil)
            #expect(!sut.isLoading)
        }
    }
}
```

---

## Tests parametrizados

```swift
@Test(
    "Filtra mesociclos por estado activo",
    arguments: [
        FilterArgument(onlyActive: true, expectedCount: 1),
        FilterArgument(onlyActive: false, expectedCount: 3)
    ]
)
func filterMesocycles(argument: FilterArgument) async {
    spyRepository.mesocyclesToReturn = Self.sampleMesocycles
    await sut.loadMesocycles()
    sut.onlyActive = argument.onlyActive
    #expect(sut.filtered.count == argument.expectedCount)
}

private extension MesocycleTests.ViewModelTests {
    struct FilterArgument: CustomTestStringConvertible {
        let onlyActive: Bool
        let expectedCount: Int

        var testDescription: String {
            "onlyActive: \(onlyActive) → esperados: \(expectedCount)"
        }
    }
}
```

---

## Assertions modernas

```swift
#expect(viewModel.items.count == 3)
#expect(viewModel.errorMessage == nil)
#expect(!viewModel.isLoading)
#expect(spy.fetchAllWasCalled)

// Error esperado
await #expect(throws: RepositoryError.unknown) {
    try await repository.fetchAll()
}

// Sin error
await #expect(throws: Never.self) {
    try await repository.save(mesocycle)
}
```

---

## Spy — para tests con tracking completo

```swift
// Solo en el test target
final class SpyMesocycleRepository: MesocycleRepositoryProtocol, @unchecked Sendable {

    // MARK: - Tracking
    private(set) var fetchAllWasCalled = false
    private(set) var lastSaved: Mesocycle?
    private(set) var lastDeleted: Mesocycle?

    // MARK: - Stub
    var mesocyclesToReturn: [Mesocycle] = []
    var shouldThrowError = false
    var errorToThrow: Error = RepositoryError.unknown

    func fetchAll() async throws -> [Mesocycle] {
        fetchAllWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return mesocyclesToReturn
    }

    func save(_ mesocycle: Mesocycle) async throws {
        lastSaved = mesocycle
        if shouldThrowError { throw errorToThrow }
    }

    func delete(_ mesocycle: Mesocycle) async throws {
        lastDeleted = mesocycle
        if shouldThrowError { throw errorToThrow }
    }

    // MARK: - Helpers
    func reset() {
        fetchAllWasCalled = false
        lastSaved = nil
        lastDeleted = nil
        mesocyclesToReturn = []
        shouldThrowError = false
    }
}
```

**`@unchecked Sendable`** — necesario porque los Spies guardan estado mutable y se usan desde contextos async. Apropiado porque los tests son secuenciales y el estado se resetea entre tests.

---

## Tags para filtrar tests

```swift
extension Tag {
    @Tag static var viewModel: Self
    @Tag static var repository: Self
    @Tag static var integration: Self
}

@Test("Carga datos", .tags(.viewModel))
func loadData() async { }
```
