---
name: review
description: Code review de los cambios actuales contra las convenciones de Forma
disable-model-invocation: true
---

## Cambios actuales
- Diff: !`git diff HEAD`
- Archivos modificados: !`git status --short`

Haz code review verificando:

**Arquitectura**
1. ¿Hay GCD o callbacks `@escaping` sin justificación? (`DispatchQueue`, `DispatchGroup`, `OperationQueue`)
2. ¿ViewModels son `@MainActor @Observable`? ¿Ninguno usa `ObservableObject`?
3. ¿Las Views son pasivas (sin lógica de negocio, sin acceso directo a SwiftData)?
4. ¿Alguna View accede directamente a un Service o repositorio en vez de pasar por ViewModel o `@Environment`?
5. ¿Las dependencias se inyectan por `init` como protocolos, no como instancias concretas?

**Design System**
6. ¿Colores o fuentes hardcodeados en vez de tokens del DesignSystem?
7. ¿Se usa `.glassEffect()` en content layer (listas, cards, ScrollViews)? — solo en navigation layer
8. ¿Se usan `.buttonStyle(.glass)` y `.glassEffect()` juntos en el mismo elemento?
9. ¿Se usa `AnyView` en algún sitio? — type erasure prohibido
10. ¿Fondo blanco puro (`Color.white`) en vez de `backgroundPrimary` (`#F5F5F5`)?

**Flujo crítico**
11. ¿Hay algún cambio que afecte al flujo: LoggedSet → WorkoutSession → Live Activity? Verificar que el registro de serie persiste correctamente y el Live Activity se actualiza.

**Accesibilidad**
12. ¿Iconos decorativos sin `.accessibilityHidden(true)`?
13. ¿Vistas compuestas sin `.accessibilityElement(children: .ignore)` + label explícito?
14. ¿Animaciones sin respetar `@Environment(\.accessibilityReduceMotion)`?
15. ¿Valores numéricos en Text sin `Text(verbatim:)` o formatters explícitos?

**Convenciones**
16. ¿Nombres siguen las convenciones del CLAUDE.md? (sufijos `View`, `ViewModel`, `Service`, `Repository`, `RepositoryProtocol`)
17. ¿Componente nuevo de un solo uso extraído a archivo propio en vez de `private struct`?
18. ¿Componente reutilizable en 2+ vistas que no está en `Shared/DesignSystem/`?
19. ¿Comentarios en español explicando el POR QUÉ, no el qué?

**Swift 6 / Concurrencia**
20. ¿Warnings de strict concurrency? ¿Tipos que cruzan actor boundaries sin `Sendable`?
21. ¿`UserDefaults.standard` accedido directamente en vez de `@AppStorage`?
22. ¿`bodyFatPercent` o `bmi` persistidos como campo en vez de `@Transient`?

Para cada problema encontrado: archivo, número de línea aproximado, qué está mal y cómo corregirlo.

Referencia de patrones: `.claude/specs/patterns/` (ui-patterns, data-patterns, testing, utilities)
