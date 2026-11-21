# Bitácora — 2026-11-21 (3): qué cambió antes y después del corte (palabras, bigramas, atención por tema y correlaciones)

Sesión de Samuel Escandón, rama `SamuelEscandonC` (trabajada en un worktree
del agente al día con `SamuelEscandonC` y con `main`; se empuja a
`SamuelEscandonC`).

## Resumen

Objetivo: escribir `02_Scripts/09_antes_despues.R`, el hito H3b de
`PLAN.md`: palabras distintivas, bigramas, atención por tema y correlaciones
entre palabras antes y después del corte del 2014-10-30, en minutas (solo la
discusión de la Junta) y comunicados, con robustez y fragmentos de los
documentos. En paralelo, otros integrantes hacen el LDA (08) y los embeddings
(10).

Desarrollo:

1. **Plan.** El `PLAN.md` de la rama numeraba `08_antes_despues.R` (H3a) y
   `09_lda_oraciones.R` (H3b). Con la asignación del día (LDA = 08,
   embeddings = 10, este trabajo = 09), el bloque H3a se reemplazó por el
   hito «H3b — Qué cambió antes y después» con `09_antes_despues.R` y tareas
   P3b.1–P3b.8. No se tocaron las tareas del LDA ni de Word2Vec. **Choque de
   numeración pendiente:** el bloque del LDA sigue llamándose «H3b —
   `09_lda_oraciones.R`» con tareas P3b.1–P3b.10.
2. **Código.** La construcción de bigramas se movió de `04_bigramas.R` a
   `construir_bigramas()` en `00_funciones_texto.R` (mismo código; `04` la
   llama). Se agregó `widyr` al `p_load()` y el script y su carpeta a
   `00_main.R`. Solo se corrieron las secciones 1 a 3 de `00_main.R` y el 09
   (unos 70 segundos); `04` no se corrió.
3. **Revisión visual.** Se abrieron las figuras y las tablas principales. Dos
   correcciones salieron de esa revisión: (i) el primer emparejamiento de
   fragmentos con el PDF usaba un prefijo y traía oraciones equivocadas; se
   exige que la oración entera esté contenida en la del PDF y se reconstruye
   «del/al», que udpipe separa; (ii) «petroleo» casi no aparece porque el
   diccionario de compuestos lo absorbe en `precio_petroleo`, que se agregó
   como ancla complementaria.
4. **Notas.** Cuatro notas en `05_Notas/09_antes_despues/` (ver «Resultados
   nuevos»). Contraste con las notas previas: consistente con
   `T_inflacion_sigue_episodios`, `T_votacion_minuta_vs_comunicado` y
   `M_cronologia_choque_petrolero`; sin contradicciones.

De los «Siguientes objetivos» de `HANDOFF.md`: el objetivo 1 (H3a y H3b en
paralelo) avanzó en su parte de palabras, temas y bigramas (ahora H3b, script
09); el LDA y Word2Vec no se trabajaron aquí (otros integrantes).

## Archivos

- Creados: `02_Scripts/09_antes_despues.R`; `03_Resultados/Figuras/09_antes_despues/` (4 figuras);
  `03_Resultados/Tablas/09_antes_despues/` (12 tablas `.png` con su `.csv` y 9 `.csv` de detalle);
  `05_Notas/09_antes_despues/` (4 notas); esta bitácora.
- Modificados: `00_main.R`, `02_Scripts/00_funciones_texto.R`, `02_Scripts/04_bigramas.R`,
  `PLAN.md`, `README.md`, `05_Notas/README.md`, `HANDOFF.md`, `CLAUDE.md`.
- Eliminados: ninguno.

## Detalle por archivo

### `02_Scripts/09_antes_despues.R`

**Diseño común.**
- Épocas: «antes» = reuniones del 2009-10-30 al 2014-10-29; «después» = del
  2014-10-30 al 2019-10-29 (5 años a cada lado; deja fuera la crisis de 2008
  y la pandemia). Quedan 54 y 53 comunicados (29.663 y 30.601 palabras) y 59
  y 53 minutas (43.788 y 23.104 palabras de la discusión de la Junta). Tabla
  `conjunto_documentos_por_epoca.png`.
