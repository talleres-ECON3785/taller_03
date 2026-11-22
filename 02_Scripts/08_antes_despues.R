# =============================================================================
# 09. Que cambio antes y despues del choque petrolero: palabras, bigramas,
#     atencion por tema y correlaciones entre palabras (H3b de PLAN.md)
# Taller 3 - ECON-3785
#
# Entradas: 01_Datos/02_Procesados/corpus_texto.rds,
#           01_Datos/03_Listos/tokens_limpios.rds, tokens_anotados.rds,
#           macro_por_reunion.rds
# Salidas:  03_Resultados/Tablas/08_antes_despues/ y Figuras/08_antes_despues/
#
# Diseno (comun a todas las medidas):
#   - Epocas: "antes" y "despues" del corte `corte_crisis` (2014-10-30), en
#     una ventana de 5 anos a cada lado (2009-10-30 a 2019-10-29): deja fuera
#     la crisis de 2008 y la pandemia. Robustez (solo tablas de apoyo): la
#     muestra completa 2007-2026 y los dos `cortes_alternativos`, cada uno con
#     su propia ventana de 5 anos.
#   - Minutas: solo la discusion de la Junta. Comunicados en paralelo como
#     CONTROL de formato: las minutas cambian de formato el 2014-05-30, casi en
#     el corte. Un cambio que aparece en minutas y no en comunicados se marca
#     como posible artefacto de formato.
#   - Todo por 1.000 palabras del texto (todas las palabras del documento, no
#     solo las que quedan tras la limpieza), como en 03.
#   - Cada palabra, bigrama o tema de una figura va con un fragmento del texto
#     (fecha y tipo de documento) en las tablas de fragmentos.
#
# Que hace:
#   1. palabras distintivas: razon de frecuencias despues / antes (medida
#      principal) y TF-IDF con dos grupos (complemento);
#   2. bigramas mas frecuentes y que mas cambian;
#   3. atencion por tema (diccionario `temas`) por reunion: medias, diferencia
#      e IC 95 %; serie por reunion junto a Brent, TRM e inflacion;
#   4. correlaciones entre palabras (pairwise_cor, documento = oracion) para
#      siete palabras ancla, antes y despues.
# La relacion texto-macro es asociativa, no causal.
# =============================================================================

# los paquetes los carga 00_main.R con pacman

source("02_Scripts/00_formato_tablas.R")
source("02_Scripts/00_funciones_texto.R")

carpeta_salida <- "08_antes_despues"
ruta_tabla <- function(nombre) file.path("03_Resultados/Tablas", carpeta_salida, nombre)

corpus <- readRDS("01_Datos/02_Procesados/corpus_texto.rds")
limpios <- readRDS("01_Datos/03_Listos/tokens_limpios.rds")
anotados <- readRDS("01_Datos/03_Listos/tokens_anotados.rds")
macro <- readRDS("01_Datos/03_Listos/macro_por_reunion.rds")

fuentes <- c(com = "Comunicados", junta = "Minutas: discusión de la Junta")
color_fuente <- c(com = unname(colores_tipo["Comunicados"]), junta = unname(colores_tipo["Minutas"]))
epocas <- c(antes = "Antes", despues = "Después")
fmt_es <- function(tabla, columnas, decimales_n) {
  fmt_number(tabla, columns = all_of(columnas), decimals = decimales_n, dec_mark = ",", sep_mark = ".")
}
# cifra con coma decimal y sin relleno de espacios
num_es <- function(x, d) sub(".", ",", sprintf(paste0("%.", d, "f"), round(x, d) + 0), fixed = TRUE)
fuente_figuras <- "Fuente: comunicados y minutas de la Junta Directiva del Banco de la República; cálculos propios."

# --- epocas y escenarios ------------------------------------------------------

# `asignar_epoca()` y `escenarios` viven en 00_funciones_texto.R (los comparten 08, 09 y 10)
nombre_esc <- setNames(escenarios$nombre, escenarios$escenario)

# tokens limpios y palabras por documento de cada fuente (como en 03)
tokens_fuente <- bind_rows(
  limpios %>% filter(tipo == "comunicado") %>% mutate(fuente = "com"),
  limpios %>% filter(tipo == "minuta", es_junta) %>% mutate(fuente = "junta")
) %>% select(fuente, id, fecha, word)
palabras_doc <- bind_rows(
  corpus %>% filter(tipo == "comunicado") %>% transmute(fuente = "com", id, fecha, palabras),
  corpus %>% filter(tipo == "minuta") %>% transmute(fuente = "junta", id, fecha, palabras = palabras_junta)
)
stopifnot(all(palabras_doc$palabras > 0))

# documentos con su epoca en cada escenario (los de fuera de la ventana salen)
docs_esc <- escenarios %>%
  rowwise() %>%
  reframe(escenario, palabras_doc %>% mutate(epoca = asignar_epoca(fecha, corte, ventana))) %>%
  filter(!is.na(epoca))

# reuniones y palabras por epoca
datos_epocas <- docs_esc %>%
  group_by(escenario, fuente, epoca) %>%
  summarise(reuniones = n(), palabras = sum(palabras), desde = min(fecha), hasta = max(fecha), .groups = "drop")
n_reun <- function(f, e, esc = "principal") {
  datos_epocas$reuniones[datos_epocas$escenario == esc & datos_epocas$fuente == f & datos_epocas$epoca == e]
}
datos_tabla_epocas <- datos_epocas %>%
  mutate(escenario = factor(nombre_esc[escenario], levels = escenarios$nombre), fuente = fuentes[fuente],
         rango = paste(desde, "a", hasta)) %>%
  select(escenario, fuente, epoca, reuniones, palabras, rango) %>%
  pivot_wider(names_from = epoca, values_from = c(reuniones, palabras, rango)) %>%
  arrange(escenario, fuente)
tabla_epocas <- datos_tabla_epocas %>%
  gt(groupname_col = "escenario") %>%
  cols_label(fuente = "Documento", reuniones_antes = "Reuniones", palabras_antes = "Palabras", rango_antes = "Fechas",
             reuniones_despues = "Reuniones", palabras_despues = "Palabras", rango_despues = "Fechas") %>%
  tab_spanner("Antes", columns = ends_with("_antes")) %>%
  tab_spanner("Después", columns = ends_with("_despues")) %>%
  fmt_es(c("reuniones_antes", "palabras_antes", "reuniones_despues", "palabras_despues"), 0) %>%
  tab_style(cell_text(weight = "bold"), cells_row_groups()) %>%
  estilo_tabla(
    titulo = "Documentos a cada lado del corte, en cada escenario",
    subtitulo = "Reuniones y palabras de la discusión de la Junta (minutas) y de los comunicados",
    nota = nota_tabla("conjunto", extra = c(
      "El escenario principal usa el corte del 2014-10-30 y 5 años a cada lado; los otros tres son de robustez.",
      "Palabras: todas las del texto (en las minutas, solo la discusión de la Junta). Las minutas tienen menos palabras después del corte por su cambio de formato."))
  )
