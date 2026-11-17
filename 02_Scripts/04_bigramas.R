# =============================================================================
# 04. Bigramas y expresiones de votacion y desacuerdo
# Taller 3 - ECON-3785
#
# Entradas: 01_Datos/03_Listos/tokens_anotados.rds, 01_Datos/02_Procesados/corpus_texto.rds
# Salidas:  03_Resultados/Tablas/04_bigramas/ y Figuras/04_bigramas/
#
# EXPLORATORIO.
#   1. Bigramas mas frecuentes por tipo y periodo. Como en el Lab 11, un
#      bigrama cuenta solo si sus dos palabras estan en el vocabulario limpio;
#      ademas deben ser contiguas en la misma oracion. Se senalan los que
#      conviene agregar al diccionario de compuestos.
#   2. Votacion: se busca sobre el TEXTO EXTRAIDO (antes de quitar digitos y
#      de lematizar), en comunicados y minutas, si el documento dice que la
#      decision fue por unanimidad o por mayoria y si da el conteo de votos.
#      Tambien se exporta, para validacion manual, la oracion de votacion de
#      cada documento y la direccion del voto de la minoria.
#   3. Expresiones de desacuerdo en las minutas ("algunos miembros", "la
#      mayoria", "otros directores"...), por ano y por cada 1.000 palabras.
# =============================================================================

# los paquetes los carga 00_main.R con pacman

source("02_Scripts/00_formato_tablas.R")
source("02_Scripts/00_funciones_texto.R")

carpeta_salida <- "04_bigramas"

corpus <- readRDS("01_Datos/02_Procesados/corpus_texto.rds")
anotados <- readRDS("01_Datos/03_Listos/tokens_anotados.rds")

n_com <- sum(corpus$tipo == "comunicado")
n_min <- sum(corpus$tipo == "minuta")
fmt_es <- function(tabla, columnas, decimales_n) {
  fmt_number(tabla, columns = all_of(columnas), decimals = decimales_n, dec_mark = ",", sep_mark = ".")
}

# -----------------------------------------------------------------------------
# 1. Bigramas
# -----------------------------------------------------------------------------

# pares de tokens contiguos (token_id consecutivo) dentro de la misma oracion,
# con las dos palabras en el vocabulario limpio
bigramas <- anotados %>%
  mutate(token_id = as.integer(token_id)) %>%
  arrange(unidad, sentence_id, token_id) %>%
  group_by(unidad, sentence_id) %>%
  mutate(palabra2 = lead(word), limpio2 = lead(limpio), contiguo = lead(token_id) == token_id + 1) %>%
  ungroup() %>%
  filter(limpio, limpio2, contiguo) %>%
  transmute(id, tipo, fecha, periodo, es_junta, bigrama = paste(word, palabra2))

fuentes <- c(com = "Comunicados", junta = "Minutas: discusión de la Junta", completo = "Minutas: texto completo")
bigramas_fuente <- bind_rows(
  bigramas %>% filter(tipo == "comunicado") %>% mutate(fuente = "com"),
  bigramas %>% filter(tipo == "minuta", es_junta) %>% mutate(fuente = "junta"),
  bigramas %>% filter(tipo == "minuta") %>% mutate(fuente = "completo")
)
palabras_doc <- bind_rows(
  corpus %>% filter(tipo == "comunicado") %>% transmute(fuente = "com", id, periodo, palabras),
  corpus %>% filter(tipo == "minuta") %>% transmute(fuente = "junta", id, periodo, palabras = palabras_junta),
  corpus %>% filter(tipo == "minuta") %>% transmute(fuente = "completo", id, periodo, palabras = palabras - palabras_preambulo)
)
palabras_fuente <- palabras_doc %>% group_by(fuente) %>% summarise(total = sum(palabras), total_docs = n(), .groups = "drop")
palabras_periodo <- palabras_doc %>% group_by(fuente, periodo) %>% summarise(total = sum(palabras), docs = n(), .groups = "drop")

# --- 1.1 los 20 mas frecuentes por tipo ---------------------------------------
frec_bi <- bigramas_fuente %>%
  group_by(fuente, bigrama) %>%
  summarise(n = n(), docs = n_distinct(id), .groups = "drop") %>%
  left_join(palabras_fuente, by = "fuente") %>%
  mutate(por_mil = 1000 * n / total, pct_docs = 100 * docs / total_docs)

datos_top_bi <- frec_bi %>%
  group_by(fuente) %>% slice_max(n, n = 20, with_ties = FALSE) %>% mutate(puesto = row_number()) %>% ungroup() %>%
  select(fuente, puesto, bigrama, por_mil, pct_docs) %>%
  pivot_wider(names_from = fuente, values_from = c(bigrama, por_mil, pct_docs)) %>%
  select(puesto, ends_with("_com"), ends_with("_junta"), ends_with("_completo"))
