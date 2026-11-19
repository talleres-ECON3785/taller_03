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

1. **Fijar la pregunta del taller con el equipo.**
   - Candidata (todavía no registrada en "Decisiones tomadas"): si la
     dirección del voto de la minoría y los argumentos de la minuta anticipan
     la siguiente decisión de tasa más allá de la inflación y las expectativas.
   - Archivo: fila nueva en "Decisiones tomadas" de `CLAUDE.md` con la
     pregunta, y tabla "Definición de variables" con cada serie macro (por
     qué, fuente con URL, cobertura, frecuencia, transformaciones).
   - *Terminado cuando:* la pregunta es una sola oración que la mesa de renta
     fija entendería, el equipo la aprobó y cada serie tiene fuente con URL.
   - Insumos: las tres notas de `05_Notas/` y la bitácora del 2026-11-12.
2. **Validar a mano la votación.**
   - Archivo: `03_Resultados/Tablas/04_bigramas/conjunto_votacion_muestra_validacion.csv`
     con las columnas de revisión llenas (30 documentos), y la nota
     `05_Notas/04_bigramas/T_votacion_minuta_vs_comunicado.md` actualizada con
     el porcentaje de aciertos de la clasificación y de la dirección de la
     minoría.
   - *Terminado cuando:* están revisados los 30 documentos y, si la tasa de
     error lo pide, se corrigieron las expresiones de `04_bigramas.R` o se
     decidió codificar a mano las reuniones por mayoría (101).
3. **`PLAN.md` y series macro**, una vez fijada la pregunta.
   - Archivos: `PLAN.md` con hitos y tareas `Pk.n`; series en
     `01_Datos/01_Crudos/` (o su script de descarga) y filas en el "Registro de
     ampliaciones" del catálogo para lo que haga falta.
   - *Terminado cuando:* cada análisis del plan usa una herramienta del
     catálogo o una ampliación registrada, y la regla de alineación temporal
     entre reuniones y series está escrita.
   - Ya hay tres archivos crudos sin documentar en `01_Datos/01_Crudos/` (Brent,
     inflación anual, tasa de cambio real): registrar su fuente y cobertura en
     "Definición de variables" y en el README.

**Bloqueos y preguntas abiertas:**

- Roles de los integrantes en el Taller 3.
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
- Tres archivos sin versionar en `01_Datos/01_Crudos/` (`brent_2000-26.csv`,
  `inflacion_variacion_anual_99_26.xlsx`, `tasa_cambio_real_70_26.xlsx`):
  falta documentar su fuente, fecha de consulta y cobertura antes de usarlos.
- Qué pipe usa el equipo: el proyecto usa `%>%`, pero un formateador de
  VS Code (hay un `.lintr` sin versionar) lo cambia a `|>` y rompe
  `con_tildes()`. Hay que desactivar esa opción o acordar la convención.

## Estado actual

- **Pipeline:** `00_main.R` corre desde cero sin errores (unos 5 minutos; 3
  si ya existe la anotación de `udpipe`). Carga los paquetes con `pacman`,
  crea las carpetas y ejecuta cinco scripts. Requiere Chrome para exportar las
  tablas e internet la primera vez.
- **Scripts:** `00_formato_graficas.R`, `00_formato_tablas.R` y
  `00_funciones_texto.R` (periodos, formatos de minuta, diccionario de
  compuestos, palabras vacías, grupos temáticos); `01_extraer_texto.R`,
  `02_limpiar_texto.R`, `03_frecuencias_tfidf.R`, `04_bigramas.R` y
  `05_lda_exploratorio.R`.
- **Datos:** 393 documentos (194 comunicados y 199 minutas), todos con texto
  extraíble. `01_Datos/02_Procesados/corpus_texto.rds` tiene el texto limpio,
  el texto de la discusión de la Junta, el formato de cada minuta y el
  periodo; `01_Datos/03_Listos/` tiene los tokens limpios (176.622) y el vocabulario.
  Aún no hay series macro versionadas (hay tres archivos crudos sin documentar
  en `01_Crudos/`, ver bloqueos).
- **Lo que se sabe del corpus:** las minutas tienen cinco formatos (cortes en
  2014-05-30, 2019-06-21, 2020-07-31 y 2023-03-30) y hasta abril de 2019 solo
  27 a 30 % del texto es discusión de la Junta; hay diez periodos de política
  monetaria definidos a priori; 188 reuniones tienen los dos documentos.
- **Resultados:** todos exploratorios, sin cruce con macro. Mapa completo en
  `README.md`. Tres notas en `05_Notas/` (estructura de la minuta, inflación
  como validación de las medidas, votación).
- **Reglas:** `CLAUDE.md` tiene las decisiones de la sesión (provisionales
  hasta fijar la pregunta); el catálogo registra `pdftools` y `gt`.
- **Git:** trabajo en la rama `SantiagoMunozM`, con los cambios de `main` hasta
  el PR #2 de Samuel. Los cambios de la sesión del 2026-11-18 se suben a esa
  rama.

## Registro de sesiones

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
