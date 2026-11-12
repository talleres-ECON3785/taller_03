# =============================================================================
# 05. LDA exploratorio sobre las minutas
# Taller 3 - ECON-3785
#
# Entradas: 01_Datos/03_Listos/tokens_limpios.rds, tokens_anotados.rds,
#           vocabulario_lda.rds y 01_Datos/02_Procesados/corpus_texto.rds
# Salidas:  03_Resultados/Tablas/05_lda_exploratorio/ y Figuras/05_lda_exploratorio/
#
# EXPLORATORIO, SIN SELECCION DE HIPERPARAMETROS. Solo minutas, con K = 6 y
# K = 10. No se eligio K con ningun criterio: los dos valores sirven para ver
# que temas aparecen, no para medir. Los topicos no se nombran: se identifican
# por numero, con sus palabras y los fragmentos que los respaldan.
#
# Dos estimaciones, las dos del catalogo (seccion 6):
#   - "vem": LDA por defecto de topicmodels (VEM), solo K y la semilla. En
#     este corpus el alfa que estima es muy alto (mas de 100) y todas las
#     minutas quedan con un peso casi igual en todos los topicos (theta cerca
#     de 1/K): no separa temas. Se reporta para dejarlo documentado.
#   - "gibbs": muestreo de Gibbs con los hiperparametros del Lab 12
#     (alpha = 0,1, delta = 1, 1.000 iteraciones, 200 de calentamiento). Son
#     los valores del laboratorio, NO elegidos para este corpus. Con esta
#     version se reportan los documentos representativos y la atencion por
#     periodo.
#
# Se estima en dos versiones, lado a lado: solo la discusion de la Junta (la
# que importa para la pregunta) y el texto completo de la minuta (que hasta
# abril de 2019 incluye la vision del equipo tecnico).
#
# Para cada topico: las 6 palabras de mayor beta, las 8 de mayor lift (entre
# las palabras con 30 o mas apariciones), las 3 minutas mas representativas
# con un fragmento de texto, la atencion promedio por periodo y la extension
# de las minutas en que es el topico principal.
# =============================================================================

# los paquetes los carga 00_main.R con pacman

source("02_Scripts/00_formato_tablas.R")
source("02_Scripts/00_funciones_texto.R")

carpeta_salida <- "05_lda_exploratorio"
set.seed(2026)

corpus <- readRDS("01_Datos/02_Procesados/corpus_texto.rds") %>% filter(tipo == "minuta")
limpios <- readRDS("01_Datos/03_Listos/tokens_limpios.rds") %>% filter(tipo == "minuta")
anotados <- readRDS("01_Datos/03_Listos/tokens_anotados.rds") %>% filter(tipo == "minuta")
vocabulario <- readRDS("01_Datos/03_Listos/vocabulario_lda.rds")
unir_referencia <- FALSE # igual que en 02 (ver la tabla de variantes de la tasa)

n_min <- nrow(corpus)
etiqueta_exploratorio <- "Exploratorio, sin selección de hiperparámetros: LDA por defecto (VEM), solo se fijan K y la semilla."
fmt_es <- function(tabla, columnas, decimales_n) {
  fmt_number(tabla, columns = all_of(columnas), decimals = decimales_n, dec_mark = ",", sep_mark = ".")
}

# de cada token (como aparece en el texto) a su lema limpio, para puntuar las
# oraciones del texto original con las palabras de cada topico
lema_de <- anotados %>%
  filter(limpio) %>%
  count(token = str_to_lower(token), word) %>%
  group_by(token) %>% slice_max(n, n = 1, with_ties = FALSE) %>% ungroup() %>%
  select(token, word)

# oraciones del texto original de la discusion de la Junta, con sus lemas
oraciones <- corpus %>%
  transmute(id, oracion = partir_oraciones(texto_junta)) %>%
  unnest(oracion) %>%
  group_by(id) %>% mutate(n_oracion = row_number()) %>% ungroup()
lemas_oracion <- oraciones %>%
  mutate(texto = aplicar_compuestos(oracion, unir_referencia)) %>%
  select(id, n_oracion, texto) %>%
  unnest_tokens(token, texto) %>%
  inner_join(lema_de, by = "token")

# -----------------------------------------------------------------------------
# Funcion: estima un LDA y arma todos sus resultados
# -----------------------------------------------------------------------------

