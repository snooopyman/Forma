# Spec: Sesión Activa de Entrenamiento

## Prioridad
**Flujo crítico MVP** — no puede fallar bajo ninguna circunstancia.

## El flujo completo

```
WorkoutDay → [Iniciar sesión] → WorkoutSession (SwiftData) → Registro de series
→ LoggedSet persiste en SwiftData → Temporizador de descanso (ActivityKit Live Activity)
→ [Finalizar] → WorkoutSession.isCompleted = true → HKWorkout a HealthKit (V1.1)
→ Post-workout summary
```

## Estado de la sesión en SwiftData

`WorkoutSession` se crea al pulsar "Iniciar" con `isCompleted = false`. Si el usuario cierra la app, la sesión persiste y se puede continuar. Solo se marca `isCompleted = true` al pulsar "Finalizar" y confirmar el resumen.

## Live Activity — temporizador de descanso

```swift
struct RestTimerAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var remainingSeconds: Int
        var totalSeconds: Int
        var exerciseName: String
        var nextSetPreview: String  // "Serie 3 — 100 kg × 8"
    }
    var sessionName: String
}
```

- Se inicia al pulsar "Completar serie"
- Se actualiza cada segundo con `AsyncStream`
- Al llegar a 0: haptic (3 pulsos) + notificación local
- El usuario puede saltar desde Dynamic Island → DeepLink a la app

## Lógica de pre-relleno de peso

Al mostrar una serie nueva, el campo de peso se pre-rellena con:
1. El peso de la misma serie en la última sesión del mismo `WorkoutDay`
2. Si no hay sesión anterior: campo vacío

## Navegación entre ejercicios

Swipe horizontal o botones `←` `→`. El estado de cada ejercicio (`LoggedSet`s completados) se mantiene independientemente de qué ejercicio está visible.

## Consideraciones de UX para sesión activa

- SF Mono para todos los valores numéricos (peso, reps, RIR) — alineación en columnas
- Botones grandes — el usuario puede tener las manos ocupadas o mojadas
- Teclado decimal para peso, entero para reps y RIR
- Micro-botones `+2.5` / `-2.5` sin abrir teclado
- Sin animaciones complejas — la legibilidad es prioritaria sobre la estética aquí

## Qué NO hace esta pantalla

- No navega a ningún otro módulo durante la sesión
- No sincroniza con CloudKit en tiempo real durante la sesión (al finalizar)
- No accede a HealthKit durante la sesión (solo al finalizar, en V1.1)
- No muestra el plan nutricional del día

## Tests obligatorios

- `WorkoutSessionService`: inicio, registro de serie, pausa/reanudación, finalización
- `VolumeCalculatorService`: cálculo de volumen total y por músculo tras sesión
- Que `LoggedSet` persiste correctamente cuando la app va a background
