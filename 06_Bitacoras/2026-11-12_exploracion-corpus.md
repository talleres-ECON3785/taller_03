# Bitácora — 2026-11-12: base del pipeline y exploración del corpus

Sesión de Samuel Escandón, rama `SamuelEscandonC`, del 10 al 12 de noviembre
de 2026.

## Resumen

Objetivo: conocer el corpus (palabras frecuentes, vocabulario distintivo por
época y por tipo de documento, bigramas, votaciones y tópicos preliminares)
para elegir la pregunta del taller con evidencia. **No se cruzó el texto con
series macroeconómicas**: ese cruce se hace después de fijar la pregunta, para
no elegir la medida mirando con qué serie se correlaciona.

Desarrollo:

1. Se creó la rama `SamuelEscandonC` desde `origin/main` y se presentó un plan
   (scripts, periodos a priori, diccionario, palabras vacías, tratamiento de
   cifras) que el usuario aprobó con ajustes.
2. Base del pipeline: `00_main.R`, los dos scripts de formato traídos del
   Taller 2 y `00_funciones_texto.R`.
3. Cinco scripts de análisis (`01` a `05`), el README y tres notas de
   hallazgos.
4. Revisión visual de las figuras y tablas que sostienen los hallazgos,
   validación de la versión de la minuta usada y una tabla para validar a mano
   la votación.

Frente a los "Siguientes objetivos" que traía `HANDOFF.md`:

- **(1) Definir la pregunta y las series macro:** avanzó, no se cerró. Hay
  evidencia exploratoria y una pregunta candidata; falta acordarla con el
  equipo.
- **(2) `PLAN.md` y ampliaciones del catálogo:** las ampliaciones (`pdftools`,
  `gt`) quedaron registradas; `PLAN.md` no se creó porque depende de la
  pregunta.
- **(3) `00_main.R`, formato y extracción de texto:** cumplido. `00_main.R`
  corre desde cero sin errores (5 minutos; 3 si ya existe la anotación) y la
  base tiene 393 documentos.

## Archivos

- Creados:
  - `00_main.R`, `README.md`
  - `02_Scripts/00_formato_graficas.R`, `00_formato_tablas.R`,
    `00_funciones_texto.R`
  - `02_Scripts/01_extraer_texto.R`, `02_limpiar_texto.R`,
    `03_frecuencias_tfidf.R`, `04_bigramas.R`, `05_lda_exploratorio.R`
  - `01_Datos/02_Procesados/texto_crudo.rds`, `corpus_texto.rds`,
    `secciones_minutas.rds`, `decisiones_reunion.rds` (y, sin versionar, el
    modelo de `udpipe` y `anotado_udpipe.rds`)
  - `01_Datos/03_Listos/tokens_anotados.rds`, `tokens_limpios.rds`,
    `vocabulario_lda.rds`
  - `03_Resultados/Tablas/` y `Figuras/` de los cinco scripts (ver el mapa del
    README)
  - `05_Notas/README.md` y tres notas (ver "Resultados nuevos")
  - Esta bitácora
- Modificados: `CLAUDE.md`, `HANDOFF.md`, `07_Recursos/catalogo_metodos.md`,
  `.gitignore`
- Eliminados: ninguno.

## Detalle por archivo

### `00_main.R`
Estructura de `CLAUDE.md`: verifica la raíz (un `.Rproj` y `02_Scripts/`),
carga los paquetes con un único `pacman::p_load()`, crea las carpetas de
salida, lista los cinco scripts y los ejecuta con
`source(..., local = new.env())`. Además mide el tiempo de cada script.
Paquetes: `tidyverse`, `pdftools`, `tidytext`, `stopwords`, `stringi`,
`udpipe`, `tm`, `topicmodels`, `gt`.

### `02_Scripts/00_formato_graficas.R` y `00_formato_tablas.R`
Traídos del Taller 2 (la carpeta está en
`Ciencia de datos y Econometría aplicada/taller_02/`, no al lado de
`taller_03/`). Cambios:

- Subtítulos por fuente (comunicados, minutas, ambos) en lugar de experimento
  y datos históricos; comunicados en azul y minutas en ocre en todas las
  figuras.
- `capa_cortes_formato()`: líneas verticales punteadas en los cortes de formato
  de las minutas.
- `guardar_figura()` parte la nota al pie en renglones según el ancho de la
  figura. Sin esto, las notas largas se cortaban en el borde derecho (se vio en
  la revisión visual).
- Tablas: decimales por tipo de cifra de texto (por 1.000 palabras, razón,
  TF-IDF, θ), `nota_tabla()` con fuente, periodo y n de documentos, y un guion
  que no permite salto de renglón entre cifras, para que las fechas no se
  partan dentro de la celda.

