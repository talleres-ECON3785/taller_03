# =============================================================================
# 03. Palabras frecuentes y vocabulario distintivo (TF-IDF)
# Taller 3 - ECON-3785
#
# Entradas: 01_Datos/03_Listos/tokens_limpios.rds, 01_Datos/02_Procesados/corpus_texto.rds
# Salidas:  03_Resultados/Tablas/03_frecuencias_tfidf/ y Figuras/03_frecuencias_tfidf/
#
# EXPLORATORIO. Todas las frecuencias se normalizan por la extension del texto
# (apariciones por cada 1.000 palabras del documento), porque el formato de
# las minutas cambia y el numero de reuniones al ano pasa de 11-12 a 8.
# Comunicados y minutas van por separado o comparados explicitamente. Las
# minutas se reportan en dos versiones, lado a lado: solo la discusion de la
# Junta (la que importa para la pregunta) y el texto completo (que hasta abril
# de 2019 incluye la vision del equipo tecnico).
#
# Que hace:
#   1. palabras mas frecuentes por tipo y por periodo;
#   2. TF-IDF con grupo = periodo, dentro de cada tipo de documento;
#   3. minutas frente a comunicados en las fechas que tienen los dos;
#   4. atencion a cada tema por ano (grupos de palabras fijados a priori);
#   5. como se nombra la tasa del Banco en cada periodo.
# =============================================================================

# los paquetes los carga 00_main.R con pacman

source("02_Scripts/00_formato_tablas.R")
source("02_Scripts/00_funciones_texto.R")

carpeta_salida <- "03_frecuencias_tfidf"

corpus <- readRDS("01_Datos/02_Procesados/corpus_texto.rds")
limpios <- readRDS("01_Datos/03_Listos/tokens_limpios.rds")

n_com <- sum(corpus$tipo == "comunicado")
n_min <- sum(corpus$tipo == "minuta")

# tres "fuentes": comunicados, minutas (solo Junta) y minutas (texto completo).
# Cada una con sus tokens limpios y con las palabras totales de cada documento
# (el denominador de las frecuencias por 1.000 palabras)
fuentes <- c(com = "Comunicados", junta = "Minutas: discusión de la Junta", completo = "Minutas: texto completo")
tokens_fuente <- bind_rows(
  limpios %>% filter(tipo == "comunicado") %>% mutate(fuente = "com"),
  limpios %>% filter(tipo == "minuta", es_junta) %>% mutate(fuente = "junta"),
  limpios %>% filter(tipo == "minuta") %>% mutate(fuente = "completo")
) %>% select(fuente, id, fecha, periodo, word)
palabras_doc <- bind_rows(
  corpus %>% filter(tipo == "comunicado") %>% transmute(fuente = "com", id, fecha, periodo, palabras),
  corpus %>% filter(tipo == "minuta") %>% transmute(fuente = "junta", id, fecha, periodo, palabras = palabras_junta),
  # el texto completo no incluye el preambulo de asistentes (02 lo excluye)
  corpus %>% filter(tipo == "minuta") %>% transmute(fuente = "completo", id, fecha, periodo, palabras = palabras - palabras_preambulo)
)
palabras_fuente <- palabras_doc %>% group_by(fuente) %>% summarise(palabras = sum(palabras), docs = n(), .groups = "drop")
palabras_periodo <- palabras_doc %>% group_by(fuente, periodo) %>% summarise(palabras = sum(palabras), docs = n(), .groups = "drop")

fmt_es <- function(tabla, columnas, decimales_n) {
  fmt_number(tabla, columns = all_of(columnas), decimals = decimales_n, dec_mark = ",", sep_mark = ".")
}
nota_norm <- "Frecuencia por cada 1.000 palabras del texto (todas las palabras, no solo las que quedan tras la limpieza). Palabras lematizadas y sin tildes; los términos compuestos van unidos con guion bajo."

# -----------------------------------------------------------------------------
# 1. Palabras mas frecuentes por tipo
# -----------------------------------------------------------------------------

