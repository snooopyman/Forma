# ADR 005: @AppStorage para el flag de onboarding completado

Fecha: 2026-03-28
Estado: Aceptada

## Contexto

El onboarding solo se muestra la primera vez. Necesitamos persistir un flag booleano que indique si el usuario ya lo completó. La regla del CLAUDE.md dice "no usar UserDefaults para datos de usuario — todo en SwiftData". La pregunta es si este flag es "dato de usuario" o "estado de UI".

## Decisión

`@AppStorage("onboardingCompleted")` — el wrapper moderno de SwiftUI sobre UserDefaults. Este flag **no es un dato del usuario** (no describe su perfil, historial ni preferencias de fitness) — es estado de navegación de la app. No tiene sentido sincronizarlo vía CloudKit ni mezclarlo con `UserProfile` en SwiftData.

```swift
// En FormaApp.swift o AppContainer
@AppStorage("onboardingCompleted") private var onboardingCompleted = false
```

## Consecuencias

- ✅ Simple, directo, sin overhead de SwiftData para un único bool
- ✅ `@AppStorage` es reactivo — SwiftUI re-renderiza automáticamente cuando cambia
- ✅ No contamina el modelo de dominio con estado de UI
- ⚠️ Se pierde si el usuario borra la app (comportamiento correcto — al reinstalar debe hacer onboarding de nuevo)
- ⚠️ No se sincroniza a otros dispositivos vía CloudKit (comportamiento correcto — cada dispositivo hace su propio onboarding)
- ❌ No usar `UserDefaults.standard.set(_, forKey:)` directamente — siempre `@AppStorage`

## Cuándo revisitar

Si el onboarding necesita guardar estado intermedio complejo (más de 1-2 valores simples), en ese caso considerar un modelo SwiftData `OnboardingState`.
