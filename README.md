# Taller 3: ¿De qué habla la Junta del Banco de la República?

Ciencia de Datos y Econometría Aplicada (ECON-3785, 2026-2), Universidad de los
Andes. Integrantes: Samuel Escandón, Douglas Plazas Guzmán, Mateo Olmos Becerra
y Santiago Muñoz Martínez.

## Objetivo

El cliente es la mesa de renta fija de un fondo de inversión, que sigue los
comunicados y las minutas de la Junta Directiva del Banco de la República para
interpretar las decisiones de política monetaria. El taller analiza esos
documentos con las herramientas de texto del curso para mostrar qué patrones
tiene la comunicación de la Junta, cómo cambian en el tiempo y cómo se
relacionan con el contexto macroeconómico.

**Estado:** el repositorio contiene la base del pipeline y una exploración del
corpus (palabras frecuentes, vocabulario distintivo, bigramas, votaciones y
tópicos preliminares). La pregunta del taller todavía no está fijada y aún no
se cruzan los textos con series macroeconómicas. Todos los resultados actuales
son exploratorios.

## Cómo ejecutar

Basta con correr `00_main.R` con el directorio de trabajo en la raíz del
proyecto (abrir `taller_03.Rproj` y ejecutar `source("00_main.R")`, o
`Rscript 00_main.R` desde la raíz).

- `00_main.R` instala y carga todos los paquetes con `pacman`, crea las
  carpetas de salida y ejecuta los scripts en orden. No hay que instalar nada a
  mano.
- Borrar `03_Resultados/`, `01_Datos/02_Procesados/` y `01_Datos/03_Listos/` y
  volver a correr `00_main.R` regenera todo.
- Requisitos externos: conexión a internet la primera vez (para instalar
  paquetes y descargar el modelo `spanish-gsd` de `udpipe`, unos 28 MB) y
  Google Chrome o Chromium (para exportar las tablas a `.png`; si está en una
  ruta no estándar, definir la variable de entorno `CHROME_PATH`).
- Tiempo de la corrida completa desde cero: unos 5 minutos (3 si ya existe
  la anotación). La anotación con
  `udpipe` (unos 4 minutos) y la extracción de los PDF se guardan en
  `01_Datos/02_Procesados/` y se reutilizan en las corridas siguientes.
- Para correr un script suelto, primero ejecutar las secciones 1 a 3 de
  `00_main.R`.

## Estructura de carpetas

| Carpeta | Contenido |
| --- | --- |
| `01_Datos/01_Crudos/` | Datos originales; nunca se modifican. `Comunicados_Minutas_Banrep/` tiene los PDF de la Junta |
| `01_Datos/02_Procesados/` | Texto extraído y limpio, modelo y anotación de `udpipe` (se generan con `00_main.R`) |
| `01_Datos/03_Listos/` | Tokens limpios y vocabulario que entran al análisis (se generan con `00_main.R`) |
| `02_Scripts/` | Scripts de R |
| `03_Resultados/` | `Tablas/` y `Figuras/`, con una subcarpeta por script |
| `04_Presentaciones/` | Borradores de la presentación |
| `05_Notas/` | Notas de hallazgos |
| `06_Bitacoras/` | Registro de cada sesión de trabajo |
| `07_Recursos/` | Enunciado, catálogo de métodos y heurísticas |
| `08_Entregables/` | Presentación final y video |
| `00_main.R` | Script maestro: único punto de entrada |

## Fuentes de los datos

**Documentos de la Junta** (dados por el curso, `Comunicados_Minutas_Banrep.zip`):

| Documento | Archivos | Cobertura | Notas |
| --- | --- | --- | --- |
| Comunicados | 194 PDF en `comunicados/` | 2007-01-26 a 2026-09-30 | Se publican el día de la reunión |
| Minutas | 199 PDF en `minutas/` | 2007-06-15 a 2026-09-30 | Fechadas con el día de la reunión; se publican unas dos semanas después |
| Informe técnico | `2020-04-30_informe_tecnico_mercados_capitales.pdf` | 2020-04-30 | Venía como minuta en el zip; no es una minuta y no se procesa |

