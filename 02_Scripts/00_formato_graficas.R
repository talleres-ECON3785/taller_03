# =============================================================================
# Formato compartido de las graficas del proyecto
# Taller 3 - ECON-3785
#
# Este script NO genera figuras: solo define la paleta, el tema, los
# subtitulos por fuente y la exportacion que deben usar TODAS las graficas del
# taller. Viene del Taller 2 (mismo estilo, para que las figuras de los tres
# talleres se vean como una sola familia); se adaptaron los subtitulos y las
# notas al nuevo cliente (mesa de renta fija) y a las nuevas fuentes
# (comunicados y minutas de la Junta del Banco de la Republica).
#
# Uso: al inicio de cualquier script que produzca figuras,
#   source("02_Scripts/00_formato_graficas.R")
# y despues construir cada grafica con `tema_presentacion` (mas
# `tema_paneles` si usa facetas) y guardarla con `guardar_figura()`.
# =============================================================================

# los paquetes los carga 00_main.R con pacman

# -----------------------------------------------------------------------------
# 1. Paleta categorica
# -----------------------------------------------------------------------------

# terna sobria del proyecto: azul, ocre y verde-azulado, distinguibles entre
# si incluso con daltonismo. Es la misma de los talleres anteriores
paleta_categorica <- c(
  "#2B5FA3", # azul
  "#B8863B", # ocre
  "#0E8A6C"  # verde-azulado
)

# una misma categoria conserva su color en todas las figuras: los comunicados
# siempre en azul y las minutas siempre en ocre
colores_tipo <- c(
  "Comunicados" = paleta_categorica[1],
  "Minutas"     = paleta_categorica[2]
)

# grises de apoyo: texto principal, texto secundario / lineas de referencia,
# notas al pie y lineas de la grilla. No son categorias, son estructura
gris_texto      <- "#0b0b0b"
gris_secundario <- "#52514e"
gris_nota       <- "#898781"
gris_grilla     <- "#e1e0d9"

# -----------------------------------------------------------------------------
# 2. Subtitulos por fuente
# -----------------------------------------------------------------------------

# cada grafica declara en su subtitulo de que documentos viene y el periodo,
# porque comunicados y minutas no son intercambiables: el comunicado anuncia
# la decision el dia de la reunion y la minuta resume la discusion
subtitulo_comunicados <- paste(
  "Comunicados de la Junta Directiva del Banco de la República,",
  "enero de 2007 a septiembre de 2026."
)
subtitulo_minutas <- paste(
  "Minutas de la Junta Directiva del Banco de la República,",
  "junio de 2007 a septiembre de 2026."
)
subtitulo_ambos <- paste(
  "Comunicados y minutas de la Junta Directiva del Banco de la República,",
  "2007 a 2026."
)

# toda la sesion exploratoria es descriptiva: se declara en la nota al pie
nota_exploratoria <- "Análisis exploratorio y descriptivo del texto; no se cruza con series macroeconómicas."

# -----------------------------------------------------------------------------
# 3. Tema
# -----------------------------------------------------------------------------

# tema compartido por todas las graficas del proyecto
tema_presentacion <- theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 16, color = gris_texto),
    plot.subtitle = element_text(
      color = gris_secundario, size = 11, margin = margin(b = 10)
    ),
    plot.caption = element_text(
      color = gris_nota, size = 8.5, hjust = 0, margin = margin(t = 10)
    ),
    plot.title.position = "plot",
    plot.caption.position = "plot",
    axis.text.x = element_text(size = 11, color = gris_texto),
    axis.text.y = element_text(color = gris_secundario),
    axis.title = element_text(color = gris_secundario),
    legend.position = "top",
    legend.justification = "left",
    legend.title = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_line(color = gris_grilla, linewidth = 0.4)
  )

# complemento para las graficas con facetas: el titulo de cada panel hace de
# etiqueta de la categoria, asi que va en negrita y sin caja de fondo
tema_paneles <- theme(
  strip.background = element_blank(),
  strip.text = element_text(face = "bold", size = 10.5, color = gris_texto,
                            hjust = 0)
)

# complemento para barras horizontales (palabras en el eje y): la grilla va
# en el eje de la cifra y las palabras se leen en gris oscuro
tema_barras_h <- theme(
  panel.grid.major.y = element_blank(),
  panel.grid.major.x = element_line(color = gris_grilla, linewidth = 0.4),
  axis.text.y = element_text(color = gris_texto, size = 9),
  axis.text.x = element_text(size = 9, color = gris_secundario)
)

# -----------------------------------------------------------------------------
# 4. Marcas de referencia en series de tiempo
# -----------------------------------------------------------------------------

# lineas verticales punteadas en las fechas de los cortes de formato de las
# minutas. `cortes` es un vector de fechas (lo define 00_funciones_texto.R).
# Sirven para ver si una medida salta justo donde cambia el formato
capa_cortes_formato <- function(cortes) {
  geom_vline(xintercept = cortes, linetype = "dashed",
             color = gris_nota, linewidth = 0.4)
}

# -----------------------------------------------------------------------------
# 5. Exportacion
# -----------------------------------------------------------------------------

# todas las figuras se exportan con la misma resolucion, fondo blanco
# explicito y la nota al pie partida en renglones. Cada script guarda sus figuras en su propia subcarpeta:
# 03_Resultados/Figuras/<script>/<fuente>_<contenido>.png, con <fuente> =
# 'comunicados', 'minutas', 'macro' o 'conjunto'. `carpeta` es el nombre del
# script sin '.R'; la subcarpeta debe estar en `carpetas_salida` de 00_main.R
# (esta funcion no crea carpetas)
guardar_figura <- function(nombre_archivo, grafica, carpeta,
                           width = 9, height = 6, dpi = 300) {
  # la nota al pie se parte en renglones segun el ancho de la figura (unos 17
  # caracteres por pulgada con el tamano de letra de la nota); si no, ggplot
  # la corta en el borde derecho
  if (!is.null(grafica$labels$caption)) {
    grafica$labels$caption <- str_wrap(grafica$labels$caption, width = round(width * 17))
  }
  ggsave(
    file.path("03_Resultados/Figuras", carpeta, nombre_archivo),
    grafica,
    width = width, height = height, dpi = dpi, bg = "white"
  )
}
