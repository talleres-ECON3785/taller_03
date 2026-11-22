# Bitácora — 2026-11-21 (5): embeddings de palabras antes y después del corte (H3c)

Sesión de Santiago Muñoz Martínez, rama `SantiagoMunozM`.

## Resumen

Objetivo: el hito H3c de `PLAN.md`, embeddings de palabras para medir si la
Junta usa las mismas palabras en otro contexto antes y después del corte del
2014-10-30.

Del handoff anterior se cumplió el objetivo 2 (H3c). El objetivo 1 (H4,
interpretación y deck) no se trabajó, salvo la discusión de cómo entra el
resultado al deck. El objetivo 3 (PR de `SantiagoMunozM` a `main`) no se
trabajó.

Desarrollo:

1. **Qué podían agregar los embeddings.** Con `04_Presentaciones/hallazgos_y_figuras.txt`
   como base se concluyó que su aporte propio no es qué temas entran o salen
   (ya lo dicen `08` y `09`), sino si cambia el **contexto de uso** de una
   misma palabra. Eso pone a prueba el hallazgo 4: «la inflación no recibió más
   espacio, recibió otra discusión».
2. **Lab 13 al catálogo.** Se revisó `Laboratorios/Laboratorio 13/Laboratorio_13/02_Scripts/`
   (Word2Vec, GloVe, vecinos y analogías, vectores preentrenados, PCA en 3D,
   `kmeans()` y embeddings de documento). Como el laboratorio se vio en clase,
   los embeddings pasaron al catálogo (secciones 10 a 14 de
   `07_Recursos/catalogo_metodos.md`) y dejaron de ser ampliación.
3. **Plan (modo plan, `ponytail`).** Diseño mínimo: un solo modelo con
   comunicados y discusión de la Junta, la oración de udpipe como documento,
   las anclas marcadas por época y una tabla como salida. La especificación se
   registró en «Decisiones tomadas» antes de correr el modelo.
4. **Word2Vec no se reproduce.** El primer script usaba `word2vec::word2vec()`.
   Dos corridas con la misma semilla dieron vecinos distintos: el código en C++
   no usa la semilla de R. Se midió con cinco corridas, cada una promediando
   tres entrenamientos. De los 10 vecinos de cada ancla y época, entre 5 y 8 se
   repetían en las cinco corridas, y aparecían 12 a 18 palabras distintas. El
   coseno antes–después varió hasta 0,06. Se probó que GloVe (`text2vec`, del
   mismo laboratorio) con `n_threads = 1` da exactamente el mismo resultado en
   cada corrida. Por decisión del usuario, el script pasó a ser `10_glove.R`.
5. **Dos errores corregidos al correr el script:** el ancla sin marca (la misma
   palabra fuera de la ventana) salía como vecino de sí misma; y
   `guardar_tabla()` sobrescribía el `.csv` largo que tenía el mismo nombre.
6. **Formato de la tabla** (pedido del usuario): un encabezado común «10
   vecinos más cercanos» con «Antes» y «Después» debajo; otro para las columnas
   de coincidencia con `09`, con un nombre más informativo que «en phi»; y
   proporción cercana a 16:9 (1,74:1).
7. **Robustez con Word2Vec.** El usuario pidió probar Word2Vec, que suele
   funcionar mejor con corpus pequeños. Coincide con GloVe en lo central y
   difiere en dos lecturas de la nota (ver «Resultados nuevos»). Por decisión
   del usuario se agregó a `10_glove.R` como robustez (cinco entrenamientos
   promediados, declarando que varían) y la nota pasó a «matizado».
8. **Lectura para el deck.** Se acordó que los embeddings no llevan una
   diapositiva propia: una línea de confirmación en la diapositiva 7
   (inflación) y la tabla en el apéndice.

## Archivos

