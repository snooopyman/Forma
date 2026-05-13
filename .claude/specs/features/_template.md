# Spec: [Nombre]

## Resumen
[Una frase: qué hace y para quién]

## Problema que resuelve
[Sin esto, el usuario no puede hacer X]

## Flujo principal
1. El usuario hace X
2. El sistema responde con Y
3. El usuario ve Z

## Flujos alternativos
- Sin HealthKit / no autorizado → [comportamiento]
- Sin plan nutricional activo → [comportamiento]
- Sin mesociclo activo → [comportamiento]
- Sin Apple Watch → [comportamiento — no romper UI]
- Cargando → [skeleton / spinner / nada]
- Sin datos → [empty state]

## Casos edge
- [ ] ¿Qué pasa si HealthKit no está disponible (iPad sin Health)?
- [ ] ¿Qué pasa si el usuario revoca permisos desde Configuración?
- [ ] ¿Qué pasa si la sesión dura 0 segundos o se descarta?
- [ ] ¿CloudKit sync afecta a estos datos?

## Criterios de aceptación
- [ ] [condición verificable]

## Lo que NO hace
[Explícito es mejor que implícito]

## Capas afectadas
- [ ] Domain (nuevo modelo / propiedad @Transient)
- [ ] Data (repository, service o HealthKitService)
- [ ] Features (ViewModel + View)
- [ ] Shared (DesignSystem, Extensions)
- [ ] Resources (Localizable.xcstrings)

## Preguntas abiertas
- [ ] [responder antes de implementar]
