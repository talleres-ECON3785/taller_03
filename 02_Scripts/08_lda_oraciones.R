# =============================================================================
# 08. LDA con bloques de oraciones: temas de la Junta antes y despues del
#     choque petrolero (H3a de PLAN.md)
# Taller 3 - ECON-3785
#
# Entradas: 01_Datos/03_Listos/tokens_anotados.rds, 01_Datos/02_Procesados/corpus_texto.rds,
#           03_Resultados/Tablas/09_antes_despues/ (reuniones por epoca y atencion por tema)
# Salidas:  03_Resultados/Tablas/08_lda_oraciones/ y 03_Resultados/Figuras/08_lda_oraciones/
#
# Documento = bloque de oraciones consecutivas de udpipe de una misma unidad
# (comunicado entero o seccion de discusion/decision de la Junta en las
# minutas). Con la minuta entera como documento, los topicos de 05 separaban
# formatos y epocas, no temas.
#
# Que hace:
#   1. ANALISIS PREVIO AL MODELO: fija el umbral de palabras por bloque. No
#      mira ningun topico. Regla (Decisiones tomadas, CLAUDE.md): el umbral
#      mas pequeno de {60, 80, 100} cuya mediana de palabras utiles por bloque
#      (limpias, sin verbos, tras el recorte de vocabulario) es de 20 o mas.
#   2. bloques con el umbral elegido, vocabulario de la ventana principal y
#      matrices documento-termino: la de la ventana estima el modelo; la de
#      fuera da theta con posterior() (muestra completa y cortes alternativos).
#   3. seleccion de K y alpha: perplejidad por document completion (3
#      pliegues) y coherencia UMass, con la regla de "Decisiones tomadas".
#   4. modelo final (semilla 2026) y estabilidad: los topicos que se repiten
#      con las semillas 2027 y 2028.
#   5. topicos: lift, beta, bloques representativos, alerta de formato y
#      nombres de los topicos estables.
#   6. peso de cada topico por reunion antes y despues del corte, en los
#      cuatro escenarios, con la regla de lectura de 09.
#   7. contraste con el diccionario de temas de 09 (correlacion por reunion)
#      y serie del peso de los topicos 2007-2019.
# =============================================================================

# los paquetes los carga 00_main.R con pacman

source("02_Scripts/00_formato_tablas.R")
source("02_Scripts/00_funciones_texto.R")

carpeta_salida <- "08_lda_oraciones"

anotados <- readRDS("01_Datos/03_Listos/tokens_anotados.rds") %>%
  filter(tipo == "comunicado" | es_junta) %>%
  mutate(fuente = if_else(tipo == "comunicado", "com", "junta"))
corpus <- readRDS("01_Datos/02_Procesados/corpus_texto.rds")

fuentes <- c(com = "Comunicados", junta = "Minutas: discusión de la Junta")
tipo_doc <- c(com = "Comunicado", junta = "Minuta")
epocas <- c(antes = "Antes", despues = "Después")
color_fuente <- c(com = unname(colores_tipo["Comunicados"]), junta = unname(colores_tipo["Minutas"]))
fuente_figuras <- "Fuente: comunicados y minutas de la Junta Directiva del Banco de la República; cálculos propios."
ruta_tabla <- function(nombre) file.path("03_Resultados/Tablas", carpeta_salida, nombre)

# -----------------------------------------------------------------------------
# 1. Analisis previo al modelo: umbral de palabras por bloque
# -----------------------------------------------------------------------------

umbrales <- c(60, 80, 100)
min_utiles <- 20

# palabras por oracion (todas las del texto, como en 09). El modelo se estima
# con la ventana principal (5 anos a cada lado del corte), como las medidas de 09
oraciones <- anotados %>%
  count(fuente, tipo, id, fecha, formato, unidad, sentence_id, name = "palabras") %>%
  mutate(en_ventana = !is.na(asignar_epoca(fecha, corte_crisis, ventana = TRUE))) %>%
  arrange(unidad, sentence_id)

# junta oraciones consecutivas hasta llegar a `umbral` palabras; el sobrante
# final de la unidad (menos de `umbral`) se une al bloque anterior
numerar_bloques <- function(n, umbral) {
  acumulado <- accumulate(n, ~ if (.x >= umbral) .y else .x + .y)
  bloque <- cumsum(lag(acumulado >= umbral, default = TRUE))
  ultimo <- bloque == max(bloque)
  if (max(bloque) > 1 && sum(n[ultimo]) < umbral) bloque[ultimo] <- max(bloque) - 1L
  bloque
}

# palabras utiles: limpias y sin verbos (los verbos de atribucion separaban
# epocas en 05)
utiles <- anotados %>% filter(limpio, upos != "VERB") %>% select(unidad, sentence_id, word)

# para un umbral: bloques, recorte de vocabulario (5 bloques y 75 %, con los
# bloques de la ventana) y palabras de cada bloque que quedan en el vocabulario
armar_bloques <- function(umbral) {
  oraciones_bloque <- oraciones %>%
    group_by(unidad) %>%
    mutate(bloque = paste(unidad, numerar_bloques(palabras, umbral), sep = "__")) %>%
    ungroup()
  bloques <- oraciones_bloque %>%
    group_by(fuente, tipo, id, fecha, formato, unidad, en_ventana, bloque) %>%
    summarise(palabras = sum(palabras), .groups = "drop")
  palabras_bloque <- utiles %>% inner_join(select(oraciones_bloque, unidad, sentence_id, bloque), by = c("unidad", "sentence_id"))
  en_ventana <- bloques$bloque[bloques$en_ventana]
  vocabulario <- palabras_bloque %>%
    filter(bloque %in% en_ventana) %>%
    distinct(bloque, word) %>%
    count(word) %>%
    filter(n >= 5, n <= 0.75 * length(en_ventana)) %>%
    pull(word)
  tokens <- palabras_bloque %>% filter(word %in% vocabulario) %>% select(bloque, word)
  bloques <- bloques %>%
    left_join(count(tokens, bloque, name = "utiles"), by = "bloque") %>%
    mutate(utiles = coalesce(utiles, 0L), umbral = umbral)
  list(bloques = bloques, tokens = tokens, oraciones = select(oraciones_bloque, unidad, sentence_id, bloque))
}
armados <- map(set_names(umbrales), armar_bloques)
bloques_umbral <- map_dfr(armados, "bloques")

