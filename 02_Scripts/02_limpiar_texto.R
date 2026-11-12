# =============================================================================
# 02. Limpieza del texto: compuestos, lemas, palabras vacias y vocabulario
# Taller 3 - ECON-3785
#
# Entradas: 01_Datos/02_Procesados/corpus_texto.rds y secciones_minutas.rds
# Salidas:
#   01_Datos/02_Procesados/spanish-gsd-ud-2.5-191206.udpipe  modelo de udpipe
#   01_Datos/02_Procesados/anotado_udpipe.rds   anotacion (se reutiliza)
#   01_Datos/03_Listos/tokens_anotados.rds   todos los tokens en orden, con la
#       marca de si quedan en el texto limpio (lo usa 04 para los bigramas)
#   01_Datos/03_Listos/tokens_limpios.rds    una fila por token limpio
#   01_Datos/03_Listos/vocabulario_lda.rds   vocabulario recortado por tipo
#   03_Resultados/Tablas/02_limpiar_texto/
#
# Sigue la seccion 5 del catalogo, en ese orden: (1) terminos compuestos,
# (2) lemas con udpipe, (3) filtro de categorias gramaticales, (4) palabras
# vacias, (5) digitos, (6) tokens de un caracter; y reporta cuantos tokens se
# pierden en cada paso. Al final revisa los umbrales del recorte de
# vocabulario para LDA.
#
# CIFRAS: todo token con digitos se elimina. En esta sesion las cifras (tasas,
# inflacion, porcentajes) NO se extraen ni entran a ninguna medida.
#
# Se anota por seccion, para poder reportar cada medida con el texto completo
# de la minuta y solo con la discusion de la Junta sin anotar dos veces.
# =============================================================================

# los paquetes los carga 00_main.R con pacman

source("02_Scripts/00_formato_tablas.R")
source("02_Scripts/00_funciones_texto.R")

carpeta_salida <- "02_limpiar_texto"
set.seed(2026) # para la muestra de contextos de "pb"

corpus <- readRDS("01_Datos/02_Procesados/corpus_texto.rds")
secciones_min <- readRDS("01_Datos/02_Procesados/secciones_minutas.rds")

# una fila por seccion: las minutas por seccion y los comunicados enteros
unidades <- bind_rows(
  secciones_min %>% select(id, tipo, fecha, seccion, texto),
  corpus %>% filter(tipo == "comunicado") %>% transmute(id, tipo, fecha, seccion = "cuerpo", texto)
) %>%
  mutate(
    unidad = paste(id, seccion, sep = "__"),
    # la discusion de la Junta: todo menos el preambulo y el equipo tecnico
    es_junta = seccion %in% c("discusion", "decision", "cuerpo"),
    periodo = asignar_periodo(fecha)
  ) %>%
  left_join(select(corpus, id, formato), by = "id")

etiqueta_tipo <- c(comunicado = "Comunicados", minuta = "Minutas")
n_com <- n_distinct(unidades$id[unidades$tipo == "comunicado"])
n_min <- n_distinct(unidades$id[unidades$tipo == "minuta"])

# -----------------------------------------------------------------------------
# 1. Como se nombra la tasa del Banco y cuando el referente es externo
# -----------------------------------------------------------------------------

# una fila por oracion (en minusculas)
oraciones <- unidades %>%
  select(id, tipo, texto) %>%
  mutate(oracion = partir_oraciones(texto)) %>%
  select(-texto) %>%
  unnest(oracion) %>%
  mutate(oracion = str_to_lower(oracion))

