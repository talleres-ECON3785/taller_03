# =============================================================================
# 01. Extraccion del texto de los PDF de la Junta y diagnostico de formato
# Taller 3 - ECON-3785
#
# Entradas: los 194 comunicados y las 199 minutas en PDF de
#   01_Datos/01_Crudos/Comunicados_Minutas_Banrep/ (el informe tecnico del
#   2020-04-30 esta fuera de minutas/ y no se lee).
# Salidas:
#   01_Datos/02_Procesados/texto_crudo.rds    texto tal como sale de pdf_text()
#   01_Datos/02_Procesados/corpus_texto.rds   una fila por documento, con el
#       texto limpio, el texto de la discusion de la Junta y sus metadatos
#   01_Datos/02_Procesados/secciones_minutas.rds  una fila por seccion
#   01_Datos/02_Procesados/decisiones_reunion.rds direccion de la decision de
#       tasa de cada reunion, con la cita
#   03_Resultados/Tablas/01_extraer_texto/    y  Figuras/01_extraer_texto/
#
# Que hace:
#   1. extrae el texto con pdftools::pdf_text() (reutiliza texto_crudo.rds si
#      existe; para regenerarlo basta borrarlo o poner regenerar <- TRUE);
#   2. limpia: numeros de pagina, restos de la pagina web, lineas de
#      encabezado y pie, titulos duplicados, guiones de fin de linea y saltos
#      de linea. Guarda cada linea eliminada para poder auditarla;
#   3. quita los restos web y los titulos, separa las secciones de las minutas (preambulo, equipo tecnico,
#      discusion, decision) y clasifica el formato de cada minuta;
#   4. verifica los periodos a priori contra la decision de cada comunicado;
#   5. exporta el diagnostico de formato (tablas y figuras).
# =============================================================================

# los paquetes los carga 00_main.R con pacman

source("02_Scripts/00_formato_tablas.R") # tambien carga 00_formato_graficas.R
source("02_Scripts/00_funciones_texto.R")

carpeta_salida <- "01_extraer_texto"
regenerar <- FALSE # TRUE: vuelve a leer los PDF aunque exista texto_crudo.rds

# -----------------------------------------------------------------------------
# 1. Extraccion
# -----------------------------------------------------------------------------

carpeta_crudos <- "01_Datos/01_Crudos/Comunicados_Minutas_Banrep"
archivos <- c(
  list.files(file.path(carpeta_crudos, "comunicados"), pattern = "[.]pdf$", full.names = TRUE),
  list.files(file.path(carpeta_crudos, "minutas"), pattern = "[.]pdf$", full.names = TRUE)
)
ruta_crudo <- "01_Datos/02_Procesados/texto_crudo.rds"

if (file.exists(ruta_crudo) && !regenerar) {
  crudo <- readRDS(ruta_crudo)
  message("Se reutiliza ", ruta_crudo, " (", nrow(crudo), " documentos).")
}
if (!exists("crudo") || !setequal(crudo$archivo, basename(archivos))) {
  message("Extrayendo el texto de ", length(archivos), " PDF con pdf_text()...")
  # se registran los PDF en los que pdf_text() emite un aviso o falla
  leer_pdf <- function(ruta) {
    aviso <- NA_character_
    paginas <- withCallingHandlers(
      tryCatch(pdf_text(ruta), error = function(e) {
        aviso <<- conditionMessage(e)
        character(0)
      }),
      warning = function(w) {
        aviso <<- conditionMessage(w)
        invokeRestart("muffleWarning")
      }
    )
    # el texto se pega ANTES de contar las paginas (si no, `paginas` ya seria
    # el numero y no el vector de textos)
    tibble(archivo = basename(ruta), texto_crudo = paste(paginas, collapse = "\n"),
           paginas = length(paginas), aviso = aviso)
  }
  crudo <- map_dfr(archivos, leer_pdf)
  saveRDS(crudo, ruta_crudo)
}

crudo <- crudo %>%
  mutate(
    id = str_remove(archivo, "[.]pdf$"),
    fecha = as.Date(str_sub(archivo, 1, 10)),
    tipo = str_extract(archivo, "comunicado|minuta"),
    palabras_crudo = contar_palabras(texto_crudo)
  )

# PDF sin texto extraible: menos de 50 palabras (un PDF escaneado da 0)
sin_texto <- crudo %>% filter(palabras_crudo < 50)
message("PDF leidos: ", nrow(crudo), " (", sum(crudo$tipo == "comunicado"),
        " comunicados y ", sum(crudo$tipo == "minuta"), " minutas). ",
        "Sin texto extraible: ", nrow(sin_texto), ". ",
        "Con aviso de pdf_text(): ", sum(!is.na(crudo$aviso)), ".")
stopifnot(nrow(crudo) == 393, !any(crudo$fecha == as.Date("2020-04-30") & crudo$tipo == "minuta"))

# -----------------------------------------------------------------------------
# 2. Limpieza por lineas: numeros de pagina, encabezados y pies
# -----------------------------------------------------------------------------

# una fila por linea no vacia de cada documento
lineas <- crudo %>%
  select(id, tipo, fecha, texto_crudo) %>%
  mutate(linea = str_split(texto_crudo, "\n")) %>%
  select(-texto_crudo) %>%
  unnest(linea) %>%
  mutate(linea = str_squish(linea)) %>%
  filter(linea != "") %>%
  group_by(id) %>%
  mutate(n_linea = row_number()) %>%
  ungroup()

