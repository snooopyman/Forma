# Spec: Catálogo de alimentos localizado (EN/ES)

> Bloqueante para `ai-food-logging.md`: el matching determinista de esa spec necesita comparar texto libre (en inglés o español) contra el catálogo, y hoy el catálogo solo existe en español. Sin este arreglo, la feature de registro por lenguaje natural degradaría casi siempre a "crear alimento personalizado" para cualquier usuario que describa su comida en inglés.

## Resumen
`FoodItem.name` y `FoodItem.category` son hoy `String` planos en español, sin ninguna capa de localización (a diferencia de `MacroType`, que ya usa `L10n`/`Localizable.xcstrings`). Esta spec introduce claves de localización para los ~219 alimentos y ~14 categorías del catálogo semilla (`FoodCatalog.swift`), de forma que se muestren en el idioma de la app (EN/ES hoy, cualquier idioma futuro sin volver a tocar el modelo) y se puedan matchear en cualquiera de los idiomas soportados.

## Problema que resuelve
Verificado directamente en el código:
- `FoodCatalog.swift` (219 `FoodItem`) tiene nombres y categorías escritos en español natural (`"Pechuga de pollo"`, `"Lácteos y Huevos"`...), sin clave ni traducción.
- `FoodBrowserView.swift:187,201` y `FoodBrowserViewModel.swift:31,37,40` muestran y filtran directamente sobre esos strings en español — un usuario con la app en inglés ve el catálogo entero en español y su búsqueda en inglés no encuentra nada. `FoodBrowserViewModel.isDuplicateName` (líneas 63-67) también compara sobre `.name` literal.
- `MealDetailView.swift` tiene su propio picker embebido (`FoodPickerSheet`/`FoodPickerRow`/`FoodItemRow`, líneas 348, 404-408, 461, 489, 492) con búsqueda/orden **independiente** de `FoodBrowserViewModel` (su propio `searchText`/`filtered` en memoria) — mismo problema, call site separado que la spec original no nombraba explícitamente.
- `FoodItemRepository.swift:33` usa `#Predicate { $0.name.localizedStandardContains(query) }` — un `#Predicate` de SwiftData solo puede operar sobre propiedades **almacenadas**, nunca sobre una computed property, lo que condiciona cómo se puede resolver esto a nivel de búsqueda.
- Forma es bilingüe EN/ES desde el día 1 (`CLAUDE.md`), así que este no es un edge case raro sino una limitación estructural del catálogo actual.

## Diseño técnico
1. **`FoodItem`** (`Forma/Domain/Models/FoodItem.swift`) gana dos campos nuevos, opcionales:
   - `catalogKey: String?` — clave de localización del nombre; `nil` para alimentos `isCustom == true`
   - `categoryKey: String?` — clave de localización de la categoría; `nil` para categorías custom introducidas por el usuario (ver `custom-food-items.md`, opción "Custom category")
