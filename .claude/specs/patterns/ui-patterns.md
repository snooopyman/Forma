# UI Patterns — ViewModel, View, Property Wrappers, MARK

Patrones de capa de presentación para Forma.

---

## 1. ViewModel — patrón completo

```swift
@Observable
@MainActor
final class MesocycleListViewModel {

    // MARK: - Private Properties
    @ObservationIgnored
    private let repository: MesocycleRepositoryProtocol

    @ObservationIgnored
    private var loadTask: Task<Void, Never>?

    // MARK: - Properties
    var mesocycles: [Mesocycle] = []
    var isLoading = false
    var errorMessage: String?

    // MARK: - Computed Properties
    var hasActiveMesocycle: Bool {
        mesocycles.contains { $0.isActive }
    }

    // MARK: - Initializers
    init(repository: MesocycleRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Functions
    func loadMesocycles() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            mesocycles = try await repository.fetchAll()
        } catch {
            handleError(error)
        }
    }

    // MARK: - Private Functions
    private func handleError(_ error: Error) {
        Logger.training.error("Error: \(error, privacy: .private)")
        errorMessage = String(localized: "Error.generic")
    }
}
```

### Reglas críticas del ViewModel

| Regla | Correcto | Incorrecto |
|-------|----------|------------|
| Observable | `@Observable` | `ObservableObject` + `@Published` |
| Actor | `@MainActor` | sin marcador |
| Tipo | `final class` | `struct` o `class` sin `final` |
| Dependencias | `@ObservationIgnored private let` | `private let` sin `@ObservationIgnored` |
| DI | recibe protocolo en `init` | instancia concreta interna |
| Logging | `Logger.subsystem.error(...)` | `print(...)` |
| Task almacenada | `@ObservationIgnored private var task` | `private var task` (sería observada) |

**Por qué `@ObservationIgnored` en dependencias:** `@Observable` convierte TODAS las propiedades en observadas. Las dependencias nunca cambian → no deben disparar re-renders.

---

## 2. Property wrappers — árbol de decisión

```
¿Qué tipo de dato es?
│
├─ ViewModel (@Observable) que la View crea y posee
│   └─ @State private var viewModel
│
├─ ViewModel @Observable recibido del padre (necesita $binding)
│   └─ @Bindable var viewModel
│
├─ ViewModel @Observable recibido del padre (solo lectura)
│   └─ let viewModel
│
├─ Valor local simple (Bool, String, Int)
│   └─ @State private var
│
├─ Sincronización bidireccional con padre
│   └─ @Binding var
│
├─ Propiedad dentro de @Observable que NO debe observarse
│   └─ @ObservationIgnored
│
├─ Valor persistido en UserDefaults (flags de UI)
│   └─ @AppStorage
│
└─ Valor de Environment (sistema o inyectado)
    └─ @Environment(\.key) o @Environment(Type.self)
```

---

## 3. View — patrón completo

```swift
struct MesocycleListView: View {

    // MARK: - States
    @State private var viewModel: MesocycleListViewModel
    @State private var showingCreateSheet = false

    // MARK: - Environment
    @Environment(AppContainer.self) private var container

    // MARK: - Initializers
    init(repository: MesocycleRepositoryProtocol) {
        _viewModel = State(initialValue: MesocycleListViewModel(repository: repository))
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.mesocycles.isEmpty {
                    skeletonView
                } else if viewModel.mesocycles.isEmpty {
                    emptyView
                } else {
                    contentView
                }
            }
            .navigationTitle(String(localized: "MesocycleList.title"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    addButton
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreateMesocycleView()
            }
            .alert(
                String(localized: "Error.title"),
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                )
            ) {
                Button(String(localized: "Common.ok"), role: .cancel) { }
                Button(String(localized: "Common.retry")) {
                    Task { await viewModel.loadMesocycles() }
                }
            } message: {
                if let msg = viewModel.errorMessage { Text(msg) }
            }
            .task {
                await viewModel.loadMesocycles()
            }
            .refreshable {
                await viewModel.loadMesocycles()
            }
        }
    }

    // MARK: - Private Views
    @ViewBuilder
    private var contentView: some View {
        List(viewModel.mesocycles) { mesocycle in
            NavigationLink(value: mesocycle) {
                MesocycleRowView(mesocycle: mesocycle)
            }
        }
        .navigationDestination(for: Mesocycle.self) { mesocycle in
            MesocycleDetailView(mesocycle: mesocycle)
        }
    }

    private var emptyView: some View {
        ContentUnavailableView(
            String(localized: "MesocycleList.empty.title"),
            systemImage: "figure.strengthtraining.traditional"
        )
    }

    private var skeletonView: some View {
        ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var addButton: some View {
        Button { showingCreateSheet = true } label: {
            Image(systemName: "plus")
        }
    }
}

// MARK: - Previews
#Preview("Con datos") {
    MesocycleListView(repository: MockMesocycleRepository())
}

#Preview("Vacío") {
    MesocycleListView(repository: MockMesocycleRepository(empty: true))
}

#Preview("Error") {
    MesocycleListView(repository: MockMesocycleRepository(shouldThrowError: true))
}
```

### Reglas de la View

- Sin lógica de negocio — delega todo al ViewModel
- Sin acceso directo a SwiftData — nunca `@Query` en Feature Views
- `@State` para poseer el ViewModel — el ViewModel vive mientras vive la View
- `.task { }` cancela automáticamente al desaparecer — preferir sobre `.onAppear + Task`
- `.task(id:) { }` recarga cuando cambia el valor de `id`
- `.refreshable { }` — pull-to-refresh gratis con async/await
- `Group` para agrupar estados: cargando / vacío / contenido / error
- `@ViewBuilder` en computed properties — permite `if/switch` en vistas privadas
- `navigationDestination` en la View raíz, no en cada row
- Siempre mínimo 2-3 previews: estado normal, vacío y error

### @Bindable para vistas hijo que necesitan $binding

```swift
struct ParentView: View {
    @State private var viewModel = SomeViewModel()

    var body: some View {
        ChildView(viewModel: viewModel)
    }
}

struct ChildView: View {
    @Bindable var viewModel: SomeViewModel  // ← @Bindable, no @State

    var body: some View {
        Toggle("Active", isOn: $viewModel.isActive)
    }
}
```

---

## 4. Estructura de archivos

```
Features/{Módulo}/
├── {Módulo}View.swift
├── {Módulo}ViewModel.swift
└── Components/
    └── {Componente}View.swift

Domain/
├── Models/          ← @Model SwiftData
└── Repositories/    ← solo protocolos (RepositoryProtocol)

Data/
├── Repositories/    ← implementaciones concretas (Repository)
└── Services/        ← HealthKit, métricas, lógica de negocio

Shared/DesignSystem/ ← componentes reutilizables en 2+ vistas
```

**Regla universal:** componente de un solo archivo → `private struct` dentro. Componente en 2+ vistas → archivo propio.
