---
name: new-screen
description: Crea pantalla SwiftUI + ViewModel siguiendo las convenciones de Forma. Uso: /new-screen NombrePantalla
disable-model-invocation: true
---

Crea una nueva pantalla SwiftUI para: $ARGUMENTS

1. Identifica a qué Feature pertenece y en qué subcarpeta de `Features/` debe vivir
2. Lee `.claude/specs/design/CLAUDE.md` para reglas de diseño y `.claude/specs/patterns/ui-patterns.md` para patrones de ViewModel/View. Si existe un spec en `.claude/specs/features/` para esta pantalla, léelo también.
3. Crea `Features/<Modulo>/<Nombre>/$ARGUMENTSView.swift` — View pasiva, sin lógica de negocio
4. Si la pantalla tiene estado o lógica no trivial, crea `Features/<Modulo>/<Nombre>/$ARGUMENTSViewModel.swift`:
   - `@MainActor @Observable final class $ARGUMENTSViewModel` — el `@MainActor` explícito es obligatorio (el default del módulo es `nonisolated`, no se infiere)
   - Recibe un `{Nombre}InteractorProtocol` en el `init` — **nunca** un `RepositoryProtocol`/`ServiceProtocol` directamente. Si la pantalla necesita datos de un repositorio, crea también `Features/<Modulo>/<Nombre>/Interactor/{Nombre}Interactor.swift` (+ `{Nombre}InteractorProtocol.swift` + `Mock{Nombre}Interactor.swift`), y es el Interactor quien recibe el repositorio en su `init` — ver `.claude/specs/patterns/data-patterns.md` sección 2 y `.claude/specs/decisions/002-arquitectura-mvvm.md`
5. Inyección de servicios: la View recibe el repositorio/servicio en su `init` (o lo lee de `@Environment(AppContainer.self)`) y construye el Interactor+ViewModel ahí mismo — no importes servicios directamente en el `body` de la View
6. Subcomponentes de un solo uso → `private struct` al final del mismo archivo
7. Extrae a archivo propio en `Shared/DesignSystem/` solo si el componente se reutiliza en 2+ vistas
8. Todos los colores desde tokens del DesignSystem, nunca literales
9. SF Symbols para todos los iconos — nunca assets custom para iconos de sistema
10. Glass solo en navigation layer (FABs, botones flotantes, sheets) — nunca en content layer
11. Añade `.accessibilityLabel` en elementos interactivos con iconos, `.accessibilityHidden(true)` en decorativos
12. Respeta `@Environment(\.accessibilityReduceMotion)` en todas las animaciones
13. No añadas navegación — la gestiona el ViewModel o `NavigationPath` del módulo
14. Sigue exactamente las convenciones del CLAUDE.md
