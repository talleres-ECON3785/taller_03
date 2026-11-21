# =============================================================================
# 07. Series macroeconomicas: graficas, descriptiva por periodo, cronologia
#     del choque petrolero de 2014 y alineacion con las reuniones de la Junta
# Taller 3 - ECON-3785
#
# Entradas:
#   01_Datos/03_Listos/macro_brent.rds, macro_trm.rds, macro_inflacion.rds,
#     macro_inflacion_total.rds, macro_meta.rds   (las genera 06_series_macro.R)
#   01_Datos/02_Procesados/decisiones_reunion.rds (decision de tasa de cada
#     reunion con su cita; la genera 01_extraer_texto.R)
#   01_Datos/02_Procesados/corpus_texto.rds       (solo metadatos: fecha, tipo,
#     formato y numero de palabras; no se usa ninguna medida de texto)
# Salidas:
#   01_Datos/03_Listos/macro_por_reunion.rds   una fila por reunion, con el
#     ultimo dato de cada serie que la Junta tenia a la fecha (regla de
#     alineacion de CLAUDE.md, paso P1.4 de PLAN.md)
#   03_Resultados/Figuras/07_graficas_macro/  y  Tablas/07_graficas_macro/
#
# REGLA DE H2: la fecha de corte se fija solo con estas series y con las
# decisiones de tasa. Este script no lee ni calcula ninguna medida de texto.
# =============================================================================

# los paquetes los carga 00_main.R con pacman

source("02_Scripts/00_formato_tablas.R") # tambien carga 00_formato_graficas.R
source("02_Scripts/00_funciones_texto.R") # tabla `periodos` y formatos de minuta

carpeta_salida <- "07_graficas_macro"
desde <- as.Date("2007-01-01") # el corpus empieza en enero de 2007
hasta <- as.Date("2026-10-31") # ultimo mes con inflacion publicada

# -----------------------------------------------------------------------------
# 1. Series
# -----------------------------------------------------------------------------

brent <- readRDS("01_Datos/03_Listos/macro_brent.rds") %>% arrange(fecha)
trm <- readRDS("01_Datos/03_Listos/macro_trm.rds") %>% arrange(fecha)
inflacion <- readRDS("01_Datos/03_Listos/macro_inflacion_total.rds") %>%
  left_join(readRDS("01_Datos/03_Listos/macro_inflacion.rds") %>%
              select(fecha, nucleo15 = `Inflación núcleo 15, anual`), by = "fecha") %>%
  arrange(fecha)
meta <- readRDS("01_Datos/03_Listos/macro_meta.rds")
decisiones <- readRDS("01_Datos/02_Procesados/decisiones_reunion.rds") %>% arrange(fecha)

# meta del ano de cada mes y brecha de inflacion: inflacion total del mes
# menos la meta de ese ano (y la nucleo 15 como complemento), en puntos
# porcentuales
inflacion <- inflacion %>%
  mutate(anio = as.integer(format(fecha, "%Y"))) %>%
  left_join(meta, by = "anio") %>%
  mutate(brecha = inflacion_total - meta, brecha_nucleo15 = nucleo15 - meta)

# promedios mensuales del Brent (dias con cotizacion) y de la TRM (dias de
# lunes a viernes: la TRM del archivo repite el ultimo valor en fines de
# semana y festivos; se quitan los fines de semana para no darle triple peso
# al viernes) y su variacion anual en %
mes_de <- function(f) as.Date(format(f, "%Y-%m-01"))
mensual <- full_join(
  brent %>% group_by(mes = mes_de(fecha)) %>% summarise(brent = mean(brent_usd), .groups = "drop"),
  trm %>% filter(!format(fecha, "%u") %in% c("6", "7")) %>%
    group_by(mes = mes_de(fecha)) %>% summarise(trm = mean(trm_cop_usd), .groups = "drop"),
  by = "mes"
) %>%
  arrange(mes) %>%
  mutate(
    var_brent = 100 * (brent / lag(brent, 12) - 1),
    var_trm = 100 * (trm / lag(trm, 12) - 1)
  )
stopifnot(all(diff(mensual$mes) %in% 28:31)) # sin meses faltantes (lag de 12)

# -----------------------------------------------------------------------------
# 2. Alineacion con las reuniones (paso P1.4; regla escrita en CLAUDE.md)
# -----------------------------------------------------------------------------

# a cada reunion se le asigna el ultimo dato que la Junta tenia ese dia:
#   - Brent: cierre del dia habil anterior a la reunion;
#   - TRM: la vigente el dia de la reunion (se publica el dia habil anterior);
#   - inflacion (total y nucleo 15): el IPC del mes m se publica a comienzos
#     del mes m+1; se supone publicado el dia 8 del mes m+1 (supuesto
#     conservador: el DANE suele publicar entre el dia 4 y el 8). La brecha usa
#     la meta del ano del dato, no la del ano de la reunion
reuniones <- decisiones %>% distinct(fecha, periodo, decision)
stopifnot(!anyDuplicated(reuniones$fecha))

