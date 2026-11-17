# =============================================================================
# Formato compartido de las tablas del proyecto
# Taller 3 - ECON-3785
#
# Este script NO genera tablas: solo define el estilo y la funcion de
# exportacion que deben usar TODAS las tablas de la presentacion. Es el
# equivalente de '00_formato_graficas.R' para las tablas. Viene del Taller 2;
# se adaptaron los decimales y las notas a las nuevas fuentes (comunicados y
# minutas de la Junta del Banco de la Republica).
#
# Uso: al inicio de cualquier script que produzca tablas,
#   source("02_Scripts/00_formato_tablas.R")
# construir la tabla con `gt()`, aplicarle `estilo_tabla()` y guardarla con
# `guardar_tabla()`.
#
# La tabla que entra a la diapositiva es la exportada, sin retoques manuales:
# si algo debe verse distinto, se cambia aqui o en el script que la crea.
# =============================================================================

# los paquetes los carga 00_main.R con pacman

# la paleta (azul, ocre, verde-azulado y grises) vive en el formato de las
# graficas; las tablas la reutilizan para verse como una sola familia
source("02_Scripts/00_formato_graficas.R")

# -----------------------------------------------------------------------------
# 1. Decimales fijos por tipo de cifra
# -----------------------------------------------------------------------------

# cada tipo de cifra tiene un numero de decimales fijo en todo el proyecto
decimales <- list(
  por_mil     = 1, # frecuencia por cada 1.000 palabras
  porcentaje  = 1, # porcentajes de documentos o de tokens
  razon       = 2, # razon de frecuencias entre dos grupos
  tfidf       = 4, # TF-IDF (numeros pequenos)
  proporcion  = 3, # pesos de topicos (theta) y probabilidades (beta)
  lift        = 1, # lift de una palabra en un topico
  conteo      = 0  # n de documentos, palabras y frecuencias
)

# -----------------------------------------------------------------------------
# 2. Notas al pie
# -----------------------------------------------------------------------------

# cada tabla declara la fuente (comunicados, minutas o ambos), el periodo y el
# n de documentos. Cada elemento de `extra` es un parrafo aparte
nota_tabla <- function(fuente = c("comunicados", "minutas", "conjunto"),
                       n = NULL, periodo = NULL, extra = NULL) {
  fuente <- match.arg(fuente)
  texto_fuente <- switch(
    fuente,
    comunicados = "Comunicados de la Junta Directiva del Banco de la República",
    minutas     = "Minutas de la Junta Directiva del Banco de la República",
    conjunto    = "Comunicados y minutas de la Junta Directiva del Banco de la República"
  )
  if (is.null(periodo)) {
    periodo <- switch(
      fuente,
      comunicados = "enero de 2007 a septiembre de 2026",
      minutas     = "junio de 2007 a septiembre de 2026",
      conjunto    = "2007 a 2026"
    )
  }
  texto_n <- if (is.null(n)) "" else paste0(
    " (n = ", format(n, big.mark = ".", decimal.mark = ",", scientific = FALSE),
    " documentos)"
  )
  c(paste0(texto_fuente, ", ", periodo, texto_n, "."), extra)
}

# -----------------------------------------------------------------------------
# 3. Estilo
# -----------------------------------------------------------------------------

# aplica el estilo del proyecto a una tabla `gt`: encabezado de columnas en
# azul con texto blanco, titulos alineados a la izquierda, filas separadas con
# lineas finas de la grilla y la nota al pie en gris. Los titulos, subtitulos
# y etiquetas de columna se definen en el script de la tabla (en espanol y sin
# nombres de variables del codigo)
estilo_tabla <- function(tabla, titulo = NULL, subtitulo = NULL, nota = NULL) {
  if (!is.null(titulo)) {
    tabla <- tab_header(tabla, title = titulo, subtitle = subtitulo)
  }
  # cada elemento de `nota` se agrega como un parrafo aparte
  for (parrafo in nota) {
    tabla <- tab_source_note(tabla, source_note = parrafo)
  }
  # un guion entre dos cifras ("2014-05-30", "2007-08") se cambia por un guion
  # que no permite salto de renglon, para que las fechas no se partan
  sin_corte <- function(x) gsub("([0-9])-(?=[0-9])", "\\1\u2011", x, perl = TRUE)
  tabla |>
    text_transform(locations = cells_body(), fn = sin_corte) |>
    text_transform(locations = cells_column_labels(), fn = sin_corte) |>
    opt_table_font(font = list(google_font("Inter"), default_fonts())) |>
    tab_options(
      table.font.size = px(14),
      table.background.color = "white",
      table.border.top.style = "none",
      table.border.bottom.color = gris_grilla,
      heading.align = "left",
      heading.title.font.size = px(18),
      heading.subtitle.font.size = px(13),
      heading.border.bottom.style = "none",
      column_labels.background.color = paleta_categorica[1],
      column_labels.font.weight = "bold",
      column_labels.border.top.style = "none",
      column_labels.border.bottom.style = "none",
      stub.border.style = "none",
      table_body.hlines.color = gris_grilla,
      table_body.border.bottom.color = gris_grilla,
      source_notes.font.size = px(11)
    ) |>
    tab_style(
      style = cell_text(color = "white"),
      locations = cells_column_labels()
    ) |>
    tab_style(
      style = cell_text(color = gris_texto, weight = "bold"),
      locations = cells_title(groups = "title")
    ) |>
    tab_style(
      style = cell_text(color = gris_secundario),
      locations = cells_title(groups = "subtitle")
    ) |>
    tab_style(
      style = cell_text(color = gris_nota),
      locations = cells_source_notes()
    )
}