- La fecha del nombre del archivo es la fecha de la reunión. 188 reuniones
  tienen los dos documentos.
- Hay 8 a 12 reuniones por año (11–12 hasta 2017 y 8 desde 2018).
- **Transformaciones** (`01_extraer_texto.R` y `02_limpiar_texto.R`): se extrae
  el texto con `pdftools`; se quitan números de página, encabezados, pies,
  restos de la página web y títulos; se unen las palabras partidas por guion a
  fin de línea; las minutas se separan en secciones (preámbulo, visión del
  equipo técnico, discusión, decisión); el preámbulo de asistentes no entra a
  ningún análisis; se unen términos compuestos, se
  lematiza con `udpipe` y se eliminan palabras vacías y tokens con dígitos
  (las cifras no se extraen).
- Las minutas cambian de formato en 2014-05-30, 2019-06-21, 2020-07-31 y
  2023-03-30. Hasta abril de 2019 incluyen una sección con la visión del equipo
  técnico; por eso cada medida se reporta con el texto completo y solo con la
  discusión de la Junta.

**Series macroeconómicas:** todavía no se han incorporado. Se elegirán y
documentarán (fuente, cobertura, frecuencia y transformaciones) cuando se fije
la pregunta.

## Mapa script → resultados

Los scripts `00_formato_graficas.R`, `00_formato_tablas.R` y
`00_funciones_texto.R` no generan resultados: definen el formato de figuras y
tablas, los periodos de política monetaria, el diccionario de términos
compuestos y las palabras vacías. Rutas relativas a `03_Resultados/`; cada
tabla con `.png` tiene además un `.csv` con las cifras.

### `01_extraer_texto.R`: extracción, limpieza y diagnóstico de formato

Datos: `01_Datos/02_Procesados/texto_crudo.rds`, `corpus_texto.rds`,
`secciones_minutas.rds`, `decisiones_reunion.rds`.

| Resultado | Contenido |
| --- | --- |
| `Tablas/01_extraer_texto/conjunto_resumen_extraccion.png` | Documentos leídos y extensión antes y después de limpiar |
| `Tablas/01_extraer_texto/conjunto_antes_despues.png` | Texto de tres documentos antes y después de la limpieza |
| `Tablas/01_extraer_texto/minutas_texto_eliminado.png` | Qué se quita en tres minutas de formatos distintos |
| `Tablas/01_extraer_texto/conjunto_lineas_eliminadas.csv` | Todas las líneas eliminadas de los 393 documentos |
| `Tablas/01_extraer_texto/conjunto_periodos.png` | Periodos a priori, con la reunión y la decisión que abre cada uno |
| `Tablas/01_extraer_texto/conjunto_decisiones_por_reunion.csv` | Dirección de la decisión de tasa en cada reunión, con la cita |
| `Tablas/01_extraer_texto/minutas_cortes_formato.png` | Formatos de las minutas y reunión en que cambia cada uno |
| `Tablas/01_extraer_texto/conjunto_metadatos_documentos.csv` | Metadatos de cada documento (formato, palabras por sección, fechas que trae el texto) |
| `Figuras/01_extraer_texto/conjunto_palabras_por_documento.png` | Palabras por documento en el tiempo, por tipo |
| `Figuras/01_extraer_texto/minutas_palabras_por_seccion.png` | Qué parte de cada minuta es discusión de la Junta |

### `02_limpiar_texto.R`: compuestos, lemas, palabras vacías y vocabulario

Datos: `01_Datos/02_Procesados/anotado_udpipe.rds` y el modelo de `udpipe`;
`01_Datos/03_Listos/tokens_anotados.rds`, `tokens_limpios.rds`,
`vocabulario_lda.rds`.