tabla_top_bi <- datos_top_bi %>%
  gt() %>%
  cols_label(puesto = "", bigrama_com = "Bigrama", por_mil_com = "Por 1.000", pct_docs_com = "% doc.",
             bigrama_junta = "Bigrama", por_mil_junta = "Por 1.000", pct_docs_junta = "% doc.",
             bigrama_completo = "Bigrama", por_mil_completo = "Por 1.000", pct_docs_completo = "% doc.") %>%
  tab_spanner("Comunicados", columns = ends_with("_com")) %>%
  tab_spanner("Minutas: discusión de la Junta", columns = ends_with("_junta")) %>%
  tab_spanner("Minutas: texto completo", columns = ends_with("_completo")) %>%
  fmt_es(c("por_mil_com", "por_mil_junta", "por_mil_completo"), 2) %>%
  fmt_es(c("pct_docs_com", "pct_docs_junta", "pct_docs_completo"), 0) %>%
  estilo_tabla(
    titulo = "Los 20 bigramas más frecuentes en los documentos de la Junta",
    subtitulo = "Pares de palabras contiguas del vocabulario limpio",
    nota = nota_tabla("conjunto", n = n_com + n_min, extra = c(
      "Por 1.000: apariciones por cada 1.000 palabras del texto. % doc.: porcentaje de los documentos con el bigrama. Palabras lematizadas y sin tildes.",
      "Los términos del diccionario de compuestos ya van unidos (con guion bajo) y cuentan como una sola palabra."
    ))
  )
guardar_tabla("conjunto_bigramas_frecuentes", tabla_top_bi, datos_top_bi, carpeta_salida)

# --- 1.2 por periodo -----------------------------------------------------------
frec_bi_periodo <- bigramas_fuente %>%
  count(fuente, periodo, bigrama) %>%
  left_join(palabras_periodo, by = c("fuente", "periodo")) %>%
  mutate(por_mil = 1000 * n / total)
write_csv(
  frec_bi_periodo %>% filter(n >= 3) %>% transmute(fuente = fuentes[fuente], periodo, bigrama, n, por_mil) %>%
    arrange(fuente, periodo, desc(n)),
  file.path("03_Resultados/Tablas", carpeta_salida, "conjunto_bigramas_por_periodo.csv")
)

figura_bi_periodo <- function(f, color, subtitulo, archivo) {
  datos <- frec_bi_periodo %>% filter(fuente == f) %>%
    group_by(periodo) %>% slice_max(n, n = 6, with_ties = FALSE) %>% ungroup() %>%
    left_join(select(periodos, periodo, etiqueta), by = "periodo") %>%
    mutate(bigrama = reorder_within(bigrama, por_mil, etiqueta))
  docs <- palabras_periodo %>% filter(fuente == f) %>% summarise(t = paste0(periodo, ": ", docs, collapse = "; ")) %>% pull(t)
  fig <- ggplot(datos, aes(por_mil, bigrama)) +
    geom_col(fill = color, width = 0.7) +
    facet_wrap(~ etiqueta, scales = "free", ncol = 5, labeller = label_wrap_gen(width = 26)) +
    scale_y_reordered() +
    scale_x_continuous(labels = scales::label_number(decimal.mark = ",", big.mark = "."), n.breaks = 3,
                       expand = expansion(mult = c(0, 0.08))) +
    labs(title = "Bigramas más frecuentes por periodo de política monetaria", subtitle = subtitulo,
         x = "Apariciones por cada 1.000 palabras", y = NULL,
         caption = paste0("n = ", sum(palabras_periodo$docs[palabras_periodo$fuente == f]), " documentos (", docs,
                          "). Los 6 bigramas más frecuentes de cada periodo. ", nota_exploratoria)) +
    tema_presentacion + tema_paneles + tema_barras_h +
    theme(strip.text = element_text(size = 8.5), axis.text.x = element_text(size = 7.5), axis.text.y = element_text(size = 7.5))
  guardar_figura(archivo, fig, carpeta_salida, width = 13, height = 6.5)
}
figura_bi_periodo("com", colores_tipo[["Comunicados"]], subtitulo_comunicados, "comunicados_bigramas_por_periodo.png")
figura_bi_periodo("junta", colores_tipo[["Minutas"]], paste(subtitulo_minutas, "Solo la discusión de la Junta."),
                  "minutas_bigramas_por_periodo.png")