# -----------------------------------------------------------------------------
# 4. Exportacion
# -----------------------------------------------------------------------------

# localiza Chrome o Chromium: primero la variable de entorno CHROME_PATH (para
# rutas no estandar) y luego las rutas habituales de macOS, Linux y Windows
ruta_chrome <- function() {
  candidatos <- c(
    Sys.getenv("CHROME_PATH"),
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "/Applications/Chromium.app/Contents/MacOS/Chromium",
    Sys.which(c("google-chrome", "google-chrome-stable", "chromium",
                "chromium-browser", "chrome")),
    "C:/Program Files/Google/Chrome/Application/chrome.exe",
    "C:/Program Files (x86)/Google/Chrome/Application/chrome.exe"
  )
  candidatos <- candidatos[nzchar(candidatos) & file.exists(candidatos)]
  if (length(candidatos) == 0) {
    stop("No se encontro Chrome ni Chromium. Instalalo o define CHROME_PATH.")
  }
  candidatos[[1]]
}

# exporta la tabla en dos formatos con el mismo nombre base:
#   - .png de alta resolucion con el formato final, que se inserta tal cual en
#     la diapositiva. Se genera sin `webshot2` (su dependencia `websocket` no
#     compila en todas las maquinas): `gt` escribe un HTML, Chrome en modo
#     headless mide la tabla y la fotografia con ese tamano exacto
#   - .csv con las cifras sin formato, para trazabilidad
# Cada script guarda sus tablas en su propia subcarpeta:
# 03_Resultados/Tablas/<script>/<fuente>_<contenido>.<ext>, donde <script> es el
# nombre del script sin '.R' y <fuente> es 'comunicados', 'minutas', 'macro' o
# 'conjunto' (p. ej. 'minutas_cortes_formato'). `carpeta` es ese <script>; `nombre` va sin
# extension; `datos` son las cifras sin formato (un data frame).
# Como `guardar_figura()`, no crea carpetas: asume que 00_main.R ya verifico
# 03_Resultados/Tablas/<script>/.
guardar_tabla <- function(nombre, tabla, datos, carpeta, zoom = 2, margen = 20) {
  chrome <- ruta_chrome()
  html <- tempfile(fileext = ".html")
  on.exit(unlink(html), add = TRUE)
  gtsave(tabla, html)

  # un script mide la tabla en el navegador y deja "ancho x alto" en el titulo
  texto <- readLines(html, warn = FALSE, encoding = "UTF-8")
  medidor <- paste0(
    "<script>window.onload=function(){var r=document.querySelector('table')",
    ".getBoundingClientRect();document.body.style.margin='", margen, "px';",
    "document.title=Math.ceil(r.width)+'x'+Math.ceil(r.height);};</script>"
  )
  writeLines(sub("</body>", paste0(medidor, "</body>"), texto, fixed = TRUE),
             html, useBytes = TRUE)
  url <- paste0("file://", normalizePath(html, winslash = "/"))
  opciones <- c("--headless", "--disable-gpu", "--hide-scrollbars",
                "--no-sandbox")

  dom <- system2(chrome, c(opciones, "--dump-dom", shQuote(url)),
                 stdout = TRUE, stderr = FALSE)
  medidas <- regmatches(
    paste(dom, collapse = "\n"),
    regexec("<title>(\\d+)x(\\d+)</title>", paste(dom, collapse = "\n"))
  )[[1]]
  if (length(medidas) != 3) stop("No se pudo medir la tabla con Chrome.")
  ancho <- as.integer(medidas[2]) + 2 * margen
  alto  <- as.integer(medidas[3]) + 2 * margen + 40 # holgura para el pie

  png <- file.path("03_Resultados/Tablas", carpeta, paste0(nombre, ".png"))
  system2(chrome, c(opciones, paste0("--force-device-scale-factor=", zoom),
                    "--default-background-color=FFFFFFFF",
                    paste0("--window-size=", ancho, ",", alto),
                    paste0("--screenshot=", shQuote(normalizePath(png, mustWork = FALSE))),
                    shQuote(url)),
          stdout = FALSE, stderr = FALSE)
  if (!file.exists(png)) stop("Chrome no genero el .png de ", nombre)

  write_csv(datos, file.path("03_Resultados/Tablas", carpeta, paste0(nombre, ".csv")))
}
