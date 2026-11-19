# PLAN.md — Taller 3: temas de la Junta antes/después de la crisis del petróleo 2014

> Entrega: dom 22-nov-2026. Casillas `[x]` se marcan en la sesión que cierra la tarea.

## Contexto

Pregunta fijada 2026-11-18. Ya existe: texto extraído y limpio (`01`–`05`), series Brent/TRM/inflación en `03_Listos/` (`06_series_macro.R`). Falta: gráficas macro, corte, embeddings (no registrados en catálogo), interpretación.

## H1 — Gráficas macro + exploración descriptiva breve

- [ ] **P1.1** Script `07_graficas_macro.R` (+ subcarpeta en `carpetas_salida` y `scripts` de `00_main.R`).
- [ ] **P1.2** Figuras: Brent, TRM, inflación (núcleo 15 vs meta 3 %), 2007–2026, con sombreado de periodos de `00_formato_graficas.R`. Panel conjunto `macro_series_2007_2026.png`.
- [ ] **P1.3** Descriptiva breve (tabla `macro_descriptiva.png`): por periodo P1–P10 → media, mín, máx, variación % de cada serie. Fechas de pico/valle Brent, salto TRM, pico inflación.
- [ ] **P1.4** Regla de alineación: último dato publicado a la fecha de reunión. Escribir en `CLAUDE.md`.
- [ ] **P1.5** Nota `05_Notas/07_graficas_macro/M_*.md` (skill `registrar-hallazgo`).

## H2 — Fecha de inicio de la crisis

- [ ] **P2.1** Fijar corte con base en H1, ANTES de ver embeddings. Candidato: **2014-09-26** (abre P4, ya fijado a priori; primera reunión tras pico Brent jun-2014). Confirmar contra fechas de P1.3.
- [ ] **P2.2** Añadir línea vertical del corte a las figuras de H1.
- [ ] **P2.3** Registrar en "Decisiones tomadas" (`CLAUDE.md`). Ojo: minutas cambian formato 2014-05-30 (A→B) ≈ corte → declarar.

## H3 — Embeddings antes/después

### P3.1 Ventana (años)

- [ ] Recomendado: **5 años a cada lado** → antes 2009-09-26 a 2014-09-25; después 2014-09-26 a 2019-09-25.
  - Por qué: simétrico, deja fuera crisis 2008 y pandemia 2020.
  - Alternativa: antes = todo desde 2007 (7,7 años), después = hasta 2020-03 (5,5 años).
- [ ] Contar docs y tokens por época; si un lado < ~40 mil tokens, ampliar ventana.

### P3.2 Qué embeddings

- [ ] Recomendado: **Word2Vec skip-gram, paquete `word2vec`** (`word2vec::word2vec()`, `predict(type="nearest")`). Rinde mejor que GloVe en corpus chico.
- [ ] Spec inicial: dim 50–100, ventana 5, min_count 5, iter 20+, `set.seed(2026)` y `threads = 1` (reproducible).
- [ ] Documento: minutas, versión «solo discusión de la Junta» + comunicados como chequeo. Unidad = oración.
- [ ] Registrar ampliación en `07_Recursos/catalogo_metodos.md` + "Decisiones tomadas" **antes** de correr. Agregar `word2vec` a `p_load()`.

### P3.3 Modelo y comparación

- [ ] Script `08_embeddings.R`: un modelo por época, mismo preprocesamiento (`02_limpiar_texto.R`).
- [ ] Palabras ancla fijadas antes: `petroleo`, `inflacion`, `tasa_cambio`/`devaluacion`, `tasa_intervencion`, `crecimiento`, `deficit`, `expectativas`.
- [ ] Medida: vecinos más cercanos por época + solapamiento (Jaccard top-10) → palabras que más cambian de contexto.
- [ ] Estabilidad: repetir con 5 semillas; reportar solo vecinos que se repiten.
- [ ] Complemento barato (ya en catálogo): frecuencia relativa de anclas por 1.000 palabras, antes vs después.
- [ ] Tablas `conjunto_vecinos_antes_despues.png`, figura de cambio por ancla.

## H4 — Interpretación con historia macro

- [ ] **P4.1** Cruzar cambios de vecinos con H1 (p. ej. `tasa_cambio` pasa de «competitividad» a «traspaso/inflación»?).
- [ ] **P4.2** Fragmentos textuales de cada cambio (fecha + tipo doc). Sin ejemplo, no entra.
- [ ] **P4.3** Descartar formato: comparar con minutas formato B vs comunicados; normalizar por extensión.
- [ ] **P4.4** Notas `X_*.md`; asociativo, no causal.
- [ ] **P4.5** Deck borrador `04_Presentaciones/` → final `08_Entregables/` (answer-first, ≤15 min).

## Riesgos

- Corpus chico → vecinos ruidosos. Mitiga: semillas múltiples + frecuencias.
- Corte ≈ cambio formato minutas → confusión tema/formato.
- Tiempo: 4 días. Orden H1 → H2 → H3 → H4.

## Verificación

- `00_main.R` desde cero sin errores, regenera figuras/tablas nuevas.
- `stopifnot()` al final de `07`/`08` (n docs por época, anclas presentes).
- README con mapa script → salidas actualizado.
