# Spec: Sugerencia de progresión de carga (doble progresión + RIR)

## Resumen
En vez de un cálculo pasivo de 1RM/PR (descartado, ver `strength-prs.md` histórico), la app sugiere activamente el peso y las reps objetivo de cada serie de la próxima sesión, comparando el rendimiento de la última vez con el rango de reps (`repsMin`/`repsMax`) y el RIR objetivo (`rirTarget`) ya definidos en el plan (`PlannedExercise`). El objetivo es forzar progreso real — subir peso, o si no, subir reps o RIR dentro del rango — no solo registrar historial.

**v2** — revisión tras contrastar el diseño original con un caso real de entrenamiento (serie top + series backoff con pesos distintos: 50kg/8/RIR2 → 40kg/8/RIR0 → 38kg/8/RIR8). El diseño v1 comparaba siempre contra la primera serie de la última sesión y precargaba el input en silencio; ninguna de las dos cosas se sostenía en la práctica. Cambios respecto a v1:
- La sugerencia ahora es **por serie individual**, no una única sugerencia compartida por ejercicio.
- Ya no hay prefill silencioso: se muestra el dato de referencia de la última vez + un botón explícito para aplicar la sugerencia.

## Por qué se descartó la idea original (PRs / 1RM)
- Calcular 1RM y detectar PRs es puramente informativo, no cambia el comportamiento del usuario ni fuerza progreso — apps como Strong/Hevy ya lo hacen y no aportan valor diferencial.
- La doble progresión + autorregulación por RIR es el método estándar evidence-based para progresión de carga (usado por apps como RP Hypertrophy, Juggernaut AI): se entrena dentro de un rango de reps, se sube el peso solo al llegar al techo del rango con el RIR objetivo cumplido; si no, se progresa en reps o se mantiene.

## Problema que resuelve
Hoy `ActiveSessionViewModel.loadLastWeight` (`Forma/Features/Training/ActiveSession/ActiveSessionViewModel.swift:174-185`) solo copia el peso de la última vez tal cual, sin comparar contra el objetivo del plan ni sugerir avance. El usuario decide manualmente si subir peso, sin ninguna guía. `PlannedExercise` (`Forma/Domain/Models/PlannedExercise.swift:16-19`) ya tiene `repsMin`, `repsMax` y `rirTarget` por ejercicio — la infraestructura para saber "qué tan cerca estuvo del objetivo" ya existe pero no se usa para generar una sugerencia. `ActiveSessionInteractor.fetchLastSets(for:exerciseName:)` ya trae **todas** las series de la última sesión completada de ese `workoutDay` — tampoco hace falta nueva query ni cruzar mesociclos.

## Flujo principal
1. El usuario abre una sesión activa para un `WorkoutDay` con ejercicios planificados (flujo existente, sin cambios)
2. Al mostrar un `PlannedExercise`, el sistema busca **todas** las series de la última sesión completada de ese mismo `workoutDay` para ese `exerciseName` (ya existe: `fetchLastSets`, ahora se usan todas las series, no solo la primera)
3. Antes de registrar la serie N de hoy, se elige una **serie de referencia** dentro de esa última sesión (ver "Selección de la serie de referencia") y se calcula una sugerencia de peso y reps según la regla de doble progresión + RIR (ver más abajo)
4. Si hay serie de referencia, se muestra un texto informativo ("Última vez: `peso` × `reps` @ RIR `rir`") junto con un botón "Usar sugerencia" que muestra el valor calculado; los inputs de peso y reps (`weightInputs`, `repsInputs`, ya existentes en `ActiveSessionViewModel`) **no se autorellenan** — solo se escriben si el usuario toca el botón
5. El usuario registra la serie con el valor que decida: el sugerido (tras tocar el botón), uno editado a mano, o uno propio desde cero

## Selección de la serie de referencia (por serie, no por ejercicio)
Dado el array `lastSets` (todas las series de la última sesión completada para ese ejercicio, ordenadas por `order`) y el número de serie que se va a registrar hoy (`setNumber`, 1-indexed):