frec_fuente <- tokens_fuente %>%
  group_by(fuente, word) %>%
  summarise(n = n(), docs = n_distinct(id), .groups = "drop") %>%
  left_join(palabras_fuente %>% rename(total = palabras, total_docs = docs), by = "fuente") %>%
  mutate(por_mil = 1000 * n / total, pct_docs = 100 * docs / total_docs)

datos_top <- frec_fuente %>%
  group_by(fuente) %>% slice_max(n, n = 20, with_ties = FALSE) %>%
  mutate(puesto = row_number()) %>% ungroup() %>%
  select(fuente, puesto, word, por_mil, pct_docs) %>%
  pivot_wider(names_from = fuente, values_from = c(word, por_mil, pct_docs)) %>%
  select(puesto, word_com, por_mil_com, pct_docs_com, word_junta, por_mil_junta, pct_docs_junta,
         word_completo, por_mil_completo, pct_docs_completo)
tabla_top <- datos_top %>%
  gt() %>%
  cols_label(puesto = "", word_com = "Palabra", por_mil_com = "Por 1.000", pct_docs_com = "% doc.",
             word_junta = "Palabra", por_mil_junta = "Por 1.000", pct_docs_junta = "% doc.",
             word_completo = "Palabra", por_mil_completo = "Por 1.000", pct_docs_completo = "% doc.") %>%
  tab_spanner("Comunicados", columns = ends_with("_com")) %>%
  tab_spanner("Minutas: discusión de la Junta", columns = ends_with("_junta")) %>%
  tab_spanner("Minutas: texto completo", columns = ends_with("_completo")) %>%
  fmt_es(c("por_mil_com", "por_mil_junta", "por_mil_completo"), decimales$por_mil) %>%
  fmt_es(c("pct_docs_com", "pct_docs_junta", "pct_docs_completo"), 0) %>%
  estilo_tabla(
    titulo = "Las 20 palabras más frecuentes en los documentos de la Junta",
    subtitulo = "Comunicados y minutas; las minutas, solo con la discusión de la Junta y con el texto completo",
    nota = nota_tabla("conjunto", n = n_com + n_min, extra = c(nota_norm, "% doc.: porcentaje de los documentos en que aparece la palabra."))
  )
guardar_tabla("conjunto_palabras_frecuentes", tabla_top, datos_top, carpeta_salida)

# -----------------------------------------------------------------------------
# 2. Frecuencias y TF-IDF por periodo, dentro de cada tipo
# -----------------------------------------------------------------------------

frec_periodo <- tokens_fuente %>%
  count(fuente, periodo, word) %>%
  left_join(palabras_periodo, by = c("fuente", "periodo")) %>%
  mutate(por_mil = 1000 * n / palabras)

# TF-IDF: el "documento" es el periodo (10 grupos), dentro de cada fuente. El
# idf solo toma 10 valores posibles: log(10 / numero de periodos con la
# palabra). Se filtra n >= 8 apariciones en el periodo (como el Lab 11) para
# que no dominen palabras rarisimas. En P9 (5 documentos) el filtro deja
# pocas palabras
tfidf_periodo <- frec_periodo %>%
  group_by(fuente) %>%
  group_modify(~ bind_tf_idf(.x, word, periodo, n)) %>%
  ungroup()
min_apariciones <- 8

# figura de barras por periodo (10 paneles): `valor` es la columna a graficar
figura_periodos <- function(datos, valor, titulo, subtitulo, eje, nota, color) {
  datos <- datos %>%
    left_join(select(periodos, periodo, etiqueta), by = "periodo") %>%
    mutate(word = reorder_within(word, .data[[valor]], etiqueta))
  ggplot(datos, aes(.data[[valor]], word)) +
    geom_col(fill = color, width = 0.7) +
    facet_wrap(~ etiqueta, scales = "free", ncol = 5, labeller = label_wrap_gen(width = 26)) +
    scale_y_reordered() +
    scale_x_continuous(labels = scales::label_number(decimal.mark = ",", big.mark = "."),
                       n.breaks = 3, expand = expansion(mult = c(0, 0.08))) +
    labs(title = titulo, subtitle = subtitulo, x = eje, y = NULL, caption = nota) +
    tema_presentacion + tema_paneles + tema_barras_h +
    theme(strip.text = element_text(size = 8.5), axis.text.x = element_text(size = 7.5),
          axis.text.y = element_text(size = 8))
}
docs_por_periodo <- function(f) {
  palabras_periodo %>% filter(fuente == f) %>%
    summarise(t = paste0(periodo, ": ", docs, collapse = "; ")) %>% pull(t)
}
color_fuente <- c(com = unname(colores_tipo["Comunicados"]), junta = unname(colores_tipo["Minutas"]),
                  completo = unname(colores_tipo["Minutas"]))