# --- 1.3 candidatos para el diccionario de compuestos --------------------------
# bigramas frecuentes en todo el corpus cuyas dos palabras son simples (no
# estan ya en el diccionario). Son candidatos: la decision de agregarlos se
# toma al fijar la pregunta
datos_candidatos <- bigramas %>%
  filter(!str_detect(bigrama, "_")) %>%
  group_by(bigrama) %>%
  summarise(apariciones = n(), comunicados = n_distinct(id[tipo == "comunicado"]),
            minutas = n_distinct(id[tipo == "minuta"]), .groups = "drop") %>%
  slice_max(apariciones, n = 30, with_ties = FALSE)
tabla_candidatos <- datos_candidatos %>%
  gt() %>%
  cols_label(bigrama = "Bigrama (lemas)", apariciones = "Apariciones", comunicados = "Comunicados con el bigrama",
             minutas = "Minutas con el bigrama") %>%
  fmt_es(c("apariciones", "comunicados", "minutas"), 0) %>%
  estilo_tabla(
    titulo = "Bigramas frecuentes que no están en el diccionario de compuestos",
    subtitulo = "Los 30 pares de palabras simples más frecuentes: candidatos a unirse en un solo término",
    nota = nota_tabla("conjunto", n = n_com + n_min, extra =
      "Minutas: texto completo sin el preámbulo. Un bigrama es candidato si nombra un concepto (p. ej. un indicador) y no una frase de redacción.")
  )
guardar_tabla("conjunto_bigramas_candidatos", tabla_candidatos, datos_candidatos, carpeta_salida)

# -----------------------------------------------------------------------------
# 2. Votacion: unanimidad, mayoria y conteo de votos
# -----------------------------------------------------------------------------

# se trabaja con oraciones del texto extraido. En las minutas se usa la
# discusion de la Junta (incluye la seccion de decision)
oraciones <- corpus %>%
  transmute(id, tipo, fecha, periodo, texto = if_else(tipo == "minuta", texto_junta, paste(coalesce(titulo, ""), ". ", texto))) %>%
  mutate(oracion = partir_oraciones(texto)) %>%
  select(-texto) %>% unnest(oracion)

patron_unanimidad <- regex("unanimidad|un[aá]nime", ignore_case = TRUE)
patron_mayoria <- regex(paste0(
  "por mayor[ií]a|decisi[oó]n mayoritaria|de manera mayoritaria|mayor[ií]a de [0-9] a [0-9]|",
  "la mayor[ií]a de (los |sus )?(miembros|directores|codirectores)|grupo mayoritario|",
  "vot(ó|aron) (a favor|en favor|por|en contra)|votos? (a favor|en contra)"
), ignore_case = TRUE)
# la oracion debe hablar de la decision de tasa (y no, p. ej., de una compra
# de reservas aprobada por unanimidad)
patron_decision <- regex("tasa|decisi[oó]n|decidi|acord|vot|incremento|reducci[oó]n|recorte|puntos|\\bpb", ignore_case = TRUE)

# conteo de votos: "cuatro directores votaron ... y tres ...", "5 directores
# votaron", "mayoria de 4 a 3". Se leen los numeros (en cifras o en letras)
# que van antes de "miembros/directores" o en "X a Y" dentro de las oraciones
# de votacion. La Junta tiene 7 miembros
numeros <- c(un = 1, uno = 1, una = 1, dos = 2, tres = 3, cuatro = 4, cinco = 5, seis = 6, siete = 7)
patron_num <- "(?<![0-9,.])[1-7](?![0-9,.%])|\\b(un|uno|una|dos|tres|cuatro|cinco|seis|siete)\\b"
leer_conteo <- function(oraciones_voto) {
  texto <- str_to_lower(paste(oraciones_voto, collapse = " "))
  # numeros seguidos (a lo sumo 4 palabras despues) de miembros/directores, o
  # de "votaron/votó", o en la forma "X a Y"
  candidatos <- c(
    str_extract_all(texto, paste0("(", patron_num, ")(?=( \\S+){0,4} (miembros?|directores|director|codirectores|codirector|votaron|vot[oó]|votos?))"))[[1]],
    str_extract_all(texto, "(?<=mayor[ií]a de )[1-7] a [1-7]|\\b[1-7] a [1-7]\\b")[[1]] %>% str_split(" a ") %>% unlist()
  )
  if (length(candidatos) == 0) return(NA_character_)
  valores <- ifelse(candidatos %in% names(numeros), numeros[candidatos], suppressWarnings(as.integer(candidatos)))
  valores <- valores[!is.na(valores)]
  # el conteo es valido si los grupos suman a lo sumo 7 y hay al menos dos
  # grupos (o uno solo de 7, que es unanimidad)
  valores <- valores[seq_len(min(length(valores), 3))]
  if (length(valores) >= 2 && sum(valores) %in% 5:7) {
    paste(sort(valores, decreasing = TRUE), collapse = "-")
  } else if (length(valores) >= 3 && sum(valores[1:2]) %in% 5:7) {
    paste(sort(valores[1:2], decreasing = TRUE), collapse = "-")
  } else NA_character_
}

