# PLAN.md — Taller 3: temas de la Junta antes/después de la crisis del petróleo 2014

> Entrega: dom 22-nov-2026. Casillas `[x]` se marcan en la sesión que cierra la tarea.

## Contexto

Pregunta fijada 2026-11-18. Ya existe: texto extraído y limpio (`01`–`05`), series Brent/TRM/inflación en `03_Listos/` (`06_series_macro.R`). Falta: gráficas macro, corte, LDA (H3), embeddings (no registrados en catálogo), interpretación.

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

## H3 — LDA: tópicos legibles con balance perplejidad–coherencia

Corpus: minutas, solo discusión de la Junta (`minuta_junta`, 199 documentos); documento = minuta entera. Comunicados solo como chequeo posterior. Entrada: `vocabulario_lda.rds`, `tokens_limpios.rds`.

- [ ] **P3.1** Registrar la regla de selección en "Decisiones tomadas" (`CLAUDE.md`) **antes de correr y de ver tópicos**:
  - Rejilla: K ∈ {4, 6, 8, 10, 12, 16} × α ∈ {0,1; 0,5; 1}, δ = 1 (valor del lab), Gibbs con 300 iteraciones, 3 pliegues, `set.seed(2026)` y `control$seed = 2026`. Después, con K elegido, comparar δ ∈ {0,1; 1} (procedimiento del lab). 54 ajustes en la primera rejilla, no los 162 del lab.
  - Regla de balance: para cada K, el mejor α; se ordenan los K por perplejidad (menor mejor) y por coherencia UMass media (más cercana a cero mejor); se elige el K con menor **suma de rangos** (empate: el K menor). Se reportan también los K vecinos, para ver la sensibilidad.
  - Chequeo de legibilidad (después de elegir K, no cambia la regla): si un tópico concentra más de 70 % de su peso en un solo formato de minuta (A a E), se marca como posible artefacto de formato y se informa; no se descarta en silencio.
  - Declarar que la perplejidad es criterio de selección del modelo, no un pronóstico, así que los pliegues son aleatorios por documento (no hay predicción de una serie en el tiempo).
- [ ] **P3.2** Funciones auxiliares en `02_Scripts/00_funciones_texto.R`: `partir_mitades()`, `perplejidad()` (document completion con `posterior(modelo, newdata = A)`, `exp(-Σ log p / N)`) y `coherencia()` (UMass, 10 palabras principales). Mover ahí desde `05_lda_exploratorio.R` `estimar_lda()`, `resumen_topicos()` y `documentos_representativos()`, con sus entradas como argumentos; `05` las llama. Criterio: las tablas de `05` salen iguales (`git diff` de sus `.csv` sin cambios).
- [ ] **P3.3** Script `02_Scripts/08_lda.R` (+ `08_lda` en `carpetas_salida` y `scripts` de `00_main.R`):
  1. Rejilla y selección de K con la regla de P3.1. Tabla `minutas_lda_seleccion_k.png` (perplejidad, costo % frente al mínimo, coherencia, suma de rangos, K elegido) y figura `minutas_lda_perplejidad_coherencia.png` (las dos medidas por K, K elegido marcado).
  2. Estimar el LDA final con el K elegido (Gibbs, 1.000 iteraciones, 200 de calentamiento).
  3. Validación de tópicos: tabla top beta y lift, tabla de las 3 minutas más representativas con fragmento (fecha + tipo), peso por formato A a E. **Los nombres se asignan solo con esos ejemplos.**
  4. Guardar `01_Datos/03_Listos/lda_theta.rds` (θ por minuta) para H5.
  5. `stopifnot()` al final: 199 minutas, filas de θ suman 1, coherencia ≤ 0, perplejidad menor que el tamaño del vocabulario (la de un modelo uniforme).