- Si `lastSets` está vacío → **no hay serie de referencia, no hay sugerencia** (ver "Ejercicio saltado por completo")
- Si `lastSets.count >= setNumber` → la referencia es `lastSets[setNumber - 1]` (la serie N de la última vez, comparando como-con-como: serie top con serie top, backoff con backoff)
- Si `lastSets.count < setNumber` (la última vez se registraron menos series de las que se van a hacer hoy) → la referencia es `lastSets.last` (la última serie disponible, repetida para las series "de más" de hoy)

Esto reemplaza el modelo v1 donde solo la primera serie de la última sesión generaba sugerencia y el resto del ejercicio compartía un único input sin sugerencia propia.

## Ejercicio saltado por completo (sin cambios respecto a "primera vez")
`ActiveSessionView` permite navegar al siguiente ejercicio (`chevron.right` en `exerciseNavigationHeader`) sin haber registrado ninguna serie, y `completeSession()` no valida que todos los ejercicios tengan series — una sesión puede completarse con ejercicios en 0 series. Si la **última sesión completada** de ese `workoutDay` tiene 0 series para un ejercicio (se saltó la vez pasada), `fetchLastSets` devuelve `[]` y, por la regla de selección de arriba, no hay serie de referencia ni sugerencia esta vez — mismo trato visual que la primera vez que se hace el ejercicio (sin texto de referencia, sin botón, input vacío).

**No se busca en sesiones anteriores a la más reciente completada.** Aunque existan datos buenos de 2 sesiones atrás, si la última sesión saltó el ejercicio, no hay sugerencia. Decisión deliberada para mantener `fetchLastSets` simple (una sola sesión, sin heurísticas de "búsqueda hacia atrás"); el usuario corrige a mano esa vez y la sugerencia vuelve a funcionar la sesión siguiente.

## Regla de sugerencia (doble progresión + autorregulación por RIR)
Dada la serie de referencia (`refSet`, ver selección arriba), el `PlannedExercise` (`repsMax`, `repsMin`, `rirTarget`) y el `equipment` del `Exercise` asociado (ver "Campo de equipo"):

1. **Sube peso** si `refSet.reps >= repsMax` Y (`rirActual == nil` O `rirActual >= rirTarget`) Y (`equipment != .bodyweight` O `refSet.weightKg > 0`)
   → `pesoSugerido = refSet.weightKg × (1 + incremento)`, redondeado al 0.5 kg más cercano, mínimo +0.5 kg sobre el peso anterior, donde `incremento` depende del equipo:
     - Barra / Máquina·Polea / sin especificar / peso corporal con lastre → **+2.5%**
     - Mancuerna → **+5%** (los tamaños disponibles saltan más grueso, +2.5% a menudo no alcanza el siguiente par real)
   → `repsSugeridas = repsMin` (vuelve a la base del rango con el peso nuevo)
2. **Sube reps** si `refSet.reps < repsMax`, o si `equipment == .bodyweight` y `refSet.weightKg == 0` y ya está en `repsMax`
   → `pesoSugerido = refSet.weightKg` (sin cambio)
   → `repsSugeridas = min(refSet.reps + 1, repsMax)` (para peso corporal sin lastre en `repsMax`, se mantiene ahí — no hay siguiente paso de peso en v1)
3. **Mantén** si `refSet.reps >= repsMax` pero `rirActual < rirTarget` (llegó a las reps pero costó más de lo prescrito)
   → `pesoSugerido = refSet.weightKg`
   → `repsSugeridas = repsMax`

La sugerencia nunca reduce el peso automáticamente en v1 (ver "Lo que NO hace").