- Creados:
  - `02_Scripts/10_glove.R`
  - `03_Resultados/Tablas/10_glove/conjunto_glove_vecinos.png` y `.csv`
  - `03_Resultados/Tablas/10_glove/conjunto_glove_vecinos_detalle.csv`
  - `03_Resultados/Tablas/10_glove/conjunto_glove_fragmentos.csv`
  - `03_Resultados/Tablas/10_glove/conjunto_w2v_vecinos_detalle.csv`
  - `05_Notas/10_glove/T_contexto_inflacion_expectativas.md`
  - `06_Bitacoras/2026-11-21_embeddings-glove.md`
- Modificados:
  - `00_main.R`, `07_Recursos/catalogo_metodos.md`, `CLAUDE.md`, `PLAN.md`,
    `README.md`, `HANDOFF.md`
  - `05_Notas/README.md`,
    `05_Notas/09_antes_despues/T_devaluacion_tema_de_inflacion.md`,
    `05_Notas/08_lda_oraciones/T_inflacion_de_meta_a_choques.md`
  - Regenerados por la corrida completa de `00_main.R`, sin cambios de código:
    17 `.csv` de `05_lda_exploratorio`, `07_graficas_macro` y
    `09_antes_despues`. En `07` y `09` solo cambian decimales a partir de la
    posición 15; en `05` cambian los tópicos de los modelos VEM exploratorios
    (sin nota). `08` no cambió.
- Eliminados: ninguno versionado. El borrador `02_Scripts/10_word2vec.R` y su
  carpeta de salidas, que creó esta sesión y nunca se commitearon, se
  reemplazaron por `10_glove.R`.

## Detalle por archivo

### `07_Recursos/catalogo_metodos.md`

Se agregó el Lab 13: seis filas en el resumen y las secciones 10 a 14.

- **10, datos:** el orden de las palabras importa, y el lab saca «estado» de
  las palabras vacías porque es contenido.
- **11, Word2Vec:** skip-gram con `dim = 50`, `window = 5`, `iter = 20`,
  `negative = 5`, `min_count = 5`. `word2vec()` no tiene argumento de semilla.
- **12, GloVe:** matriz de co-ocurrencias con `create_tcm()`,
  `GlobalVectors$new(rank = 50, x_max = 10)` y la suma de los vectores
  principales y de contexto.
- **13, vecinos y analogías:** las funciones `vecinos()` y `analogia()` con
  `sim2()`, y el recorte de fastText al vocabulario CEPAL.
- **14, espacio y temas:** PCA y `plotly` en 3D; `kmeans()` sobre vectores
  normalizados; el embedding de un documento como promedio de los vectores de
  sus palabras.

«Herramientas previstas» marca los embeddings como cubiertos. Siguen «fuera
del catálogo» la alineación de modelos estimados por separado (Procrustes) y
los vectores preentrenados completos. Intuición: lo que se vio en clase es
herramienta del curso; lo que el lab no hizo sigue necesitando registro.

### `02_Scripts/10_glove.R`

- **Texto.** Palabras limpias de `tokens_anotados.rds`, comunicados y
  discusión de la Junta, 2007–2026: 97.250 tokens en 8.913 oraciones. La
  oración de udpipe es el documento, la misma unidad que `pairwise_cor()` en
  `09`, así que la ventana de 5 palabras no cruza oraciones.
- **Anclas marcadas por época.** En la ventana principal (2009-10-30 a
  2019-10-29, `asignar_epoca()`) cada ancla se reemplaza por `ancla_antes` o
  `ancla_despues`; fuera de la ventana queda sin marca. Intuición: el modelo
  aprende dos vectores de la misma palabra en un solo espacio, y no hace falta
  alinear dos modelos (fuera del catálogo).
