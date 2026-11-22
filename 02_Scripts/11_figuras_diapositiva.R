# =============================================================================
# 11. Figuras para las diapositivas (16:9, letra grande para video)
# Taller 3 - ECON-3785
#
# Entradas (resultados ya guardados; este script no estima nada):
#   03_Resultados/Tablas/09_lda_oraciones/conjunto_lda_antes_despues_detalle.csv
#   03_Resultados/Tablas/09_lda_oraciones/conjunto_lda_theta_por_reunion.csv
#   03_Resultados/Tablas/08_antes_despues/conjunto_temas_por_reunion.csv
#   03_Resultados/Tablas/08_antes_despues/conjunto_palabras_cambio_detalle.csv
#   03_Resultados/Tablas/08_antes_despues/conjunto_correlaciones_anclas.csv
#   03_Resultados/Tablas/08_antes_despues/conjunto_cronologia_texto_macro.csv
#   03_Resultados/Tablas/10_glove/conjunto_glove_vecinos.csv
#   01_Datos/03_Listos/macro_por_reunion.rds, tokens_anotados.rds (solo para
#     poner tildes a las etiquetas)
# Salidas:  03_Resultados/Figuras/11_figuras_diapositiva/ y
#           03_Resultados/Tablas/11_figuras_diapositiva/ (verificacion)
#
# Versiones para diapositiva de figuras de 07, 08 y 09: menos elementos por
# figura, 13,33 x 7,5 pulgadas y letra grande. Las cifras son las mismas de
# los scripts de origen; las figuras originales no cambian. Ademas, una
# verificacion: si el discurso cambio antes de la primera alza del ciclo
# (2015-09-25).
# =============================================================================

# los paquetes los carga 00_main.R con pacman

source("02_Scripts/00_formato_graficas.R")
source("02_Scripts/00_funciones_texto.R")

carpeta_salida <- "11_figuras_diapositiva"
ancho <- 13.33
alto <- 7.5
leer <- function(ruta) read_csv(ruta, show_col_types = FALSE)
num_es <- function(x, d = 1) sub(".", ",", sprintf(paste0("%.", d, "f"), round(x, d) + 0), fixed = TRUE)

primera_alza <- as.Date("2015-09-25")
ultima_alza <- as.Date("2016-07-29")
fuentes_09 <- c("Comunicados", "Minutas: discusión de la Junta")
color_fuente <- c("Comunicados" = unname(colores_tipo["Comunicados"]),
                  "Minutas: discusión de la Junta" = unname(colores_tipo["Minutas"]))
n_reuniones <- "n = 54 comunicados antes y 53 después; 59 minutas antes y 53 después."
ventana_txt <- "Antes: 2009-10-30 a 2014-10-29; después: 2014-10-30 a 2019-10-29."
fuente_txt <- "Fuente: comunicados y minutas de la Junta Directiva del Banco de la República; cálculos propios."

# -----------------------------------------------------------------------------
# 0. Etiquetas con tildes
# -----------------------------------------------------------------------------

# los lemas del analisis no llevan tildes ni "de" en los compuestos. Para las
# etiquetas: (i) un compuesto se muestra con su primera expresion del
# diccionario de 00_funciones_texto.R; (ii) cada palabra toma la forma con
# escritura mas frecuente en el texto original (con o sin tilde)
anotados <- readRDS("01_Datos/03_Listos/tokens_anotados.rds")
formas <- anotados %>%
  transmute(forma = str_to_lower(token)) %>%
  filter(str_detect(forma, "^[\\p{L}]+$")) %>%
  count(forma) %>%
  mutate(clave = sin_tilde(forma)) %>%
  arrange(desc(n)) %>%
  distinct(clave, .keep_all = TRUE)
con_tilde_de <- setNames(formas$forma, formas$clave)
# lemas cuya forma mas frecuente es otra palabra (verbo conjugado): se fijan a mano
con_tilde_de[["termino"]] <- "término"
rm(anotados)
expresion_de <- tapply(names(compuestos), compuestos, function(x) x[1])
etiqueta <- function(lema) {
  map_chr(lema, function(l) {
    texto <- if (l %in% names(expresion_de)) expresion_de[[l]] else str_replace_all(l, "_", " ")
    palabras <- str_split(texto, " ")[[1]]
    paste(coalesce(unname(con_tilde_de[palabras]), palabras), collapse = " ")
  })
}

