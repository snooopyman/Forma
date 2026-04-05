# Forma — Plan de Desarrollo

Estado actual: → **Fase 7**

---

## Fase 0 — Project setup ✅
- [x] CLAUDE.md + `.claude/` (ADRs, skills, specs)
- [x] PRD corregido
- [x] Design tokens definidos (DesignTokens.swift)
- [x] Color assets en Asset Catalog (15 colorsets light/dark)
- [x] Borrar boilerplate Xcode (ContentView, Item)
- [x] FormaApp.swift limpio (Forma/FormaApp.swift)
- [x] Estructura de carpetas creada en disco
- [x] Configurado: iOS 26.4, Swift 6.0, Strict Concurrency = Complete

---

## Fase 1 — Design System ✅
- [x] Color+DesignSystem.swift — extensión Color con todos los tokens + muscle groups
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
- [x] Countdown con Task + háptica básica (3 pulsos → Fase 12)

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

## Fase 7 — Módulo Progreso
- [ ] ProgressOverviewView + ProgressOverviewViewModel
- [ ] NewMeasurementView + NewMeasurementViewModel
- [ ] BodyChartsView
- [ ] BodyMetricsService (% grasa fórmula Marina, IMC)
- [ ] BodyMeasurementRepository (implementación concreta)
- [ ] Swift Charts: peso, % grasa, perímetros

---

## Fase 8 — Dashboard
- [ ] DashboardView + DashboardViewModel
- [ ] Tarjeta entreno del día (planned/rest/paused states)
- [ ] Anillos de macros (MacroRingView integrado)
- [ ] Tarjeta HealthKit (pasos, calorías, anillos actividad)
- [ ] Tarjeta medición corporal (prompt semanal)

---

## Fase 9 — Onboarding
- [ ] WelcomeView
- [ ] Perfil de usuario (nombre, fecha, altura, sexo)
- [ ] Nivel de actividad
- [ ] Permisos HealthKit
- [ ] @AppStorage("onboardingCompleted")
- [ ] Enlace a crear mesociclo y plan nutricional

---

## Fase 10 — Integraciones
- [ ] HealthKitService — peso bidireccional, pasos, calorías
- [ ] CloudKit — verificar NSPersistentCloudKitContainer con FormaModelContainer
- [ ] Estado de sync en Settings

---

## Fase 11 — Settings
- [ ] SettingsView (sheet global)
- [ ] Perfil de usuario (edición)
- [ ] Permisos HealthKit
- [ ] Estado CloudKit sync
- [ ] Exportar datos

---

## Fase 12 — Polish + Accesibilidad
- [ ] accessibilityLabel en todos los interactivos
- [ ] accessibilityHidden en decorativos
- [ ] accessibilityReduceMotion en todas las animaciones
- [ ] VoiceOver pass — flujo sesión activa
- [ ] Haptics en todos los puntos definidos
- [ ] Bold Text pass — pantalla sesión activa

---

## Fase 13 — Tests
- [ ] FormaTests target con Swift Testing
- [ ] Spies para todos los repository protocols (FormaTests/Shared/Spies/)
- [ ] MesocycleTests+ViewModel, WorkoutSessionTests+ViewModel
- [ ] ActiveSessionViewModel tests (flujo crítico)
- [ ] BodyMetricsService tests
- [ ] VolumeCalculatorService tests
- [ ] Cobertura ≥ 70% en lógica de negocio

---

## Notas de arquitectura

- **App Group** `group.com.armando.forma` configurado desde Fase 2 — necesario para Widget (V1.1). Migrar después implica pérdida de datos.
- **Repository implementations** van junto a su feature (Fase 4, 6, 7) — no antes, para no crear código sin tests ni uso real.
- **Seed data** en Fase 2 — necesario para que las Previews de Fase 3+ funcionen sin SwiftData real.
- **Logger+Forma** en Fase 2 — usado desde el primer log en AppContainer.