votacion <- oraciones %>%
  mutate(
    de_decision = str_detect(oracion, patron_decision),
    unanimidad = de_decision & str_detect(oracion, patron_unanimidad),
    mayoria = de_decision & str_detect(oracion, patron_mayoria),
    de_voto = unanimidad | mayoria | str_detect(oracion, regex("\\bvot(ó|aron|os?)\\b", ignore_case = TRUE))
  ) %>%
  group_by(id, tipo, fecha, periodo) %>%
  summarise(
    dice_unanimidad = any(unanimidad),
    dice_mayoria = any(mayoria),
    conteo = leer_conteo(oracion[de_voto]),
    cita = str_trunc(paste(oracion[unanimidad | mayoria], collapse = " [...] "), 400),
    .groups = "drop"
  ) %>%
  mutate(
    # si el documento dice las dos cosas (p. ej. unanimidad sobre la
    # direccion y mayoria sobre el tamano), se clasifica como mayoria: hubo
    # votos distintos
    resultado = case_when(
      dice_mayoria ~ "Mayoría",
      dice_unanimidad ~ "Unanimidad",
      TRUE ~ "Sin información"
    ),
    ambas = dice_mayoria & dice_unanimidad,
    anio = as.integer(format(fecha, "%Y"))
  )
write_csv(votacion %>% select(id, tipo, fecha, periodo, resultado, ambas, conteo, cita),
          file.path("03_Resultados/Tablas", carpeta_salida, "conjunto_votacion_por_documento.csv"))
message("Votacion: documentos con las dos expresiones (unanimidad y mayoria): ", sum(votacion$ambas),
        "; con conteo de votos codificable: ", sum(!is.na(votacion$conteo)), ".")

# --- 2.1 por ano ----------------------------------------------------------------
resumen_voto <- function(datos, grupo) {
  datos %>%
    group_by(tipo, {{ grupo }}) %>%
    summarise(
      docs = n(),
      pct_info = 100 * mean(resultado != "Sin información"),
      pct_unanimidad = 100 * mean(resultado == "Unanimidad"),
      pct_mayoria = 100 * mean(resultado == "Mayoría"),
      pct_conteo = 100 * mean(!is.na(conteo)),
      .groups = "drop"
    )
}
voto_anio <- resumen_voto(votacion, anio)
datos_voto_anio <- voto_anio %>%
  pivot_wider(names_from = tipo, values_from = c(docs, pct_info, pct_unanimidad, pct_mayoria, pct_conteo)) %>%
  select(anio, ends_with("_comunicado"), ends_with("_minuta"))
tabla_voto_anio <- datos_voto_anio %>%
  gt() %>%
  cols_label(anio = "Año") %>%
  cols_label_with(columns = starts_with("docs"), fn = ~ "n") %>%
  cols_label_with(columns = starts_with("pct_info"), fn = ~ "Con información de votación") %>%
  cols_label_with(columns = starts_with("pct_unanimidad"), fn = ~ "Unanimidad") %>%
  cols_label_with(columns = starts_with("pct_mayoria"), fn = ~ "Mayoría") %>%
  cols_label_with(columns = starts_with("pct_conteo"), fn = ~ "Con conteo de votos") %>%
  tab_spanner("Comunicados (% de los documentos del año)", columns = ends_with("_comunicado")) %>%
  tab_spanner("Minutas (% de los documentos del año)", columns = ends_with("_minuta")) %>%
  fmt_es(names(datos_voto_anio)[str_detect(names(datos_voto_anio), "^pct")], 0) %>%
  estilo_tabla(
    titulo = "Información de votación en los documentos de la Junta, por año",
    subtitulo = "Porcentaje de documentos que dicen si la decisión fue por unanimidad o por mayoría, y que dan el conteo de votos",
    nota = nota_tabla("conjunto", n = n_com + n_min, extra = c(
      "Búsqueda sobre el texto extraído (en las minutas, la discusión y la decisión de la Junta), en oraciones que hablan de la decisión. «Mayoría»: el documento dice «por mayoría», «la mayoría de los miembros», «grupo mayoritario» o reporta votos a favor o en contra; si también dice «unanimidad», se clasifica como mayoría.",
      "Conteo de votos: se leen los números de miembros en cada grupo (en cifras o en letras) cuando suman entre 5 y 7. Es una codificación automática, sin revisión manual de cada documento."
    ))
  )
guardar_tabla("conjunto_votacion_por_anio", tabla_voto_anio, datos_voto_anio, carpeta_salida)

