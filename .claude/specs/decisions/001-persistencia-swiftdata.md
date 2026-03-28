# ADR 001: SwiftData como capa de persistencia

Fecha: 2026-03-28
Estado: Aceptada

## Contexto

Necesitamos persistencia local para todos los modelos de la app: mesociclos, sesiones, mediciones corporales, plan nutricional y perfil de usuario. La alternativa natural era CoreData.

## Decisión

SwiftData con `NSPersistentCloudKitContainer`. Código declarativo con `@Model`, integración nativa con Swift 6, `@Observable` y CloudKit sync automático sin configuración extra.

## Consecuencias

- ✅ Modelos como clases Swift normales con `@Model` — sin XML ni NSManagedObject
- ✅ CloudKit sync automático con el contenedor `iCloud.com.armando.forma`
- ✅ Propiedades `@Transient` para métricas calculadas (`bodyFatPercent`, `bmi`) — se recalculan en lectura, nunca se persisten
- ✅ Compatible con async/await y `@Observable` de forma nativa
- ⚠️ Menos maduro que CoreData — algunos edge cases en migraciones complejas requieren workarounds
- ❌ No se vuelve a CoreData salvo migración forzada por Apple

## Cuándo revisitar

Si SwiftData no soporta un predicado o migración crítica que CoreData sí soportaría.
