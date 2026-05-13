# Spec: HealthKit — HKWorkout Export + Dashboard contextual

## Resumen
Exportar entrenamientos a Apple Salud al finalizar sesión (para cerrar los anillos de Actividad) y mostrar las métricas del Dashboard con progreso hacia metas diarias, no solo como números sueltos.

## Problema que resuelve
Sin esto:
- Los anillos de Actividad de Apple nunca reconocen un entreno hecho en Forma
- El Dashboard muestra pasos/calorías/minutos sin contexto — el usuario no sabe si lo está haciendo bien o mal

## Flujo principal — HKWorkout Export

1. El usuario completa un entreno pulsando "Finish workout" y confirmando
2. `ActiveSessionViewModel.completeSession()` llama a `sessionService.completeSession(session)` → `session.completedAt` se establece
3. A continuación llama a `healthKitService.writeWorkout(activityType:start:end:)`
4. `HealthKitService` crea un `HKWorkoutBuilder`, abre colección, la cierra y llama a `finishWorkout()`
5. El entrenamiento aparece en Apple Salud como "Fuerza tradicional" (o Cardio / Flexibilidad según tipo)
6. Los anillos de Actividad del día se actualizan con la duración del entreno

## Flujo principal — Dashboard contextual

1. El Dashboard carga y llama a `loadHealthKitData()`
2. `DashboardView` calcula `stepsProgress` y `exerciseProgress` localmente desde `@AppStorage`
3. La tarjeta de Actividad muestra:
   - Pasos: valor + "/ X,XXX" + barra de progreso verde
   - Calorías: valor + "kcal" (sin barra — sin meta fija)
   - Ejercicio: valor en minutos + "/ Xm" + barra de progreso azul
4. La meta de pasos por defecto es 10.000 y se persiste en `@AppStorage`
5. La meta de ejercicio por defecto es 30 min y se persiste en `@AppStorage` (opciones: 15–120 min, step 15)

## Flujos alternativos

- **HealthKit no autorizado** → La tarjeta de Actividad sigue mostrando el botón "Connect with Health". Sin cambios de comportamiento
- **HealthKit no disponible** (iPad sin Health) → `HealthKitService.writeWorkout` hace guard `isAvailable` y retorna silenciosamente. La tarjeta de Actividad muestra "Health not available on this device"
- **Sesión descartada** → `discardSession()` no llama a `writeWorkout`. El entrenamiento no se registra en HealthKit
- **Error al escribir en HealthKit** → `writeWorkout` captura el error, lo loguea con `Logger.healthKit` y retorna silenciosamente. El usuario no ve ningún mensaje de error
- **Sin plan nutricional activo** → La columna de Calorías muestra solo el número y "kcal", sin barra de progreso
- **ProgressView con 0 pasos** → Barra vacía, sin crasheo. `min(..., 1.0)` previene overflow
- **Toggle "Export workouts to Health" desactivado** → `completeSession()` omite `writeWorkout`. No se crea ningún `HKWorkout`
- **Usuarios con Apple Watch** → desactivar el toggle evita duplicados en la app Salud (los anillos son seguros igualmente porque iOS deduplica tiempos solapados)

## Casos edge

- [x] HealthKit no disponible (iPad) → `guard isAvailable` en `writeWorkout` y `fetchTodaySum`
- [x] Usuario revoca permisos → `HKWorkoutBuilder.finishWorkout()` lanza error que se captura y loguea
- [x] Sesión de 0 segundos o con `completedAt == nil` → `if let end = session.completedAt` previene la llamada
- [x] `dailyStepsGoal = 0` → `guard dailyStepsGoal > 0` en `stepsProgress` retorna 0
- [x] Steps > goal → `min(..., 1.0)` en los computed properties
- [x] `dailyExerciseGoal = 0` → guard análogo en `exerciseProgress` retorna 0
- [x] Toggle OFF → `UserDefaults.standard.object(forKey:) as? Bool ?? true` — default ON si la clave no existe aún
- [ ] Sincronización CloudKit: los `WorkoutSession` ya se sincronizan; el `HKWorkout` es independiente y vive en HealthKit, no en SwiftData

## Criterios de aceptación

- [ ] Al completar una sesión de tipo `planned` o `freeStyle`, aparece un entrenamiento "Fuerza tradicional" en Apple Salud con la duración correcta
- [ ] Al completar una sesión de tipo `cardio`, aparece como "Cardio mixto" en Apple Salud
- [ ] Al completar una sesión de tipo `mobility`, aparece como "Flexibilidad" en Apple Salud
- [ ] Los anillos de Actividad del día reflejan la duración del entreno
- [ ] Descartar una sesión NO crea ningún HKWorkout
- [ ] Si HealthKit no está autorizado, no se produce ningún crasheo ni error visible
- [ ] El Dashboard muestra barra de progreso bajo "Pasos" con meta de 10.000 por defecto
- [ ] El Dashboard muestra barra de progreso bajo "Ejercicio" con meta configurable (default 30 min)
- [ ] La barra de pasos llega al 100% y no desborda si se supera la meta
- [ ] La meta de pasos persiste entre reinicios de app (`@AppStorage`)
- [ ] La meta de ejercicio persiste entre reinicios de app (`@AppStorage`, opciones 15–120 min step 15)
- [ ] Cambiar la meta en Settings → el Dashboard refleja el nuevo progreso inmediatamente
- [ ] Toggle "Export workouts to Health" desactivado → no se crea ningún HKWorkout al finalizar sesión
- [ ] Toggle activado por defecto para usuarios nuevos (primera instalación)

## Lo que NO hace

- No escribe `HKWorkout` con datos de calorías (se necesitaría un monitor de HR o estimación — demasiada variabilidad para MVP)
- No lee `HKWorkout` de otras apps para el Dashboard
- No sincroniza sesiones ya completadas antes de esta actualización
- No edita la meta de pasos desde el Dashboard (queda para Settings en V1.1)
- No añade la FC en reposo ni señal de recuperación (descartado en esta iteración)
- No sincroniza `bodyFatPercentage` (descartado en esta iteración)

## Capas afectadas

- [x] Data → `HealthKitService` (nuevo método `writeWorkout`, `HKObjectType.workoutType()` en writeTypes)
- [x] Features/Training/ActiveSession → `ActiveSessionViewModel` (nueva dependencia + llamada), `ActiveSessionView` (nuevo parámetro)
- [x] Features/Dashboard → `DashboardView` (metas y progress bars via `@AppStorage`, VM solo expone datos brutos)
- [x] Features/Training/WorkoutDay → `WorkoutDayDetailView` (propagación de `healthKitService` a `ActiveSessionView`)

## Preguntas abiertas

- [x] Meta de pasos configurable desde Settings → `@AppStorage` compartido entre `DashboardView` y `SettingsView`
- [x] Meta de ejercicio configurable desde Settings → `@AppStorage` compartido, opciones 15–120 min step 15
- [x] Toggle "Export workouts to Health" → en Settings, sección "Activity Goals". Default ON. Usuarios con Apple Watch lo desactivan para evitar duplicados en Salud
- [ ] ¿Mostramos una confirmación visual ("Workout saved to Health") al finalizar sesión, o es suficiente con que aparezca en Salud automáticamente?
