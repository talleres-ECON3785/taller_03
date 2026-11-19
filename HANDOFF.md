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

1. **Cerrar el diseño de la pregunta fijada el 2026-11-18** («¿Cómo cambiaron
   los temas de interés de la Junta antes y después de la crisis del petróleo
   de 2014?»; método previsto: GloVe o Word2Vec).
   - Archivos: entrada en "Registro de ampliaciones" de
     `07_Recursos/catalogo_metodos.md` y fila en "Decisiones tomadas" de
     `CLAUDE.md`, con el paquete, la función y la aprobación del equipo; fecha
     de corte antes/después y tipo de documento.
   - *Terminado cuando:* los embeddings están registrados como ampliación, y el
     corte y el tipo de documento están decididos antes de ver resultados.
2. **`PLAN.md` y alineación de las series macro.**
   - Archivos: `PLAN.md` con hitos y tareas `Pk.n`; la regla de alineación
     (último dato publicado a la fecha de la reunión) escrita en `CLAUDE.md`;
     lista de series que entran (Brent, TRM, inflación; la tasa de cambio real
     es complemento).
   - *Terminado cuando:* cada análisis del plan usa una herramienta del
     catálogo o una ampliación registrada, y está confirmado desde qué fecha se
     conoce cada valor de la TRM y si alguna reunión cae en un día sin Brent.
3. **Validar a mano la votación**, si el equipo decide que sigue siendo
   relevante para la nueva pregunta.
   - Archivo: `03_Resultados/Tablas/04_bigramas/conjunto_votacion_muestra_validacion.csv`
     con las columnas de revisión llenas (30 documentos) y la nota
     `05_Notas/04_bigramas/T_votacion_minuta_vs_comunicado.md` actualizada.
   - *Terminado cuando:* están revisados los 30 documentos.

**Bloqueos y preguntas abiertas:**

- Roles de los integrantes en el Taller 3.
- Corpus pequeño (unas 177 mil palabras limpias) para entrenar embeddings y
  partirlo en dos épocas; los cambios de formato de las minutas pueden
  confundirse con cambio de temas.
- Fecha de la retroalimentación a compañeros (no afecta el repositorio).
- La clasificación de la votación y la dirección de la minoría son
  automáticas y no están validadas; la dirección no es codificable en 35 de
  las 101 reuniones decididas por mayoría, casi todas antes de 2016.
- Parte del aumento de las decisiones por mayoría puede ser un cambio en cómo
  se redacta la minuta (ver la nota de votación).
- Solo 31 minutas traen su fecha de publicación (rezago mediano de 14 días);
  para las demás hay que suponerlo o consultarlo.
- El LDA con la minuta entera como documento separa épocas y formatos, no
  temas: si la pregunta necesita temas, hay que bajar a párrafo u oración.
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

- **Pipeline:** `00_main.R` corre desde cero sin errores (unos 5 minutos; 3
  si ya existe la anotación de `udpipe`). Carga los paquetes con `pacman`,
  crea las carpetas y ejecuta seis scripts. Requiere Chrome para exportar las
  tablas e internet la primera vez.
- **Scripts:** `00_formato_graficas.R`, `00_formato_tablas.R` y
  `00_funciones_texto.R` (periodos, formatos de minuta, diccionario de
  compuestos, palabras vacías, grupos temáticos); `01_extraer_texto.R`,
  `02_limpiar_texto.R`, `03_frecuencias_tfidf.R`, `04_bigramas.R` y
  `05_lda_exploratorio.R` y `06_series_macro.R`.
- **Datos:** 393 documentos (194 comunicados y 199 minutas), todos con texto
  extraíble. `01_Datos/02_Procesados/corpus_texto.rds` tiene el texto limpio,
  el texto de la discusión de la Junta, el formato de cada minuta y el
  periodo; `01_Datos/03_Listos/` tiene los tokens limpios (176.622) y el vocabulario.
  Series macro desde 2000 en `01_Datos/03_Listos/`: `macro_brent.rds` (6.511
  días), `macro_inflacion.rds` y `macro_tcr.rds` (322 meses, hasta 2026-10),
  y `macro_trm.rds` (TRM diaria, 9.820 días, hasta 2026-11-19), sin transformar
  ni alinear con las reuniones. Sus crudos están en `01_Crudos/` y documentados
  en el README.
- **Lo que se sabe del corpus:** las minutas tienen cinco formatos (cortes en
  2014-05-30, 2019-06-21, 2020-07-31 y 2023-03-30) y hasta abril de 2019 solo
  27 a 30 % del texto es discusión de la Junta; hay diez periodos de política
  monetaria definidos a priori; 188 reuniones tienen los dos documentos.
- **Resultados:** todos exploratorios, sin cruce con macro. Mapa completo en
  `README.md`. Tres notas en `05_Notas/` (estructura de la minuta, inflación
  como validación de las medidas, votación).
- **Pregunta:** fijada el 2026-11-18 (temas de la Junta antes y después de la
  crisis del petróleo de 2014), con embeddings previstos pero sin registrar.
- **Reglas:** `CLAUDE.md` tiene la pregunta y las decisiones; las de la
  exploración (scripts 01 a 05) siguen siendo provisionales. El catálogo
  registra `pdftools`, `gt` y `readxl`.
- **Git:** trabajo en la rama `SantiagoMunozM`, con los cambios de `main` hasta
  el PR #2 de Samuel. Los cambios de la sesión del 2026-11-18 se suben a esa
  rama.

## Registro de sesiones

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