datos_fig_voto <- votacion %>%
  mutate(tipo = if_else(tipo == "comunicado", "Comunicados", "Minutas"),
         resultado = factor(resultado, levels = c("Sin información", "Unanimidad", "Mayoría"))) %>%
  count(tipo, anio, resultado)
fig_voto <- ggplot(datos_fig_voto, aes(anio, n, fill = resultado)) +
  geom_col(width = 0.75) +
  facet_wrap(~ tipo, ncol = 1) +
  scale_fill_manual(values = c("Sin información" = gris_grilla, "Unanimidad" = paleta_categorica[3], "Mayoría" = paleta_categorica[2])) +
  scale_x_continuous(breaks = seq(2008, 2026, 2)) +
  scale_y_continuous(breaks = seq(0, 12, 4)) +
  labs(
    title = "Qué dicen los documentos sobre la votación de la Junta",
    subtitle = subtitulo_ambos,
    x = "Año de la reunión", y = "Número de documentos",
    caption = paste0("n = ", n_com, " comunicados y ", n_min, " minutas. Clasificación automática por expresiones («por unanimidad», «por mayoría», votos a favor o en contra) en las oraciones de la decisión. ", nota_exploratoria)
  ) +
  tema_presentacion + tema_paneles
guardar_figura("conjunto_votacion_por_anio.png", fig_voto, carpeta_salida, height = 6.5)

# --- 2.2 por periodo -------------------------------------------------------------
datos_voto_periodo <- resumen_voto(votacion, periodo) %>%
  pivot_wider(names_from = tipo, values_from = c(docs, pct_info, pct_unanimidad, pct_mayoria, pct_conteo)) %>%
  left_join(select(periodos, periodo, etiqueta), by = "periodo") %>%
  mutate(periodo = as.character(etiqueta)) %>%
  select(periodo, ends_with("_comunicado"), ends_with("_minuta"))
write_csv(datos_voto_periodo, file.path("03_Resultados/Tablas", carpeta_salida, "conjunto_votacion_por_periodo.csv"))

# --- 2.3 comunicado frente a minuta de la misma reunion ---------------------------
ambos <- votacion %>%
  select(fecha, tipo, resultado, conteo) %>%
  pivot_wider(names_from = tipo, values_from = c(resultado, conteo)) %>%
  filter(!is.na(resultado_comunicado), !is.na(resultado_minuta))
datos_cruce <- ambos %>%
  count(resultado_comunicado, resultado_minuta) %>%
  pivot_wider(names_from = resultado_minuta, values_from = n, values_fill = 0)
for (col in c("Sin información", "Unanimidad", "Mayoría")) if (!col %in% names(datos_cruce)) datos_cruce[[col]] <- 0L
datos_cruce <- datos_cruce %>% select(resultado_comunicado, `Sin información`, Unanimidad, `Mayoría`)
coinciden <- sum(ambos$resultado_comunicado == ambos$resultado_minuta)
contradicen <- sum((ambos$resultado_comunicado == "Unanimidad" & ambos$resultado_minuta == "Mayoría") |
                     (ambos$resultado_comunicado == "Mayoría" & ambos$resultado_minuta == "Unanimidad"))
tabla_cruce <- datos_cruce %>%
  gt() %>%
  cols_label(resultado_comunicado = "El comunicado dice") %>%
  tab_spanner("La minuta de la misma reunión dice (número de reuniones)", columns = -resultado_comunicado) %>%
  estilo_tabla(
    titulo = "Votación según el comunicado y según la minuta de la misma reunión",
    subtitulo = paste0("Reuniones con los dos documentos (", nrow(ambos), ")"),
    nota = nota_tabla("conjunto", n = 2 * nrow(ambos), periodo = paste0(nrow(ambos), " reuniones con comunicado y minuta, junio de 2007 a septiembre de 2026"), extra = c(
      paste0("Los dos documentos dicen lo mismo en ", coinciden, " reuniones; uno dice unanimidad y el otro mayoría en ", contradicen, "."),
      "Clasificación automática por expresiones; ver conjunto_votacion_por_documento.csv para la cita de cada documento."
    ))
  )
guardar_tabla("conjunto_votacion_comunicado_vs_minuta", tabla_cruce, datos_cruce, carpeta_salida)
write_csv(ambos, file.path("03_Resultados/Tablas", carpeta_salida, "conjunto_votacion_por_reunion.csv"))

# --- 2.4 direccion de la minoria y tabla para validacion manual ---------------