estimar_lda <- function(tokens, grupo_vocabulario, K, metodo) {
  voc <- vocabulario %>% filter(grupo == grupo_vocabulario)
  dtm <- tokens %>%
    filter(word %in% voc$word) %>%
    count(id, word) %>%
    cast_dtm(id, word, n)
  # la semilla va en `control` (set.seed() no basta en topicmodels)
  modelo <- if (metodo == "vem") {
    # LDA por defecto (VEM): solo K y la semilla
    LDA(dtm, k = K, control = list(seed = 2026))
  } else {
    # Gibbs con los hiperparametros del Lab 12 (no elegidos para este corpus)
    LDA(dtm, k = K, method = "Gibbs",
        control = list(alpha = 0.1, delta = 1, iter = 1000, burnin = 200, seed = 2026))
  }

  beta <- tidy(modelo, matrix = "beta")
  gamma <- tidy(modelo, matrix = "gamma") %>% rename(id = document)

  # lift = probabilidad de la palabra en el topico / frecuencia en el corpus
  frecuencia <- tibble(term = colnames(dtm), total = colSums(as.matrix(dtm))) %>%
    mutate(xbar = total / sum(total))
  beta <- beta %>% left_join(frecuencia, by = "term") %>% mutate(lift = beta / xbar)

  list(K = K, metodo = metodo, alpha = modelo@alpha, dtm = dtm, beta = beta, gamma = gamma,
       terminos = ncol(dtm), tokens_dtm = sum(as.matrix(dtm)))
}

# tabla de topicos: palabras, atencion y extension de las minutas
resumen_topicos <- function(m) {
  top_beta <- m$beta %>% group_by(topic) %>% slice_max(beta, n = 6, with_ties = FALSE) %>%
    summarise(top_beta = paste(term, collapse = ", "))
  top_lift <- m$beta %>% filter(total >= 30) %>% group_by(topic) %>% slice_max(lift, n = 8, with_ties = FALSE) %>%
    summarise(top_lift = paste(term, collapse = ", "))
  principal <- m$gamma %>% group_by(id) %>% slice_max(gamma, n = 1, with_ties = FALSE) %>% ungroup() %>%
    left_join(select(corpus, id, palabras_junta, formato), by = "id") %>%
    group_by(topic) %>%
    summarise(minutas_principal = n(), palabras_mediana = median(palabras_junta),
              theta_principal = median(gamma), .groups = "drop")
  m$gamma %>% group_by(topic) %>% summarise(atencion = mean(gamma)) %>%
    left_join(top_beta, by = "topic") %>% left_join(top_lift, by = "topic") %>%
    left_join(principal, by = "topic") %>%
    mutate(minutas_principal = coalesce(minutas_principal, 0L)) %>%
    select(topic, top_beta, top_lift, atencion, minutas_principal, palabras_mediana, theta_principal)
}

# las 3 minutas mas representativas de cada topico, con el fragmento (una
# oracion del texto original) cuyas palabras mas pesan en el topico. El peso
# de una palabra w de la minuta d en el topico k es p(k | w, d), proporcional
# a beta_kw * theta_dk; el fragmento es la oracion con 8 o mas palabras del
# vocabulario y el mayor peso promedio
documentos_representativos <- function(m) {
  top_docs <- m$gamma %>% group_by(topic) %>% slice_max(gamma, n = 3, with_ties = FALSE) %>% ungroup()
  pesos <- lemas_oracion %>%
    filter(id %in% top_docs$id) %>%
    inner_join(select(m$beta, topic, term, beta), by = c("word" = "term"), relationship = "many-to-many") %>%
    left_join(m$gamma, by = c("id", "topic")) %>%
    group_by(id, n_oracion, token, word) %>%
    mutate(p = beta * gamma / sum(beta * gamma)) %>%
    ungroup()
  mejor <- pesos %>%
    group_by(id, topic, n_oracion) %>%
    summarise(peso = mean(p), palabras = n(), .groups = "drop") %>%
    filter(palabras >= 8) %>%
    inner_join(select(top_docs, id, topic), by = c("id", "topic")) %>%
    group_by(id, topic) %>% slice_max(peso, n = 1, with_ties = FALSE) %>% ungroup()
  top_docs %>%
    left_join(mejor, by = c("id", "topic")) %>%
    left_join(oraciones, by = c("id", "n_oracion")) %>%
    left_join(select(corpus, id, fecha, palabras_junta), by = "id") %>%
    transmute(topic, fecha, theta = gamma, palabras_junta, fragmento = str_trunc(oracion, 380)) %>%
    arrange(topic, desc(theta))
}

