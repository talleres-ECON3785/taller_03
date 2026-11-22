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
tópicos preliminares). Aún no se cruzan los textos con series
macroeconómicas. Todos los resultados actuales son exploratorios y anteriores a
la pregunta.

## Pregunta de investigación

Fijada por el equipo el 2026-11-18:

> **¿Cómo cambiaron los temas de interés de la Junta del Banco de la República
> antes y después de la crisis del petróleo de 2014 en Colombia?**

- **Historia macro:** las series cuentan la historia (caída del precio del
  petróleo, aumento de la tasa de cambio e impacto en la inflación) y se
  relacionan con los cambios de temas que trata la Junta. La relación es
  asociativa, no causal.
- **Método previsto:** embeddings de palabras (GloVe o Word2Vec) para entender
  de qué se hablaba antes y después y cómo cambian las prioridades o
  preocupaciones. Todavía no están en el catálogo de métodos
  (`07_Recursos/catalogo_metodos.md`) y no se usan hasta registrarlos como
  ampliación.
- **Por definir:** fecha de corte antes/después, tipo de documento
  (comunicados, minutas o ambos) y paquete y especificación de los embeddings.

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
| `01_Datos/01_Crudos/` | Datos originales; nunca se modifican. `Comunicados_Minutas_Banrep/` tiene los PDF de la Junta; los `.xlsx` y el `.csv` sueltos son las series macro |
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
  lematiza con `udpipe` y se eliminan palabras vacías y tokens con dígitos o símbolos
  (las cifras no se extraen).
- Las minutas cambian de formato en 2014-05-30, 2019-06-21, 2020-07-31 y
  2023-03-30. Hasta abril de 2019 incluyen una sección con la visión del equipo
  técnico; por eso cada medida se reporta con el texto completo y solo con la
  discusión de la Junta.

**Series macroeconómicas** (descargadas a mano el 2026-11-18 y guardadas sin
modificar en `01_Datos/01_Crudos/`; `06_series_macro.R` las lee):

| Archivo crudo | Series | Fuente (consulta 2026-11-18) | Frecuencia y cobertura en el archivo |
| --- | --- | --- | --- |
| `inflacion_variacion_anual_99_26.xlsx` | Inflación núcleo 15, anual; inflación sin alimentos ni regulados, anual; inflación sin alimentos, anual (variación porcentual anual) | DANE, con cálculos del Banco de la República. Series históricas de precios e inflación: <https://uba.banrep.gov.co/htmlcommons/SeriesHistoricas/precios-inflacion.html> | Mensual, 1999-01 a 2026-10 |
| `tasa_cambio_real_70_26.xlsx` | Índices de tasa de cambio real: FMI, IPC no transables, IPC transables, IPP no transables, IPP transables y competidores | Banco de la República. Series históricas de tasas de cambio y sector externo: <https://uba.banrep.gov.co/htmlcommons/SeriesHistoricas/tasas-cambio-sector-externo.html> | Mensual, 1970-01 a 2026-10 (FMI y competidores traen vacíos al comienzo) |
| `TRM.csv` | Tasa Representativa del Mercado (TRM), pesos colombianos por dólar (`trm_cop_usd`) | Banco de la República, SUAMECA: <https://suameca.banrep.gov.co/estadisticas-economicas/informacionSerie/1/tasa_cambio_peso_colombiano_trm_dolar_usd> | Diaria calendario (con fines de semana y festivos, que repiten el último valor), 1991-11-27 a 2026-11-19 |
| `brent_2000-26.csv` | Precio spot del petróleo Brent, Europa (`DCOILBRENTEU`, dólares por barril) | FRED, Federal Reserve Bank of St. Louis: <https://fred.stlouisfed.org/series/DCOILBRENTEU> | Diaria (días hábiles), 2000-01-04 a 2026-11-17 |
| `IPC TOTAL_Variación_Porcentual_Anual.xlsx` | Inflación total, anual (variación porcentual anual del IPC total): la serie principal frente a la meta | DANE, con cálculos del Banco de la República. Misma página de precios e inflación, pestaña «IPC total» > «Variación porcentual anual» (consulta 2026-11-19) | Mensual, 1955-07 a 2026-10 |
| `Meta e inflación anual.xlsx` | Meta de inflación de cada año (y de nuevo la inflación total) | Banco de la República. Misma página, pestaña «Meta e inflación anual» (consulta 2026-11-19) | Anual, repetida en cada mes; hasta 2026 |