# Para cada documento se guarda la oracion (o las oraciones) de votacion
# completa, la clasificacion automatica y, cuando se puede leer, hacia donde
# voto la minoria frente a la decision: mas restrictiva (queria una tasa mas
# alta que la decidida), mas expansiva (mas baja) o mixta (hubo votos a los
# dos lados). CODIFICACION AUTOMATICA, PENDIENTE DE VALIDACION MANUAL.
#
# Como se lee: (1) la decision de la reunion es un cambio de la tasa en puntos
# basicos con signo (+ alza, - recorte, 0 sin cambio), leido de la primera
# oracion de decision; (2) en las oraciones de votacion se leen todas las
# alternativas mencionadas ("un incremento de 25 pb", "reducir en 50 pb",
# "mantener inalterada"); (3) las alternativas distintas de la decision son
# los votos de la minoria, y se comparan con la decision.
patron_pb <- "([0-9]{2,3}) ?(pbs?\\b|p[.] ?b|puntos)"
patron_alza <- "increment|aument|alza|subir|elev"
patron_recorte <- "reducci|reduc|disminu|recort|baja|bajar|rebaj"
patron_sin_cambio <- "mantener|mantenerla|inalterad|estable|sin cambio|no modificar"

# cambio decidido, en pb con signo
decisiones <- readRDS("01_Datos/02_Procesados/decisiones_reunion.rds")
cambio_decidido <- function(decision, cita) {
  if (is.na(decision)) return(NA_real_)
  if (decision == "mantiene") return(0)
  cita <- str_to_lower(coalesce(cita, ""))
  pb <- as.numeric(str_match(cita, patron_pb)[, 2])
  if (is.na(pb) && str_detect(cita, "medio punto")) pb <- 50
  if (is.na(pb) && str_detect(cita, "un punto porcentual")) pb <- 100
  if (decision == "sube") pb else -pb
}
decisiones <- decisiones %>%
  mutate(cambio_pb = map2_dbl(decision, cita, cambio_decidido)) %>%
  select(fecha, decision, cambio_pb)

# alternativas mencionadas en un texto: vector de cambios en pb con signo
leer_alternativas <- function(texto) {
  texto <- str_to_lower(texto)
  # cada mencion: un verbo o sustantivo de direccion seguido (a lo sumo 60
  # caracteres despues, sin cruzar un punto) de una cifra en pb
  m <- str_match_all(
    texto,
    paste0("(", patron_alza, "|", patron_recorte, ")[^.;]{0,60}?(?<![0-9,.])", patron_pb)
  )[[1]]
  valores <- numeric(0)
  if (nrow(m) > 0) {
    pb <- as.numeric(m[, 3])
    signo <- if_else(str_detect(m[, 2], patron_alza), 1, -1)
    ok <- pb <= 200 & pb %% 25 == 0 # se descartan cifras que no son un movimiento de tasa
    valores <- (signo * pb)[ok]
  }
  if (str_detect(texto, paste0("(vot[oó]|votaron|partidari[oa]s?|favor|prefiri|consider[oó]|propus)[^.;]{0,80}(", patron_sin_cambio, ")"))) {
    valores <- c(valores, 0)
  }
  unique(valores)
}

# oraciones de votacion de cada documento: las de unanimidad o mayoria, las
# que reportan votos y las que atribuyen una posicion a una parte de la Junta
patron_grupo <- regex(paste0(
  "\\bvot(ó|aron|os?)\\b|minor[ií]a|minoritari|restantes?|",
  "\\b(otros?|algunos|un|una|dos|tres) (de los )?(miembros?|directore?s?|codirectore?s?|integrantes?)"
), ignore_case = TRUE)
validacion <- oraciones %>%
  mutate(
    de_decision = str_detect(oracion, patron_decision),
    es_voto = de_decision & (str_detect(oracion, patron_unanimidad) | str_detect(oracion, patron_mayoria) |
                               str_detect(oracion, patron_grupo))
  ) %>%
  group_by(id, tipo, fecha) %>%
  summarise(oracion_votacion = paste(oracion[es_voto], collapse = " [...] "), .groups = "drop") %>%
  left_join(select(votacion, id, periodo, resultado, ambas, conteo), by = "id") %>%
  left_join(decisiones, by = "fecha") %>%
  left_join(select(corpus, id, formato), by = "id") %>%
  mutate(
    estrato = coalesce(formato, "Comunicado"),
    alternativas = map(oracion_votacion, leer_alternativas),
    # votos de la minoria: alternativas distintas de la decision
    minoria = map2(alternativas, cambio_pb, ~ if (is.na(.y)) numeric(0) else setdiff(.x, .y)),
    direccion_minoria = pmap_chr(list(minoria, cambio_pb, resultado), function(m, d, r) {
      if (r != "Mayoría" || is.na(d) || length(m) == 0) return(NA_character_)
      if (all(m > d)) "Más restrictiva" else if (all(m < d)) "Más expansiva" else "Mixta"
    }),
    alternativas_pb = map_chr(alternativas, ~ paste(sort(.x), collapse = "; ")),
    minoria_pb = map_chr(minoria, ~ paste(sort(.x), collapse = "; "))
  ) %>%
  select(id, tipo, fecha, periodo, estrato, decision, cambio_pb, clasificacion = resultado, ambas, conteo,
         direccion_minoria, alternativas_pb, minoria_pb, oracion_votacion) %>%
  arrange(fecha, tipo)
