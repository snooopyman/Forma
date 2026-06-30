# ADR 002: MVVM + Interactor con @Observable como patrón de arquitectura

Fecha: 2026-03-28 (MVVM inicial) — ampliada 2026-06 con la capa Interactor
Estado: Aceptada

## Contexto

Necesitábamos un patrón de arquitectura para organizar la app. Las opciones eran MVVM, TCA (The Composable Architecture) y MV (vistas que acceden directamente a SwiftData).

Con MVVM puro, los ViewModels empezaron a acumular llamadas directas a varios repositorios y servicios a la vez (ej. el Dashboard combina mesociclo activo, sesión en curso, última medición y plan nutricional). Eso mezclaba "qué datos se necesitan y en qué orden" con el estado de presentación, y dificultaba testear esa orquestación sin arrastrar todo el ViewModel. Se añadió una capa Interactor entre ViewModel y Repository/Service para separar ambas responsabilidades.

## Decisión

MVVM con `@Observable` + capa Interactor. Flujo de datos: View → ViewModel → Interactor Protocol → Repository Protocol / Service Protocol → SwiftData / HealthKit / CloudKit.

- **ViewModels**: `@MainActor @Observable final class`, terminan en `ViewModel`. Reciben un `{Feature}InteractorProtocol` en el `init` y nunca llaman a un repositorio o servicio directamente.
- **Interactors** (`Features/{Feature}/Interactor/`): `final class`, conforman a un `{Feature}InteractorProtocol: Sendable`, sin `@MainActor`. Reciben los repositorios/servicios que necesitan en su `init` y orquestan las llamadas, devolviendo datos ya listos para el ViewModel (a menudo un struct `Sendable` tipo snapshot, ej. `DashboardSnapshot`).
- **Repositorios**: protocolo `RepositoryProtocol: Sendable` + implementación `Repository` — permiten inyectar mocks/spies en tests.
- **Services**: lógica de negocio y cálculos (`VolumeCalculatorService`, `BodyMetricsService`, `WorkoutSessionService`, `HealthKitService`), también expuestos como protocolo en `AppContainer`.
- **Errores tipados por módulo**: `TrainingError`, `NutritionError`, `ProgressError`, `SettingsError` — cada ViewModel tiene un `handleError(_:)` privado que mapea el error de su dominio a un `errorMessage` legible.
- `AppContainer` expone únicamente tipos protocolo (repos y services), nunca tipos concretos.
- Inyección de dependencias: 5 pantallas tienen `ViewModelProtocol` + `MockViewModel` — las 4 raíces de cada tab (Dashboard, MesocycleList, PlanOverview, ProgressOverview), construidas una vez en `MainTabView` e inyectadas vía `@Environment`/`@Entry`, y `ActiveSession`, que tiene el protocolo+mock pero NO se inyecta por `@Environment`: se construye directamente vía `@State` en el `init` de `ActiveSessionView`. El resto de pantallas construye su ViewModel+Interactor directamente en el `init` de la View, leyendo repos/services de `@Environment(AppContainer.self)`.

## Consecuencias

- ✅ Patrón bien documentado por Apple para SwiftUI
- ✅ Sin dependencias de terceros (TCA requiere SPM externo)
- ✅ ViewModels e Interactors son testeables en aislamiento — Interactor con Spies de repositorio, ViewModel con un Spy/Mock del Interactor
- ✅ `@Observable` elimina el boilerplate de `@Published` / `ObservableObject`
- ✅ El Interactor aísla la orquestación multi-repositorio del estado de presentación — los ViewModels de pantallas que combinan varias fuentes (Dashboard) se mantienen legibles
- ⚠️ El patrón no es 100% uniforme: 5 de 15 features con ViewModel (las 4 tab-root + ActiveSession) tienen `ViewModelProtocol`+`Mock`; de esas, solo las 4 tab-root usan además inyección por `@Environment`/`@Entry` — `ActiveSession` tiene el protocolo+mock pero construye el ViewModel directamente vía `@State`. El resto usa ViewModel+Interactor construidos directamente por la View. Es una decisión consciente — el protocolo de ViewModel solo se añadió donde hacía falta mockear la pantalla completa para Previews/tests de integración
- ⚠️ Dos vistas de solo lectura (`BodyChartsView`, `PostWorkoutSummaryView`) no tienen ViewModel ni Interactor — reciben los datos ya cargados de su vista padre
- ❌ No se usa TCA ni arquitecturas basadas en reducers

## Cuándo revisitar

Si la complejidad de estado crece tanto que el flujo unidireccional de TCA aporte más que su overhead. También si la falta de `ViewModelProtocol` en las 11 features restantes empieza a doler para testearlas — en ese caso, generalizar el patrón de las 5 pantallas que ya lo tienen.