# Brent: indice del ultimo cierre anterior a la reunion
i_brent <- findInterval(reuniones$fecha - 1, brent$fecha)
# variacion anual del Brent: frente al ultimo cierre de un ano antes
i_brent_12 <- findInterval(brent$fecha[i_brent] %m-% years(1), brent$fecha)
# maximo del Brent en los 12 meses previos a la reunion
max_brent_12m <- map_dbl(reuniones$fecha, function(d) {
  max(brent$brent_usd[brent$fecha >= d %m-% years(1) & brent$fecha < d])
})
# TRM vigente el dia de la reunion y un ano antes (la serie es diaria
# calendario y no tiene vacios)
i_trm <- match(reuniones$fecha, trm$fecha)
i_trm_12 <- match(reuniones$fecha %m-% years(1), trm$fecha)
# inflacion: ultimo mes publicado al dia de la reunion
publicacion <- inflacion$fecha + 8 # fecha = ultimo dia del mes m
i_inf <- findInterval(reuniones$fecha, publicacion)

# los valores se toman antes del mutate(): dentro de el, las columnas nuevas
# `brent` y `trm` taparian a las tablas del mismo nombre
brent_reunion <- brent$brent_usd[i_brent]
brent_hace_un_ano <- brent$brent_usd[i_brent_12]
trm_reunion <- trm$trm_cop_usd[i_trm]
trm_hace_un_ano <- trm$trm_cop_usd[i_trm_12]
macro_por_reunion <- reuniones %>%
  mutate(
    fecha_brent = brent$fecha[i_brent],
    brent = brent_reunion,
    var_brent = 100 * (brent_reunion / brent_hace_un_ano - 1),
    max_brent_12m = max_brent_12m,
    brent_vs_max = 100 * (brent_reunion / max_brent_12m - 1),
    trm = trm_reunion,
    var_trm = 100 * (trm_reunion / trm_hace_un_ano - 1),
    mes_inflacion = inflacion$fecha[i_inf],
    inflacion_total = inflacion$inflacion_total[i_inf],
    nucleo15 = inflacion$nucleo15[i_inf],
    meta = inflacion$meta[i_inf],
    brecha = inflacion$brecha[i_inf],
    brecha_nucleo15 = inflacion$brecha_nucleo15[i_inf]
  )
stopifnot(
  nrow(macro_por_reunion) == 205, !anyNA(select(macro_por_reunion, -decision)),
  all(macro_por_reunion$fecha_brent < macro_por_reunion$fecha),
  # el dato de inflacion es de uno o dos meses antes de la reunion
  all(as.numeric(macro_por_reunion$fecha - macro_por_reunion$mes_inflacion) %in% 8:70)
)
saveRDS(macro_por_reunion, "01_Datos/03_Listos/macro_por_reunion.rds")

# -----------------------------------------------------------------------------
# 3. Hitos del choque petrolero (cronologia, 2013-2017)
# -----------------------------------------------------------------------------

# cada hito se define con una regla sobre las series, no a ojo
entre <- function(f, a, b) f >= as.Date(a) & f <= as.Date(b)
# pico del Brent: el cierre mas alto de 2014, el ano de la caida (el de
# 2013-2014 completo cae en febrero de 2013, lejos del comienzo de la caida)
pico_brent <- brent %>% filter(entre(fecha, "2014-01-01", "2014-12-31")) %>% slice_max(brent_usd, n = 1, with_ties = FALSE)
valle_brent <- brent %>% filter(entre(fecha, "2015-01-01", "2016-12-31")) %>% slice_min(brent_usd, n = 1, with_ties = FALSE)
# inicio de la depreciacion: la TRM mas baja de 2014, antes de la subida
valle_trm <- trm %>% filter(entre(fecha, "2014-01-01", "2014-12-31")) %>% slice_min(trm_cop_usd, n = 1, with_ties = FALSE)
pico_trm <- trm %>% filter(entre(fecha, "2015-01-01", "2016-12-31")) %>% slice_max(trm_cop_usd, n = 1, with_ties = FALSE)
pico_inflacion <- inflacion %>% filter(entre(fecha, "2015-01-01", "2017-12-31")) %>% slice_max(inflacion_total, n = 1, with_ties = FALSE)
# ciclo de alzas de 2015-2016: primera y ultima alza (decisiones leidas de los
# comunicados en 01_extraer_texto.R)
alzas <- decisiones %>% filter(decision == "sube", fecha >= as.Date("2015-01-01"), fecha <= as.Date("2016-12-31"))
primera_alza <- alzas %>% slice_min(fecha, n = 1)
ultima_alza <- alzas %>% slice_max(fecha, n = 1)
stopifnot(primera_alza$fecha == as.Date("2015-09-25"), ultima_alza$fecha == as.Date("2016-07-29"),
          # primera y ultima se verifican contra el comunicado; la de
          # 2015-10-30 no tiene comunicado en los datos y se lee de la minuta
          primera_alza$fuente == "comunicado", ultima_alza$fuente == "comunicado")
