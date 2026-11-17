# =============================================================================
# Script maestro: ejecuta todo el pipeline del Taller 3 en una sola corrida
# Taller 3 - ECON-3785: "De que habla la Junta del Banco de la Republica?"
#
# Corre los scripts de 02_Scripts/ en el orden de su numeracion. Antes de
# ejecutarlos, (1) verifica que el directorio de trabajo es la raiz del
# proyecto, (2) instala y carga con pacman todos los paquetes del proyecto y
# (3) crea las carpetas de salida que falten. Los scripts individuales NO
# cargan paquetes ni crean carpetas: asumen que este script ya lo hizo.
#
# Para correr un script suelto (p. ej. al depurar), primero se ejecutan las
# secciones 1 a 3 de este archivo.
# =============================================================================

# -----------------------------------------------------------------------------
# 1. Verificar que el directorio de trabajo es la raiz del proyecto
# -----------------------------------------------------------------------------

# la raiz se reconoce porque tiene un archivo .Rproj (con cualquier nombre) y
# la carpeta 02_Scripts/
if (length(list.files(pattern = "[.]Rproj$")) == 0 || !dir.exists("02_Scripts")) {
  stop(
    "Este script debe ejecutarse con el directorio de trabajo en la raiz ",
    "del proyecto (donde estan el archivo .Rproj y la carpeta 02_Scripts/). ",
    "Directorio actual: ", getwd()
  )
}

# -----------------------------------------------------------------------------
# 2. Paquetes: pacman los instala si no estan y luego los carga
# -----------------------------------------------------------------------------

# lista unica de paquetes del proyecto: si un script nuevo necesita otro
# paquete, se agrega aqui (no dentro del script)
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  tidyverse,   # limpieza, manipulacion, fechas (lubridate) y graficas
  pdftools,    # pdf_text(): extraer el texto de los PDF de la Junta (ampliacion del catalogo)
  tidytext,    # unnest_tokens(), bind_tf_idf(), cast_dtm(), reorder_within()
  stopwords,   # palabras vacias en espanol (snowball) e ingles
  stringi,     # stri_trans_general(): quitar tildes
  udpipe,      # lemas y categorias gramaticales (modelo spanish-gsd)
  tm,          # clase DocumentTermMatrix, entrada de LDA
  topicmodels, # LDA()
  gt           # formato de las tablas de la presentacion (ampliacion del catalogo)
)

# -----------------------------------------------------------------------------
# 3. Verificar las carpetas de salida (una sola vez, antes de todo)
# -----------------------------------------------------------------------------

# si un script nuevo escribe en otra carpeta, se agrega a esta lista.
# 01_Datos/01_Crudos/ no va aqui: no es una salida y nunca se escribe en ella
carpetas_salida <- c(
  "01_Datos/02_Procesados", "01_Datos/03_Listos",
  "03_Resultados/Tablas", "03_Resultados/Figuras",
  # una subcarpeta por script que genera tablas o figuras (nombre del script)
  "03_Resultados/Tablas/01_extraer_texto",
  "03_Resultados/Figuras/01_extraer_texto",
  "03_Resultados/Tablas/02_limpiar_texto",
  "03_Resultados/Tablas/03_frecuencias_tfidf",
  "03_Resultados/Figuras/03_frecuencias_tfidf",
  "03_Resultados/Tablas/04_bigramas",
  "03_Resultados/Figuras/04_bigramas",
  "03_Resultados/Tablas/05_lda_exploratorio",
  "03_Resultados/Figuras/05_lda_exploratorio"
)
for (carpeta in carpetas_salida) {
  if (!dir.exists(carpeta)) dir.create(carpeta, recursive = TRUE)
}

# -----------------------------------------------------------------------------
# 4. Orden de ejecucion de los scripts (segun su numeracion)
# -----------------------------------------------------------------------------

scripts <- c(
  "02_Scripts/01_extraer_texto.R",
  "02_Scripts/02_limpiar_texto.R",
  "02_Scripts/03_frecuencias_tfidf.R",
  "02_Scripts/04_bigramas.R",
  "02_Scripts/05_lda_exploratorio.R"
)

# nota: los scripts '00_formato_graficas.R', '00_formato_tablas.R' y
# '00_funciones_texto.R' no aparecen en esta lista porque no producen
# resultados por si mismos; los cargan con source() los scripts que los usan

# -----------------------------------------------------------------------------
# 5. Ejecutar cada script en su propio entorno, en orden
# -----------------------------------------------------------------------------

tiempos <- numeric(0)
for (script in scripts) {
  mensaje <- paste0("Ejecutando: ", script)
  message(strrep("=", nchar(mensaje)))
  message(mensaje)
  message(strrep("=", nchar(mensaje)))

  inicio <- Sys.time()
  source(script, local = new.env(), encoding = "UTF-8")
  tiempos[script] <- as.numeric(difftime(Sys.time(), inicio, units = "secs"))
  message("Tiempo: ", round(tiempos[script]), " segundos")
}

message("Pipeline completo: los ", length(scripts),
        " scripts se ejecutaron sin errores en ",
        round(sum(tiempos) / 60, 1), " minutos.")