- Robustez, solo en tablas de apoyo: muestra completa 2007–2026 con el mismo
  corte, y los cortes 2014-09-26 y 2014-12-19 con su propia ventana de 5 años.
- Minutas: solo la discusión de la Junta; comunicados en paralelo como
  control del cambio de formato de las minutas (2014-05-30).
- Todo por 1.000 palabras del texto (todas las palabras del documento, no solo
  las que sobreviven a la limpieza), igual que `03`.

**Medida 1: razón de frecuencias (palabras y bigramas).** Fuente: catálogo,
sección de frecuencias y TF-IDF (Lab 11) y la misma razón ya usada en `03`
(minutas frente a comunicados). Cálculo: (apariciones después + 0,5) / palabras
después dividido por (apariciones antes + 0,5) / palabras antes. El +0,5 evita
divisiones por cero cuando un término falta en una época. Mínimos: 20
apariciones sumando las dos épocas para palabras (como `03`) y 10 para
bigramas. El TF-IDF con las dos épocas como grupos se calcula como
complemento y queda en los `.csv` de detalle: con dos grupos el idf solo vale
0 o log(2), así que solo distingue los términos exclusivos de una época y no
ordena los compartidos. Rol: identificar qué vocabulario entra y sale de la
agenda.

**Lectura de robustez de cada término (regla fijada antes de ver los
resultados).** En minutas, si en los comunicados la razón va en la dirección
contraria, «posible artefacto de formato»; en comunicados, si las minutas van
en contra, «no se ve en las minutas»; si no, «robusta» cuando la dirección se
mantiene con la muestra completa y con los dos cortes alternativos, y
«matizada» si alguno la cambia. Resultado: de las 30 palabras de cada figura,
28 robustas y 2 posibles artefactos en minutas («señalar», «acordar»); 27
robustas y 3 «no se ven en las minutas» en comunicados. En bigramas, 9 de 20
de las minutas son posibles artefactos.

**Medida 2: bigramas.** `construir_bigramas()` (pares contiguos de la misma
oración, las dos palabras del vocabulario limpio, catálogo sección 4).

**Medida 3: atención por tema.** Diccionario `temas` de
`00_funciones_texto.R`, sin modificar (fijado a priori). Por reunión:
palabras del tema por 1.000 palabras. Media por época, diferencia después −
antes e IC 95 % de la prueba t de Welch con la reunión como unidad, por tipo de
documento y escenario. La lectura de robustez usa el signo de la diferencia
con la misma regla de arriba. Rol: medir prioridades de la Junta.

**Medida 4: correlación entre palabras.** `widyr::pairwise_cor()` (catálogo,
Lab 11), coeficiente phi de aparición conjunta en la misma oración, por tipo y
época; solo palabras en 10 o más oraciones de la época. **Unidad: oración de
udpipe** (la de `tokens_anotados.rds`, la misma de los bigramas) en lugar de
`partir_oraciones()`: así se usan los lemas y el vocabulario limpio ya
calculados sin volver a lematizar. Anclas: petroleo, precio_petroleo
(agregada), inflacion, tasa_cambio, tasa_intervencion, crecimiento,
expectativas_inflacion y deficit. Rol: versión dentro del catálogo del
análisis de contexto que harán los embeddings (10).

**Fragmentos.** Para cada término de una figura: del documento de la época en
que el término es más frecuente que más oraciones con él tiene, la primera
oración de 12 a 70 tokens que lo contiene. La oración se recupera del texto
del PDF (con mayúsculas y tildes) si está completa dentro de una oración de
`partir_oraciones()`; si no, se reconstruye desde los tokens (56 de 60
palabras y 39 de 40 bigramas salen del texto original). Temas: la oración con
más palabras del tema por época y tipo.