# patrones de lineas que no son contenido
patron_pagina <- "^[0-9]{1,2}$"
patron_pie_comunicado <- paste0(
  "^Banco de la Rep[uú]blica - Comunicado de la Junta Directiva$|",
  "^Fecha de publicaci[oó]n:|^Fuente: https?://|^[(]PDF generado a partir|",
  "^Bogot[aá],? D[.] ?C[.]$|^Rueda de prensa$"
)
patron_pie_minuta <- "^Fuente: https?://|^[(]PDF generado a partir"

lineas <- lineas %>%
  mutate(
    motivo = case_when(
      str_detect(linea, patron_pagina) ~ "número de página",
      tipo == "comunicado" & str_detect(linea, patron_pie_comunicado) ~ "encabezado o pie del comunicado",
      tipo == "minuta" & str_detect(linea, patron_pie_minuta) ~ "pie de la minuta",
      TRUE ~ NA_character_
    )
  )

# fechas que trae el propio texto (se guardan como metadatos antes de quitar
# las lineas): fecha de publicacion del comunicado, fecha con que cierran
# algunas minutas ("Bogota D. C., enero 05 de 2009") y "ultima modificacion"
# de la pagina web de la minuta
meses <- c("enero", "febrero", "marzo", "abril", "mayo", "junio", "julio",
           "agosto", "septiembre", "octubre", "noviembre", "diciembre")
a_fecha <- function(x) {
  # "26 de enero de 2007" o "enero 05 de 2009" -> Date (NA si no hay fecha)
  x <- str_to_lower(x)
  dia <- coalesce(str_extract(x, "[0-9]{1,2}(?= de [a-z])"), str_extract(x, "(?<=[a-z] )[0-9]{1,2}(?= de [0-9]{4})"))
  mes <- match(str_extract(x, paste(meses, collapse = "|")), meses)
  anio <- str_extract(x, "[0-9]{4}")
  suppressWarnings(as.Date(sprintf("%s-%02d-%02d", anio, mes, as.integer(dia)), optional = TRUE))
}
fechas_texto <- lineas %>%
  group_by(id) %>%
  summarise(
    fecha_publicacion_comunicado = a_fecha(str_extract(
      paste(linea[str_detect(linea, "^Fecha de publicaci[oó]n:")], collapse = " "),
      "[0-9]{1,2} de [a-z]+ de [0-9]{4}"
    )),
    fecha_cierre_minuta = a_fecha(str_extract(
      paste(tail(linea, 4), collapse = " "),
      "(?<=Bogot[aá],? D[.] ?C[.],? )[a-z]+ [0-9]{1,2} de [0-9]{4}|(?<=Bogot[aá],? D[.] ?C[.],? )[0-9]{1,2} de [a-z]+ de [0-9]{4}"
    )),
    ultima_modificacion_web = a_fecha(str_extract(
      paste(linea, collapse = " "),
      "(?<=[UÚ]ltima modificaci[oó]n )[A-Za-zéá]+, [0-9]{1,2} de [a-z]+ de [0-9]{4}"
    )),
    .groups = "drop"
  )

eliminadas <- lineas %>% filter(!is.na(motivo)) %>% select(id, tipo, fecha, motivo, texto = linea)
lineas <- lineas %>% filter(is.na(motivo)) %>% select(id, tipo, fecha, linea)

# -----------------------------------------------------------------------------
# 3. De lineas a texto: guiones de fin de linea y saltos de linea
# -----------------------------------------------------------------------------

# une las lineas de un documento. Si una linea termina en letra + guion y la
# siguiente empieza en minuscula, la palabra estaba partida: se une sin guion
unir_lineas <- function(x) {
  texto <- paste(x, collapse = "\n")
  texto <- str_replace_all(texto, "(?<=\\p{Ll})-\n(?=\\p{Ll})", "")
  str_squish(str_replace_all(texto, "\n", " "))
}
documentos <- lineas %>%
  group_by(id, tipo, fecha) %>%
  summarise(
    guiones_fin_linea = sum(str_detect(linea, "\\p{Ll}-$") & str_detect(lead(linea, default = ""), "^\\p{Ll}")),
    texto = unir_lineas(linea),
    .groups = "drop"
  )

# -----------------------------------------------------------------------------
# 4. Restos de la pagina web y titulos
# -----------------------------------------------------------------------------

