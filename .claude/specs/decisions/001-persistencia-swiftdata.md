# ADR 001: SwiftData como capa de persistencia

Fecha: 2026-03-28
Estado: Aceptada

## Contexto

Necesitamos persistencia local para todos los modelos de la app: mesociclos, sesiones, mediciones corporales, plan nutricional y perfil de usuario. La alternativa natural era CoreData.

## Decisión

SwiftData puro, con sync CloudKit habilitado vía `ModelConfiguration(cloudKitDatabase:)` — sin usar `NSPersistentCloudKitContainer` (esa es la API de CoreData; SwiftData expone el mismo mecanismo a través de `ModelConfiguration`). Código declarativo con `@Model`, integración nativa con Swift 6, `@Observable` y CloudKit sync automático sin configuración extra.

`FormaModelContainer.swift` arma el `ModelConfiguration` con la URL del store dentro del App Group (`group.com.armando.forma`) y, fuera del simulador, con `cloudKitDatabase: .private("iCloud.com.armando.forma")`. En el simulador no se pasa `cloudKitDatabase` (limitación de entitlements) — solo persistencia local. Si la apertura del store falla (corrupción), `FormaModelContainer` borra el `.sqlite`/`-shm`/`-wal` y reintenta con un store limpio antes de rendirse.

## Consecuencias

- ✅ Modelos como clases Swift normales con `@Model` — sin XML ni NSManagedObject
- ✅ CloudKit sync automático con el contenedor `iCloud.com.armando.forma`, vía `ModelConfiguration.cloudKitDatabase` (no se usa `NSPersistentCloudKitContainer`)
- ✅ Métricas calculadas (`bodyFatPercent`, `bmi` en `BodyMeasurement`) como propiedades computadas normales — nunca se persisten porque no tienen storage, sin necesidad de marcarlas `@Transient` explícitamente
- ✅ Compatible con async/await y `@Observable` de forma nativa
- ⚠️ Menos maduro que CoreData — algunos edge cases en migraciones complejas requieren workarounds
- ❌ No se vuelve a CoreData salvo migración forzada por Apple

## Cuándo revisitar

Si SwiftData no soporta un predicado o migración crítica que CoreData sí soportaría.
