# PLAN.md — Taller 3: temas de la Junta antes/después de la crisis del petróleo 2014

> Entrega: dom 22-nov-2026. Casillas `[x]` se marcan en la sesión que cierra la tarea.

## Contexto

Pregunta fijada 2026-11-18. Ya existe: texto extraído y limpio (`01`–`05`), series macro (`06`), gráficas macro, alineación por reunión y fecha de corte (`07`, H1 y H2). Medidas antes/después (H3): LDA (`08`, H3a), `09_antes_despues.R` (H3b) y embeddings (`10_glove.R`, H3c) hechos; faltan cerrar la robustez común (H3d) y la interpretación con la historia macro (H4).

## H1 — Gráficas macro + exploración descriptiva breve

- [x] **P1.1** Script `07_graficas_macro.R` (+ subcarpeta en `carpetas_salida` y `scripts` de `00_main.R`).
- [x] **P1.2** Figuras: Brent, TRM, inflación (total como serie principal y núcleo 15 como complemento, frente a la meta escalonada del año y su rango; 2026-11-19), 2007–2026, con sombreado de periodos de `00_formato_graficas.R`. Panel conjunto `macro_series_2007_2026.png`.
- [x] **P1.3** Descriptiva breve (tabla `macro_descriptiva.png`): por periodo P1–P10 → media, mín, máx, variación % de cada serie. Fechas de pico/valle Brent, salto TRM, pico inflación.
- [x] **P1.4** Regla de alineación: último dato publicado a la fecha de reunión. Escribir en `CLAUDE.md`.
- [x] **P1.5** Nota `05_Notas/07_graficas_macro/M_*.md` (skill `registrar-hallazgo`).

## H2 — Fecha de inicio de la crisis

- [x] **P2.1** Fijar corte con base en H1, ANTES de ver embeddings. Candidato: **2014-09-26** (abre P4, ya fijado a priori; primera reunión tras pico Brent jun-2014). Confirmar contra fechas de P1.3. **Fijado el 2026-11-19: 2014-10-30** (regla (i): primera reunión con el Brent 20 % o más por debajo de su máximo de 12 meses); alternativas 2014-09-26 y 2014-12-19 (`corte_crisis` y `cortes_alternativos` en `00_funciones_texto.R`).
- [x] **P2.2** Añadir línea vertical del corte a las figuras de H1.
- [x] **P2.3** Registrar en "Decisiones tomadas" (`CLAUDE.md`). Ojo: minutas cambian formato 2014-05-30 (A→B) ≈ corte → declarar.

## H3 — ¿Qué cambió antes y después del corte?

Medidas acordadas por el equipo el 2026-11-21. Corte: **2014-10-30** (`corte_crisis` en `00_funciones_texto.R`). Cada parte tiene su script, para trabajar en paralelo; las cuatro comparten la robustez de H3d.

Reglas comunes a H3a, H3b y H3c:

- **Ventana:** 5 años a cada lado → antes 2009-10-30 a 2014-10-29; después 2014-10-30 a 2019-10-29.
- **Documentos:** minutas (solo discusión de la Junta) y comunicados **por separado**. Las minutas tienen la mitad de palabras después del corte (unas 43.800 frente a 23.100): todo se normaliza por extensión y se contrasta con los comunicados.
- **Validación:** toda medida va con fragmentos del texto (fecha + tipo de documento). Sin ejemplo, no entra.

### H3a — `08_lda_oraciones.R`: LDA antes y después

Por qué no se repite el LDA de `05`: en la exploración, con la minuta entera como documento, los tópicos separaban épocas y formatos, no temas. Un LDA antes/después hecho así muestra «cambio» por construcción. Por eso la unidad baja a bloques de oraciones y se estima un solo modelo. Diseño acordado el 2026-11-21: la versión del equipo (bloques, un solo modelo, θ por reunión) con la rejilla de α, la prueba de semillas y la alerta de formato de la versión anterior de Santiago Muñoz Martínez (minuta entera, `08_lda.R`, que se descarta).