### `02_Scripts/00_funciones_texto.R`
Define una sola vez lo que comparten los scripts: `sin_tilde()`,
`con_tildes()`, `partir_oraciones()`, los periodos, los formatos de minuta, el
diccionario de compuestos, `unificar_tasas()`, las palabras vacías y los
grupos temáticos de palabras.

**Periodos (definidos a priori).** Cada periodo lo abre la primera reunión
cuya decisión cambia la dirección de la tasa; se verificó contra la decisión
que anuncia el comunicado. P1 2007-01-26, P2 2008-12-19, P3 2011-02-25, P4
2014-09-26, P5 2016-12-16, P6 2020-03-27, P7 2021-09-30, P8 2023-12-19, P9
2025-06-27 y P10 2026-01-30. Frente al plan inicial cambiaron P2 (era
2008-09), P3 (era 2011-01), P4 (era 2014-07) y P6. P4 es el único de P1 a P8
que abre con una pausa: no hay una decisión de tasa que marque el choque
petrolero. P6 se cita de la minuta porque los datos no traen comunicados entre
2020-01-31 y 2020-05-29. Por pedido del usuario, el antiguo P8 se partió en
recortes (P8), pausa (P9) y alzas de 2026 (P10). La regla quedó en "Decisiones
tomadas".

**Diccionario de compuestos.** Unas 75 expresiones, aplicadas de la más larga
a la más corta, más siglas con patrón propio («pb», «p.b.», «TES», «Fed», «EE.
UU.», «PIB», «IPC», «covid»). «pb» solo cuenta como palabra completa: de 880
apariciones, 792 van después de una cifra, 80 entre paréntesis y las 8
restantes son «(pb.)» o comienzos de oración; todas son puntos básicos.

**La tasa del Banco** (`unificar_tasas()`):

- «tasa de [interés de] intervención» y «tasa de [interés de] política
  [monetaria]» se unen en `tasa_intervencion`.
- Cualquier variante seguida de un banco central externo pasa a
  `tasa_externa`. Se agregó porque «tasa de política» también es ambigua: 9 a
  15 % de sus menciones está en una oración con un referente externo.
- «tasa de referencia» queda como token aparte. La regla se fijó antes de
  contar: unirlas solo si menos de 10 % tenía un referente externo en la
  oración; resultó 31 % (22 % en comunicados, 38 % en minutas).

**Palabras vacías.** Las de *snowball* en español e inglés, una lista de
dominio de procedimiento y calendario fijada antes de ver las frecuencias, los
numerales romanos de las enumeraciones «(i)… (vi)» y los nombres propios del
preámbulo de las minutas. Criterio de ampliación: estar en 90 % o más de los
documentos de un tipo y ser de procedimiento. Ninguna de las 23 candidatas lo
cumplía (todas describen el entorno o la decisión), así que la lista no se
amplió.

**Grupos temáticos.** Seis listas de lemas fijadas a priori (inflación,
actividad, entorno externo, mercado laboral, fiscal, riesgo e incertidumbre).
Fuente: elaboración propia a partir del vocabulario de los documentos; es un
conteo de palabras (catálogo, sección 2), no un modelo. Rol: seguir la
atención a cada tema en el tiempo y contrastarla con episodios conocidos.

### `02_Scripts/01_extraer_texto.R`
- Extrae el texto de los 393 PDF con `pdftools::pdf_text()`. Ningún PDF queda
  sin texto y no hay avisos. Reutiliza `texto_crudo.rds` si existe.
- Limpieza, con cada línea eliminada guardada en
  `conjunto_lineas_eliminadas.csv`: números de página, encabezados y pies
  («Banco de la República - Comunicado de la Junta Directiva», «Fecha de
  publicación», «Fuente: https…»), restos de la página web de las minutas de
  2012 a 2019 («Anexo estadístico», «Contenidos relacionados», «Última
  modificación»), títulos duplicados y guiones de fin de línea (6 uniones).
  Mediana de palabras: comunicados, 492 → 449; minutas, 1.657 → 1.600.
- Los encabezados de sección se buscan en todo el texto y no por línea, porque
  en algunos PDF quedaron pegados al párrafo anterior.
- Separa las minutas en preámbulo, equipo técnico, discusión y decisión, y
  clasifica el formato. Verifica que los cinco formatos sean contiguos y
  empiecen en las fechas de `00_funciones_texto.R`; si no, se detiene.
- Dos versiones del texto de la minuta: completo y solo la discusión de la
  Junta. La segunda es la que importa para la pregunta.