- **Transformaciones** (`06_series_macro.R`): solo se filtran las fechas desde
  2000-01-01 y se guardan como `.rds` en `01_Datos/03_Listos/`. En el Brent se
  eliminan los 500 días sin cotización (vacíos en el crudo); no se
  rellenan. La TRM solo se filtra (9.820 días, sin vacíos). La inflación total se verifica contra cuatro cifras conocidas (±0,05 pp) y la meta queda con una fila por año; su rango se construye con la nota del archivo (±0,5 pp entre 2003 y 2009, ±1 pp desde 2010).
- **Transformaciones** (`07_graficas_macro.R`): promedios mensuales del Brent
  (días con cotización) y de la TRM (lunes a viernes), variación anual en % de
  cada uno, y brecha de inflación (total y núcleo 15 menos la meta del año, en
  puntos porcentuales).
- **Alineación con las reuniones** (`07_graficas_macro.R`, regla en
  `CLAUDE.md`, «Alineación temporal»): a cada reunión, el Brent del día hábil
  anterior, la TRM vigente ese día y la inflación del último mes publicado
  (supuesto: publicada el día 8 del mes siguiente). Resultado:
  `01_Datos/03_Listos/macro_por_reunion.rds`, una fila por cada una de las 205
  reuniones.
- Las fechas mensuales son el fin del mes de referencia, no la de publicación
  del dato (el IPC sale unos días después del cierre del mes). Al cruzar con las
  reuniones de la Junta hay que usar solo lo publicado a la fecha de la reunión.
- La fecha de la TRM es el día de vigencia, y el archivo llega hasta
  2026-11-19, un día posterior a la consulta. Al alinear con las reuniones hay
  que confirmar con el Banco desde qué fecha se conoce cada valor.
- Los archivos del Banco de la República traen los datos como estaban el
  2026-11-18, es decir, con las revisiones posteriores.
- Qué series entran al análisis se decide con la pregunta fijada el 2026-11-18
  (petróleo, tasa de cambio e inflación). La TRM nominal (`TRM.csv`) ya está
  descargada; el índice de tasa de cambio *real* queda como complemento.

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

### `06_series_macro.R`: series macroeconómicas desde 2000

No genera tablas ni figuras. Lee los tres archivos crudos de series macro y
guarda en `01_Datos/03_Listos/`: `macro_brent.rds` (fecha, `brent_usd`; 6.511
días), `macro_inflacion.rds` y `macro_tcr.rds` (una columna por serie; 322
meses, 2000-01 a 2026-10), `macro_trm.rds` (fecha, `trm_cop_usd`; 9.820
días, 2000-01-01 a 2026-11-19), `macro_inflacion_total.rds` (fecha,
`inflacion_total`; 322 meses) y `macro_meta.rds` (año, `meta`, `rango_inf`,
`rango_sup`).

### `07_graficas_macro.R`: series macro, cronología del choque y alineación

Datos: `01_Datos/03_Listos/macro_por_reunion.rds` (una fila por reunión con
las series alineadas). No lee ninguna medida de texto: del corpus solo toma
fechas, formato y número de palabras.

| Resultado | Contenido |
| --- | --- |
| `Figuras/07_graficas_macro/macro_series_2007_2026.png` | Brent, TRM e inflación total y núcleo 15 con la meta escalonada y su rango, 2007–2026, con los periodos P1–P10 sombreados y la línea del corte (2014-10-30) |
| `Figuras/07_graficas_macro/macro_cronologia_choque.png` | Zoom 2013–2017: pico y valle del Brent, inicio y pico de la depreciación, pico de la inflación, ciclo de alzas de la tasa y la línea del corte (2014-10-30) |
| `Tablas/07_graficas_macro/macro_descriptiva.png` | Media, mínimo, máximo y variación de Brent, TRM e inflación por periodo, con la brecha frente a la meta (P3 y P4 resaltados) |
| `Tablas/07_graficas_macro/macro_cronologia.png` | Cada hito del choque con su fecha, su valor y la cita del comunicado cuando es una decisión de tasa |
| `Tablas/07_graficas_macro/macro_cortes_candidatos.png` | Fechas de corte candidatas (apertura de P4 y dos reglas mecánicas) con los datos que la Junta tenía ese día |
| `Tablas/07_graficas_macro/conjunto_ventanas_corte.png` | Minutas del formato B antes de cada corte y reuniones y palabras de la Junta a cada lado, en una ventana de 5 años |

### `08_lda_oraciones.R`: modelo de tópicos con bloques de oraciones

Hito H3a de `PLAN.md`. Documento: bloques de oraciones consecutivas de un
comunicado o de la discusión de la Junta en una minuta. El modelo se estima
con la ventana de 5 años a cada lado del corte, como las medidas de `09`; fuera
de ella, θ sale de `posterior()`. La sección 1 es un
análisis previo al modelo, sin tópicos: fija el umbral de palabras por bloque.