archivo_fuente <- c(com = "comunicados", junta = "minutas", completo = "minutas")
sufijo_fuente <- c(com = "", junta = "", completo = "_completo")
subtitulo_fuente <- c(
  com = subtitulo_comunicados,
  junta = paste(subtitulo_minutas, "Solo la discusión de la Junta."),
  completo = paste(subtitulo_minutas, "Texto completo (incluye al equipo técnico).")
)

for (f in names(fuentes)) {
  n_f <- palabras_fuente$docs[palabras_fuente$fuente == f]
  # (a) las mas frecuentes
  fig <- frec_periodo %>% filter(fuente == f) %>%
    group_by(periodo) %>% slice_max(n, n = 8, with_ties = FALSE) %>% ungroup() %>%
    figura_periodos(
      "por_mil", "Palabras más frecuentes por periodo de política monetaria", subtitulo_fuente[[f]],
      "Apariciones por cada 1.000 palabras",
      paste0("n = ", n_f, " documentos (", docs_por_periodo(f), "). Las 8 palabras más frecuentes de cada periodo. ", nota_exploratoria),
      color_fuente[[f]]
    )
  guardar_figura(paste0(archivo_fuente[[f]], "_frecuentes_periodo", sufijo_fuente[[f]], ".png"), fig,
                 carpeta_salida, width = 12, height = 7)
  # (b) las mas distintivas (TF-IDF)
  fig <- tfidf_periodo %>% filter(fuente == f, n >= min_apariciones) %>%
    group_by(periodo) %>% slice_max(tf_idf, n = 8, with_ties = FALSE) %>% ungroup() %>%
    mutate(tf_idf = 1000 * tf_idf) %>%
    figura_periodos(
      "tf_idf", "Palabras distintivas de cada periodo de política monetaria (TF-IDF)", subtitulo_fuente[[f]],
      "TF-IDF × 1.000",
      paste0("n = ", n_f, " documentos (", docs_por_periodo(f), "). TF-IDF con el periodo como grupo (10 grupos); palabras con ",
             min_apariciones, " o más apariciones en el periodo. ", nota_exploratoria),
      color_fuente[[f]]
    )
  guardar_figura(paste0(archivo_fuente[[f]], "_tfidf_periodo", sufijo_fuente[[f]], ".png"), fig,
                 carpeta_salida, width = 12, height = 7)
}

# tabla compacta: las 8 palabras distintivas de cada periodo, las tres fuentes
# lado a lado
datos_tfidf <- tfidf_periodo %>%
  filter(n >= min_apariciones) %>%
  group_by(fuente, periodo) %>% slice_max(tf_idf, n = 8, with_ties = FALSE) %>%
  summarise(palabras = paste(word, collapse = ", "), .groups = "drop") %>%
  pivot_wider(names_from = fuente, values_from = palabras) %>%
  left_join(select(periodos, periodo, etiqueta), by = "periodo") %>%
  left_join(palabras_periodo %>% select(fuente, periodo, docs) %>% pivot_wider(names_from = fuente, values_from = docs, names_prefix = "docs_"),
            by = "periodo") %>%
  transmute(periodo = as.character(etiqueta), docs_com, com, docs_junta, junta, completo)
