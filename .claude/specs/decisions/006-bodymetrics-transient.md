# ADR 006: bodyFatPercent y bmi como propiedades computadas (no persistidas)

Fecha: 2026-03-28
Estado: Aceptada

## Contexto

`BodyMeasurement` necesita mostrar `bodyFatPercent` (% grasa corporal) y `bmi` (índice de masa corporal). Estas métricas se pueden calcular a partir de los perímetros raw que sí se persisten (`neckCm`, `abdomenCm`) y de `heightCm`, que se guarda como snapshot directamente en cada `BodyMeasurement` (no se lee de `UserProfile` en el momento del cálculo) — usando la fórmula de la Marina de EE.UU.

La alternativa era persistirlas como campos normales en SwiftData.

## Decisión

Propiedades computadas normales en `BodyMeasurement` (`Forma/Domain/Models/BodyMeasurement.swift`) — sin el atributo `@Transient` de SwiftData. No hace falta marcarlas explícitamente: al no tener storage propio, SwiftData ya las excluye de la persistencia igual que cualquier `var` computada de una clase Swift.

```swift
var bodyFatPercent: Double? { ... }  // usa neckCm, abdomenCm, heightCm
var bmi: Double? { ... }             // usa weightKg, heightCm
```

**Fórmula % grasa (hombres, Marina EE.UU.)** — verificada carácter a carácter contra el código:
`86.010 × log10(abdomen − neck) − 70.041 × log10(heightCm) + 36.76`

**Fórmula IMC:**
`weightKg / (heightCm / 100)²`

`BodyMetricsService` no calcula estos dos valores — solo clasifica un valor ya calculado en categorías (`bmiCategory(for:)`, `bodyFatCategory(for:sex:)`).

## Consecuencias

- ✅ Si se mejora la fórmula, todos los datos históricos se recalculan automáticamente y de forma consistente
- ✅ No hay posibilidad de desincronización entre el valor calculado y los perímetros raw
- ✅ Menor tamaño del store — no duplicamos datos derivados
- ⚠️ El cálculo ocurre en cada acceso — en listas largas considerar caché en ViewModel
- ⚠️ `heightCm` se guarda como snapshot en cada `BodyMeasurement` (no se referencia desde `UserProfile`) — si el usuario corrige su altura en el perfil, las mediciones antiguas conservan la altura que tenían en el momento de crearse, intencionadamente
- ❌ `bodyFatPercent` y `bmi` nunca se escriben directamente — son read-only computadas

## Cuándo revisitar

Si el cálculo fuera muy costoso en tiempo real con miles de mediciones. En ese caso, persistir como campo y recalcular solo al modificar los perímetros.