familias_tasa <- c(
  "intervención («tasa de [interés de] intervención»)" = "\\btasas? de (inter[eé]s de )?intervenci[oó]n\\b",
  "política («tasa de [interés de] política [monetaria]»)" = "\\btasas? de (inter[eé]s de )?pol[ií]tica( monetaria)?\\b",
  "referencia («tasa de [interés de] referencia»)" = patron_tasa_referencia
)
variantes_tasa <- imap_dfr(familias_tasa, function(patron, familia) {
  oraciones %>%
    mutate(
      menciones = str_count(oracion, patron),
      # referente externo pegado: "tasa de politica de la Reserva Federal"
      pegado = str_count(oracion, paste0("(", patron, ")", patron_externo_pegado)),
      externo_oracion = str_detect(oracion, patron_externo)
    ) %>%
    filter(menciones > 0) %>%
    group_by(tipo) %>%
    summarise(
      familia = familia,
      # `menciones` se resume de ultimo: la linea siguiente usa el vector
      con_externo_oracion = sum(menciones[externo_oracion]),
      con_externo_pegado = sum(pegado),
      menciones = sum(menciones),
      .groups = "drop"
    )
}) %>%
  mutate(
    pct_externo_oracion = 100 * con_externo_oracion / menciones,
    pct_externo_pegado = 100 * con_externo_pegado / menciones
  )

# regla (fijada antes de ver el conteo): si menos de 10 % de las menciones de
# "tasa de referencia" esta en una oracion con un referente externo, se unen a
# tasa_intervencion las que NO tienen referente externo en la oracion; si son
# 10 % o mas, todas quedan como un token aparte (tasa_referencia)
ref <- variantes_tasa %>% filter(str_detect(familia, "^referencia")) %>%
  summarise(pct = 100 * sum(con_externo_oracion) / sum(menciones)) %>% pull(pct)
unir_referencia <- ref < 10
message("'tasa de referencia': ", round(ref, 1), " % de las menciones con referente externo en la oracion. ",
        if (unir_referencia) "Se unen a tasa_intervencion las que no lo tienen." else "Quedan como token aparte (tasa_referencia).")

datos_variantes <- variantes_tasa %>%
  transmute(tipo = etiqueta_tipo[tipo], familia, menciones, con_externo_oracion, pct_externo_oracion,
            con_externo_pegado, pct_externo_pegado) %>%
  arrange(familia, tipo)
tabla_variantes <- datos_variantes %>%
  gt(groupname_col = "familia") %>%
  cols_label(tipo = "Documento", menciones = "Menciones", con_externo_oracion = "Menciones",
             pct_externo_oracion = "%", con_externo_pegado = "Menciones", pct_externo_pegado = "%") %>%
  tab_spanner("Con referente externo en la misma oración", columns = c(con_externo_oracion, pct_externo_oracion)) %>%
  tab_spanner("Con referente externo pegado a la expresión", columns = c(con_externo_pegado, pct_externo_pegado)) %>%
  fmt_number(columns = c(menciones, con_externo_oracion, con_externo_pegado), decimals = 0, sep_mark = ".", dec_mark = ",") %>%
  fmt_number(columns = starts_with("pct"), decimals = decimales$porcentaje, dec_mark = ",", sep_mark = ".") %>%
  tab_style(cell_text(weight = "bold"), cells_row_groups()) %>%
  estilo_tabla(
    titulo = "Cómo se nombra la tasa de política y cuándo el referente es externo",
    subtitulo = "Menciones de cada forma de nombrar la tasa y cuántas aparecen junto a otro banco central",
    nota = nota_tabla("conjunto", n = n_com + n_min, extra = c(
      "Referente externo: Reserva Federal, Fed, BCE, Banco Central Europeo, Estados Unidos, EE. UU., bancos centrales, Banco de Inglaterra o Banco de Japón. «Pegado»: la expresión va seguida de «de/en» y el referente (p. ej. «tasa de política de la Reserva Federal»).",
      paste0("Regla aplicada: las menciones con referente pegado pasan a «tasa_externa». ",
             if (unir_referencia) "Las de «referencia» sin referente externo en la oración se unen a «tasa_intervencion»; las demás quedan como «tasa_referencia»."
             else "Las de «referencia» quedan como un token aparte («tasa_referencia»), porque 10 % o más aparece junto a un referente externo.")
    ))
  )
guardar_tabla("conjunto_variantes_tasa", tabla_variantes, datos_variantes, carpeta_salida)