- **Anclas.** Las de `09` con 30 o más oraciones en cada época, sumando las dos
  fuentes, según `conjunto_anclas_oraciones.csv` de `09`: inflación (479 /
  474), expectativas de inflación (166 / 154), crecimiento (658 / 246) y tasa
  de intervención (256 / 230). Quedan fuera déficit (2 / 115), tasa de cambio
  (25 / 36), petróleo (38 / 24) y precio del petróleo (14 / 71). Intuición:
  con pocas oraciones el vector es ruido; esas palabras casi no existían antes
  del corte, y eso ya lo muestran los hallazgos 2 y 5.
- **GloVe.** Especificación del Lab 13: ventana 5, frecuencia mínima 5,
  `rank = 50`, `x_max = 10`, 50 iteraciones, `n_threads = 1`. Semillas 2026,
  2027 y 2028: el coseno se promedia. Los vecinos excluyen el ancla sin marca.
- **Robustez con Word2Vec (sección 2b).** Mismo texto y anclas, skip-gram con
  la especificación del lab y `split = c(" \n", "\n")`, porque el `split` por
  defecto parte los tokens en `_` y `-`. Cinco entrenamientos promediados. Va
  marcado con un comentario `shortcut:` porque no se reproduce exactamente.
- **Fragmentos.** Para cada ancla y época, la oración más corta (12 a 70 tokens)
  que contiene el ancla y su vecino principal. Se prefiere una cuyo texto
  original no quede cortado, porque en las minutas la oración original puede
  ser una enumeración entera. En «expectativas de inflación + anclar» antes del
  corte solo hay enumeraciones, y ese fragmento no se cita.
- **Chequeos (`stopifnot()`):** cada ancla marcada tiene vector, cada una
  tiene 30 o más oraciones, hay 10 vecinos por ancla y época, y los cosenos
  están entre −1 y 1.
- Se corrió dos veces: la parte de GloVe da archivos idénticos.

### `00_main.R`

Agrega `text2vec` (GloVe) y `word2vec` (robustez) al `p_load()`,
`03_Resultados/Tablas/10_glove` a `carpetas_salida` y `10_glove.R` a
`scripts`. La corrida completa se hizo antes de agregar la robustez con
Word2Vec: 10 scripts, sin errores, 4,8 minutos. Después de ese cambio solo se
corrió `10_glove.R` (unos 30 segundos).

### `CLAUDE.md`

- Contexto: los embeddings «se vieron en el Laboratorio 13 y están en el
  catálogo».
- Regla metodológica: el catálogo incluye los Labs 11, 12 y 13.
- «Decisiones tomadas», dos filas:
  - el Lab 13 al catálogo;
  - el diseño de H3c, con la razón para usar GloVe y no Word2Vec, la lista de
    anclas con sus conteos y la robustez con Word2Vec que matiza la nota.

### `PLAN.md`

H3c reescrito con el diseño simplificado: GloVe, sin Jaccard, porque el coseno
antes–después lo reemplaza. P3c.1 a P3c.8 quedan marcados.

### `README.md`

Sección de `10_glove.R` en el mapa script → resultados, con sus cuatro
archivos.

### Notas de `05_Notas/`

- Nueva: `10_glove/T_contexto_inflacion_expectativas.md`, en estado
  «matizado».
- Historial agregado en `09_antes_despues/T_devaluacion_tema_de_inflacion.md`
  y en `08_lda_oraciones/T_inflacion_de_meta_a_choques.md`; el contraste es
  consistente con las dos.
- Índice actualizado.

## Medidas nuevas

### Vecinos por coseno de un ancla en cada época

- **Objeto de interés:** con qué otras palabras usa la Junta una misma palabra
  en cada época, es decir, su contexto de uso.
- **Medida:** las 10 palabras con mayor coseno respecto del vector
  `ancla_antes` (o `ancla_despues`) en un modelo GloVe. El coseno es el
  promedio de tres semillas. Se marcan con * las que no están entre las 10
  primeras de alguna semilla.
- **Fuente:** Lab 13 (`03_glove.R`, `04_vecinos.R`); Pennington, Socher y
  Manning (2014).
- **Rol:** sustenta el cambio de contexto con palabras concretas, que se pueden
  validar con fragmentos.

