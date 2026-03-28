# ADR 002: MVVM con @Observable como patrón de arquitectura

Fecha: 2026-03-28
Estado: Aceptada

## Contexto

Necesitábamos un patrón de arquitectura para organizar la app. Las opciones eran MVVM, TCA (The Composable Architecture) y MV (vistas que acceden directamente a SwiftData).

## Decisión

MVVM con `@Observable`. Flujo de datos: View → ViewModel → Repository Protocol → SwiftData / HealthKit / CloudKit.

- ViewModels: `@MainActor @Observable final class`, terminan en `ViewModel`
- Repositorios: protocolo `RepositoryProtocol` + implementación `Repository` — permiten inyectar mocks en tests
- Services: lógica de negocio y cálculos (`VolumeCalculatorService`, `BodyMetricsService`, `WorkoutSessionService`)
- Inyección de dependencias via `@Environment` desde `AppContainer`

## Consecuencias

- ✅ Patrón bien documentado por Apple para SwiftUI
- ✅ Sin dependencias de terceros (TCA requiere SPM externo)
- ✅ ViewModels y Services son testeables en aislamiento con mocks de repositorio
- ✅ `@Observable` elimina el boilerplate de `@Published` / `ObservableObject`
- ⚠️ En pantallas muy simples el ViewModel puede ser overkill — en esos casos la vista accede directamente al `@Environment`
- ❌ No se usa TCA ni arquitecturas basadas en reducers

## Cuándo revisitar

Si la complejidad de estado crece tanto que el flujo unidireccional de TCA aporte más que su overhead.
