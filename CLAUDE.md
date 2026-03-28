# Forma — CLAUDE.md

## El producto
App iOS nativa de fitness personal que centraliza en un solo lugar los tres pilares del progreso físico: entrenamiento estructurado por mesociclos, seguimiento corporal semanal y plan nutricional. Sin backend propio, sin login, todo local + CloudKit. PRD completo en `/Users/armando/Projects/forma-prd.md`.

## Stack
- Swift 6.2, iOS 26.0 deployment target (Liquid Glass requiere iOS 26 — no hay compatibilidad hacia atrás)
- SwiftUI + Liquid Glass (iOS 26 design language)
- SwiftData + CloudKit (`iCloud.com.armando.forma`) — única fuente de verdad, offline-first
- HealthKit — peso bidireccional, calorías/pasos desde Apple Watch, HKWorkout
- ActivityKit — Live Activity para temporizador de descanso (Lock Screen + Dynamic Island)
- WidgetKit — widget de entreno del día y resumen de macros (V1.1)
- App Intents + Siri — consultas de historial de entrenamiento (V1.1)
- Swift Charts — todas las gráficas
- Sin librerías de terceros — cero dependencias externas
- Concurrencia: async/await siempre. Nunca GCD, nunca DispatchQueue, nunca callbacks @escaping

## Arquitectura — Tier 3 (Medium)
MVVM con `@Observable`. ViewModels dependen de protocolos de repositorio → testeables con mocks.
Repositorios abstraen SwiftData. `@Environment` para inyección de dependencias.
Servicios concretos para HealthKit, CloudKit status y métricas calculadas.

Flujo de datos: View → ViewModel → Repository Protocol → SwiftData Model / HealthKit / CloudKit

## Estructura de carpetas
```
Forma/
├── App/
│   ├── FormaApp.swift
│   └── AppContainer.swift          ← ModelContainer + DI setup
├── Features/
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   └── DashboardViewModel.swift
│   ├── Training/
│   │   ├── MesocycleList/
│   │   ├── MesocycleDetail/
│   │   ├── WorkoutDay/
│   │   ├── ActiveSession/
│   │   └── VolumesSummary/
│   ├── Nutrition/
│   │   ├── PlanOverview/
│   │   ├── MealDetail/
│   │   └── FoodBrowser/
│   ├── Progress/
│   │   ├── ProgressOverview/
│   │   ├── BodyCharts/
│   │   ├── NewMeasurement/
│   │   └── PhotoGallery/
│   ├── Onboarding/
│   └── Settings/
├── Domain/
│   ├── Models/                     ← SwiftData @Model classes
│   └── Repositories/               ← protocolos
├── Data/
│   ├── Repositories/               ← implementaciones concretas
│   └── Services/                   ← HealthKit, Metrics, VolumeCalculator
├── Shared/
│   ├── DesignSystem/               ← DesignTokens.swift, colores, tipografía, componentes
│   ├── Extensions/
│   └── Utilities/
└── Resources/
    ├── Assets.xcassets
    └── Localizable.xcstrings
```

## Convenciones de código
- Views: siempre terminan en `View` (ej: `DashboardView`)
- ViewModels: siempre terminan en `ViewModel`, marcados `@MainActor` (ej: `DashboardViewModel`)
- Repositories: protocolo termina en `RepositoryProtocol`, implementación en `Repository`
- Services: terminan en `Service` (ej: `HealthKitService`, `VolumeCalculatorService`)
- Modelos SwiftData: nombres en singular sin sufijo (ej: `Mesocycle`, `WorkoutSession`)
- Comentarios en español, explicando el POR QUÉ, no el qué
- Colores y fuentes: siempre desde `DesignSystem/`, nunca hardcoded
- SF Symbols: siempre usar `Image(systemName:)`, nunca assets custom para iconos de sistema

