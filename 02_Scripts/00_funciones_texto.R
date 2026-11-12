# =============================================================================
# Definiciones compartidas para el analisis de texto
# Taller 3 - ECON-3785
#
# Este script NO genera resultados: define, una sola vez, las funciones y las
# listas que usan los scripts de analisis de texto, para que no queden
# copiadas (y desincronizadas) en cada uno:
#   1. funciones de normalizacion (tildes, oraciones);
#   2. periodos de politica monetaria, definidos a priori por la decision de
#      tasa que abre cada uno;
#   3. cortes de formato de las minutas;
#   4. diccionario de terminos compuestos de la Junta;
#   5. palabras vacias (generales y de dominio).
#
# Uso: source("02_Scripts/00_funciones_texto.R") al inicio del script.
# =============================================================================

# los paquetes los carga 00_main.R con pacman

# -----------------------------------------------------------------------------
# 1. Normalizacion
# -----------------------------------------------------------------------------

# quita tildes y dieresis (catalogo, "Convenciones comunes"). Se aplica
# DESPUES de lematizar: udpipe necesita el texto original
sin_tilde <- function(x) stringi::stri_trans_general(x, "Latin-ASCII")

# convierte una expresion escrita sin tildes en un patron que acepta la vocal
# con o sin tilde y que solo coincide con palabras completas (catalogo, sec. 5)
con_tildes <- function(x) {
  x %>%
    str_replace_all(c("a" = "[aá]", "e" = "[eé]", "i" = "[ií]",
                      "o" = "[oó]", "u" = "[uú]")) %>%
    paste0("\\b", ., "\\b")
}

# parte un texto en oraciones. El corte es un punto (o punto y coma) despues
# de una palabra de al menos dos letras, un porcentaje o un parentesis, y
# seguido de mayuscula; asi no se corta en "p.b.", "D.C." ni en "3,5%. en"
partir_oraciones <- function(texto) {
  str_split(
    texto,
    "(?<=[\\p{Ll}%\\)\\d]{2}[.;])\\s+(?=[\\p{Lu}¿])"
  )
}

# cuenta palabras (secuencias sin espacios) de un texto
contar_palabras <- function(texto) str_count(texto, "\\S+")

# -----------------------------------------------------------------------------
# 2. Periodos de politica monetaria (definidos a priori)
# -----------------------------------------------------------------------------

# cada periodo lo abre la primera reunion en que la Junta cambia la direccion
# de la tasa de intervencion (o entra en pausa). Las fechas se fijaron antes
# de mirar las medidas de texto y se verificaron contra la decision que
# anuncia el comunicado de esa fecha: '01_extraer_texto.R' exporta la tabla
# con la cita de cada decision. La reunion del 2020-03-27 no tiene comunicado
# en los datos del curso; su decision se cita de la minuta
periodos <- tribble(
  ~periodo, ~inicio,      ~nombre,
  "P1",     "2007-01-26", "Alzas previas a la crisis",
  "P2",     "2008-12-19", "Crisis global y recortes",
  "P3",     "2011-02-25", "Normalización",
  "P4",     "2014-09-26", "Choque petrolero e inflación",
  "P5",     "2016-12-16", "Recortes y tasa estable",
  "P6",     "2020-03-27", "Pandemia",
  "P7",     "2021-09-30", "Alzas por inflación",
  "P8",     "2023-12-19", "Recortes",
  "P9",     "2025-06-27", "Pausa",
  "P10",    "2026-01-30", "Alzas de 2026"
) %>%
  mutate(
    inicio = as.Date(inicio),
    fin = lead(inicio - 1, default = as.Date("2026-09-30")),
    # etiqueta para los paneles de las figuras: "P4 Choque petrolero (2014-16)"
    etiqueta = paste0(
      periodo, " ", nombre, " (",
      if_else(format(inicio, "%Y") == format(fin, "%Y"),
              format(inicio, "%Y"),
              paste0(format(inicio, "%Y"), "-", format(fin, "%y"))),
      ")"
    ),
    periodo = factor(periodo, levels = periodo),
    etiqueta = factor(etiqueta, levels = etiqueta)
  )

# asigna a cada fecha de reunion su periodo (factor ordenado P1..P10)
asignar_periodo <- function(fecha) {
  periodos$periodo[findInterval(fecha, periodos$inicio)]
}

# -----------------------------------------------------------------------------
# 3. Cortes de formato de las minutas
# -----------------------------------------------------------------------------