# -----------------------------------------------------------------------------
# Estimacion: K = 6 y K = 10, discusion de la Junta y texto completo
# -----------------------------------------------------------------------------

modelos <- list()
for (K in c(6, 10)) {
  modelos[[paste0("vem_junta_k", K)]] <- estimar_lda(filter(limpios, es_junta), "minuta_junta", K, "vem")
  modelos[[paste0("gibbs_junta_k", K)]] <- estimar_lda(filter(limpios, es_junta), "minuta_junta", K, "gibbs")
  modelos[[paste0("gibbs_completo_k", K)]] <- estimar_lda(limpios, "minuta_completo", K, "gibbs")
}
message("LDA estimados: ", paste(names(modelos), collapse = ", "), ". Vocabulario (Junta): ",
        modelos$gibbs_junta_k6$terminos, " terminos; (texto completo): ", modelos$gibbs_completo_k6$terminos, ".")
message("Alfa estimado por el LDA por defecto (VEM): K = 6: ", round(modelos$vem_junta_k6$alpha, 1),
        "; K = 10: ", round(modelos$vem_junta_k10$alpha, 1), ".")

nota_modelo <- function(m, version) {
  c(if (m$metodo == "vem") {
      paste0("Exploratorio, sin selección de hiperparámetros: LDA por defecto (VEM), solo se fijan K y la semilla. Alfa estimado: ",
             format(round(m$alpha, 1), decimal.mark = ","), "; todas las minutas quedan con un peso casi igual en todos los tópicos.")
    } else {
      "Exploratorio, sin selección de hiperparámetros: LDA con muestreo de Gibbs y los valores del laboratorio (alfa = 0,1; delta = 1; 1.000 iteraciones), no elegidos para este corpus."
    },
    paste0("Versión: ", version, ". Vocabulario: ", format(m$terminos, big.mark = ".", decimal.mark = ","), " términos (palabras en 5 o más minutas y en no más del 75 %); ",
           format(m$tokens_dtm, big.mark = ".", decimal.mark = ","), " tokens. Semilla 2026."),
    "Los tópicos se identifican por número: no se les asigna nombre en esta sesión.")
}

