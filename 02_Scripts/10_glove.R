# =============================================================================
# 10. Con que palabras se usan las anclas antes y despues del choque petrolero:
#     GloVe (H3c de PLAN.md; catalogo, Lab 13)
# Taller 3 - ECON-3785
#
# Entradas: 01_Datos/02_Procesados/corpus_texto.rds,
#           01_Datos/03_Listos/tokens_anotados.rds,
#           03_Resultados/Tablas/09_antes_despues/conjunto_correlaciones_anclas.csv
# Salidas:  03_Resultados/Tablas/10_glove/
#
# Diseno (ver "Decisiones tomadas" de CLAUDE.md, 2026-11-21):
#   - GloVe y no Word2Vec: el paquete word2vec no usa la semilla de R y dos
#     corridas iguales dan vecinos distintos; GloVe (text2vec) se reproduce;
#   - un solo modelo GloVe (Lab 13) con comunicados y discusion de la Junta,
#     2007-2026; documento = oracion de udpipe con las palabras limpias (la
#     misma unidad de pairwise_cor en 09);
#   - en la ventana principal (2009-10-30 a 2019-10-29) cada ancla se reemplaza
#     por ancla_antes / ancla_despues: dos vectores en el mismo espacio, sin
#     alinear modelos;
#   - tres semillas; el coseno se promedia y se reportan los 10 vecinos del
#     promedio, cuales se repiten en las tres semillas y cuales coinciden con
#     las correlaciones phi de 09.
# La relacion texto-macro es asociativa, no causal.
# =============================================================================

# los paquetes los carga 00_main.R con pacman

source("02_Scripts/00_formato_tablas.R")
source("02_Scripts/00_funciones_texto.R")

carpeta_salida <- "10_glove"
ruta_tabla <- function(nombre) file.path("03_Resultados/Tablas", carpeta_salida, nombre)

corpus <- readRDS("01_Datos/02_Procesados/corpus_texto.rds")
anotados <- readRDS("01_Datos/03_Listos/tokens_anotados.rds")
cor_09 <- read_csv("03_Resultados/Tablas/09_antes_despues/conjunto_correlaciones_anclas.csv", show_col_types = FALSE)

# anclas de 09 con 30 o mas oraciones en cada epoca (comunicados + minutas)
anclas <- c("inflacion", "expectativas_inflacion", "crecimiento", "tasa_intervencion")
min_oraciones <- 30
semillas <- c(2026, 2027, 2028)
n_vecinos <- 10

# -----------------------------------------------------------------------------
# 1. Texto: los tokens de cada oracion en orden; en la ventana el ancla lleva su epoca
# -----------------------------------------------------------------------------

tokens <- anotados %>%
  filter(tipo == "comunicado" | es_junta) %>%
  mutate(token_id = as.integer(token_id), epoca = asignar_epoca(fecha, corte_crisis, ventana = TRUE),
         oracion = paste(unidad, sentence_id, sep = "__")) %>%
  arrange(unidad, sentence_id, token_id)

limpias <- tokens %>%
  filter(limpio) %>%
  mutate(word = if_else(word %in% anclas & !is.na(epoca), paste(word, epoca, sep = "_"), word))

claves <- paste(rep(anclas, each = 2), c("antes", "despues"), sep = "_")
oraciones_ancla <- limpias %>% filter(word %in% claves) %>% distinct(word, oracion) %>% count(word, name = "oraciones")

# -----------------------------------------------------------------------------
# 2. GloVe con tres semillas (Lab 13: ventana 5, frecuencia minima 5, rango 50)
# -----------------------------------------------------------------------------

# matriz de co-ocurrencias: la ventana no cruza oraciones
it <- itoken(split(limpias$word, limpias$oracion), progressbar = FALSE)
vocabulario <- create_vocabulary(it) %>% prune_vocabulary(term_count_min = 5)
X <- create_tcm(it, vocab_vectorizer(vocabulario), skip_grams_window = 5)

normalizar <- function(M) M / sqrt(rowSums(M^2))
entrenar <- function(semilla) {
  set.seed(semilla)   # con n_threads = 1 la estimacion se reproduce
  glove <- GlobalVectors$new(rank = 50, x_max = 10)
  W <- glove$fit_transform(X, n_iter = 50, convergence_tol = 1e-4, n_threads = 1, progressbar = FALSE)
  W <- normalizar(W + t(glove$components))   # vectores principales + de contexto, como el lab
  W %*% t(W[claves, ])   # coseno de cada palabra con cada ancla marcada
}
cosenos <- map(semillas, entrenar)
vocab <- rownames(cosenos[[1]])
cosenos <- map(cosenos, ~ .x[vocab, ])
coseno_medio <- reduce(cosenos, `+`) / length(semillas)