# --- verificacion de "pb": solo palabra completa -----------------------------
# se guarda cada aparicion con su contexto para comprobar que "pb" siempre es
# "puntos basicos" (va despues de una cifra o en "(pb)")
contextos_pb <- oraciones %>%
  mutate(c = str_extract_all(oracion, ".{0,25}\\bpbs?\\b.{0,15}")) %>%
  select(id, tipo, c) %>% unnest(c) %>%
  mutate(
    tras_cifra = str_detect(c, "[0-9] ?pbs?\\b"),
    entre_parentesis = str_detect(c, "[(]pbs?[)]")
  )
message("'pb'/'pbs' como palabra completa: ", nrow(contextos_pb), " apariciones; ",
        sum(contextos_pb$tras_cifra), " despues de una cifra, ",
        sum(contextos_pb$entre_parentesis & !contextos_pb$tras_cifra), " entre parentesis y ",
        sum(!contextos_pb$tras_cifra & !contextos_pb$entre_parentesis), " en otro contexto.")
write_csv(
  bind_rows(
    contextos_pb %>% filter(!tras_cifra, !entre_parentesis),
    contextos_pb %>% filter(tras_cifra | entre_parentesis) %>% slice_sample(n = 30)
  ),
  file.path("03_Resultados/Tablas", carpeta_salida, "conjunto_contextos_pb.csv")
)

# -----------------------------------------------------------------------------
# 2. Terminos compuestos
# -----------------------------------------------------------------------------

unidades <- unidades %>% mutate(texto_compuestos = aplicar_compuestos(texto, unir_referencia))

# -----------------------------------------------------------------------------
# 3. Lemas con udpipe (modelo spanish-gsd)
# -----------------------------------------------------------------------------

carpeta_modelo <- "01_Datos/02_Procesados"
archivo_modelo <- list.files(carpeta_modelo, pattern = "^spanish-gsd.*[.]udpipe$", full.names = TRUE)
if (length(archivo_modelo) == 0) {
  options(timeout = 600) # el modelo pesa unos 28 MB
  archivo_modelo <- udpipe_download_model(language = "spanish-gsd", model_dir = carpeta_modelo)$file_model
}

# la anotacion tarda varios minutos: se reutiliza si el texto no cambio (se
# compara la longitud de cada unidad). Para regenerarla basta borrar el .rds
ruta_anotado <- "01_Datos/02_Procesados/anotado_udpipe.rds"
huella <- setNames(nchar(unidades$texto_compuestos), unidades$unidad)
anotado <- NULL
if (file.exists(ruta_anotado)) {
  guardado <- readRDS(ruta_anotado)
  if (identical(guardado$huella, huella)) anotado <- guardado$anotado
}
if (is.null(anotado)) {
  message("Anotando ", nrow(unidades), " unidades con udpipe (varios minutos)...")
  ud <- udpipe_load_model(archivo_modelo[1])
  anotado <- udpipe_annotate(ud, x = unidades$texto_compuestos, doc_id = unidades$unidad, parser = "none") %>%
    as_tibble() %>%
    select(doc_id, sentence_id, token_id, token, lemma, upos)
  saveRDS(list(huella = huella, anotado = anotado), ruta_anotado)
} else {
  message("Se reutiliza ", ruta_anotado)
}

# -----------------------------------------------------------------------------
# 4. Filtros, paso a paso
# -----------------------------------------------------------------------------

# nombres propios de los asistentes: los nombres propios que udpipe encuentra
# en el preambulo de las minutas (la lista de asistentes). Son procedimiento
nombres_asistentes <- anotado %>%
  filter(str_detect(doc_id, "__preambulo$"), upos == "PROPN", !str_detect(token, "_")) %>%
  transmute(word = sin_tilde(str_to_lower(lemma))) %>%
  count(word) %>% filter(n >= 3, nchar(word) > 2) %>% pull(word)

vacias_dom <- unique(c(vacias_dominio, vacias_dominio_ampliacion, nombres_asistentes))