tabla_tfidf <- datos_tfidf %>%
  gt() %>%
  cols_label(periodo = "Periodo", docs_com = "n", com = "Comunicados", docs_junta = "n",
             junta = "Minutas: discusión de la Junta", completo = "Minutas: texto completo") %>%
  sub_missing(missing_text = "—") %>%
  cols_width(periodo ~ px(170), com ~ px(290), junta ~ px(290), completo ~ px(290)) %>%
  tab_style(cell_text(size = px(11.5)), cells_body(columns = c(com, junta, completo))) %>%
  estilo_tabla(
    titulo = "Vocabulario distintivo de cada periodo de política monetaria",
    subtitulo = "Las 8 palabras de mayor TF-IDF por periodo, en comunicados y en minutas",
    nota = nota_tabla("conjunto", n = n_com + n_min, extra = c(
      paste0("TF-IDF con el periodo como grupo (10 grupos), dentro de cada tipo de documento; palabras con ", min_apariciones, " o más apariciones en el periodo. n: documentos del periodo."),
      "Los periodos P6 en adelante coinciden con formatos de minuta distintos de los anteriores: en las minutas, una palabra puede distinguir un periodo por el formato y no por el tema. Los comunicados sirven de contraste."
    ))
  )
guardar_tabla("conjunto_tfidf_por_periodo", tabla_tfidf, datos_tfidf, carpeta_salida)
write_csv(
  tfidf_periodo %>% filter(n >= min_apariciones) %>%
    transmute(fuente = fuentes[fuente], periodo, word, n, por_mil, tf, idf, tf_idf) %>%
    arrange(fuente, periodo, desc(tf_idf)),
  file.path("03_Resultados/Tablas", carpeta_salida, "conjunto_tfidf_periodo_detalle.csv")
)

# -----------------------------------------------------------------------------
# 3. Minutas frente a comunicados, en las fechas con los dos documentos
# -----------------------------------------------------------------------------

fechas_ambos <- as.Date(intersect(
  as.character(corpus$fecha[corpus$tipo == "comunicado"]),
  as.character(corpus$fecha[corpus$tipo == "minuta"])
))
n_ambos <- length(fechas_ambos)
message("Fechas con comunicado y minuta: ", n_ambos)

comparar <- function(f_minuta) {
  tok <- tokens_fuente %>% filter(fuente %in% c("com", f_minuta), fecha %in% fechas_ambos)
  tot <- palabras_doc %>% filter(fuente %in% c("com", f_minuta), fecha %in% fechas_ambos) %>%
    group_by(fuente) %>% summarise(total = sum(palabras), .groups = "drop")
  tok %>%
    count(fuente, word) %>%
    # TF-IDF con 2 grupos: el idf solo vale 0 (la palabra esta en los dos) o
    # log(2) (esta en uno solo)
    bind_tf_idf(word, fuente, n) %>%
    left_join(tot, by = "fuente") %>%
    mutate(por_mil = 1000 * n / total, fuente = if_else(fuente == "com", "com", "min")) %>%
    select(fuente, word, n, por_mil, tf_idf) %>%
    pivot_wider(names_from = fuente, values_from = c(n, por_mil, tf_idf), values_fill = 0) %>%
    mutate(
      # razon de frecuencias normalizadas, con 0,5 apariciones sumadas a cada
      # lado para que la razon exista cuando la palabra falta en un documento
      razon = ((n_min + 0.5) / tot$total[tot$fuente == f_minuta]) / ((n_com + 0.5) / tot$total[tot$fuente == "com"]),
      version = f_minuta
    )
}
comp_junta <- comparar("junta")
comp_completo <- comparar("completo")
min_total <- 20 # apariciones minimas (sumando los dos documentos) para entrar

datos_comp <- comp_junta %>%
  filter(n_min + n_com >= min_total) %>%
  left_join(comp_completo %>% select(word, razon_completo = razon, por_mil_min_completo = por_mil_min), by = "word") %>%
  mutate(lado = if_else(razon > 1, "Más en las minutas (discusión de la Junta)", "Más en los comunicados")) %>%
  group_by(lado) %>%
  slice_max(abs(log(razon)), n = 20, with_ties = FALSE) %>%
  ungroup() %>%
  arrange(lado, desc(abs(log(razon)))) %>%
  transmute(lado, word, por_mil_com, por_mil_min, razon, por_mil_min_completo, razon_completo,
            solo_en_uno = if_else(n_com == 0 | n_min == 0, "sí", "no"))