top <- function(S) {
  as_tibble(S, rownames = "palabra") %>%
    pivot_longer(-palabra, names_to = "clave", values_to = "coseno") %>%
    filter(!palabra %in% c(claves, anclas)) %>%   # el ancla sin marca es la misma palabra fuera de la ventana
    group_by(clave) %>% slice_max(coseno, n = n_vecinos, with_ties = FALSE) %>% ungroup()
}
vecinos <- top(coseno_medio) %>%
  mutate(ancla = str_remove(clave, "_(antes|despues)$"), epoca = str_extract(clave, "(antes|despues)$"))
# estable = esta en el top 10 de cada una de las tres semillas
por_semilla <- map(cosenos, top) %>% map(~ paste(.x$clave, .x$palabra))
vecinos <- vecinos %>%
  mutate(estable = map_lgl(paste(clave, palabra), \(k) all(map_lgl(por_semilla, ~ k %in% .x))))

# que tan parecido es el uso del ancla antes y despues (1 = mismo contexto)
coseno_epocas <- tibble(ancla = anclas, coseno_antes_despues = map_dbl(anclas, \(a)
  mean(map_dbl(cosenos, ~ .x[paste0(a, "_antes"), paste0(a, "_despues")]))))

# cruce con 09: vecinos que tambien estan entre las 8 palabras phi del ancla (cualquier fuente)
phi <- cor_09 %>%
  transmute(ancla, epoca = if_else(epoca == "Antes", "antes", "despues"), palabra, en_phi = TRUE) %>%
  distinct()
vecinos <- vecinos %>%
  left_join(phi, by = c("ancla", "epoca", "palabra")) %>%
  mutate(en_phi = coalesce(en_phi, FALSE))
write_csv(vecinos %>% select(ancla, epoca, palabra, coseno, estable, en_phi), ruta_tabla("conjunto_glove_vecinos_detalle.csv"))

# -----------------------------------------------------------------------------
# 2b. Robustez: Word2Vec skip-gram (Lab 13) con el mismo texto y las mismas anclas
# -----------------------------------------------------------------------------

# shortcut: word2vec no usa la semilla de R, asi que estas cifras cambian un poco
# entre corridas; se promedian 5 entrenamientos y se declara en la tabla
corridas_w2v <- 5
textos <- limpias %>% group_by(oracion) %>% summarise(texto = paste(word, collapse = " ")) %>% pull(texto)
cosenos_w2v <- map(seq_len(corridas_w2v), function(r) {
  # split sin "_" ni "-": el de defecto parte los compuestos y las anclas marcadas
  m <- word2vec(x = textos, type = "skip-gram", dim = 50, window = 5, iter = 20, negative = 5,
                min_count = 5, threads = 1, split = c(" \n", "\n"))
  W <- normalizar(as.matrix(m))
  W <- W[rownames(W) != "</s>", ]
  W %*% t(W[claves, ])
})
cosenos_w2v <- map(cosenos_w2v, ~ .x[rownames(cosenos_w2v[[1]]), ])
vecinos_w2v <- top(reduce(cosenos_w2v, `+`) / corridas_w2v)
por_corrida <- map(cosenos_w2v, top) %>% map(~ paste(.x$clave, .x$palabra))
vecinos_w2v <- vecinos_w2v %>%
  mutate(ancla = str_remove(clave, "_(antes|despues)$"), epoca = str_extract(clave, "(antes|despues)$"),
         corridas = map_int(paste(clave, palabra), \(k) sum(map_lgl(por_corrida, ~ k %in% .x))),
         en_glove = paste(clave, palabra) %in% paste(vecinos$clave, vecinos$palabra))
write_csv(vecinos_w2v %>% select(ancla, epoca, palabra, coseno, corridas, en_glove), ruta_tabla("conjunto_w2v_vecinos_detalle.csv"))
coseno_epocas <- coseno_epocas %>%
  mutate(coseno_w2v = map_dbl(anclas, \(a) mean(map_dbl(cosenos_w2v, ~ .x[paste0(a, "_antes"), paste0(a, "_despues")]))))

# -----------------------------------------------------------------------------
# 3. Fragmentos: oracion de la epoca con el ancla y su vecino principal
# -----------------------------------------------------------------------------

oraciones <- tokens %>%
  group_by(tipo, id, fecha, epoca, oracion) %>%
  summarise(lemas = paste0(" ", paste(word, collapse = " "), " "), texto_tok = paste(token, collapse = " "),
            n_tok = n(), .groups = "drop")