Qué va en cada archivo: `08` lleva todo lo del LDA (bloques, rejilla, `perplejidad()`, `coherencia()`, nombres y medida). No se toca `05`. A `00_funciones_texto.R` solo pasan `asignar_epoca()` y `escenarios` desde `09`, porque son definiciones del diseño antes/después, como `periodos` y `corte_crisis`, y las usan `08`, `09` y `10`.

- [x] **P3a.1** Mover `asignar_epoca()`, `anios_ventana` y `escenarios` de `09_antes_despues.R` a la sección 7 de `00_funciones_texto.R`, junto a `corte_crisis`. Criterio: los `.csv` de `09` salen iguales (`git diff` sin cambios).
- [x] **P3a.2** Bloques desde `tokens_anotados.rds`, que ya trae las oraciones de udpipe (`unidad`, `sentence_id`) y `upos`. No hace falta volver a partir el texto ni buscar párrafos. Se toman los comunicados y las secciones de discusión de la Junta de las minutas (`es_junta`). Las oraciones consecutivas de una misma unidad se van juntando y el bloque se cierra al llegar al umbral de palabras; lo que sobra al final de la unidad se une al bloque anterior. Cada bloque conserva su fecha, tipo y formato. **Umbral (sección 1 de `08`, análisis previo al modelo):** el más pequeño de {60, 80, 100} cuya mediana de palabras útiles por bloque (limpias, sin verbos y después del recorte) es de 20 o más. Resultado del 2026-11-21: **60 palabras**, con 1.619 bloques en la ventana (3.083 en 2007–2026), una mediana de 23 palabras útiles por bloque y una mediana de 9 bloques por reunión antes del corte y 6 después en las minutas (7 y 7 en los comunicados). Tabla: `conjunto_lda_umbral_bloques.png`.
- [x] **P3a.3** Vocabulario: `limpio` y `upos` distinto de `VERB`, porque los verbos de atribución separaban épocas en `05`. Entran las palabras que están en 5 bloques o más y en no más del 75 % de ellos, contados **en los bloques de la ventana**. Matriz con `cast_dtm()`: 1.619 bloques × 656 términos en la ventana; 1.464 bloques fuera, con las mismas columnas y ninguno vacío.
- [x] **P3a.4** Un solo modelo, **estimado con la ventana principal** (2009-10-30 a 2019-10-29), como las medidas de `09`, que se calculan dentro de la muestra de cada escenario. Fuera de la ventana, θ sale de `posterior(modelo, newdata = dtm_fuera)`. El cambio se mide en θ antes frente a después, no comparando dos modelos. (Antes decía «un solo modelo 2007–2026»; se cambió el 2026-11-21, ver «Decisiones tomadas».)
- [x] **P3a.5** Selección de K y α, con la regla de "Decisiones tomadas", que ya está escrita:
  - Gibbs con δ = 0,1, K ∈ {6, 8, 10, 12, 15} × α ∈ {0,05; 0,1; 0,5; 1}, 3 pliegues aleatorios por bloque.
  - `perplejidad()` (*document completion*) y `coherencia()` (UMass, 10 palabras) se definen en `08`, como en el Lab 12.
  - Para cada K, el α con menor perplejidad. Se elige el K más pequeño a menos del 5 % de la perplejidad mínima; si su coherencia es la peor, el siguiente K que cumpla.
  - `set.seed(2026)` y `control = list(seed = 2026)`.
  - **Resultado (2026-11-21): K = 10, α = 0,1.** Su perplejidad (240,3) está 3,0 % por encima del mínimo (K = 15) y su coherencia media es −69,6. K = 6 y K = 8 quedan a más del 5 %, y K = 15 tiene la peor coherencia (−76,3). Tabla `conjunto_lda_seleccion.png`; rejilla completa en `conjunto_lda_rejilla.csv`. La rejilla usa 300 iteraciones, como el lab.
