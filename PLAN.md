# PLAN.md — Taller 3: temas de la Junta antes/después de la crisis del petróleo 2014

> Entrega: dom 22-nov-2026. Casillas `[x]` se marcan en la sesión que cierra la tarea.

## Contexto

Pregunta fijada 2026-11-18. Ya existe: texto extraído y limpio (`01`–`05`), series macro (`06`), gráficas macro, alineación por reunión y fecha de corte (`07`, H1 y H2). Falta: las medidas antes/después (H3: `08`, `09`, `10`) y la interpretación con la historia macro (H4).

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

### H3b — `09_lda_oraciones.R`: LDA antes y después

Por qué no se repite el LDA de `05`: en la exploración, con la minuta entera como documento, los tópicos separaban épocas y formatos, no temas. Un LDA antes/después hecho así muestra «cambio» por construcción. Por eso la unidad baja a párrafo o bloque de oraciones y se estima un solo modelo.

- [ ] **P3b.1** Unidad de documento: **párrafo**, si la extracción de `01` conserva los saltos de párrafo de forma confiable (verificarlo en 5 minutas de formatos distintos); si no, **bloques de oraciones consecutivas de 60 a 100 palabras** con `partir_oraciones()`. Texto: discusión de la Junta en las minutas y comunicados completos. Cada bloque conserva fecha, tipo y época.
- [ ] **P3b.2** Un solo modelo para todo el corpus 2007–2026 (no uno por época). El cambio se mide comparando el peso de cada tópico (θ) antes y después, no comparando dos modelos.
- [ ] **P3b.3** Vocabulario: sustantivos, adjetivos, nombres propios y compuestos. **Sin verbos**, porque los verbos de atribución separaban épocas en `05`. Recorte de 5 documentos y 75 %, revisado para la nueva unidad.
- [ ] **P3b.4** Selección de K (catálogo, sección 7), con la regla escrita en "Decisiones tomadas" **antes** de ver los tópicos:
  - Gibbs con α = 0,1 y δ = 0,1; K ∈ {6, 8, 10, 12, 15}.
  - Perplejidad por *document completion* con 3 pliegues y coherencia UMass, con las funciones `partir_mitades()`, `perplejidad()` y `coherencia()` del Lab 12.
  - Se elige el **K más pequeño cuya perplejidad está a menos del 5 % del mínimo**, y se descarta si su coherencia media es la peor de la rejilla.
  - Semilla 2026 en `set.seed()` y en `control`.
- [ ] **P3b.5** Nombrar los tópicos con el top 8 por lift, el top 6 por beta y los 3 bloques más representativos con su fecha y tipo. Sin fragmento, el tópico no se nombra.
- [ ] **P3b.6** Medida antes/después: promedio de θ **por reunión** (la reunión es la unidad, no el bloque) y diferencia de medias antes y después con IC 95 %, por tipo de documento. Ventana de 5 años a cada lado.
- [ ] **P3b.7** Validación cruzada con H3a: correlación por reunión entre el θ de cada tópico y la atención al tema equivalente del diccionario. Si no coinciden, se reporta y se reconcilia (heurística H2).
- [ ] **P3b.8** Robustez (H3d): los dos cortes alternativos; minutas frente a comunicados; y las 4 o 5 minutas del formato B anteriores al corte, que permiten ver el cambio de tema con el formato fijo.
- [ ] **P3b.9** Salidas:
  - tabla de tópicos con nombre, palabras y fragmento;
  - figura de θ antes/después con IC por tópico y tipo;
  - figura de θ por reunión 2007–2026 con el corte y los cortes de formato marcados (`capa_corte()`, `capa_cortes_formato()`);
  - nota `05_Notas/09_lda_oraciones/T_*.md`.
- [ ] **P3b.10** Límite de tiempo: 3 horas. Si la selección de K no termina, se usa K = 10 y se declara.

Riesgos del hito: corpus chico, así que θ es ruidoso en minutas cortas (formato C, unas 400 palabras) y los tópicos pueden ser inestables.

### H3b — Qué cambió antes y después: palabras, bigramas, atención y co-ocurrencias (`09_antes_despues.R`)

Samuel Escandón, 2026-11-21. Reemplaza el antiguo H3a (`08_antes_despues.R`): el 08 queda para el LDA y el 10 para los embeddings, que hacen otros integrantes. Reglas comunes de H3 (ventana de 5 años a cada lado del 2014-10-30, minutas solo con la discusión de la Junta, comunicados en paralelo como control de formato, todo por 1.000 palabras, fragmento textual para cada palabra, bigrama o tema de una figura).