guardar_tabla("conjunto_documentos_por_epoca", tabla_epocas, datos_tabla_epocas, carpeta_salida)

# -----------------------------------------------------------------------------
# 0. Fragmentos del texto
# -----------------------------------------------------------------------------

# oraciones de udpipe (la misma particion que usan los bigramas de 04), con la
# cadena de lemas (para buscar palabras y bigramas) y la de formas originales
oraciones <- anotados %>%
  filter(tipo == "comunicado" | es_junta) %>%
  mutate(fuente = if_else(tipo == "comunicado", "com", "junta"), token_id = as.integer(token_id)) %>%
  arrange(unidad, sentence_id, token_id) %>%
  group_by(fuente, id, fecha, unidad, sentence_id) %>%
  summarise(lemas = paste0(" ", paste(word, collapse = " "), " "), texto_tok = paste(token, collapse = " "),
            n_tok = n(), .groups = "drop") %>%
  mutate(oracion = paste(unidad, sentence_id, sep = "__"))

# `texto_original()` (oracion original del PDF) vive en 00_funciones_texto.R

# fragmento para un termino (palabra o bigrama, en lemas) en una fuente y un
# conjunto de documentos: del documento con mas oraciones que lo usan, la
# primera oracion de 12 a 70 tokens que lo contiene
fragmento <- function(f, ids, termino) {
  cand <- oraciones %>% filter(fuente == f, id %in% ids, str_detect(lemas, fixed(paste0(" ", termino, " "))))
  if (nrow(cand) == 0) return(tibble(fecha = as.Date(NA), fragmento = NA_character_))
  if (any(between(cand$n_tok, 12, 70))) cand <- filter(cand, between(n_tok, 12, 70))
  elegida <- cand %>% add_count(id, name = "usos") %>% arrange(desc(usos), fecha, sentence_id) %>% slice(1)
  tibble(fecha = elegida$fecha, fragmento = texto_original(corpus$texto[corpus$id == elegida$id], elegida$texto_tok))
}
ids_epoca <- function(f, e, esc = "principal") docs_esc$id[docs_esc$escenario == esc & docs_esc$fuente == f & docs_esc$epoca == e]
tipo_doc <- c(com = "comunicado", junta = "minuta")

# -----------------------------------------------------------------------------
# 1 y 2. Palabras y bigramas que cambian: razon de frecuencias y TF-IDF
# -----------------------------------------------------------------------------

# frecuencias por epoca de cada termino, en cada escenario y fuente.
# Razon = (frecuencia por palabra despues) / (antes), con 0,5 apariciones
# sumadas a cada lado para que exista cuando el termino falta en una epoca.
# TF-IDF con las dos epocas como grupos: el idf solo vale 0 (el termino esta
# en las dos) o log(2) (solo en una), asi que solo ordena los exclusivos
cambios_terminos <- function(terminos) {
  totales <- docs_esc %>% group_by(escenario, fuente, epoca) %>% summarise(total = sum(palabras), .groups = "drop")
  conteos <- docs_esc %>%
    select(escenario, fuente, id, epoca) %>%
    inner_join(terminos, by = c("fuente", "id"), relationship = "many-to-many") %>%
    count(escenario, fuente, epoca, termino)
  tfidf <- conteos %>%
    group_by(escenario, fuente) %>% group_modify(~ bind_tf_idf(.x, termino, epoca, n)) %>% ungroup() %>%
    select(escenario, fuente, epoca, termino, tf_idf)
  conteos %>%
    left_join(tfidf, by = c("escenario", "fuente", "epoca", "termino")) %>%
    pivot_wider(names_from = epoca, values_from = c(n, tf_idf), values_fill = 0) %>%
    left_join(totales %>% pivot_wider(names_from = epoca, values_from = total, names_prefix = "total_"),
              by = c("escenario", "fuente")) %>%
    mutate(por_mil_antes = 1000 * n_antes / total_antes, por_mil_despues = 1000 * n_despues / total_despues,
           razon = ((n_despues + 0.5) / total_despues) / ((n_antes + 0.5) / total_antes))
}

# lectura de cada termino seleccionado en el escenario principal:
#   - en minutas, si en los comunicados va en la direccion contraria (o no
#     cambia), "posible artefacto de formato"; en comunicados, "no se ve en
#     las minutas";
#   - si no, "robusta" cuando la direccion se mantiene en la muestra completa
#     y con los dos cortes alternativos, y "matizada" cuando alguno la cambia
leer_robustez <- function(seleccion, cambios) {
  dir <- function(r) sign(log(r))
  otros <- cambios %>% select(escenario, fuente, termino, razon) %>%
    pivot_wider(names_from = escenario, values_from = razon, names_prefix = "razon_")
  otra_fuente <- cambios %>% filter(escenario == "principal") %>%
    transmute(fuente = if_else(fuente == "com", "junta", "com"), termino, razon_otra = razon)
  seleccion %>%
    left_join(select(otros, -razon_principal), by = c("fuente", "termino")) %>%
    left_join(otra_fuente, by = c("fuente", "termino")) %>%
    mutate(
      across(c(razon_completa, razon_corte_p4, razon_corte_trm, razon_otra), ~ coalesce(.x, 1)),
      misma_otra = dir(razon_otra) == dir(razon),
      misma_rob = dir(razon_completa) == dir(razon) & dir(razon_corte_p4) == dir(razon) & dir(razon_corte_trm) == dir(razon),
      lectura = case_when(
        !misma_otra & fuente == "junta" ~ "Posible artefacto de formato",
        !misma_otra ~ "No se ve en las minutas",
        misma_rob ~ "Robusta",
        TRUE ~ "Matizada"
      )
    )
}