tokens <- anotado %>%
  rename(unidad = doc_id) %>%
  left_join(select(unidades, unidad, id, tipo, fecha, periodo, formato, seccion, es_junta), by = "unidad") %>%
  filter(upos != "PUNCT", !is.na(upos)) %>%
  mutate(
    es_compuesto = str_detect(token, "_"),
    # los compuestos no se lematizan; el resto usa el lema. Las tildes se
    # quitan DESPUES de lematizar
    word = sin_tilde(str_to_lower(if_else(es_compuesto | is.na(lemma), token, lemma))),
    p1_categoria = upos %in% c("NOUN", "ADJ", "VERB", "PROPN") | es_compuesto,
    p2_vacias = p1_categoria & !word %in% vacias_generales,
    p3_dominio = p2_vacias & !word %in% vacias_dom,
    p4_digitos = p3_dominio & !str_detect(word, "[0-9]"),
    p5_un_caracter = p4_digitos & nchar(str_remove_all(word, "[^a-zñ]")) > 1,
    # el preambulo de las minutas (titulo, asistentes y la frase que anuncia
    # el contenido) es procedimiento: no entra a ningun analisis
    p6_preambulo = p5_un_caracter & seccion != "preambulo",
    limpio = p6_preambulo
  )

# tokens que sobreviven a cada paso, por tipo y por version del texto
contar_pasos <- function(datos, version) {
  datos %>%
    group_by(tipo) %>%
    summarise(
      `0. Tokens anotados (sin puntuación)` = n(),
      `1. Categoría gramatical: sustantivos, adjetivos, verbos, nombres propios y compuestos` = sum(p1_categoria),
      `2. Sin palabras vacías generales (español e inglés)` = sum(p2_vacias),
      `3. Sin palabras vacías de dominio ni nombres de asistentes` = sum(p3_dominio),
      `4. Sin tokens con dígitos` = sum(p4_digitos),
      `5. Sin tokens de un carácter` = sum(p5_un_caracter),
      `6. Sin el preámbulo de las minutas (asistentes)` = sum(p6_preambulo),
      .groups = "drop"
    ) %>%
    pivot_longer(-tipo, names_to = "paso", values_to = "tokens") %>%
    group_by(tipo) %>%
    mutate(perdidos = lag(tokens) - tokens, pct_del_total = 100 * tokens / first(tokens)) %>%
    ungroup() %>%
    mutate(version = version)
}
pasos <- bind_rows(
  contar_pasos(tokens, "Texto completo"),
  contar_pasos(filter(tokens, es_junta), "Solo discusión de la Junta")
) %>%
  filter(!(tipo == "comunicado" & version == "Solo discusión de la Junta")) %>%
  mutate(grupo = case_when(
    tipo == "comunicado" ~ "Comunicados",
    version == "Texto completo" ~ "Minutas, texto completo",
    TRUE ~ "Minutas, solo discusión de la Junta"
  ))

datos_pasos <- pasos %>% select(grupo, paso, tokens, perdidos, pct_del_total)
tabla_pasos <- datos_pasos %>%
  gt(groupname_col = "grupo") %>%
  cols_label(paso = "Paso de la limpieza", tokens = "Tokens que quedan", perdidos = "Tokens que se pierden",
             pct_del_total = "% de los tokens iniciales") %>%
  fmt_number(columns = c(tokens, perdidos), decimals = 0, sep_mark = ".", dec_mark = ",") %>%
  fmt_number(columns = pct_del_total, decimals = decimales$porcentaje, dec_mark = ",", sep_mark = ".") %>%
  sub_missing(missing_text = "—") %>%
  tab_style(cell_text(weight = "bold"), cells_row_groups()) %>%
  estilo_tabla(
    titulo = "Tokens que se pierden en cada paso de la limpieza",
    subtitulo = "Los términos compuestos se unen antes de anotar; después se filtra en el orden del catálogo",
    nota = nota_tabla("conjunto", n = n_com + n_min, extra = c(
      "Las cifras se eliminan con los tokens con dígitos (paso 4) y con el filtro gramatical (los números son otra categoría): en esta sesión no se extraen.",
      "Discusión de la Junta: en las minutas con secciones, «Discusión y opciones de política» y «Decisión de política»."
    ))
  )
guardar_tabla("conjunto_tokens_por_paso", tabla_pasos, datos_pasos, carpeta_salida)