### Coseno antes–después

- **Objeto de interés:** cuánto cambió el contexto de una palabra entre las dos
  épocas.
- **Medida:** el coseno entre los vectores `ancla_antes` y `ancla_despues`
  (1 = mismo contexto), promediado entre semillas, con GloVe y con Word2Vec.
- **Rol:** ordena las anclas según cuánto cambia su uso. No tiene umbral: se
  lee en forma relativa.

### Coincidencia con `09`

- **Medida:** cuántos de los 10 vecinos están entre las 8 palabras con mayor
  correlación phi con el ancla en la misma oración (`09`, comunicados o
  minutas).
- **Rol:** contraste entre una medida de segundo orden (contextos parecidos) y
  una de primer orden (aparición conjunta), heurística H2.

## Resultados nuevos (tablas, figuras, gráficos)

### `03_Resultados/Tablas/10_glove/conjunto_glove_vecinos.png`

Comunica en qué contextos se usan las cuatro anclas antes y después del corte.
Los datos salen de la sección 2 de `10_glove.R` (GloVe) y de la 2b
(Word2Vec). Rol: tercera medida, después de las palabras de `09` y el LDA de
`08`, del cambio en la discusión de la inflación. Va en el apéndice; en la
diapositiva 7 entra una línea de confirmación. Interpretación y límites en
[T_contexto_inflacion_expectativas.md](../05_Notas/10_glove/T_contexto_inflacion_expectativas.md).

Coseno antes–después (épocas 2009-10-30 a 2014-10-29 y 2014-10-30 a
2019-10-29; 54 y 53 comunicados, 59 y 53 minutas):

| Ancla | GloVe | Word2Vec (5 entrenamientos) |
| --- | --- | --- |
| inflación | 0,56 | 0,78 |
| expectativas de inflación | 0,31 | 0,61 |
| crecimiento | 0,59 | 0,72 |
| tasa de intervención | 0,71 | 0,69 |

Lo que coincide en los dos métodos:

- las expectativas son el ancla con el coseno más bajo;
- después del corte, «inflación» tiene como vecinos «meta» y «convergencia».

Lo que solo aparece con GloVe:

- las expectativas con «anclaje» y «desanclaje»; con Word2Vec van con «derivar»,
  «papel» e «implícita», es decir, las expectativas que se derivan de los TES;
- la tasa de intervención como el ancla que menos cambia.

De los 10 vecinos de cada ancla y época, solo 1 a 4 se repiten entre los dos
métodos.

### `03_Resultados/Tablas/10_glove/*.csv`

Las cifras de la tabla, el detalle de los vecinos de GloVe y de Word2Vec y los
fragmentos (ver el README).

## Pendientes

- **Robustez de H3d para `10`:** no se corrieron los cortes alternativos ni se
  separaron las fuentes (comunicados como control). En su lugar, la robustez
  de `10` es entre métodos. Decidir si P3d.1 y P3d.2 se dan por cerrados con
  `08` y `09` y se declara el alcance de `10`.
- **`00_main.R` completo** después de agregar la robustez con Word2Vec: solo se
  corrió `10_glove.R`.
- **`.csv` regenerados de `05`, `07` y `09`:** decidir si se commitean o se
  descartan con `git checkout`. Los de `07` y `09` son ruido de punto flotante;
  los de `05` cambian los tópicos VEM exploratorios.
- **Lemas sin tildes** en la tabla («inflacion», «expectativas inflacion»),
  como en las tablas de `09`.
- **`x_max = 10` de GloVe** viene del Lab 13 y no está calibrado para un corpus
  de 97 mil palabras. No se ajustó, para no elegir la especificación después
  de ver los resultados.
- **Deck (H4):** una línea en la diapositiva 7 y la tabla como apéndice A9;
  falta actualizar la sección 5 de `04_Presentaciones/hallazgos_y_figuras.txt`.
