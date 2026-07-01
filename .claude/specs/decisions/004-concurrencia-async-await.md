# ADR 004: async/await como única estrategia de concurrencia

Fecha: 2026-03-28 — Strict Concurrency Complete activado en 2026-06-29 (commit `d48d300`) — `SWIFT_DEFAULT_ACTOR_ISOLATION` cambiado a `nonisolated` en 2026-07-01 (commit `07a40fa`)
Estado: Aceptada

## Contexto

La app tiene múltiples operaciones asíncronas: acceso a SwiftData, llamadas a HealthKit, sync con CloudKit, temporizador de Live Activity. La alternativa era GCD (Grand Central Dispatch) o Combine.

## Decisión

Strict Concurrency Checking en modo **Complete**, a nivel de proyecto (`SWIFT_STRICT_CONCURRENCY = complete`), junto con `SWIFT_APPROACHABLE_CONCURRENCY = YES` y `SWIFT_DEFAULT_ACTOR_ISOLATION = nonisolated`. Toda operación asíncrona usa `async/await` y `Task`. Cero `DispatchQueue`, `DispatchGroup`, `DispatchSemaphore` ni callbacks `@escaping` — confirmado: cero apariciones en todo `Forma/`.

**Cambio 2026-07-01:** el default pasó de `MainActor` a `nonisolated` (el default clásico de Swift 6.0/6.1, confirmado por el usuario como permanente, no un experimento). Esto invierte la relación entre el default del módulo y las anotaciones explícitas: con `nonisolated` de default, `@MainActor` en ViewModels **ya no es redundante** — es la única razón por la que esas clases corren en el hilo principal. Ver `.claude/specs/patterns/concurrency-isolation.md` sección 6 para el detalle de qué se infiere con cada valor.

- ViewModels e Interactors-protocol: `@MainActor` explícito y **obligatorio** (con el default en `nonisolated`, nada se infiere como `@MainActor` automáticamente) — todas las actualizaciones de UI en el hilo principal. Los Interactors concretos en sí son `Sendable` planos, sin `@MainActor` (orquestan repos/services y pueden ejecutarse fuera del main actor) — con `nonisolated` de default esto ya no depende de la excepción de `SendableMetatype` (sección 3/6 de `concurrency-isolation.md`), es simplemente el comportamiento por defecto del módulo.
- `async let` para paralelismo acotado conocido — usado en `DashboardInteractor` (combinar varias fuentes del Dashboard) y en `HealthKitService` (fetch paralelo de minutos de ejercicio/entreno).
- HealthKit expone APIs basadas en callback (`HKSampleQuery`, `HKStatisticsQuery`); `HealthKitService` las envuelve con `withCheckedContinuation` para exponerlas como `async`.
- `HealthKitService` es `final class ...: @unchecked Sendable` — es la única excepción `@unchecked Sendable` del código de producción, justificada porque envuelve `HKHealthStore`, cuyas garantías de thread-safety no las puede verificar el compilador.

**No usado todavía, pero disponible si hace falta:** `actor` (no hay ningún `actor` custom declarado en el código — el aislamiento de `ModelContext` se resuelve con `@MainActor`), `TaskGroup`, `AsyncStream`/`AsyncSequence`, `@concurrent`, `Task.detached`. El temporizador de descanso de la sesión activa no usa `AsyncStream`: es un `Task` con un bucle `for...in stride` + `Task.sleep(for:)` por segundo (`ActiveSessionViewModel.startRestTimer`); la Live Activity renderiza su propia cuenta atrás declarativamente con `Text(timerInterval:countsDown:)` a partir de un `endsAt: Date` en el `ContentState`, sin necesidad de que el proceso principal la actualice cada segundo.

## Consecuencias

- ✅ Cero warnings de concurrencia con Strict Concurrency Complete
- ✅ Código más legible y mantenible que callbacks anidados
- ✅ Integración natural con SwiftData y HealthKit async APIs
- ⚠️ HealthKit (API legacy basada en callbacks) requiere wrapper async vía `withCheckedContinuation` en `HealthKitService`
- ⚠️ `FormaLiveActivityExtension` (el target del widget) sigue en `SWIFT_VERSION = 5.0` — no se ha migrado a Swift 6 todavía, pendiente
- ❌ No se usa GCD en ninguna forma: sin `DispatchQueue.main.async`, sin `DispatchGroup`, sin `DispatchSemaphore`
- ❌ No se usa `ObservableObject` + `@Published` (requeriría Combine)

## Cuándo revisitar

Si Apple depreca algún patrón async/await en favor de algo más nuevo, o si aparece la primera necesidad real de `actor`/`TaskGroup`/`AsyncStream` (hoy no hay ningún uso en el código).