# resumen por umbral en la ventana principal: palabras utiles por bloque y
# bloques por reunion, por fuente y epoca
resumen_utiles <- bloques_umbral %>%
  filter(en_ventana) %>%
  group_by(umbral) %>%
  summarise(bloques = n(), mediana_utiles = median(utiles), p25_utiles = quantile(utiles, 0.25),
            sin_utiles = sum(utiles == 0), .groups = "drop")
resumen_reunion <- bloques_umbral %>%
  mutate(epoca = asignar_epoca(fecha, corte_crisis, ventana = TRUE)) %>%
  filter(!is.na(epoca)) %>%
  count(umbral, fuente, epoca, id, name = "bloques_reunion") %>%
  group_by(umbral, fuente, epoca) %>%
  summarise(mediana = median(bloques_reunion), .groups = "drop") %>%
  pivot_wider(names_from = c(fuente, epoca), values_from = mediana, names_glue = "{fuente}_{epoca}")

umbral_bloque <- c(resumen_utiles$umbral[resumen_utiles$mediana_utiles >= min_utiles], max(umbrales))[1]
message("Umbral de palabras por bloque: ", umbral_bloque)

datos_umbral <- resumen_utiles %>%
  left_join(resumen_reunion, by = "umbral") %>%
  mutate(elegido = if_else(umbral == umbral_bloque, "Sí", ""))
tabla_umbral <- datos_umbral %>%
  gt() %>%
  cols_label(umbral = "Umbral (palabras)", bloques = "Bloques", mediana_utiles = "Mediana",
             p25_utiles = "Percentil 25", sin_utiles = "Bloques sin palabras útiles",
             com_antes = "Antes", com_despues = "Después", junta_antes = "Antes", junta_despues = "Después",
             elegido = "Elegido") %>%
  tab_spanner("Palabras útiles por bloque", columns = c(mediana_utiles, p25_utiles, sin_utiles)) %>%
  tab_spanner("Comunicados: bloques por reunión", columns = starts_with("com_")) %>%
  tab_spanner("Minutas: bloques por reunión", columns = starts_with("junta_")) %>%
  fmt_number(columns = -c(umbral, elegido), decimals = 0, dec_mark = ",", sep_mark = ".") %>%
  fmt_number(columns = c(com_antes, com_despues, junta_antes, junta_despues), decimals = 1, dec_mark = ",") %>%
  tab_style(list(cell_fill(color = "#EADBC4"), cell_text(weight = "bold")), cells_body(rows = elegido == "Sí")) %>%
  cols_hide(elegido) %>%
  estilo_tabla(
    titulo = "Tamaño de los bloques de texto para el modelo de tópicos",
    subtitulo = "Análisis previo al modelo: palabras útiles por bloque y bloques por reunión, según el umbral",
    nota = nota_tabla("conjunto", periodo = "2009-10-30 a 2019-10-29", extra = c(
      "Bloque: oraciones consecutivas de un comunicado o de la discusión de la Junta en una minuta, hasta llegar al umbral de palabras; el sobrante final se une al bloque anterior.",
      "Palabras útiles: sin palabras vacías ni verbos, y en 5 bloques o más y no más del 75 % de ellos.",
      paste0("Regla: se elige el umbral más pequeño cuya mediana de palabras útiles por bloque es de ", min_utiles, " o más. Fila resaltada: umbral elegido."),
      "Bloques, vocabulario y bloques por reunión (mediana): ventana de 5 años a cada lado del corte del 2014-10-30, con la que se estima el modelo."))
  )
guardar_tabla("conjunto_lda_umbral_bloques", tabla_umbral, datos_umbral, carpeta_salida)

# -----------------------------------------------------------------------------
# 2. Bloques, vocabulario y matriz del modelo (umbral elegido)
# -----------------------------------------------------------------------------

final <- armados[[as.character(umbral_bloque)]]
bloques <- final$bloques
dtm <- final$tokens %>% count(bloque, word) %>% cast_dtm(bloque, word, n)
# el modelo se estima con la ventana; fuera de ella theta sale de posterior()
en_ventana <- rownames(dtm) %in% bloques$bloque[bloques$en_ventana]
dtm_ventana <- dtm[en_ventana, ]
dtm_fuera <- dtm[!en_ventana, ]
message("Matriz del modelo (ventana): ", nrow(dtm_ventana), " bloques x ", ncol(dtm), " términos; ",
        "fuera de la ventana: ", nrow(dtm_fuera), " bloques (", sum(!bloques$en_ventana) - nrow(dtm_fuera),
        " sin palabras del vocabulario)")

# -----------------------------------------------------------------------------
# 3. Seleccion de K y alpha (catalogo, sec. 7; regla en "Decisiones tomadas")
# -----------------------------------------------------------------------------