- [x] **P3a.6** Modelo final (1.000 iteraciones, 200 de calentamiento) con las semillas 2026, 2027 y 2028. Un tópico de la semilla 2026 se repite si la correlación de su β es de 0,8 o más con algún tópico de cada una de las otras dos (`cor()` de las matrices β). Solo se nombran los tópicos que se repiten. **Resultado: 8 de los 10 tópicos se repiten** (el detalle por tópico entra a la tabla de P3a.7).
- [x] **P3a.7** Nombres: top 8 por lift, top 6 por β y los 3 bloques con mayor θ, con su fecha y tipo. **Alerta de formato:** se marca el tópico que tenga más del 70 % de su peso, en las minutas, en un solo formato (A a E). **Salvedad (2026-11-21):** en la ventana el formato B casi coincide con la época «después», así que la alerta no separa formato de época; lo decide el contraste con los comunicados (P3a.8). **Resultado:** los 8 tópicos estables se nombraron (aprobados por Santiago Muñoz Martínez): 1 Actividad económica interna, 2 Crédito y sistema financiero, 3 Decisión y postura de política monetaria, 4 Inflación por depreciación y alimentos, 6 Déficit externo y capacidad productiva, 7 Seguimiento y provisión de liquidez, 8 Inflación básica y expectativas frente a la meta, 10 Economía mundial. Los tópicos 5 y 9 no se repiten. La alerta marca 1, 2, 7, 8 y 10 (formato A), pero los comunicados caen igual. Tablas `conjunto_lda_topicos.png` y `conjunto_lda_fragmentos.png`.
- [x] **P3a.8** Medida: θ promedio por reunión y tipo (la reunión es la unidad), y diferencia antes frente a después con `t.test`, en cada uno de los `escenarios` (principal, muestra completa, dos cortes alternativos). Es la robustez de H3d, sin código aparte. Los bloques fuera de la ventana principal (la muestra completa y los bordes de las ventanas de los cortes alternativos) usan el θ de `posterior()`. **Resultado:** suben 3, 4 y 6, y bajan 1, 2, 7, 8 y 10, en las dos fuentes; todas las diferencias son «robustas», salvo el tópico 4 en las minutas (+2,0 pp, «matizada»). Figura `conjunto_lda_antes_despues.png`, tabla `conjunto_lda_antes_despues.png` y θ por reunión en `conjunto_lda_theta_por_reunion.csv`.
- [x] **P3a.9** Contraste con H3b: correlación por reunión entre θ y la atención al tema equivalente, que se lee de `03_Resultados/Tablas/09_antes_despues/conjunto_temas_por_reunion.csv` (no se recalcula). Si no coinciden, se reporta (heurística H2). Equivalencias fijadas antes de calcular: Actividad económica = 1; Inflación = 4, 8 y 4 + 8; Entorno externo = 6, 10 y 6 + 10. **Resultado (ventana, 107 comunicados y 112 minutas):** Actividad r = 0,53 en las dos fuentes; Inflación con 4 + 8, r = 0,71 y 0,73; Entorno externo con 6 + 10, r = 0,39 en las minutas y **0,04 [−0,15; 0,23] en los comunicados**: hipótesis (sin verificar con un resultado guardado): allí el tema del diccionario lo dominan palabras genéricas («internacional», «externo», «mundial») que el LDA reparte entre varios tópicos. Nota matizada: `T_choque_externo_llega_a_colombia.md`. Tabla `conjunto_lda_vs_diccionario.png`.
- [x] **P3a.10** Salidas (`08_lda_oraciones` en `carpetas_salida` y `scripts` de `00_main.R`; README):
  - `conjunto_lda_seleccion.png`: perplejidad, costo % frente al mínimo y coherencia por K y α, con el elegido marcado;
  - tabla de tópicos con nombre, palabras, fragmento, peso por formato y si se repite entre semillas;
  - figura de θ antes y después con IC 95 % por tópico y tipo;
  - figura de θ por reunión 2007–2026 con `capa_corte()` y `capa_cortes_formato()` (fuera de la ventana, θ de `posterior()`, marcado en la nota): `conjunto_lda_theta_por_reunion_topicos_1_4.png` y `conjunto_lda_theta_por_reunion_topicos_6_10.png` (4 tópicos cada una, para que se lean en una diapositiva). **Rango recortado a 2007–2019** (decisión de Santiago Muñoz Martínez, 2026-11-21): desde 2020 entra la pandemia, otro choque que habría que explicar aparte;
  - `.csv` de θ por reunión (lo lee H4);
  - nota `05_Notas/08_lda_oraciones/T_*.md` (skill `registrar-hallazgo`).
