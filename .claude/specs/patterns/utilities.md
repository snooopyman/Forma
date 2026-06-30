# Utilities — Concurrencia, Localización, Logging, Secrets, Git

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

### Con cancelación — patrón real (`ActiveSessionViewModel.startRestTimer`)

```swift
@ObservationIgnored
private var restTimerTask: Task<Void, Never>?

private func startRestTimer(seconds: Int) {
    restTimerTask?.cancel()
    guard seconds > 0 else { return }
    restSecondsRemaining = seconds
    isResting = true

    restTimerTask = Task { [weak self] in
        guard let self else { return }
        await interactor.startRestActivity(exerciseName: exerciseName, seconds: seconds)
        for remaining in stride(from: seconds - 1, through: 0, by: -1) {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { break }
            restSecondsRemaining = remaining
        }
        if !Task.isCancelled {
            isResting = false
            restJustEnded = true
            await interactor.endRestActivity()
        }
    }
}
```

`[weak self]` porque la clase es `final class` con el `Task` guardado como propiedad — sin `weak self` el `Task` retendría al ViewModel indefinidamente mientras corre.

### Paginación — patrón ilustrativo, todavía sin uso real en Forma

Ninguna pantalla de Forma implementa paginación hoy (confirmado: no hay `loadMore`/`hasMorePages`/`isLoadingMore` en el código). Si una lista larga (ej. `FoodBrowserView` con el catálogo de ~250 alimentos) lo necesitara en el futuro, el patrón a seguir:

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
        let response = try await interactor.fetch(page: nextPage)
        items.append(contentsOf: response.items)
        currentPage = nextPage
        hasMorePages = response.hasMore
    } catch {
        handleError(error)
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

### Enum L10n type-safe — `Shared/Localization/L10n.swift`

Estructura real, verificada contra el código (no es solo `Common`/`Training` — cubre todos los módulos con errores tipados):

```swift
enum L10n {
    enum Common {
        static let ok = String(localized: "OK")
        static let cancel = String(localized: "Cancel")
        static let save = String(localized: "Save")
        // done, delete, loading, retry
    }
    enum Error {
        nonisolated static let generic = String(localized: "Something went wrong")
    }
    enum Tab { /* today, training, nutrition, progress */ }
    enum Dashboard { /* goodMorning, goodAfternoon, goodEvening */ }
    enum Training {
        enum Session {
            static let start = String(localized: .TrainingLocalizable.sessionStart)
            static let finish = String(localized: .TrainingLocalizable.sessionFinish)
            // restTimer, invalidSetInput
        }
        enum Error {
            nonisolated static let loadFailed = String(localized: .TrainingLocalizable.errorLoadFailed)
            // saveFailed, deleteFailed, setActiveFailed, sessionNotFound, logSetFailed, finishFailed
        }
    }
    enum Nutrition { enum Meal { /* breakfast, lunch, dinner, snack, postWorkout */ }, enum Error { /* ... */ } }
    enum Progress { enum Error { /* ... */ } }
    enum Settings { enum ICloud { /* syncing, noAccount, restricted, ... */ }, enum Error { /* ... */ } }
    // + WorkoutSession, Weekday, BiologicalSex, ActivityLevel, MacroType
}

Text(L10n.Training.Session.start)
```

Notas:
- Las claves de error (`loadFailed`, `saveFailed`, etc.) son `nonisolated static let` — necesario porque se leen desde `errorDescription` de enums de error (`TrainingError`, `NutritionError`...) que pueden evaluarse fuera de `@MainActor`.
- Algunas claves usan `String(localized: .TrainingLocalizable.sessionStart)` — referencias generadas automáticamente al catálogo de `Localizable.xcstrings` (`LocalizedStringResource` con extensión por tabla), no siempre un literal `String(localized: "...")` directo.
- El sub-enum bajo `Training` se llama `Session`, no `Button`.

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

## 3. Logging — `Logger+Forma.swift`

```swift
extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.armando.forma"

    static let core      = Logger(subsystem: subsystem, category: "core")
    static let training  = Logger(subsystem: subsystem, category: "training")
    static let nutrition = Logger(subsystem: subsystem, category: "nutrition")
    static let progress  = Logger(subsystem: subsystem, category: "progress")
    static let healthKit = Logger(subsystem: subsystem, category: "healthkit")
    static let sync      = Logger(subsystem: subsystem, category: "sync")
}

Logger.training.error("Error: \(error, privacy: .private)")
Logger.healthKit.error("Error: \(error, privacy: .private)")
```

Las 6 categorías reales son `core`, `training`, `nutrition`, `progress`, `healthKit` (categoría string en minúsculas `"healthkit"`), `sync` — no existe categoría `network`. **Nunca `print()` en código de producción.**

---

## 4. Secrets — para proyectos con API propia (no aplica en Forma MVP)

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

## 5. Git — flujo de trabajo Forma

### Formato de commit

`git log` real del proyecto usa Conventional Commits simple, **sin** corchetes ni scope entre paréntesis:

```
tipo: descripción en inglés
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
feat: add interactors, mocks and implementation
fix: non-fixed mesocycle day resolution and add debug data tools
feat: add Spy doubles and ViewModel/Interactor test suites
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

## 6. Errores comunes — tabla de referencia

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
| SwiftData en View | `@Query var items` en Feature View | via Repository → Interactor → ViewModel |
| ModelContext en VM/Interactor | `@Environment(\.modelContext)` en ViewModel | via Repository |
| Repositorio en ViewModel | `init(repository: XRepositoryProtocol)` en un ViewModel | el ViewModel recibe el Interactor; el Interactor recibe el repositorio |
| Formatter legacy | `DateFormatter()`, `String(format:)` | `.formatted()` APIs |
| Test framework | `XCTest`, `XCTAssert` | `Swift Testing`, `#expect` |
| App Group omitido | setup solo cuando se añade widget | setup desde el primer commit |