2. Computed properties `displayName` y `displayCategory`: si hay key, resuelven vía `String(localized:)` contra `Localizable.xcstrings`; si no (alimento/categoría custom), caen al `name`/`category` literal tal cual se guardó.
3. **`FoodCatalog.swift`**: cada una de las 219 entradas gana `catalogKey:`; cada una de las ~14 categorías gana su `categoryKey:` correspondiente (mismo valor de key para todas las entradas que comparten categoría).
4. **`Localizable.xcstrings`**: ~233 claves nuevas (219 alimentos + 14 categorías). El texto ES ya existe (es el `name`/`category` actual del catálogo) — el trabajo real es escribir las traducciones EN, que no dependen de ninguna API externa ni de `FoundationModels`.
5. **Búsqueda/filtro**: `FoodBrowserView`/`FoodBrowserViewModel` **y `MealDetailView`'s `FoodPickerSheet`/`FoodPickerRow`/`FoodItemRow`** (picker embebido usado al construir opciones de comida, con su propio `searchText`/`filtered` independiente de `FoodBrowserViewModel` — `MealDetailView.swift:348,404-408,461,489,492`) pasan a leer `displayName`/`displayCategory` en vez de `name`/`category`. `FoodItemRepository.search` deja de depender del `#Predicate` sobre `name` para el catálogo — el filtrado por substring se mueve a Swift en memoria (219 filas, sin problema de rendimiento), dejando la puerta abierta a que el futuro `FoodMatchingService` de `ai-food-logging.md` compare contra **todos** los locales soportados, no solo el del dispositivo. `FoodItemRepository.fetchAll()` también deja de ordenar vía `SortDescriptor(\.name)` (propiedad almacenada en español) — el orden alfabético pasa a resolverse en memoria sobre `displayName`, si no la lista quedaría ordenada por el nombre en español aunque se muestre en inglés.
6. **Reconciliación del catálogo (no hay reseed versionado hoy — corrección respecto al spec original)**: `AppContainer.reconcileFoodCatalog` (`AppContainer.swift:98-135`) **no usa ningún flag `foodCatalogV1`** — esa descripción no corresponde al código actual (verificado; no hay ningún `UserDefaults` flag de este tipo en el repo). El mecanismo real corre en **cada arranque** de la app y hace un diff por `name` (string en español) entre `FoodCatalog.catalog` y los `FoodItem` `!isCustom` existentes: borra los que ya no están en el catálogo (si no están en uso) e **inserta únicamente los que faltan por nombre** — nunca actualiza campos de un `FoodItem` ya persistido cuyo nombre matchea. Esto es crítico para esta spec: como `name` no cambia (solo se añade `catalogKey` al lado), en cualquier instalación que ya tenga el catálogo sembrado (todo usuario actual) el nombre "ya existe" → la reconciliación nunca vuelve a tocar esas filas → `catalogKey`/`categoryKey` se quedan en `nil` para siempre y la localización no se activa para nadie que ya tenga la app instalada. `reconcileFoodCatalog` debe modificarse para, además de insertar/borrar, **hacer backfill de `catalogKey`/`categoryKey` en los `FoodItem` ya existentes que matchean por `name`** con la entrada correspondiente de `FoodCatalog.catalog`. Los alimentos `isCustom == true` del usuario no se tocan (el filtro `!$0.isCustom` ya los excluye, esto sigue siendo correcto).

## Flujos alternativos
- Alimento o categoría `isCustom == true` → nunca tiene `catalogKey`/`categoryKey`; `displayName`/`displayCategory` devuelven siempre el literal introducido por el usuario, sin pasar por localización
- Idioma del dispositivo sin traducción disponible en `Localizable.xcstrings` (futuro, si se añaden más idiomas) → Xcode/String Catalogs ya resuelven esto con fallback automático al idioma de desarrollo (inglés), sin necesidad de lógica propia

## Casos edge
- [ ] `FoodItemEditorView` (edición/creación de alimentos custom) no cambia — nunca opera sobre `catalogKey`/`categoryKey`, solo sobre `name`/`category` literales
- [ ] Detección de nombre duplicado en `custom-food-items.md` (comparación en memoria contra `allItems`) debe comparar contra `displayName`, no contra `name`, para no dejar colar un duplicado visual entre un alimento custom en inglés y uno del catálogo cuya key resuelve al mismo texto
- [ ] El backfill en `reconcileFoodCatalog` no debe duplicar alimentos custom ni perder ediciones de usuario sobre alimentos custom existentes (el filtro `!isCustom` ya los excluye del backfill, igual que hoy los excluye del delete/insert)
- [ ] Alimentos con nombres de marca (`"Pechuga de pavo 92% Hacendado"`, `"Yogur +Proteínas Coco"`) no se traducen literalmente — se mantiene el nombre de marca y solo se traduce la parte genérica si aplica