# (a) En las minutas de 2012 a 2019 el PDF se genero desde la pagina web y
# trae, entre el titulo y el primer parrafo, los enlaces de la pagina
# ("Informe de politica monetaria", "Anexo estadistico", "Contenidos
# relacionados <titulo del comunicado>", "Ultima modificacion <fecha>").
# El bloque va del primer enlace hasta la fecha de "Ultima modificacion"; si
# no trae esa fecha, se quitan solo los nombres de los enlaces. Solo se busca
# en los primeros 1.200 caracteres
enlaces_web <- paste0(
  "Informe de pol[ií]tica monetaria|Informe sobre Inflaci[oó]n|Detalle de la situaci[oó]n macroecon[oó]mica|",
  "Comportamiento de los Mercados Financieros Internacionales y Determinantes de las Din[aá]micas de los Mercados Locales de Capitales|",
  "Determinantes de las Din[aá]micas de los Mercados de Capitales|",
  "Anexo estad[ií]stico|Contenidos relacionados"
)
patron_bloque_web <- paste0(
  "(", enlaces_web, ").{0,700}?[UÚ]ltima modificaci[oó]n [A-Za-zéá]+, [0-9]{1,2} de [a-z]+ de [0-9]{4}"
)
quitar_web <- function(texto) {
  cabeza <- str_sub(texto, 1, 1200)
  bloque <- str_extract(cabeza, patron_bloque_web)
  if (is.na(bloque)) {
    # sin "Ultima modificacion": solo los nombres de los enlaces, si estan
    # antes del primer parrafo (primeros 400 caracteres)
    inicio <- str_sub(texto, 1, 400)
    sueltos <- str_extract_all(inicio, enlaces_web)[[1]]
    if (length(sueltos) == 0) return(list(texto = texto, quitado = NA_character_))
    limpio <- str_squish(str_remove_all(inicio, enlaces_web))
    return(list(texto = str_squish(paste(limpio, str_sub(texto, 401))),
                quitado = paste(sueltos, collapse = " / ")))
  }
  list(texto = str_squish(str_replace(texto, fixed(bloque), " ")), quitado = bloque)
}
web <- map(if_else(documentos$tipo == "minuta", documentos$texto, NA_character_),
           ~ if (is.na(.x)) list(texto = NA_character_, quitado = NA_character_) else quitar_web(.x))
documentos <- documentos %>%
  mutate(texto = coalesce(map_chr(web, "texto"), texto), web_quitado = map_chr(web, "quitado"))
eliminadas <- bind_rows(
  eliminadas,
  documentos %>% filter(!is.na(web_quitado)) %>%
    transmute(id, tipo, fecha, motivo = "restos de la página web", texto = web_quitado)
)

# (b) Titulos. Si el texto empieza con el titulo repetido (la pagina web lo
# trae como titulo y como primer encabezado), se quita la primera copia
quitar_titulo_repetido <- function(texto) {
  p <- str_split(texto, " ")[[1]]
  if (length(p) >= 8) {
    for (k in seq(min(80, length(p) %/% 2), 4)) {
      if (identical(p[1:k], p[(k + 1):(2 * k)])) {
        return(list(titulo = paste(p[1:k], collapse = " "),
                    texto = paste(p[(k + 1):length(p)], collapse = " ")))
      }
    }
  }
  list(titulo = NA_character_, texto = texto)
}
# en los comunicados anteriores a 2019-03 el titulo va antes de la linea
# "Banco de la Republica - Comunicado de la Junta Directiva" (ya eliminada).
# Como el primer parrafo repite la decision, ese titulo no entra al cuerpo
titulos_comunicado_antiguo <- crudo %>%
  filter(tipo == "comunicado", str_detect(texto_crudo, "Banco de la Rep[uú]blica - Comunicado de la Junta Directiva")) %>%
  transmute(id, titulo_antiguo = str_squish(str_extract(
    texto_crudo, regex("^.*?(?=Banco de la Rep[uú]blica - Comunicado de la Junta Directiva)", dotall = TRUE)
  )))
# titulo de procedimiento de las minutas: "Minutas de la reunion de la Junta
# Directiva del Banco de la Republica del <fecha>"
patron_titulo_minuta <- regex(paste0(
  "^Minutas de la reuni[oó]n de la (Junta Directiva del Banco de la Rep[uú]blica|JDBR)",
  " ?(del|de)? .{3,40}? [0-9]{4}"
), ignore_case = TRUE)

documentos <- documentos %>%
  left_join(titulos_comunicado_antiguo, by = "id") %>%
  mutate(
    texto = if_else(
      !is.na(titulo_antiguo) & str_starts(texto, fixed(coalesce(titulo_antiguo, "\u0001"))),
      str_squish(str_sub(texto, nchar(coalesce(titulo_antiguo, "")) + 1)), texto
    ),
    rep = map(texto, quitar_titulo_repetido),
    titulo = coalesce(titulo_antiguo, map_chr(rep, "titulo")),
    texto = if_else(is.na(titulo_antiguo), map_chr(rep, "texto"), texto),
    # desde 2023 el titulo de la minuta es un titular con la decision
    # ("Minutas BanRep: ..."), que se repite en el cuerpo: marca el formato E
    titular_nuevo = tipo == "minuta" & str_detect(texto, regex("^Minutas( Banrep)?:", ignore_case = TRUE)),
    titulo_proc = if_else(tipo == "minuta", str_extract(texto, patron_titulo_minuta), NA_character_),
    texto = if_else(!is.na(titulo_proc), str_squish(str_remove(texto, patron_titulo_minuta)), texto),
    titulo = coalesce(titulo, titulo_proc),
    # cierre "Bogota D. C., enero 05 de 2009." de algunas minutas
    texto = str_squish(str_remove(texto, "Bogot[aá],? D[.] ?C[.],? [A-Za-z0-9 ]{0,30}[0-9]{4}[.]?$"))
  ) %>%
  select(-rep, -titulo_antiguo, -titulo_proc, -web_quitado)

# -----------------------------------------------------------------------------
# 5. Secciones de las minutas
# -----------------------------------------------------------------------------

