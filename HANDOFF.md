# HANDOFF

Resumen accionable del Taller 3 para retomar el trabajo. El detalle de cada
sesión está en `06_Bitacoras/`; aquí solo va lo necesario para saber dónde
estamos y qué sigue. Las reglas para mantener este archivo están en
`CLAUDE.md` (sección "`HANDOFF.md`").

**Fecha de entrega (video de máximo 15 minutos, slides y material de soporte):
domingo 22 de noviembre de 2026.**

## Siguientes objetivos

<!-- Dos a tres tareas concretas, en orden de prioridad, cada una con el
     archivo que debe producirse, un criterio de terminado verificable y, si
     aplica, el integrante a cargo. Cuando exista el plan de implementación,
     cada objetivo cita el paso del plan del que sale. Se reescribe al cerrar
     cada sesión. -->

1. **H4 de `PLAN.md` (P4.5): deck final y video, todo el equipo (domingo 22).**
   - Hay un borrador: `04_Presentaciones/borrador_presentacion.pptx` (13 diapositivas más el
     apéndice, guion en las notas del orador). Se regenera con
     `python 04_Presentaciones/construir_borrador.py`.
   - Faltan:
     - revisarlo en PowerPoint (Codec Pro no está en LibreOffice);
     - reemplazar la diapositiva 7 (embeddings);
     - pasar la versión final a `08_Entregables/`;
     - grabar el video.
   - *Terminado cuando:* el video dura máximo 15 minutos, los cuatro integrantes exponen y cada
     hallazgo lleva su fragmento y la salvedad «asociación, no causalidad».
2. **H3c de `PLAN.md`: `10_word2vec.R` (otro integrante), o decidir omitirlo.**
   - Para confirmar los hallazgos, los vecinos de «inflación» deberían pasar de proyección y
     monitoreo a devaluación, traslado e indexación (sección 5 de `hallazgos_y_figuras.txt`).
   - *Terminado cuando:* existe la figura de vecinos con su nota y la diapositiva 7 del deck la
     usa, o la omisión queda en «Decisiones tomadas» y la diapositiva 7 se quita.
3. **Correr `00_main.R` completo (ahora con `11`) y abrir el PR de `SamuelEscandonC` a `main`
   (Samuel Escandón).**
   - *Terminado cuando:* `00_main.R` termina sin errores, las figuras de `11` coinciden con las
     del deck y el PR está abierto.

**Bloqueos y preguntas abiertas:**

- Roles de los integrantes en el Taller 3.
- La validación manual de la votación quedó fuera de `PLAN.md`: decidir si se
  abandona.
- Corpus pequeño (unas 177 mil palabras limpias) para entrenar embeddings y
  partirlo en dos épocas; los cambios de formato de las minutas pueden
  confundirse con cambio de temas.
- Fecha de la retroalimentación a compañeros (no afecta el repositorio).
- Los dos xlsx de inflación total y meta también quedaron sin versionar en
  `01_Datos/01_Crudos/` de la carpeta principal del repositorio (en `main`).
  Al traer `SamuelEscandonC` a esa carpeta, git puede negarse a sobrescribir
  archivos sin seguimiento: hay que borrarlos o moverlos antes.
- Supuesto de la alineación: el IPC del mes m se publica el día 8 del mes m+1
  (sin confirmar mes por mes).
- En la ventana de 5 años, las minutas tienen la mitad de palabras después del
  corte (unas 43.800 antes y 23.100 después) por el cambio de formato; los
  comunicados están equilibrados.
- La clasificación de la votación y la dirección de la minoría son
  automáticas y no están validadas; la dirección no es codificable en 35 de
  las 101 reuniones decididas por mayoría, casi todas antes de 2016.
- Parte del aumento de las decisiones por mayoría puede ser un cambio en cómo
  se redacta la minuta (ver la nota de votación).
- Solo 31 minutas traen su fecha de publicación (rezago mediano de 14 días);
  para las demás hay que suponerlo o consultarlo.
- LDA (`08`): en las minutas, el formato B (desde 2014-05-30) casi coincide con
  la época «después», así que la alerta de formato no separa formato de época.
  El tópico 3 (decisión y postura) puede ser en parte de formato en las
  minutas.