fmt <- function(x, d = 0) format(round(x, d), big.mark = ".", decimal.mark = ",", nsmall = d)

hitos <- tribble(
  ~hito, ~fecha, ~valor, ~serie,
  "Pico del Brent", pico_brent$fecha, paste0(fmt(pico_brent$brent_usd, 1), " USD por barril"), "Brent",
  "Inicio de la depreciación (TRM más baja de 2014)", valle_trm$fecha, paste0(fmt(valle_trm$trm_cop_usd), " pesos por dólar"), "TRM",
  "Primera alza de la tasa de intervención", primera_alza$fecha, "+25 pb", "Inflación total",
  "Valle del Brent", valle_brent$fecha, paste0(fmt(valle_brent$brent_usd, 1), " USD por barril"), "Brent",
  "Pico de la TRM", pico_trm$fecha, paste0(fmt(pico_trm$trm_cop_usd), " pesos por dólar"), "TRM",
  "Pico de la inflación total", pico_inflacion$fecha, paste0(fmt(pico_inflacion$inflacion_total, 2), " %"), "Inflación total",
  "Última alza del ciclo", ultima_alza$fecha, "+25 pb", "Inflación total"
) %>%
  mutate(fecha = as.Date(fecha)) %>%
  left_join(decisiones %>% select(fecha, cita), by = "fecha") %>%
  mutate(cita = if_else(str_detect(hito, "alza"), cita, NA_character_)) %>%
  arrange(fecha)

# -----------------------------------------------------------------------------
# 4. Reglas mecanicas para la fecha de corte (H2)
# -----------------------------------------------------------------------------

# Candidata de partida: 2014-09-26 (abre P4). Dos reglas calculadas solo con
# las series, buscando desde el 2014-01-01 (para no tomar la crisis de 2008):
#   (i)  el Brent esta 20 % o mas por debajo de su maximo de los 12 meses previos;
#   (ii) la depreciacion anual de la TRM supera el 20 %.
# Para cada regla: el primer dia en que se cumple con datos diarios y la
# primera reunion en que se cumple con los datos alineados
brent_dia <- brent %>%
  filter(fecha >= as.Date("2014-01-01")) %>%
  mutate(max12 = map_dbl(fecha, function(d) max(brent$brent_usd[brent$fecha >= d %m-% years(1) & brent$fecha <= d])),
         caida = 100 * (brent_usd / max12 - 1))
trm_dia <- trm %>%
  filter(fecha >= as.Date("2014-01-01")) %>%
  mutate(var = 100 * (trm_cop_usd / trm$trm_cop_usd[match(fecha %m-% years(1), trm$fecha)] - 1))
desde_2014 <- macro_por_reunion %>% filter(fecha >= as.Date("2014-01-01"))
dia_i <- brent_dia %>% filter(caida <= -20) %>% slice_min(fecha, n = 1)
dia_ii <- trm_dia %>% filter(var > 20) %>% slice_min(fecha, n = 1)
reunion_i <- desde_2014 %>% filter(brent_vs_max <= -20) %>% slice_min(fecha, n = 1)
reunion_ii <- desde_2014 %>% filter(var_trm > 20) %>% slice_min(fecha, n = 1)
# la regla (i) es el corte aprobado (corte_crisis, en 00_funciones_texto.R) y
# las otras dos son los cortes alternativos: si las series cambian, el script
# se detiene en vez de dibujar un corte que ya no cumple su regla
stopifnot(reunion_i$fecha == corte_crisis,
          reunion_ii$fecha == cortes_alternativos[["depreciacion_trm"]])
candidata <- macro_por_reunion %>% filter(fecha == as.Date("2014-09-26"))

cortes <- tribble(
  ~regla, ~dia_regla, ~reunion,
  "Candidata: apertura de P4 (primera reunión sin alza tras el ciclo de abril a agosto de 2014)", as.Date(NA), candidata$fecha,
  "(i) Brent 20 % o más por debajo de su máximo de 12 meses (corte aprobado)", dia_i$fecha, reunion_i$fecha,
  "(ii) Depreciación anual de la TRM mayor que 20 %", dia_ii$fecha, reunion_ii$fecha
) %>%
  left_join(macro_por_reunion %>% select(reunion = fecha, brent, brent_vs_max, trm, var_trm, inflacion_total, brecha),
            by = "reunion")

