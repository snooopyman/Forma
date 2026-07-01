# Design System — CLAUDE.md

## Contexto de diseño

Forma sigue el lenguaje **Liquid Glass** de iOS 26 y la estética de Apple Fitness+ — el objetivo es que se sienta como una app first-party de Apple.

Cuando propongas UI:
- Explica brevemente por qué cada decisión visual es correcta para fitness
- Avisa si algo rompería las reglas de Liquid Glass antes de implementarlo
- Prioriza legibilidad con las manos ocupadas (pantalla de sesión activa)
- Propón la jerarquía visual completa antes de escribir código

---

## Liquid Glass — reglas obligatorias (iOS 26)

### `.glassEffect()` vs `.buttonStyle(.glass)` — distinción crítica

Son dos conceptos distintos con reglas distintas:

| | `.glassEffect()` | `.buttonStyle(.glass)` / `.buttonStyle(.glassProminent)` |
|---|---|---|
| **Para qué** | Contenedores, superficies, vistas custom | Botones interactivos |
| **Dónde puede ir** | Solo navigation layer | También en CTAs standalone dentro del content layer |

### Reglas de `.glassEffect()`

- Glass **solo** en navigation layer: tab bars, toolbars, FABs, sheets, botones flotantes
- **Nunca** en content layer: listas, cards, ScrollViews, fondos, texto
- `.glassEffect()` siempre como **último** modificador de layout
- Dos o más elementos glass adyacentes → obligatorio `GlassEffectContainer`
- `TabView`, `NavigationStack`, `.sheet` ya tienen glass integrado → NO añadir `.glassEffect()` encima
- `.buttonStyle(.glass)` y `.glassEffect()` son mutuamente excluyentes — nunca los dos a la vez

### Reglas de botones con glass

- **CTA primario:** `.buttonStyle(.glassProminent)` + `.tint(.accent)` — opaco, destaca visualmente
- **Acción secundaria:** `.buttonStyle(.glass)` — translúcido, el fondo se ve a través
- `.buttonStyle(.glass/.glassProminent)` puede usarse en CTAs standalone dentro de cards y secciones de contenido — no solo en navigation layer
- **Nunca** glass en botones dentro de celdas de lista o filas de tabla (List rows, ForEach dentro de List)
- Tintear **solo** para transmitir significado semántico (acción primaria, estado) — nunca decorativo
- No tintear botones secundarios (`.glass`); reservar `.tint()` para CTAs con `.glassProminent`
- `NavigationLink` acepta `.buttonStyle()` igual que `Button` — mismo patrón

### Anatomía correcta de un CTA con glass

```swift
// ✅ Correcto — label limpio, estilo en el botón
Button { action() } label: {
    Text(String(localized: "Start workout"))
        .frame(maxWidth: .infinity)
}
.buttonStyle(.glassProminent)
.tint(.accent)

// ✅ NavigationLink — mismo patrón
NavigationLink { DestinationView() } label: {
    Text(String(localized: "Resume mesocycle"))
        .frame(maxWidth: .infinity)
}
.buttonStyle(.glassProminent)
.tint(.accent)

// ❌ Incorrecto — estilo manual pre-iOS 26
Button { action() } label: {
    Text("Start workout")
        .font(.subheadline.bold())
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.accent)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
}
```

**Regla del label:** solo content (Text, Image, HStack, Label) + `.frame(maxWidth: .infinity)` si ocupa todo el ancho. Nunca `.padding()`, `.background()`, `.foregroundStyle()` de estilo, ni `.clipShape()` en el label — el `buttonStyle` los gestiona.

### Modificadores opcionales para glass buttons

```swift
.controlSize(.mini | .small | .regular | .large | .extraLarge)  // tamaño
.buttonBorderShape(.capsule | .circle | .roundedRectangle(radius:))  // forma
```

