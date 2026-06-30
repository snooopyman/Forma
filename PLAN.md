# Forma — Plan de Desarrollo

Estado actual: → **Fase 13** (Tests, en progreso) — Fase 15 (Polish + Accesibilidad) aún no iniciada

---

## Fase 0 — Project setup ✅
- [x] CLAUDE.md + `.claude/` (ADRs, skills, specs)
- [x] PRD corregido
- [x] Design tokens definidos (DesignTokens.swift)
- [x] Color assets en Asset Catalog (15 colorsets light/dark)
- [x] Borrar boilerplate Xcode (ContentView, Item)
- [x] FormaApp.swift limpio (Forma/FormaApp.swift)
- [x] Estructura de carpetas creada en disco
- [x] Configurado: iOS 26.0 (target Forma) / 26.4 (default proyecto), Swift 6.0 — Strict Concurrency Complete llegó después, en Fase 14

---

## Fase 1 — Design System ✅
- [x] Colores en Asset Catalog (`Resources/Assets.xcassets/Colors/`, 15 colorsets light/dark) + `MuscleGroup.swift` con color por grupo — no se creó un fichero `Color+DesignSystem.swift` separado, los colores se referencian directamente desde el catálogo
- [x] ViewModifiers: `.cardStyle()`, `.primaryButtonLabel()`
- [x] MacroRingView
- [x] MuscleGroupBadge
- [x] NutritionProgressBar
- [x] MetricTrendCard (sparkline)
- [x] ExerciseSetRow
- [x] Localizable.xcstrings — EN base + ES traducido

---

## Fase 2 — Data layer ✅
- [x] SwiftData @Model: UserProfile, Mesocycle, WorkoutDay, Exercise, PlannedExercise
- [x] SwiftData @Model: WorkoutSession, LoggedSet, MuscleVolumeTarget
- [x] SwiftData @Model: BodyMeasurement, ProgressPhoto
- [x] SwiftData @Model: NutritionPlan, Meal, MealOption, MealOptionItem, FoodItem, DailyNutritionLog, MealLog
- [x] Repository protocols (Domain/Repositories/)
- [x] FormaSchema.swift — lista central de todos los @Model para el ModelContainer
- [x] FormaModelContainer.swift — setup SwiftData + App Group + CloudKit
- [x] AppContainer.swift — DI con todos los repos y services
- [x] FormaApp.swift — entry point con guard del container + environment injection
- [x] Logger+Forma.swift — subsistemas de logging (core, training, nutrition, progress, healthkit, sync)
- [x] Repository implementations — 6 repositorios concretos en Data/Repositories/
- [x] Localizable.xcstrings — traducciones ES completadas (100%), %lld%% eliminado
- [x] Seed data — 1 mesociclo completo + plan nutricional para Previews (PreviewContainer + PreviewSeedData en Shared/Preview/)

---

## Fase 3 — Navigation shell ✅
- [x] MainTabView con 4 tabs (Tab API iOS 26)
- [x] NavigationStack por módulo
- [x] Placeholder views compilables
- [x] AppContainer inyectado via `@Environment` desde FormaApp

---

## Fase 4 — Módulo Entreno ✅
- [x] MesocycleListView + MesocycleListViewModel
- [x] MesocycleDetailView + MesocycleDetailViewModel
- [x] WorkoutDayDetailView + WorkoutDayDetailViewModel
- [x] ActiveSessionView + ActiveSessionViewModel
- [x] PostWorkoutSummaryView
- [x] WorkoutSessionService
- [x] VolumeCalculatorService
- [x] MesocycleRepository (implementación concreta)
- [x] WorkoutSessionRepository (implementación concreta)

---

## Fase 5 — Live Activity (temporizador descanso) ✅
- [x] RestTimerAttributes (ActivityAttributes)
- [x] Lock Screen layout
- [x] Dynamic Island compact + expanded + minimal
- [x] Countdown con `Task` + `Task.sleep` (no `AsyncStream`) — háptica básica implementada (`.sensoryFeedback`), la secuencia de 3 pulsos al finalizar queda para Fase 15

