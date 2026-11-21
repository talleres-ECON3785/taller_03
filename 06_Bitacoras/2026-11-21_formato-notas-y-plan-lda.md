# Bitácora — 2026-11-21: formato de la nota al pie y nuevo hito H3 (LDA) en el plan

Sesión de Santiago Muñoz Martínez, rama `SantiagoMunozM`.

## Resumen

Objetivo: corregir el formato de la nota al pie de las figuras de
`07_graficas_macro.R`, aclarar la diferencia entre TF-IDF, Word2Vec y LDA, y
planear un hito nuevo para implementar LDA con tópicos legibles y buen balance
entre perplejidad y coherencia.

Desarrollo:

1. **Nota al pie.** Se partió cada oración en su propio renglón y se movieron
   las fuentes al último renglón. Las dos reglas se registraron en `CLAUDE.md`
   ("Formato de las gráficas").
2. **Aclaraciones metodológicas (sin archivos).** Se explicó que Word2Vec no es
   un modelo de tópicos, que LDA no usa embeddings y cómo se nombra un tópico
   (palabras de mayor beta y lift, documentos representativos).
3. **Plan.** Se constató que `PLAN.md` no contemplaba LDA. En modo plan se
   diseñó el hito y el usuario pidió que fuera **H3**, corriendo los demás: los
   embeddings pasan a H4 y la interpretación a H5. Corpus: minutas, solo la
   discusión de la Junta (199 minutas); documento: la minuta entera.

De los "Siguientes objetivos" que traía `HANDOFF.md` (H3 con `pairwise_cor()`,
embeddings, interpretación), ninguno se trabajó; solo se renumeraron. No se
escribió código de análisis.

## Archivos

- Creados: esta bitácora.
- Modificados: `02_Scripts/00_formato_graficas.R`, `02_Scripts/07_graficas_macro.R`,
  `02_Scripts/00_funciones_texto.R` (un comentario), `CLAUDE.md`, `PLAN.md`,
  `HANDOFF.md`, `03_Resultados/Figuras/07_graficas_macro/macro_series_2007_2026.png`
  y `macro_cronologia_choque.png`.
- Eliminados: ninguno.

## Detalle por archivo

### `02_Scripts/00_formato_graficas.R`
`guardar_figura()` partía la nota con `str_wrap`, que trata los `\n` como
espacios y junta todo en un párrafo. Ahora separa el texto en renglones por
`\n` y parte cada uno por aparte según el ancho de la figura. Una nota sin `\n`
sale igual que antes, así que las demás figuras no cambian.

### `02_Scripts/07_graficas_macro.R`
Los `caption` de las dos figuras se arman con `paste(..., sep = "\n")`, una
oración por elemento. En la figura de series, las fuentes pasaron al final;
la de cronología ya las tenía al final.

### `CLAUDE.md`
- Bullet de la nota al pie: las fuentes van siempre en el último renglón y
  una oración por renglón (decidido el 2026-11-21).
- Celda de "Decisiones tomadas" del 2026-11-19: «robustez de H3» → «robustez
  de H4» por la renumeración. Mismo cambio en un comentario de
  `00_funciones_texto.R`.

### `PLAN.md`
Hito nuevo **H3 — LDA** (P3.1 a P3.5):
- P3.1 regla de selección, registrada en "Decisiones tomadas" **antes** de ver
  tópicos: rejilla K ∈ {4, 6, 8, 10, 12, 16} × α ∈ {0,1; 0,5; 1}, δ = 1, Gibbs
  con 300 iteraciones, 3 pliegues, semilla 2026 (54 ajustes, no los 162 del
  laboratorio). Balance: para cada K el mejor α; se ordenan los K por
  perplejidad y por coherencia UMass y se elige la menor suma de rangos
  (empate: el K menor). Chequeo de artefacto de formato: un tópico con más de
  70 % de su peso en un formato de minuta se marca.
- P3.2 funciones `partir_mitades()`, `perplejidad()` y `coherencia()` (el código
  del laboratorio no está en el repo) y mover a `00_funciones_texto.R` los
  ayudantes de `05_lda_exploratorio.R`.
- P3.3 script `08_lda.R`; P3.4 atención por tópico antes y después del corte;
  P3.5 nota de hallazgo y README.
Renumeración: embeddings H3 → H4 (P4.x, script `10_embeddings.R`) e
interpretación H4 → H5 (P5.x).

La perplejidad por *document completion* es criterio de selección del modelo,
no un pronóstico de una serie; por eso sus pliegues son aleatorios por
documento y no chocan con la regla de evaluación temporal.

### `HANDOFF.md`
Solo se renumeraron referencias en "Siguientes objetivos" y "Estado actual";
la reescritura completa va en el Paso 2.

## Resultados nuevos (tablas, figuras, gráficos)

Sin resultados nuevos: las dos figuras de `07_graficas_macro` se regeneraron
solo para cambiar la nota al pie. Las series, los periodos y las cifras no
cambiaron, así que las notas de `05_Notas/` siguen vigentes. Las tablas y el
`.rds` que regenera el script difirieron únicamente por ruido de punto
flotante y de render de Chrome; se restauraron con `git checkout`.

## Pendientes

- **Implementar H3** (P3.1 a P3.3): registrar la regla en "Decisiones tomadas"
  y escribir `08_lda.R`. La regla de balance (suma de rangos) es propuesta de la
  sesión y el equipo debe aprobarla antes de correr.
- Las medidas de H4 (`pairwise_cor()` y embeddings) siguen sin implementar. El
  `PLAN.md` y el `HANDOFF.md` no coincidían en cuál es la principal: se
  numeraron `09_correlaciones_antes_despues.R` y `10_embeddings.R`.
- Tiempo: la entrega vence el 22 de noviembre.