# -----------------------------------------------------------------------------
# 1. LDA antes y despues, una figura por diapositiva
# -----------------------------------------------------------------------------

lda <- leer("03_Resultados/Tablas/09_lda_oraciones/conjunto_lda_antes_despues_detalle.csv") %>%
  filter(str_starts(escenario, "Principal")) %>%
  mutate(num = as.integer(str_extract(topico, "^\\d+")))

figura_lda <- function(topicos, titulo, archivo) {
  datos <- lda %>%
    filter(num %in% topicos) %>%
    transmute(fuente, topico, num,
              Antes_media = media_antes, Antes_inf = ic_antes_inf, Antes_sup = ic_antes_sup,
              `Después_media` = media_despues, `Después_inf` = ic_despues_inf, `Después_sup` = ic_despues_sup) %>%
    pivot_longer(-c(fuente, topico, num), names_to = c("epoca", ".value"), names_sep = "_") %>%
    mutate(epoca = factor(epoca, levels = c("Antes", "Después")),
           topico = factor(topico, levels = unique(topico[order(match(num, topicos))])),
           fuente = factor(fuente, levels = fuentes_09))
  fig <- ggplot(datos, aes(epoca, media, fill = fuente, alpha = epoca)) +
    geom_col(width = 0.65) +
    geom_errorbar(aes(ymin = inf, ymax = sup), width = 0.18, color = gris_secundario, linewidth = 0.5) +
    geom_text(aes(y = sup, label = paste0(num_es(media), " %")), vjust = -0.6, size = 5.4,
              color = gris_texto, alpha = 1) +
    facet_grid(topico ~ fuente, scales = "free_y", labeller = label_wrap_gen(width = 45)) +
    scale_fill_manual(values = color_fuente, guide = "none") +
    scale_alpha_manual(values = c("Antes" = 0.4, "Después" = 1), guide = "none") +
    scale_y_continuous(labels = scales::label_number(decimal.mark = ","), expand = expansion(mult = c(0, 0.22))) +
    labs(title = titulo,
         subtitle = "Peso medio del tópico en la reunión, 5 años antes y 5 años después del 2014-10-30.",
         x = NULL, y = "Peso del tópico (%)",
         caption = paste("Barras: media por reunión; líneas: intervalo de confianza del 95 %. Modelo de tópicos (LDA, K = 10) estimado con bloques de oraciones.",
                         n_reuniones, fuente_txt, sep = "\n")) +
    tema_presentacion + tema_paneles + tema_diapositiva +
    theme(strip.text.y = element_text(angle = 0, hjust = 0, size = 15), panel.grid.major.x = element_blank())
  guardar_figura(archivo, fig, carpeta_salida, width = ancho, height = alto)
}
figura_lda(c(6, 10), "Peso de los tópicos de déficit externo y de economía mundial, antes y después del corte",
           "conjunto_lda_externo_6_10.png")
figura_lda(c(1, 2), "Peso de los tópicos de actividad interna y de crédito, antes y después del corte",
           "conjunto_lda_credito_actividad_1_2.png")
figura_lda(c(4, 8), "Peso de los dos tópicos de inflación, antes y después del corte",
           "conjunto_lda_inflacion_4_8.png")

# -----------------------------------------------------------------------------
# 2. Texto frente a macro, 2013 a 2018
# -----------------------------------------------------------------------------

desde <- as.Date("2013-01-01")
hasta <- as.Date("2018-12-31")
media_movil <- function(x) as.numeric(stats::filter(x, rep(1 / 5, 5), sides = 1)) # 5 reuniones, solo el pasado
paneles <- c("Entorno externo (por 1.000 palabras)", "Brent (dólares por barril)",
             "TRM (pesos por dólar)", "Inflación total anual (%)")