## Criterios de aceptación
- [ ] `FoodItem.catalogKey`/`categoryKey` añadidos como campos opcionales, sin romper el esquema CloudKit existente (adición aditiva)
- [ ] `displayName`/`displayCategory` implementados y usados en todas las vistas que hoy leen `.name`/`.category` directamente: `FoodBrowserView`, `FoodBrowserViewModel` (incluye `isDuplicateName`), `FoodItemRepository.fetchAll()` (orden), y **`MealDetailView`'s `FoodPickerSheet`/`FoodPickerRow`/`FoodItemRow`** (call site independiente, ver "Diseño técnico" punto 5)
- [ ] Las 219 entradas de `FoodCatalog.swift` tienen `catalogKey`; las 14 categorías tienen `categoryKey`
- [ ] `NutritionLocalizable.xcstrings` (no el `Localizable.xcstrings` genérico — sigue la convención existente de `.xcstrings` por dominio, ver `L10n.swift`) tiene las ~233 claves con EN (fuente) + ES (traducción, reutilizando el texto actual del catálogo). Como `catalogKey`/`categoryKey` se resuelven con una key **dinámica** (`String(localized: String.LocalizationValue(key))`, no un literal en el call site), Xcode no las extrae automáticamente por escaneo de código — las ~233 entradas deben añadirse a mano en el `.xcstrings`
- [ ] `FoodItemRepository.search` ya no depende de un `#Predicate` sobre `name` para el catálogo — filtrado en memoria sobre `displayName`
- [ ] `reconcileFoodCatalog` (`AppContainer.swift`) hace backfill de `catalogKey`/`categoryKey` sobre `FoodItem` ya existentes que matchean por `name`, verificado con test explícito: instalación existente (con o sin alimentos custom) recibe las keys nuevas en sus filas ya sembradas, y los alimentos custom se conservan intactos
- [ ] Ningún alimento/categoría custom (`isCustom == true` / categoría libre) pasa por resolución de `String(localized:)` — siempre texto literal

## Lo que NO hace
- No añade un tercer idioma ahora — solo sienta la base para que añadir uno futuro sea un cambio de contenido en `Localizable.xcstrings`, no de esquema
- No cambia el modelo de datos de `MealOptionItem`, `DailyNutritionLog` ni ningún otro consumidor de `FoodItem` más allá de leer `displayName`/`displayCategory` en vez de `name`/`category`
- No resuelve el matching multi-idioma de `ai-food-logging.md` en sí (el `FoodMatchingService` es responsabilidad de esa spec) — solo lo hace posible al dejar de tener un catálogo monolingüe
- No toca `FoodItemEditorView` ni el flujo de creación/edición de alimentos custom de `custom-food-items.md`

## Capas afectadas
- [ ] Domain (`FoodItem.swift` — nuevos campos + computed properties)
- [ ] Data (`FoodCatalog.swift` — 219 `catalogKey` + 14 `categoryKey`; `FoodItemRepository.swift` — búsqueda en memoria en vez de `#Predicate` sobre `name`, orden en memoria sobre `displayName` en `fetchAll()`)
- [ ] App (`AppContainer.swift` — `reconcileFoodCatalog` gana backfill de `catalogKey`/`categoryKey` sobre filas existentes; no hay flag de versión que tocar, no existe)
- [ ] Features (`Features/Nutrition/FoodBrowser/` — `FoodBrowserView`, `FoodBrowserViewModel` leen `displayName`/`displayCategory`; `Features/Nutrition/MealDetail/MealDetailView.swift` — picker embebido, mismo tratamiento)
- [ ] Resources (`NutritionLocalizable.xcstrings` — ~233 claves nuevas EN/ES; entradas añadidas a mano, no auto-extraídas por Xcode al ser key dinámica)

## Preguntas abiertas
- [ ] ¿Quién redacta las ~233 traducciones EN? Propuesta: las escribo directamente (dominio acotado, nombres de alimentos) y se revisan en el PR antes de mergear, sin necesidad de `FoundationModels` ni de ningún proceso aparte
- [ ] ¿El slug de `catalogKey`/`categoryKey` sigue algún prefijo/convención concreta (`food_chicken_breast` vs. otra) o es indiferente mientras sea estable? Se asume libre mientras no colisione y no cambie una vez publicado (cambiarlo después del reseed rompería la key ya persistida en instalaciones existentes)