for (nombre in names(modelos)) {
  m <- modelos[[nombre]]
  es_junta <- str_detect(nombre, "_junta_")
  version <- if (es_junta) "solo la discusión de la Junta" else "texto completo de la minuta (incluye la visión del equipo técnico hasta abril de 2019)"
  sufijo <- if (es_junta) "" else "_completo"
  base <- paste0("minutas_", m$metodo, "_k", m$K)
  nombre_metodo <- if (m$metodo == "vem") "LDA por defecto" else "LDA con Gibbs"

  # --- tabla de topicos ---------------------------------------------------------
  datos_top <- resumen_topicos(m)
  tabla_top <- datos_top %>%
    gt() %>%
    cols_label(topic = "Tópico", top_beta = "Palabras más probables (beta)", top_lift = "Palabras más propias (lift)",
               atencion = "Atención promedio (θ)", minutas_principal = "Minutas en que es el tópico principal",
               palabras_mediana = "Palabras de esas minutas (mediana)", theta_principal = "θ del tópico en esas minutas (mediana)") %>%
    fmt_es(c("atencion", "theta_principal"), decimales$proporcion) %>%
    fmt_es("palabras_mediana", 0) %>%
    sub_missing(missing_text = "—") %>%
    cols_width(top_beta ~ px(260), top_lift ~ px(330)) %>%
    tab_style(cell_text(size = px(11.5)), cells_body(columns = c(top_beta, top_lift))) %>%
    estilo_tabla(
      titulo = paste0("Tópicos de las minutas con K = ", m$K, ", ", nombre_metodo, " (exploratorio)"),
      subtitulo = paste0("Palabras de cada tópico, atención promedio y extensión de las minutas; ", version),
      nota = nota_tabla("minutas", n = n_min, extra = c(
        nota_modelo(m, version),
        "Lift: probabilidad de la palabra en el tópico dividida por su frecuencia en el corpus, entre palabras con 30 o más apariciones. Palabras de la discusión de la Junta por minuta: mediana de 403 a 457 entre junio de 2019 y junio de 2020; con minutas tan cortas, θ es más ruidoso."
      ))
    )
  guardar_tabla(paste0(base, "_topicos", sufijo), tabla_top, datos_top, carpeta_salida)

  # gamma por documento, para trazabilidad
  write_csv(
    m$gamma %>% left_join(select(corpus, id, fecha, periodo, formato, palabras_junta), by = "id") %>%
      arrange(fecha, topic),
    file.path("03_Resultados/Tablas", carpeta_salida, paste0(base, "_theta", sufijo, ".csv"))
  )
  # con el LDA por defecto theta es plano: no se reportan documentos
  # representativos ni atencion por periodo (no distinguen nada)
  if (m$metodo == "vem") next

  # --- atencion por periodo -----------------------------------------------------
  atencion <- m$gamma %>%
    left_join(select(corpus, id, fecha, periodo), by = "id") %>%
    mutate(topico = factor(paste("Tópico", topic), levels = paste("Tópico", seq_len(m$K))))
  por_periodo <- atencion %>%
    group_by(topico, periodo) %>% summarise(theta = mean(gamma), .groups = "drop") %>%
    left_join(select(periodos, periodo, inicio, fin), by = "periodo")
  datos_per <- por_periodo %>% select(topico, periodo, theta) %>%
    pivot_wider(names_from = periodo, values_from = theta)
  tabla_per <- datos_per %>%
    gt() %>%
    cols_label(topico = "") %>%
    tab_spanner("Atención promedio (θ) por periodo de política monetaria", columns = -topico) %>%
    fmt_es(names(datos_per)[-1], 2) %>%
    data_color(columns = -topico, palette = c("white", paleta_categorica[2]), domain = c(0, 1)) %>%
    estilo_tabla(
      titulo = paste0("Atención a cada tópico por periodo, K = ", m$K, ", ", nombre_metodo, " (exploratorio)"),
      subtitulo = paste0("Promedio del peso del tópico en las minutas de cada periodo; ", version),
      nota = nota_tabla("minutas", n = n_min, extra = c(
        nota_modelo(m, version),
        paste0("Periodos: ", paste0(periodos$periodo, " ", periodos$nombre, " (desde ", format(periodos$inicio, "%Y-%m"), ")", collapse = "; "), "."),
        "Los formatos de minuta cambian en 2014-05, 2019-06, 2020-07 y 2023-03: un tópico concentrado en P6 a P10 puede reflejar el formato y no el tema."
      ))
    )
  guardar_tabla(paste0(base, "_periodos", sufijo), tabla_per, datos_per, carpeta_salida)

  fig <- ggplot(atencion, aes(fecha, gamma)) +
    capa_cortes_formato(cortes_formato) +
    geom_point(color = colores_tipo[["Minutas"]], size = 0.7, alpha = 0.55) +
    geom_segment(data = por_periodo, aes(x = inicio, xend = fin, y = theta, yend = theta),
                 color = gris_texto, linewidth = 0.8) +
    facet_wrap(~ topico, ncol = if (m$K == 6) 3 else 5) +
    scale_x_date(date_breaks = "5 years", date_labels = "%Y") +
    scale_y_continuous(limits = c(0, 1), labels = scales::label_number(decimal.mark = ",")) +
    labs(
      title = paste0("Atención a cada tópico en las minutas, K = ", m$K, ", ", nombre_metodo, " (exploratorio)"),
      subtitle = paste0(subtitulo_minutas, if (es_junta) " Solo la discusión de la Junta." else " Texto completo."),
      x = "Fecha de la reunión", y = "Peso del tópico en la minuta (θ)",
      caption = paste0("n = ", n_min, " minutas. Puntos: una minuta. Segmentos negros: promedio del periodo de política monetaria. Líneas punteadas: cambios de formato de las minutas (",
                       paste(format(cortes_formato, "%Y-%m"), collapse = ", "), ").\n", "Exploratorio, sin selección de hiperparámetros (valores del laboratorio).")
    ) +
    tema_presentacion + tema_paneles + theme(axis.text.x = element_text(size = 9))
  guardar_figura(paste0(base, "_atencion", sufijo, ".png"), fig, carpeta_salida, width = if (m$K == 6) 10 else 13, height = 6.5)

  # --- documentos representativos (solo en la version de la Junta) --------------
  if (es_junta) {
    datos_doc <- documentos_representativos(m)
    tabla_doc <- datos_doc %>%
      mutate(topic = paste("Tópico", topic), fecha = format(fecha, "%Y-%m-%d")) %>%
      gt(groupname_col = "topic") %>%
      cols_label(fecha = "Reunión", theta = "θ", palabras_junta = "Palabras", fragmento = "Fragmento de la minuta") %>%
      fmt_es("theta", 2) %>%
      sub_missing(missing_text = "—") %>%
      cols_width(fragmento ~ px(720), fecha ~ px(95)) %>%
      tab_style(cell_text(size = px(11.5)), cells_body(columns = fragmento)) %>%
      tab_style(cell_text(weight = "bold"), cells_row_groups()) %>%
      estilo_tabla(
        titulo = paste0("Minutas más representativas de cada tópico, K = ", m$K, ", ", nombre_metodo, " (exploratorio)"),
        subtitulo = "Las 3 minutas con mayor peso de cada tópico y la oración cuyas palabras más pesan en él",
        nota = nota_tabla("minutas", n = n_min, extra = c(
          nota_modelo(m, version),
          "Fragmento: oración del texto original (8 o más palabras del vocabulario) con el mayor peso promedio de sus palabras en el tópico. Palabras: extensión de la discusión de la Junta en esa minuta."
        ))
      )
    guardar_tabla(paste0(base, "_documentos"), tabla_doc, datos_doc, carpeta_salida)
  }
}