- [x] **P3b.1** Script `02_Scripts/09_antes_despues.R` (+ `09_antes_despues` en `carpetas_salida` y `scripts` de `00_main.R`; `widyr` en el `p_load()`). Si algo de `03` o `04` sirve, se mueve a `00_funciones_texto.R` sin cambiar sus salidas.
- [x] **P3b.2** Palabras distintivas: medida principal = razón de frecuencias por 1.000 palabras (después / antes, +0,5 a cada lado, mínimo de apariciones declarado); TF-IDF con dos grupos como complemento. Figura de las 15 que más ganan y las 15 que más pierden, por tipo.
- [x] **P3b.3** Bigramas (vocabulario limpio, como en `04`): más frecuentes y los que más cambian, por tipo.
- [x] **P3b.4** Atención por tema (diccionario `temas`, sin modificarlo): por reunión, media antes y después, diferencia e IC 95 % (`t.test` por reunión), por tipo. Figuras: (a) barras antes/después por tema; (b) serie por reunión 2007–2026 de «Entorno externo» e «Inflación» con Brent, TRM e inflación total de `macro_por_reunion.rds` en paneles alineados, corte y periodos marcados (lectura asociativa).
- [x] **P3b.5** Correlaciones entre palabras (`pairwise_cor()`, Lab 11; documento = oración; umbral declarado): 8 palabras más correlacionadas antes y después con `petroleo`, `inflacion`, `tasa_cambio`, `tasa_intervencion`, `crecimiento`, `expectativas_inflacion` y `deficit`. Tabla lado a lado; es el contraste dentro del catálogo para los embeddings (10).
- [x] **P3b.6** Robustez en tablas de apoyo: muestra completa 2007–2026 y los dos cortes alternativos; marcar como posible artefacto de formato lo que cambia en minutas y no en comunicados.
- [x] **P3b.7** `stopifnot()` (reuniones por época, anclas presentes, temas sin NA), README con el mapa de salidas, revisión visual de cada figura y tabla.
- [x] **P3b.8** Notas `05_Notas/09_antes_despues/T_*.md` (skill `registrar-hallazgo`) solo para las conclusiones robustas o matizadas.

### H3c — `10_word2vec.R`: contexto de las palabras ancla

- [ ] **P3c.1** Registrar la ampliación en `07_Recursos/catalogo_metodos.md` y en "Decisiones tomadas" **antes** de correr. Agregar `word2vec` y `widyr` al `p_load()`.
- [ ] **P3c.2** Word2Vec skip-gram, paquete `word2vec` (`word2vec::word2vec()`, `predict(type = "nearest")`). Especificación inicial: dimensión 50–100, ventana 5, `min_count` 5, 20 o más iteraciones, `set.seed(2026)` y `threads = 1` (reproducible).
- [ ] **P3c.3** **Un solo modelo con todo el corpus**, con las anclas marcadas por época en el texto (`petroleo_antes`, `petroleo_despues`), en vez de un modelo por época. Así los dos vectores de cada ancla viven en el mismo espacio y se comparan directamente.
- [ ] **P3c.4** Palabras ancla fijadas antes de ver resultados: `petroleo`, `inflacion`, `tasa_cambio`/`devaluacion`, `tasa_intervencion`, `crecimiento`, `deficit`, `expectativas`. Documento: minutas (solo discusión de la Junta) y comunicados como chequeo; unidad = oración.
- [ ] **P3c.5** Medida: vecinos más cercanos de cada ancla antes y después, y solapamiento (Jaccard del top 10). Estabilidad: repetir con 5 semillas y reportar solo los vecinos que se repiten.
- [ ] **P3c.6** Contraste con `pairwise_cor()` (`widyr`; catálogo, Lab 11, sección 4) sobre las mismas anclas, antes y después: las palabras más correlacionadas con cada ancla deberían coincidir en parte con los vecinos de Word2Vec. Si no coinciden, se reporta.
- [ ] **P3c.7** Salidas: tabla `conjunto_vecinos_antes_despues.png` (vecinos y correlaciones por ancla y época) y figura del cambio por ancla. Nota `05_Notas/10_word2vec/T_*.md`.

### H3d — Robustez común a H3a, H3b y H3c

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
- `stopifnot()` al final de `07`, `08`, `09` y `10`: reuniones por época, anclas presentes, θ que suma 1 por bloque.
- README con mapa script → salidas actualizado.