temas_reunion <- leer("03_Resultados/Tablas/08_antes_despues/conjunto_temas_por_reunion.csv")
externo <- temas_reunion %>%
  filter(tema == "Entorno externo") %>%
  arrange(fecha) %>%
  group_by(fuente) %>% mutate(valor = media_movil(por_mil)) %>% ungroup() %>%
  transmute(fecha, valor, serie = if_else(fuente == "Comunicados", "Comunicados", "Minutas"), panel = paneles[1])
macro <- readRDS("01_Datos/03_Listos/macro_por_reunion.rds")
serie_macro <- bind_rows(
  macro %>% transmute(fecha, valor = brent, serie = "Brent", panel = paneles[2]),
  macro %>% transmute(fecha, valor = trm, serie = "TRM", panel = paneles[3]),
  macro %>% transmute(fecha, valor = inflacion_total, serie = "Inflación total", panel = paneles[4])
)
serie <- bind_rows(externo, serie_macro) %>%
  filter(between(fecha, desde, hasta), !is.na(valor)) %>%
  mutate(panel = factor(panel, levels = paneles))

# extremos: los mismos de la cronologia de 08 (se leen, no se recalculan)
crono <- leer("03_Resultados/Tablas/08_antes_despues/conjunto_cronologia_texto_macro.csv")
extremos <- tribble(
  ~patron,                               ~panel,     ~serie,            ~vj,  ~hj,
  "Entorno externo \\(Comunicados\\)",   paneles[1], "Comunicados",     -0.7, 0.5,
  "Entorno externo \\(Minutas\\)",       paneles[1], "Minutas",          1.8, 0.5,
  "Brent",                               paneles[2], "Brent",            1.7, 0.5,
  "TRM",                                 paneles[3], "TRM",             -0.7, 0.5,
  "nflación total",                      paneles[4], "Inflación total", -0.7, 0.5
) %>%
  mutate(fila = map_int(patron, ~ which(str_detect(crono$evento, .x))[1])) %>%
  mutate(fecha = crono$fecha[fila], valor = crono$valor[fila],
         rotulo = format(fecha, "%d-%m-%Y"), panel = factor(panel, levels = paneles))
stopifnot(!anyNA(extremos$fila))

primer_panel <- list(panel = factor(paneles[1], levels = paneles))
fig_macro <- ggplot(serie, aes(fecha, valor, color = serie)) +
  annotate("rect", xmin = primera_alza, xmax = ultima_alza, ymin = -Inf, ymax = Inf, fill = gris_grilla, alpha = 0.6) +
  capa_corte(corte_crisis, "Corte 30-10-2014", panel = primer_panel) +
  geom_line(linewidth = 1.1) +
  geom_point(data = extremos, size = 3.2, show.legend = FALSE) +
  geom_text(data = extremos, aes(label = rotulo, vjust = vj, hjust = hj), size = 4.6, show.legend = FALSE) +
  facet_wrap(~ panel, ncol = 1, scales = "free_y") +
  coord_cartesian(clip = "off") + # las fechas de los extremos pueden salir del panel
  scale_color_manual(values = c(colores_tipo, colores_macro_diapositiva), breaks = names(colores_tipo)) +
  scale_x_date(breaks = as.Date(paste0(2013:2018, "-01-01")), date_labels = "%Y", limits = c(desde, hasta), expand = expansion(mult = 0.01)) +
  scale_y_continuous(labels = scales::label_number(decimal.mark = ",", big.mark = "."), expand = expansion(mult = c(0.3, 0.35))) +
  labs(title = "Atención al entorno externo, Brent, TRM e inflación total por reunión, 2013 a 2018",
       subtitle = "Comunicados y minutas (solo la discusión de la Junta) y series macro alineadas con cada reunión.",
       x = NULL, y = NULL,
       caption = paste("Texto: media móvil de las últimas 5 reuniones. Macro: último dato que la Junta tenía el día de cada reunión. Puntos: extremos de 2013 a 2018.",
                       "Franja gris: ciclo de alzas de la tasa (25-09-2015 a 29-07-2016). Línea negra: corte del 30-10-2014.",
                       "Fuentes: comunicados y minutas de la Junta; Brent: FRED; TRM: Banco de la República; IPC: DANE.", sep = "\n")) +
  tema_presentacion + tema_paneles + tema_diapositiva +
  theme(plot.title = element_text(size = 20), strip.text = element_text(size = 14), axis.text.y = element_text(size = 12),
        panel.spacing.y = unit(0.3, "lines"))
