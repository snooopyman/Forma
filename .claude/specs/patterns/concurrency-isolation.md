# Actor Isolation en Swift 6 / 6.2 — MainActor, nonisolated, actor, @concurrent

Guía de referencia sobre aislamiento de actores en Swift 6.2. Cubre los fundamentos (qué es "isolation", cómo se infiere por tipo de declaración) y las dos features nuevas de Xcode 26 que cambian el comportamiento por defecto: **Default Actor Isolation** (SE-0466) y **Approachable Concurrency** (SE-0461 + otras). Incluye cómo se aplica esto hoy en Forma.

---

## 0. TL;DR

- **Isolation** = a qué "dominio de ejecución" pertenece una declaración (main actor, un actor custom, o ninguno — `nonisolated`). El compilador usa esto para probar en tiempo de compilación que no hay data races.
- Antes de Swift 6.2, todo lo no anotado explícitamente era `nonisolated` por defecto ("presunción de concurrencia"). Esto generaba muchos falsos positivos en apps que son, en la práctica, single-threaded.
- **Swift 6.2 permite cambiar ese default a nivel de módulo/target**: con `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, todo lo no anotado pasa a ser `@MainActor` implícitamente. `nonisolated` sigue existiendo para excluir código puntual de ese default.
- **Swift 6.2 también cambia qué significa `nonisolated` en funciones `async`**: antes saltaban siempre al executor global (background). Ahora, por defecto (`nonisolated(nonsending)`), se quedan en el actor de quien las llama. Si quieres el comportamiento antiguo (saltar a background explícitamente), usas `@concurrent`.
- Forma tiene `SWIFT_APPROACHABLE_CONCURRENCY = YES` activado, pero **no** usa `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` — desde el 2026-07-01 el proyecto está en `nonisolated` (el default clásico, confirmado permanente), ver sección 6. Esto significa que, a diferencia de lo que sugeriría la sección 3 de esta guía, en Forma **nada se infiere como `@MainActor` automáticamente** — cada `@MainActor` en el código es una anotación explícita obligatoria, no una redundancia estética.

---

## 1. Conceptos base

Toda declaración en Swift (función, closure, propiedad, tipo) tiene un **isolation domain**, igual que tiene un nivel de acceso (`private`/`internal`/`public`). Los dominios posibles son:

| Dominio | Significado |
|---|---|
| `nonisolated` | No pertenece a ningún actor. Puede llamarse desde cualquier lado, pero no puede tocar estado mutable aislado de otros. |
| `@MainActor` | Pertenece al main actor (hilo principal). Todo lo marcado así se serializa ahí. |
| `@GlobalActor` custom (`@MyActor`) | Igual que `@MainActor` pero con tu propio actor global singleton. |
| `actor Foo` → dentro de `Foo` | El propio tipo `Foo` es su dominio. Cada instancia serializa su estado. |
| `isolated (any Actor)` param | Aislamiento dinámico: la función es isolated al actor que le pasan como parámetro. |

**Isolation ≠ Sendable.** Son conceptos relacionados pero distintos:
- **Isolation** dice *dónde* corre el código.
- **Sendable** dice si un *valor* puede cruzar de un dominio a otro de forma segura.

---

## 2. Reglas de inferencia clásicas (sin Default Actor Isolation) — `struct` / `class` / `final class` / `actor`

Esto es lo que aplica siempre que **no** actives `-default-isolation MainActor` (o cuando uses `nonisolated` para escapar de él). Es el comportamiento "clásico" de Swift 6.0/6.1.

### `struct`

Las structs no tienen aislamiento propio — cada propiedad/método se infiere individualmente (normalmente `nonisolated`, salvo que herede de un protocolo `@MainActor` o esté anotada explícitamente).

```swift
struct WorkoutSummary {           // nonisolated por defecto
    let totalVolume: Double
    let completedSets: Int
}

@MainActor
struct DashboardSnapshotUI {      // Toda la struct (init, props, métodos) es @MainActor
    let title: String
}
```

Como son value types, dos copias nunca comparten memoria — por eso casi siempre son `Sendable` "gratis" (si todas sus propiedades lo son), independientemente del isolation domain.

### `class` (no final)

Igual que struct: sin anotación, `nonisolated` por defecto. Una `class` normal **no** es `Sendable` automáticamente (referencia mutable compartida = riesgo de data race), salvo que la marques `@MainActor` (entonces el compilador sabe que el acceso está serializado) o la conformes a `Sendable` manualmente asegurando inmutabilidad/sincronización propia.

```swift
class Foo {                      // nonisolated, NO Sendable implícito
    var value = 0                // acceso desde múltiples actors = error de compilación
}