# primera reunion de cada formato de minuta. Los ubica '01_extraer_texto.R' a
# partir de los encabezados de seccion y verifica que coincidan con estas
# fechas (si el texto cambiara, ese script se detiene). Se usan para marcar
# lineas verticales en las series de tiempo
formatos_minutas <- tribble(
  ~formato, ~inicio,      ~descripcion,
  "A",      "2007-06-15", "Antecedentes del equipo técnico + discusión + decisión",
  "B",      "2014-05-30", "Síntesis del equipo técnico + discusión + decisión",
  "C",      "2019-06-21", "Discusión + decisión, sin sección del equipo técnico",
  "D",      "2020-07-31", "Texto corrido, sin secciones",
  "E",      "2023-03-30", "Titular con la decisión + texto corrido"
) %>%
  mutate(inicio = as.Date(inicio))

# los cortes son los inicios de los formatos B a E
cortes_formato <- formatos_minutas$inicio[-1]

# -----------------------------------------------------------------------------
# 4. Diccionario de terminos compuestos de la Junta
# -----------------------------------------------------------------------------

# expresion (sin tildes, en minusculas) -> token. Se aplica de la expresion mas
# larga a la mas corta (lo ordena `patrones_compuestos`), para que "tasa de
# cambio real" se reemplace antes que "tasa de cambio" (catalogo, sec. 5).
# Las formas de nombrar la tasa del Banco NO estan aqui: se tratan aparte en
# `unificar_tasas()` porque algunas tambien nombran la tasa de otros bancos
# centrales
compuestos <- c(
  # Junta y gobierno
  "junta directiva del banco de la republica" = "junta_directiva",
  "junta directiva"                           = "junta_directiva",
  "jdbr"                                      = "junta_directiva",
  "ministro de hacienda y credito publico"    = "ministro_hacienda",
  "ministerio de hacienda y credito publico"  = "ministerio_hacienda",
  "ministro de hacienda"                      = "ministro_hacienda",
  "ministerio de hacienda"                    = "ministerio_hacienda",
  "equipo tecnico"                            = "equipo_tecnico",
  # inflacion
  "inflacion sin alimentos ni regulados"      = "inflacion_basica",
  "inflacion basica"                          = "inflacion_basica",
  "expectativas de inflacion"                 = "expectativas_inflacion",
  "expectativa de inflacion"                  = "expectativas_inflacion",
  "pronosticos de inflacion"                  = "pronostico_inflacion",
  "pronostico de inflacion"                   = "pronostico_inflacion",
  "indice de precios al consumidor"           = "ipc",
  "inflacion de alimentos"                    = "inflacion_alimentos",
  "inflacion total"                           = "inflacion_total",
  "meta de inflacion"                         = "meta_inflacion",
  "rango meta"                                = "meta_inflacion",
  "choques de oferta"                         = "choque_oferta",
  "choque de oferta"                          = "choque_oferta",
  "fenomeno de el niño"                       = "fenomeno_nino",
  "fenomeno del niño"                         = "fenomeno_nino",
  "salario minimo"                            = "salario_minimo",
  # actividad
  "producto interno bruto"                    = "pib",
  "brecha del producto"                       = "brecha_producto",
  "brecha de producto"                        = "brecha_producto",
  "demanda interna"                           = "demanda_interna",
  "demanda agregada"                          = "demanda_agregada",
  "actividad economica"                       = "actividad_economica",
  "crecimiento economico"                     = "crecimiento_economico",
  "mercado laboral"                           = "mercado_laboral",
  "tasa de desempleo"                         = "tasa_desempleo",
  # sector externo
  "terminos de intercambio"                   = "terminos_intercambio",
  "inversion extranjera directa"              = "ied",
  "balanza de pagos"                          = "balanza_pagos",
  "cuenta corriente"                          = "cuenta_corriente",
  "tasa de cambio real"                       = "tasa_cambio_real",
  "tipo de cambio real"                       = "tasa_cambio_real",
  "tasa de cambio"                            = "tasa_cambio",
  "tipo de cambio"                            = "tasa_cambio",
  "precios internacionales del petroleo"      = "precio_petroleo",
  "precios del petroleo"                      = "precio_petroleo",
  "precio del petroleo"                       = "precio_petroleo",
  "primas de riesgo"                          = "prima_riesgo",
  "prima de riesgo"                           = "prima_riesgo",
  "reserva federal"                           = "reserva_federal",
  "banco central europeo"                     = "bce",
  "estados unidos"                            = "estados_unidos",
  "zona del euro"                             = "zona_euro",
  "zona euro"                                 = "zona_euro",
  # politica y finanzas
  "postura de politica monetaria"             = "postura_politica",
  "postura de la politica monetaria"          = "postura_politica",
  "postura de politica"                       = "postura_politica",
  "postura monetaria"                         = "postura_politica",
  "politica monetaria"                        = "politica_monetaria",
  "politica fiscal"                           = "politica_fiscal",
  "regla fiscal"                              = "regla_fiscal",
  "deuda publica"                             = "deuda_publica",
  "balance de riesgos"                        = "balance_riesgos",
  "condiciones financieras"                   = "condiciones_financieras",
  "tasas de interes reales"                   = "tasa_interes_real",
  "tasa de interes real"                      = "tasa_interes_real",
  "tasas de interes"                          = "tasa_interes",
  "tasa de interes"                           = "tasa_interes",
  "puntos basicos"                            = "puntos_basicos",
  "puntos base"                               = "puntos_basicos",
  "puntos porcentuales"                       = "puntos_porcentuales",
  "punto porcentual"                          = "puntos_porcentuales",
  # horizontes
  "corto plazo"                               = "corto_plazo",
  "mediano plazo"                             = "mediano_plazo",
  "largo plazo"                               = "largo_plazo"
)