# encabezados de seccion. Se buscan en todo el texto y no solo al comienzo de
# la linea, porque en algunos PDF generados desde la web el encabezado quedo
# pegado al parrafo anterior ("... (seccion 2). 1. SITUACION INFLACIONARIA")
patrones_encabezado <- list(
  tecnico_a = regex("\\b1[.]\\s*(antecedentes|situaci[oó]n inflacionaria y de crecimiento econ[oó]mico)", ignore_case = TRUE),
  tecnico_b = regex("\\b1[.]\\s*contexto macroecon[oó]mico", ignore_case = TRUE),
  discusion = regex("\\b[12][.]\\s*discusi[oó]n y opciones de pol[ií]tica", ignore_case = TRUE),
  decision  = regex("\\b[23][.]\\s*decisi[oó]n de pol[ií]tica", ignore_case = TRUE)
)
# frase del preambulo que anuncia el contenido; se usa cuando una minuta trae
# el encabezado de la decision pero no el de la discusion
patron_fin_preambulo <- "A continuaci[oó]n,? se (rese[ñn]an|se[ñn]alan|presenta|hace)[^.]*[.]"

separar_secciones <- function(texto, titular_nuevo) {
  pos <- map_dfr(names(patrones_encabezado), function(k) {
    m <- str_locate(texto, patrones_encabezado[[k]])
    tibble(encabezado = k, ini = m[1, "start"], fin = m[1, "end"])
  }) %>% filter(!is.na(ini)) %>% arrange(ini)

  formato <- case_when(
    "tecnico_a" %in% pos$encabezado ~ "A",
    "tecnico_b" %in% pos$encabezado ~ "B",
    "decision" %in% pos$encabezado ~ "C",
    titular_nuevo ~ "E",
    TRUE ~ "D"
  )
  if (nrow(pos) == 0) {
    return(list(formato = formato, encabezados = NA_character_,
                secciones = tibble(seccion = "cuerpo", texto = texto)))
  }
  cortes <- c(pos$fin + 1, nchar(texto) + 1)
  secciones <- tibble(
    seccion = c("preambulo", str_replace(pos$encabezado, "tecnico_[ab]", "equipo_tecnico")),
    texto = c(str_sub(texto, 1, pos$ini[1] - 1),
              map2_chr(pos$fin + 1, c(pos$ini[-1] - 1, nchar(texto)), ~ str_sub(texto, .x, .y)))
  )
  # formato C sin encabezado de discusion: lo que sigue a "A continuacion..."
  if (formato == "C" && !"discusion" %in% secciones$seccion) {
    pre <- secciones$texto[1]
    fin <- str_locate(pre, patron_fin_preambulo)[1, "end"]
    if (!is.na(fin)) {
      secciones <- bind_rows(
        tibble(seccion = c("preambulo", "discusion"),
               texto = c(str_sub(pre, 1, fin), str_sub(pre, fin + 1))),
        secciones[-1, ]
      )
    }
  }
  list(formato = formato,
       encabezados = paste(str_sub(texto, pos$ini, pos$fin), collapse = " / "),
       secciones = secciones %>% mutate(texto = str_squish(texto)))
}

sep <- map2(documentos$texto, documentos$titular_nuevo, separar_secciones)
documentos <- documentos %>%
  mutate(
    formato = if_else(tipo == "minuta", map_chr(sep, "formato"), NA_character_),
    encabezados = if_else(tipo == "minuta", map_chr(sep, "encabezados"), NA_character_)
  )
secciones <- documentos %>%
  select(id, tipo, fecha, formato) %>%
  mutate(s = map(sep, "secciones")) %>%
  unnest(s) %>%
  # los comunicados no tienen secciones: todo es cuerpo
  group_by(id) %>%
  mutate(seccion = if (first(tipo) == "comunicado") "cuerpo" else seccion) %>%
  group_by(id, tipo, fecha, formato, seccion) %>%
  summarise(texto = paste(texto, collapse = " "), .groups = "drop") %>%
  mutate(palabras = contar_palabras(texto))

# -----------------------------------------------------------------------------
# 6. Base por documento
# -----------------------------------------------------------------------------

# "texto": todo el documento limpio (sin titulo ni encabezados de seccion).
# "texto_junta": lo que resena la discusion y la decision de la Junta: en las
# minutas con secciones (formatos A a C), discusion + decision, sin el
# preambulo de asistentes ni la seccion del equipo tecnico; en las minutas sin
# secciones (D y E) y en los comunicados, todo el cuerpo
orden_seccion <- c("preambulo", "equipo_tecnico", "discusion", "decision", "cuerpo")
pegar <- function(texto, seccion, cuales) {
  i <- which(seccion %in% cuales)
  paste(texto[i][order(match(seccion[i], orden_seccion))], collapse = " ")
}
corpus <- secciones %>%
  group_by(id) %>%
  summarise(
    # `texto` se resume de ultimo: las lineas anteriores usan el vector de
    # textos por seccion, no el texto ya pegado
    texto_junta = pegar(texto, seccion, c("discusion", "decision", "cuerpo")),
    palabras_preambulo = sum(palabras[seccion == "preambulo"]),
    palabras_equipo_tecnico = sum(palabras[seccion == "equipo_tecnico"]),
    texto = pegar(texto, seccion, orden_seccion),
    .groups = "drop"
  ) %>%
  left_join(select(documentos, id, tipo, fecha, formato, titulo, encabezados, guiones_fin_linea), by = "id") %>%
  mutate(
    palabras = contar_palabras(texto),
    palabras_junta = contar_palabras(texto_junta),
    periodo = asignar_periodo(fecha)
  ) %>%
  left_join(select(crudo, id, archivo, paginas, palabras_crudo), by = "id") %>%
  left_join(fechas_texto, by = "id") %>%
  arrange(tipo, fecha)