# selecciona los `k` que mas ganan y los `k` que mas pierden en el escenario
# principal, con su lectura de robustez y un fragmento de la epoca en que son
# mas frecuentes
seleccionar <- function(cambios, k, min_n) {
  sel <- cambios %>%
    filter(escenario == "principal", n_antes + n_despues >= min_n) %>%
    group_by(fuente) %>%
    group_modify(~ bind_rows(slice_max(.x, razon, n = k, with_ties = FALSE) %>% mutate(lado = "Gana"),
                             slice_min(.x, razon, n = k, with_ties = FALSE) %>% mutate(lado = "Pierde"))) %>%
    ungroup() %>%
    leer_robustez(cambios)
  frag <- sel %>% select(fuente, termino, lado) %>%
    mutate(epoca = if_else(lado == "Gana", "despues", "antes")) %>%
    rowwise() %>%
    mutate(fragmento(fuente, ids_epoca(fuente, epoca), termino)) %>%
    ungroup() %>%
    rename(fecha_fragmento = fecha)
  left_join(sel, frag, by = c("fuente", "termino", "lado"))
}

# figura de barras divergentes: log2 de la razon, con la etiqueta en la escala
# original (0,5 = la mitad; 2 = el doble)
figura_cambios <- function(sel, titulo, subtitulo, nota, archivo, height) {
  datos <- sel %>%
    mutate(panel = factor(fuentes[fuente], levels = fuentes),
           termino_fig = reorder_within(str_replace_all(termino, "_", " "), razon, panel))
  fig <- ggplot(datos, aes(log2(razon), termino_fig, fill = fuente)) +
    geom_col(width = 0.7) +
    geom_vline(xintercept = 0, color = gris_secundario, linewidth = 0.4) +
    facet_wrap(~ panel, scales = "free_y") +
    scale_y_reordered() +
    scale_x_continuous(labels = c("1/16", "1/4", "1", "4", "16", "64"),
                       breaks = log2(c(1 / 16, 1 / 4, 1, 4, 16, 64))) +
    scale_fill_manual(values = color_fuente, guide = "none") +
    labs(title = titulo, subtitle = subtitulo, x = "Razón de frecuencias por 1.000 palabras, después / antes (escala logarítmica)",
         y = NULL, caption = nota) +
    tema_presentacion + tema_paneles + tema_barras_h + theme(axis.text.y = element_text(size = 8.5))
  guardar_figura(archivo, fig, carpeta_salida, width = 11, height = height)
}

# tabla de fragmentos: los `k` primeros de cada lado y fuente
tabla_fragmentos <- function(sel, k, titulo, subtitulo, archivo, etiqueta_termino) {
  datos <- sel %>%
    group_by(fuente, lado) %>% slice_max(abs(log(razon)), n = k, with_ties = FALSE) %>% ungroup() %>%
    arrange(fuente, lado, desc(abs(log(razon)))) %>%
    transmute(grupo = paste0(fuentes[fuente], ": ", if_else(lado == "Gana", "más frecuentes después", "más frecuentes antes")),
              termino = str_replace_all(termino, "_", " "), razon, lectura,
              documento = paste(tipo_doc[fuente], fecha_fragmento), fragmento)
  tabla <- datos %>%
    gt(groupname_col = "grupo") %>%
    cols_label(termino = etiqueta_termino, razon = "Razón después / antes", lectura = "Lectura",
               documento = "Documento", fragmento = "Fragmento") %>%
    fmt_es("razon", decimales$razon) %>%
    cols_width(termino ~ px(150), razon ~ px(90), lectura ~ px(120), documento ~ px(130), fragmento ~ px(620)) %>%
    tab_style(cell_text(size = px(12)), cells_body(columns = fragmento)) %>%
    tab_style(cell_text(weight = "bold"), cells_row_groups()) %>%
    estilo_tabla(titulo = titulo, subtitulo = subtitulo, nota = nota_tabla("conjunto", periodo = "2009-10-30 a 2019-10-29", extra = c(
      "Fragmento: una oración del documento de la época en que el término es más frecuente (después si gana, antes si pierde), tomada del documento que más lo usa.",
      "Lectura: «Robusta» si la dirección se mantiene con la muestra completa y con los cortes 2014-09-26 y 2014-12-19; «Matizada» si alguno la cambia; «Posible artefacto de formato» si cambia en las minutas y no en los comunicados; «No se ve en las minutas» si cambia solo en los comunicados.")))
  guardar_tabla(archivo, tabla, datos, carpeta_salida)
}

# tabla de robustez completa de los terminos de la figura, por fuente
tabla_robustez <- function(sel, f, titulo, archivo, etiqueta_termino) {
  datos <- sel %>% filter(fuente == f) %>% arrange(lado, desc(abs(log(razon)))) %>%
    transmute(lado = if_else(lado == "Gana", "Más frecuentes después", "Más frecuentes antes"),
              termino = str_replace_all(termino, "_", " "), por_mil_antes, por_mil_despues, razon,
              razon_otra, razon_completa, razon_corte_p4, razon_corte_trm, lectura)
  otra <- if (f == "com") "En las minutas" else "En los comunicados"
  tabla <- datos %>%
    gt(groupname_col = "lado") %>%
    cols_label(termino = etiqueta_termino, por_mil_antes = "Antes", por_mil_despues = "Después", razon = "Razón",
               razon_otra = otra, razon_completa = "Muestra completa", razon_corte_p4 = "Corte 2014-09-26",
               razon_corte_trm = "Corte 2014-12-19", lectura = "Lectura") %>%
    tab_spanner("Por 1.000 palabras", columns = c(por_mil_antes, por_mil_despues)) %>%
    tab_spanner("Razón después / antes en otros escenarios", columns = c(razon_otra, razon_completa, razon_corte_p4, razon_corte_trm)) %>%
    fmt_es(c("por_mil_antes", "por_mil_despues"), 2) %>%
    fmt_es(c("razon", "razon_otra", "razon_completa", "razon_corte_p4", "razon_corte_trm"), decimales$razon) %>%
    tab_style(cell_text(weight = "bold"), cells_row_groups()) %>%
    estilo_tabla(titulo = titulo, subtitulo = paste0(fuentes[[f]], ": escenario principal y robustez"),
                 nota = nota_tabla(if (f == "com") "comunicados" else "minutas", periodo = "2009-10-30 a 2019-10-29",
                                   n = n_reun(f, "antes") + n_reun(f, "despues"), extra = c(
      "Razón: frecuencia por 1.000 palabras después del corte dividida por la de antes, con 0,5 apariciones sumadas a cada lado. Mayor que 1: más frecuente después.",
      "Lectura: ver la tabla de fragmentos. Las minutas usan solo la discusión de la Junta.")))
  guardar_tabla(archivo, tabla, datos, carpeta_salida)
}