guardar_figura("conjunto_externo_macro_2013_2018.png", fig_macro, carpeta_salida, width = ancho, height = alto)

# -----------------------------------------------------------------------------
# 3. Palabras distintivas, 10 y 10
# -----------------------------------------------------------------------------

min_palabra <- 20 # el mismo minimo de 08
palabras <- leer("03_Resultados/Tablas/08_antes_despues/conjunto_palabras_cambio_detalle.csv") %>%
  filter(str_starts(escenario, "Principal"), n_antes + n_despues >= min_palabra) %>%
  group_by(fuente) %>%
  group_modify(~ bind_rows(slice_max(.x, razon, n = 10, with_ties = FALSE),
                           slice_min(.x, razon, n = 10, with_ties = FALSE))) %>%
  ungroup() %>%
  mutate(fuente = factor(fuente, levels = fuentes_09), etiqueta = etiqueta(termino),
         etiqueta_fig = reorder_within(etiqueta, razon, fuente))
fig_palabras <- ggplot(palabras, aes(log2(razon), etiqueta_fig, fill = fuente)) +
  geom_col(width = 0.72) +
  geom_vline(xintercept = 0, color = gris_secundario, linewidth = 0.5) +
  facet_wrap(~ fuente, scales = "free_y") +
  scale_y_reordered() +
  scale_x_continuous(breaks = log2(c(1 / 64, 1 / 16, 1 / 4, 1, 4, 16, 64, 256)),
                     labels = c("1/64", "1/16", "1/4", "1", "4", "16", "64", "256")) +
  scale_fill_manual(values = color_fuente, guide = "none") +
  labs(title = "Palabras que más ganan y más pierden peso después del corte",
       subtitle = "Comunicados y minutas (solo la discusión de la Junta), 5 años antes y 5 años después del 2014-10-30.",
       x = "Frecuencia después / antes, por 1.000 palabras (escala logarítmica)", y = NULL,
       caption = paste(paste0("Las 10 palabras que más ganan y las 10 que más pierden; palabras con ", min_palabra, " o más apariciones; se suman 0,5 apariciones a cada época."),
                       paste(ventana_txt, n_reuniones), fuente_txt, sep = "\n")) +
  tema_presentacion + tema_paneles + tema_barras_h + tema_diapositiva +
  theme(axis.text.y = element_text(size = 14, color = gris_texto), axis.text.x = element_text(size = 13))
guardar_figura("conjunto_palabras_10_10.png", fig_palabras, carpeta_salida, width = ancho, height = alto)

# -----------------------------------------------------------------------------
# 4. Con que palabras aparece «inflación» (minutas)
# -----------------------------------------------------------------------------

anclas_fig <- c("inflacion", "expectativas_inflacion")
cor_inf <- leer("03_Resultados/Tablas/08_antes_despues/conjunto_correlaciones_anclas.csv") %>%
  filter(fuente == "Minutas: discusión de la Junta", ancla %in% anclas_fig) %>%
  mutate(ancla = factor(etiqueta(ancla), levels = etiqueta(anclas_fig)),
         epoca = factor(epoca, levels = c("Antes", "Después")),
         palabra = etiqueta(palabra),
         panel = paste(ancla, epoca, sep = "___"),
         palabra_fig = reorder_within(palabra, correlacion, panel))