# funciones del Lab 12 (04_hiperparametros.R), tal cual
# divide las palabras de cada documento de prueba en dos mitades al azar
partir_mitades <- function(dtm_test) {
  palabras <- tidy(dtm_test) %>%
    uncount(count) %>%
    group_by(document) %>%
    mutate(mitad = sample(rep(c("A", "B"), length.out = n()))) %>%
    ungroup()
  list(A = palabras %>% filter(mitad == "A") %>% count(document, term) %>% cast_dtm(document, term, n),
       B = palabras %>% filter(mitad == "B") %>% count(document, term))
}

# perplejidad de la mitad B, con theta estimado en la mitad A
perplejidad <- function(modelo, A, B) {
  theta <- posterior(modelo, newdata = A)$topics
  phi   <- exp(modelo@beta)
  colnames(phi) <- modelo@terms
  B <- B %>% filter(document %in% rownames(theta))
  p <- rowSums(theta[B$document, , drop = FALSE] * t(phi[, B$term, drop = FALSE]))
  c(log_p = sum(B$n * log(p)), N = sum(B$n))
}

# coherencia UMass de las 10 palabras principales de cada topico
presencia <- as.matrix(dtm_ventana) > 0
coherencia <- function(modelo, n_top = 10) {
  apply(modelo@beta, 1, function(fila) {
    top <- modelo@terms[order(fila, decreasing = TRUE)[1:n_top]]
    s <- 0
    for (j in 2:n_top) for (i in 1:(j - 1)) {
      s <- s + log((sum(presencia[, top[i]] & presencia[, top[j]]) + 1) /
                     sum(presencia[, top[i]]))
    }
    s
  })
}

delta <- 0.1
# especificacion final (Gibbs, 1.000 iteraciones y 200 de calentamiento)
estimar_lda <- function(k, a, semilla) {
  LDA(dtm_ventana, k = k, method = "Gibbs",
      control = list(alpha = a, delta = delta, iter = 1000, burnin = 200, seed = semilla))
}

# perplejidad por document completion con 3 pliegues (300 iteraciones, como el lab)
set.seed(2026)
pliegue <- sample(rep(1:3, length.out = nrow(dtm_ventana)))
mitades <- map(1:3, \(f) partir_mitades(dtm_ventana[pliegue == f, ]))
rejilla <- expand_grid(K = c(6, 8, 10, 12, 15), alpha = c(0.05, 0.1, 0.5, 1), f = 1:3) %>%
  mutate(r = pmap(list(K, alpha, f), \(k, a, f) {
    m <- LDA(dtm_ventana[pliegue != f, ], k = k, method = "Gibbs",
             control = list(alpha = a, delta = delta, iter = 300, seed = 2026))
    perplejidad(m, mitades[[f]]$A, mitades[[f]]$B)
  })) %>%
  unnest_wider(r) %>%
  group_by(K, alpha) %>%
  summarise(perplejidad = exp(-sum(log_p) / sum(N)), .groups = "drop")
write_csv(rejilla, file.path("03_Resultados/Tablas", carpeta_salida, "conjunto_lda_rejilla.csv"))