- [ ] **P3.4** Atención por tópico antes y después del corte (2014-10-30): θ medio por lado, normalizado por extensión, con la figura del formato de `05`. Es entrada de H5; la lectura es asociativa.
- [ ] **P3.5** Nota `05_Notas/08_lda/T_*.md` (skill `registrar-hallazgo`), contrastada con las notas de `03_frecuencias_tfidf` y con los episodios de política monetaria; README (mapa script → salidas) y "Decisiones tomadas" actualizados.

Riesgos del hito: (i) corpus chico (62 mil tokens, 199 documentos): θ ruidoso en minutas cortas (formato C, unas 400 palabras) y tópicos inestables; mitigación: reportar K vecinos y repetir la estimación final con 3 semillas, informando solo tópicos que se repiten; (ii) el corte 2014-10-30 casi coincide con el cambio de formato A→B (2014-05-30).

## H4 — Embeddings antes/después

### P4.1 Ventana (años)

- [ ] Recomendado: **5 años a cada lado** → antes 2009-09-26 a 2014-09-25; después 2014-09-26 a 2019-09-25.
  - Por qué: simétrico, deja fuera crisis 2008 y pandemia 2020.
  - Alternativa: antes = todo desde 2007 (7,7 años), después = hasta 2020-03 (5,5 años).
- [ ] Contar docs y tokens por época; si un lado < ~40 mil tokens, ampliar ventana.

### P4.2 Qué embeddings

- [ ] Recomendado: **Word2Vec skip-gram, paquete `word2vec`** (`word2vec::word2vec()`, `predict(type="nearest")`). Rinde mejor que GloVe en corpus chico.
- [ ] Spec inicial: dim 50–100, ventana 5, min_count 5, iter 20+, `set.seed(2026)` y `threads = 1` (reproducible).
- [ ] Documento: minutas, versión «solo discusión de la Junta» + comunicados como chequeo. Unidad = oración.
- [ ] Registrar ampliación en `07_Recursos/catalogo_metodos.md` + "Decisiones tomadas" **antes** de correr. Agregar `word2vec` a `p_load()`.

### P4.3 Modelo y comparación

- [ ] Script `10_embeddings.R` (el 08 es el LDA y el 09 queda para las correlaciones entre palabras): un modelo por época, mismo preprocesamiento (`02_limpiar_texto.R`).
- [ ] Palabras ancla fijadas antes: `petroleo`, `inflacion`, `tasa_cambio`/`devaluacion`, `tasa_intervencion`, `crecimiento`, `deficit`, `expectativas`.
- [ ] Medida: vecinos más cercanos por época + solapamiento (Jaccard top-10) → palabras que más cambian de contexto.
- [ ] Estabilidad: repetir con 5 semillas; reportar solo vecinos que se repiten.
- [ ] Complemento barato (ya en catálogo): frecuencia relativa de anclas por 1.000 palabras, antes vs después.
- [ ] Tablas `conjunto_vecinos_antes_despues.png`, figura de cambio por ancla.

## H5 — Interpretación con historia macro

- [ ] **P5.1** Cruzar cambios de vecinos con H1 (p. ej. `tasa_cambio` pasa de «competitividad» a «traspaso/inflación»?).
- [ ] **P5.2** Fragmentos textuales de cada cambio (fecha + tipo doc). Sin ejemplo, no entra.
- [ ] **P5.3** Descartar formato: comparar con minutas formato B vs comunicados; normalizar por extensión.
- [ ] **P5.4** Notas `X_*.md`; asociativo, no causal.
- [ ] **P5.5** Deck borrador `04_Presentaciones/` → final `08_Entregables/` (answer-first, ≤15 min).

## Riesgos

- Corpus chico → vecinos ruidosos. Mitiga: semillas múltiples + frecuencias.
- Corte ≈ cambio formato minutas → confusión tema/formato.
- Tiempo: 4 días. Orden H1 → H2 → H3 → H4 → H5.

## Verificación

- `00_main.R` desde cero sin errores, regenera figuras/tablas nuevas.
- `stopifnot()` al final de `07`/`08`/`10` (n docs por época, anclas presentes).
- README con mapa script → salidas actualizado.