| Resultado | Contenido |
| --- | --- |
| `Tablas/02_limpiar_texto/conjunto_variantes_tasa.png` | Formas de nombrar la tasa de política y cuántas tienen un referente externo |
| `Tablas/02_limpiar_texto/conjunto_contextos_pb.csv` | Contextos de «pb» para verificar que siempre es «puntos básicos» |
| `Tablas/02_limpiar_texto/conjunto_tokens_por_paso.png` | Tokens que se pierden en cada paso de la limpieza |
| `Tablas/02_limpiar_texto/conjunto_compuestos_frecuencia.csv` | Frecuencia de cada término compuesto |
| `Tablas/02_limpiar_texto/conjunto_candidatas_vacias.png` | Palabras en 90 % o más de los documentos (candidatas a palabras vacías) |
| `Tablas/02_limpiar_texto/conjunto_umbrales_vocabulario.png` | Tamaño del vocabulario según los umbrales del recorte para LDA |

### `03_frecuencias_tfidf.R`: palabras frecuentes y vocabulario distintivo

| Resultado | Contenido |
| --- | --- |
| `Tablas/03_frecuencias_tfidf/conjunto_palabras_frecuentes.png` | Las 20 palabras más frecuentes por tipo de documento |
| `Figuras/03_frecuencias_tfidf/comunicados_frecuentes_periodo.png` | Palabras más frecuentes por periodo, comunicados |
| `Figuras/03_frecuencias_tfidf/minutas_frecuentes_periodo.png` | Ídem, minutas (discusión de la Junta) |
| `Figuras/03_frecuencias_tfidf/minutas_frecuentes_periodo_completo.png` | Ídem, minutas (texto completo) |
| `Figuras/03_frecuencias_tfidf/comunicados_tfidf_periodo.png` | Palabras distintivas de cada periodo (TF-IDF), comunicados |
| `Figuras/03_frecuencias_tfidf/minutas_tfidf_periodo.png` | Ídem, minutas (discusión de la Junta) |
| `Figuras/03_frecuencias_tfidf/minutas_tfidf_periodo_completo.png` | Ídem, minutas (texto completo) |
| `Tablas/03_frecuencias_tfidf/conjunto_tfidf_por_periodo.png` | Las 8 palabras distintivas de cada periodo, las tres versiones lado a lado |
| `Tablas/03_frecuencias_tfidf/conjunto_tfidf_periodo_detalle.csv` | TF-IDF de todas las palabras por periodo |
| `Tablas/03_frecuencias_tfidf/conjunto_minutas_vs_comunicados.png` | Palabras que pesan más en la minuta o en el comunicado de la misma reunión |
| `Figuras/03_frecuencias_tfidf/conjunto_minutas_vs_comunicados.png` | Ídem, en figura |
| `Tablas/03_frecuencias_tfidf/conjunto_min_vs_com_detalle.csv` | Razón de frecuencias de todas las palabras |
| `Figuras/03_frecuencias_tfidf/conjunto_temas_por_anio.png` | Atención a seis temas por año, comunicados y minutas |
| `Figuras/03_frecuencias_tfidf/minutas_temas_junta_vs_completo.png` | Atención a cada tema: discusión de la Junta frente a texto completo |
| `Tablas/03_frecuencias_tfidf/conjunto_temas_por_periodo.png` | Atención a cada tema por periodo |
| `Tablas/03_frecuencias_tfidf/conjunto_temas_por_anio.csv`, `conjunto_temas_por_documento.csv` | Atención a cada tema por año y por documento |
| `Tablas/03_frecuencias_tfidf/conjunto_nombres_tasa_por_periodo.png` | Cómo se nombra la tasa del Banco en cada periodo |

### `04_bigramas.R`: bigramas, votación y desacuerdo