# -----------------------------------------------------------------------------
# Ruido de theta segun la extension de la minuta
# -----------------------------------------------------------------------------

# por formato de minuta: extension y concentracion de theta (peso del topico
# principal) en los dos modelos de la discusion de la Junta
datos_ruido <- map_dfr(names(modelos)[str_detect(names(modelos), "_junta_")], function(nombre) {
  modelos[[nombre]]$gamma %>%
    group_by(id) %>% summarise(theta_max = max(gamma), .groups = "drop") %>%
    left_join(select(corpus, id, formato, palabras_junta), by = "id") %>%
    group_by(formato) %>%
    summarise(minutas = n(), palabras = median(palabras_junta), theta_max = median(theta_max), .groups = "drop") %>%
    mutate(modelo = str_remove(nombre, "_junta"))
}) %>%
  pivot_wider(names_from = modelo, values_from = theta_max) %>%
  left_join(formatos_minutas %>% transmute(formato, descripcion, inicio = format(inicio, "%Y-%m-%d")), by = "formato") %>%
  select(formato, descripcion, inicio, minutas, palabras, vem_k6, vem_k10, gibbs_k6, gibbs_k10)
tabla_ruido <- datos_ruido %>%
  gt() %>%
  cols_label(formato = "", descripcion = "Formato de la minuta", inicio = "Desde", minutas = "Minutas",
             palabras = "Palabras de la discusión de la Junta (mediana)",
             vem_k6 = "K = 6", vem_k10 = "K = 10", gibbs_k6 = "K = 6", gibbs_k10 = "K = 10") %>%
  tab_spanner("LDA por defecto (VEM)", columns = c(vem_k6, vem_k10)) %>%
  tab_spanner("LDA con Gibbs (valores del laboratorio)", columns = c(gibbs_k6, gibbs_k10)) %>%
  fmt_es("palabras", 0) %>% fmt_es(c("vem_k6", "vem_k10", "gibbs_k6", "gibbs_k10"), 2) %>%
  estilo_tabla(
    titulo = "Extensión de las minutas y peso del tópico principal, por formato",
    subtitulo = "Mediana del mayor peso (θ) de cada minuta; con el LDA por defecto todas quedan cerca de 1/K",
    nota = nota_tabla("minutas", n = n_min, extra = c(
      "Exploratorio, sin selección de hiperparámetros. Solo la discusión de la Junta.",
      paste0("El LDA por defecto estima un alfa de ", format(round(modelos$vem_junta_k6$alpha, 1), decimal.mark = ","), " (K = 6) y ",
             format(round(modelos$vem_junta_k10$alpha, 1), decimal.mark = ","), " (K = 10): reparte cada minuta por igual entre los tópicos (1/6 = 0,17; 1/10 = 0,10) y no distingue temas."),
      "Con minutas cortas (formato C, unas 400 palabras) el peso de cada tópico se estima con pocas palabras y es más ruidoso."
    ))
  )
guardar_tabla("minutas_lda_extension_por_formato", tabla_ruido, datos_ruido, carpeta_salida)

message("05_lda_exploratorio: listo.")