@MainActor
class ViewModel {                 // toda la clase serializada en main actor
    var value = 0                 // seguro: solo se toca desde MainActor
}
```

### `final class`

`final` no cambia las reglas de isolation por sí solo — su efecto es habilitar optimizaciones y, en algunos casos, permitir que el compilador infiera `Sendable` automáticamente si **todas** las propiedades son inmutables (`let`) y `Sendable`:

```swift
final class ImmutableConfig: Sendable {   // OK: final + solo `let` Sendable
    let apiKey: String
    let timeout: Int
}
```

En Forma, los `Repository`/`Service`/Interactor concretos son `final class` que conforman un protocolo `Sendable` (ver sección 6) — `final` ahí es sobre todo una convención de "no se hereda de esto", no la razón de que sean thread-safe.

### `actor`

Un `actor` es su propio dominio de aislamiento. Todo lo declarado dentro (propiedades, métodos síncronos) es implícitamente isolated a `Self` — no hace falta anotar nada, y **el Default Actor Isolation del módulo nunca se aplica dentro de un `actor`** (ya está aislado a sí mismo, no tendría sentido inferirle `@MainActor`).

```swift
actor ImageCache {
    private var cache: [URL: Data] = [:]   // isolated a `Self`, no a MainActor

    func store(_ data: Data, for url: URL) {
        cache[url] = data                  // seguro: un solo caller a la vez
    }

    nonisolated func staticHelper() -> String {  // opt-out explícito, puede llamarse sin await
        "ImageCache"
    }
}
```

Llamar a un método `actor` desde fuera requiere `await` (salvo que esté `nonisolated`), porque puede haber cola de espera si otra tarea ya está dentro.

**Forma no declara ningún `actor` custom hoy** — el aislamiento de `ModelContext`/SwiftData se resuelve con `@MainActor` en los ViewModels/protocolos, no con un actor propio (ver ADR 004).

---

## 3. Swift 6.2 — Default Actor Isolation (SE-0466)

### El problema que resuelve

La mayoría de apps son, en la práctica, single-threaded: casi todo corre en el main actor. Pero el default histórico de Swift (`nonisolated`) obligaba a anotar `@MainActor` por todas partes, o generaba falsos positivos en:
- variables globales/estáticas,
- tipos `@MainActor` que conforman protocolos no anotados,
- `deinit` de clases,
- overrides de métodos de superclases no aisladas,
- llamadas a APIs de UIKit/SwiftUI que son `@MainActor` en el SDK.

### La solución: cambiar el default a nivel de módulo

SE-0466 introduce una bandera de compilación que controla qué se infiere cuando **no** hay anotación explícita:

```bash
swiftc -default-isolation MainActor   file.swift   # todo nonisolated → @MainActor implícito
swiftc -default-isolation nonisolated file.swift   # comportamiento clásico (default histórico)
```

En Xcode 26 esto es el build setting **"Default Actor Isolation"** (`SWIFT_DEFAULT_ACTOR_ISOLATION`), con valores `MainActor` / `Nonisolated`. **Los proyectos nuevos en Xcode 26 lo traen en `MainActor` por defecto; los proyectos existentes lo traen en `Nonisolated`** (no rompe código al actualizar Xcode).

En SPM:
```swift
swiftSettings: [
    .defaultIsolation(MainActor.self)   // o .defaultIsolation(nil) para nonisolated
]
```

### Qué se infiere y qué no, con `-default-isolation MainActor`

**Se infiere `@MainActor`:**
```swift
func f() { }                 // → @MainActor func f()
class C {                    // → toda la clase @MainActor: init, deinit, static vars, nested types
    struct Nested { }
    static var value = 10
}
struct S: P { }               // si P no aísla, S hereda @MainActor por default del módulo
Task { }                       // hereda el actor del contexto que lo lanza (@MainActor)
```

**NO se infiere (excepciones):**
- Cualquier declaración con isolation explícita (`nonisolated`, `@MainActor` manual, actor propio).
- Declaraciones que ya heredan isolation de otro lado (superclase, protocolo, propiedad de un actor).
- **Todo lo que está dentro de un `actor`** (ya aislado a `Self`).
- `Task.detached { }` (por diseño, nunca hereda nada).
- Tipos que conforman (directa o indirectamente) un protocolo que hereda `SendableMetatype` — **incluyendo el propio `Sendable`, que hereda `SendableMetatype`**. Esta es la excepción más importante en la práctica: es la razón por la que un `final class Foo: FooProtocol` con `protocol FooProtocol: Sendable` se queda `nonisolated` aunque el módulo tenga default `MainActor`. Ver sección 6.

```swift
nonisolated protocol Q: Sendable { }
struct S2: Q {
    struct Inner { }   // nonisolated, NO @MainActor — Q hereda SendableMetatype vía Sendable
}
```

### Opt-out puntual: `nonisolated`

`nonisolated` sigue funcionando exactamente igual que siempre: anula cualquier default (del módulo o heredado) para esa declaración concreta.

```swift
@MainActor   // implícito por default del módulo, o explícito — da igual
class RunsOnMain {
    var name = "example"