# --- 1. palabras -------------------------------------------------------------
min_palabra <- 20 # apariciones minimas, sumando las dos epocas (como en 03)
cambios_palabras <- cambios_terminos(tokens_fuente %>% transmute(fuente, id, termino = word))
sel_palabras <- seleccionar(cambios_palabras, 15, min_palabra)
write_csv(cambios_palabras %>% mutate(escenario = nombre_esc[escenario], fuente = fuentes[fuente]) %>% arrange(escenario, fuente, desc(razon)),
          ruta_tabla("conjunto_palabras_cambio_detalle.csv"))

nota_n <- paste0("n = ", n_reun("com", "antes"), " comunicados antes y ", n_reun("com", "despues"), " después; ",
                 n_reun("junta", "antes"), " minutas antes y ", n_reun("junta", "despues"), " después.")
figura_cambios(
  sel_palabras,
  "Palabras que más ganan y más pierden peso después del choque petrolero",
  "Comunicados y minutas (solo la discusión de la Junta), 5 años antes y 5 años después del 2014-10-30.",
  paste(
    "Razón de frecuencias por 1.000 palabras, después / antes, con 0,5 apariciones sumadas a cada lado; las 15 que más ganan y las 15 que más pierden.",
    paste0("Palabras con ", min_palabra, " o más apariciones en las dos épocas juntas. Antes: 2009-10-30 a 2014-10-29; después: 2014-10-30 a 2019-10-29."),
    nota_n,
    "Lectura de robustez y fragmentos de cada palabra en las tablas de apoyo de este script.",
    fuente_figuras, sep = "\n"),
  "conjunto_palabras_distintivas.png", height = 8.5
)
tabla_fragmentos(sel_palabras, 5, "Qué dicen las palabras que más cambian antes y después del corte",
                 "Las 5 palabras que más ganan y las 5 que más pierden, con un fragmento de los documentos",
                 "conjunto_fragmentos_palabras", "Palabra")
write_csv(sel_palabras %>% mutate(fuente = fuentes[fuente]), ruta_tabla("conjunto_palabras_seleccion_fragmentos.csv"))
for (f in names(fuentes)) {
  tabla_robustez(sel_palabras, f, "Palabras que más cambian antes y después del corte, con su robustez",
                 paste0(c(com = "comunicados", junta = "minutas")[[f]], "_palabras_robustez"), "Palabra")
}

# --- 2. bigramas -------------------------------------------------------------
min_bigrama <- 10
bigramas <- construir_bigramas(anotados) %>%
  filter(tipo == "comunicado" | es_junta) %>%
  transmute(fuente = if_else(tipo == "comunicado", "com", "junta"), id, termino = bigrama)
cambios_bigramas <- cambios_terminos(bigramas)
sel_bigramas <- seleccionar(cambios_bigramas, 10, min_bigrama)
write_csv(cambios_bigramas %>% mutate(escenario = nombre_esc[escenario], fuente = fuentes[fuente]) %>% arrange(escenario, fuente, desc(razon)),
          ruta_tabla("conjunto_bigramas_cambio_detalle.csv"))
write_csv(sel_bigramas %>% mutate(fuente = fuentes[fuente]), ruta_tabla("conjunto_bigramas_seleccion_fragmentos.csv"))

figura_cambios(
  sel_bigramas,
  "Pares de palabras que más ganan y más pierden peso después del choque petrolero",
  "Comunicados y minutas (solo la discusión de la Junta), 5 años antes y 5 años después del 2014-10-30.",
  paste(
    "Bigramas: dos palabras contiguas de la misma oración, las dos del vocabulario limpio (como en 04); los términos compuestos cuentan como una palabra.",
    paste0("Razón de frecuencias por 1.000 palabras, después / antes, con 0,5 apariciones sumadas a cada lado; bigramas con ", min_bigrama, " o más apariciones."),
    nota_n,
    "Lectura de robustez y fragmentos de cada bigrama en las tablas de apoyo de este script.",
    fuente_figuras, sep = "\n"),
  "conjunto_bigramas_cambio.png", height = 7
)
tabla_fragmentos(sel_bigramas, 5, "Qué dicen los bigramas que más cambian antes y después del corte",
                 "Los 5 bigramas que más ganan y los 5 que más pierden, con un fragmento de los documentos",
                 "conjunto_fragmentos_bigramas", "Bigrama")

# los mas frecuentes en cada epoca (tabla)
datos_top_bi <- cambios_bigramas %>%
  filter(escenario == "principal") %>%
  select(fuente, termino, por_mil_antes, por_mil_despues) %>%
  pivot_longer(starts_with("por_mil"), names_to = "epoca", names_prefix = "por_mil_", values_to = "por_mil") %>%
  group_by(fuente, epoca) %>% slice_max(por_mil, n = 12, with_ties = FALSE) %>% mutate(puesto = row_number()) %>% ungroup() %>%
  mutate(col = paste(fuente, epoca, sep = "_"), termino = str_replace_all(termino, "_", " ")) %>%
  select(puesto, col, termino, por_mil) %>%
  pivot_wider(names_from = col, values_from = c(termino, por_mil)) %>%
  select(puesto, termino_com_antes, por_mil_com_antes, termino_com_despues, por_mil_com_despues,
         termino_junta_antes, por_mil_junta_antes, termino_junta_despues, por_mil_junta_despues)
tabla_top_bi <- datos_top_bi %>%
  gt() %>%
  cols_label(puesto = "", termino_com_antes = "Antes", por_mil_com_antes = "Por 1.000", termino_com_despues = "Después",
             por_mil_com_despues = "Por 1.000", termino_junta_antes = "Antes", por_mil_junta_antes = "Por 1.000",
             termino_junta_despues = "Después", por_mil_junta_despues = "Por 1.000") %>%
  tab_spanner("Comunicados", columns = contains("_com_")) %>%
  tab_spanner("Minutas: discusión de la Junta", columns = contains("_junta_")) %>%
  fmt_es(names(datos_top_bi)[str_detect(names(datos_top_bi), "por_mil")], 2) %>%
  estilo_tabla(titulo = "Los bigramas más frecuentes antes y después del corte",
               subtitulo = "Los 12 pares de palabras más frecuentes en cada época, por tipo de documento",
               nota = nota_tabla("conjunto", periodo = "2009-10-30 a 2019-10-29", extra = c(
                 "Por 1.000: apariciones por cada 1.000 palabras del texto de la época. Antes: 2009-10-30 a 2014-10-29; después: 2014-10-30 a 2019-10-29.",
                 nota_n)))
