# Spec: Sesión Activa de Entrenamiento

## Prioridad
**Flujo crítico MVP** — no puede fallar bajo ninguna circunstancia.

## El flujo completo

```
WorkoutDay → [Iniciar sesión] → WorkoutSession (SwiftData) → Registro de series
→ LoggedSet persiste en SwiftData → Temporizador de descanso (ActivityKit Live Activity)
→ [Finish workout] → completedAt = .now → export opcional a HealthKit (HKWorkout)
→ Post-workout summary
```

`ActiveSessionViewModel` recibe un `ActiveSessionInteractorProtocol` en su `init` (capa Interactor — ver `.claude/specs/decisions/002-arquitectura-mvvm.md`); el Interactor es quien llama a `WorkoutSessionService`, al repositorio de sesiones y a `HealthKitService`.

## Estado de la sesión en SwiftData

`WorkoutSession` se crea al pulsar "Iniciar" con `completedAt = nil`. `isCompleted` es una propiedad computada (`completedAt != nil`), no un campo guardado aparte. Si el usuario cierra la app, la sesión persiste y se puede continuar. Solo se establece `completedAt` al pulsar "Finish workout" y confirmar el resumen (`WorkoutSessionService.completeSession`, que hace `session.completedAt = .now`).

## Export a HealthKit al finalizar — ya implementado (no es V1.1)

`ActiveSessionViewModel.completeSession()` hace, en este orden:
1. `interactor.completeSession(session)` → persiste `completedAt`
2. Cancela el `Task` del temporizador de descanso y cierra la Live Activity (`interactor.endRestActivity()`)
3. Lee `UserDefaults` la clave `"com.armando.forma.exportWorkoutsToHealth"` (el toggle "Export workouts to Health" de Settings, default `true`)
4. Si está activo y `session.completedAt` existe, llama a `interactor.writeWorkout(activityType:start:end:)`, que delega en `HealthKitService.writeWorkout` (crea un `HKWorkoutBuilder`, hace `beginCollection`/`endCollection`/`finishWorkout`)

Mapeo de `sessionType` a `HKWorkoutActivityType` (`ActiveSessionViewModel.hkActivityType`): `.planned`/`.freeStyle` → `.traditionalStrengthTraining`, `.cardio` → `.mixedCardio`, `.mobility` → `.flexibility`. Detalle completo en `.claude/specs/features/healthkit-improvements.md`.

## Live Activity — temporizador de descanso

`RestTimerAttributes` (`Forma/Shared/LiveActivity/RestTimerAttributes.swift`) — verificado contra el código actual:

```swift
struct RestTimerAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable, Sendable {
        var endsAt: Date
    }
    var exerciseName: String
    var totalSeconds: Int
}
```

`exerciseName` y `totalSeconds` son propiedades estáticas de `ActivityAttributes` (fijas durante toda la Activity), no del `ContentState`. El `ContentState` solo lleva `endsAt: Date` — no existen `remainingSeconds` ni `nextSetPreview`.

- `ActiveSessionViewModel.startRestTimer` lanza un `Task` que llama a `interactor.startRestActivity(exerciseName:seconds:)` y luego recorre `stride(from: seconds - 1, through: 0, by: -1)` con `try? await Task.sleep(for: .seconds(1))` por iteración, actualizando `restSecondsRemaining` en el ViewModel para la UI local de la app — esto **no** es un `AsyncStream`.
- La Live Activity (widget) no necesita que nadie la "tickee": renderiza su propia cuenta atrás declarativamente con `Text(timerInterval: Date.now...context.state.endsAt, countsDown: true)` a partir de `endsAt`.
- Al llegar a 0: se dispara `restJustEnded`, que activa `.sensoryFeedback(.success, trigger:)` en `ActiveSessionView`. (La doble háptica de 3 pulsos descrita en el design system todavía no está implementada — ver `.claude/specs/design/CLAUDE.md`.)

## Lógica de pre-relleno de peso

Confirmado en `ActiveSessionViewModel.loadLastWeight(for:)`, llamado desde `.task(id: exercise.id)` en `ActiveSessionView`:
1. Si ya hay un valor en `weightInputs[exercise.id]`, no hace nada
2. Si no, llama a `interactor.fetchLastSets(for:exerciseName:)` (delega en `WorkoutSessionService.fetchLastSets`, que busca la sesión completada más reciente del mismo `WorkoutDay`) y precarga el peso del primer set encontrado
3. Si no hay sesión anterior: campo vacío

## Navegación entre ejercicios

**No es swipe** — `exerciseNavigationHeader` en `ActiveSessionView.swift` usa botones con chevron izquierda/derecha (`viewModel.navigatePrevious()` / `navigateNext()`). No hay `DragGesture` ni `TabView` paginado en esta vista. El estado de cada ejercicio (`LoggedSet`s completados) se mantiene independientemente de qué ejercicio está visible.

## Consideraciones de UX para sesión activa

- `.monospacedDigit()` (modificador del sistema, no una fuente "SF Mono" custom) para los valores numéricos (peso, reps, RIR) — alineación en columnas
- Botones grandes — el usuario puede tener las manos ocupadas o mojadas
- Teclado decimal para peso, entero para reps y RIR
- Micro-botones `+2.5` / `-2.5` sin abrir teclado
- Sin animaciones complejas — la legibilidad es prioritaria sobre la estética aquí

## Qué NO hace esta pantalla

- No navega a ningún otro módulo durante la sesión
- No sincroniza con CloudKit en tiempo real durante la sesión — confirmado, no hay referencias a CloudKit en `WorkoutSessionService` ni en la capa Interactor de ActiveSession
- No accede a HealthKit durante la sesión — solo al finalizar, y solo si el toggle "Export workouts to Health" está activo
- No muestra el plan nutricional del día

## Tests obligatorios

- `ActiveSessionTests+ViewModel` / `ActiveSessionTests+Interactor` (`FormaTests/Features/Training/`) — ya existen, cubren el flujo crítico
- `WorkoutSessionService`: inicio, registro de serie, pausa/reanudación, finalización — **pendiente**, no hay tests de `Data/Services/` todavía (ver `.claude/specs/patterns/testing.md`)
- `VolumeCalculatorService`: cálculo de volumen total y por músculo tras sesión — **pendiente**
- Que `LoggedSet` persiste correctamente cuando la app va a background — cubierto indirectamente por ser parte del flujo de SwiftData, sin test dedicado
