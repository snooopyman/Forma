# UI Patterns — ViewModel, View, Property Wrappers, MARK

Patrones de capa de presentación para Forma. Ver `.claude/specs/patterns/data-patterns.md` para el patrón de Interactor que vive entre el ViewModel y los repositorios/servicios.

---

## 1. ViewModel — patrón completo

```swift
@Observable
@MainActor
final class MesocycleListViewModel: MesocycleListViewModelProtocol {

    // MARK: - Private Properties

    @ObservationIgnored
    private let interactor: MesocycleListInteractorProtocol

    // MARK: - States

    var mesocycles: [Mesocycle] = []
    var isLoading = false
    var errorMessage: String?

    // MARK: - Computed Properties

    var activeMesocycle: Mesocycle? {
        mesocycles.first { $0.isActive }
    }

    // MARK: - Initializers

    init(interactor: MesocycleListInteractorProtocol) {
        self.interactor = interactor
    }

    // MARK: - Functions

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            mesocycles = try await interactor.fetchMesocycles()
        } catch {
            handleError(error)
        }
    }

    func delete(_ mesocycle: Mesocycle) async {
        do {
            try await interactor.deleteMesocycle(mesocycle)
            mesocycles.removeAll { $0.id == mesocycle.id }
        } catch {
            handleError(error)
        }
    }

    // MARK: - Private Functions

    private func handleError(_ error: Error) {
        Logger.training.error("Error: \(error, privacy: .private)")
        if let trainingError = error as? TrainingError {
            errorMessage = trainingError.errorDescription
        } else {
            errorMessage = L10n.Error.generic
        }
    }
}
```

### Reglas críticas del ViewModel

| Regla | Correcto | Incorrecto |
|-------|----------|------------|
| Observable | `@Observable` | `ObservableObject` + `@Published` |
| Actor | `@MainActor` (en la clase y en su protocolo) | sin marcador |
| Tipo | `final class` | `struct` o `class` sin `final` |
| Dependencias | `@ObservationIgnored private let interactor: {Feature}InteractorProtocol` | dependencia directa a un repositorio/servicio, o sin `@ObservationIgnored` |
| DI | recibe el **Interactor** (nunca un repositorio) en `init` | repositorio/servicio concreto inyectado directamente |
| Logging | `Logger.subsystem.error(...)` | `print(...)` |
| Errores | `handleError(_:)` privado, mapea el error tipado del módulo (`TrainingError`, `NutritionError`, `ProgressError`, `SettingsError`) | mensaje de error genérico sin tipar |

**Por qué `@ObservationIgnored` en dependencias:** `@Observable` convierte TODAS las propiedades en observadas. Las dependencias nunca cambian → no deben disparar re-renders.

**MARK order verificado** (`DashboardViewModel.swift`, `MesocycleListViewModel.swift`): `Private Properties` → `States` → `Computed Properties` → `Initializers` → `Functions` → `Private Functions`.

---

## 2. Property wrappers — árbol de decisión

```
¿Qué tipo de dato es?
│
├─ ViewModel (@Observable) que la View crea y posee
│   └─ @State private var
│
├─ ViewModel @Observable inyectado por @Environment/@Entry (pantallas tab-root)
│   └─ @Environment(\.{feature}ViewModel) private var viewModel
│
├─ ViewModel @Observable recibido del padre (necesita $binding)
│   └─ @Bindable var viewModel
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
└─ Valor de Environment (sistema o inyectado: AppContainer, ViewModel de pantalla raíz)
    └─ @Environment(\.key) o @Environment(Type.self)
```

---

## 3. Dos formas de construir el ViewModel — según la pantalla

Forma usa **dos mecanismos de inyección distintos**, según si la pantalla es una de las 4 raíces de tab (Dashboard, MesocycleList, PlanOverview, ProgressOverview), o cualquier otra. `ActiveSession` es un caso aparte: tiene `ViewModelProtocol`+`MockViewModel` como las 4 raíces, pero no usa `@Entry`/`@Environment` — construye el ViewModel directamente, como el grupo 3b.