| Resultado | Contenido |
| --- | --- |
| `Tablas/08_lda_oraciones/conjunto_lda_umbral_bloques.png` | Palabras útiles por bloque y bloques por reunión antes y después del corte para umbrales de 60, 80 y 100 palabras, con el elegido marcado; bloques y vocabulario de la ventana de 5 años con la que se estima el modelo |
| `Tablas/08_lda_oraciones/conjunto_lda_seleccion.png` | Perplejidad por validación cruzada (3 pliegues) con el mejor α, costo frente al mínimo y coherencia UMass media para K = 6, 8, 10, 12 y 15, con el K elegido marcado |
| `Tablas/08_lda_oraciones/conjunto_lda_rejilla.csv` | Perplejidad de las 20 combinaciones de K y α |
| `Tablas/08_lda_oraciones/conjunto_lda_topicos.png` | Los 10 tópicos: nombre, palabras de mayor lift y más probables, formato de minuta con más peso, alerta de formato y si se repite con las semillas 2027 y 2028 |
| `Tablas/08_lda_oraciones/conjunto_lda_fragmentos.png` | Los 3 bloques de texto con mayor peso de cada tópico estable, con fecha y tipo de documento |
| `Figuras/08_lda_oraciones/conjunto_lda_antes_despues.png` | Peso medio por reunión de cada tópico estable antes y después del corte, con IC 95 %, por tipo de documento |
| `Tablas/08_lda_oraciones/conjunto_lda_antes_despues.png` | Media antes y después, diferencia, IC 95 % (prueba t de Welch por reunión) y lectura de robustez de cada tópico estable |
| `Tablas/08_lda_oraciones/conjunto_lda_theta_por_reunion.csv` | Peso de cada tópico por reunión, 2007–2026 (fuera de la ventana, con `posterior()`) |
| `Tablas/08_lda_oraciones/conjunto_lda_antes_despues_detalle.csv` | Medias, diferencias e IC de cada tópico en los cuatro escenarios |
| `Tablas/08_lda_oraciones/conjunto_lda_vs_diccionario.png` (y `.csv`) | Correlación por reunión, con IC 95 %, entre el peso de los tópicos y la atención al tema equivalente del diccionario de `09` (Actividad económica, Inflación, Entorno externo), en la ventana |
| `Figuras/08_lda_oraciones/conjunto_lda_theta_por_reunion_topicos_1_4.png` y `..._topicos_6_10.png` | Peso de cada tópico estable por reunión, 2007–2019 (desde 2020 entra la pandemia), en dos figuras de 4 tópicos (1 a 4 y 6 a 10), con media móvil de 5 reuniones, el corte, los cambios de formato y los periodos de política (fuera de la ventana, con el modelo estimado en ella) |

### `09_antes_despues.R`: palabras, bigramas, atención por tema y correlaciones antes y después del corte

Hito H3b de `PLAN.md`. Épocas: 5 años antes y 5 años después del 2014-10-30
(2009-10-30 a 2019-10-29). Minutas: solo la discusión de la Junta;
comunicados en paralelo como control del cambio de formato de las minutas.
Todo por 1.000 palabras. Robustez (solo tablas): muestra completa 2007–2026 y
cortes 2014-09-26 y 2014-12-19. La construcción de bigramas se movió a
`construir_bigramas()` de `00_funciones_texto.R` (la usan `04` y `09`).

