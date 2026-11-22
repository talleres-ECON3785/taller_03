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

1. **H4 de `PLAN.md` (P4.1–P4.5): interpretación y deck, todo el equipo
   (domingo 22).**
   - Insumos listos: las notas de `05_Notas/08_lda_oraciones/` (LDA) y de
     `05_Notas/09_antes_despues/` (diccionario, palabras, bigramas), con
     cifras, fragmentos y lectura de robustez. Las figuras por reunión del LDA
     (`conjunto_lda_theta_por_reunion_topicos_1_4.png` y `_6_10.png`) ya
     están en formato de diapositiva.
   - *Terminado cuando:* el borrador en `04_Presentaciones/` tiene cada cambio
     de tema con su fragmento y la salvedad «asociación, no causalidad», y el
     video dura máximo 15 minutos.
2. **H3c de `PLAN.md` (P3c.1–P3c.8): `10_word2vec.R`, o decidir omitirlo
   (integrante por definir).**
   - Antes de correr: registrar Word2Vec como ampliación del catálogo
     (P3c.1). Contrastar con `pairwise_cor()` de `09` y con los tópicos de
     `08` (vecinos de «inflación» y de «déficit»).
   - *Terminado cuando:* existe `conjunto_vecinos_antes_despues.png` con su
     nota en `05_Notas/10_word2vec/`, o la omisión queda registrada en
     «Decisiones tomadas».
3. **Llevar `SantiagoMunozM` a `main` con un pull request (lo pide Santiago
   Muñoz Martínez, no el agente).**
   - `SamuelEscandonC` ya está en `main` (PR #6). `00_main.R` corre completo
     en `SantiagoMunozM` (nueve scripts, 4,6 minutos); si `main` avanzó, hay
     que traerlo antes y resolver conflictos en `PLAN.md`, `CLAUDE.md` y
     `HANDOFF.md`.
   - *Terminado cuando:* el PR está mergeado y `00_main.R` corre sin errores
     en `main`.

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
- `04_Presentaciones/indicaciones_deck.md` está sin seguimiento y no lo creó
  esta rama: confirmar de quién es antes de versionarlo.
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

- **Pipeline:** `00_main.R` corre nueve scripts (01 a 09) en unos 4,6 minutos
  si ya existe la anotación de `udpipe` (verificado el 2026-11-21 en
  `SantiagoMunozM`). Requiere Chrome para las tablas e internet la primera vez.
- **Scripts:**
  - de formato y definiciones: `00_formato_graficas.R`, `00_formato_tablas.R`
    (desde el 2026-11-21: encabezados y cifras centrados, texto a la izquierda,
    márgenes de 8 px) y `00_funciones_texto.R` (periodos, formatos de minuta,
    compuestos, palabras vacías, temas, corte, `construir_bigramas()`,
    `asignar_epoca()`, `escenarios` y `texto_original()`);
  - de texto: `01_extraer_texto.R` a `05_lda_exploratorio.R`;
  - de series: `06_series_macro.R` y `07_graficas_macro.R`;
  - antes/después del corte:
    - `08_lda_oraciones.R`: LDA con bloques de 60 palabras, estimado en la
      ventana con K = 10 y α = 0,1; 8 tópicos estables con nombre; θ por
      reunión antes/después en cuatro escenarios, contraste con el
      diccionario y serie 2007–2019;
    - `09_antes_despues.R`: palabras, bigramas, atención por tema y
      correlaciones.
  - `10_word2vec.R` no existe.
- **Datos:**
  - Corpus: 393 documentos (194 comunicados y 199 minutas). Tokens limpios y
    anotados en `01_Datos/03_Listos/`.
  - Series macro en `01_Datos/03_Listos/`, y `macro_por_reunion.rds` con las
    205 reuniones alineadas.
- **Fecha de corte:** 2014-10-30. Alternativas: 2014-09-26 y 2014-12-19. En
  la ventana de 5 años: 54 y 53 comunicados, 59 y 53 minutas.
- **Resultados:**
  - exploratorios (01 a 05), macro (07), antes/después por diccionario (09) y
    LDA (08). Mapa completo en `README.md`.
  - LDA, peso medio por reunión antes → después (pp, comunicados / minutas):
    - suben: déficit externo (+14,1 / +9,4), inflación por depreciación
      (+10,8 / +2,0, matizada en minutas) y decisión y postura
      (+2,8 / +18,4, matizada);
    - bajan: economía mundial, inflación básica frente a la meta, actividad,
      crédito y liquidez.
- **Notas:** doce notas en `05_Notas/`, cuatro de ellas de `08_lda_oraciones/`.
  La del sector externo se matizó: el LDA y el diccionario coinciden en la
  dirección antes/después y, reunión a reunión, solo en las minutas.
- **Plan:** `PLAN.md` con H1, H2, H3a (LDA) y H3b (`09`) terminados. Siguen
  H3c (Word2Vec, sin registrar), H3d (robustez; falta solo `10`) y H4.
- **Reglas:** el catálogo registra `pdftools`, `gt` y `readxl`; `widyr` está
  en el `p_load()`. Word2Vec sigue sin registrar.
- **Git:** el trabajo del LDA está en `SantiagoMunozM` y el de `09` en
  `SamuelEscandonC` (mergeado a `main` en el PR #6); `SantiagoMunozM` no está
  mergeado a `main`.

## Registro de sesiones

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