## Localización
- **Dos idiomas desde el día 1:** EN (clave / idioma fuente) y ES (traducción)
- Las claves son inglés natural legible: `"Start workout"`, `"Rest day"`, `"Weekly volume"`
- El español es la traducción en `Localizable.xcstrings`
- Nunca strings hardcodeados en español directamente en las vistas
- Formatos de fecha, número y unidades: siempre `Locale.current`, nunca strings literales
- `Text(verbatim:)` solo para valores numéricos que NO deben localizarse (ej: pesos en kg en la sesión activa)

## Design System — DesignTokens.swift
Todos los valores de layout viven en `Shared/DesignSystem/DesignTokens.swift` bajo el namespace `DS`.
**Nunca hardcodear valores numéricos** en vistas — siempre tokens semánticos.

```
DS.Radius.card     → 16   (cards, contenedores de sección)
DS.Radius.button   → 12   (botones, opciones interactivas)
DS.Radius.chip     → 8    (badges de músculo, macro pills)
DS.Radius.inner    → 4    (elementos anidados dentro de cards)
DS.Radius.setRow   → 10   (filas de serie en sesión activa)

DS.Spacing.xs  →  4
DS.Spacing.sm  →  8
DS.Spacing.md  → 12
DS.Spacing.lg  → 16
DS.Spacing.xl  → 24
DS.Spacing.xxl → 32
```

## Diseño — Liquid Glass (iOS 26)
- Glass SOLO en capa de navegación: FABs, botones flotantes, sheets, tab bar, nav bar
- Glass NUNCA en capa de contenido: cards, list rows, ScrollViews, fondos
- `.glassEffect()` siempre es el ÚLTIMO modificador de layout
- CTA primario: `.buttonStyle(.glassProminent)` con tint azul `#0A7AFF`
- Acción secundaria: `.buttonStyle(.glass)`
- Múltiples glass adyacentes: siempre dentro de `GlassEffectContainer`
- TabView y NavigationStack ya tienen glass automático — no añadir `.glassEffect()` encima
- Fondo app: `#F5F5F5` (nunca blanco puro), cards: `#FFFFFF`

## Tokens de color (siempre desde `Color+DesignSystem.swift`)

| Token | Light | Dark | Uso |
|-------|-------|------|-----|
| `.accent` | `#0A7AFF` | `#0A84FF` | CTAs, progreso activo, tint principal |
| `.success` | `#34C759` | `#30D158` | Series completadas, metas |
| `.warning` | `#FF9500` | `#FF9F0A` | Volumen bajo óptimo |
| `.error` | `#FF3B30` | `#FF453A` | Volumen sobre MRV, errores |
| `.macroProtein` | `#007AFF` | `#0A84FF` | Anillo y badge proteína |
| `.macroCarbs` | `#FF9500` | `#FF9F0A` | Anillo y badge carbohidratos |
| `.macroFat` | `#FFCC00` | `#FFD60A` | Anillo y badge grasa |
| `.backgroundPrimary` | `#F5F5F5` | `#000000` | Fondo de pantalla |
| `.backgroundCard` | `#FFFFFF` | `#1C1C1E` | Cards y list rows |
| `.backgroundSecondary` | `#EBEBEB` | `#2C2C2E` | Superficies secundarias |
| `.textPrimary` | `#1C1C1E` | `#FFFFFF` | Texto principal |
| `.textSecondary` | `#6C6C70` | `#8E8E93` | Subtítulos, metadatos |
| `.textTertiary` | `#AEAEB2` | `#636366` | Solo decorativo |
| `.textOnAccent` | `#FFFFFF` | `#FFFFFF` | Texto sobre fondos de acento |
| `.borderSubtle` | `#E5E5EA` | `#38383A` | Bordes sutiles, separadores |

**Grupos musculares:** `Color.muscleGroup("chest")` — definidos en `Color+DesignSystem.swift` como colores adaptativos del sistema.