guardar_tabla("conjunto_bigramas_frecuentes_epoca", tabla_top_bi, datos_top_bi, carpeta_salida)

# -----------------------------------------------------------------------------
# 3. Atencion por tema, por reunion
# -----------------------------------------------------------------------------

tema_de <- enframe(temas, name = "tema", value = "word") %>% unnest(word)
# palabras de cada tema por 1.000 palabras, en cada documento (reunion)
atencion_doc <- tokens_fuente %>%
  inner_join(tema_de, by = "word", relationship = "many-to-many") %>%
  count(fuente, id, tema) %>%
  right_join(expand_grid(palabras_doc, tema = names(temas)), by = c("fuente", "id", "tema")) %>%
  mutate(n = coalesce(n, 0L), por_mil = 1000 * n / palabras)
write_csv(atencion_doc %>% mutate(fuente = fuentes[fuente]) %>% arrange(fuente, fecha, tema),
          ruta_tabla("conjunto_temas_por_reunion.csv"))

# media por epoca con su IC 95 % y diferencia despues - antes con su IC 95 %
# (t.test de Welch, la reunion es la unidad)
comparar_temas <- atencion_doc %>%
  inner_join(docs_esc %>% select(escenario, fuente, id, epoca), by = c("fuente", "id"), relationship = "many-to-many") %>%
  group_by(escenario, fuente, tema) %>%
  summarise({
    a <- por_mil[epoca == "antes"]; d <- por_mil[epoca == "despues"]
    prueba <- t.test(d, a)
    ic_a <- t.test(a)$conf.int; ic_d <- t.test(d)$conf.int
    tibble(media_antes = mean(a), ic_antes_inf = ic_a[1], ic_antes_sup = ic_a[2],
           media_despues = mean(d), ic_despues_inf = ic_d[1], ic_despues_sup = ic_d[2],
           diferencia = mean(d) - mean(a), dif_inf = prueba$conf.int[1], dif_sup = prueba$conf.int[2],
           p_valor = prueba$p.value, reuniones_antes = length(a), reuniones_despues = length(d))
  }, .groups = "drop") %>%
  mutate(cambio_pct = 100 * diferencia / media_antes)
write_csv(comparar_temas %>% mutate(escenario = nombre_esc[escenario], fuente = fuentes[fuente]),
          ruta_tabla("conjunto_temas_antes_despues_detalle.csv"))
principal_temas <- comparar_temas %>% filter(escenario == "principal")

# (a) figura de barras antes / despues
datos_fig_temas <- principal_temas %>%
  transmute(fuente, tema, media_antes, inf_antes = ic_antes_inf, sup_antes = ic_antes_sup,
            media_despues, inf_despues = ic_despues_inf, sup_despues = ic_despues_sup) %>%
  pivot_longer(-c(fuente, tema), names_to = c(".value", "epoca"), names_sep = "_") %>%
  mutate(panel = factor(fuentes[fuente], levels = fuentes), epoca = factor(epocas[epoca], levels = epocas),
         tema = factor(tema, levels = rev(names(temas))))
fig_temas <- ggplot(datos_fig_temas, aes(media, tema, fill = fuente, alpha = epoca)) +
  geom_col(aes(group = fct_rev(epoca)), position = position_dodge(width = 0.75), width = 0.7) +
  geom_errorbar(aes(xmin = inf, xmax = sup, group = fct_rev(epoca)), position = position_dodge(width = 0.75), width = 0.25,
                color = gris_secundario, linewidth = 0.4) +
  facet_wrap(~ panel) +
  scale_fill_manual(values = color_fuente, guide = "none") +
  scale_alpha_manual(values = c("Antes" = 0.4, "Después" = 1)) +
  scale_x_continuous(labels = scales::label_number(decimal.mark = ","), expand = expansion(mult = c(0, 0.08))) +
  guides(alpha = guide_legend(override.aes = list(fill = gris_secundario))) +
  labs(title = "Atención de la Junta a cada tema antes y después del choque petrolero",
       subtitle = "Comunicados y minutas (solo la discusión de la Junta), 5 años antes y 5 años después del 2014-10-30.",
       x = "Palabras del tema por cada 1.000 palabras (media por reunión)", y = NULL,
       caption = paste(
         "Barras: media por reunión de las palabras de cada tema por 1.000 palabras; líneas: intervalo de confianza del 95 % de la media.",
         "Temas: grupos de palabras fijados a priori (00_funciones_texto.R). La diferencia y su intervalo están en la tabla de este script.",
         nota_n, fuente_figuras, sep = "\n")) +
  tema_presentacion + tema_paneles + tema_barras_h
guardar_figura("conjunto_temas_antes_despues.png", fig_temas, carpeta_salida, width = 11, height = 6.5)

# tabla: medias, diferencia e IC, y la lectura con los otros escenarios
lectura_temas <- comparar_temas %>%
  select(escenario, fuente, tema, diferencia) %>%
  pivot_wider(names_from = escenario, values_from = diferencia) %>%
  group_by(tema) %>%
  mutate(otra = rev(principal)) %>% # la otra fuente (dos filas por tema: com y junta)
  ungroup() %>%
  mutate(lectura = case_when(
    sign(otra) != sign(principal) & fuente == "junta" ~ "Posible artefacto de formato",
    sign(otra) != sign(principal) ~ "No se ve en las minutas",
    sign(completa) == sign(principal) & sign(corte_p4) == sign(principal) & sign(corte_trm) == sign(principal) ~ "Robusta",
    TRUE ~ "Matizada"))
datos_tabla_temas <- principal_temas %>%
  left_join(select(lectura_temas, fuente, tema, lectura), by = c("fuente", "tema")) %>%
  mutate(grupo = paste0(fuentes[fuente], " (", reuniones_antes, " reuniones antes y ", reuniones_despues, " después)"),
         ic = paste0("[", num_es(dif_inf, 1), "; ",
                     num_es(dif_sup, 1), "]")) %>%
  arrange(fuente, match(tema, names(temas))) %>%
  select(grupo, tema, media_antes, media_despues, diferencia, ic, cambio_pct, lectura)