fig_cor <- ggplot(cor_inf, aes(correlacion, palabra_fig, alpha = epoca)) +
  geom_col(fill = colores_tipo[["Minutas"]], width = 0.72) +
  geom_text(aes(label = num_es(correlacion, 2)), hjust = -0.15, size = 4.8, color = gris_texto, alpha = 1) +
  facet_wrap(~ ancla + epoca, scales = "free_y", nrow = 2, labeller = label_wrap_gen(multi_line = FALSE)) +
  scale_y_reordered() +
  scale_alpha_manual(values = c("Antes" = 0.45, "Después" = 1), guide = "none") +
  scale_x_continuous(labels = scales::label_number(decimal.mark = ","), expand = expansion(mult = c(0, 0.18))) +
  labs(title = "Palabras que acompañan a «inflación» en las minutas, antes y después del corte",
       subtitle = "Minutas (solo la discusión de la Junta), 5 años antes y 5 años después del 2014-10-30.",
       x = "Correlación de aparición en la misma oración (phi)", y = NULL,
       caption = paste("Minutas (solo la discusión de la Junta): las 8 palabras con mayor correlación con cada ancla, por época; palabras en 10 o más oraciones de la época.",
                       paste(ventana_txt, "n = 59 minutas antes y 53 después."), fuente_txt, sep = "\n")) +
  tema_presentacion + tema_paneles + tema_barras_h + tema_diapositiva +
  theme(axis.text.y = element_text(size = 14, color = gris_texto), strip.text = element_text(size = 16))
guardar_figura("minutas_correlaciones_inflacion.png", fig_cor, carpeta_salida, width = ancho, height = alto)

# -----------------------------------------------------------------------------
# 5. Verificacion: ¿el discurso cambio antes de la primera alza?
# -----------------------------------------------------------------------------

# regla fijada antes de ver el resultado: para cada medida y fuente, la media
# movil de 5 reuniones (solo el pasado) se compara con su maximo en los 5 anos
# antes del corte (2009-10-30 a 2014-10-29). Se reporta la primera reunion
# desde el corte en que lo supera. La figura se genera solo si las dos medidas
# lo superan antes de la primera alza (2015-09-25) en comunicados Y en minutas
theta <- leer("03_Resultados/Tablas/09_lda_oraciones/conjunto_lda_theta_por_reunion.csv")
medidas <- bind_rows(
  theta %>% filter(topico == 4) %>% transmute(medida = "Tópico 4: inflación por depreciación y alimentos (%)", fuente, fecha, valor = theta),
  temas_reunion %>% filter(tema == "Entorno externo") %>% transmute(medida = "Entorno externo (por 1.000 palabras)", fuente, fecha, valor = por_mil)
) %>%
  mutate(fuente = if_else(str_starts(fuente, "Comunicados"), "Comunicados", "Minutas")) %>%
  arrange(fecha) %>%
  group_by(medida, fuente) %>% mutate(movil = media_movil(valor)) %>% ungroup()
inicio_antes <- corte_crisis - years(anios_ventana)
verificacion <- medidas %>%
  group_by(medida, fuente) %>%
  summarise(
    maximo_antes = max(movil[fecha >= inicio_antes & fecha < corte_crisis], na.rm = TRUE),
    fecha_maximo_antes = fecha[fecha >= inicio_antes & fecha < corte_crisis][which.max(movil[fecha >= inicio_antes & fecha < corte_crisis])],
    # NA si nunca lo supera
    primera_reunion_supera = suppressWarnings(min(fecha[fecha >= corte_crisis & movil > maximo_antes], na.rm = TRUE)),
    .groups = "drop") %>%
  mutate(primera_reunion_supera = if_else(is.finite(primera_reunion_supera), primera_reunion_supera, as.Date(NA)),
         antes_primera_alza = coalesce(primera_reunion_supera < primera_alza, FALSE),
         meses_antes_alza = round(as.numeric(primera_alza - primera_reunion_supera) / 30.44, 1))
write_csv(verificacion, file.path("03_Resultados/Tablas", carpeta_salida, "conjunto_verificacion_antes_alzas.csv"))
print(verificacion)
sostiene <- all(verificacion$antes_primera_alza)