stopifnot(nrow(corpus) == 393, all(corpus$palabras_junta > 30))

saveRDS(corpus, "01_Datos/02_Procesados/corpus_texto.rds")
saveRDS(filter(secciones, tipo == "minuta"), "01_Datos/02_Procesados/secciones_minutas.rds")

# -----------------------------------------------------------------------------
# 7. Verificaciones
# -----------------------------------------------------------------------------

# (a) la fecha del nombre del archivo frente a la fecha de publicacion que
# trae el comunicado
verif_com <- corpus %>% filter(!is.na(fecha_publicacion_comunicado))
message("Comunicados con 'Fecha de publicacion' en el texto: ", nrow(verif_com),
        "; coinciden con el nombre del archivo: ",
        sum(verif_com$fecha_publicacion_comunicado == verif_com$fecha), ".")

# (b) rezago entre la reunion y la fecha con que cierra la minuta (solo en
# las minutas que la traen)
verif_min <- corpus %>% filter(!is.na(fecha_cierre_minuta)) %>%
  mutate(rezago = as.integer(fecha_cierre_minuta - fecha))
message("Minutas que cierran con fecha ('Bogota D. C., ...'): ", nrow(verif_min),
        " (", min(verif_min$fecha), " a ", max(verif_min$fecha), "); rezago mediano frente a la reunion: ",
        median(verif_min$rezago), " dias (min ", min(verif_min$rezago), ", max ", max(verif_min$rezago), ").")

# (c) los formatos son contiguos en el tiempo y empiezan en las fechas de
# 00_funciones_texto.R
formatos_obs <- corpus %>% filter(tipo == "minuta") %>%
  group_by(formato) %>% summarise(inicio = min(fecha), fin = max(fecha), n = n(), .groups = "drop")
stopifnot(
  identical(formatos_obs$inicio, formatos_minutas$inicio),
  all(formatos_obs$fin[-nrow(formatos_obs)] < formatos_obs$inicio[-1])
)

# -----------------------------------------------------------------------------
# 8. Tablas
# -----------------------------------------------------------------------------

n_com <- sum(corpus$tipo == "comunicado")
n_min <- sum(corpus$tipo == "minuta")
etiqueta_tipo <- c(comunicado = "Comunicados", minuta = "Minutas")

# --- 8.1 resumen de la extraccion --------------------------------------------
resumen <- corpus %>%
  group_by(tipo) %>%
  summarise(
    documentos = n(),
    sin_texto = sum(palabras_crudo < 50),
    desde = min(fecha), hasta = max(fecha),
    paginas = median(paginas),
    palabras_crudo = median(palabras_crudo),
    palabras = median(palabras),
    palabras_junta = median(palabras_junta),
    guiones = sum(guiones_fin_linea),
    .groups = "drop"
  ) %>%
  left_join(count(eliminadas, tipo, name = "lineas_eliminadas"), by = "tipo") %>%
  mutate(tipo = etiqueta_tipo[tipo])

tabla_resumen <- resumen %>%
  mutate(across(c(desde, hasta), ~ format(.x, "%Y-%m-%d"))) %>%
  gt() %>%
  cols_label(
    tipo = "Documento", documentos = "PDF", sin_texto = "Sin texto extraíble",
    desde = "Primera reunión", hasta = "Última reunión", paginas = "Páginas (mediana)",
    palabras_crudo = "Palabras, texto crudo (mediana)", palabras = "Palabras, texto limpio (mediana)",
    palabras_junta = "Palabras, discusión de la Junta (mediana)",
    guiones = "Guiones de fin de línea unidos", lineas_eliminadas = "Líneas eliminadas"
  ) %>%
  fmt_number(columns = c(paginas, palabras_crudo, palabras, palabras_junta, guiones, lineas_eliminadas),
             decimals = 0, sep_mark = ".", dec_mark = ",") %>%
  estilo_tabla(
    titulo = "Extracción del texto de los documentos de la Junta",
    subtitulo = "Documentos leídos, extensión antes y después de la limpieza",
    nota = nota_tabla("conjunto", n = nrow(corpus), extra = c(
      "Texto limpio: sin números de página, restos de la página web, encabezados, pies ni títulos. Discusión de la Junta: en las minutas con secciones, solo «Discusión y opciones de política» y «Decisión de política».",
      "El informe técnico del 30 de abril de 2020 no es una minuta y no se procesa."
    ))
  )
guardar_tabla("conjunto_resumen_extraccion", tabla_resumen, resumen, carpeta_salida)

# --- 8.2 lineas eliminadas (auditoria completa en .csv) ----------------------
write_csv(eliminadas, file.path("03_Resultados/Tablas", carpeta_salida, "conjunto_lineas_eliminadas.csv"))

