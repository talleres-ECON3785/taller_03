# =============================================================================
# 06. Series macroeconomicas: lectura de los crudos, filtro desde 2000 y RDS
# Taller 3 - ECON-3785
#
# Entradas (01_Datos/01_Crudos/, descargadas a mano; fuentes en el README):
#   brent_2000-26.csv                      Brent, FRED (DCOILBRENTEU), diaria
#   inflacion_variacion_anual_99_26.xlsx   inflacion anual, BanRep, mensual
#   tasa_cambio_real_70_26.xlsx            indices de tasa de cambio real, BanRep, mensual
# Salidas (01_Datos/03_Listos/), una por fuente, solo con fechas >= 2000-01-01:
#   macro_brent.rds       fecha, brent_usd
#   macro_inflacion.rds   fecha (fin de mes) y una columna por serie, en %
#   macro_tcr.rds         fecha (fin de mes) y una columna por indice
# No genera tablas ni figuras. No transforma ni alinea las series con las
# reuniones de la Junta: eso se decide en el script de analisis.
# =============================================================================

# los paquetes los carga 00_main.R con pacman

fecha_inicio <- as.Date("2000-01-01")

# los xlsx del Banco de la Republica traen los nombres de las series en la fila 3
# de la hoja "Series de datos", la fecha (serial de Excel) en la columna 1 y un
# punto "." donde falta el dato; la ultima fila es una nota al pie
leer_banrep <- function(ruta) {
  x <- read_excel(ruta, sheet = "Series de datos", col_names = FALSE,
                  na = ".", .name_repair = "minimal")
  datos <- x[-(1:3), ]
  names(datos) <- c("fecha", str_squish(unlist(x[3, -1])))
  datos |>
    # las filas de rotulo y la nota al pie no son numericas y quedan fuera
    mutate(fecha = as.Date(suppressWarnings(as.numeric(fecha)), origin = "1899-12-30")) |>
    filter(!is.na(fecha), fecha >= fecha_inicio) |>
    mutate(across(-fecha, as.numeric))
}

brent <- read_csv("01_Datos/01_Crudos/brent_2000-26.csv", show_col_types = FALSE) |>
  transmute(fecha = observation_date, brent_usd = DCOILBRENTEU) |>
  filter(fecha >= fecha_inicio)
# FRED deja vacios los festivos sin cotizacion; se quitan, no se rellenan
n_brent_festivos <- sum(is.na(brent$brent_usd))
brent <- drop_na(brent, brent_usd)

inflacion <- leer_banrep("01_Datos/01_Crudos/inflacion_variacion_anual_99_26.xlsx")
tcr <- leer_banrep("01_Datos/01_Crudos/tasa_cambio_real_70_26.xlsx")

saveRDS(brent, "01_Datos/03_Listos/macro_brent.rds")
saveRDS(inflacion, "01_Datos/03_Listos/macro_inflacion.rds")
saveRDS(tcr, "01_Datos/03_Listos/macro_tcr.rds")

for (s in list(brent = brent, inflacion = inflacion, tcr = tcr)) {
  message(nrow(s), " filas, ", min(s$fecha), " a ", max(s$fecha))
}
message("Brent: ", n_brent_festivos, " dias sin cotizacion eliminados")

# auto-chequeo: nada anterior a 2000, fechas unicas y series numericas
stopifnot(
  all(map_lgl(list(brent, inflacion, tcr), ~ min(.x$fecha) >= fecha_inicio)),
  !anyDuplicated(brent$fecha), !anyDuplicated(inflacion$fecha), !anyDuplicated(tcr$fecha),
  is.numeric(brent$brent_usd), all(map_lgl(inflacion[-1], is.numeric)),
  all(map_lgl(tcr[-1], is.numeric))
)