    nonisolated func pureHelper(_ x: Int) -> Int {   // escapa del MainActor
        x * 2
    }
}
```

### Gotchas conocidos

- **Nested types dentro de tipos `nonisolated`**: un `deinit` de una clase anidada privada dentro de un tipo `@MainActor` puede seguir sin considerarse en el mismo dominio si el nesting rompe la cadena de inferencia — hay que anotar explícitamente si el compilador se queja.
- **Macros**: no pueden "ver" el default isolation del módulo que las usa; si una macro genera código que asume `nonisolated`, puede chocar con un módulo en `MainActor` default. Requiere que el autor del macro contemple el caso explícitamente.
- **"Dialectos" de lenguaje**: el significado de una declaración sin anotar depende de un build setting invisible en el propio archivo `.swift`. Si copias/pegas código entre módulos con defaults distintos, el comportamiento cambia sin que se note en el diff.

---

## 4. `nonisolated(nonsending)` y `@concurrent` (SE-0461)

Esto es un cambio distinto (aunque relacionado): **qué hilo/actor usa una función `async` que no tiene isolation propia.**

### Antes de Swift 6.2

Una función `nonisolated async` siempre saltaba al **global cooperative executor** (background), sin importar desde qué actor la llamabas:

```swift
class Downloader {
    func fetch() async -> Data { ... }   // nonisolated async → SIEMPRE salta a background
}

@MainActor
func caller() async {
    let d = Downloader()
    await d.fetch()   // hop a background y vuelta, aunque no haga falta
}
```

Esto obligaba a marcar todo como `Sendable` innecesariamente o generaba hops de hilo costosos/impredecibles solo por ser `async`.

### Después de Swift 6.2 — `nonisolated(nonsending)` es el nuevo default

Con el upcoming feature `NonisolatedNonsendingByDefault` activo (parte de "Approachable Concurrency"), una función `nonisolated async` **se queda en el actor de quien la llama**, en vez de saltar a background:

```swift
class Downloader {
    func fetch() async -> Data { ... }   // ahora: nonisolated(nonsending) implícito
}

@MainActor
func caller() async {
    let d = Downloader()
    await d.fetch()   // se queda en MainActor — no hay hop
}
```

Es exactamente el mismo comportamiento que ya tenían las funciones **no-async** `nonisolated` (corren donde las llamas), solo que ahora aplica también a `async`. Corrige una inconsistencia histórica.

### `@concurrent` — cuando SÍ quieres saltar a background

Si necesitas que una función async corra en el executor global (paralelismo real, no bloquear el actor del caller), lo marcas explícitamente:

```swift
struct Image {
    static var cachedImage: [URL: Image] = [:]

    static func create(from url: URL) async throws -> Image {
        if let image = cachedImage[url] { return image }
        let image = try await fetchImage(at: url)   // await normal, sigue en el actor del caller
        cachedImage[url] = image
        return image
    }