---

## Fase 6 — Módulo Nutrición ✅
- [x] PlanOverviewView + PlanOverviewViewModel
- [x] MealDetailView + MealDetailViewModel (opciones intercambiables, log diario, opción preferida)
- [x] FoodBrowserView + FoodBrowserViewModel
- [x] CreateNutritionPlanView + CreateNutritionPlanViewModel
- [x] EditNutritionPlanView + EditNutritionPlanViewModel
- [x] MacroTrackingService + MacroTrackingServiceProtocol
- [x] NutritionRepository (implementación concreta)
- [x] FoodItemRepository (implementación concreta)
- [x] FoodCatalog.swift — seed data ~250 alimentos con macros
- [x] Localizable.xcstrings — 100% traducido EN + ES

---

## Fase 7 — Módulo Progreso ✅
- [x] ProgressOverviewView + ProgressOverviewViewModel
- [x] NewMeasurementView + NewMeasurementViewModel (edit mode, DatePicker, Advanced con altura)
- [x] BodyChartsView — filtro por rango (1M/3M/6M/1Y/All) + picker de perímetro individual
- [x] BodyMetricsService (% grasa fórmula US Navy, IMC, categorías ACE)
- [x] BodyMeasurementRepository (implementación concreta + update)
- [x] ProgressPhotoRepository + ProgressPhotoRepositoryProtocol
- [x] PhotoGalleryView + PhotoGalleryViewModel — galería agrupada por mes, orden frontal→espalda→lados
- [x] Miniatura cuadrada universal (portrait/landscape), label de ángulo siempre visible
- [x] Límite 1 foto por ángulo/mes con alert de reemplazo
- [x] Swift Charts: peso, % grasa, perímetros
- [x] Localizable.xcstrings — 100% EN + ES

---

## Fase 8 — Dashboard ✅
- [x] DashboardView + DashboardViewModel
- [x] Tarjeta entreno del día (planned/rest/paused states)
- [x] Anillos de macros (MacroRingView integrado)
- [x] Tarjeta HealthKit (pasos, calorías, anillos actividad)
- [x] Tarjeta medición corporal (prompt semanal)

---

## Fase 9 — Onboarding ✅
- [x] `OnboardingView` (tour de bienvenida) — no existe un fichero `WelcomeView.swift` separado
- [x] `ProfileSetupView` + `ProfileSetupViewModel` + `ProfileSetupInteractor` — perfil de usuario (nombre, fecha, altura, sexo)
- [x] Nivel de actividad
- [x] Permisos HealthKit
- [x] `@AppStorage("tourCompleted")` (ver `.claude/specs/decisions/005-onboarding-appstorage.md`)
- [x] Enlace a crear mesociclo y plan nutricional

---

## Fase 10 — Integraciones ✅
- [x] HealthKitService — writeWeight con dedup por día + permiso toShare
- [x] NewMeasurementViewModel — prellenar peso desde HealthKit (solo medición nueva) + escribir a HealthKit al guardar

---

## Fase 11 — Settings ✅
- [x] SettingsView (sheet global)
- [x] Perfil de usuario (edición)
- [x] Permisos HealthKit
- [x] CloudKit — verificar `ModelConfiguration.cloudKitDatabase` con `FormaModelContainer`
- [x] Estado de sync CloudKit
- [x] Exportar datos (perfil en JSON via ShareLink)
- [x] NSHealthShareUsageDescription + NSHealthUpdateUsageDescription en Info.plist

---