# metadatos de los documentos alrededor de cada corte (no medidas de texto):
# minutas del formato B antes del corte y reuniones y palabras de la
# discusion de la Junta a cada lado, en una ventana de 5 anos
corpus_meta <- readRDS("01_Datos/02_Procesados/corpus_texto.rds") %>%
  select(id, tipo, fecha, formato, palabras_junta)
ventanas <- cortes %>%
  select(regla, corte = reunion) %>%
  mutate(corto = c("Candidata", "Regla (i)", "Regla (ii)")) %>%
  crossing(tipo = c("comunicado", "minuta")) %>%
  mutate(datos = pmap(list(corte, tipo), function(corte, tp) {
    d <- corpus_meta %>% filter(tipo == tp)
    antes <- d %>% filter(fecha >= corte %m-% years(5), fecha < corte)
    despues <- d %>% filter(fecha >= corte, fecha < corte %m+% years(5))
    tibble(
      minutas_b_antes = if (tp == "minuta") sum(d$formato == "B" & d$fecha < corte) else NA_integer_,
      docs_antes = nrow(antes), docs_despues = nrow(despues),
      palabras_antes = sum(antes$palabras_junta), palabras_despues = sum(despues$palabras_junta)
    )
  })) %>%
  unnest(datos)

# -----------------------------------------------------------------------------
# 5. Figura 1: Brent, TRM e inflacion 2007-2026
# -----------------------------------------------------------------------------

paneles <- c("Brent (dólares por barril)", "TRM (pesos por dólar)", "Inflación anual (%)")
series_fig <- bind_rows(
  mensual %>% transmute(fecha = mes, valor = brent, serie = "Brent", panel = paneles[1]),
  mensual %>% transmute(fecha = mes, valor = trm, serie = "TRM", panel = paneles[2]),
  inflacion %>% transmute(fecha = mes_de(fecha), valor = inflacion_total, serie = "Inflación total", panel = paneles[3]),
  inflacion %>% transmute(fecha = mes_de(fecha), valor = nucleo15, serie = "Inflación núcleo 15", panel = paneles[3])
) %>%
  filter(fecha >= desde, fecha <= hasta) %>%
  mutate(panel = factor(panel, levels = paneles))
meta_fig <- meta %>%
  filter(anio >= 2007) %>%
  transmute(inicio = as.Date(paste0(anio, "-01-01")), fin = pmin(as.Date(paste0(anio, "-12-31")), hasta),
            meta, rango_inf, rango_sup, panel = factor(paneles[3], levels = paneles))
# la meta como escalera: un tramo horizontal por ano, unidos en el cambio
meta_escalera <- meta_fig %>%
  select(inicio, fin, meta, panel) %>%
  pivot_longer(c(inicio, fin), values_to = "fecha") %>%
  arrange(fecha)

capa_meta <- list(
  geom_rect(data = meta_fig, aes(xmin = inicio, xmax = fin + 1, ymin = rango_inf, ymax = rango_sup),
            inherit.aes = FALSE, fill = colores_macro[["Inflación total"]], alpha = 0.13),
  geom_line(data = meta_escalera, aes(fecha, meta, color = "Meta"), linewidth = 0.6)
)

n_reuniones <- nrow(macro_por_reunion)
# una oración por renglón ("\n"); guardar_figura() parte cada una por aparte
nota_series <- paste(
  paste0("Sombreado alterno: periodos de política monetaria P1 a P10, abiertos por la primera reunión que cambia la ",
         "dirección de la tasa."),
  paste0("Línea vertical continua: corte antes/después del choque petrolero (", format(corte_crisis, "%d-%m-%Y"),
         "), primera reunión en que el Brent que tenía la Junta estaba 20 % o más por debajo de su máximo de 12 meses."),
  paste0("Fuentes: Brent, FRED (DCOILBRENTEU), promedio mensual de los días con cotización; TRM, Banco de la República ",
         "(SUAMECA), promedio mensual de lunes a viernes; inflación total y núcleo 15, DANE con cálculos del Banco de la ",
         "República, variación anual; meta, Banco de la República (punto y rango: ±0,5 pp hasta 2009, ±1 pp desde 2010)."),
  sep = "\n"
)