# muestra en tres minutas de formatos distintos: que se quito
ejemplos_min <- c("2008-12-19_minuta", "2015-09-25_minuta", "2019-01-31_minuta")
quitado <- bind_rows(
  eliminadas %>% filter(id %in% ejemplos_min) %>%
    group_by(id, motivo) %>%
    summarise(lineas = n(), texto = str_trunc(paste(texto, collapse = " / "), 420), .groups = "drop"),
  corpus %>% filter(id %in% ejemplos_min, !is.na(encabezados)) %>%
    transmute(id, motivo = "encabezado de sección (se usa para separar secciones)",
              lineas = str_count(encabezados, " / ") + 1L, texto = encabezados),
  corpus %>% filter(id %in% ejemplos_min, !is.na(titulo)) %>%
    transmute(id, motivo = "título (se guarda aparte)", lineas = NA_integer_, texto = titulo),
  corpus %>% filter(id %in% ejemplos_min, !is.na(fecha_cierre_minuta)) %>%
    transmute(id, motivo = "cierre con ciudad y fecha", lineas = 1L,
              texto = paste0("Bogotá D. C., ", format(fecha_cierre_minuta, "%Y-%m-%d"), " (se guarda como fecha de cierre)"))
) %>%
  arrange(id, motivo) %>%
  left_join(select(corpus, id, palabras_crudo, palabras), by = "id") %>%
  mutate(documento = paste0("Minuta ", str_sub(id, 1, 10), " (", palabras_crudo, " → ", palabras, " palabras)")) %>%
  select(documento, motivo, lineas, texto)

tabla_quitado <- quitado %>%
  gt(groupname_col = "documento") %>%
  cols_label(motivo = "Qué se quitó", lineas = "Líneas", texto = "Texto eliminado") %>%
  sub_missing(missing_text = "—") %>%
  cols_width(motivo ~ px(210), lineas ~ px(60), texto ~ px(640)) %>%
  tab_style(cell_text(weight = "bold"), cells_row_groups()) %>%
  estilo_tabla(
    titulo = "Qué se elimina del texto de las minutas",
    subtitulo = "Tres minutas de formatos distintos: todo lo que la limpieza quita, palabra por palabra",
    nota = nota_tabla("minutas", n = 3, periodo = "reuniones del 19 de diciembre de 2008, el 25 de septiembre de 2015 y el 31 de enero de 2019", extra =
      "Las líneas eliminadas de los 393 documentos están en conjunto_lineas_eliminadas.csv.")
  )
guardar_tabla("minutas_texto_eliminado", tabla_quitado, quitado, carpeta_salida)

# --- 8.3 antes y despues ------------------------------------------------------
ejemplos_ad <- c("2008-01-25_minuta", "2013-12-20_minuta", "2024-01-31_comunicado")
antes_despues <- corpus %>%
  filter(id %in% ejemplos_ad) %>%
  left_join(select(crudo, id, texto_crudo), by = "id") %>%
  transmute(
    documento = paste0(etiqueta_tipo[tipo], " ", fecha),
    antes = str_trunc(str_replace_all(str_trim(texto_crudo), "\n+", " ¶ ") %>% str_replace_all(" {2,}", " "), 620),
    despues = str_trunc(texto, 620)
  )
tabla_ad <- antes_despues %>%
  gt() %>%
  cols_label(documento = "Documento", antes = "Antes: texto crudo de pdf_text() (¶ = salto de línea)",
             despues = "Después: texto limpio") %>%
  cols_width(documento ~ px(110), antes ~ px(430), despues ~ px(430)) %>%
  tab_style(cell_text(size = px(11.5)), cells_body(columns = c(antes, despues))) %>%
  estilo_tabla(
    titulo = "Texto antes y después de la limpieza",
    subtitulo = "Comienzo de tres documentos (primeros 620 caracteres)",
    nota = nota_tabla("conjunto", n = 3, periodo = "tres documentos de ejemplo")
  )
guardar_tabla("conjunto_antes_despues", tabla_ad, antes_despues, carpeta_salida)

# --- 8.4 decision de cada reunion y verificacion de los periodos -------------

# direccion de la decision, leida del titulo y del comienzo del comunicado
# (la primera expresion de decision que aparece)
patrones_decision <- c(
  sube = "aument|increment|subi[oór]|elev[aó]",
  baja = "reduc|reduj|disminu|baj[aóe]|recort",
  mantiene = "mant[eiu]|inalterad|sin modificar|no modificar"
)
direccion <- function(texto) {
  texto <- str_to_lower(texto)
  pos <- map_int(patrones_decision, ~ {
    p <- str_locate(texto, .x)[1, "start"]
    if (is.na(p)) .Machine$integer.max else as.integer(p)
  })
  if (all(pos == .Machine$integer.max)) NA_character_ else names(pos)[which.min(pos)]
}
# primera oracion que anuncia la decision
cita_decision <- function(texto) {
  o <- partir_oraciones(texto)[[1]]
  i <- which(str_detect(str_to_lower(o), "tasa") &
               str_detect(str_to_lower(o), paste(patrones_decision, collapse = "|")))
  if (length(i) == 0) NA_character_ else str_trunc(o[i[1]], 200)
}

