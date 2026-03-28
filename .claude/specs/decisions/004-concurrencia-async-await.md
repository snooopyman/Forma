# ADR 004: async/await como única estrategia de concurrencia

Fecha: 2026-03-28
Estado: Aceptada

## Contexto

La app tiene múltiples operaciones asíncronas: acceso a SwiftData, llamadas a HealthKit, sync con CloudKit, temporizador de Live Activity. La alternativa era GCD (Grand Central Dispatch) o Combine.

## Decisión

Strict Concurrency Checking en modo **Complete**. Toda operación asíncrona usa `async/await`, `Task`, `TaskGroup`, `AsyncStream` o `actor`. Cero `DispatchQueue`, `DispatchGroup` ni callbacks `@escaping` en código nuevo.

- ViewModels: `@MainActor` — todas las actualizaciones de UI en el hilo principal
- State compartido entre actores: `actor` o `Sendable`
- Operaciones atómicas sin contexto async: `Atomic` del framework `Synchronization`

## Consecuencias

- ✅ Cero warnings de concurrencia con Strict Concurrency Complete
- ✅ Código más legible y mantenible que callbacks anidados
- ✅ Integración natural con SwiftData y HealthKit async APIs
- ⚠️ Algunas APIs de Apple legacy (HealthKit callbacks) requieren wrapper async
- ❌ No se usa GCD en ninguna forma: sin `DispatchQueue.main.async`, sin `DispatchGroup`, sin `DispatchSemaphore`
- ❌ No se usa `ObservableObject` + `@Published` (requeriría Combine)

## Cuándo revisitar

Si Apple depreca algún patrón async/await en favor de algo más nuevo.
