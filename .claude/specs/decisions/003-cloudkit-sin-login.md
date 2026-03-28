# ADR 003: CloudKit sin Sign in with Apple ni backend propio

Fecha: 2026-03-28
Estado: Aceptada

## Contexto

La app necesita sincronización entre dispositivos Apple del mismo usuario. Las opciones eran: Sign in with Apple + backend propio, Firebase/Supabase, o CloudKit nativo.

## Decisión

`NSPersistentCloudKitContainer` con SwiftData. CloudKit usa el Apple ID de iCloud del dispositivo como identidad de forma automática y transparente — sin pantalla de login, sin servidor.

Contenedor: `iCloud.com.armando.forma`

## Consecuencias

- ✅ Cero backend propio — sin coste de servidor, sin complejidad de auth
- ✅ Sync automático entre iPhone, iPad y Watch con el mismo Apple ID
- ✅ Offline-first: todas las operaciones van al store local; CloudKit sync es eventual
- ✅ Resolución de conflictos last-write-wins — suficiente para un único usuario
- ✅ App funciona 100% sin iCloud activo (solo local)
- ⚠️ No hay modelo multi-usuario — decisión consciente, esta app es personal
- ❌ No se implementa Sign in with Apple (requeriría servidor para validar tokens)
- ❌ No se usan servicios de terceros (Firebase, Supabase, etc.)

## Cuándo revisitar

Nunca para el caso de uso actual. Si se añadiera un modelo cliente-entrenador (descartado en PRD), requeriría backend propio.