fig_series <- ggplot(series_fig, aes(fecha, valor, color = serie)) +
  capa_periodos(periodos, etiquetas = TRUE, desde = desde, hasta = hasta,
                panel = list(panel = factor(paneles[1], levels = paneles))) +
  capa_corte(corte_crisis, rotulo = paste0("Corte: ", format(corte_crisis, "%d-%m-%Y")),
             panel = list(panel = factor(paneles[1], levels = paneles))) +
  capa_meta +
  geom_line(aes(linetype = serie), linewidth = 0.7) +
  facet_wrap(~ panel, ncol = 1, scales = "free_y") +
  scale_color_manual(values = colores_macro,
                     breaks = c("Brent", "TRM", "Inflación total", "Inflación núcleo 15", "Meta")) +
  scale_linetype_manual(values = c("Brent" = "solid", "TRM" = "solid", "Inflación total" = "solid",
                                   "Inflación núcleo 15" = "22"), guide = "none") +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y", expand = expansion(mult = 0.01)) +
  scale_y_continuous(labels = scales::label_number(big.mark = ".", decimal.mark = ",")) +
  labs(
    title = "Petróleo, tasa de cambio e inflación en Colombia, 2007–2026",
    subtitle = "Series mensuales; periodos de política monetaria sombreados",
    x = NULL, y = NULL, caption = nota_series
  ) +
  tema_presentacion + tema_paneles +
  theme(panel.grid.major.x = element_blank(), legend.key.width = unit(1.4, "lines"))
guardar_figura("macro_series_2007_2026.png", fig_series, carpeta_salida, width = 10, height = 8.5)

# -----------------------------------------------------------------------------
# 6. Figura 2: cronologia del choque, 2013-2017
# -----------------------------------------------------------------------------

z_desde <- as.Date("2013-01-01")
z_hasta <- as.Date("2017-12-31")
paneles_z <- c("Brent (dólares por barril)", "TRM (pesos por dólar)", "Inflación total anual (%)")
series_z <- bind_rows(
  brent %>% transmute(fecha, valor = brent_usd, serie = "Brent", panel = paneles_z[1]),
  trm %>% transmute(fecha, valor = trm_cop_usd, serie = "TRM", panel = paneles_z[2]),
  inflacion %>% transmute(fecha = mes_de(fecha) + 14, valor = inflacion_total, serie = "Inflación total", panel = paneles_z[3])
) %>%
  filter(fecha >= z_desde, fecha <= z_hasta) %>%
  mutate(panel = factor(panel, levels = paneles_z))
meta_z <- meta_fig %>% filter(inicio >= z_desde, inicio <= z_hasta) %>% mutate(panel = factor(paneles_z[3], levels = paneles_z))

# puntos de los hitos en su panel, con su rotulo
puntos <- tribble(
  ~hito, ~fecha, ~valor, ~panel, ~hjust, ~vjust,
  "Pico del Brent", pico_brent$fecha, pico_brent$brent_usd, paneles_z[1], 0.5, -0.6,
  "Valle del Brent", valle_brent$fecha, valle_brent$brent_usd, paneles_z[1], -0.12, 0.6,
  "Inicio de la depreciación", valle_trm$fecha, valle_trm$trm_cop_usd, paneles_z[2], 1.04, 1.25,
  "Pico de la TRM", pico_trm$fecha, pico_trm$trm_cop_usd, paneles_z[2], -0.1, 0.1,
  "Pico de la inflación", mes_de(pico_inflacion$fecha) + 14, pico_inflacion$inflacion_total, paneles_z[3], -0.08, 0.4
) %>%
  mutate(fecha = as.Date(fecha),
         etiqueta = paste0(hito, "\n", format(fecha, "%d-%m-%Y")),
         panel = factor(panel, levels = paneles_z))
puntos$etiqueta[puntos$hito == "Pico de la inflación"] <- paste0("Pico de la inflación\n", format(pico_inflacion$fecha, "%m-%Y"), ": ",
                                                             fmt(pico_inflacion$inflacion_total, 2), " %")
alzas_rot <- tibble(
  x = c(primera_alza$fecha, ultima_alza$fecha),
  etiqueta = c(paste0("Primera alza\n", format(primera_alza$fecha, "%d-%m-%Y")),
               paste0("Última alza\n", format(ultima_alza$fecha, "%d-%m-%Y"))),
  hjust = c(1.05, -0.05),
  panel = factor(paneles_z[3], levels = paneles_z)
)