## Interacción en sesión activa (reemplaza el prefill silencioso de v1)
- Por cada serie pendiente de registrar, si hay serie de referencia: se muestra un texto secundario ("Última vez: `peso` × `reps` @ RIR `rir`") y un botón "Usar sugerencia" con el valor calculado por la regla de arriba
- Tocar el botón escribe el valor sugerido en `weightInputs[exercise.id]` / `repsInputs[exercise.id]` (los campos existen y se mantienen editables después)
- Si no hay serie de referencia (primera vez o ejercicio saltado la última vez), no se muestra ni el texto ni el botón — el campo se comporta como hoy sin esta feature (vacío, edición manual)
- El usuario puede ignorar la sugerencia y escribir directamente sin tocar el botón

## Campo de equipo (nuevo, opcional) — sin cambios respecto a v1, ya implementado
- Nuevo enum `EquipmentType: barbell, dumbbell, machineOrCable, bodyweight` más un caso implícito "sin especificar" (equivalente al `Exercise.equipment == ""` actual)
- `AddPlannedExerciseView`: `Picker` opcional junto a los campos existentes, con un botón `info.circle` al lado que muestra un `.popover` explicando que ajusta la precisión del peso sugerido
- Enhebrado end-to-end: `AddPlannedExerciseView` → `WorkoutDayDetailViewModel.addPlannedExercise`/`updatePlannedExercise` → `WorkoutDayInteractor` → `MesocycleRepository` → `Exercise.equipmentType` (computed sobre el campo `String` existente)
- Por defecto "sin especificar" para no romper ejercicios ya creados (se comportan igual que hoy: +2.5%)

## Casos edge
- [ ] Peso muy bajo (ej. barra vacía, o accesorio con lastre mínimo) donde el % redondea a menos de 0.5 kg → aplicar el mínimo absoluto de +0.5 kg
- [ ] `repsMax`/`rirTarget` editados por el usuario en el plan entre una sesión y otra → la sugerencia usa los valores *actuales* del `PlannedExercise`, no los vigentes cuando se registró la serie de referencia (puede dar una sugerencia distinta justo tras editar el plan — aceptable, caso raro)
- [ ] `fetchLastSets` ya filtra por `workoutDay`, así que una sesión `freeStyle` sin `plannedExercise` asociado no interfiere — sin cambios necesarios ahí
- [ ] Ejercicio `bodyweight` con `weightKg > 0` (ej. dominadas lastradas) → se trata igual que barra/máquina para el % de subida de peso (el lastre añadido sí tiene sentido progresarlo); solo se omite la subida de peso cuando no aplica (dominadas sin lastre, `weightKg == 0` y ya en `repsMax`)
- [ ] Ejercicio existente creado antes de este cambio (equipment vacío) → se trata como "sin especificar", +2.5%, sin migración de datos necesaria
- [ ] Ejercicio saltado por completo la última sesión (0 series) → sin sugerencia, mismo trato que "primera vez" (ver sección dedicada arriba)
- [ ] Última sesión con menos series registradas que las de hoy (ej. la vez pasada solo se logueó 1 serie de 3 planeadas) → las series 2, 3... de hoy usan como referencia la última serie disponible de la vez pasada, repetida (ver "Selección de la serie de referencia")

