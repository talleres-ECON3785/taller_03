# Bitácora — 2026-11-18: plan de implementación

## Resumen

Sesión de Santiago Muñoz Martínez (rama `SantiagoMunozM`). Objetivo: escribir
el plan de implementación de los pasos que siguen para responder la pregunta
del taller («¿Cómo cambiaron los temas de interés de la Junta antes y después
de la crisis del petróleo de 2014?»).

El usuario fijó los puntos del plan: gráficas de las series macro, definición
de la fecha de inicio de la crisis, embeddings antes y después (ventana en
años y elección entre GloVe y Word2Vec) e interpretación frente a la historia
macro. En una primera versión la fecha de corte iba antes de las gráficas; el
usuario pidió invertir el orden: primero las gráficas macro con una
exploración descriptiva breve y, con base en ellas, el punto de corte. El plan
quedó en `PLAN.md` (raíz), con hitos H1 a H4 y tareas `Pk.n`, como pide
`CLAUDE.md`.

Frente a los "Siguientes objetivos" del handoff: se cumplió la parte de
`PLAN.md` del objetivo 2; la regla de alineación queda como tarea P1.4. El
objetivo 1 (registrar embeddings, corte, tipo de documento) no se cerró: quedó
ordenado en el plan (H2 y P3.1–P3.2). El objetivo 3 (validar la votación) no
se trabajó y no entra al plan.

No se escribió código ni se generaron resultados.

## Archivos

- Creados: `PLAN.md`; `06_Bitacoras/2026-11-18_plan-implementacion.md`.
- Modificados: `HANDOFF.md`; `CLAUDE.md` (la referencia a `PLAN.md` deja de
  decir "pendiente: crearlo").
- Eliminados: ninguno.

## Detalle por archivo

### `PLAN.md`

Cuatro hitos, en el orden pedido por el usuario:

- **H1. Gráficas macro y exploración descriptiva breve** (P1.1–P1.5). Script
  nuevo `07_graficas_macro.R`: Brent, TRM e inflación (núcleo 15 frente a la
  meta de 3 %) de 2007 a 2026, con el sombreado de los periodos de
  `00_formato_graficas.R`; tabla descriptiva por periodo P1–P10 (media,
  mínimo, máximo, variación) y fechas de pico y valle; regla de alineación
  (último dato publicado a la fecha de la reunión); nota `M_*` en `05_Notas/`.
  Intuición: ver primero los datos que cuentan la historia y, con ellos,
  decidir cuándo empieza la crisis.
- **H2. Fecha de inicio de la crisis** (P2.1–P2.3). Se fija con las series de
  H1 y antes de ver cualquier embedding, para que el corte no se elija por lo
  que muestre el texto. Candidato: 2014-09-26, que abre el periodo P4 (fijado
  a priori el 2026-11-10) y es la primera reunión de política tras el pico del
  Brent de mediados de 2014; se confirma contra las fechas de P1.3. Salvedad
  anotada: las minutas pasan del formato A al B el 2014-05-30, cerca del
  corte, lo que puede confundir cambio de formato con cambio de temas.
- **H3. Embeddings antes y después** (P3.1–P3.3).
  - Ventana recomendada (por decidir con el equipo): 5 años a cada lado del
    corte (2009-09-26 a 2014-09-25 y 2014-09-26 a 2019-09-25), simétrica y
    sin la crisis de 2008 ni la pandemia. Alternativa: todo desde 2007 antes y
    hasta 2020-03 después. Se cuentan documentos y tokens por época antes de
    entrenar.
  - Método recomendado (por decidir): Word2Vec skip-gram con el paquete
    `word2vec`, porque en corpus pequeños suele dar vecinos más estables que
    GloVe. Especificación inicial: dimensión 50–100, ventana 5, frecuencia
    mínima 5, `set.seed(2026)` y un solo hilo para que sea reproducible.
    Unidad: oración; documento principal: minutas, versión «solo discusión de
    la Junta», con comunicados como chequeo.
  - Debe registrarse como ampliación del catálogo antes de correrse.
  - Medida prevista: vecinos más cercanos de palabras ancla fijadas antes
    (`petroleo`, `inflacion`, `tasa_cambio`, `tasa_intervencion`, etc.) en
    cada época y su solapamiento (Jaccard sobre los 10 primeros), repetido con
    cinco semillas; como complemento del catálogo, la frecuencia relativa de
    las anclas por 1.000 palabras.
- **H4. Interpretación** (P4.1–P4.5): cruzar los cambios de vecinos con la
  historia macro, sustentarlos con fragmentos de los documentos, descartar el
  efecto de formato y armar el deck. Relación asociativa, no causal.

El plan cierra con riesgos (corpus pequeño, corte cercano al cambio de
formato, cuatro días hasta la entrega) y verificación (`00_main.R` desde cero,
`stopifnot()` en los scripts nuevos, README actualizado).

### `HANDOFF.md`

Objetivos reescritos a partir de los primeros pasos del plan; estado actual y
registro de sesiones actualizados.

### `CLAUDE.md`

En la sección "`HANDOFF.md`", la línea del plan de implementación ya no lo
marca como pendiente de crear.

## Pendientes

- H1 completo (P1.1–P1.5): script `07_graficas_macro.R`, figuras, tabla
  descriptiva, regla de alineación y nota.
- H2: fijar y registrar el corte con base en H1.
- Decisiones del equipo sin tomar: ventana (5 + 5 años o la alternativa) y
  Word2Vec frente a GloVe; luego registrar la ampliación en el catálogo.
- La validación manual de la votación queda fuera del plan; decidir si se
  abandona.