fig_crono <- ggplot(series_z, aes(fecha, valor, color = serie)) +
  # ciclo de alzas de la tasa de intervencion (de la primera a la ultima alza)
  capa_corte(corte_crisis, rotulo = paste0("Corte
", format(corte_crisis, "%d-%m-%Y")),
             panel = list(panel = factor(paneles_z[1], levels = paneles_z))) +
  annotate("rect", xmin = primera_alza$fecha, xmax = ultima_alza$fecha, ymin = -Inf, ymax = Inf,
           fill = gris_grilla, alpha = 0.7) +
  geom_rect(data = meta_z, aes(xmin = inicio, xmax = fin + 1, ymin = rango_inf, ymax = rango_sup),
            inherit.aes = FALSE, fill = colores_macro[["Inflación total"]], alpha = 0.13) +
  geom_segment(data = meta_z, aes(x = inicio, xend = fin + 1, y = meta, yend = meta),
               inherit.aes = FALSE, color = colores_macro[["Meta"]], linewidth = 0.5, linetype = "22") +
  geom_vline(xintercept = c(primera_alza$fecha, ultima_alza$fecha), color = gris_secundario,
             linewidth = 0.4, linetype = "dashed") +
  geom_line(linewidth = 0.75) +
  geom_point(data = puntos, aes(fecha, valor), inherit.aes = FALSE, size = 2.6, color = gris_texto) +
  geom_text(data = puntos, aes(fecha, valor, label = etiqueta, hjust = hjust, vjust = vjust),
            inherit.aes = FALSE, size = 3.3, lineheight = 0.9, color = gris_texto) +
  geom_text(data = alzas_rot, aes(x = x, y = -Inf, label = etiqueta, hjust = hjust),
            inherit.aes = FALSE, vjust = -0.4, size = 3.1, lineheight = 0.9, color = gris_secundario) +
  facet_wrap(~ panel, ncol = 1, scales = "free_y") +
  scale_color_manual(values = colores_macro, guide = "none") +
  scale_x_date(date_breaks = "6 months", date_labels = "%m-%Y", expand = expansion(mult = 0.01)) +
  scale_y_continuous(labels = scales::label_number(big.mark = ".", decimal.mark = ","),
                     expand = expansion(mult = c(0.22, 0.25))) +
  labs(
    title = "El choque petrolero de 2014: del precio del crudo a la inflación",
    subtitle = "Brent y TRM diarios; inflación total mensual con la meta (línea punteada) y su rango. 2013–2017",
    x = NULL, y = NULL,
    # una oración por renglón ("\n"); guardar_figura() parte cada una por aparte
    caption = paste(
      paste0("Línea vertical continua: corte antes/después del choque (", format(corte_crisis, "%d-%m-%Y"),
             "), primera reunión con el Brent 20 % o más por debajo de su máximo de 12 meses."),
      paste0("Franja gris: ciclo de alzas de la tasa de intervención, de la primera (", format(primera_alza$fecha, "%d-%m-%Y"),
             ") a la última alza (", format(ultima_alza$fecha, "%d-%m-%Y"), "), según los comunicados de la Junta."),
      paste0("Hitos definidos con reglas sobre las series: pico del Brent en 2014, valle en 2015–2016; TRM más baja de 2014 y más alta de 2015–2016; ",
             "inflación más alta de 2015–2017."),
      "Fuentes: FRED (Brent), Banco de la República (TRM, meta), DANE (inflación).",
      sep = "\n"
    )
  ) +
  tema_presentacion + tema_paneles +
  theme(axis.text.x = element_text(size = 10), strip.text = element_text(size = 12))
guardar_figura("macro_cronologia_choque.png", fig_crono, carpeta_salida, width = 10, height = 8.5)

# -----------------------------------------------------------------------------
# 7. Tabla 3: descriptiva por periodo
# -----------------------------------------------------------------------------

# Brent y TRM con datos diarios del periodo (la TRM de lunes a viernes);
# inflacion con los meses cuyo ultimo dia cae en el periodo. Variacion: ultimo
# dato del periodo frente al primero (en % para Brent y TRM, en puntos
# porcentuales para la inflacion)
resumir <- function(x, f) {
  tibble(media = mean(x), minimo = min(x), maximo = max(x), cambio = f(last(x), first(x)))
}
var_pct <- function(u, p) 100 * (u / p - 1)
var_pp <- function(u, p) u - p
trm_habil <- trm %>% filter(!format(fecha, "%u") %in% c("6", "7"))
descriptiva <- periodos %>%
  select(periodo, nombre, inicio, fin) %>%
  mutate(
    brent = map2(inicio, fin, ~ resumir(brent$brent_usd[brent$fecha >= .x & brent$fecha <= .y], var_pct)),
    trm = map2(inicio, fin, ~ resumir(trm_habil$trm_cop_usd[trm_habil$fecha >= .x & trm_habil$fecha <= .y], var_pct)),
    inf = map2(inicio, fin, ~ resumir(inflacion$inflacion_total[inflacion$fecha >= .x & inflacion$fecha <= .y], var_pp)),
    brecha = map2_dbl(inicio, fin, ~ mean(inflacion$brecha[inflacion$fecha >= .x & inflacion$fecha <= .y])),
    fuera_rango = map2_dbl(inicio, fin, ~ {
      d <- inflacion[inflacion$fecha >= .x & inflacion$fecha <= .y, ]
      100 * mean(d$inflacion_total > d$rango_sup | d$inflacion_total < d$rango_inf)
    })
  ) %>%
  unnest_wider(c(brent, trm, inf), names_sep = "_") %>%
  mutate(periodo = as.character(periodo))

tabla_desc <- descriptiva %>%
  mutate(fechas = paste0(format(inicio, "%Y-%m"), " a ", format(fin, "%Y-%m"))) %>%
  select(periodo, nombre, fechas, starts_with("brent_"), starts_with("trm_"), starts_with("inf_"), brecha, fuera_rango) %>%
  gt() %>%
  cols_label(
    periodo = "", nombre = "Periodo", fechas = "Fechas",
    brent_media = "Media", brent_minimo = "Mín.", brent_maximo = "Máx.", brent_cambio = "Var. %",
    trm_media = "Media", trm_minimo = "Mín.", trm_maximo = "Máx.", trm_cambio = "Var. %",
    inf_media = "Media", inf_minimo = "Mín.", inf_maximo = "Máx.", inf_cambio = "Cambio (pp)",
    brecha = "Brecha media frente a la meta (pp)", fuera_rango = "% de meses fuera del rango meta"
  ) %>%
  tab_spanner("Brent (USD por barril)", columns = starts_with("brent_")) %>%
  tab_spanner("TRM (pesos por dólar)", columns = starts_with("trm_")) %>%
  tab_spanner("Inflación total anual (%)", columns = c(starts_with("inf_"), brecha, fuera_rango)) %>%
  fmt_number(columns = c(starts_with("brent_"), starts_with("inf_"), brecha), decimals = 1, dec_mark = ",", sep_mark = ".") %>%
  fmt_number(columns = c(trm_media, trm_minimo, trm_maximo), decimals = 0, dec_mark = ",", sep_mark = ".") %>%
  fmt_number(columns = c(trm_cambio, fuera_rango), decimals = 0, dec_mark = ",", sep_mark = ".") %>%
  fmt_number(columns = c(brent_cambio), decimals = 0, dec_mark = ",", sep_mark = ".") %>%
  cols_width(nombre ~ px(160), fechas ~ px(120), everything() ~ px(66)) %>%
  tab_style(style = list(cell_fill(color = "#f3e7d3"), cell_text(weight = "bold")),
            locations = cells_body(rows = periodo %in% c("P3", "P4"))) %>%
  estilo_tabla(
    titulo = "Petróleo, tasa de cambio e inflación por periodo de política monetaria",
    subtitulo = "P3 y P4 (resaltados) enmarcan el choque petrolero de 2014",
    nota = c(
      "Fuentes: Brent, FRED (DCOILBRENTEU), días con cotización; TRM, Banco de la República (SUAMECA), días de lunes a viernes; inflación total anual, DANE con cálculos del Banco de la República; meta, Banco de la República.",
      "Periodos definidos a priori por la primera reunión de la Junta que cambia la dirección de la tasa (ver CLAUDE.md). Var. %: último dato del periodo frente al primero. Cambio (pp): inflación del último mes del periodo menos la del primero. Brecha: inflación total menos la meta del año, promedio de los meses del periodo. Rango meta: ±0,5 pp hasta 2009 y ±1 pp desde 2010.",
      "P10 llega hasta septiembre de 2026."
    )
  )
guardar_tabla("macro_descriptiva", tabla_desc, descriptiva, carpeta_salida)

# -----------------------------------------------------------------------------
# 8. Tabla 4: cronologia del choque
# -----------------------------------------------------------------------------

tabla_crono <- hitos %>%
  select(fecha, hito, valor, cita) %>%
  mutate(fecha = format(fecha, "%Y-%m-%d")) %>%
  gt() %>%
  cols_label(fecha = "Fecha", hito = "Hito", valor = "Valor", cita = "Decisión de la Junta (comunicado)") %>%
  sub_missing(missing_text = "—") %>%
  cols_width(fecha ~ px(105), hito ~ px(240), valor ~ px(170), cita ~ px(470)) %>%
  tab_style(cell_text(size = px(12)), cells_body(columns = cita)) %>%
  estilo_tabla(
    titulo = "Cronología del choque petrolero de 2014",
    subtitulo = "Del pico del precio del petróleo al fin del ciclo de alzas de la tasa de intervención",
    nota = c(
      "Hitos definidos con reglas sobre las series: pico del Brent (cierre diario más alto de 2014), valle del Brent (más bajo de 2015–2016), inicio de la depreciación (TRM más baja de 2014), pico de la TRM (más alta de 2015–2016), pico de la inflación total (mes más alto de 2015–2017). La inflación del mes se fecha con el último día del mes.",
      "Primera y última alza del ciclo de 2015–2016: decisiones de la Junta leídas de los comunicados (01_extraer_texto.R).",
      "Fuentes: FRED (Brent), Banco de la República (TRM, decisiones de tasa), DANE (inflación)."
    )
  )
guardar_tabla("macro_cronologia", tabla_crono, hitos, carpeta_salida)

# -----------------------------------------------------------------------------
# 9. Tablas para H2: cortes candidatos y documentos a cada lado
# -----------------------------------------------------------------------------

tabla_cortes <- cortes %>%
  mutate(across(c(dia_regla, reunion), ~ format(.x, "%Y-%m-%d"))) %>%
  gt() %>%
  cols_label(regla = "Regla", dia_regla = "Primer día en que se cumple", reunion = "Reunión de corte",
             brent = "Brent (USD)", brent_vs_max = "Brent frente a su máximo de 12 meses (%)",
             trm = "TRM", var_trm = "Variación anual de la TRM (%)",
             inflacion_total = "Inflación total (%)", brecha = "Brecha frente a la meta (pp)") %>%
  tab_spanner("Datos que la Junta tenía en la reunión de corte", columns = c(brent, brent_vs_max, trm, var_trm, inflacion_total, brecha)) %>%
  sub_missing(missing_text = "—") %>%
  fmt_number(columns = c(brent, brent_vs_max, var_trm, inflacion_total, brecha), decimals = 1, dec_mark = ",", sep_mark = ".") %>%
  fmt_number(columns = trm, decimals = 0, dec_mark = ",", sep_mark = ".") %>%
  cols_width(regla ~ px(300), everything() ~ px(105)) %>%
  estilo_tabla(
    titulo = "Fechas de corte candidatas para el antes y el después del choque petrolero",
    subtitulo = "Calculadas solo con las series macroeconómicas y las decisiones de tasa",
    nota = c(
      "Las reglas (i) y (ii) se buscan desde el 2014-01-01. Primer día: con datos diarios. Reunión de corte: primera reunión de la Junta en que la regla se cumple con los datos que tenía (Brent del día hábil anterior, TRM vigente el día de la reunión, inflación del último mes publicado, supuesto publicado el día 8 del mes siguiente).",
      "Fuentes: FRED (Brent), Banco de la República (TRM, meta, decisiones), DANE (inflación)."
    )
  )
guardar_tabla("macro_cortes_candidatos", tabla_cortes, cortes, carpeta_salida)

datos_ventanas <- ventanas %>%
  arrange(match(corto, c("Candidata", "Regla (i)", "Regla (ii)")), tipo) %>%
  transmute(corte = paste0(corto, " (", format(corte, "%Y-%m-%d"), ")"), tipo = if_else(tipo == "minuta", "Minutas", "Comunicados"),
            minutas_b_antes, docs_antes, docs_despues, palabras_antes, palabras_despues) %>%
  mutate(corte = factor(corte, levels = unique(corte)))
tabla_ventanas <- datos_ventanas %>%
  gt(groupname_col = "corte") %>%
  cols_label(tipo = "Documento", minutas_b_antes = "Minutas del formato B antes del corte",
             docs_antes = "Antes", docs_despues = "Después", palabras_antes = "Antes", palabras_despues = "Después") %>%
  tab_spanner("Reuniones en la ventana", columns = c(docs_antes, docs_despues)) %>%
  tab_spanner("Palabras (discusión de la Junta)", columns = c(palabras_antes, palabras_despues)) %>%
  sub_missing(missing_text = "—") %>%
  fmt_number(columns = c(palabras_antes, palabras_despues), decimals = 0, dec_mark = ",", sep_mark = ".") %>%
  tab_style(cell_text(weight = "bold"), cells_row_groups()) %>%
  estilo_tabla(
    titulo = "Documentos a cada lado de cada fecha de corte",
    subtitulo = "Ventana de 5 años antes y 5 años después del corte",
    nota = nota_tabla("conjunto", n = nrow(corpus_meta), extra = c(
      "Antes: desde 5 años antes del corte hasta el día anterior. Después: desde el corte hasta 5 años después. Palabras de la discusión de la Junta: en las minutas con secciones, solo «Discusión» y «Decisión»; en los comunicados, todo el texto.",
      "El formato de las minutas cambia el 2014-05-30 (de A a B: la sección del equipo técnico pasa de «Antecedentes» a una síntesis). Solo se cuentan documentos; no se mira ninguna medida de texto."
    ))
  )
guardar_tabla("conjunto_ventanas_corte", tabla_ventanas, datos_ventanas, carpeta_salida)

message("07_graficas_macro: ", n_reuniones, " reuniones alineadas en 01_Datos/03_Listos/macro_por_reunion.rds")