decisiones <- bind_rows(
  # fuente principal: el comunicado (titulo + comienzo del cuerpo)
  corpus %>% filter(tipo == "comunicado") %>%
    transmute(fecha, fuente = "comunicado", cuerpo = texto,
              base = paste(coalesce(titulo, ""), str_sub(texto, 1, 500))),
  # reuniones sin comunicado en los datos: seccion de decision de la minuta
  secciones %>% filter(tipo == "minuta", seccion == "decision",
                       !fecha %in% corpus$fecha[corpus$tipo == "comunicado"]) %>%
    transmute(fecha, fuente = "minuta (sin comunicado)", cuerpo = texto, base = texto)
) %>%
  # la direccion se lee del titulo y del comienzo del cuerpo; la cita, solo
  # del cuerpo (el titulo repite la decision)
  mutate(decision = map_chr(base, direccion), cita = map_chr(cuerpo, cita_decision),
         periodo = asignar_periodo(fecha)) %>%
  arrange(fecha)
# 04_bigramas.R las usa para leer la direccion del voto de la minoria
saveRDS(select(decisiones, fecha, periodo, fuente, decision, cita),
        "01_Datos/02_Procesados/decisiones_reunion.rds")
write_csv(select(decisiones, fecha, periodo, fuente, decision, cita),
          file.path("03_Resultados/Tablas", carpeta_salida, "conjunto_decisiones_por_reunion.csv"))

etiqueta_decision <- c(sube = "Alzas", baja = "Recortes", mantiene = "Sin cambio")
conteo_periodo <- decisiones %>%
  mutate(decision = coalesce(etiqueta_decision[decision], "Sin clasificar")) %>%
  count(periodo, decision) %>%
  pivot_wider(names_from = decision, values_from = n, values_fill = 0)
for (col in c("Alzas", "Recortes", "Sin cambio", "Sin clasificar")) {
  if (!col %in% names(conteo_periodo)) conteo_periodo[[col]] <- 0L
}

datos_periodos <- periodos %>%
  left_join(decisiones %>% select(fecha, fuente, cita), by = c("inicio" = "fecha")) %>%
  left_join(conteo_periodo, by = "periodo") %>%
  left_join(corpus %>% count(periodo, tipo) %>% pivot_wider(names_from = tipo, values_from = n, values_fill = 0),
            by = "periodo") %>%
  transmute(periodo = as.character(periodo), nombre, inicio, fin, fuente, cita,
            Alzas, Recortes, `Sin cambio`, `Sin clasificar`, comunicados = comunicado, minutas = minuta)

tabla_periodos <- datos_periodos %>%
  mutate(across(c(inicio, fin), ~ format(.x, "%Y-%m-%d"))) %>%
  gt() %>%
  cols_label(periodo = "", nombre = "Periodo", inicio = "Reunión que lo abre", fin = "Hasta",
             fuente = "Fuente de la cita", cita = "Decisión que abre el periodo (cita)",
             comunicados = "Comunicados", minutas = "Minutas") %>%
  tab_spanner("Decisiones dentro del periodo", columns = c(Alzas, Recortes, `Sin cambio`, `Sin clasificar`)) %>%
  tab_spanner("Documentos", columns = c(comunicados, minutas)) %>%
  cols_width(periodo ~ px(45), nombre ~ px(150), inicio ~ px(105), fin ~ px(105), fuente ~ px(115),
             cita ~ px(430), everything() ~ px(108)) %>%
  tab_style(cell_text(size = px(11.5)), cells_body(columns = cita)) %>%
  estilo_tabla(
    titulo = "Periodos de política monetaria definidos a priori",
    subtitulo = "Cada periodo lo abre la primera reunión en que la Junta cambia la dirección de la tasa o entra en pausa",
    nota = nota_tabla("conjunto", n = nrow(corpus), extra = c(
      "Las decisiones se leen del título y del primer párrafo de cada comunicado; en las reuniones sin comunicado en los datos, de la sección de decisión de la minuta.",
      "«Sin clasificar»: reuniones cuyo comunicado no nombra la decisión de tasa con las expresiones buscadas."
    ))
  )
guardar_tabla("conjunto_periodos", tabla_periodos, datos_periodos, carpeta_salida)

# --- 8.5 formatos de las minutas ----------------------------------------------
datos_formatos <- corpus %>%
  filter(tipo == "minuta") %>%
  group_by(formato) %>%
  summarise(
    inicio = min(fecha), fin = max(fecha), minutas = n(),
    palabras = median(palabras),
    palabras_equipo_tecnico = median(palabras_equipo_tecnico),
    palabras_junta = median(palabras_junta),
    pct_junta = 100 * sum(palabras_junta) / sum(palabras),
    .groups = "drop"
  ) %>%
  left_join(select(formatos_minutas, formato, descripcion), by = "formato") %>%
  left_join(
    # evidencia: los encabezados de la primera minuta de cada formato, o el
    # comienzo del texto si no tiene encabezados
    corpus %>% filter(tipo == "minuta") %>% group_by(formato) %>% slice_min(fecha, n = 1) %>% ungroup() %>%
      transmute(formato, evidencia = coalesce(encabezados, paste0("Sin encabezados. Empieza: «", str_trunc(coalesce(titulo, texto), 150), "»"))),
    by = "formato"
  ) %>%
  select(formato, descripcion, inicio, fin, minutas, palabras, palabras_equipo_tecnico, palabras_junta, pct_junta, evidencia)