tabla_comp <- datos_comp %>%
  gt(groupname_col = "lado") %>%
  cols_label(word = "Palabra", por_mil_com = "Comunicados", por_mil_min = "Por 1.000", razon = "Razón minuta / comunicado",
             por_mil_min_completo = "Por 1.000", razon_completo = "Razón minuta / comunicado",
             solo_en_uno = "Solo en un tipo (idf > 0)") %>%
  tab_spanner("Por 1.000", columns = por_mil_com, id = "sp_com") %>%
  tab_spanner("Minutas: discusión de la Junta", columns = c(por_mil_min, razon)) %>%
  tab_spanner("Minutas: texto completo", columns = c(por_mil_min_completo, razon_completo)) %>%
  fmt_es(c("por_mil_com", "por_mil_min", "por_mil_min_completo"), 2) %>%
  fmt_es(c("razon", "razon_completo"), decimales$razon) %>%
  tab_style(cell_text(weight = "bold"), cells_row_groups()) %>%
  estilo_tabla(
    titulo = "Qué palabras pesan más en la minuta que en el comunicado de la misma reunión",
    subtitulo = paste0("Las 20 palabras con mayor diferencia en cada dirección, en las ", n_ambos, " reuniones con los dos documentos"),
    nota = nota_tabla("conjunto", n = 2 * n_ambos, periodo = paste0(n_ambos, " reuniones con comunicado y minuta, junio de 2007 a septiembre de 2026"), extra = c(
      paste0("Razón: frecuencia por 1.000 palabras en las minutas dividida por la de los comunicados (con 0,5 apariciones sumadas a cada lado). Palabras con ", min_total, " o más apariciones en total."),
      "Limitación: con solo 2 grupos el TF-IDF no ordena las palabras compartidas (su idf es 0) y solo destaca las que están en un único tipo de documento; por eso se ordena por la razón de frecuencias."
    ))
  )
guardar_tabla("conjunto_minutas_vs_comunicados", tabla_comp, datos_comp, carpeta_salida)
write_csv(
  bind_rows(comp_junta, comp_completo) %>% mutate(version = fuentes[version]) %>% arrange(version, desc(razon)),
  file.path("03_Resultados/Tablas", carpeta_salida, "conjunto_min_vs_com_detalle.csv")
)

datos_fig_comp <- datos_comp %>%
  group_by(lado) %>% slice_max(abs(log(razon)), n = 15, with_ties = FALSE) %>% ungroup() %>%
  mutate(word = reorder(word, razon))
fig_comp <- ggplot(datos_fig_comp, aes(razon, word, fill = lado)) +
  geom_col(width = 0.7) +
  geom_vline(xintercept = 1, color = gris_secundario, linewidth = 0.4) +
  scale_x_log10(labels = scales::label_number(decimal.mark = ",", big.mark = ".")) +
  scale_fill_manual(values = c("Más en las minutas (discusión de la Junta)" = unname(colores_tipo["Minutas"]),
                               "Más en los comunicados" = unname(colores_tipo["Comunicados"]))) +
  labs(
    title = "Palabras propias de la minuta y del comunicado de una misma reunión",
    subtitle = paste0("Comunicados y minutas (solo la discusión de la Junta) de las ", n_ambos, " reuniones con los dos documentos, 2007 a 2026."),
    x = "Razón de frecuencias por 1.000 palabras, minuta / comunicado (escala logarítmica)", y = NULL,
    caption = paste0("n = ", n_ambos, " comunicados y ", n_ambos, " minutas. La línea vertical marca la misma frecuencia en los dos documentos. Palabras con ",
                     min_total, " o más apariciones. ", nota_exploratoria)
  ) +
  tema_presentacion + tema_barras_h
guardar_figura("conjunto_minutas_vs_comunicados.png", fig_comp, carpeta_salida, height = 7.5)

# -----------------------------------------------------------------------------
# 4. Atencion a cada tema por ano
# -----------------------------------------------------------------------------