if (sostiene) {
  datos_v <- medidas %>% filter(between(fecha, desde, hasta), !is.na(movil)) %>%
    mutate(medida = factor(medida, levels = unique(verificacion$medida)))
  umbrales <- verificacion %>% mutate(medida = factor(medida, levels = levels(datos_v$medida)))
  fig_v <- ggplot(datos_v, aes(fecha, movil, color = fuente)) +
    annotate("rect", xmin = primera_alza, xmax = ultima_alza, ymin = -Inf, ymax = Inf, fill = gris_grilla, alpha = 0.6) +
    geom_vline(xintercept = corte_crisis, color = gris_texto, linewidth = 0.7) +
    geom_hline(data = umbrales, aes(yintercept = maximo_antes, color = fuente), linetype = "dashed", linewidth = 0.6) +
    geom_line(linewidth = 1.1) +
    geom_point(data = umbrales, aes(x = primera_reunion_supera, y = maximo_antes), size = 3.4) +
    facet_wrap(~ medida, ncol = 1, scales = "free_y") +
    scale_color_manual(values = colores_tipo) +
    scale_x_date(breaks = as.Date(paste0(2013:2018, "-01-01")), date_labels = "%Y", limits = c(desde, hasta), expand = expansion(mult = 0.01)) +
    scale_y_continuous(labels = scales::label_number(decimal.mark = ",")) +
    labs(title = "Inflación por depreciación y entorno externo frente a su máximo antes del corte, 2013 a 2018",
         subtitle = "Comunicados y minutas (solo la discusión de la Junta), por reunión.",
         x = NULL, y = NULL,
         caption = paste("Líneas: media móvil de las últimas 5 reuniones. Punteadas: máximo de la media móvil en los 5 años antes del corte; punto: primera reunión que lo supera.",
                         "Franja gris: ciclo de alzas (25-09-2015 a 29-07-2016). Línea negra: corte del 30-10-2014.", fuente_txt, sep = "\n")) +
    tema_presentacion + tema_paneles + tema_diapositiva
  guardar_figura("conjunto_cambio_antes_alzas.png", fig_v, carpeta_salida, width = ancho, height = alto)
}

# -----------------------------------------------------------------------------
# 5b. Atencion a cada tema antes y despues (version de diapositiva de la figura de 08)
# -----------------------------------------------------------------------------

temas_ad <- leer("03_Resultados/Tablas/08_antes_despues/conjunto_temas_antes_despues_detalle.csv") %>%
  filter(str_starts(escenario, "Principal")) %>%
  transmute(fuente = factor(fuente, levels = fuentes_09), tema,
            Antes_media = media_antes, Antes_inf = ic_antes_inf, Antes_sup = ic_antes_sup,
            `Después_media` = media_despues, `Después_inf` = ic_despues_inf, `Después_sup` = ic_despues_sup) %>%
  pivot_longer(-c(fuente, tema), names_to = c("epoca", ".value"), names_sep = "_") %>%
  mutate(epoca = factor(epoca, levels = c("Antes", "Después")),
         tema = factor(tema, levels = rev(unique(tema))))
fig_temas <- ggplot(temas_ad, aes(media, tema, fill = fuente, alpha = epoca)) +
  geom_col(aes(group = fct_rev(epoca)), position = position_dodge(width = 0.8), width = 0.75) +
  geom_errorbar(aes(xmin = inf, xmax = sup, group = fct_rev(epoca)), position = position_dodge(width = 0.8),
                width = 0.3, color = gris_secundario, linewidth = 0.5) +
  geom_text(aes(x = sup, label = num_es(media), group = fct_rev(epoca)), position = position_dodge(width = 0.8),
            hjust = -0.25, size = 4.6, color = gris_texto, alpha = 1) +
  facet_wrap(~ fuente) +
  scale_fill_manual(values = color_fuente, guide = "none") +
  scale_alpha_manual(values = c("Antes" = 0.4, "Después" = 1)) +
  scale_x_continuous(labels = scales::label_number(decimal.mark = ","), expand = expansion(mult = c(0, 0.15))) +
  guides(alpha = guide_legend(override.aes = list(fill = gris_secundario))) +
  labs(title = "Atención a cada tema antes y después del corte, por tipo de documento",
       subtitle = "Comunicados y minutas (solo la discusión de la Junta), 5 años antes y 5 años después del 2014-10-30.",
       x = "Palabras del tema por cada 1.000 palabras (media por reunión)", y = NULL,
       caption = paste("Barras claras: antes; oscuras: después. Líneas: intervalo de confianza del 95 % de la media por reunión. Temas: diccionario fijado a priori.",
                       n_reuniones, fuente_txt, sep = "\n")) +
  tema_presentacion + tema_paneles + tema_barras_h + tema_diapositiva +
  theme(axis.text.y = element_text(size = 16, color = gris_texto))