tabla_temas <- datos_tabla_temas %>%
  gt(groupname_col = "grupo") %>%
  cols_label(tema = "Tema", media_antes = "Antes", media_despues = "Después", diferencia = "Diferencia",
             ic = "IC 95 %", cambio_pct = "Cambio (%)", lectura = "Lectura") %>%
  tab_spanner("Por 1.000 palabras (media por reunión)", columns = c(media_antes, media_despues, diferencia, ic)) %>%
  fmt_es(c("media_antes", "media_despues", "diferencia"), decimales$por_mil) %>%
  fmt_es("cambio_pct", 0) %>%
  tab_style(cell_text(weight = "bold"), cells_row_groups()) %>%
  estilo_tabla(titulo = "Cuánto cambió la atención a cada tema después del choque petrolero",
               subtitulo = "Media por reunión antes y después del 2014-10-30, diferencia e intervalo de confianza del 95 %",
               nota = nota_tabla("conjunto", periodo = "2009-10-30 a 2019-10-29", extra = c(
                 "Diferencia: después menos antes, en palabras del tema por 1.000 palabras; IC 95 % de la prueba t de Welch con la reunión como unidad. Cambio (%): diferencia sobre la media de antes.",
                 "Lectura: «Robusta» si el signo de la diferencia se mantiene con la muestra completa y con los cortes 2014-09-26 y 2014-12-19; «Matizada» si alguno lo cambia; «Posible artefacto de formato» si cambia en las minutas en dirección contraria a los comunicados.",
                 "Las minutas usan solo la discusión de la Junta; cambian de formato el 2014-05-30, cinco reuniones antes del corte.")))
guardar_tabla("conjunto_temas_antes_despues", tabla_temas, datos_tabla_temas, carpeta_salida)

# robustez: la diferencia con su IC en cada escenario
datos_rob_temas <- comparar_temas %>%
  mutate(valor = paste0(num_es(diferencia, 1), " [",
                        num_es(dif_inf, 1), "; ",
                        num_es(dif_sup, 1), "]"),
         grupo = fuentes[fuente]) %>%
  select(grupo, tema, escenario, valor) %>%
  pivot_wider(names_from = escenario, values_from = valor) %>%
  arrange(grupo, match(tema, names(temas)))
tabla_rob_temas <- datos_rob_temas %>%
  gt(groupname_col = "grupo") %>%
  cols_label(tema = "Tema", principal = "Principal", completa = "Muestra completa 2007–2026",
             corte_p4 = "Corte 2014-09-26", corte_trm = "Corte 2014-12-19") %>%
  tab_style(cell_text(weight = "bold"), cells_row_groups()) %>%
  estilo_tabla(titulo = "La diferencia de atención por tema en cada escenario",
               subtitulo = "Después menos antes, en palabras del tema por 1.000 palabras, con su IC 95 %",
               nota = nota_tabla("conjunto", extra = c(
                 "Principal: corte 2014-10-30 y 5 años a cada lado. Muestra completa: todas las reuniones de 2007 a 2026 con el mismo corte. Cortes alternativos: 5 años a cada lado de cada uno.",
                 "IC 95 % de la prueba t de Welch con la reunión como unidad.")))
guardar_tabla("conjunto_temas_robustez", tabla_rob_temas, datos_rob_temas, carpeta_salida)

# fragmentos de cada tema: en cada epoca y fuente, la oracion con mas palabras
# del tema (de 12 a 70 tokens)
oracion_tema <- anotados %>%
  filter(limpio, tipo == "comunicado" | es_junta) %>%
  mutate(fuente = if_else(tipo == "comunicado", "com", "junta"), oracion = paste(unidad, sentence_id, sep = "__")) %>%
  inner_join(tema_de, by = "word", relationship = "many-to-many") %>%
  count(fuente, id, oracion, tema, name = "n_tema")
datos_frag_temas <- docs_esc %>% filter(escenario == "principal") %>%
  select(fuente, id, epoca) %>%
  inner_join(oracion_tema, by = c("fuente", "id")) %>%
  inner_join(oraciones %>% filter(between(n_tok, 12, 70)) %>% select(oracion, fecha, texto_tok), by = "oracion") %>%
  group_by(fuente, tema, epoca) %>%
  arrange(desc(n_tema), fecha, .by_group = TRUE) %>% slice(1) %>% ungroup() %>%
  rowwise() %>% mutate(fragmento = texto_original(corpus$texto[corpus$id == id], texto_tok)) %>% ungroup() %>%
  transmute(tema = factor(tema, levels = names(temas)), fuente, epoca = epocas[epoca],
            documento = paste(tipo_doc[fuente], fecha), n_tema, fragmento) %>%
  arrange(tema, fuente, epoca)
write_csv(datos_frag_temas %>% mutate(fuente = fuentes[fuente]), ruta_tabla("conjunto_fragmentos_temas.csv"))
tabla_frag_temas <- datos_frag_temas %>%
  mutate(fuente = fuentes[fuente]) %>%
  gt(groupname_col = "tema") %>%
  cols_label(fuente = "Documento", epoca = "Época", documento = "Fecha", n_tema = "Palabras del tema", fragmento = "Fragmento") %>%
  cols_width(fuente ~ px(150), epoca ~ px(70), documento ~ px(130), n_tema ~ px(70), fragmento ~ px(640)) %>%
  tab_style(cell_text(size = px(12)), cells_body(columns = fragmento)) %>%
  tab_style(cell_text(weight = "bold"), cells_row_groups()) %>%
  estilo_tabla(titulo = "Qué captura cada tema: un fragmento por época y tipo de documento",
               subtitulo = "La oración con más palabras del tema en cada época, comunicados y minutas",
               nota = nota_tabla("conjunto", periodo = "2009-10-30 a 2019-10-29", extra =
                 "Oraciones de 12 a 70 palabras; empate: la más antigua. Palabras del tema: cuántas palabras del diccionario del tema tiene la oración."))
guardar_tabla("conjunto_fragmentos_temas", tabla_frag_temas, datos_frag_temas, carpeta_salida)

# (b) serie por reunion de Entorno externo e Inflacion, con Brent, TRM e
# inflacion total (ultimo dato que la Junta tenia el dia de la reunion)
temas_serie <- c("Entorno externo", "Inflación")
paneles_b <- c("Entorno externo (por 1.000 palabras)", "Inflación (por 1.000 palabras)",
               "Brent (dólares por barril)", "TRM (pesos por dólar)", "Inflación total anual (%)")