### 3a. Pantallas con `ViewModelProtocol` + `@Entry` (las 4 tab-root)

El ViewModel se construye **una sola vez** en `MainTabView`, dentro de `.task`, y se inyecta vía `@Environment`/`@Entry` — la View no lo construye:

```swift
// Features/Training/MesocycleList/MesocycleListViewModelProtocol.swift
@MainActor
protocol MesocycleListViewModelProtocol: AnyObject {
    var mesocycles: [Mesocycle] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get set }
    func load() async
    func delete(_ mesocycle: Mesocycle) async
    func setActive(_ mesocycle: Mesocycle) async
}

extension EnvironmentValues {
    @Entry var mesocycleListViewModel: (any MesocycleListViewModelProtocol)? = nil
}
```

```swift
// App/MainTabView.swift
@State private var mesocycleListViewModel: MesocycleListViewModel?

var body: some View {
    TabView(selection: $selectedTab) {
        Tab(L10n.Tab.training, systemImage: "figure.strengthtraining.traditional", value: AppTab.training) {
            NavigationStack { MesocycleListView() }
        }
        // ...
    }
    .environment(\.mesocycleListViewModel, mesocycleListViewModel)
    .task {
        guard dashboardViewModel == nil else { return }
        mesocycleListViewModel = MesocycleListViewModel(
            interactor: MesocycleListInteractor(repository: container.mesocycleRepository)
        )
        // ... resto de ViewModels tab-root
    }
}
```

```swift
// Features/Training/MesocycleList/MesocycleListView.swift
struct MesocycleListView: View {
    @Environment(AppContainer.self) private var container
    @Environment(\.mesocycleListViewModel) private var viewModel  // opcional — puede ser nil un instante en el arranque

    var body: some View {
        Group {
            if let viewModel {
                mainContent(viewModel)
            } else {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task { await viewModel?.load() }
    }
}
```

Previews para estas pantallas inyectan un `Mock{Feature}ViewModel` por el mismo entorno:

```swift
#Preview("With data") {
    NavigationStack { MesocycleListView() }
        .environment(\.mesocycleListViewModel, MockMesocycleListViewModel.withData)
}
```

### 3b. El resto de pantallas — construcción directa en `init`

Sin `ViewModelProtocol` ni `@Entry`. La View recibe lo que necesita en su `init` (o lo lee de `@Environment(AppContainer.self)`) y construye su propio ViewModel+Interactor con `@State`:

```swift
struct SomeDetailView: View {
    @State private var viewModel: SomeDetailViewModel

    init(entity: SomeEntity, repository: SomeRepositoryProtocol) {
        _viewModel = State(initialValue: SomeDetailViewModel(
            interactor: SomeDetailInteractor(repository: repository)
        ))
    }
}
```

---

## 4. View — patrón completo (pantalla tab-root real)