limpios <- tokens %>% filter(limpio) %>%
  select(id, tipo, fecha, periodo, formato, seccion, es_junta, word)

# --- frecuencia de los compuestos ---------------------------------------------
datos_compuestos <- tokens %>%
  filter(es_compuesto) %>%
  count(word, tipo) %>%
  pivot_wider(names_from = tipo, values_from = n, values_fill = 0) %>%
  arrange(desc(minuta + comunicado))
write_csv(datos_compuestos, file.path("03_Resultados/Tablas", carpeta_salida, "conjunto_compuestos_frecuencia.csv"))

# -----------------------------------------------------------------------------
# 5. Candidatas a palabras vacias de dominio
# -----------------------------------------------------------------------------

# palabras del texto limpio (antes de la ampliacion) que estan en 90 % o mas
# de los documentos de un tipo. De estas, solo las de procedimiento o
# redaccion pasan a `vacias_dominio_ampliacion`; las de contenido se quedan
candidatas <- tokens %>%
  filter(p2_vacias, !word %in% c(vacias_dominio, nombres_asistentes), !str_detect(word, "[0-9]"), nchar(word) > 1) %>%
  distinct(tipo, id, word) %>%
  count(tipo, word, name = "docs") %>%
  mutate(pct_docs = 100 * docs / if_else(tipo == "comunicado", n_com, n_min)) %>%
  filter(pct_docs >= 90) %>%
  mutate(decision = if_else(word %in% vacias_dominio_ampliacion, "Se elimina (redacción)", "Se conserva (contenido)")) %>%
  arrange(tipo, desc(pct_docs))

datos_candidatas <- candidatas %>% transmute(tipo = etiqueta_tipo[tipo], word, docs, pct_docs, decision)
tabla_candidatas <- datos_candidatas %>%
  gt(groupname_col = "tipo") %>%
  cols_label(word = "Palabra (lema)", docs = "Documentos", pct_docs = "% de los documentos", decision = "Decisión") %>%
  fmt_number(columns = pct_docs, decimals = decimales$porcentaje, dec_mark = ",", sep_mark = ".") %>%
  tab_style(cell_text(weight = "bold"), cells_row_groups()) %>%
  estilo_tabla(
    titulo = "Palabras presentes en 90 % o más de los documentos",
    subtitulo = "Candidatas a palabras vacías de dominio: solo se eliminan las de redacción",
    nota = nota_tabla("conjunto", n = n_com + n_min, extra =
      "Criterio: una palabra se elimina solo si está en 90 % o más de los documentos de su tipo y es de procedimiento o redacción. Las de contenido económico se conservan en las frecuencias; en LDA las acota el recorte del vocabulario.")
  )
guardar_tabla("conjunto_candidatas_vacias", tabla_candidatas, datos_candidatas, carpeta_salida)

# -----------------------------------------------------------------------------
# 6. Umbrales del recorte de vocabulario (solo para LDA)
# -----------------------------------------------------------------------------

# el Lab 12 conserva las palabras en 5 o mas documentos y en no mas del 25 %
# (corpus CEPAL: miles de resumenes de temas distintos). Aqui hay unos 200
# documentos de un solo tema, asi que se compara una rejilla de umbrales
palabras_clave <- c("inflacion", "tasa_intervencion", "crecimiento", "expectativas_inflacion",
                    "meta_inflacion", "politica_monetaria", "economia", "precio", "demanda_interna",
                    "pib", "riesgo", "tasa_cambio", "credito", "petroleo", "reserva_federal")