media_movil <- function(x) as.numeric(stats::filter(x, rep(1 / 5, 5), sides = 1)) # 5 reuniones, solo el pasado
serie_texto <- atencion_doc %>%
  filter(tema %in% temas_serie) %>%
  arrange(fecha) %>%
  group_by(fuente, tema) %>% mutate(movil = media_movil(por_mil)) %>% ungroup() %>%
  transmute(fecha, valor = por_mil, movil, serie = c(com = "Comunicados", junta = "Minutas")[fuente],
            panel = paneles_b[match(tema, temas_serie)])
serie_macro <- bind_rows(
  macro %>% transmute(fecha, valor = brent, serie = "Brent", panel = paneles_b[3]),
  macro %>% transmute(fecha, valor = trm, serie = "TRM", panel = paneles_b[4]),
  macro %>% transmute(fecha, valor = inflacion_total, serie = "Inflación total", panel = paneles_b[5])
) %>% filter(!is.na(valor))
serie_b <- bind_rows(serie_texto, serie_macro %>% mutate(movil = valor)) %>%
  mutate(panel = factor(panel, levels = paneles_b))
primer_panel <- list(panel = factor(paneles_b[1], levels = paneles_b))
fig_serie <- ggplot(serie_b, aes(fecha, movil, color = serie)) +
  capa_periodos(periodos, etiquetas = TRUE, panel = primer_panel) +
  capa_cortes_formato(cortes_formato) +
  capa_corte(corte_crisis, "Corte: 2014-10-30", panel = primer_panel) +
  geom_point(data = serie_texto %>% mutate(panel = factor(panel, levels = paneles_b)), aes(y = valor),
             size = 0.6, alpha = 0.35) +
  geom_line(linewidth = 0.8, na.rm = TRUE) +
  facet_wrap(~ panel, ncol = 1, scales = "free_y") +
  scale_color_manual(values = c(colores_tipo, colores_macro), breaks = names(colores_tipo)) +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y", expand = expansion(mult = 0.01)) +
  scale_y_continuous(labels = scales::label_number(decimal.mark = ",", big.mark = ".")) +
  labs(title = "Atención al entorno externo y a la inflación frente a las series macro, por reunión",
       subtitle = "Comunicados, minutas (solo la discusión de la Junta) y series macro, enero de 2007 a septiembre de 2026.",
       x = "Fecha de la reunión", y = NULL,
       caption = paste(
         "Paneles de texto: puntos = cada reunión; línea = media móvil de las últimas 5 reuniones. Paneles macro: último dato que la Junta tenía el día de la reunión (Brent del día hábil anterior, TRM del día, IPC del último mes publicado).",
         "Línea negra: corte del 2014-10-30. Líneas punteadas: cambios de formato de las minutas. Sombreado: periodos de política monetaria (P1 a P10).",
         paste0("n = ", sum(palabras_doc$fuente == "com"), " comunicados y ", sum(palabras_doc$fuente == "junta"), " minutas; ", nrow(macro), " reuniones con datos macro. La lectura es asociativa, no causal."),
         "Fuentes: comunicados y minutas de la Junta Directiva del Banco de la República; Brent: FRED (DCOILBRENTEU); TRM: Banco de la República; IPC: DANE.",
         sep = "\n")) +
  tema_presentacion + tema_paneles + theme(panel.grid.major.x = element_blank())
guardar_figura("conjunto_temas_macro_por_reunion.png", fig_serie, carpeta_salida, width = 11, height = 11)

# cronologia: cuando toca su extremo cada serie entre 2013 y 2018 (media movil
# para el texto). Sirve para leer si el texto se mueve antes, a la vez o
# despues que las series
ventana_crono <- c(as.Date("2013-01-01"), as.Date("2018-12-31"))
extremo <- function(datos, fun) datos %>% filter(between(fecha, ventana_crono[1], ventana_crono[2]), !is.na(movil)) %>% slice(fun(movil))
datos_crono <- bind_rows(
  serie_texto %>% group_by(panel, serie) %>% group_modify(~ extremo(.x, which.max)) %>% ungroup() %>%
    mutate(evento = paste0("Máximo de la atención: ", str_remove(panel, " \\(.*"), " (", serie, ")")),
  serie_macro %>% mutate(movil = valor) %>% group_by(serie) %>%
    group_modify(~ extremo(.x, if (.y$serie == "Brent") which.min else which.max)) %>% ungroup() %>%
    mutate(evento = if_else(serie == "Brent", "Mínimo del Brent", paste0("Máximo de la ", if_else(serie == "TRM", serie, str_to_lower(serie)))))
) %>%
  transmute(evento, fecha, valor = movil) %>% arrange(fecha)
tabla_crono <- datos_crono %>%
  gt() %>%
  cols_label(evento = "Evento", fecha = "Reunión", valor = "Valor") %>%
  fmt_es("valor", 1) %>%
  estilo_tabla(titulo = "En qué reunión toca su extremo cada serie, 2013 a 2018",
               subtitulo = "Atención al entorno externo y a la inflación (media móvil de 5 reuniones) frente a Brent, TRM e inflación total",
               nota = nota_tabla("conjunto", periodo = "reuniones de enero de 2013 a diciembre de 2018", extra = c(
                 "Texto: por 1.000 palabras, media de las últimas 5 reuniones. Brent en dólares por barril, TRM en pesos por dólar e inflación total en %, con el último dato que la Junta tenía el día de la reunión.",
                 "Es una cronología descriptiva: no muestra causalidad.")))
guardar_tabla("conjunto_cronologia_texto_macro", tabla_crono, datos_crono, carpeta_salida)

# -----------------------------------------------------------------------------
# 4. Correlaciones entre palabras (pairwise_cor, Lab 11)
# -----------------------------------------------------------------------------

# documento = oracion (de udpipe, la misma de los bigramas); una palabra entra
# si aparece en al menos `min_oraciones` oraciones de la epoca y fuente
# precio_petroleo se agrega como complemento: el diccionario de compuestos une
# "precio(s) del petroleo", asi que la mayoria de las menciones no quedan en "petroleo"
anclas <- c("petroleo", "precio_petroleo", "inflacion", "tasa_cambio", "tasa_intervencion", "crecimiento",
            "expectativas_inflacion", "deficit")
min_oraciones <- 10
palabras_oracion <- anotados %>%
  filter(limpio, tipo == "comunicado" | es_junta) %>%
  transmute(fuente = if_else(tipo == "comunicado", "com", "junta"), id, oracion = paste(unidad, sentence_id, sep = "__"), word) %>%
  distinct() %>%
  inner_join(docs_esc %>% filter(escenario == "principal") %>% select(fuente, id, epoca), by = c("fuente", "id"))