| Resultado | Contenido |
| --- | --- |
| `Figuras/09_antes_despues/conjunto_palabras_distintivas.png` | Las 15 palabras que más ganan y las 15 que más pierden peso después del corte (razón de frecuencias), por tipo de documento |
| `Figuras/09_antes_despues/conjunto_bigramas_cambio.png` | Los 10 bigramas que más ganan y los 10 que más pierden, por tipo |
| `Figuras/09_antes_despues/conjunto_temas_antes_despues.png` | Atención media por reunión a cada tema del diccionario `temas`, antes y después, con IC 95 % |
| `Figuras/09_antes_despues/conjunto_temas_macro_por_reunion.png` | Atención al entorno externo y a la inflación por reunión, 2007–2026, con Brent, TRM e inflación total en paneles alineados, corte y periodos marcados |
| `Tablas/09_antes_despues/conjunto_documentos_por_epoca.png` | Reuniones y palabras a cada lado del corte en los cuatro escenarios |
| `Tablas/09_antes_despues/conjunto_fragmentos_palabras.png` | Las 5 palabras que más ganan y más pierden, con su lectura de robustez y un fragmento |
| `Tablas/09_antes_despues/{comunicados,minutas}_palabras_robustez.png` | Las 30 palabras de la figura con su frecuencia, la razón en el otro tipo de documento y en los tres escenarios de robustez |
| `Tablas/09_antes_despues/conjunto_fragmentos_bigramas.png` | Ídem para los bigramas |
| `Tablas/09_antes_despues/conjunto_bigramas_frecuentes_epoca.png` | Los 12 bigramas más frecuentes en cada época, por tipo |
| `Tablas/09_antes_despues/conjunto_temas_antes_despues.png` | Media antes y después, diferencia, IC 95 % (prueba t de Welch por reunión) y lectura de cada tema |
| `Tablas/09_antes_despues/conjunto_temas_robustez.png` | La diferencia por tema en los cuatro escenarios |
| `Tablas/09_antes_despues/conjunto_fragmentos_temas.png` | Un fragmento por tema, época y tipo de documento |
| `Tablas/09_antes_despues/conjunto_cronologia_texto_macro.png` | Reunión en que toca su extremo cada serie (texto y macro), 2013–2018 |
| `Tablas/09_antes_despues/{comunicados,minutas}_correlaciones_anclas.png` | Las 8 palabras más correlacionadas (phi, `pairwise_cor()`, documento = oración) con cada palabra ancla, antes y después |
| `Tablas/09_antes_despues/*.csv` | Cifras sin formato de cada tabla; además el detalle completo de palabras y bigramas (`*_cambio_detalle.csv`, con TF-IDF de dos grupos), la atención por reunión (`conjunto_temas_por_reunion.csv`) y los fragmentos de las anclas (`conjunto_fragmentos_anclas.csv`) |

### `11_figuras_diapositiva.R`: versiones de las figuras para la presentación

Solo lee resultados ya guardados de `07`, `08` y `09` (no estima nada) y
los redibuja en 16:9 (13,33 × 7,5 pulgadas) con letra grande para un video.
Las cifras son las de los scripts de origen; las figuras originales no cambian.
El tema de letra grande (`tema_diapositiva`) y los colores de las series macro
que no se confunden con los de comunicados y minutas
(`colores_macro_diapositiva`) viven en `00_formato_graficas.R`.

| Resultado | Contenido |
| --- | --- |
| `Figuras/11_figuras_diapositiva/conjunto_lda_externo_6_10.png` | Tópicos 6 (déficit externo) y 10 (economía mundial), antes y después, comunicados y minutas, con IC 95 % |
| `Figuras/11_figuras_diapositiva/conjunto_lda_credito_actividad_1_2.png` | Tópicos 1 (actividad interna) y 2 (crédito), ídem |
| `Figuras/11_figuras_diapositiva/conjunto_lda_inflacion_4_8.png` | Tópicos 4 (inflación por depreciación) y 8 (inflación básica frente a la meta), ídem |
| `Figuras/11_figuras_diapositiva/conjunto_externo_macro_2013_2018.png` | Atención al entorno externo, Brent, TRM e inflación por reunión, 2013–2018, con el corte, el ciclo de alzas y los extremos fechados |
| `Figuras/11_figuras_diapositiva/conjunto_palabras_10_10.png` | Las 10 palabras que más ganan y las 10 que más pierden, con tildes |
| `Figuras/11_figuras_diapositiva/minutas_correlaciones_inflacion.png` | Palabras más correlacionadas con «inflación» y «expectativas de inflación» en las minutas, antes y después |
| `Figuras/11_figuras_diapositiva/conjunto_temas_antes_despues.png` | Atención media por reunión a cada tema del diccionario, antes y después, comunicados y minutas, con IC 95 % (versión de diapositiva de la figura de `09`) |
| `Figuras/11_figuras_diapositiva/macro_series_2007_2026.png` | Brent, TRM e inflación total por reunión, 2007–2026, con la meta y su rango, el corte y el periodo P10 destacado |
| `Tablas/11_figuras_diapositiva/conjunto_verificacion_antes_alzas.csv` | Primera reunión en que la media móvil del tópico 4 y del tema «Entorno externo» supera su máximo de los 5 años antes del corte, frente a la primera alza (2015-09-25). La figura `conjunto_cambio_antes_alzas.png` solo se genera si las dos medidas lo superan antes de la alza en comunicados y en minutas; con los datos actuales no se genera |

### Borrador de la presentación (fuera del pipeline)

`04_Presentaciones/construir_borrador.py` (Python, `python-pptx`) arma
`04_Presentaciones/borrador_presentacion.pptx` sobre la plantilla del equipo
(`04_Presentaciones/plantilla_presentacion.pptx`) con las figuras de
`03_Resultados/` y el guion en las notas del orador. El contenido sale de
`04_Presentaciones/hallazgos_y_figuras.txt`. Se corre aparte, desde la raíz:
`python 04_Presentaciones/construir_borrador.py`.

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