- Hipótesis sin verificar en `T_choque_externo_llega_a_colombia.md`: en los
  comunicados, el tema «Entorno externo» del diccionario lo dominan palabras
  genéricas que el LDA reparte entre tópicos (correlación por reunión de 0,04
  con los tópicos 6 + 10).
- `00_main.R` emite un warning de ggplot (`position_stack()` con intervalos
  que se solapan); no se revisó de qué figura sale.
- El título de la diapositiva 7 del deck (embeddings) es provisional.
- La figura de verificación «el discurso cambió antes de las alzas» no se generó: la regla solo se
  cumple para el entorno externo (ver `05_Notas/11_figuras_diapositiva/`).
- Lista de palabras vacías de redacción: `mantener`, `continuar`, `seguir`,
  los verbos de atribución («resaltar», «destacar», «señalar»…) y adjetivos
  como `anual`, `mayor` o `menor` quedan entre las palabras más frecuentes. Si
  el equipo quiere sacarlos, hay que fijar el criterio antes de ver el efecto
  (detalle en la bitácora del 2026-11-18).
- Brent (FRED): 500 de 7.011 días hábiles sin precio, 335 de ellos entre 2000
  y 2006 y sin causa documentada (desde 2007 parecen feriados de Londres). El
  README y `CLAUDE.md` aún los llaman "festivos"; falta corregir la redacción.
  El equipo decidió quedarse con FRED (la EIA trae los mismos vacíos).
- Qué pipe usa el equipo: el proyecto usa `%>%`, pero un formateador de
  VS Code (hay un `.lintr` sin versionar) lo cambia a `|>` y rompe
  `con_tildes()`. Hay que desactivar esa opción o acordar la convención.

## Estado actual

- **Pipeline:** `00_main.R` corre diez scripts: 01 a 09 y `11`.
  - Con 01 a 09 tardaba unos 4,6 minutos (2026-11-21); `11` suma unos 10 segundos.
  - La corrida completa con `11` todavía no se ha hecho; `11` se probó solo.
  - Requiere Chrome para las tablas e internet la primera vez.
- **Scripts:**
  - de formato y definiciones: `00_formato_graficas.R` (incluye `tema_diapositiva` y
    `colores_macro_diapositiva`), `00_formato_tablas.R` y `00_funciones_texto.R`;
  - de texto: `01_extraer_texto.R` a `05_lda_exploratorio.R`;
  - de series: `06_series_macro.R` y `07_graficas_macro.R`;
  - antes/después del corte: `08_lda_oraciones.R` (LDA, K = 10) y `09_antes_despues.R` (palabras,
    bigramas, temas y correlaciones);
  - `11_figuras_diapositiva.R`: versiones 16:9 de las figuras para la presentación y la
    verificación del momento del cambio;
  - `10_word2vec.R` no existe todavía (otro integrante).
- **Datos:**
  - corpus de 393 documentos (194 comunicados y 199 minutas);
  - series macro y `macro_por_reunion.rds` (205 reuniones alineadas).
- **Fecha de corte:** 2014-10-30. Alternativas: 2014-09-26 y 2014-12-19.
- **Presentación** (en `04_Presentaciones/`):
  - documento base: `hallazgos_y_figuras.txt`;
  - reglas de diseño: `indicaciones_deck.md`;
  - plantilla: `plantilla_presentacion.pptx`;
  - borrador: `borrador_presentacion.pptx`, que genera `construir_borrador.py`.
- **Notas:** trece notas en `05_Notas/`. Las de `08`, `09` y `11` sostienen la presentación; las
  dos discrepancias entre notas y `.csv` de `09` quedaron corregidas.
- **Plan:** `PLAN.md` tiene H1, H2, H3a (LDA) y H3b (`09`) terminados. Siguen H3c (Word2Vec) y H4
  (el borrador del deck existe; faltan la versión final y el video).