guardar_figura("conjunto_temas_antes_despues.png", fig_temas, carpeta_salida, width = ancho, height = alto)

# -----------------------------------------------------------------------------
# 5c. Brent, TRM e inflacion 2007-2026, con P10 destacado
# -----------------------------------------------------------------------------

meta_anual <- readRDS("01_Datos/03_Listos/macro_meta.rds")
paneles_s <- c("Brent (dólares por barril)", "TRM (pesos por dólar)", "Inflación total anual (%)")
series <- bind_rows(
  macro %>% transmute(fecha, valor = brent, serie = "Brent", panel = paneles_s[1]),
  macro %>% transmute(fecha, valor = trm, serie = "TRM", panel = paneles_s[2]),
  macro %>% transmute(fecha, valor = inflacion_total, serie = "Inflación total", panel = paneles_s[3])
) %>% filter(!is.na(valor)) %>% mutate(panel = factor(panel, levels = paneles_s))
# meta y rango del ano de cada reunion (solo en el panel de inflacion)
meta_reunion <- macro %>%
  transmute(fecha, anio = as.integer(format(fecha, "%Y"))) %>%
  left_join(meta_anual, by = "anio") %>%
  mutate(panel = factor(paneles_s[3], levels = paneles_s))
p10 <- periodos %>% filter(periodo == "P10")
fig_series <- ggplot(series, aes(fecha, valor)) +
  capa_periodos(periodos) +
  annotate("rect", xmin = p10$inicio, xmax = p10$fin, ymin = -Inf, ymax = Inf, fill = gris_secundario, alpha = 0.4) +
  geom_text(data = tibble(fecha = p10$inicio, panel = factor(paneles_s[1], levels = paneles_s)),
            aes(x = fecha, y = Inf, label = "P10"), inherit.aes = FALSE, vjust = 1.4, hjust = 1.15, size = 5, fontface = "bold",
            color = gris_texto) +
  geom_ribbon(data = meta_reunion, aes(x = fecha, ymin = rango_inf, ymax = rango_sup), inherit.aes = FALSE,
              fill = colores_macro_diapositiva[["Inflación total"]], alpha = 0.15) +
  geom_step(data = meta_reunion, aes(x = fecha, y = meta), inherit.aes = FALSE, linetype = "dashed",
            color = gris_texto, linewidth = 0.6) +
  capa_corte(corte_crisis) +
  geom_line(aes(color = serie), linewidth = 1, show.legend = FALSE) +
  facet_wrap(~ panel, ncol = 1, scales = "free_y") +
  scale_color_manual(values = colores_macro_diapositiva) +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y", expand = expansion(mult = 0.01)) +
  scale_y_continuous(labels = scales::label_number(decimal.mark = ",", big.mark = ".")) +
  labs(title = "Brent, TRM e inflación total por reunión, 2007 a 2026",
       subtitle = "Series macro alineadas con cada reunión de la Junta; franja oscura: periodo P10 (alzas de 2026).",
       x = NULL, y = NULL,
       caption = paste("Último dato que la Junta tenía el día de cada reunión. Inflación: línea punteada = meta del año; franja verde = rango meta.",
                       "Sombreado tenue: periodos de política monetaria P1 a P10. Línea negra: corte del 30-10-2014.",
                       "Fuentes: Brent, FRED (DCOILBRENTEU); TRM y meta, Banco de la República; inflación, DANE.", sep = "\n")) +
  tema_presentacion + tema_paneles + tema_diapositiva +
  theme(strip.text = element_text(size = 15), axis.text.y = element_text(size = 13), panel.spacing.y = unit(0.4, "lines"))
