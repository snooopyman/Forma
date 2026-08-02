# Spec: Alimentos personalizados

## Resumen
Flujo para que el usuario cree sus propios `FoodItem` cuando el catálogo semilla no tiene lo que busca, con formulario manual de macros.

## Problema que resuelve
`FoodItem.isCustom: Bool` (`Forma/Domain/Models/FoodItem.swift`, default `false`) ya existe en el modelo y ya está protegido del reseed del catálogo (`AppContainer.swift`, línea ~55: `FetchDescriptor<FoodItem>(predicate: #Predicate { !$0.isCustom })` borra solo los no-custom antes de re-sembrar `FoodCatalog.catalog`). Pero nada en la UI escribe nunca ese campo — `FoodBrowserView` solo tiene filtro por categoría, búsqueda y lista, sin botón de creación. `Exercise` ya tiene el patrón equivalente completo y funcionando (`WorkoutDayDetailViewModel.swift`: `Exercise(name: name, primaryMuscle: muscle, isCustom: true)`) — este spec replica ese patrón para comida.

## Flujo principal
1. El usuario busca un alimento en `FoodBrowserView` y no lo encuentra
2. Pulsa el botón "+" en la toolbar de `FoodBrowserView` (siempre visible, no solo tras búsqueda sin resultados — ver decisiones)
3. Formulario: nombre, marca (opcional), categoría, macro principal (`MacroType`), calorías/proteína/carbos/grasa/fibra por 100g, tamaño de porción base
4. Al guardar, si el nombre coincide (case-insensitive) con otro `FoodItem` existente (semilla o custom), se muestra un alert de confirmación antes de persistir el duplicado
5. Se crea `FoodItem(..., isCustom: true)` vía el repositorio existente (`FoodItemRepositoryProtocol.save`, ya soporta create/update/delete — no requiere cambios en Data)
6. El alimento aparece inmediatamente en `FoodBrowserView` junto al resto del catálogo, con un badge "Personalizado" que lo distingue del catálogo semilla

## Flujos alternativos
- Usuario introduce valores de macros inconsistentes (ej. proteína+carbos+grasa no cuadra con calorías) → no bloquear, se muestra en el formulario un cálculo de referencia en tiempo real ("con estos macros, las calorías estimadas son X") sin forzar corrección. Incluido en el alcance de V1
- Usuario quiere editar un alimento custom ya creado → debe ser posible (editar, no solo crear) — el catálogo semilla no editable, pero los custom sí. Al editar, la detección de nombre duplicado excluye el propio `id` del item que se está editando (comparar contra `allItems.filter { $0.id != editingItem.id }`), para no disparar el alert contra sí mismo cuando el usuario no cambia el nombre
- Usuario quiere borrar un alimento custom que está en uso en algún `MealOptionItem` del plan activo → **se bloquea el borrado** con un alert indicando en cuántas opciones se usa. No hay historial que preservar (a diferencia de `LoggedSet.exerciseName`): `DailyNutritionLog` no referencia `FoodItem` en absoluto, solo `MealOptionItem` (relación al plan activo) lo hace

## Decisiones (spec original tenía esto como preguntas abiertas)
- **Entry point de creación:** solo desde `FoodBrowserView`. `MealDetailView` tiene su propio `FoodPickerSheet` embebido que lee del mismo repositorio, así que el alimento nuevo aparece ahí automáticamente sin cambios — no se añade un segundo punto de entrada de creación en V1
- **Visibilidad del botón crear:** siempre visible como "+" en la toolbar de `FoodBrowserView` (no solo en el estado vacío de búsqueda)
- **Nombre duplicado:** se avisa con un alert de confirmación (no se bloquea, pero tampoco se ignora silenciosamente como en el patrón de `Exercise`). Se detecta comparando en memoria contra `FoodBrowserViewModel.allItems` (ya cargado al abrir la vista) — no hace falta query nueva al repositorio, `search()` no sirve porque usa `localizedStandardContains`, no match exacto
- **Patrón a replicar NO es el de `Exercise`:** `Exercise` no tiene catálogo navegable ni relación compartida — cada `PlannedExercise` crea su propio `Exercise` 1:1 privado. `FoodItem` ya es un catálogo compartido con relación muchos-a-uno vía `MealOptionItem`, así que el patrón correcto es extender el repositorio/interactor/viewmodel ya existentes de `FoodBrowser`, usando `AddPlannedExerciseView` solo como referencia de *formulario* (layout, no arquitectura)
- **Categoría:** ~~`TextField` libre (no picker)~~ — implementado como `Picker` con las categorías ya existentes en `allItems` + una opción "Custom category" que revela un `TextField` para escribir una categoría nueva. Se decidió así en la implementación para evitar que el usuario cree categorías duplicadas por variación de mayúsculas/typos al escribir libremente; el catálogo semilla sigue usando strings libres por debajo, pero el formulario ahora guía hacia las categorías existentes
- **Edición/borrado de custom:** `.swipeActions` nativo en `FoodBrowserRow`, visible solo cuando `isCustom == true` — botón "Editar" (abre el mismo sheet en modo edición) y "Eliminar" (destructive, dispara el check de uso antes de confirmar)