- **Git:**
  - `main` incluye `SantiagoMunozM` (PR #8) y `SamuelEscandonC` hasta el documento de hallazgos
    (PR #9);
  - el trabajo de esta sesión está en `SamuelEscandonC`, sin mergear.

## Registro de sesiones

### 2026-11-21 (5): documento de hallazgos, figuras para diapositiva y borrador del deck

- Samuel Escandón (`SamuelEscandonC`). Avanza H4 (P4.2 y P4.5, sin cerrar). Se escribieron:
  - `hallazgos_y_figuras.txt`;
  - `11_figuras_diapositiva.R`, con versiones 16:9 de las figuras de 07 a 09 y una verificación:
    el entorno externo supera su máximo previo antes de la primera alza y la inflación por
    depreciación después;
  - el borrador del deck sobre la plantilla del equipo, con `python-pptx` y el guion en las notas.
  Se corrigieron dos discrepancias de las notas de `09`. No se corrió `00_main.R` completo.
- Bitácora: [2026-11-21_figuras-diapositiva-y-borrador.md](06_Bitacoras/2026-11-21_figuras-diapositiva-y-borrador.md)
- **Siguientes objetivos:**
  1. Deck final y video (P4.5).
  2. Word2Vec (H3c) u omitirlo.
  3. `00_main.R` completo y PR de `SamuelEscandonC` a `main`.

### 2026-11-21 (4): LDA con bloques de oraciones (H3a)

- Santiago Muñoz Martínez (`SantiagoMunozM`). Se diseñó y escribió
  `08_lda_oraciones.R` (H3a, P3a.1–P3a.12 cerrados): umbral de 60 palabras por
  bloque, LDA en la ventana con K = 10 y α = 0,1, 8 tópicos estables con
  nombre, diferencia antes/después por reunión en cuatro escenarios, contraste
  con el diccionario de `09` y serie por reunión 2007–2019. El estilo de las
  tablas cambió para todo el proyecto. Cuatro notas nuevas; la del sector
  externo se matizó. `00_main.R` corre completo.
- Bitácora: [2026-11-21_lda-oraciones.md](06_Bitacoras/2026-11-21_lda-oraciones.md)
- **Siguientes objetivos:** (1) H4, interpretación y deck; (2) H3c Word2Vec
  o decidir omitirlo; (3) PR de `SantiagoMunozM` a `main`.

### 2026-11-21 (3): qué cambió antes y después del corte

- Samuel Escandón (`SamuelEscandonC`). Se escribió `09_antes_despues.R`
  (hito H3b, P3b.1–P3b.8 cerrados): razón de frecuencias de palabras y
  bigramas, atención por tema con IC 95 % por reunión, `pairwise_cor()` por
  oración para ocho anclas y la figura por reunión de entorno externo e
  inflación frente a Brent, TRM e inflación; robustez con la muestra completa
  y los dos cortes alternativos. Cuatro notas nuevas. El H3a del plan se
  reemplazó por este hito; `00_main.R` completo queda para Samuel.
- Bitácora: [2026-11-21_antes-despues-palabras-temas.md](06_Bitacoras/2026-11-21_antes-despues-palabras-temas.md)
- **Siguientes objetivos:** (1) `00_main.R` completo y PR a `main`;
  (2) LDA (08) y embeddings (10), contrastados con las notas de `09`;
  (3) H4, interpretación y deck.

### 2026-11-21 (2): H3 reorganizado con las medidas del equipo

- Samuel Escandón (`SamuelEscandonC`). Sesión de planeación, sin código. Se
  reorganizó H3 de `PLAN.md` en cuatro partes con su script: H3a
  `08_antes_despues.R` (TF-IDF, temas y bigramas), H3b `09_lda_oraciones.R`
  (un solo LDA por párrafo o bloque, P3b.1–P3b.10), H3c `10_word2vec.R` (un
  solo modelo con anclas por época y `pairwise_cor()`) y H3d (robustez común).
  El LDA por minuta entera y los embeddings de los hitos anteriores quedan
  dentro de H3; la interpretación vuelve a H4. Decisión registrada en
  `CLAUDE.md`. Sin bitácora (sesión de 15 minutos).
- **Siguientes objetivos:** (1) H3a y H3b en paralelo; (2) H3c con la
  ampliación de Word2Vec; (3) H4, interpretación y deck.

### 2026-11-21: formato de la nota al pie y nuevo hito H3 (LDA)

- Santiago Muñoz Martínez (`SantiagoMunozM`). La nota al pie de las figuras de
  `07_graficas_macro.R` queda con una oración por renglón y las fuentes al
  final (reglas en `CLAUDE.md`). Se agregó el hito H3 (LDA con balance
  perplejidad–coherencia) a `PLAN.md` y se corrieron los demás: embeddings
  pasa a H4 e interpretación a H5. No se escribió código de análisis.
- Bitácora: [2026-11-21_formato-notas-y-plan-lda.md](06_Bitacoras/2026-11-21_formato-notas-y-plan-lda.md)
- **Siguientes objetivos:** (1) H3, P3.1–P3.3: regla de selección y
  `08_lda.R`; (2) H4, P4.1 y P4.3: `pairwise_cor()` antes/después;
  (3) H4, P4.2: registrar los embeddings como ampliación.

### 2026-11-19: gráficas macro, alineación por reunión y fecha de corte (H1 y H2)

- Samuel Escandón (`SamuelEscandonC`). Se trajo `main` (PR #3). Se agregaron
  la inflación total y la meta, descargadas por el usuario; las capas de
  periodos y de corte; y `07_graficas_macro.R`, con dos figuras, cuatro tablas
  y la alineación por reunión (`macro_por_reunion.rds`).
- El corte se fijó solo con las series y las decisiones de tasa: 2014-10-30,
  con alternativas 2014-09-26 y 2014-12-19.
- Se cerraron P1.1–P1.5 y P2.1–P2.3. Se escribió la nota
  `M_cronologia_choque_petrolero.md`.
- Bitácora: [2026-11-19_graficas-macro-y-corte.md](06_Bitacoras/2026-11-19_graficas-macro-y-corte.md)
- **Siguientes objetivos:**
  1. H3 con `pairwise_cor()` como medida principal antes/después
     (`08_correlaciones_antes_despues.R`).
  2. Embeddings como complemento, registrados antes de usarlos.
  3. H4: interpretación con la cronología macro y borrador del deck.

### 2026-11-18 (4): plan de implementación

- Santiago Muñoz Martínez (`SantiagoMunozM`). Se escribió `PLAN.md` con hitos
  H1–H4 y tareas `Pk.n`: gráficas macro con descriptiva breve, luego el corte
  de la crisis (orden pedido por el usuario), embeddings antes/después
  (recomendado: 5 + 5 años y Word2Vec skip-gram, por decidir) e
  interpretación. Cumple la parte de `PLAN.md` del objetivo 2 anterior; no se
  escribió código.
- Bitácora: [2026-11-18_plan-implementacion.md](06_Bitacoras/2026-11-18_plan-implementacion.md)
- **Siguientes objetivos:** (1) P1.1–P1.4: gráficas macro y descriptiva;
  (2) P2: fijar el corte de la crisis; (3) P3.1–P3.2: decidir y registrar
  ventana y embeddings.

### 2026-11-18 (3): pregunta del taller y TRM

- Santiago Muñoz Martínez (`SantiagoMunozM`). El equipo fijó la pregunta (temas
  de la Junta antes y después de la crisis del petróleo de 2014, con GloVe o
  Word2Vec); se registró en `CLAUDE.md`, README, handoff y catálogo, donde los
  embeddings quedan previstos pero sin registrar como ampliación. Se integró la
  TRM diaria (SUAMECA) a `06_series_macro.R` (`macro_trm.rds`, 9.820 días).
  Cumplió el objetivo 1 en cuanto a fijar la pregunta; avanzó el 3 anterior.
- Bitácora: [2026-11-18_pregunta-y-trm.md](06_Bitacoras/2026-11-18_pregunta-y-trm.md)
- **Siguientes objetivos:** (1) cerrar el diseño: registrar los embeddings,
  fijar corte y tipo de documento; (2) `PLAN.md` y alineación de las series;
  (3) validar la votación si sigue siendo relevante.

### 2026-11-18 (2): primeras series macro

- Santiago Muñoz Martínez (`SantiagoMunozM`). Se documentaron las fuentes de los
  tres crudos macro (README, `CLAUDE.md`), se registró `readxl` y se escribió
  `06_series_macro.R`, que filtra desde 2000 y guarda tres `.rds` en `03_Listos/`.
  Se revisaron los 500 días sin precio del Brent: la EIA trae los mismos y se
  mantiene FRED. Avanzó el objetivo 3; no se trabajaron el 1 ni el 2.
- Bitácora: [2026-11-18_series-macro-crudas_2.md](06_Bitacoras/2026-11-18_series-macro-crudas_2.md)
- **Siguientes objetivos:** (1) fijar la pregunta con el equipo; (2) validar a
  mano la votación (30 documentos); (3) `PLAN.md` y alineación de las series macro.

### 2026-11-18: lectura de la exploración, revisión de la limpieza y filtro de símbolos

- Santiago Muñoz Martínez (`SantiagoMunozM`). Se revisó la exploración de
  Samuel (scripts 01 a 05) y la limpieza del texto, y el paso 4 de
  `02_limpiar_texto.R` pasó a descartar símbolos además de dígitos (176.750 →
  176.622 tokens limpios). Se revirtió un reformateo con `|>` que rompía
  `con_tildes()`, se corrió `00_main.R` completo y las tres notas siguen
  consistentes. No se trabajaron los objetivos de `HANDOFF.md`; `graphify`
  se probó y se descartó.
- Bitácora: [2026-11-18_filtro-simbolos-limpieza.md](06_Bitacoras/2026-11-18_filtro-simbolos-limpieza.md)
- **Siguientes objetivos:** (1) fijar la pregunta con el equipo; (2) validar a
  mano la votación (30 documentos); (3) `PLAN.md` y series macro, empezando por
  documentar los tres archivos de `01_Crudos/`.

### 2026-11-12: base del pipeline y exploración del corpus

- Samuel Escandón (`SamuelEscandonC`). Se crearon `00_main.R`, los scripts de
  formato, `00_funciones_texto.R` y cinco scripts (extracción, limpieza,
  frecuencias y TF-IDF, bigramas y votación, LDA exploratorio), el README y
  tres notas. Se ubicaron los cortes de formato de las minutas, se definieron
  diez periodos a priori y se exportó una muestra de 30 documentos para
  validar la votación. No se cruzó texto con series macro. El objetivo de
  definir la pregunta avanzó sin cerrarse: falta acordarla con el equipo.
- Bitácora: [2026-11-12_exploracion-corpus.md](06_Bitacoras/2026-11-12_exploracion-corpus.md)
- **Siguientes objetivos:** (1) fijar la pregunta con el equipo (candidata: si
  el voto de la minoría y los argumentos de la minuta anticipan la siguiente
  decisión más allá de la inflación y las expectativas); (2) validar a mano la
  votación con la muestra de 30 documentos; (3) `PLAN.md` y series macro.

### 2026-11-08: configuración inicial, catálogo de métodos y verificación de los documentos

- Santiago Muñoz Martínez (`SantiagoMunozM`). Se replicó la estructura del
  Taller 2, se descomprimieron los documentos en
  `01_Datos/01_Crudos/Comunicados_Minutas_Banrep/` y se escribieron
  `CLAUDE.md`, las tres skills y este handoff. Se armó el catálogo de métodos
  de los Labs 11 y 12, se registró la entrega (22 de noviembre, video de 15
  minutos) y se verificó que el nombre de cada archivo es la fecha de la
  reunión. El informe técnico que venía como minuta del 2020-04-30 se sacó de
  `minutas/` y se renombró.
- Bitácora: [2026-11-08_configuracion-inicial.md](06_Bitacoras/2026-11-08_configuracion-inicial.md)
- **Siguientes objetivos:** (1) definir la pregunta y las series macro;
  (2) `PLAN.md` y ampliaciones del catálogo; (3) `00_main.R`, formato y
  extracción de texto.