# expresiones que necesitan un patron propio (siglas y abreviaturas con
# puntos): se aplican ANTES que el diccionario. "pb" y "tes" solo cuentan como
# palabra completa (\\b), para no capturar pedazos de otras palabras
compuestos_regex <- c(
  "\\bp[.] ?b[.]?(?=\\s|$|[,;)])" = "puntos_basicos",
  "\\bpbs?\\b"                   = "puntos_basicos",
  "\\btes\\b"                    = "tes",
  "\\bfed\\b"                    = "reserva_federal",
  "\\bee[.] ?uu[.]?"             = "estados_unidos",
  "\\bcovid(-| )?19\\b"          = "covid",
  "\\bpib\\b"                    = "pib",
  "\\bipc\\b"                    = "ipc"
)

# patrones del diccionario, ordenados de la expresion mas larga a la mas corta
patrones_compuestos <- {
  orden <- order(nchar(names(compuestos)), decreasing = TRUE)
  setNames(compuestos[orden], con_tildes(names(compuestos)[orden]))
}

# --- la tasa del Banco de la Republica --------------------------------------

# formas de nombrar la tasa de politica. Las de "intervencion" y "politica"
# casi siempre nombran la tasa del Banco; las de "referencia" tambien se usan
# para la Reserva Federal y otros bancos centrales
patron_tasa_fuerte <- paste0(
  "\\btasas? de inter[eé]s de pol[ií]tica monetaria\\b|",
  "\\btasas? de inter[eé]s de intervenci[oó]n\\b|",
  "\\btasas? de pol[ií]tica monetaria\\b|",
  "\\btasas? de inter[eé]s de pol[ií]tica\\b|",
  "\\btasas? de intervenci[oó]n\\b|",
  "\\btasas? de pol[ií]tica\\b"
)
patron_tasa_referencia <- "\\btasas? de inter[eé]s de referencia\\b|\\btasas? de referencia\\b"

# referente externo en la misma oracion
patron_externo <- paste0(
  "reserva federal|\\bfed\\b|\\bbce\\b|banco central europeo|estados unidos|",
  "\\bee[.] ?uu|bancos centrales|banco de inglaterra|banco de jap[oó]n"
)
# referente externo pegado a la expresion: "tasa de politica de la Reserva Federal"
patron_externo_pegado <- paste0(
  "(?=\\s+(de|en|por parte de)\\s+(la\\s+|el\\s+|los\\s+)?(", patron_externo, "))"
)

# reemplaza las formas de nombrar la tasa de politica por un token:
#   - cualquier variante con un referente externo pegado -> tasa_externa;
#   - variantes de "intervencion" y "politica" -> tasa_intervencion;
#   - variantes de "referencia": si `unir_referencia` es TRUE, pasan a
#     tasa_intervencion cuando la oracion no tiene referente externo y a
#     tasa_referencia cuando lo tiene; si es FALSE, todas quedan como
#     tasa_referencia.
# `texto` debe venir en minusculas. Devuelve el texto con los tokens
unificar_tasas <- function(texto, unir_referencia) {
  todas <- paste0("(", patron_tasa_fuerte, "|", patron_tasa_referencia, ")")
  texto <- str_replace_all(texto, paste0(todas, patron_externo_pegado), "tasa_externa")
  texto <- str_replace_all(texto, patron_tasa_fuerte, "tasa_intervencion")
  if (!unir_referencia) {
    return(str_replace_all(texto, patron_tasa_referencia, "tasa_referencia"))
  }
  # el corte de oraciones en minusculas es solo por punto + espacio
  map_chr(str_split(texto, "(?<=[\\p{Ll}%\\)\\d]{2}[.;])\\s+"), function(oraciones) {
    externa <- str_detect(oraciones, patron_externo)
    oraciones <- if_else(
      externa,
      str_replace_all(oraciones, patron_tasa_referencia, "tasa_referencia"),
      str_replace_all(oraciones, patron_tasa_referencia, "tasa_intervencion")
    )
    paste(oraciones, collapse = " ")
  })
}

