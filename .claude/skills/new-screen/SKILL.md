---
name: new-screen
description: Crea pantalla SwiftUI + ViewModel siguiendo las convenciones de Forma. Uso: /new-screen NombrePantalla
disable-model-invocation: true
---

Crea una nueva pantalla SwiftUI para: $ARGUMENTS

1. Identifica a qué Feature pertenece y en qué subcarpeta de `Features/` debe vivir
2. Lee el spec en `.claude/specs/features/` si existe para esta pantalla, y `.claude/specs/design/CLAUDE.md` para las reglas de diseño
3. Crea `Features/<Modulo>/<Nombre>/$ARGUMENTSView.swift` — View pasiva, sin lógica de negocio
4. Si la pantalla tiene estado o lógica no trivial, crea `Features/<Modulo>/<Nombre>/$ARGUMENTSViewModel.swift`:
   - `@MainActor @Observable final class $ARGUMENTSViewModel`
   - Dependencias inyectadas por `init` como protocolos, no instancias concretas
5. Inyección de servicios: `@Environment(\.appContainer)` — no importes servicios directamente en la View
6. Subcomponentes de un solo uso → `private struct` al final del mismo archivo
7. Extrae a archivo propio en `Shared/DesignSystem/` solo si el componente se reutiliza en 2+ vistas
8. Todos los colores desde tokens del DesignSystem, nunca literales
9. SF Symbols para todos los iconos — nunca assets custom para iconos de sistema
10. Glass solo en navigation layer (FABs, botones flotantes, sheets) — nunca en content layer
11. Añade `.accessibilityLabel` en elementos interactivos con iconos, `.accessibilityHidden(true)` en decorativos
12. Respeta `@Environment(\.accessibilityReduceMotion)` en todas las animaciones
13. No añadas navegación — la gestiona el ViewModel o `NavigationPath` del módulo
14. Sigue exactamente las convenciones del CLAUDE.md