**Chequeos (`stopifnot`).** 40 o más reuniones por época y tipo; épocas dentro
de la ventana; todas las anclas presentes en las minutas en las dos épocas;
atención sin NA y una fila por documento y tema; cada término de las figuras
con fragmento.

### `02_Scripts/00_funciones_texto.R` y `02_Scripts/04_bigramas.R`

Nueva sección 8 con `construir_bigramas(anotados)`, copia exacta del bloque
que estaba en `04`. `04` ahora la llama. Las salidas de `04` deberían quedar
iguales, pero **no se verificó** (no se corrió `04`, por instrucción del
usuario): se verifica con la corrida completa de `00_main.R`.

### `00_main.R`

`widyr` en el `p_load()` (catálogo, Lab 11); carpetas
`03_Resultados/{Tablas,Figuras}/09_antes_despues` en `carpetas_salida`;
`09_antes_despues.R` en `scripts`.

### `PLAN.md`

Bloque H3a (`08_antes_despues.R`) reemplazado por el hito H3b de
`09_antes_despues.R` (P3b.1–P3b.8, marcadas como terminadas).

### `README.md`, `05_Notas/README.md`, `CLAUDE.md`

Mapa script → resultados de `09`; cuatro filas nuevas en el índice de notas;
una fila en «Decisiones tomadas» con el diseño de `09`.

## Resultados nuevos (tablas, figuras, gráficos)

Todos los genera `09_antes_despues.R` con las bases ya guardadas
(`corpus_texto.rds`, `tokens_limpios.rds`, `tokens_anotados.rds`,
`macro_por_reunion.rds`). Mapa completo en `README.md`.

- `Figuras/09_antes_despues/conjunto_palabras_distintivas.png` y
  `conjunto_bigramas_cambio.png`: qué vocabulario gana y pierde peso. Notas
  [T_cuenta_corriente_deficit_externo](../05_Notas/09_antes_despues/T_cuenta_corriente_deficit_externo.md)
  y [T_devaluacion_tema_de_inflacion](../05_Notas/09_antes_despues/T_devaluacion_tema_de_inflacion.md).
- `Figuras/09_antes_despues/conjunto_temas_antes_despues.png` y la tabla
  `conjunto_temas_antes_despues.png`: cambio de prioridades por tema. Nota
  [T_atencion_temas_antes_despues](../05_Notas/09_antes_despues/T_atencion_temas_antes_despues.md).
- `Figuras/09_antes_despues/conjunto_temas_macro_por_reunion.png` y
  `conjunto_cronologia_texto_macro.png`: atención al entorno externo y a la
  inflación frente a Brent, TRM e inflación por reunión (asociativo). Nota
  [X_atencion_se_adelanta_a_las_series](../05_Notas/09_antes_despues/X_atencion_se_adelanta_a_las_series.md).
- Tablas de correlaciones por ancla (`{comunicados,minutas}_correlaciones_anclas.png`):
  insumo de contraste para los embeddings; parte de su lectura está en la
  nota de devaluación e inflación.
- Tablas de robustez y de fragmentos: apoyo de las notas.

Cambio de redacción, sin nota propia: después del corte crecen «votar»,
«restante votar», «mayoría decidir» y «grupo mayoritario» (la minuta y el
comunicado empiezan a reportar la votación), y desaparece la frase de cierre
«La Junta seguirá haciendo un cuidadoso monitoreo… y reitera que…». Son
cambios en cómo se escribe, no en de qué se habla.

## Pendientes

- Correr `00_main.R` completo (lo hace el usuario antes del pull request a
  `main`) y verificar que las salidas de `04` no cambiaron con
  `construir_bigramas()`.
- Resolver el choque de numeración en `PLAN.md`: dos bloques «H3b» (este y el
  LDA de `09_lda_oraciones.R`, que en la práctica es `08`).
- Contrastar con el LDA (08) y los embeddings (10): un tópico o vecindario
  «externo / cuenta corriente» y «traslado / persistencia» que aparezca
  después del corte.
- Llevar las conclusiones al deck (H4).
