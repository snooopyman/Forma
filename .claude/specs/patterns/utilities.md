# Utilities — Concurrencia, Localización, Secrets, Git

Patrones transversales de Forma.

---

## 1. Concurrencia

### Simple

```swift
func loadData() async {
    guard !isLoading else { return }
    isLoading = true
    defer { isLoading = false }

    do {
        data = try await repository.fetchAll()
    } catch {
        handleError(error)
    }
}
```

### Paralela — `async let`

```swift
func loadInitialData() async {
    async let mesocyclesTask = repository.fetchAll()
    async let profileTask = profileRepository.fetchProfile()

    do {
        let (mesocycles, profile) = try await (mesocyclesTask, profileTask)
        self.mesocycles = mesocycles
        self.userProfile = profile
    } catch {
        handleError(error)
    }
}
```

### Con cancelación

```swift
@ObservationIgnored
private var loadTask: Task<Void, Never>?

func startLoading() {
    loadTask?.cancel()
    loadTask = Task { @MainActor in
        guard !Task.isCancelled else { return }
        await loadData()
    }
}
```

### Paginación

```swift
var items: [Item] = []
var isLoading = false
var isLoadingMore = false    // siempre separados de isLoading
var hasMorePages = true

@ObservationIgnored
private var currentPage = 1  // @ObservationIgnored — no debe disparar re-renders

func loadMore() async {
    guard !isLoadingMore, !isLoading, hasMorePages else { return }
    isLoadingMore = true
    defer { isLoadingMore = false }

    let nextPage = currentPage + 1
    do {
        let response = try await repository.fetch(page: nextPage)
        items.append(contentsOf: response.items)
        currentPage = nextPage
        hasMorePages = response.hasMore
    } catch {
        handleError(error)
    }
}
```

```swift
// View — threshold de 3 items antes del final
ForEach(viewModel.items) { item in
    ItemRow(item: item)
        .task {
            let threshold = max(0, viewModel.items.count - 3)
            if let index = viewModel.items.firstIndex(of: item),
               index >= threshold {
                await viewModel.loadMore()
            }
        }
}
```

---

## 2. Localización

### Claves EN naturales

```swift
// ✅ Clave EN legible
Text("Start workout")
Text("Weekly volume")
Button("Save") { }
Text("Set \(setNumber) of \(totalSets)")

// ✅ En ViewModel (strings dinámicos)
errorMessage = String(localized: "Error.generic")

// ✅ Valores numéricos que NO se localizan
Text(verbatim: "\(weight)")  // kg en sesión activa

// ❌ String en español hardcodeado
Text("Iniciar entreno")

// ❌ Clave críptica ilegible
Text("training.session.start.button")
```

### Enum L10n type-safe — para features con muchas keys

```swift
enum L10n {
    enum Common {
        static let ok     = String(localized: "OK")
        static let cancel = String(localized: "Cancel")
        static let save   = String(localized: "Save")
    }
    enum Training {
        enum Button {
            static let start  = String(localized: "Start workout")
            static let finish = String(localized: "Finish workout")
        }
    }
}

Text(L10n.Training.Button.start)
```

### Pluralización — String Catalog, nunca manual

```swift
// ❌ Manual — no funciona en todos los idiomas
let text = count == 1 ? "1 set" : "\(count) sets"

// ✅ String Catalog con pluralización
// xcstrings: one → "1 set", other → "\(n) sets", zero → "No sets"
static func setCount(_ n: Int) -> String {
    String(localized: "Set count \(n)")
}
```

### Previsualizar idiomas en Previews

```swift
#Preview("Español") {
    MesocycleListView()
        .environment(\.locale, Locale(identifier: "es"))
}
```

---

## 3. Secrets — para proyectos con API propia (no aplica en Forma MVP)

```
Secrets.xcconfig (gitignoreado) → Info.plist → Bundle → Keychain
```

```swift
// Al primer arranque, seed desde Bundle → Keychain
@AppStorage("hasSeededToken") private var hasSeededToken = false

private func seedTokenIfNeeded() {
    guard !hasSeededToken,
          let token = Bundle.main.infoDictionary?["API_TOKEN"] as? String,
          !token.isEmpty else { return }
    try? KeychainService().save(token: token, key: "api_token")
    hasSeededToken = true
}
```

```swift
final class KeychainService: Sendable {
    private let service: String

    init(service: String = Bundle.main.bundleIdentifier ?? "com.example.app") {
        self.service = service
    }

    func save(_ value: String, key: String) throws {
        guard let data = value.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem {
            let update: [String: Any] = [kSecValueData as String: data]
            SecItemUpdate(query as CFDictionary, update as CFDictionary)
        }
    }

    func get(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
```

---

## 4. Git — flujo de trabajo Forma

### Formato de commit

```
[tipo](scope): descripción en inglés
```

| Tipo | Uso |
|------|-----|
| `feat` | Feature nueva |
| `fix` | Bug fix |
| `refactor` | Refactoring sin cambio funcional |
| `test` | Tests |
| `docs` | Documentación |
| `chore` | Config, build, herramientas |
| `style` | Formato de código |

```bash
[feat](Training): Add active workout session recording
[fix](Nutrition): Fix macro calculation for partial meals
[refactor](Core): Extract AppContainer to separate file
```

### Versioning semántico

```
0.x.x  → desarrollo pre-MVP
1.0.0  → MVP release
1.1.0  → features nuevas (Watch, Widgets, etc.)
1.1.1  → bug fixes
2.0.0  → cambios mayores
```

---

## 5. Errores comunes — tabla de referencia

| Error | Incorrecto | Correcto |
|-------|-----------|----------|
| Observable antiguo | `ObservableObject` + `@Published` | `@Observable` |
| Actor | Sin `@MainActor` en ViewModel | `@MainActor` |
| Dependencias observadas | `private let service = Service()` | `@ObservationIgnored private let service` |
| Type erasure | `AnyView(someView)` | genéricos o `@ViewBuilder` |
| GCD | `DispatchQueue.main.async` | `Task { @MainActor in }` o `.task` |
| onAppear async | `.onAppear { Task { await vm.load() } }` | `.task { await vm.load() }` |
| Lógica en View | red call en `.task` directo | delegar al ViewModel |
| Repositorio sync | `func fetchAll() -> [T]` | `func fetchAll() async throws -> [T]` |
| Hardcoded español | `Text("Guardar")` | `Text("Save")` con xcstrings |
| Valores numéricos | `.padding(16)` | `.padding(DS.Spacing.lg)` |
| Colores | `.foregroundStyle(.blue)` | `.foregroundStyle(.accent)` |
| print | `print("Error: \(e)")` | `Logger.core.error(...)` |
| SwiftData en View | `@Query var items` en Feature View | via Repository → ViewModel |
| ModelContext en VM | `@Environment(\.modelContext)` en ViewModel | via Repository |
| Formatter legacy | `DateFormatter()`, `String(format:)` | `.formatted()` APIs |
| Test framework | `XCTest`, `XCTAssert` | `Swift Testing`, `#expect` |
| App Group omitido | setup solo cuando se añade widget | setup desde el primer commit |