# para cada K, el alpha con menor perplejidad; coherencia con el modelo final
# de ese par (el del K elegido es el modelo final: no se estima dos veces)
mejor_por_K <- rejilla %>%
  group_by(K) %>%
  slice_min(perplejidad, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  mutate(costo_pct = 100 * (perplejidad / min(perplejidad) - 1))
modelos <- map2(mejor_por_K$K, mejor_por_K$alpha, \(k, a) estimar_lda(k, a, 2026)) %>% set_names(mejor_por_K$K)
mejor_por_K$coherencia <- map_dbl(modelos, \(m) mean(coherencia(m)))

# regla: el K mas pequeno a menos del 5 % de la perplejidad minima, salvo que
# su coherencia sea la peor (pasa al siguiente que cumpla)
elegibles <- mejor_por_K %>% filter(costo_pct < 5, coherencia > min(coherencia))
K_elegido <- if (nrow(elegibles) > 0) min(elegibles$K) else {
  message("Ningún K cumple la regla: se usa el de perplejidad mínima")
  mejor_por_K$K[which.min(mejor_por_K$perplejidad)]
}
alpha_elegido <- mejor_por_K$alpha[mejor_por_K$K == K_elegido]
message("K elegido: ", K_elegido, "; alpha: ", alpha_elegido)

datos_seleccion <- mejor_por_K %>% mutate(elegido = if_else(K == K_elegido, "Sí", ""))
tabla_seleccion <- datos_seleccion %>%
  gt() %>%
  cols_label(K = "Tópicos (K)", alpha = "α con menor perplejidad", perplejidad = "Perplejidad",
             costo_pct = "Costo frente al mínimo (%)", coherencia = "Coherencia media", elegido = "Elegido") %>%
  fmt_number(columns = alpha, decimals = 2, dec_mark = ",") %>%
  fmt_number(columns = c(perplejidad, costo_pct, coherencia), decimals = 1, dec_mark = ",", sep_mark = ".") %>%
  tab_style(list(cell_fill(color = "#EADBC4"), cell_text(weight = "bold")), cells_body(rows = elegido == "Sí")) %>%
  cols_hide(elegido) %>%
  estilo_tabla(
    titulo = "Selección del número de tópicos",
    subtitulo = "Perplejidad por validación cruzada y coherencia de los tópicos, para cada número de tópicos",
    nota = nota_tabla("conjunto", periodo = "2009-10-30 a 2019-10-29", extra = c(
      paste0("Modelo de tópicos (LDA, muestreo de Gibbs, δ = 0,1) estimado con ", format(nrow(dtm_ventana), big.mark = ".", decimal.mark = ","),
             " bloques de comunicados y de la discusión de la Junta en las minutas."),
      "Perplejidad: document completion con 3 pliegues y 300 iteraciones (menor es mejor); α ∈ {0,05; 0,1; 0,5; 1}, se muestra el de menor perplejidad para cada K.",
      "Coherencia: UMass media de las 10 palabras principales de cada tópico (más cercana a cero es más coherente), con el modelo final de 1.000 iteraciones.",
      "Regla, fijada antes de ver los tópicos: el K más pequeño a menos del 5 % de la perplejidad mínima, salvo que su coherencia sea la peor. Fila resaltada: especificación elegida."))
  )
guardar_tabla("conjunto_lda_seleccion", tabla_seleccion, datos_seleccion, carpeta_salida)

# -----------------------------------------------------------------------------
# 4. Modelo final y estabilidad entre semillas
# -----------------------------------------------------------------------------

modelo <- modelos[[as.character(K_elegido)]]
# un topico se repite si su beta tiene correlacion >= 0,8 con algun topico de
# cada una de las otras dos semillas
cor_max <- map(c(2027, 2028), \(s) {
  otro <- estimar_lda(K_elegido, alpha_elegido, s)
  apply(cor(t(exp(modelo@beta)), t(exp(otro@beta))), 1, max)
})
estabilidad <- tibble(topico = seq_len(K_elegido), cor_2027 = cor_max[[1]], cor_2028 = cor_max[[2]]) %>%
  mutate(se_repite = cor_2027 >= 0.8 & cor_2028 >= 0.8)
message("Tópicos que se repiten en las tres semillas: ", sum(estabilidad$se_repite), " de ", K_elegido)

# -----------------------------------------------------------------------------
# 5. Topicos: palabras, bloques representativos, formato y nombres
# -----------------------------------------------------------------------------

# nombres asignados con las palabras y los fragmentos de las tablas de esta
# seccion, uno por topico estable (en el orden de `estables`). Vacio: "Topico k".
# Aprobados por Santiago Munoz Martinez el 2026-11-21 (los topicos 5 y 9 no se repiten)
nombres_topicos <- c(
  "Actividad económica interna",       # 1: crecimiento, consumo, inversion, industria (comunicado 2013-04-26)
  "Crédito y sistema financiero",      # 2: credito, cartera, vivienda, tasa de interes (comunicado 2012-04-30)
  "Decisión y postura de política monetaria", # 3: postura, ajuste, tasa de intervencion, meta (comunicado 2016-04-29)
  "Inflación por depreciación y alimentos", # 4: devaluacion, El Nino, alimentos, indexacion (comunicado 2015-08-21)
  "Déficit externo y capacidad productiva", # 6: cuenta corriente, deficit, capacidad (comunicado 2017-08-31)
  "Seguimiento y provisión de liquidez",    # 7: monitoreo; "cuenta con las herramientas ... de liquidez" (2012)
  "Inflación básica y expectativas frente a la meta", # 8: meta, inflacion basica, expectativas (comunicado 2010-06-18)
  "Economía mundial"                   # 10: zona euro, Asia, Estados Unidos, emergentes (minuta 2014-01-31)
)
estables <- estabilidad$topico[estabilidad$se_repite]
etiqueta_topico <- function(k) {
  case_when(!k %in% estables ~ paste0("Tópico ", k, " (inestable)"),
            length(nombres_topicos) == 0 ~ paste0("Tópico ", k),
            TRUE ~ paste0(k, ". ", nombres_topicos[match(k, estables)]))
}

# lift = probabilidad de la palabra en el topico / frecuencia en el corpus (catalogo, sec. 6)
frecuencia <- tibble(term = colnames(dtm_ventana), total = colSums(as.matrix(dtm_ventana))) %>%
  mutate(xbar = total / sum(total))
palabras_topico <- tidy(modelo, matrix = "beta") %>%
  left_join(frecuencia, by = "term") %>%
  mutate(lift = beta / xbar) %>%
  group_by(topico = topic) %>%
  summarise(top_lift = paste(head(term[total >= 30][order(-lift[total >= 30])], 8), collapse = ", "),
            top_beta = paste(head(term[order(-beta)], 6), collapse = ", "))

# theta por bloque: estimado en la ventana; fuera de ella, con posterior()
theta_bloque <- bind_rows(
  as_tibble(posterior(modelo)$topics, rownames = "bloque"),
  as_tibble(posterior(modelo, newdata = dtm_fuera, control = list(seed = 2026))$topics, rownames = "bloque")
) %>%
  pivot_longer(-bloque, names_to = "topico", values_to = "theta", names_transform = as.integer) %>%
  left_join(select(bloques, bloque, fuente, tipo, id, fecha, formato, en_ventana), by = "bloque")

# alerta: mas del 70 % del peso del topico en las minutas cae en un solo formato.
# En la ventana el formato B casi coincide con "despues": no separa formato de epoca
peso_formato <- theta_bloque %>%
  filter(en_ventana, tipo == "minuta") %>%
  group_by(topico, formato) %>%
  summarise(theta = sum(theta), .groups = "drop_last") %>%
  mutate(peso = theta / sum(theta)) %>%
  slice_max(peso, n = 1, with_ties = FALSE) %>%
  ungroup()

# los 3 bloques de la ventana con mayor theta de cada topico estable, con sus
# oraciones recuperadas del PDF
texto_oracion <- anotados %>%
  mutate(token_id = as.integer(token_id)) %>%
  arrange(unidad, sentence_id, token_id) %>%
  group_by(unidad, sentence_id) %>%
  summarise(texto_tok = paste(token, collapse = " "), .groups = "drop")
fragmentos <- theta_bloque %>%
  filter(en_ventana, topico %in% estables) %>%
  group_by(topico) %>%
  slice_max(theta, n = 3, with_ties = FALSE) %>%
  ungroup() %>%
  left_join(final$oraciones, by = "bloque", relationship = "one-to-many") %>%
  left_join(texto_oracion, by = c("unidad", "sentence_id")) %>%
  left_join(select(corpus, id, texto), by = "id") %>%
  rowwise() %>%
  mutate(original = texto_original(texto, texto_tok)) %>%
  group_by(topico, bloque, fuente, fecha, theta) %>%
  summarise(fragmento = paste(original, collapse = " "), .groups = "drop") %>%
  mutate(fragmento = if_else(nchar(fragmento) > 330, paste0(str_sub(fragmento, 1, 327), "…"), fragmento))

datos_topicos <- palabras_topico %>%
  left_join(peso_formato, by = "topico") %>%
  left_join(estabilidad, by = "topico") %>%
  transmute(topico = etiqueta_topico(topico), top_lift, top_beta,
            formato = paste0(formato, " (", sprintf("%.0f", 100 * peso), " %)"),
            alerta = if_else(peso > 0.7, "Posible artefacto de formato o de época", ""),
            se_repite = if_else(se_repite, "Sí", "No"))
tabla_topicos <- datos_topicos %>%
  gt() %>%
  cols_label(topico = "Tópico", top_lift = "Palabras de mayor lift", top_beta = "Palabras más probables",
             formato = "Formato de minuta con más peso", alerta = "Alerta de formato", se_repite = "Se repite con otras semillas") %>%
  cols_width(topico ~ px(190), top_lift ~ px(300), top_beta ~ px(240), formato ~ px(120),
             alerta ~ px(190), se_repite ~ px(110)) %>%
  estilo_tabla(
    titulo = "Tópicos de la comunicación de la Junta",
    subtitulo = paste0("Modelo de tópicos con ", K_elegido, " tópicos, estimado con bloques de comunicados y de la discusión de la Junta"),
    nota = nota_tabla("conjunto", periodo = "2009-10-30 a 2019-10-29", extra = c(
      "Lift: probabilidad de la palabra en el tópico sobre su frecuencia en el corpus (palabras con 30 apariciones o más); más probables: mayor probabilidad en el tópico.",
      "Formato con más peso: proporción del peso del tópico en las minutas que cae en ese formato. En la ventana, el formato B (desde 2014-05-30) casi coincide con el periodo posterior al corte, así que la alerta (más del 70 %) no separa formato de época.",
      "Se repite: correlación de 0,8 o más entre las probabilidades de palabras del tópico y algún tópico de los modelos con semillas 2027 y 2028. Solo se nombran los tópicos que se repiten."))
  )
guardar_tabla("conjunto_lda_topicos", tabla_topicos, datos_topicos, carpeta_salida)

datos_fragmentos <- fragmentos %>%
  arrange(topico, desc(theta)) %>%
  transmute(topico = etiqueta_topico(topico), documento = paste(tipo_doc[fuente], fecha), theta = 100 * theta, fragmento)
tabla_fragmentos <- datos_fragmentos %>%
  gt(groupname_col = "topico") %>%
  cols_label(documento = "Documento", theta = "Peso del tópico (%)", fragmento = "Fragmento") %>%
  fmt_number(columns = theta, decimals = 0, dec_mark = ",") %>%
  cols_width(documento ~ px(160), theta ~ px(110), fragmento ~ px(720)) %>%
  tab_style(cell_text(weight = "bold"), cells_row_groups()) %>%
  estilo_tabla(
    titulo = "Fragmentos más representativos de cada tópico",
    subtitulo = "Los tres bloques de texto con mayor peso de cada tópico que se repite con otras semillas",
    nota = nota_tabla("conjunto", periodo = "2009-10-30 a 2019-10-29", extra = c(
      "Bloque: oraciones consecutivas de un comunicado o de la discusión de la Junta en una minuta (60 palabras o más); se recorta a 330 caracteres.",
      "Peso del tópico: proporción del bloque asignada al tópico por el modelo."))
  )
guardar_tabla("conjunto_lda_fragmentos", tabla_fragmentos, datos_fragmentos, carpeta_salida)

# -----------------------------------------------------------------------------
# 6. Atencion a cada topico antes y despues del corte
# -----------------------------------------------------------------------------

# la reunion es la unidad: media de theta de sus bloques, en %
theta_reunion <- theta_bloque %>%
  group_by(fuente, id, fecha, topico) %>%
  summarise(theta = 100 * mean(theta), .groups = "drop")
write_csv(theta_reunion %>% mutate(fuente = fuentes[fuente]), ruta_tabla("conjunto_lda_theta_por_reunion.csv"))

# reuniones con su epoca en cada escenario (como docs_esc en 09)
reuniones_esc <- escenarios %>%
  rowwise() %>%
  reframe(escenario, theta_reunion %>% mutate(epoca = asignar_epoca(fecha, corte, ventana))) %>%
  filter(!is.na(epoca))

# media por epoca con su IC 95 % y diferencia despues - antes con su IC 95 %
# (t.test de Welch, la reunion es la unidad), como comparar_temas en 09
comparar_topicos <- reuniones_esc %>%
  group_by(escenario, fuente, topico) %>%
  summarise({
    a <- theta[epoca == "antes"]
    d <- theta[epoca == "despues"]
    prueba <- t.test(d, a)
    ic_a <- t.test(a)$conf.int
    ic_d <- t.test(d)$conf.int
    tibble(media_antes = mean(a), ic_antes_inf = ic_a[1], ic_antes_sup = ic_a[2],
           media_despues = mean(d), ic_despues_inf = ic_d[1], ic_despues_sup = ic_d[2],
           diferencia = mean(d) - mean(a), dif_inf = prueba$conf.int[1], dif_sup = prueba$conf.int[2],
           p_valor = prueba$p.value, reuniones_antes = length(a), reuniones_despues = length(d))
  }, .groups = "drop")
write_csv(comparar_topicos %>% mutate(escenario = escenarios$nombre[match(escenario, escenarios$escenario)],
                                      fuente = fuentes[fuente], topico = etiqueta_topico(topico)),
          ruta_tabla("conjunto_lda_antes_despues_detalle.csv"))

# lectura (regla de 09): artefacto de formato si minutas y comunicados van en
# direcciones opuestas; robusta si el signo se mantiene en los otros escenarios
lectura_topicos <- comparar_topicos %>%
  select(escenario, fuente, topico, diferencia) %>%
  pivot_wider(names_from = escenario, values_from = diferencia) %>%
  arrange(topico, fuente) %>%
  group_by(topico) %>%
  mutate(otra = rev(principal)) %>%
  ungroup() %>%
  mutate(lectura = case_when(
    sign(otra) != sign(principal) & fuente == "junta" ~ "Posible artefacto de formato",
    sign(otra) != sign(principal) ~ "No se ve en las minutas",
    sign(completa) == sign(principal) & sign(corte_p4) == sign(principal) & sign(corte_trm) == sign(principal) ~ "Robusta",
    TRUE ~ "Matizada"))

principal_topicos <- comparar_topicos %>% filter(escenario == "principal", topico %in% estables)
n_reuniones <- principal_topicos %>% distinct(fuente, reuniones_antes, reuniones_despues)
nota_n <- paste0("n = ", n_reuniones$reuniones_antes[n_reuniones$fuente == "com"], " comunicados antes y ",
                 n_reuniones$reuniones_despues[n_reuniones$fuente == "com"], " después; ",
                 n_reuniones$reuniones_antes[n_reuniones$fuente == "junta"], " minutas antes y ",
                 n_reuniones$reuniones_despues[n_reuniones$fuente == "junta"], " después.")

datos_fig_topicos <- principal_topicos %>%
  transmute(fuente, topico, media_antes, inf_antes = ic_antes_inf, sup_antes = ic_antes_sup,
            media_despues, inf_despues = ic_despues_inf, sup_despues = ic_despues_sup) %>%
  pivot_longer(-c(fuente, topico), names_to = c(".value", "epoca"), names_sep = "_") %>%
  mutate(panel = factor(fuentes[fuente], levels = fuentes), epoca = factor(epocas[epoca], levels = epocas),
         topico = factor(etiqueta_topico(topico), levels = rev(etiqueta_topico(estables))))
fig_topicos <- ggplot(datos_fig_topicos, aes(media, topico, fill = fuente, alpha = epoca)) +
  geom_col(aes(group = fct_rev(epoca)), position = position_dodge(width = 0.75), width = 0.7) +
  geom_errorbar(aes(xmin = inf, xmax = sup, group = fct_rev(epoca)), position = position_dodge(width = 0.75), width = 0.25,
                color = gris_secundario, linewidth = 0.4) +
  facet_wrap(~ panel) +
  scale_fill_manual(values = color_fuente, guide = "none") +
  scale_alpha_manual(values = c("Antes" = 0.4, "Después" = 1)) +
  scale_x_continuous(labels = scales::label_number(decimal.mark = ","), expand = expansion(mult = c(0, 0.08))) +
  guides(alpha = guide_legend(override.aes = list(fill = gris_secundario))) +
  labs(title = "Peso de cada tópico en las reuniones de la Junta antes y después del choque petrolero",
       subtitle = "Comunicados y minutas (solo la discusión de la Junta), 5 años antes y 5 años después del 2014-10-30.",
       x = "Peso del tópico en la reunión (%, media por reunión)", y = NULL,
       caption = paste(
         "Barras: media por reunión del peso del tópico (promedio de sus bloques de texto); líneas: intervalo de confianza del 95 % de la media.",
         "Solo los tópicos que se repiten con otras semillas. La diferencia y su intervalo están en la tabla de este script.",
         nota_n, fuente_figuras, sep = "\n")) +
  tema_presentacion + tema_paneles + tema_barras_h
guardar_figura("conjunto_lda_antes_despues.png", fig_topicos, carpeta_salida, width = 11, height = 6.5)

datos_tabla_topicos <- principal_topicos %>%
  left_join(select(lectura_topicos, fuente, topico, lectura), by = c("fuente", "topico")) %>%
  mutate(grupo = paste0(fuentes[fuente], " (", reuniones_antes, " reuniones antes y ", reuniones_despues, " después)"),
         ic = paste0("[", sub(".", ",", sprintf("%.1f", dif_inf), fixed = TRUE), "; ",
                     sub(".", ",", sprintf("%.1f", dif_sup), fixed = TRUE), "]"),
         topico_n = topico, topico = etiqueta_topico(topico)) %>%
  arrange(fuente, topico_n) %>%
  select(grupo, topico, media_antes, media_despues, diferencia, ic, lectura)
tabla_antes_despues <- datos_tabla_topicos %>%
  gt(groupname_col = "grupo") %>%
  cols_label(topico = "Tópico", media_antes = "Antes", media_despues = "Después", diferencia = "Diferencia",
             ic = "IC 95 %", lectura = "Lectura") %>%
  tab_spanner("Peso del tópico (%, media por reunión)", columns = c(media_antes, media_despues, diferencia, ic)) %>%
  fmt_number(columns = c(media_antes, media_despues, diferencia), decimals = 1, dec_mark = ",") %>%
  tab_style(cell_text(weight = "bold"), cells_row_groups()) %>%
  estilo_tabla(
    titulo = "Cuánto cambió el peso de cada tópico después del choque petrolero",
    subtitulo = "Media por reunión antes y después del 2014-10-30, diferencia e intervalo de confianza del 95 %",
    nota = nota_tabla("conjunto", periodo = "2009-10-30 a 2019-10-29", extra = c(
      "Diferencia: después menos antes, en puntos porcentuales del peso del tópico; IC 95 % de la prueba t de Welch con la reunión como unidad.",
      "Lectura: «Robusta» si el signo de la diferencia se mantiene con la muestra completa y con los cortes 2014-09-26 y 2014-12-19; «Matizada» si alguno lo cambia; «Posible artefacto de formato» si cambia en las minutas en dirección contraria a los comunicados.",
      "Fuera de la ventana (muestra completa y bordes de los cortes alternativos), el peso de los tópicos se calcula con el modelo estimado en la ventana."))
  )
guardar_tabla("conjunto_lda_antes_despues", tabla_antes_despues, datos_tabla_topicos, carpeta_salida)

# -----------------------------------------------------------------------------
# 7. Contraste con el diccionario de 09 y peso de los topicos en 2007-2019
# -----------------------------------------------------------------------------

# (a) correlacion por reunion entre theta y la atencion al tema equivalente del
# diccionario, leida de 09 (no se recalcula). Equivalencias fijadas por las
# palabras de cada tema y topico, antes de ver las correlaciones; la suma
# muestra lo que el diccionario mezcla y cada topico, su composicion
equivalencias <- tibble(
  tema = c("Actividad económica", rep("Inflación", 3), rep("Entorno externo", 3)),
  topicos = list(1, 4, 8, c(4, 8), 6, 10, c(6, 10))
) %>% mutate(etiqueta = map_chr(topicos, ~ paste(.x, collapse = " + ")))
atencion_09 <- read_csv("03_Resultados/Tablas/09_antes_despues/conjunto_temas_por_reunion.csv", show_col_types = FALSE) %>%
  mutate(fuente = names(fuentes)[match(fuente, fuentes)])
theta_ventana <- theta_reunion %>% filter(!is.na(asignar_epoca(fecha, corte_crisis, ventana = TRUE)))
cor_diccionario <- equivalencias %>%
  rowwise() %>%
  reframe(tema, etiqueta, theta_ventana %>% filter(topico %in% topicos) %>%
            group_by(fuente, id) %>% summarise(theta = sum(theta), .groups = "drop")) %>%
  inner_join(select(atencion_09, fuente, id, tema, por_mil), by = c("fuente", "id", "tema")) %>%
  group_by(tema, etiqueta, fuente) %>%
  summarise({
    prueba <- cor.test(theta, por_mil)
    tibble(r = unname(prueba$estimate), r_inf = prueba$conf.int[1], r_sup = prueba$conf.int[2], reuniones = n())
  }, .groups = "drop")

coma <- function(x) sub(".", ",", sprintf("%.2f", x), fixed = TRUE)
datos_tabla_dicc <- cor_diccionario %>%
  mutate(r_ic = paste0(coma(r), " [", coma(r_inf), "; ", coma(r_sup), "]"),
         topico = if_else(str_detect(etiqueta, "\\+"), paste0("Suma de ", etiqueta),
                          etiqueta_topico(suppressWarnings(as.numeric(etiqueta))))) %>%
  select(tema, etiqueta, topico, fuente, r_ic) %>%
  pivot_wider(names_from = fuente, values_from = r_ic) %>%
  arrange(match(tema, equivalencias$tema), match(etiqueta, equivalencias$etiqueta)) %>%
  select(tema, topico, com, junta)
n_dicc <- cor_diccionario %>% distinct(fuente, reuniones)
tabla_dicc <- datos_tabla_dicc %>%
  gt(groupname_col = "tema") %>%
  cols_label(topico = "Tópico del LDA", com = "Comunicados", junta = "Minutas: discusión de la Junta") %>%
  tab_spanner("Correlación por reunión [IC 95 %]", columns = c(com, junta)) %>%
  tab_style(cell_text(weight = "bold"), cells_row_groups()) %>%
  estilo_tabla(
    titulo = "El peso de los tópicos frente a la atención del diccionario de temas",
    subtitulo = "Correlación de Pearson por reunión entre el peso del tópico (%) y las palabras del tema por cada 1.000",
    nota = nota_tabla("conjunto", periodo = "2009-10-30 a 2019-10-29", extra = c(
      paste0("n = ", n_dicc$reuniones[n_dicc$fuente == "com"], " comunicados y ",
             n_dicc$reuniones[n_dicc$fuente == "junta"], " minutas; la reunión es la unidad."),
      "Equivalencias fijadas por las palabras de cada tema y tópico antes de calcular las correlaciones; «Suma» usa el peso conjunto de los dos tópicos.",
      "La correlación es entre niveles, así que incluye el cambio entre épocas antes y después del 2014-10-30.",
      "Atención por tema: diccionario de 09_antes_despues.R (Mercado laboral, Fiscal y Riesgo no tienen tópico equivalente)."))
  )
guardar_tabla("conjunto_lda_vs_diccionario", tabla_dicc, cor_diccionario %>% mutate(fuente = fuentes[fuente]), carpeta_salida)

# (b) peso de cada topico estable por reunion hasta 2019: desde 2020 entra la
# pandemia, otro choque que habria que explicar aparte (fuera de la ventana,
# theta de posterior()). Estilo de la serie por reunion de 09
media_movil <- function(x) as.numeric(stats::filter(x, rep(1 / 5, 5), sides = 1)) # 5 reuniones, solo el pasado
fin_serie <- as.Date("2019-12-31")
serie_topicos <- theta_reunion %>%
  filter(topico %in% estables, fecha <= fin_serie) %>%
  arrange(fecha) %>%
  group_by(fuente, topico) %>% mutate(movil = media_movil(theta)) %>% ungroup() %>%
  mutate(serie = c(com = "Comunicados", junta = "Minutas")[fuente],
         panel = factor(etiqueta_topico(topico), levels = etiqueta_topico(estables)))
n_serie <- serie_topicos %>% distinct(fuente, id) %>% count(fuente)
# dos figuras de 4 topicos, en orden de numeracion, para que se lean en una diapositiva
grupos_serie <- list(topicos_1_4 = c(1, 2, 3, 4), topicos_6_10 = c(6, 7, 8, 10))
for (g in names(grupos_serie)) {
  niveles <- etiqueta_topico(grupos_serie[[g]])
  datos_g <- serie_topicos %>% filter(topico %in% grupos_serie[[g]]) %>% mutate(panel = factor(as.character(panel), levels = niveles))
  primer_panel <- list(panel = factor(niveles[1], levels = niveles))
  fig_g <- ggplot(datos_g, aes(fecha, movil, color = serie)) +
    capa_periodos(periodos, etiquetas = TRUE, hasta = fin_serie, panel = primer_panel) +
    capa_cortes_formato(cortes_formato[cortes_formato <= fin_serie]) +
    capa_corte(corte_crisis, "Corte: 2014-10-30", panel = primer_panel) +
    geom_point(aes(y = theta), size = 0.6, alpha = 0.3) +
    geom_line(linewidth = 0.8, na.rm = TRUE) +
    facet_wrap(~ panel, ncol = 2) +
    scale_color_manual(values = colores_tipo) +
    scale_x_date(date_breaks = "2 years", date_labels = "%Y", expand = expansion(mult = 0.01)) +
    scale_y_continuous(labels = scales::label_number(decimal.mark = ",")) +
    labs(title = paste0("Peso de los tópicos ", paste(head(grupos_serie[[g]], -1), collapse = ", "), " y ", last(grupos_serie[[g]]), " en las reuniones de la Junta, 2007 a 2019"),
         subtitle = "Comunicados y minutas (solo la discusión de la Junta), enero de 2007 a diciembre de 2019.",
         x = "Fecha de la reunión", y = "Peso del tópico en la reunión (%)",
         caption = paste(
           "Puntos: cada reunión (promedio de sus bloques de texto); línea: media móvil de las últimas 5 reuniones.",
           "El modelo se estimó con la ventana 2009-10-30 a 2019-10-29; fuera de ella, el peso se calcula con ese mismo modelo.",
           "Línea negra: corte del 2014-10-30. Líneas punteadas: cambios de formato de las minutas. Sombreado: periodos de política monetaria (P1 a P5).",
           paste0("n = ", n_serie$n[n_serie$fuente == "com"], " comunicados y ", n_serie$n[n_serie$fuente == "junta"],
                  " minutas. Los otros cuatro tópicos estables están en la figura compañera de este script."),
           fuente_figuras, sep = "\n")) +
    tema_presentacion + tema_paneles + theme(panel.grid.major.x = element_blank())
  guardar_figura(paste0("conjunto_lda_theta_por_reunion_", g, ".png"), fig_g, carpeta_salida, width = 14, height = 7.5)
}

# reuniones por epoca del escenario principal, tal como las cuenta 09
epocas_09 <- read_csv("03_Resultados/Tablas/09_antes_despues/conjunto_documentos_por_epoca.csv", show_col_types = FALSE) %>%
  filter(str_starts(escenario, "Principal"))

stopifnot(
  # theta fuera de la ventana tambien suma 1 por bloque
  all(abs(count(theta_bloque, bloque, wt = theta)$n - 1) < 1e-8),
  # mismas reuniones que 09 en el escenario principal
  identical(as.integer(sort(c(n_reuniones$reuniones_antes, n_reuniones$reuniones_despues))),
            as.integer(sort(c(epocas_09$reuniones_antes, epocas_09$reuniones_despues)))),
  length(nombres_topicos) %in% c(0, length(estables)),
  # ninguna reunion de la ventana se pierde en el cruce con el diccionario de 09
  all(cor_diccionario$reuniones == count(distinct(theta_ventana, fuente, id), fuente)$n[match(cor_diccionario$fuente, c("com", "junta"))]),
  # theta del modelo final suma 1 por bloque
  all(abs(rowSums(posterior(modelo)$topics) - 1) < 1e-8),
  all(mejor_por_K$coherencia <= 0),
  # mejor que un modelo uniforme (perplejidad = tamano del vocabulario)
  all(rejilla$perplejidad < ncol(dtm_ventana)),
  K_elegido %in% mejor_por_K$K,
  # LDA no acepta filas vacias: todo bloque de la ventana tiene palabras del vocabulario
  nrow(dtm_ventana) == sum(bloques$en_ventana),
  # cada oracion queda en un solo bloque, para todos los umbrales
  all(count(bloques_umbral, umbral, wt = palabras)$n == sum(oraciones$palabras)),
  # un bloque bajo el umbral solo existe si su unidad entera es mas corta que el umbral
  bloques_umbral %>% group_by(umbral, unidad) %>% summarise(ok = all(palabras >= umbral) | n() == 1, .groups = "drop") %>% pull(ok) %>% all(),
  umbral_bloque %in% umbrales
)