correlaciones <- palabras_oracion %>%
  group_by(fuente, epoca) %>%
  group_modify(~ .x %>% add_count(word, name = "n_oraciones") %>% filter(n_oraciones >= min_oraciones) %>%
                 pairwise_cor(word, oracion, sort = TRUE) %>% filter(item1 %in% anclas)) %>%
  ungroup()
presencia_anclas <- palabras_oracion %>% filter(word %in% anclas) %>% count(fuente, epoca, word, name = "oraciones")
write_csv(presencia_anclas %>% mutate(fuente = fuentes[fuente]), ruta_tabla("conjunto_anclas_oraciones.csv"))

top_cor <- correlaciones %>%
  group_by(fuente, epoca, item1) %>% slice_max(correlation, n = 8, with_ties = FALSE) %>% ungroup()
write_csv(top_cor %>% transmute(fuente = fuentes[fuente], epoca = epocas[epoca], ancla = item1, palabra = item2, correlacion = correlation),
          ruta_tabla("conjunto_correlaciones_anclas.csv"))

# fragmento por ancla y epoca: oracion con el ancla y su palabra mas correlacionada
fragmento_par <- function(f, e, a, b) {
  cand <- oraciones %>%
    filter(fuente == f, id %in% ids_epoca(f, e), str_detect(lemas, fixed(paste0(" ", a, " "))),
           str_detect(lemas, fixed(paste0(" ", b, " "))), between(n_tok, 12, 70)) %>%
    arrange(fecha) %>% slice(1)
  if (nrow(cand) == 0) return(tibble(documento = NA_character_, fragmento = NA_character_))
  tibble(documento = paste(tipo_doc[[f]], cand$fecha), fragmento = texto_original(corpus$texto[corpus$id == cand$id], cand$texto_tok))
}
frag_anclas <- top_cor %>% group_by(fuente, epoca, item1) %>% slice(1) %>% ungroup() %>%
  mutate(pmap_dfr(list(fuente, epoca, item1, item2), fragmento_par)) %>%
  transmute(fuente, epoca = epocas[epoca], ancla = item1, palabra = item2, documento, fragmento)
write_csv(frag_anclas %>% mutate(fuente = fuentes[fuente]), ruta_tabla("conjunto_fragmentos_anclas.csv"))

for (f in names(fuentes)) {
  datos_cor <- top_cor %>% filter(fuente == f) %>%
    group_by(item1, epoca) %>%
    summarise(lista = paste0(str_replace_all(item2, "_", " "), " (", num_es(correlation, 2), ")", collapse = ", "),
              palabras = list(item2), .groups = "drop") %>%
    pivot_wider(names_from = epoca, values_from = c(lista, palabras)) %>%
    right_join(tibble(item1 = anclas), by = "item1") %>%
    mutate(comunes = map2_int(palabras_antes, palabras_despues, ~ length(intersect(.x, .y))),
           ancla = str_replace_all(item1, "_", " ")) %>%
    left_join(presencia_anclas %>% filter(fuente == f) %>% pivot_wider(names_from = epoca, values_from = oraciones, names_prefix = "orac_") %>%
                select(word, starts_with("orac_")), by = c("item1" = "word")) %>%
    transmute(ancla, orac_antes, lista_antes, orac_despues, lista_despues, comunes)
  tabla_cor <- datos_cor %>%
    gt() %>%
    cols_label(ancla = "Palabra ancla", orac_antes = "Oraciones", lista_antes = "Antes: palabras más correlacionadas (phi)",
               orac_despues = "Oraciones", lista_despues = "Después: palabras más correlacionadas (phi)", comunes = "En común") %>%
    sub_missing(missing_text = "—") %>%
    cols_width(ancla ~ px(150), lista_antes ~ px(430), lista_despues ~ px(430)) %>%
    tab_style(cell_text(size = px(12.5)), cells_body(columns = c(lista_antes, lista_despues))) %>%
    estilo_tabla(titulo = "Con qué palabras aparecen las palabras ancla antes y después del corte",
                 subtitulo = paste0(fuentes[[f]], ": las 8 palabras con mayor correlación en la misma oración"),
                 nota = nota_tabla(if (f == "com") "comunicados" else "minutas", periodo = "2009-10-30 a 2019-10-29",
                                   n = n_reun(f, "antes") + n_reun(f, "despues"), extra = c(
                   paste0("Correlación phi de aparición conjunta en la misma oración (pairwise_cor, Lab 11); solo palabras en ", min_oraciones, " o más oraciones de la época. Oraciones: cuántas contienen el ancla."),
                   "En común: cuántas de las 8 palabras se repiten en las dos épocas. «—»: el ancla no llega al mínimo de oraciones en esa época.",
                   "Fragmentos de cada ancla con su palabra más correlacionada en conjunto_fragmentos_anclas.csv.")))
  guardar_tabla(paste0(c(com = "comunicados", junta = "minutas")[[f]], "_correlaciones_anclas"), tabla_cor,
                select(datos_cor, everything()), carpeta_salida)
}

# -----------------------------------------------------------------------------
# 5. Chequeos
# -----------------------------------------------------------------------------

stopifnot(
  # reuniones por epoca en el escenario principal (ver CLAUDE.md, H2)
  n_reun("com", "antes") >= 40, n_reun("com", "despues") >= 40,
  n_reun("junta", "antes") >= 40, n_reun("junta", "despues") >= 40,
  # las epocas no se solapan y respetan la ventana
  all(docs_esc$fecha[docs_esc$escenario == "principal" & docs_esc$epoca == "antes"] < corte_crisis),
  all(docs_esc$fecha[docs_esc$escenario == "principal"] >= corte_crisis - years(5)),
  all(docs_esc$fecha[docs_esc$escenario == "principal"] < corte_crisis + years(5)),
  # todas las anclas aparecen en las minutas en las dos epocas
  all(anclas %in% presencia_anclas$word[presencia_anclas$fuente == "junta" & presencia_anclas$epoca == "antes"]),
  all(anclas %in% presencia_anclas$word[presencia_anclas$fuente == "junta" & presencia_anclas$epoca == "despues"]),
  # temas sin NA, uno por documento y tema
  !anyNA(atencion_doc$por_mil), nrow(atencion_doc) == nrow(palabras_doc) * length(temas),
  !anyNA(comparar_temas$diferencia),
  # cada termino de las figuras tiene fragmento
  !anyNA(sel_palabras$fragmento), !anyNA(sel_bigramas$fragmento)
)

message("08_antes_despues: listo.")