fragmento_par <- function(a, e, b) {
  cand <- oraciones %>%
    filter(epoca == e, str_detect(lemas, fixed(paste0(" ", a, " "))), str_detect(lemas, fixed(paste0(" ", b, " "))),
           between(n_tok, 12, 70)) %>%
    arrange(n_tok, fecha) %>% head(20)
  if (nrow(cand) == 0) return(tibble(documento = NA_character_, fragmento = NA_character_))
  frags <- map2_chr(cand$id, cand$texto_tok, \(i, t) texto_original(corpus$texto[corpus$id == i], t))
  # en las minutas la oracion original puede ser toda una enumeracion: se prefiere una que no quede cortada
  k <- coalesce(which(!str_ends(frags, "…"))[1], 1L)
  tibble(documento = paste(cand$tipo[k], cand$fecha[k]), fragmento = frags[k])
}
frag <- vecinos %>%
  group_by(clave) %>% slice_max(coseno, n = 1) %>% ungroup() %>%
  mutate(pmap_dfr(list(ancla, epoca, palabra), fragmento_par)) %>%
  select(ancla, epoca, palabra, documento, fragmento)
write_csv(frag, ruta_tabla("conjunto_glove_fragmentos.csv"))

# -----------------------------------------------------------------------------
# 4. Tabla para la presentacion
# -----------------------------------------------------------------------------

lista <- function(palabra, estable) paste0(str_replace_all(palabra, "_", " "), if_else(estable, "", "*"), collapse = ", ")
datos_tabla <- vecinos %>%
  arrange(clave, desc(coseno)) %>%
  group_by(ancla, epoca) %>%
  summarise(lista = lista(palabra, estable), n_phi = sum(en_phi), .groups = "drop") %>%
  pivot_wider(names_from = epoca, values_from = c(lista, n_phi)) %>%
  left_join(coseno_epocas, by = "ancla") %>%
  arrange(factor(ancla, anclas)) %>%
  transmute(ancla = str_replace_all(ancla, "_", " "), lista_antes, lista_despues,
            coseno_antes_despues, coseno_w2v, n_phi_antes, n_phi_despues)
tabla <- datos_tabla %>%
  gt() %>%
  tab_spanner(label = "10 vecinos más cercanos", columns = c(lista_antes, lista_despues)) %>%
  tab_spanner(label = "Coseno antes–después", columns = c(coseno_antes_despues, coseno_w2v)) %>%
  tab_spanner(label = "Vecinos que también aparecen en la misma oración", columns = starts_with("n_phi")) %>%
  cols_label(ancla = "Palabra ancla", lista_antes = "Antes", lista_despues = "Después",
             coseno_antes_despues = "GloVe", coseno_w2v = "Word2Vec",
             n_phi_antes = "Antes", n_phi_despues = "Después") %>%
  fmt_number(columns = c(coseno_antes_despues, coseno_w2v), decimals = 2, dec_mark = ",", sep_mark = ".") %>%
  cols_width(ancla ~ px(160), lista_antes ~ px(300), lista_despues ~ px(300),
             starts_with("coseno") ~ px(95), starts_with("n_phi") ~ px(95)) %>%
  estilo_tabla(titulo = "En qué contextos se usan las palabras ancla antes y después del corte",
               subtitulo = "Comunicados y discusión de la Junta: vecinos por coseno en un modelo GloVe",
               nota = nota_tabla("conjunto", periodo = "épocas 2009-10-30 a 2019-10-29; modelo con 2007–2026", extra = c(
    "GloVe (Lab 13): 50 dimensiones, ventana de 5 palabras, palabras con 5 o más apariciones, documento = oración; coseno promedio de tres semillas (2026, 2027 y 2028).",
    "*: el vecino no está entre los 10 primeros en alguna de las tres semillas. Coseno antes–después: parecido entre los dos vectores del ancla (1 = mismo contexto).",
    "Word2Vec (robustez): skip-gram con el mismo texto, 50 dimensiones y ventana de 5; promedio de 5 entrenamientos. El paquete no usa la semilla de R, así que esta columna varía en unos 0,01–0,03 entre corridas. Sus vecinos están en conjunto_w2v_vecinos_detalle.csv.",
    "Vecinos que también aparecen en la misma oración: cuántos de los 10 están entre las 8 palabras con mayor correlación phi con el ancla en la misma oración (09, comunicados o minutas).",
    "Fragmentos de cada ancla con su vecino principal en conjunto_glove_fragmentos.csv.")))
guardar_tabla("conjunto_glove_vecinos", tabla, datos_tabla, carpeta_salida)

# -----------------------------------------------------------------------------
# 5. Chequeos
# -----------------------------------------------------------------------------

stopifnot(
  all(claves %in% vocab),                                 # cada ancla marcada tiene vector
  nrow(oraciones_ancla) == length(claves), all(oraciones_ancla$oraciones >= min_oraciones),
  nrow(vecinos) == length(claves) * n_vecinos,
  all(between(coseno_epocas$coseno_antes_despues, -1, 1))
)

message("10_glove: listo.")