## Criterios de aceptación
- [x] Nuevo enum `EquipmentType` (`barbell`, `dumbbell`, `machineOrCable`, `bodyweight`) en `Domain/Models/`, con un caso "sin especificar" (equivalente a `Exercise.equipment == ""`)
- [x] `AddPlannedExerciseView`: `Picker` opcional de equipo + botón `info.circle` con `.popover` explicativo; nuevas claves en `Localizable.xcstrings`
- [x] `equipment` enhebrado end-to-end: `AddPlannedExerciseView` → `WorkoutDayDetailViewModel` → `WorkoutDayInteractor` → `MesocycleRepository` → `Exercise.equipmentType`
- [x] Función pura en `Shared/Utilities/` actualizada: dado `lastSets: [LoggedSet]`, `setNumber: Int`, `plannedExercise: PlannedExercise` y `equipment: EquipmentType?`, selecciona la serie de referencia (ver regla de selección) y devuelve `(suggestedWeightKg: Double, suggestedReps: Int)?` (`nil` si `lastSets` está vacío)
- [x] `ActiveSessionViewModel`: ya no precarga `weightInputs`/`repsInputs` automáticamente. Cachea `lastSets` por ejercicio al entrar (`.task(id: exercise.id)`) y expone algo como `referenceSet(for:)` (para el texto informativo) y `suggestedTarget(for:)` (para el botón), recalculados en base a `nextSetNumber(for:)`; nuevo método `applySuggestion(for:)` que escribe en los inputs solo cuando se invoca
- [x] `ActiveSessionView`: nueva fila con el texto "Última vez: ..." + botón "Usar sugerencia" cerca de los campos de peso/reps, visible solo si hay serie de referencia; nuevas claves de localización
- [x] Test unitario de la función pura: los 3 casos de la regla (sube peso / sube reps / mantén) × equipo (barra, mancuerna, peso corporal con y sin lastre) + edge cases de redondeo, mínimo absoluto, `lastSets` vacío, y `lastSets.count < setNumber` (carry-forward de la última serie disponible)
- [x] Test de `ActiveSessionViewModel` cubriendo `applySuggestion` y el caso sin serie de referencia (no debe mostrar sugerencia ni fallar)

## Lo que NO hace
- No sugiere bajar peso automáticamente en v1 (deload autorregulado) — si el RIR viene muy por debajo del objetivo, la sugerencia es "mantener", nunca reducir; un deload sigue siendo decisión manual del usuario
- No calcula 1RM estimado ni tiene concepto de PR/récord histórico — la sugerencia mira solo la última sesión, no el historial completo (idea original descartada, ver arriba)
- No hace obligatorio el campo de equipo — es opcional, con fallback a +2.5% si no se especifica; no se migra ni se pide retroactivamente en ejercicios ya creados
- No busca en sesiones anteriores a la más reciente completada — si esa sesión no tiene series de un ejercicio (se saltó), no hay sugerencia esta vez aunque existan datos más antiguos (ver "Ejercicio saltado por completo")
- No autorrellena los inputs sin acción explícita del usuario (cambio respecto a v1) — siempre requiere tocar "Usar sugerencia"

## Capas afectadas
- [x] Domain (`EquipmentType`; `Exercise.equipmentType` computed sobre el `String` existente)
- [x] Shared/Utilities (función pura de sugerencia: cambia de firma para trabajar por serie, no por ejercicio)
- [x] Features/Training/WorkoutDay (`AddPlannedExerciseView`, `WorkoutDayDetailViewModel`, `WorkoutDayInteractor`: equipo enhebrado — ya implementado)
- [x] Features/Training/ActiveSession (`ActiveSessionViewModel`: reemplazar el prefill de `loadSuggestedTarget` por `referenceSet(for:)`/`suggestedTarget(for:)`/`applySuggestion(for:)`; `ActiveSessionView`: nueva fila de texto + botón; Interactor sin cambios, ya expone `fetchLastSets` con todas las series)
- [x] Data — sin cambios de repositorio (`fetchLastSets` ya devuelve todas las series necesarias)
- [x] Resources (nuevas claves en `Localizable.xcstrings`: texto "Última vez: ..." y botón "Usar sugerencia")

## Decisiones ya cerradas (spec no tiene preguntas abiertas)
- Incremento de peso: +2.5% (barra/máquina/sin especificar) o +5% (mancuerna), redondeado al 0.5 kg más cercano, mínimo absoluto +0.5 kg
- Granularidad: sugerencia **por serie individual**, comparando serie N de hoy con serie N de la última sesión (o la última serie disponible si la vez pasada se registraron menos series)
- Interacción UI: texto de referencia ("Última vez: ...") + botón explícito "Usar sugerencia"; sin autorrelleno silencioso
- Fallback de sesión saltada: si la última sesión completada no tiene series de ese ejercicio, no hay sugerencia — no se busca en sesiones más antiguas
- Campo de equipo opcional con fallback a "sin especificar" (+2.5%), sin romper ejercicios existentes — ya implementado
