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
2. ¿ViewModels son `@MainActor @Observable`? ¿Ninguno usa `ObservableObject`? (el `@MainActor` es obligatorio, no decorativo — el default del módulo es `nonisolated`)
3. ¿Las Views son pasivas (sin lógica de negocio, sin acceso directo a SwiftData)?
4. ¿Alguna View accede directamente a un Service o repositorio en vez de pasar por ViewModel o `@Environment`?
5. **¿El ViewModel llama a un `RepositoryProtocol`/`ServiceProtocol` directamente en vez de a su `{Feature}InteractorProtocol`?** Comprueba tanto el `init` (¿qué tipo recibe?) como cada método (¿qué llama por dentro?) — un `init` correcto con un método que hace `try await someRepository.x()` en vez de `try await interactor.x()` es el mismo bug aunque el `init` parezca bien. (Encontrado en 11/15 features el 2026-07-01 — ver `.claude/specs/decisions/002-arquitectura-mvvm.md`.)
6. ¿Las dependencias se inyectan por `init` como protocolos, no como instancias concretas? Para un ViewModel, el protocolo correcto es siempre el Interactor de su feature, nunca un Repository/Service.
7. Si el cambio toca un test `+Interactor.swift`: ¿el `sut` es la clase Interactor real (`{Feature}Interactor`) probada contra un Spy de Repository/Service? Si el `sut` es el propio `Spy{Feature}Interactor`, el test no cubre ningún código de producción — ver `.claude/specs/patterns/testing.md`.

**Design System**
8. ¿Colores o fuentes hardcodeados en vez de tokens del DesignSystem?
9. ¿Se usa `.glassEffect()` en content layer (listas, cards, ScrollViews)? — solo en navigation layer
10. ¿Se usan `.buttonStyle(.glass)` y `.glassEffect()` juntos en el mismo elemento?
11. ¿Se usa `AnyView` en algún sitio? — type erasure prohibido
12. ¿Fondo blanco puro (`Color.white`) en vez de `backgroundPrimary` (`#F5F5F5`)?

**Flujo crítico**
13. ¿Hay algún cambio que afecte al flujo: LoggedSet → WorkoutSession → Live Activity? Verificar que el registro de serie persiste correctamente y el Live Activity se actualiza.

**Accesibilidad**
14. ¿Iconos decorativos sin `.accessibilityHidden(true)`?
15. ¿Vistas compuestas sin `.accessibilityElement(children: .ignore)` + label explícito?
16. ¿Animaciones sin respetar `@Environment(\.accessibilityReduceMotion)`?
17. ¿Valores numéricos en Text sin `Text(verbatim:)` o formatters explícitos?

**Convenciones**
18. ¿Nombres siguen las convenciones del CLAUDE.md? (sufijos `View`, `ViewModel`, `Service`, `Repository`, `RepositoryProtocol`)
19. ¿Componente nuevo de un solo uso extraído a archivo propio en vez de `private struct`?
20. ¿Componente reutilizable en 2+ vistas que no está en `Shared/DesignSystem/`?
21. ¿Comentarios en español explicando el POR QUÉ, no el qué?

**Swift 6 / Concurrencia**
22. ¿Warnings de strict concurrency? ¿Tipos que cruzan actor boundaries sin `Sendable`?
23. ¿`UserDefaults.standard` accedido directamente en vez de `@AppStorage`?
24. ¿`bodyFatPercent` o `bmi` persistidos como campo en vez de `@Transient`?

Para cada problema encontrado: archivo, número de línea aproximado, qué está mal y cómo corregirlo.

Referencia de patrones: `.claude/specs/patterns/` (ui-patterns, data-patterns, testing, utilities)