| Resultado | Contenido |
| --- | --- |
| `Tablas/04_bigramas/conjunto_bigramas_frecuentes.png` | Los 20 bigramas más frecuentes por tipo de documento |
| `Figuras/04_bigramas/comunicados_bigramas_por_periodo.png` | Bigramas más frecuentes por periodo, comunicados |
| `Figuras/04_bigramas/minutas_bigramas_por_periodo.png` | Ídem, minutas (discusión de la Junta) |
| `Tablas/04_bigramas/conjunto_bigramas_por_periodo.csv` | Bigramas por periodo (3 o más apariciones) |
| `Tablas/04_bigramas/conjunto_bigramas_candidatos.png` | Bigramas candidatos al diccionario de compuestos |
| `Tablas/04_bigramas/conjunto_votacion_por_anio.png` | Porcentaje de documentos con información de votación, por año |
| `Figuras/04_bigramas/conjunto_votacion_por_anio.png` | Unanimidad, mayoría o sin información, por año y tipo |
| `Tablas/04_bigramas/conjunto_votacion_por_periodo.csv` | Ídem, por periodo |
| `Tablas/04_bigramas/conjunto_votacion_por_documento.csv` | Clasificación de cada documento, con la cita |
| `Tablas/04_bigramas/conjunto_votacion_comunicado_vs_minuta.png` | Lo que dice el comunicado frente a la minuta de la misma reunión |
| `Tablas/04_bigramas/conjunto_votacion_por_reunion.csv` | Ídem, reunión por reunión |
| `Tablas/04_bigramas/conjunto_votacion_validacion.csv` | Oración de votación de cada documento, clasificación automática, decisión en puntos básicos y dirección del voto de la minoría |
| `Tablas/04_bigramas/conjunto_votacion_muestra_validacion.csv` | Muestra de 30 documentos (5 por formato de minuta y 5 comunicados, semilla 2026) para revisión manual |
| `Tablas/04_bigramas/conjunto_minoria_por_anio.png` | Reuniones con dirección del voto de la minoría codificable, por año |
| `Figuras/04_bigramas/minutas_desacuerdo_por_anio.png` | Expresiones de desacuerdo y votación en las minutas, por año |
| `Tablas/04_bigramas/minutas_desacuerdo_por_anio.csv`, `minutas_desacuerdo_por_documento.csv` | Ídem, cifras |
| `Tablas/04_bigramas/minutas_desacuerdo_por_formato.png` | Uso de cada expresión según el formato de la minuta |

### `05_lda_exploratorio.R`: tópicos preliminares de las minutas

Exploratorio, sin selección de hiperparámetros. `<m>` es `vem` (LDA por
defecto) o `gibbs` (hiperparámetros del laboratorio); `<K>` es 6 o 10. El
sufijo `_completo` indica el texto completo de la minuta; sin sufijo, solo la
discusión de la Junta.

| Resultado | Contenido |
| --- | --- |
| `Tablas/05_lda_exploratorio/minutas_<m>_k<K>_topicos.png` | Palabras de cada tópico (beta y lift), atención promedio y extensión de las minutas |
| `Tablas/05_lda_exploratorio/minutas_gibbs_k<K>_topicos_completo.png` | Ídem, texto completo |
| `Tablas/05_lda_exploratorio/minutas_gibbs_k<K>_documentos.png` | Las 3 minutas más representativas de cada tópico, con un fragmento |
| `Tablas/05_lda_exploratorio/minutas_gibbs_k<K>_periodos.png` (y `_completo`) | Atención promedio a cada tópico por periodo |
| `Figuras/05_lda_exploratorio/minutas_gibbs_k<K>_atencion.png` (y `_completo`) | Atención a cada tópico por reunión, con los cortes de formato |
| `Tablas/05_lda_exploratorio/minutas_<m>_k<K>_theta.csv` (y `_completo`) | Peso de cada tópico en cada minuta |
| `Tablas/05_lda_exploratorio/minutas_lda_extension_por_formato.png` | Extensión de las minutas y peso del tópico principal, por formato |

## Documentación

- `CLAUDE.md`: reglas del proyecto, decisiones tomadas y definición de variables.
- `HANDOFF.md`: estado actual y siguientes objetivos.
- `06_Bitacoras/`: detalle de cada sesión.
- `07_Recursos/catalogo_metodos.md`: métodos, paquetes y funciones permitidos.