CTAs con `.glass`/`.glassProminent` sin `.buttonBorderShape` explícito → toman **capsule por defecto del sistema**, no `DS.Radius.button`. `DS.Radius.button` (12) aplica solo a botones no-glass/`.bordered`.

### Fondo de app

- Fondo de app: `#F5F5F5` (nunca blanco puro) — el glass necesita contraste

---

## Design Tokens — `DesignTokens.swift`

Todos los valores de layout viven en `Shared/DesignSystem/DesignTokens.swift` bajo el namespace `DS`.
**Nunca hardcodear valores numéricos** en vistas — siempre tokens semánticos.

`DS.Radius` define primero una escala cruda (`xs/sm/md/lg/xl`) y luego alias semánticos sobre esa misma escala — usar siempre el alias semántico en vistas:

| Token | Valor | Alias de | Uso |
|-------|-------|----------|-----|
| `DS.Radius.card` | 16 | `xl` | Cards de contenido, contenedores de sección |
| `DS.Radius.button` | 12 | `lg` | Botones interactivos, CTAs, option pickers |
| `DS.Radius.setRow` | 10 | `md` | Filas de serie en sesión activa |
| `DS.Radius.chip` | 8 | `sm` | Badges de músculo, macro pills, status chips |
| `DS.Radius.inner` | 4 | `xs` | Elementos anidados dentro de cards |

| Token | Valor |
|-------|-------|
| `DS.Spacing.xs` | 4 |
| `DS.Spacing.sm` | 8 |
| `DS.Spacing.md` | 12 |
| `DS.Spacing.lg` | 16 |
| `DS.Spacing.xl` | 24 |
| `DS.Spacing.xxl` | 32 |

| Token | Valor | Uso |
|-------|-------|-----|
| `DS.Sizing.macroRingOuter` | 140 | Anillo exterior de macros (`MacroRingView`) |
| `DS.Sizing.macroRingMiddle` | 110 | Anillo intermedio de macros |
| `DS.Sizing.macroRingInner` | 80 | Anillo interior de macros |
| `DS.Sizing.restTimerRing` | 180 | Anillo del temporizador de descanso |
| `DS.Sizing.minTapTarget` | 44 | Área mínima de tap (HIG) — usado en `ViewModifiers.swift` y `ExerciseSetRow.swift` |

`DS` solo define estos tres sub-namespaces (`Radius`, `Spacing`, `Sizing`) — no existe `DS.Opacity`, `DS.Animation` ni `DS.IconSize`.

---

## Tokens de color

Los colores viven directamente en el Asset Catalog (`Forma/Resources/Assets.xcassets/Colors/`, 25 colorsets light/dark: 15 de la tabla de abajo + 10 `muscle*` de categoría muscular) y se referencian como `Color`/`ShapeStyle` del sistema (ej. `.accent`, `.backgroundCard`) — **no existe un fichero `Color+DesignSystem.swift`**, los nombres de abajo son los nombres exactos de los colorsets. Nunca valores RGB literales en vistas. La app soporta light y dark mode completo. Todos los tokens son adaptativos vía Asset Catalog.

| Token | Light | Dark | Uso |
|-------|-------|------|-----|
| `.accent` | `#0A7AFF` | `#0A84FF` | CTAs, progreso activo, tint de la app |
| `.success` | `#34C759` | `#30D158` | Series completadas, metas alcanzadas |
| `.warning` | `#FF9500` | `#FF9F0A` | Volumen bajo óptimo, alertas suaves |
| `.error` | `#FF3B30` | `#FF453A` | Volumen sobre MRV, errores |
| `.macroProtein` | `#007AFF` | `#0A84FF` | Anillo y badge de proteína |
| `.macroCarbs` | `#FF9500` | `#FF9F0A` | Anillo y badge de carbohidratos |
| `.macroFat` | `#8A6E00` | `#FFD60A` | Anillo y badge de grasa — light oscurecido para cumplir contraste 4.5:1 sobre `.backgroundCard` en texto (ver A6) |
| `.backgroundPrimary` | `#F5F5F5` | `#000000` | Fondo de pantalla — nunca blanco puro |
| `.backgroundCard` | `#FFFFFF` | `#1C1C1E` | Cards y list rows |
| `.backgroundSecondary` | `#EBEBEB` | `#2C2C2E` | Superficies secundarias, grouped insets |
| `.textPrimary` | `#1C1C1E` | `#FFFFFF` | Texto principal — headings, valores |
| `.textSecondary` | `#6C6C70` | `#8E8E93` | Subtítulos, metadatos — WCAG AA ✓ |
| `.textTertiary` | `#AEAEB2` | `#636366` | Solo decorativo — nunca texto informativo |
| `.textOnAccent` | `#FFFFFF` | `#FFFFFF` | Texto sobre fondos de acento |
| `.borderSubtle` | `#E5E5EA` | `#38383A` | Bordes sutiles, separadores |