write_csv(validacion, file.path("03_Resultados/Tablas", carpeta_salida, "conjunto_votacion_validacion.csv"))

# muestra para revision manual: 30 documentos, 5 por estrato (los cinco
# formatos de minuta y los comunicados), semilla 2026. Las tres ultimas
# columnas quedan vacias para que las llene quien revise
set.seed(2026)
muestra <- validacion %>%
  group_by(estrato) %>%
  slice_sample(n = 5) %>%
  ungroup() %>%
  arrange(estrato, fecha) %>%
  mutate(revision_clasificacion = "", revision_direccion_minoria = "", comentario = "")
write_csv(muestra, file.path("03_Resultados/Tablas", carpeta_salida, "conjunto_votacion_muestra_validacion.csv"))

# por reunion: se usa la minuta; si la reunion no tiene minuta, el comunicado
por_reunion <- validacion %>%
  arrange(fecha, desc(tipo == "minuta")) %>%
  group_by(fecha) %>% slice(1) %>% ungroup() %>%
  mutate(anio = as.integer(format(fecha, "%Y")))
datos_minoria <- por_reunion %>%
  group_by(anio) %>%
  summarise(
    reuniones = n(),
    mayoria = sum(clasificacion == "Mayoría"),
    codificable = sum(!is.na(direccion_minoria)),
    restrictiva = sum(direccion_minoria == "Más restrictiva", na.rm = TRUE),
    expansiva = sum(direccion_minoria == "Más expansiva", na.rm = TRUE),
    mixta = sum(direccion_minoria == "Mixta", na.rm = TRUE),
    .groups = "drop"
  )
datos_minoria <- bind_rows(
  datos_minoria %>% mutate(anio = as.character(anio)),
  datos_minoria %>% summarise(anio = "Total", across(-anio, sum))
)
tabla_minoria <- datos_minoria %>%
  gt() %>%
  cols_label(anio = "Año", reuniones = "Reuniones", mayoria = "Decididas por mayoría",
             codificable = "Con dirección de la minoría codificable", restrictiva = "Más restrictiva",
             expansiva = "Más expansiva", mixta = "Mixta") %>%
  tab_spanner("Dirección del voto de la minoría frente a la decisión", columns = c(restrictiva, expansiva, mixta)) %>%
  tab_style(cell_text(weight = "bold"), cells_body(rows = anio == "Total")) %>%
  estilo_tabla(
    titulo = "Reuniones con dirección del voto de la minoría codificable, por año",
    subtitulo = "Número de reuniones; codificación automática, pendiente de validación manual",
    nota = nota_tabla("conjunto", n = nrow(por_reunion), periodo = paste0(nrow(por_reunion), " reuniones, enero de 2007 a septiembre de 2026 (la minuta de cada reunión o, si no hay, el comunicado)"), extra = c(
      "Más restrictiva: la minoría votó por una tasa más alta que la decidida (un alza mayor, un recorte menor o no recortar). Más expansiva: por una tasa más baja. Mixta: hubo votos a los dos lados.",
      "Se leen las alternativas en puntos básicos de las oraciones de votación y se comparan con la decisión. No codificable: la decisión fue por mayoría pero el texto no dice qué proponía la minoría con una cifra o con «mantener».",
      "La oración de votación de cada documento está en conjunto_votacion_validacion.csv; una muestra de 30 documentos para revisión manual, en conjunto_votacion_muestra_validacion.csv."
    ))
  )
guardar_tabla("conjunto_minoria_por_anio", tabla_minoria, datos_minoria, carpeta_salida)
message("Direccion de la minoria codificable en ", sum(!is.na(por_reunion$direccion_minoria)), " de ",
        sum(por_reunion$clasificacion == "Mayoría"), " reuniones decididas por mayoria.")

# -----------------------------------------------------------------------------
# 3. Expresiones de desacuerdo en las minutas, por ano
# -----------------------------------------------------------------------------

