# ADR 006: bodyFatPercent y bmi como propiedades @Transient

Fecha: 2026-03-28
Estado: Aceptada

## Contexto

`BodyMeasurement` necesita mostrar `bodyFatPercent` (% grasa corporal) y `bmi` (índice de masa corporal). Estas métricas se pueden calcular a partir de los perímetros raw que sí se persisten (`neckCm`, `abdomenCm`, `waistCm`, `heightCm` del perfil) y la fórmula de la Marina de EE.UU.

La alternativa era persistirlas como campos normales en SwiftData.

## Decisión

`@Transient` en SwiftData — se calculan en tiempo de lectura, nunca se almacenan.

**Fórmula % grasa (hombres, Marina EE.UU.):**
`86.010 × log10(abdomen − neck) − 70.041 × log10(height) + 36.76`

**Fórmula IMC:**
`weight / (height_m)²`

## Consecuencias

- ✅ Si se mejora la fórmula, todos los datos históricos se recalculan automáticamente y de forma consistente
- ✅ No hay posibilidad de desincronización entre el valor almacenado y los perímetros raw
- ✅ Menor tamaño del store — no duplicamos datos derivados
- ⚠️ El cálculo ocurre en cada acceso — en listas largas considerar caché en ViewModel
- ❌ `bodyFatPercent` y `bmi` nunca se escriben directamente — son read-only computadas

## Cuándo revisitar

Si el cálculo fuera muy costoso en tiempo real con miles de mediciones. En ese caso, persistir como campo y recalcular solo al modificar los perímetros.
