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

- Glass **solo** en navigation layer: tab bars, toolbars, FABs, sheets, botones flotantes
- **Nunca** en content layer: listas, cards, ScrollViews, fondos, texto
- `.glassEffect()` siempre como **último** modificador de layout
- Dos o más elementos glass adyacentes → obligatorio `GlassEffectContainer`
- `TabView`, `NavigationStack`, `.sheet` ya tienen glass integrado → NO añadir `.glassEffect()` encima
- `.buttonStyle(.glass)` y `.glassEffect()` son mutuamente excluyentes — nunca los dos a la vez
- CTA primario: `.buttonStyle(.glassProminent)` con tint `accentColor`
- Acción secundaria: `.buttonStyle(.glass)`
- Fondo de app: `#F5F5F5` (nunca blanco puro) — el glass necesita contraste

---

## Design Tokens — `DesignTokens.swift`

Todos los valores de layout viven en `Shared/DesignSystem/DesignTokens.swift` bajo el namespace `DS`.
**Nunca hardcodear valores numéricos** en vistas — siempre tokens semánticos.

| Token | Valor | Uso |
|-------|-------|-----|
| `DS.Radius.card` | 16 | Cards de contenido, contenedores de sección |
| `DS.Radius.button` | 12 | Botones interactivos, CTAs, option pickers |
| `DS.Radius.setRow` | 10 | Filas de serie en sesión activa |
| `DS.Radius.chip` | 8 | Badges de músculo, macro pills, status chips |
| `DS.Radius.inner` | 4 | Elementos anidados dentro de cards |
| `DS.Sizing.macroRingOuter` | 140 | Anillo exterior de macros |
| `DS.Sizing.restTimerRing` | 180 | Anillo del temporizador de descanso |
| `DS.Sizing.minTapTarget` | 44 | Área mínima de tap (HIG) |

---

## Tokens de color

Todos los colores vienen de `Color+DesignSystem.swift` — nunca valores RGB literales en vistas.
La app soporta light y dark mode completo. Todos los tokens son adaptativos vía Asset Catalog.

| Token | Light | Dark | Uso |
|-------|-------|------|-----|
| `.accent` | `#0A7AFF` | `#0A84FF` | CTAs, progreso activo, tint de la app |
| `.success` | `#34C759` | `#30D158` | Series completadas, metas alcanzadas |
| `.warning` | `#FF9500` | `#FF9F0A` | Volumen bajo óptimo, alertas suaves |
| `.error` | `#FF3B30` | `#FF453A` | Volumen sobre MRV, errores |
| `.macroProtein` | `#007AFF` | `#0A84FF` | Anillo y badge de proteína |
| `.macroCarbs` | `#FF9500` | `#FF9F0A` | Anillo y badge de carbohidratos |
| `.macroFat` | `#FFCC00` | `#FFD60A` | Anillo y badge de grasa |
| `.backgroundPrimary` | `#F5F5F5` | `#000000` | Fondo de pantalla — nunca blanco puro |
| `.backgroundCard` | `#FFFFFF` | `#1C1C1E` | Cards y list rows |
| `.backgroundSecondary` | `#EBEBEB` | `#2C2C2E` | Superficies secundarias, grouped insets |
| `.textPrimary` | `#1C1C1E` | `#FFFFFF` | Texto principal — headings, valores |
| `.textSecondary` | `#6C6C70` | `#8E8E93` | Subtítulos, metadatos — WCAG AA ✓ |
| `.textTertiary` | `#AEAEB2` | `#636366` | Solo decorativo — nunca texto informativo |
| `.textOnAccent` | `#FFFFFF` | `#FFFFFF` | Texto sobre fondos de acento |
| `.borderSubtle` | `#E5E5EA` | `#38383A` | Bordes sutiles, separadores |

### Colores de grupos musculares

`Color.muscleGroup("chest")` — definidos en `Color+DesignSystem.swift`.
Usan colores adaptativos del sistema (no necesitan asset catalog).

| ID | Color |
|----|-------|
| `"chest"` | `.blue` |
| `"back"` | `.green` |
| `"legs"` / `"quadriceps"` / `"hamstrings"` | `.red` |
| `"shoulders"` | `.purple` |
| `"biceps"` | `.orange` |
| `"triceps"` | `.yellow` |
| `"core"` / `"abs"` | `.teal` |
| `"glutes"` | `.pink` |
| `"calves"` | `.brown` |
| `"cardio"` / `"fullbody"` | `.cyan` |

---

## Tipografía

- **SF Pro Display:** Large Title, Title 1 — encabezados de módulo
- **SF Pro Text:** Body, Subheadline, Caption — contenido y UI general
- **SF Mono:** pesos (kg), repeticiones y valores numéricos en sesión activa — alineación perfecta en columnas
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

---

## Componentes reutilizables clave

Viven en `Shared/DesignSystem/`. Usar siempre estos en vez de reimplementar.

| Componente | Tipo | Props / Uso |
|-----------|------|-------------|
| `MacroRingView` | View | `proteinCurrent/Goal`, `carbsCurrent/Goal`, `fatCurrent/Goal` — tres anillos con Swift Charts. Usado en Dashboard, Nutrición y Widget |
| `ExerciseSetRow` | View | Estado `pending/active/completed`. Spring animation + haptic al completar |
| `MetricTrendCard` | View | Métrica principal, valor actual, delta vs período anterior, sparkline — Progreso y Dashboard |
| `MuscleGroupBadge` | View | Nombre del grupo muscular + SF Symbol. Colores consistentes por grupo |
| `NutritionProgressBar` | View | Gradiente: azul → verde → naranja al superar objetivo |

---

## Háptica

| Momento | Tipo |
|---------|------|
| Completar una serie | `.success` |
| Iniciar temporizador de descanso | `.rigid` |
| Finalizar temporizador (0s) | Secuencia: 3 pulsos crecientes |
| Personal Record detectado | `.notification` heavy |
| Marcar comida completada | `.light` |

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

---

## Para pedirme diseño

Dime:
1. Qué pantalla es y qué módulo pertenece
2. Cuál es la acción principal del usuario en esa pantalla
3. Si es una pantalla de sesión activa o de consulta (afecta a densidad de información)

Propongo la jerarquía visual, el uso correcto de glass y los tokens de color antes de escribir código.