## Gaps técnicos encontrados al analizar el código (no estaban en el spec original)
- **Editar no requiere repo nuevo:** `FoodItemRepositoryProtocol.save(_:)` hace `modelContext.insert(item)` + `save()`; insertar un objeto ya trackeado por el contexto (como uno salido de `fetchAll()`) es un no-op seguro en SwiftData. Editar = mutar los campos del `FoodItem` existente + `save()`
- **Bloqueo de borrado SÍ requiere repo nuevo:** `MealOptionItem.foodItem: FoodItem?` (`MealOptionItem.swift:17`) no tiene `@Relationship` explícito → SwiftData usa `deleteRule` default `.nullify`. Sin intervención, borrar un `FoodItem` en uso desengancharía la referencia en silencio en vez de bloquear. Hace falta `FoodItemRepositoryProtocol.usageCount(for:) async throws -> Int` (fetch de `MealOptionItem` filtrando por `foodItem.id`) y un caso nuevo en `NutritionError` con valor asociado (`case inUse(count: Int)`, los 3 casos actuales no llevan payload)

## Casos edge
- [x] Nombre duplicado con un alimento del catálogo semilla o con otro custom → se avisa con alert de confirmación, no se bloquea
- [ ] El reseed del catálogo (`AppContainer.swift`) debe seguir sin tocar los `isCustom == true` — el mecanismo actual (gateado por `UserDefaults` flag `foodCatalogV1`, corre una sola vez y ya filtra `!isCustom`) ya lo garantiza estructuralmente; falta test que lo verifique explícitamente
- [x] `basePortionG` con valor 0 o negativo — mínimo de validación en el formulario: `1g` (default prellenado sigue siendo `100`, consistente con el default de `FoodItem.init`, pero eso es un valor por defecto, no un mínimo — el mínimo real es 1)

## Criterios de aceptación
- [ ] Nuevo flujo de creación en `FoodBrowserView` vía sheet, extendiendo `FoodBrowserInteractor`/`FoodBrowserViewModel` existentes (no un Interactor nuevo desde cero)
- [ ] `FoodItem` creado con `isCustom: true` sobrevive a `AppContainer`'s reseed del catálogo (test explícito)
- [ ] Edición y borrado de alimentos custom soportados (no solo creación); borrado bloqueado si el alimento está en uso en algún `MealOptionItem`
- [ ] Badge visual "Personalizado" en `FoodBrowserRow` para alimentos con `isCustom == true`

## Lo que NO hace
- No usa ninguna API externa para autocompletar macros — sigue siendo 100% offline, entrada manual (la variante con IA on-device está en `ai-custom-food-description.md`, es un spec separado y opcional)
- No permite editar el catálogo semilla (`isCustom == false`) — esos alimentos son de solo lectura
- No sincroniza alimentos custom entre usuarios — son locales al usuario vía CloudKit privado, como el resto de los datos

## Capas afectadas
- [ ] Domain (`FoodItem` sin cambios de esquema, solo se empieza a usar `isCustom: true`)
- [ ] Data (repositorio de `FoodItem` si no existe ya create/update/delete)
- [ ] Features (`Features/Nutrition/FoodBrowser/` — nuevo Interactor/ViewModel/View de creación, siguiendo el patrón de `WorkoutDayDetailViewModel` para `Exercise` custom)
- [ ] Shared (DesignSystem)
- [ ] Resources (Localizable.xcstrings)

## Preguntas abiertas
Ninguna — resueltas en la sección "Decisiones" arriba.
