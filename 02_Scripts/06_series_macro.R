# =============================================================================
# 06. Series macroeconomicas: lectura de los crudos, filtro desde 2000 y RDS
# Taller 3 - ECON-3785
#
# Entradas (01_Datos/01_Crudos/, descargadas a mano; fuentes en el README):
#   brent_2000-26.csv                      Brent, FRED (DCOILBRENTEU), diaria
#   inflacion_variacion_anual_99_26.xlsx   inflacion anual, BanRep, mensual
#   tasa_cambio_real_70_26.xlsx            indices de tasa de cambio real, BanRep, mensual
#   TRM.csv                                TRM (COP por USD), BanRep (SUAMECA), diaria calendario
#   IPC TOTAL_Variación_Porcentual_Anual.xlsx  inflacion total anual, BanRep (DANE), mensual
#   Meta e inflación anual.xlsx            meta de inflacion de cada ano, BanRep, anual
# Salidas (01_Datos/03_Listos/), una por fuente, solo con fechas >= 2000-01-01:
#   macro_brent.rds       fecha, brent_usd
#   macro_inflacion.rds   fecha (fin de mes) y una columna por serie, en %
#   macro_tcr.rds         fecha (fin de mes) y una columna por indice
#   macro_trm.rds         fecha (dia de vigencia), trm_cop_usd
#   macro_inflacion_total.rds  fecha (fin de mes), inflacion_total (%)
#   macro_meta.rds        anio, meta (%), rango_inf y rango_sup (%)
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

# la TRM trae un encabezado largo (se salta), fechas "AAAA/MM/DD" y calendario
# completo: fines de semana y festivos repiten el ultimo valor
trm <- read_csv("01_Datos/01_Crudos/TRM.csv", skip = 1, col_names = c("fecha", "trm_cop_usd"),
                col_types = "cd") |>
  mutate(fecha = ymd(fecha)) |>
  filter(fecha >= fecha_inicio)

# inflacion total al consumidor: es la medida sobre la que se define la meta
inflacion_total <- leer_banrep("01_Datos/01_Crudos/IPC TOTAL_Variación_Porcentual_Anual.xlsx") |>
  rename(inflacion_total = `Inflación total, anual`)

# meta de inflacion: el archivo la trae repetida en cada mes del ano; se deja
# una fila por ano. El rango no viene en las series: la nota del archivo dice
# que entre 2003 y 2009 es de +/- 0,5 pp alrededor del punto y desde 2010 de
# +/- 1 pp
meta_crudo <- leer_banrep("01_Datos/01_Crudos/Meta e inflación anual.xlsx")
meta <- meta_crudo |>
  filter(!is.na(`Meta de inflación`)) |>
  group_by(anio = as.integer(format(fecha, "%Y"))) |>
  summarise(meta = unique(`Meta de inflación`), .groups = "drop") |>
  mutate(
    ancho = case_when(anio >= 2010 ~ 1, anio >= 2003 ~ 0.5, TRUE ~ NA_real_),
    rango_inf = meta - ancho,
    rango_sup = meta + ancho
  ) |>
  select(-ancho)

saveRDS(brent, "01_Datos/03_Listos/macro_brent.rds")
saveRDS(inflacion, "01_Datos/03_Listos/macro_inflacion.rds")
saveRDS(tcr, "01_Datos/03_Listos/macro_tcr.rds")
saveRDS(trm, "01_Datos/03_Listos/macro_trm.rds")
saveRDS(inflacion_total, "01_Datos/03_Listos/macro_inflacion_total.rds")
saveRDS(meta, "01_Datos/03_Listos/macro_meta.rds")

for (s in list(brent = brent, inflacion = inflacion, tcr = tcr, trm = trm,
               inflacion_total = inflacion_total)) {
  message(nrow(s), " filas, ", min(s$fecha), " a ", max(s$fecha))
}
message("Brent: ", n_brent_festivos, " dias sin cotizacion eliminados")

# auto-chequeo: nada anterior a 2000, fechas unicas y series numericas
stopifnot(
  all(map_lgl(list(brent, inflacion, tcr, trm), ~ min(.x$fecha) >= fecha_inicio)),
  !anyDuplicated(brent$fecha), !anyDuplicated(inflacion$fecha), !anyDuplicated(tcr$fecha),
  !anyDuplicated(trm$fecha), !anyNA(trm), is.numeric(trm$trm_cop_usd),
  is.numeric(brent$brent_usd), all(map_lgl(inflacion[-1], is.numeric)),
  all(map_lgl(tcr[-1], is.numeric))
)

# verificacion de la inflacion total contra cifras conocidas del DANE
# (tolerancia de +/- 0,05 pp): diciembre de 2014, diciembre de 2015, julio de
# 2016 (pico del choque) y diciembre de 2022
inflacion_conocida <- tibble(
  fecha = as.Date(c("2014-12-31", "2015-12-31", "2016-07-31", "2022-12-31")),
  esperado = c(3.66, 6.77, 8.97, 13.12)
)
control <- inner_join(inflacion_conocida, inflacion_total, by = "fecha")
stopifnot(
  nrow(control) == 4,
  all(abs(control$inflacion_total - control$esperado) <= 0.05),
  !anyDuplicated(inflacion_total$fecha), !anyNA(inflacion_total$inflacion_total),
  # la inflacion que trae el archivo de la meta es la misma serie
  isTRUE(all.equal(
    inner_join(meta_crudo, inflacion_total, by = "fecha") |> pull(`Inflación total, anual`),
    inner_join(meta_crudo, inflacion_total, by = "fecha") |> pull(inflacion_total)
  )),
  # una meta por ano desde 2000 hasta el ano en curso; 3 % desde 2010
  !anyDuplicated(meta$anio), all(2000:2026 %in% meta$anio),
  all(meta$meta[meta$anio >= 2010] == 3)
)