- [x] **P3a.11** `stopifnot()` al final: θ suma 1 por bloque, coherencia ≤ 0, perplejidad menor que el tamaño del vocabulario. Ya estaban desde P3a.5–P3a.8; se agregó que ninguna reunión de la ventana se pierde en el cruce con el diccionario de `09`.
- [x] **P3a.12** Límite de 3 horas: si la rejilla no termina, K = 10 y α = 0,1, y se declara. No se usó: la rejilla completa corre en un par de minutos y `08` entero en unos 95 segundos.

Riesgo: θ ruidoso en reuniones con pocos bloques (formato C, unas 400 palabras); lo mitiga P3a.6.

### H3b — Qué cambió antes y después: palabras, bigramas, atención y co-ocurrencias (`09_antes_despues.R`)

Samuel Escandón, 2026-11-21. Reemplaza el antiguo `08_antes_despues.R`: el 08 queda para el LDA (H3a) y el 10 para los embeddings (H3c), que hacen otros integrantes. Reglas comunes de H3 (ventana de 5 años a cada lado del 2014-10-30, minutas solo con la discusión de la Junta, comunicados en paralelo como control de formato, todo por 1.000 palabras, fragmento textual para cada palabra, bigrama o tema de una figura).

- [x] **P3b.1** Script `02_Scripts/09_antes_despues.R` (+ `09_antes_despues` en `carpetas_salida` y `scripts` de `00_main.R`; `widyr` en el `p_load()`). Si algo de `03` o `04` sirve, se mueve a `00_funciones_texto.R` sin cambiar sus salidas.
- [x] **P3b.2** Palabras distintivas: medida principal = razón de frecuencias por 1.000 palabras (después / antes, +0,5 a cada lado, mínimo de apariciones declarado); TF-IDF con dos grupos como complemento. Figura de las 15 que más ganan y las 15 que más pierden, por tipo.
- [x] **P3b.3** Bigramas (vocabulario limpio, como en `04`): más frecuentes y los que más cambian, por tipo.
- [x] **P3b.4** Atención por tema (diccionario `temas`, sin modificarlo): por reunión, media antes y después, diferencia e IC 95 % (`t.test` por reunión), por tipo. Figuras: (a) barras antes/después por tema; (b) serie por reunión 2007–2026 de «Entorno externo» e «Inflación» con Brent, TRM e inflación total de `macro_por_reunion.rds` en paneles alineados, corte y periodos marcados (lectura asociativa).
- [x] **P3b.5** Correlaciones entre palabras (`pairwise_cor()`, Lab 11; documento = oración; umbral declarado): 8 palabras más correlacionadas antes y después con `petroleo`, `inflacion`, `tasa_cambio`, `tasa_intervencion`, `crecimiento`, `expectativas_inflacion` y `deficit`. Tabla lado a lado; es el contraste dentro del catálogo para los embeddings (10).
- [x] **P3b.6** Robustez en tablas de apoyo: muestra completa 2007–2026 y los dos cortes alternativos; marcar como posible artefacto de formato lo que cambia en minutas y no en comunicados.
- [x] **P3b.7** `stopifnot()` (reuniones por época, anclas presentes, temas sin NA), README con el mapa de salidas, revisión visual de cada figura y tabla.
- [x] **P3b.8** Notas `05_Notas/09_antes_despues/T_*.md` (skill `registrar-hallazgo`) solo para las conclusiones robustas o matizadas.

### H3c — `10_glove.R`: contexto de las palabras ancla

Simplificado el 2026-11-21 (ver "Decisiones tomadas" de `CLAUDE.md`). **GloVe en vez de Word2Vec:** el paquete `word2vec` no usa la semilla de R y cinco corridas iguales dieron vecinos distintos; GloVe (`text2vec`, Lab 13) se reproduce exactamente. Sin Jaccard: lo reemplaza el coseno antes–después.

