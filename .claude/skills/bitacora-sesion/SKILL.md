---
name: bitacora-sesion
description: Registra el trabajo de una sesión del Taller 3 — escribe la bitácora en 06_Bitacoras/ con el formato exigido por CLAUDE.md, verifica las notas de hallazgos de 05_Notas/ y actualiza HANDOFF.md (estado actual, dos a tres siguientes objetivos y registro de sesiones). No hace commit ni push ni copia la conversación: eso lo hace después la skill cerrar-sesion. Usar cuando el usuario pida "registrar la sesión", "escribir la bitácora" o "actualizar el handoff".
---

# Bitácora de la sesión

Al terminar una sesión de trabajo en este taller, hace dos cosas en este orden:

1. Escribir la bitácora de la sesión en `06_Bitacoras/`.
2. Actualizar `HANDOFF.md` (raíz del repo) a partir de esa bitácora.

El commit, el push y la copia del `.jsonl` de la conversación **no** son de esta
skill: los hace `cerrar-sesion` después (ver "Cierre").

Básate solo en lo que ocurrió en la conversación. Confirma los archivos
afectados con `git status` / `git diff --stat` (y `git log` si hubo commits).
Si algo no es inferible con certeza (un supuesto, un resultado ambiguo, quién
del equipo trabajó en la sesión, cuáles deben ser los siguientes objetivos),
pregunta al usuario en vez de adivinar. Si el usuario pide solo una de las
partes, haz solo esa.

## Paso 1: bitácora

Antes de escribir, lee `HANDOFF.md` y **solo la última bitácora** de
`06_Bitacoras/` (la más reciente por nombre) para entender qué se hizo, qué
quedó pendiente y mantener el formato. Lee otras bitácoras únicamente si
necesitas más contexto (p. ej. una decisión o un resultado que la sesión retoma
y que el handoff no explica); en ese caso abre solo las pertinentes, no todas.

Nombre del archivo: `YYYY-MM-DD_slug-descriptivo.md` (minúsculas, guiones), con
la fecha real de la sesión. Si ya hay una bitácora del mismo día, agrega un
sufijo numérico (`_2`) o pregunta.

Estructura (la que exige `CLAUDE.md`):

```markdown
# Bitácora — YYYY-MM-DD: <descripción corta>

## Resumen
Objetivo de la sesión y desarrollo, en pocos párrafos. Indica cuáles de los
"Siguientes objetivos" que traía HANDOFF.md se cumplieron, cuáles avanzaron y
cuáles no se trabajaron.

## Archivos
- Creados: ...
- Modificados: ...
- Eliminados: ...

## Detalle por archivo
### `ruta/relativa/archivo`
Qué cambió, decisiones de implementación, supuestos usados y la intuición
en lenguaje natural de cada decisión.

## Resultados nuevos (tablas, figuras, gráficos)
Por cada uno: qué busca comunicar, cómo se generan los datos que lo alimentan
y qué rol cumple dentro del taller. Omitir la sección si no hubo.

## Pendientes
Lo que quedó sin hacer, supuestos sin confirmar y el siguiente paso. Esta
sección alimenta los "Siguientes objetivos" de HANDOFF.md.
```

Reglas de contenido (de `CLAUDE.md`):

- Reporta cuántas observaciones se pierden en cualquier limpieza o filtro
  mencionado.
- No juicios de "bueno" o "malo" sobre resultados, ni entusiasmo por
  coeficientes, métricas o significancia.
- Distingue siempre objeto de interés, medida o estimador y estimación; y
  declara la fuente (comunicados, minutas o serie macro), el periodo y la
  unidad de cada número.
- Una relación entre una medida de texto y una variable macro es asociativa,
  no causal, salvo que un diseño explícito lo sostenga.
- Si una medida de texto depende de decisiones de preprocesamiento (stopwords,
  diccionario, número de tópicos, semilla), dilo y registra la elección.
- Para las medidas que se construyen a partir del texto o de las series,
  explica cada una por aparte: fuente (recurso de `07_Recursos/`, paper o
  documentación), cómo se calcula y qué rol cumple en el análisis.
- Si se tomó una decisión metodológica relevante, regístrala también en la
  tabla "Decisiones tomadas" de `CLAUDE.md` (o en "Análisis descartados" si se
  descartó algo); el estado de avance se actualiza en `HANDOFF.md` (Paso 2).
- Sin código en la bitácora salvo que aporte a entender una decisión.

### Verificación de notas de hallazgos

Antes de dar por escrita la bitácora, revisa que cada tabla o figura nueva o
modificada en la sesión (`git status` sobre `03_Resultados/`) tenga su nota en
`05_Notas/` actualizada y que `05_Notas/README.md` la liste.

- Si falta alguna, invoca la skill `registrar-hallazgo` para crearla o
  actualizarla (incluye el contraste con las notas previas).
- Si hay contradicciones pendientes de conciliar, menciónalas en "Pendientes" de
  la bitácora y como bloqueo en `HANDOFF.md`.
- En "Resultados nuevos" de la bitácora, enlaza a la nota correspondiente en
  lugar de repetir su explicación.
- Si la sesión no generó ni cambió resultados, omite esta verificación.

## Paso 2: actualizar `HANDOFF.md`

Sigue la sección "`HANDOFF.md`" de `CLAUDE.md`. Actualiza las tres secciones:

- **Siguientes objetivos:** reescríbela con **dos a tres** tareas concretas,
  en orden de prioridad. Cada una lleva el archivo que debe producirse, un
  criterio de terminado verificable y, si aplica, el integrante a cargo.
  - **Si existe el plan de implementación** (su ruta está en la sección
    "`HANDOFF.md`" de `CLAUDE.md`): toma los próximos pasos no terminados del
    plan, en su orden, y cita el número de paso en cada objetivo. Si la sesión
    cerró pasos del plan, márcalos como terminados en el plan también.
  - **Si no existe:** derívalos de "Pendientes" de la bitácora. Si hay
    varias opciones razonables, pregunta al usuario cuáles siguen.
  - Un objetivo que no se terminó se mantiene.
  - Actualiza la lista de bloqueos y preguntas abiertas debajo de los
    objetivos: quita los resueltos y agrega los nuevos.
- **Estado actual:** reescríbelo para reflejar qué existe y funciona hoy
  (datos, scripts, resultados). No es un historial.
- **Registro de sesiones:** agrega una entrada arriba (la más reciente
  primero), con este formato:

  ```markdown
  ### YYYY-MM-DD: <descripción corta>

  - <Integrante> (`<rama>`). Qué se hizo, en tres a cinco líneas; si hay plan,
    qué pasos avanzó o cerró. Si un objetivo no se terminó, qué avanzó y qué
    lo impidió.
  - Bitácora: [<archivo>.md](06_Bitacoras/<archivo>.md)
  - **Siguientes objetivos:** (1) ...; (2) ...; (3) ... (los mismos dos a tres
    de la sección de arriba, en una línea cada uno).
  ```

  No edites las entradas anteriores.

## Cierre

Termina con un reporte corto: ruta de la bitácora, notas de `05_Notas/` creadas
o actualizadas, y los dos a tres siguientes objetivos que quedaron en
`HANDOFF.md`. Después, **indica al usuario que el siguiente paso es la skill
`cerrar-sesion`** (commit y push a su rama, y copia del `.jsonl`) y pregunta si
quiere correrla ahora. No hagas commit ni push desde aquí.