## Modelos de datos clave
- `UserProfile` — perfil único, altura/peso/edad para cálculos
- `Mesocycle` — bloque de entrenamiento, `useFixedDays`, `pausedAt/resumedAt`
- `WorkoutDay` — día de la semana con ejercicios planificados
- `PlannedExercise` — ejercicio con cadencia `"1-0-3"`, RIR, descanso, notas
- `WorkoutSession` — sesión real, `sessionType: planned/freeStyle/cardio/mobility`
- `LoggedSet` — serie registrada con peso, reps, RIR real
- `BodyMeasurement` — medición semanal; `bodyFatPercent` y `bmi` son `@Transient` (calculados)
- `NutritionPlan` — plan activo con macros objetivo
- `Meal` — comida con `mealType` enum; `postEntreno` se oculta en días de descanso
- `MealOption` — opción intercambiable (1/2/3) por comida
- `FoodItem` — catálogo de ~250 alimentos con macros por 100g
- `DailyNutritionLog` — log diario con `adherenceStatus: followed/partial/offPlan`

## Reglas absolutas (NUNCA hacer)
- No usar `DispatchQueue` — siempre `async/await` y `@MainActor`
- No usar `ObservableObject` — siempre `@Observable` (Observation framework)
- No usar `AnyView` — type erasure innecesario
- No usar `UIKit` directamente salvo que sea estrictamente imposible en SwiftUI
- No usar `UserDefaults.standard` directamente — `@AppStorage` para flags de UI, SwiftData para datos de usuario
- No hardcodear colores ni fuentes — siempre desde `DesignSystem/`
- No hardcodear valores numéricos de layout — siempre `DS.Radius.*` o `DS.Spacing.*`
- No hardcodear strings en español directamente en vistas — siempre claves EN en `Localizable.xcstrings`
- No añadir `.glassEffect()` sobre `TabView` o `NavigationStack`
- No almacenar `bodyFatPercent` ni `bmi` — son propiedades `@Transient` calculadas
- No instalar librerías de terceros
- No crear abstracciones para uso único — tres líneas similares no justifican un helper

## Testing
- Framework: Swift Testing (nunca XCTest salvo legacy)
- Cobertura mínima: 70% en lógica de negocio (ViewModels y Services)
- Los repositorios tienen protocolo precisamente para poder inyectar mocks en tests
- No testear Views directamente — testear ViewModels y Services
- Tests de integración para flujos críticos: sesión activa, cálculo de métricas corporales

## Flujo crítico (no puede fallar)
Registro de una serie durante sesión activa → `LoggedSet` persiste en SwiftData → Live Activity del timer se actualiza → al finalizar sesión, `WorkoutSession` se completa.

## Sincronización
CloudKit usa el Apple ID de iCloud del dispositivo como identidad. Sin login propio, sin Sign in with Apple. `NSPersistentCloudKitContainer` gestiona todo automáticamente. La app funciona 100% offline; CloudKit sync es eventual y nunca bloquea operaciones locales.

## Flujo de trabajo
| Situación | Flujo |
|-----------|-------|
| Feature nueva | Spec en `.claude/specs/features/` → crítica → implementa → `/review` → commit |
| Bug / tarea pequeña | Describe el problema → implementa → `/review` → commit |
| Pantalla nueva | Di "Lee design/CLAUDE.md" → `/new-screen Nombre` |
| Duda de arquitectura | Pide que lea `.claude/specs/decisions/` |
| Estado general del proyecto | Lee `forma-prd.md` sección 12 |

## Lo que está fuera de alcance en MVP
- Apple Watch app (V1.1)
- Widgets (V1.1)
- App Intents / Siri (V1.1)
- Fotos de progreso y comparador (V1.1)
- HKWorkout al finalizar sesión (V1.1)
- Resumen de volumen semanal con rangos MEV/MRV (V1.1)
- Importar desde Excel/CSV (V1.1)
- Soporte iPad layout maestro-detalle (V2)
- Modelo cliente-entrenador (descartado permanentemente)
- Backend propio (descartado permanentemente)