## Fase 12 — Capa Interactor + errores tipados + protocolos de ViewModel ✅
*No estaba planificada como fase propia originalmente — se hizo como bloque de retrofit (commits `041cdd2`, `3a15320`, `74a1051`, `8e7578d`) antes de Fase 13. Se documenta aquí a posteriori para que el plan refleje lo que realmente pasó.*
- [x] Errores de dominio tipados por módulo: `TrainingError`, `NutritionError`, `ProgressError`, `SettingsError`
- [x] Capa Interactor (`Features/{Módulo}/Interactor/`) en las 16 features con ViewModel — el ViewModel ya no llama a repositorios/servicios directamente
- [x] `AppContainer` expone solo tipos protocolo (repos y services), nunca tipos concretos
- [x] `handleError` por ViewModel, mapeando el error tipado del módulo a `errorMessage`
- [x] `ViewModelProtocol` + `MockViewModel` + inyección por `@Environment`/`@Entry` en las 4 pantallas tab-root (Dashboard, MesocycleList, PlanOverview, ProgressOverview) y en ActiveSession — el resto de pantallas usa ViewModel+Interactor sin protocolo

---

## Fase 13 — Tests (en progreso)
- [x] FormaTests target con Swift Testing
- [x] Spies para BodyMeasurement, Mesocycle, Nutrition y WorkoutSession repository protocols (FormaTests/Shared/Spies/)
- [ ] Spies + tests para FoodItem, ProgressPhoto y UserProfile repositories
- [x] `MesocycleListTests+ViewModel`, `MesocycleListTests+Interactor`
- [x] `ActiveSessionTests+ViewModel`, `ActiveSessionTests+Interactor` (flujo crítico)
- [x] `PlanOverviewTests+ViewModel/+Interactor`, `ProgressOverviewTests+ViewModel/+Interactor`
- [ ] Tests para Dashboard, Onboarding, Settings, Nutrition (CreatePlan/EditPlan/FoodBrowser/MealDetail), Progress (BodyCharts/NewMeasurement/PhotoGallery), Training (MesocycleDetail/VolumesSummary/WorkoutDay)
- [ ] BodyMetricsService tests
- [ ] VolumeCalculatorService tests
- [ ] Cobertura ≥ 70% en lógica de negocio — no medida formalmente todavía (25 ficheros de test, 81 `@Test` en total)

---

## Fase 14 — Concurrencia estricta + Localización type-safe ✅
- [x] `L10n.swift` — enum type-safe de claves de localización (`Shared/Localization/`)
- [x] `SWIFT_STRICT_CONCURRENCY = complete` a nivel de proyecto
- [x] `SWIFT_APPROACHABLE_CONCURRENCY = YES`
- [x] `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`
- Nota: `FormaLiveActivityExtension` sigue en `SWIFT_VERSION = 5.0` — no se ha migrado el widget extension a Swift 6 todavía

---

## Fase 15 — Polish + Accesibilidad (pendiente)
- [ ] accessibilityLabel en todos los interactivos — hoy solo presente en ProgressOverview, PhotoGallery y ProfileSetup (6 usos totales)
- [ ] accessibilityHidden en decorativos
- [ ] accessibilityReduceMotion en todas las animaciones — no usado todavía en ningún sitio
- [ ] VoiceOver pass — flujo sesión activa
- [ ] Haptics en todos los puntos definidos — hoy solo implementados en ActiveSession (`.sensoryFeedback(.impact)` al iniciar descanso, `.sensoryFeedback(.success)` al terminar)
- [ ] Bold Text pass — pantalla sesión activa

---

## Notas de arquitectura

- **App Group** `group.com.armando.forma` configurado desde Fase 2 — necesario para Widget (V1.1). Migrar después implica pérdida de datos.
- **Repository implementations** van junto a su feature (Fase 4, 6, 7) — no antes, para no crear código sin tests ni uso real.
- **Seed data** en Fase 2 — necesario para que las Previews de Fase 3+ funcionen sin SwiftData real.
- **Logger+Forma** en Fase 2 — usado desde el primer log en AppContainer.