```swift
struct MesocycleListView: View {

    // MARK: - Environment

    @Environment(AppContainer.self) private var container
    @Environment(\.mesocycleListViewModel) private var viewModel

    // MARK: - States

    @AppStorage("postOnboardingAction") private var postOnboardingAction: AppTab = .today
    @State private var showingCreate = false

    // MARK: - Body

    var body: some View {
        Group {
            if let viewModel {
                mainContent(viewModel)
            } else {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle(String(localized: "Training"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingCreate = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showingCreate) {
            CreateMesocycleView { Task { await viewModel?.load() } }
        }
        .task { await viewModel?.load() }
        .refreshable { await viewModel?.load() }
    }

    // MARK: - Private Views

    @ViewBuilder
    private func mainContent(_ viewModel: any MesocycleListViewModelProtocol) -> some View {
        Group {
            if viewModel.isLoading && viewModel.mesocycles.isEmpty {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.mesocycles.isEmpty {
                emptyView
            } else {
                contentView(viewModel)
            }
        }
        .alert(
            String(localized: "Error"),
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button(String(localized: "OK"), role: .cancel) {}
            Button(String(localized: "Retry")) { Task { await viewModel.load() } }
        } message: {
            if let msg = viewModel.errorMessage { Text(msg) }
        }
    }

    private var emptyView: some View {
        ContentUnavailableView {
            Label(String(localized: "No mesocycles yet"), systemImage: "figure.strengthtraining.traditional")
        } description: {
            Text(String(localized: "Create your first mesocycle to build a structured training routine"))
        } actions: {
            Button { showingCreate = true } label: {
                Text(String(localized: "Create mesocycle")).primaryButtonLabel()
            }
            .buttonStyle(.glassProminent)
            .tint(.accent)
        }
    }
}

// MARK: - Previews

#Preview("Empty") {
    NavigationStack { MesocycleListView() }
        .environment(\.mesocycleListViewModel, MockMesocycleListViewModel.empty)
}

#Preview("With data") {
    NavigationStack { MesocycleListView() }
        .environment(\.mesocycleListViewModel, MockMesocycleListViewModel.withData)
}

#Preview("Error") {
    NavigationStack { MesocycleListView() }
        .environment(\.mesocycleListViewModel, MockMesocycleListViewModel.withError)
}
```

### Reglas de la View

- Sin lógica de negocio — delega todo al ViewModel
- Sin acceso directo a SwiftData — nunca `@Query` en Feature Views
- ViewModel inyectado como opcional (`@Environment(\.{feature}ViewModel)`) en pantallas tab-root, o poseído con `@State` en el resto — nunca instanciado de cero dentro de `body`
- `.task { }` cancela automáticamente al desaparecer — preferir sobre `.onAppear + Task`
- `.refreshable { }` — pull-to-refresh gratis con async/await
- `Group` para agrupar estados: cargando / vacío / contenido / error
- `@ViewBuilder` en funciones/computed properties privadas — permite `if/switch` en vistas privadas
- `navigationDestination` en la View raíz, no en cada row
- Mínimo 2-3 previews por pantalla: con datos, vacío, error (las pantallas con `ViewModelProtocol` los inyectan vía `Mock*ViewModel`; el resto construye el ViewModel real con datos de ejemplo)

### `@Bindable` para vistas hijo que necesitan `$binding`

```swift
struct ParentView: View {
    @State private var viewModel = SomeViewModel()
    var body: some View { ChildView(viewModel: viewModel) }
}

struct ChildView: View {
    @Bindable var viewModel: SomeViewModel  // ← @Bindable, no @State
    var body: some View { Toggle("Active", isOn: $viewModel.isActive) }
}
```

---

## 5. Estructura de archivos

```
Features/{Módulo}/
├── {Módulo}View.swift
├── {Módulo}ViewModel.swift
├── {Módulo}ViewModelProtocol.swift   ← solo en 5 pantallas: las 4 tab-root (inyectadas vía @Entry) +
│                                        ActiveSession (protocolo+mock sin @Entry, construcción directa)
├── Mock{Módulo}ViewModel.swift       ← idem
└── Interactor/
    ├── {Módulo}Interactor.swift
    ├── {Módulo}InteractorProtocol.swift
    └── Mock{Módulo}Interactor.swift

Domain/
├── Models/          ← @Model SwiftData
└── Repositories/    ← solo protocolos (RepositoryProtocol)

Data/
├── Repositories/    ← implementaciones concretas (Repository)
└── Services/        ← HealthKit, métricas, lógica de negocio

Shared/DesignSystem/ ← componentes reutilizables en 2+ vistas
```

**Regla universal:** componente de un solo archivo → `private struct` dentro. Componente en 2+ vistas → archivo propio.