tabla_formatos <- datos_formatos %>%
  mutate(across(c(inicio, fin), ~ format(.x, "%Y-%m-%d"))) %>%
  gt() %>%
  cols_label(formato = "", descripcion = "Formato", inicio = "Primera reunión", fin = "Última reunión",
             minutas = "Minutas", palabras = "Total", palabras_equipo_tecnico = "Equipo técnico",
             palabras_junta = "Discusión de la Junta", pct_junta = "% del texto que es de la Junta",
             evidencia = "Texto que lo muestra (primera minuta del formato)") %>%
  tab_spanner("Palabras por minuta (mediana)", columns = c(palabras, palabras_equipo_tecnico, palabras_junta)) %>%
  fmt_number(columns = c(palabras, palabras_equipo_tecnico, palabras_junta), decimals = 0, sep_mark = ".", dec_mark = ",") %>%
  fmt_number(columns = pct_junta, decimals = decimales$porcentaje, dec_mark = ",", sep_mark = ".") %>%
  cols_width(descripcion ~ px(190), evidencia ~ px(330)) %>%
  tab_style(cell_text(size = px(11.5)), cells_body(columns = evidencia)) %>%
  estilo_tabla(
    titulo = "Formatos de las minutas y reunión en que cambia cada uno",
    subtitulo = "Hasta abril de 2019 la minuta incluye una sección con la visión del equipo técnico, que no es discusión de la Junta",
    nota = nota_tabla("minutas", n = n_min, extra =
      "El formato se identifica por los encabezados de sección de cada minuta. Discusión de la Junta: secciones «Discusión y opciones de política» y «Decisión de política» (formatos A a C) o todo el cuerpo (D y E).")
  )
guardar_tabla("minutas_cortes_formato", tabla_formatos, datos_formatos, carpeta_salida)

# metadatos de cada documento, sin el texto, para trazabilidad
write_csv(
  corpus %>% select(id, tipo, fecha, periodo, formato, paginas, palabras_crudo, palabras,
                    palabras_preambulo, palabras_equipo_tecnico, palabras_junta, guiones_fin_linea,
                    fecha_publicacion_comunicado, fecha_cierre_minuta, ultima_modificacion_web),
  file.path("03_Resultados/Tablas", carpeta_salida, "conjunto_metadatos_documentos.csv")
)

# -----------------------------------------------------------------------------
# 9. Figuras
# -----------------------------------------------------------------------------

nota_cortes <- paste0(
  "Líneas punteadas: reuniones en que cambia el formato de las minutas (",
  paste(format(cortes_formato, "%Y-%m-%d"), collapse = ", "), ")."
)

# --- 9.1 palabras por documento en el tiempo, por tipo ------------------------
datos_fig <- corpus %>% mutate(tipo = etiqueta_tipo[tipo])
fig_palabras <- ggplot(datos_fig, aes(fecha, palabras, color = tipo)) +
  capa_cortes_formato(cortes_formato) +
  geom_point(size = 1.3, alpha = 0.85) +
  scale_color_manual(values = colores_tipo) +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
  scale_y_continuous(labels = scales::label_number(big.mark = ".", decimal.mark = ",")) +
  labs(
    title = "Extensión de los documentos de la Junta",
    subtitle = subtitulo_ambos,
    x = "Fecha de la reunión", y = "Palabras por documento (texto limpio)",
    caption = paste0("n = ", n_com, " comunicados y ", n_min, " minutas. Cada punto es un documento. ", nota_cortes)
  ) +
  tema_presentacion
guardar_figura("conjunto_palabras_por_documento.png", fig_palabras, carpeta_salida)

# --- 9.2 composicion de las minutas por seccion --------------------------------
etiqueta_seccion <- c(
  preambulo = "Preámbulo (asistentes)", equipo_tecnico = "Visión del equipo técnico",
  junta = "Discusión y decisión de la Junta"
)
datos_secc <- corpus %>%
  filter(tipo == "minuta") %>%
  transmute(fecha, preambulo = palabras_preambulo, equipo_tecnico = palabras_equipo_tecnico, junta = palabras_junta) %>%
  pivot_longer(-fecha, names_to = "seccion", values_to = "palabras") %>%
  mutate(seccion = factor(etiqueta_seccion[seccion], levels = etiqueta_seccion[c("equipo_tecnico", "preambulo", "junta")]))
fig_secciones <- ggplot(datos_secc, aes(fecha, palabras, fill = seccion)) +
  geom_col(width = 25) +
  capa_cortes_formato(cortes_formato) +
  scale_fill_manual(values = setNames(c(gris_grilla, gris_nota, paleta_categorica[2]), levels(datos_secc$seccion))) +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
  scale_y_continuous(labels = scales::label_number(big.mark = ".", decimal.mark = ",")) +
  labs(
    title = "Qué parte de cada minuta es discusión de la Junta",
    subtitle = subtitulo_minutas,
    x = "Fecha de la reunión", y = "Palabras por minuta",
    caption = paste0("n = ", n_min, " minutas. Cada barra es una minuta. ", nota_cortes)
  ) +
  tema_presentacion
guardar_figura("minutas_palabras_por_seccion.png", fig_secciones, carpeta_salida)

message("01_extraer_texto: corpus de ", nrow(corpus), " documentos guardado en 01_Datos/02_Procesados/corpus_texto.rds")