### Colores de grupos musculares

`muscleGroup.color` — propiedad de instancia del enum `MuscleGroup` (`Shared/DesignSystem/MuscleGroup.swift`), no un helper estático en `Color`. Usan un colorset dedicado por grupo en el Asset Catalog (`Colors/muscle*.colorset`), **desacoplado a propósito** de `.success`/`.error`/`.warning` — antes reciclaban colores de sistema (`.green` para back, `.red` para legs) que coincidían visualmente con esos tokens semánticos; ahora son tonos propios que no colisionan con ningún otro significado de la app. Todos los 10 colorsets cumplen contraste WCAG AA (≥4.5:1) como texto sobre `.backgroundCard` en su modo correspondiente. Consumido por ejemplo en `MuscleGroupBadge`.

| Caso de `MuscleGroup` | Colorset |
|----|-------|
| `.chest` | `.muscleChest` |
| `.back` | `.muscleBack` |
| `.legs` / `.quadriceps` / `.hamstrings` | `.muscleLegs` |
| `.shoulders` | `.muscleShoulders` |
| `.biceps` | `.muscleBiceps` |
| `.triceps` | `.muscleTriceps` |
| `.core` | `.muscleCore` |
| `.glutes` | `.muscleGlutes` |
| `.calves` | `.muscleCalves` |
| `.cardio` / `.fullBody` | `.muscleCardio` |

No existe un caso `.abs` — solo `.core`.

---

## Tipografía

- **SF Pro Display:** Large Title, Title 1 — encabezados de módulo
- **SF Pro Text:** Body, Subheadline, Caption — contenido y UI general
- **`.monospacedDigit()`:** pesos (kg), repeticiones y valores numéricos en sesión activa — alineación perfecta en columnas. Es el modificador del sistema, no una fuente "SF Mono" custom — confirmado en `ActiveSessionView.swift`
- **Dynamic Type:** soporte completo hasta `.accessibilityExtraExtraExtraLarge`
- **Bold Text:** la pantalla de sesión activa debe funcionar con Bold Text activado

---

## SF Symbols — mapa de uso

| Contexto | Symbol |
|----------|--------|
| Tab Hoy | `house.fill` |
| Tab Entreno | `figure.strengthtraining.traditional` |
| Tab Nutrición | `fork.knife` |
| Tab Progreso | `chart.line.uptrend.xyaxis` |
| Iniciar sesión | `play.fill` |
| Serie completada | `checkmark.circle.fill` |
| Temporizador descanso | `timer` |
| Peso corporal | `scalemass.fill` |
| HealthKit | `heart.fill` |
| Músculo | `figure.arms.open` |
| Macros | `chart.pie.fill` |
| Descanso activo | `figure.walk` |

Los 4 tabs están confirmados en `Forma/App/MainTabView.swift` usando la API moderna `Tab(_:systemImage:value:)` dentro de `TabView(selection:)`, con `.tabViewStyle(.sidebarAdaptable)` y `.tabBarMinimizeBehavior(.onScrollDown)`.