guardar_figura("macro_series_2007_2026.png", fig_series, carpeta_salida, width = ancho, height = alto)

# -----------------------------------------------------------------------------
# 5d. Embeddings: coseno antes-despues de cada ancla con GloVe y con Word2Vec
# -----------------------------------------------------------------------------

# lee la tabla de 10_glove.R (no recalcula nada). 1 = el ancla se usa en el mismo
# contexto en las dos epocas; mas bajo = su contexto cambio mas
cosenos <- leer("03_Resultados/Tablas/10_glove/conjunto_glove_vecinos.csv") %>%
  # las anclas vienen con espacio en vez de guion bajo; la tasa se nombra a mano (no es un compuesto del diccionario)
  transmute(ancla = recode(etiqueta(str_replace_all(ancla, " ", "_")), "tasa intervención" = "tasa de intervención"),
            GloVe = coseno_antes_despues, Word2Vec = coseno_w2v) %>%
  pivot_longer(-ancla, names_to = "metodo", values_to = "coseno") %>%
  mutate(metodo = factor(metodo, levels = c("GloVe", "Word2Vec")),
         destacada = ancla == "expectativas de inflación",
         ancla_fig = reorder_within(ancla, -coseno, metodo))
fig_cosenos <- ggplot(cosenos, aes(coseno, ancla_fig, fill = destacada)) +
  geom_col(width = 0.65) +
  geom_vline(xintercept = 1, color = gris_texto, linewidth = 0.7, linetype = "dashed") +
  annotate("text", x = 0.99, y = Inf, label = "1 = mismo contexto", hjust = 1, vjust = 1.3, size = 5, color = gris_texto) +
  geom_text(aes(label = num_es(coseno, 2)), hjust = -0.2, size = 5.4, color = gris_texto) +
  facet_wrap(~ metodo, scales = "free_y") +
  scale_y_reordered() +
  scale_x_continuous(limits = c(0, 1.02), breaks = seq(0, 1, 0.25), labels = scales::label_number(decimal.mark = ","),
                     expand = expansion(mult = c(0, 0.02))) +
  scale_fill_manual(values = c("TRUE" = paleta_categorica[3], "FALSE" = gris_nota), guide = "none") +
  labs(title = "Parecido entre el contexto de cada palabra antes y después del corte",
       subtitle = "Comunicados y minutas (solo la discusión de la Junta) en un solo modelo, 5 años antes y 5 años después del 2014-10-30.",
       x = "Coseno entre el vector de la palabra antes y después (más bajo = su contexto cambió más)", y = NULL,
       caption = paste("GloVe: promedio de tres semillas. Word2Vec: promedio de cinco entrenamientos, como robustez; varía unas centésimas entre corridas.",
                       "Palabras ancla con 30 o más oraciones en cada época; documento = oración.",
                       fuente_txt, sep = "\n")) +
  tema_presentacion + tema_paneles + tema_barras_h + tema_diapositiva +
  theme(axis.text.y = element_text(size = 17, color = gris_texto))
guardar_figura("conjunto_glove_cosenos.png", fig_cosenos, carpeta_salida, width = ancho, height = alto)

# -----------------------------------------------------------------------------
# 6. Chequeos
# -----------------------------------------------------------------------------

stopifnot(
  nrow(lda %>% filter(num %in% c(1, 2, 4, 6, 8, 10))) == 12, # 6 topicos x 2 fuentes
  nrow(palabras) == 40,
  all(c("déficit", "devaluación", "indexación", "cuenta corriente") %in% palabras$etiqueta),
  nrow(cor_inf) == 32, # 2 anclas x 2 epocas x 8 palabras
  nrow(verificacion) == 4, all(is.finite(verificacion$maximo_antes)),
  nrow(temas_ad) == 24, # 6 temas x 2 fuentes x 2 epocas
  nrow(p10) == 1,
  nrow(cosenos) == 8, # 4 anclas x 2 metodos
  all(between(cosenos$coseno, -1, 1))
)

message("11_figuras_diapositiva: listo. Verificación antes de alzas: ", if (sostiene) "se sostiene" else "no se sostiene")