tema_de <- enframe(temas, name = "tema", value = "word") %>% unnest(word)
atencion_doc <- tokens_fuente %>%
  inner_join(tema_de, by = "word", relationship = "many-to-many") %>%
  count(fuente, id, tema) %>%
  right_join(expand_grid(palabras_doc, tema = names(temas)), by = c("fuente", "id", "tema")) %>%
  mutate(n = coalesce(n, 0L), anio = as.integer(format(fecha, "%Y")))
atencion_anio <- atencion_doc %>%
  group_by(fuente, tema, anio) %>%
  summarise(por_mil = 1000 * sum(n) / sum(palabras), docs = n(), .groups = "drop") %>%
  mutate(tema = factor(tema, levels = names(temas)))
write_csv(atencion_anio %>% mutate(fuente = fuentes[fuente]),
          file.path("03_Resultados/Tablas", carpeta_salida, "conjunto_temas_por_anio.csv"))
write_csv(atencion_doc %>% transmute(fuente = fuentes[fuente], id, fecha, periodo, tema, n, palabras, por_mil = 1000 * n / palabras),
          file.path("03_Resultados/Tablas", carpeta_salida, "conjunto_temas_por_documento.csv"))

datos_fig_temas <- atencion_anio %>%
  filter(fuente != "completo") %>%
  mutate(fuente = if_else(fuente == "com", "Comunicados", "Minutas"),
         fecha = as.Date(paste0(anio, "-07-01")))
fig_temas <- ggplot(datos_fig_temas, aes(fecha, por_mil, color = fuente)) +
  capa_cortes_formato(cortes_formato) +
  geom_line(linewidth = 0.8) +
  facet_wrap(~ tema, scales = "free_y", ncol = 3) +
  scale_color_manual(values = colores_tipo) +
  scale_x_date(date_breaks = "4 years", date_labels = "%Y") +
  scale_y_continuous(labels = scales::label_number(decimal.mark = ",", big.mark = "."), limits = c(0, NA)) +
  labs(
    title = "Atención de la Junta a cada tema, por año",
    subtitle = "Comunicados y minutas (solo la discusión de la Junta), 2007 a 2026. Grupos de palabras fijados a priori.",
    x = "Año de la reunión", y = "Apariciones por cada 1.000 palabras",
    caption = paste0("n = ", n_com, " comunicados y ", n_min, " minutas. Suma de las apariciones de las palabras de cada tema sobre las palabras del año. Líneas punteadas: cambios de formato de las minutas. ", nota_exploratoria)
  ) +
  tema_presentacion + tema_paneles
guardar_figura("conjunto_temas_por_anio.png", fig_temas, carpeta_salida, width = 11, height = 6.5)

# la misma medida, minutas completas frente a solo la Junta (lado a lado)
datos_fig_versiones <- atencion_anio %>%
  filter(fuente != "com") %>%
  mutate(fuente = if_else(fuente == "junta", "Solo discusión de la Junta", "Texto completo"),
         fecha = as.Date(paste0(anio, "-07-01")))
fig_versiones <- ggplot(datos_fig_versiones, aes(fecha, por_mil, linetype = fuente)) +
  capa_cortes_formato(cortes_formato) +
  geom_line(linewidth = 0.8, color = colores_tipo[["Minutas"]]) +
  facet_wrap(~ tema, scales = "free_y", ncol = 3) +
  scale_linetype_manual(values = c("Solo discusión de la Junta" = "solid", "Texto completo" = "22")) +
  scale_x_date(date_breaks = "4 years", date_labels = "%Y") +
  scale_y_continuous(labels = scales::label_number(decimal.mark = ",", big.mark = "."), limits = c(0, NA)) +
  labs(
    title = "Atención a cada tema en las minutas: discusión de la Junta frente a texto completo",
    subtitle = subtitulo_minutas,
    x = "Año de la reunión", y = "Apariciones por cada 1.000 palabras",
    caption = paste0("n = ", n_min, " minutas. Desde junio de 2019 las dos versiones casi coinciden: la minuta ya no trae la sección del equipo técnico. Líneas punteadas: cambios de formato. ", nota_exploratoria)
  ) +
  tema_presentacion + tema_paneles
guardar_figura("minutas_temas_junta_vs_completo.png", fig_versiones, carpeta_salida, width = 11, height = 6.5)