    @concurrent
    static func fetchImage(at url: URL) async throws -> Image {
        // esto SÍ corre en el executor global/background
        let (data, _) = try await URLSession.shared.data(from: url)
        return await decode(data: data)
    }
}
```

Reglas de `@concurrent`:
- Solo en funciones `async`.
- Los parámetros/valores de retorno que cruzan el boundary deben ser `Sendable`.
- Compatible con `async let` / `TaskGroup` (concurrencia estructurada).

### Tabla comparativa

| | Antes de 6.2 (`nonisolated async`) | 6.2 `nonisolated(nonsending)` (default nuevo) | 6.2 `@concurrent` |
|---|---|---|---|
| ¿Dónde corre? | Executor global (background), siempre | Actor de quien llama | Executor global (background), siempre |
| ¿Requiere `Sendable` en los parámetros? | Sí (cruza boundary) | No necesariamente | Sí (cruza boundary) |
| Uso típico | — (comportamiento legacy) | Wrappers finos, helpers que no hacen trabajo pesado | Decode/parse/compresión/red — trabajo CPU-bound o I/O que no debe bloquear el actor del caller |
| Equivalente pre-6.2 | comportamiento por defecto | `Task { @MainActor in await legacyFunc() }` manual | `Task.detached { }` (pero estructurado, con cancelación heredada) |

**Migración**: la herramienta de migración de Xcode 26 puede añadir `@concurrent` automáticamente a funciones existentes para preservar el comportamiento antiguo — conviene revisar cada caso a mano en vez de aceptar todo en bloque, porque muchas de esas funciones probablemente están mejor quedándose en el actor del caller.

---

## 5. "Approachable Concurrency" — el paraguas

En Xcode 26, el build setting **`SWIFT_APPROACHABLE_CONCURRENCY = YES`** activa un conjunto de 5 upcoming features a la vez (en vez de tener que buscarlas una por una):

| Feature (SE) | Qué hace |
|---|---|
| `NonisolatedNonsendingByDefault` (SE-0461) | Ver sección 4 — `nonisolated async` corre en el actor del caller. |
| `InferIsolatedConformances` (SE-0470) | Permite que una conformidad a protocolo herede isolation del tipo que conforma. |
| `InferSendableFromCaptures` (SE-0418) | Infiere `@Sendable` automáticamente en closures según lo que capturan. |
| `GlobalActorIsolatedTypesUsability` (SE-0434) | Simplifica trabajar con tipos aislados a un actor global. |
| `DisableOutwardActorInference` (SE-0401) | Un property wrapper `@MainActor` ya no "contagia" isolation al tipo contenedor entero. |

`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` (sección 3) es una bandera **independiente** — puedes activar una sin la otra, pero en la práctica casi siempre van juntas: Approachable Concurrency asume que la mayoría del código vive en MainActor por defecto.

En SPM (sin Xcode), se activan una por una:
```swift
swiftSettings: [
    .defaultIsolation(MainActor.self),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("InferSendableFromCaptures"),
    .enableUpcomingFeature("GlobalActorIsolatedTypesUsability"),
    .enableUpcomingFeature("DisableOutwardActorInference"),
]
```

---

## 6. Cómo se aplica esto hoy en Forma

Forma tuvo `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` desde el commit `d48d300` (2026-06-29) hasta el 2026-07-01, cuando el usuario lo cambió a mano a `nonisolated` en las 4 ocurrencias del `.pbxproj` (commit `07a40fa`) — confirmado permanente, no un experimento temporal. `SWIFT_APPROACHABLE_CONCURRENCY = YES` sigue activo (es una bandera independiente, ver sección 5). Esto es importante: **con `nonisolated` de default, nada se infiere como `@MainActor` automáticamente** — es exactamente el comportamiento clásico de Swift 6.0/6.1 descrito en la sección 2, no el de la sección 3.

- **ViewModels** (`@MainActor @Observable final class`): la anotación `@MainActor` explícita **ya no es redundante — es obligatoria**. Sin ella, la clase sería `nonisolated` (el default del módulo) y todo el patrón MVVM+Interactor de Forma (ver `CLAUDE.md` y ADR 002) dejaría de garantizar que las actualizaciones de estado observable ocurren en el hilo principal. Cualquier ViewModel nuevo debe llevar `@MainActor` explícito sin excepción.

- **Interactors, Repositories y Services concretos** (`final class XInteractor: XInteractorProtocol`, donde `protocol XInteractorProtocol: Sendable`) se quedan `nonisolated` — pero ahora es simplemente **el comportamiento por defecto del módulo**, no la excepción de `SendableMetatype` de la sección 3 (esa excepción solo importa cuando el default es `MainActor`; con default `nonisolated` es un no-op, el resultado habría sido el mismo con o sin que el protocolo heredara `Sendable`). El motivo real por el que siguen conformando `Sendable` no ha cambiado: permite que crucen actor boundaries de forma segura y que `AppContainer`/las Views los construyan e inyecten sin `await`.

- **`HealthKitService`** sigue siendo `final class HealthKitService: HealthKitServiceProtocol, @unchecked Sendable` — sin cambios, `@unchecked Sendable` es ortogonal al default de isolation del módulo.

- **Nadie usa `actor` todavía** en Forma. Sin cambios respecto a antes.

### Qué significa esto para código nuevo en Forma

- **Hay que escribir `@MainActor` explícito en todo ViewModel nuevo** — el módulo ya no lo infiere. Omitirlo es un bug de concurrencia real, no solo un estilo distinto.
- No hace falta escribir `nonisolated` en un Interactor/Repository/Service nuevo — ya es el default del módulo, con o sin que su protocolo herede `Sendable` (aunque seguir heredando `Sendable` sigue siendo necesario por las razones de la sección anterior, no por el default de isolation).
- Si escribes una función `async` en un Service/Interactor y necesitas que corra en background de verdad (p. ej. parseo pesado de un catálogo de alimentos, decode de imágenes de progreso), la diferencia práctica con `@concurrent` es menor que antes: con default `nonisolated`, una función `async` sin anotación ya corre fuera de MainActor por defecto (comportamiento de la sección 2, no el `nonisolated(nonsending)` de la sección 4, que solo aplica cuando hay isolation explícita de la que "escapar"). `@concurrent` sigue siendo la forma explícita de garantizar el salto al executor global si hace falta ser inequívoco.

---

## 7. Árbol de decisión rápido

| Pregunta | Respuesta |
|---|---|
| ¿Es una View/ViewModel, algo que toca UI? | `@MainActor` **explícito y obligatorio** — el default del módulo es `nonisolated`, no se hereda nada |
| ¿Es un Repository/Service/Interactor sin estado mutable propio, solo orquesta llamadas async? | No anotes nada — ya es `nonisolated` por default del módulo; sigue conformando `Sendable` en su protocolo por las razones de la sección 6 |
| ¿Tiene estado mutable compartido entre tasks concurrentes que NO es UI? | `actor` |
| ¿Necesitas que una función `async` haga trabajo pesado (CPU/red) explícitamente fuera del actor de quien la llama? | `@concurrent` (aunque con default `nonisolated` una función sin anotación ya suele quedar fuera de MainActor — ver sección 6) |
| ¿Envuelve una API legacy no-Sendable que tú sabes que es thread-safe (HealthKit, etc.)? | `final class ...: @unchecked Sendable` — única excepción justificada |
| ¿Quieres que un ViewModel/View puntual escape a `nonisolated` pese a estar en un contexto `@MainActor`? | `nonisolated` en esa declaración concreta |

---

## Fuentes

- [SE-0466: Control default actor isolation inference](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0466-control-default-actor-isolation.md)
- [SE-0461: Run nonisolated async functions on the caller's actor by default](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0461-async-function-isolation.md)
- [Swift.org — Swift 6.2 Released](https://www.swift.org/blog/swift-6.2-released/)
- [WWDC25 — Embracing Swift concurrency (session 268)](https://developer.apple.com/videos/play/wwdc2025/268/)
- [WWDC25 — Code-along: Elevate an app with Swift concurrency (session 270)](https://developer.apple.com/videos/play/wwdc2025/270/)
- [WWDC25 — Explore concurrency in SwiftUI (session 266)](https://developer.apple.com/videos/play/wwdc2025/266/)
- [Default isolation with Swift 6.2 — massicotte.org](https://www.massicotte.org/default-isolation-swift-6_2/)
- [Default Actor Isolation: New Problems from Good Intentions — fatbobman](https://fatbobman.com/en/posts/default-actor-isolation/)
- [Setting default actor isolation in Xcode 26 — Donny Wals](https://www.donnywals.com/setting-default-actor-isolation-in-xcode-26/)
- [Should you opt-in to Swift 6.2's Main Actor isolation? — Donny Wals](https://www.donnywals.com/should-you-opt-in-to-swift-6-2s-main-actor-isolation/)
- [@concurrent explained with code examples — SwiftLee](https://www.avanderlee.com/concurrency/concurrent-explained-with-code-examples/)
- [Approachable Concurrency in Swift 6.2: A Clear Guide — SwiftLee](https://www.avanderlee.com/concurrency/approachable-concurrency-in-swift-6-2-a-clear-guide/)