# aplica todo el diccionario a un vector de textos: minusculas, tasas, siglas
# y compuestos (en ese orden)
aplicar_compuestos <- function(texto, unir_referencia) {
  texto %>%
    str_to_lower() %>%
    unificar_tasas(unir_referencia) %>%
    str_replace_all(compuestos_regex) %>%
    str_replace_all(patrones_compuestos)
}

# -----------------------------------------------------------------------------
# 5. Palabras vacias
# -----------------------------------------------------------------------------

# generales: snowball en espanol mas las de ingles, sin tildes (catalogo)
vacias_generales <- unique(sin_tilde(c(
  stopwords::stopwords("es", source = "snowball"),
  stopwords::stopwords("en")
)))

# de dominio (lista inicial, fijada antes de ver las frecuencias). Son palabras
# de procedimiento o de calendario, no de contenido economico. Criterio para
# ampliarla: la palabra esta en 90 % o mas de los documentos de su tipo Y es de
# procedimiento o redaccion. Las palabras de contenido economico ("inflacion",
# "tasa", "crecimiento") nunca entran, aunque esten en todos los documentos
vacias_dominio <- c(
  # procedimiento
  "junta", "junta_directiva", "directiva", "banco", "republica", "reunion",
  "sesion", "ordinaria", "miembro", "director", "codirector", "gerente",
  "ministro", "ministro_hacienda", "doctor", "presencia", "ciudad", "bogota",
  "minuta", "comunicado", "banrep", "republico", "bogotar", "dc",
  # numerales romanos de las enumeraciones "(i) ... (vi)"
  "ii", "iii", "iv", "vi", "vii", "viii", "ix", "xi", "xii",
  # calendario
  "mes", "ano", "trimestre", "semestre", "semana", "dia", "hoy",
  "enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto",
  "septiembre", "octubre", "noviembre", "diciembre",
  "lunes", "martes", "miercoles", "jueves", "viernes", "sabado", "domingo"
)

# ampliacion despues de ver las frecuencias ('02_limpiar_texto.R' exporta la
# tabla de candidatas: palabras en 90 % o mas de los documentos de un tipo).
# Solo entran las de redaccion; se documenta cada una.
# Revision del 2026-11-10: las 23 candidatas (inflacion, tasa_intervencion,
# crecimiento, continuar, mantener, expectativas_inflacion, economia, externo,
# mayor, nivel, politica_monetaria, tasa_interes, contexto, inflacion_basica,
# meta, precio, anual, aumento, seguir) describen el entorno economico o la
# decision ("mantener", "continuar", "aumento"); ninguna es de procedimiento.
# No se agrega ninguna: quedan en las frecuencias y, en LDA, las acota el tope
# del recorte de vocabulario
vacias_dominio_ampliacion <- character(0)

# -----------------------------------------------------------------------------
# 6. Grupos tematicos de palabras (diccionarios exploratorios)
# -----------------------------------------------------------------------------

# listas de lemas por tema, fijadas a priori (antes de ver las series), para
# seguir en el tiempo cuanta atencion recibe cada tema. Son conteos de
# palabras, no un modelo: sirven para contrastar con episodios conocidos
temas <- list(
  "Inflación" = c("inflacion", "inflacion_basica", "inflacion_total", "inflacion_alimentos",
                  "expectativas_inflacion", "meta_inflacion", "pronostico_inflacion", "ipc",
                  "inflacionario", "precio", "indexacion"),
  "Actividad económica" = c("crecimiento", "crecimiento_economico", "pib", "actividad_economica",
                            "demanda_interna", "demanda_agregada", "consumo", "inversion",
                            "brecha_producto", "producto", "recuperacion", "desaceleracion"),
  "Entorno externo" = c("reserva_federal", "estados_unidos", "zona_euro", "bce", "externo",
                        "internacional", "global", "mundial", "precio_petroleo", "petroleo",
                        "terminos_intercambio", "tasa_cambio", "tasa_cambio_real", "tasa_externa",
                        "china", "exportacion", "prima_riesgo", "cuenta_corriente", "balanza_pagos",
                        "depreciacion", "devaluacion", "peso", "dolar"),
  "Mercado laboral" = c("mercado_laboral", "tasa_desempleo", "empleo", "desempleo", "salario",
                        "salario_minimo", "laboral"),
  "Fiscal" = c("politica_fiscal", "regla_fiscal", "deuda_publica", "fiscal", "tes", "gobierno",
               "tributario", "deficit"),
  "Riesgo e incertidumbre" = c("incertidumbre", "riesgo", "balance_riesgos", "incierto", "volatilidad")
)