---

## Componentes reutilizables clave

Viven en `Shared/DesignSystem/`. Usar siempre estos en vez de reimplementar.

| Componente | Tipo | Props / Uso |
|-----------|------|-------------|
| `MacroRingView` | View | `proteinCurrent/Goal`, `carbsCurrent/Goal`, `fatCurrent/Goal` — tres anillos con Swift Charts. Usado en Dashboard, Nutrición y Widget |
| `ExerciseSetRow` | View | Estado `pending/active/completed`. Spring animation + haptic al completar |
| `MuscleGroupBadge` | View | Nombre del grupo muscular + SF Symbol. Colores consistentes por grupo |

---

## Estados vacíos y de carga

- **Empty state de pantalla completa** (el tab/pantalla entero no tiene datos, ej. sin mesociclos, sin plan de nutrición, sin fotos): `ContentUnavailableView` + `.buttonStyle(.glassProminent)` en la acción principal. Ejemplos: `MesocycleListView.emptyView`, `PlanOverviewView.emptyView`, `ProgressOverviewView.emptyView`, `PhotoGalleryView`.
- **Empty state inline dentro de una card** (una sección entre otras en una pantalla con más contenido, ej. la card de entreno en el Dashboard cuando no hay mesociclo activo): link de texto (`.foregroundStyle(.accent)`, sin `buttonStyle`), no un botón prominente — evita competir visualmente con el resto de cards de la pantalla. Ejemplo: `DashboardView.noMesocycleContent`.
- **Loading state de pantalla completa** (antes de la primera carga de datos): skeleton — reutilizar la vista de contenido real (`contentView`/`loadedContent`) con el `Mock*ViewModel.withData` de esa feature, envuelto en `.redacted(reason: .placeholder)` + `.allowsHitTesting(false)`. Nunca un `ProgressView()` centrado genérico para el loading inicial de una pantalla completa — sí es correcto para indicadores puntuales de una acción en curso (ej. fila de HealthKit en Settings mientras se espera el permiso, estado `.couldNotDetermine` de iCloud).

---

## Háptica

| Momento | Tipo |
|---------|------|
| Completar una serie | `.success` |
| Iniciar temporizador de descanso | `.rigid` |
| Finalizar temporizador (0s) | Secuencia: 3 pulsos crecientes |
| Personal Record detectado | `.notification` heavy |
| Marcar comida completada | `.light` |

Implementado hoy con `.sensoryFeedback(_:trigger:)`: solo "iniciar temporizador de descanso" (`.impact(weight: .heavy)`) y "finalizar temporizador" (`.success`), ambos en `ActiveSessionView.swift`. El resto de la tabla es objetivo de Fase 15 (Polish), todavía no implementado.

---

## Accesibilidad — requisitos mínimos

- `accessibilityLabel` en todos los elementos interactivos con iconos
- `accessibilityValue` en controles de progreso y sliders
- `accessibilityHint` en acciones no obvias
- Contraste mínimo: 4.5:1 texto normal, 3:1 texto grande
- `@Environment(\.accessibilityReduceMotion)` respetado en todas las animaciones
- VoiceOver probado en el flujo completo de registro de serie
- Iconos decorativos: `.accessibilityHidden(true)`
- Vistas compuestas: `.accessibilityElement(children: .ignore)` + label explícito

Estado actual (Fase 15 todavía no iniciada): solo `ProgressOverviewView`, `PhotoGalleryView` y `ProfileSetupView` usan modificadores de accesibilidad explícitos hoy; `accessibilityReduceMotion` no se respeta en ninguna vista todavía.

---

## Para pedirme diseño

Dime:
1. Qué pantalla es y qué módulo pertenece
2. Cuál es la acción principal del usuario en esa pantalla
3. Si es una pantalla de sesión activa o de consulta (afecta a densidad de información)

Propongo la jerarquía visual, el uso correcto de glass y los tokens de color antes de escribir código.