# resumen por periodo (tabla): atencion a cada tema en minutas (Junta) y comunicados
datos_temas_periodo <- atencion_doc %>%
  filter(fuente != "completo") %>%
  group_by(fuente, periodo, tema) %>%
  summarise(por_mil = 1000 * sum(n) / sum(palabras), .groups = "drop") %>%
  mutate(col = paste(if_else(fuente == "com", "com", "min"), tema, sep = "__")) %>%
  select(periodo, col, por_mil) %>%
  pivot_wider(names_from = col, values_from = por_mil) %>%
  left_join(select(periodos, periodo, etiqueta), by = "periodo") %>%
  mutate(periodo = as.character(etiqueta)) %>% select(-etiqueta)
tabla_temas_periodo <- datos_temas_periodo %>%
  gt() %>%
  cols_label(periodo = "Periodo") %>%
  cols_label_with(columns = -periodo, fn = ~ str_remove(.x, "^(com|min)__")) %>%
  tab_spanner("Comunicados", columns = starts_with("com__")) %>%
  tab_spanner("Minutas: discusión de la Junta", columns = starts_with("min__")) %>%
  fmt_es(names(datos_temas_periodo)[-1], decimales$por_mil) %>%
  estilo_tabla(
    titulo = "Atención a cada tema por periodo de política monetaria",
    subtitulo = "Apariciones de las palabras de cada tema por cada 1.000 palabras",
    nota = nota_tabla("conjunto", n = n_com + n_min, extra = c(
      "Temas: grupos de palabras fijados antes de ver las series (ver 00_funciones_texto.R). Son conteos de palabras, no un modelo.",
      nota_norm))
  )
guardar_tabla("conjunto_temas_por_periodo", tabla_temas_periodo, datos_temas_periodo, carpeta_salida)

# -----------------------------------------------------------------------------
# 5. Como se nombra la tasa del Banco en cada periodo
# -----------------------------------------------------------------------------

nombres_tasa <- c(
  "«intervención»" = "\\btasas? de (inter[eé]s de )?intervenci[oó]n\\b",
  "«política»" = "\\btasas? de (inter[eé]s de )?pol[ií]tica( monetaria)?\\b",
  "«referencia»" = patron_tasa_referencia
)
datos_nombres <- corpus %>%
  select(tipo, periodo, texto) %>%
  mutate(texto = str_to_lower(texto)) %>%
  group_by(tipo, periodo) %>%
  summarise(across(texto, list(!!!map(nombres_tasa, ~ function(x) sum(str_count(x, .x)))), .names = "{.fn}"), .groups = "drop") %>%
  pivot_wider(names_from = tipo, values_from = all_of(names(nombres_tasa)), names_glue = "{tipo}__{.value}") %>%
  left_join(select(periodos, periodo, etiqueta), by = "periodo") %>%
  mutate(periodo = as.character(etiqueta)) %>% select(-etiqueta) %>%
  select(periodo, starts_with("comunicado"), starts_with("minuta"))
tabla_nombres <- datos_nombres %>%
  gt() %>%
  cols_label(periodo = "Periodo") %>%
  cols_label_with(columns = -periodo, fn = ~ str_remove(.x, "^(comunicado|minuta)__")) %>%
  tab_spanner("Comunicados (menciones)", columns = starts_with("comunicado")) %>%
  tab_spanner("Minutas, texto completo (menciones)", columns = starts_with("minuta")) %>%
  estilo_tabla(
    titulo = "Cómo se nombra la tasa del Banco en cada periodo",
    subtitulo = "Menciones de «tasa de intervención», «tasa de política» y «tasa de referencia»",
    nota = nota_tabla("conjunto", n = n_com + n_min, extra =
      "Conteo sobre el texto extraído, antes de unir los términos. En el análisis, «intervención» y «política» se unen en un solo término; «referencia» queda aparte porque también nombra la tasa de otros bancos centrales.")
  )
guardar_tabla("conjunto_nombres_tasa_por_periodo", tabla_nombres, datos_nombres, carpeta_salida)

message("03_frecuencias_tfidf: listo.")