quien <- "(miembros|directores|codirectores|integrantes)"
expresiones <- c(
  "«algunos miembros / directores»" = paste0("\\balgunos (de los )?", quien),
  "«otros miembros / directores»" = paste0("\\b(otros|los dem[aá]s|los restantes) (de los )?", quien, "|\\bel (otro|resto del) grupo|\\botro grupo"),
  "«un miembro / director»" = "\\b(un|una|otro) (miembro|director|codirector|directora|codirectora)\\b",
  "«la mayoría» / «grupo mayoritario»" = paste0("\\bla mayor[ií]a( de (los |sus )?", quien, ")?|\\bgrupo mayoritario|\\bpor mayor[ií]a"),
  "«unanimidad»" = "unanimidad|un[aá]nime",
  "votos («votaron», «votó», «votos»)" = "\\bvot(aron|[oó]|os?)\\b"
)
desacuerdo_doc <- corpus %>%
  filter(tipo == "minuta") %>%
  transmute(id, fecha, anio = as.integer(format(fecha, "%Y")), palabras = palabras_junta, texto = str_to_lower(texto_junta))
for (k in names(expresiones)) desacuerdo_doc[[k]] <- str_count(desacuerdo_doc$texto, expresiones[[k]])
desacuerdo_anio <- desacuerdo_doc %>%
  select(-texto) %>%
  pivot_longer(all_of(names(expresiones)), names_to = "expresion", values_to = "n") %>%
  group_by(anio, expresion) %>%
  summarise(menciones = sum(n), por_mil = 1000 * sum(n) / sum(palabras), pct_minutas = 100 * mean(n > 0), minutas = n(), .groups = "drop") %>%
  mutate(expresion = factor(expresion, levels = names(expresiones)))
write_csv(desacuerdo_anio, file.path("03_Resultados/Tablas", carpeta_salida, "minutas_desacuerdo_por_anio.csv"))
write_csv(desacuerdo_doc %>% select(-texto), file.path("03_Resultados/Tablas", carpeta_salida, "minutas_desacuerdo_por_documento.csv"))

fig_desacuerdo <- ggplot(desacuerdo_anio, aes(as.Date(paste0(anio, "-07-01")), por_mil)) +
  capa_cortes_formato(cortes_formato) +
  geom_line(color = colores_tipo[["Minutas"]], linewidth = 0.8) +
  geom_point(color = colores_tipo[["Minutas"]], size = 1.2) +
  facet_wrap(~ expresion, ncol = 3, scales = "free_y") +
  scale_x_date(date_breaks = "4 years", date_labels = "%Y") +
  scale_y_continuous(labels = scales::label_number(decimal.mark = ",", big.mark = "."), limits = c(0, NA)) +
  labs(
    title = "Expresiones de desacuerdo y votación en las minutas, por año",
    subtitle = paste(subtitulo_minutas, "Solo la discusión de la Junta."),
    x = "Año de la reunión", y = "Menciones por cada 1.000 palabras",
    caption = paste0("n = ", n_min, " minutas. Búsqueda sobre el texto extraído. Líneas punteadas: cambios de formato de las minutas. ", nota_exploratoria)
  ) +
  tema_presentacion + tema_paneles
guardar_figura("minutas_desacuerdo_por_anio.png", fig_desacuerdo, carpeta_salida, width = 11, height = 6.5)

# tabla resumen: porcentaje de minutas con cada expresion, por formato
datos_desac_formato <- desacuerdo_doc %>%
  left_join(select(corpus, id, formato), by = "id") %>%
  select(-texto) %>%
  pivot_longer(all_of(names(expresiones)), names_to = "expresion", values_to = "n") %>%
  group_by(formato, expresion) %>%
  summarise(pct = 100 * mean(n > 0), minutas = n(), .groups = "drop") %>%
  left_join(formatos_minutas %>% transmute(formato, etiqueta = paste0(formato, " (desde ", format(inicio, "%Y-%m"), ")")), by = "formato") %>%
  mutate(etiqueta = paste0(etiqueta, ", n = ", minutas)) %>%
  select(expresion, etiqueta, pct) %>%
  pivot_wider(names_from = etiqueta, values_from = pct)
tabla_desac <- datos_desac_formato %>%
  gt() %>%
  cols_label(expresion = "Expresión") %>%
  tab_spanner("Formato de la minuta (% de las minutas que usan la expresión)", columns = -expresion) %>%
  fmt_es(names(datos_desac_formato)[-1], 0) %>%
  estilo_tabla(
    titulo = "Expresiones de desacuerdo y votación según el formato de la minuta",
    subtitulo = "Porcentaje de las minutas de cada formato que usan cada expresión al menos una vez",
    nota = nota_tabla("minutas", n = n_min, extra =
      "Búsqueda sobre la discusión y la decisión de la Junta. La forma de reportar el desacuerdo cambia con el formato: una diferencia entre épocas puede ser un cambio en cómo se redacta la minuta y no en cuánto se divide la Junta.")
  )
guardar_tabla("minutas_desacuerdo_por_formato", tabla_desac, datos_desac_formato, carpeta_salida)

message("04_bigramas: listo.")