- [x] **P3c.1** Word2Vec y GloVe están en el catálogo (Lab 13, secciones 10 a 14 de `07_Recursos/catalogo_metodos.md`). `text2vec` en el `p_load()` y la especificación en "Decisiones tomadas", antes de ver los vecinos.
- [x] **P3c.2** Texto: oración de udpipe con las palabras limpias de `tokens_anotados.rds`, como `pairwise_cor()` en `09`. Comunicados y discusión de la Junta juntos, 2007–2026.
- [x] **P3c.3** Un solo modelo; en la ventana principal las anclas se marcan por época (`inflacion_antes`, `inflacion_despues`) con `asignar_epoca()`.
- [x] **P3c.4** Anclas de `09` con 30 o más oraciones en cada época: inflación, expectativas de inflación, crecimiento y tasa de intervención (quedan fuera déficit, tasa de cambio y petróleo).
- [x] **P3c.5** GloVe con la especificación del Lab 13 (`rank = 50`, `x_max = 10`, ventana 5, frecuencia mínima 5, 50 iteraciones, `n_threads = 1`). Semillas 2026, 2027 y 2028, con el coseno promediado.
- [x] **P3c.6** Medida: los 10 vecinos de cada ancla y época, marcados los que no se repiten en las tres semillas, y el coseno entre `ancla_antes` y `ancla_despues`. Fragmento: oración con el ancla y su vecino principal.
- [x] **P3c.7** Contraste con `pairwise_cor()`: cuántos vecinos están entre las 8 palabras phi de `09`.
- [x] **P3c.8** Salidas: `03_Resultados/Tablas/10_glove/conjunto_glove_vecinos.png` y `.csv` y `conjunto_glove_fragmentos.csv`; nota `05_Notas/10_glove/T_contexto_inflacion_expectativas.md`.

### H3d — Robustez común a H3a, H3b y H3c

No tiene script propio: cada script la corre con los `escenarios` compartidos (P3a.1).

- [ ] **P3d.1** Los dos cortes alternativos (`cortes_alternativos`: 2014-09-26 y 2014-12-19). Se reporta si cambia la dirección del resultado.
- [ ] **P3d.2** Comunicados como control del cambio de formato de las minutas: un cambio que aparece en minutas pero no en comunicados puede ser de formato.
- [ ] **P3d.3** Ventana de 5 años a cada lado (la misma para los tres scripts) y, si alcanza el tiempo, la ventana completa como alternativa.

## H4 — Interpretación con historia macro

- [ ] **P4.1** Cruzar con H1 los resultados de H3a, H3b y H3c (no solo los vecinos): p. ej. ¿la atención a la tasa de cambio sube después del corte?, ¿`tasa_cambio` pasa de «competitividad» a «traspaso/inflación»?
- [ ] **P4.2** Fragmentos textuales de cada cambio (fecha + tipo doc). Sin ejemplo, no entra.
- [ ] **P4.3** Descartar formato: comparar con minutas formato B vs comunicados; normalizar por extensión.
- [ ] **P4.4** Notas `X_*.md`; asociativo, no causal.
- [ ] **P4.5** Deck borrador `04_Presentaciones/` → final `08_Entregables/` (answer-first, ≤15 min).

## Riesgos

- Corpus chico → vecinos ruidosos y tópicos inestables. Mitiga: semillas múltiples, un solo modelo para todo el corpus y contraste entre medidas (H3a, H3b y H3c).
- Corte ≈ cambio formato minutas → confusión tema/formato. Mitiga: comunicados como control y minutas del formato B (H3d).
- **Tiempo:** análisis congelado el sábado 21 a las 8 p. m.; domingo 22, diapositivas y video.

## Verificación

- `00_main.R` desde cero sin errores, regenera figuras/tablas nuevas.
- `stopifnot()` al final de `07`, `08`, `09` y `10`: reuniones por época, anclas presentes, θ que suma 1 por bloque (`08`).
- README con mapa script → salidas actualizado.