rejilla <- expand_grid(min_docs = c(3, 5, 10), max_pct = c(25, 50, 75, 90, 100))
evaluar_umbral <- function(datos, grupo) {
  D <- n_distinct(datos$id)
  df <- datos %>% distinct(id, word) %>% count(word, name = "docs")
  total <- nrow(datos)
  pmap_dfr(rejilla, function(min_docs, max_pct) {
    voc <- df %>% filter(docs >= min_docs, docs <= max_pct / 100 * D)
    tibble(
      grupo = grupo, documentos = D, min_docs = min_docs, max_pct = max_pct,
      terminos = nrow(voc),
      pct_tokens = 100 * sum(datos$word %in% voc$word) / total,
      clave_excluidas = paste(setdiff(intersect(palabras_clave, df$word), voc$word), collapse = ", ")
    )
  })
}
umbrales <- bind_rows(
  evaluar_umbral(filter(limpios, tipo == "comunicado"), "Comunicados"),
  evaluar_umbral(filter(limpios, tipo == "minuta"), "Minutas, texto completo"),
  evaluar_umbral(filter(limpios, tipo == "minuta", es_junta), "Minutas, solo discusión de la Junta")
)
# umbrales propuestos para este corpus (ver la bitacora): 5 documentos y 75 %
umbral_min_docs <- 5
umbral_max_pct <- 75

tabla_umbrales <- umbrales %>%
  mutate(clave_excluidas = if_else(clave_excluidas == "", "ninguna", clave_excluidas)) %>%
  gt(groupname_col = "grupo") %>%
  cols_hide(documentos) %>%
  cols_label(min_docs = "Mínimo de documentos", max_pct = "Máximo (% de documentos)", terminos = "Términos del vocabulario",
             pct_tokens = "% de los tokens limpios que se conserva", clave_excluidas = "Palabras de referencia que quedan por fuera") %>%
  fmt_number(columns = terminos, decimals = 0, sep_mark = ".", dec_mark = ",") %>%
  fmt_number(columns = pct_tokens, decimals = decimales$porcentaje, dec_mark = ",", sep_mark = ".") %>%
  cols_width(clave_excluidas ~ px(420)) %>%
  tab_style(cell_text(size = px(11.5)), cells_body(columns = clave_excluidas)) %>%
  tab_style(cell_fill(color = "#f3efe4"),
            cells_body(rows = min_docs == umbral_min_docs & max_pct == umbral_max_pct)) %>%
  tab_style(cell_text(weight = "bold"), cells_row_groups()) %>%
  estilo_tabla(
    titulo = "Umbrales del recorte de vocabulario para los modelos de tópicos",
    subtitulo = "Tamaño del vocabulario según el mínimo de documentos y el máximo de documentos en que puede estar una palabra",
    nota = nota_tabla("conjunto", n = n_com + n_min, extra = c(
      "Los umbrales del laboratorio (5 documentos y 25 %) dejan por fuera el vocabulario central de la política monetaria. Fila resaltada: umbrales propuestos para este corpus.",
      paste0("Palabras de referencia: ", paste(palabras_clave, collapse = ", "), "."),
      "El recorte solo se aplica a los modelos de tópicos; las frecuencias, el TF-IDF y los bigramas usan todos los tokens limpios."
    ))
  )
guardar_tabla("conjunto_umbrales_vocabulario", tabla_umbrales, umbrales, carpeta_salida)

vocabulario <- function(datos, grupo) {
  D <- n_distinct(datos$id)
  datos %>% distinct(id, word) %>% count(word, name = "docs") %>%
    filter(docs >= umbral_min_docs, docs <= umbral_max_pct / 100 * D) %>%
    mutate(grupo = grupo)
}
vocabulario_lda <- bind_rows(
  vocabulario(filter(limpios, tipo == "comunicado"), "comunicado"),
  vocabulario(filter(limpios, tipo == "minuta"), "minuta_completo"),
  vocabulario(filter(limpios, tipo == "minuta", es_junta), "minuta_junta")
)

# -----------------------------------------------------------------------------
# 7. Guardar
# -----------------------------------------------------------------------------

saveRDS(
  tokens %>% select(unidad, id, tipo, fecha, periodo, formato, seccion, es_junta,
                    sentence_id, token_id, token, upos, word, limpio),
  "01_Datos/03_Listos/tokens_anotados.rds"
)
saveRDS(limpios, "01_Datos/03_Listos/tokens_limpios.rds")
saveRDS(vocabulario_lda, "01_Datos/03_Listos/vocabulario_lda.rds")

message("02_limpiar_texto: ", nrow(limpios), " tokens limpios (",
        n_distinct(limpios$word), " palabras distintas) en 01_Datos/03_Listos/tokens_limpios.rds")