- Clasifica la decisión de cada reunión (alza, recorte, sin cambio) con la
  cita: 53 alzas, 45 recortes y 107 sin cambio en 205 reuniones.
- **Fechas en el texto.** Los 131 comunicados con «Fecha de publicación»
  coinciden con el nombre del archivo. 31 minutas cierran con ciudad y fecha;
  el rezago frente a la reunión es de 14 días (mediana; 12 a 17). Esto corrige
  lo que decía `CLAUDE.md`.

### `02_Scripts/02_limpiar_texto.R`
Sigue la sección 5 del catálogo: compuestos, lemas con `udpipe`
(`spanish-gsd`), filtro gramatical, palabras vacías, dígitos y tokens de un
carácter. Se anota por sección, para tener las dos versiones de la minuta sin
anotar dos veces. El modelo y la anotación se guardan en `02_Procesados/` y no
se versionan (pesan y se regeneran).

Tokens que quedan, como porcentaje de los anotados: comunicados, 84.942 →
41 %; minutas (texto completo), 365.802 → 40 %; minutas (discusión de la
Junta), 152.078 → 41 %. Casi toda la pérdida es el filtro gramatical (se
conserva 44 %). El preámbulo de asistentes no entra a ningún análisis.

**Cifras:** los tokens con dígitos se eliminan y las cifras no se extraen.

**Recorte de vocabulario para LDA.** Los umbrales del laboratorio (5 documentos
y 25 %) dejan por fuera el vocabulario central y conservan 30 % de los tokens
de la discusión de la Junta. Se propone 5 documentos y 75 %: 1.168 términos y
80 % de los tokens; aun así quedan fuera «inflacion», «tasa_intervencion»,
«crecimiento», «expectativas_inflacion», «politica_monetaria», «economia» y
«precio». Es una propuesta, no una elección validada.

### `02_Scripts/03_frecuencias_tfidf.R`
Frecuencias por cada 1.000 palabras del texto, TF-IDF con el periodo como
grupo dentro de cada tipo (filtro de 8 apariciones), minutas frente a
comunicados en las 188 reuniones con los dos documentos, atención a los seis
temas por año y nombre de la tasa por periodo. Con 2 grupos el TF-IDF no
ordena las palabras compartidas; por eso la comparación usa la razón de
frecuencias normalizadas.

### `02_Scripts/04_bigramas.R`
- Bigramas: pares contiguos en la misma oración con las dos palabras en el
  vocabulario limpio.
- **Votación.** Se busca sobre el texto extraído, en comunicados y minutas, en
  las oraciones que hablan de la decisión. Medida: clasificación del documento
  en unanimidad, mayoría o sin información según expresiones. Fuente:
  elaboración propia. Rol: es la información que la minuta agrega al
  comunicado.
- **Dirección de la minoría.** Se lee la decisión como un cambio en puntos
  básicos con signo y, en las oraciones de votación, las alternativas
  mencionadas; las distintas de la decisión son los votos de la minoría. Más
  restrictiva: una tasa más alta que la decidida; más expansiva: más baja;
  mixta: a los dos lados. Es automática y está pendiente de validación.
- Expresiones de desacuerdo por año y por formato.

### `02_Scripts/05_lda_exploratorio.R`
Solo minutas, K = 6 y K = 10, sin selección de hiperparámetros. **Desviación
de lo previsto:** el LDA por defecto (VEM) estimó α = 114,3 (K = 6) y 87,7
(K = 10) y dejó θ cerca de 1/K en todas las minutas. Se agregó el LDA con
Gibbs y los valores del Lab 12 (α = 0,1, δ = 1), no elegidos para este corpus.
Los tópicos no se nombran. El fragmento de cada documento representativo es la
oración del texto original cuyas palabras más pesan en el tópico.

### `CLAUDE.md`, `07_Recursos/catalogo_metodos.md`, `.gitignore`
- "Decisiones tomadas": ampliación del catálogo, decisiones provisionales de
  la sesión, regla de las fronteras de periodo, LDA con Gibbs como desviación
  y `tasa_externa`.
- "Datos": fecha de publicación de las minutas (31 la traen, rezago de 14
  días), cortes de formato ubicados y 11 minutas sin comunicado.
- Se quitaron las marcas de pendiente de `00_main.R`, los scripts de formato y
  el README.
- Catálogo: `pdftools` y `gt` en el "Registro de ampliaciones".
- `.gitignore`: el modelo de `udpipe` y la anotación.

## Resultados nuevos (tablas, figuras, gráficos)

El mapa completo está en el README. Con nota de hallazgo:

- **Estructura de la minuta** (`minutas_cortes_formato.png`,
  `minutas_palabras_por_seccion.png`):
  [05_Notas/01_extraer_texto/T_estructura_minuta.md](../05_Notas/01_extraer_texto/T_estructura_minuta.md).
- **La inflación sigue los episodios** (`conjunto_temas_por_anio.png`):
  [05_Notas/03_frecuencias_tfidf/T_inflacion_sigue_episodios.md](../05_Notas/03_frecuencias_tfidf/T_inflacion_sigue_episodios.md).
- **Votación** (`conjunto_votacion_*`, `conjunto_minoria_por_anio.png`):
  [05_Notas/04_bigramas/T_votacion_minuta_vs_comunicado.md](../05_Notas/04_bigramas/T_votacion_minuta_vs_comunicado.md).

Exploratorios, sin nota por decisión del usuario:

- **Vocabulario propio de la minuta** (`conjunto_minutas_vs_comunicados.png`).
  Busca mostrar qué palabras pesan más en la minuta que en el comunicado de la
  misma reunión. Versión usada: la discusión de la Junta (la tabla trae al
  lado el texto completo). «Revaluación»: 28 apariciones en la discusión de la
  Junta y 0 en comunicados; por sección, 17 en «Discusión» (formatos A y B), 11
  en el cuerpo del formato E y 1 en el equipo técnico: viene de la Junta. Por
  año se concentra en 2008 (10) y 2025–2026 (10). «Preocupación»: 59 en la
  Junta y 1 en comunicados; hay 8 más en el equipo técnico, que no entran;
  50 de las 59 son de 2019 en adelante. «Salario mínimo»: 52 y 3; 43 de las 52
  están en el formato E (desde 2023). El resto de la lista son verbos de
  atribución («resaltar», «anotar», «advertir»).
- **Vocabulario laboral y fiscal desde 2021** (`conjunto_tfidf_por_periodo.png`,
  `conjunto_temas_por_periodo.png`): «salario_minimo» está entre las palabras
  de mayor TF-IDF de P8 a P10 en las minutas. Cifras pequeñas y coincidentes
  con el formato E.
- **Nombre de la tasa** (`conjunto_nombres_tasa_por_periodo.png`):
  «intervención» tiene 61 menciones en comunicados de P5 y 0 desde P7.
- **LDA** (`minutas_gibbs_k*`, `minutas_vem_k*`,
  `minutas_lda_extension_por_formato.png`): con Gibbs y K = 6 cada tópico es
  casi un periodo (0,88 y 0,93 en P1 y P2; 0,84 en P3; 0,81 en P4; 0,78 a 0,92
  en P7 a P10) y sus palabras propias son de redacción. Con la minuta entera
  como documento, el modelo separa épocas y formatos, no temas.

Correcciones de la revisión visual: notas al pie de las figuras partidas en
renglones; fechas que ya no se parten en las tablas; eje de la figura de
votación en enteros; tabla de periodos con la cita en una columna ancha.
También se corrige un dato del informe en el chat: comunicado y minuta se
contradicen en 1 reunión, no en 2.

Limitaciones vistas: algunos lemas de `udpipe` son erróneos («disminuyr»,
«concuerdar», «llevandola»); no cambian los conteos de los temas, pero
aparecen en las tablas de TF-IDF.

## Pendientes

- **Fijar la pregunta con el equipo.** Candidata: si la dirección del voto de
  la minoría y los argumentos de la minuta anticipan la siguiente decisión más
  allá de la inflación y las expectativas. No está registrada en "Decisiones
  tomadas".
- **Validación manual de la votación:** revisar los 30 documentos de
  `conjunto_votacion_muestra_validacion.csv`. La dirección de la minoría no es
  codificable en 35 de las 101 reuniones por mayoría, casi todas antes de
  2016; el conteo de votos solo se leyó en 36 documentos.
- Series macro y `PLAN.md`, una vez fijada la pregunta.
- Unidad de análisis para medir temas (párrafo u oración).
- En los formatos D y E, separar los párrafos de contexto que repiten el
  comunicado de la discusión de los directores.
- Decisiones provisionales por revisar: recorte de vocabulario (5 documentos y
  75 %), verbos de atribución, cifras sin extraer, candidatos al diccionario
  (`conjunto_bigramas_candidatos.png`).
- Supuesto sin confirmar: que el rezago de 14 días de las 31 minutas con fecha
  vale para las demás.
- Varios nombres de archivo se acortaron porque, dentro de la carpeta de
  trabajo de esta sesión, las rutas superaban el límite de Windows.
