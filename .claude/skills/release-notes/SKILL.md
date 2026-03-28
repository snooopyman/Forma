---
name: release-notes
description: Genera release notes desde el último tag para App Store Connect
disable-model-invocation: true
---

## Commits desde el último release
- Último tag: !`git describe --tags --abbrev=0 2>/dev/null || echo "Sin tags — primer release"`
- Commits: !`git log $(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD)..HEAD --oneline`

Genera release notes para App Store Connect en español:

1. Agrupa en: Novedades / Mejoras / Correcciones
2. Lenguaje para usuarios finales — nada técnico, sin nombres de clases ni archivos
3. Máximo 4000 caracteres
4. Texto plano sin markdown
5. Enfoca en el beneficio para el usuario, no en la implementación

Contexto del producto: Forma es una app de fitness personal que centraliza entrenamiento por mesociclos, seguimiento corporal y plan nutricional. El usuario objetivo entrena con entrenador personal y sigue programas estructurados.
