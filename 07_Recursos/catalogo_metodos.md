# Catálogo de métodos, librerías y funciones del Taller 3

Este documento fija **qué métodos de texto como datos se pueden usar en el
Taller 3 y con qué paquetes y funciones de R se aplican**. Se armó revisando los
Laboratorios 11, 12 y 13 del curso (ECON-3785, 2026-2), que trabajan con los
resúmenes de la Revista CEPAL (`Laboratorios/Laboratorio 11/Laboratorio_11/02_Scripts/`,
`Laboratorios/Laboratorio 12/Laboratorio_12/02_Scripts/` y
`Laboratorios/Laboratorio 13/Laboratorio_13/02_Scripts/`; el Lab 13 se agregó
el 2026-11-21). Es la referencia obligatoria para escribir cualquier script de
análisis de este repositorio.

**Reglas de uso**

1. El trabajo del taller se limita a los métodos, paquetes y funciones de este
   catálogo. Si un método no aparece aquí, no se usa.
2. Si el equipo decide agregar un método, paquete o función que no está aquí
   (incluidas las de "Herramientas previstas"), **antes de usarlo** se
   documenta en ["Registro de ampliaciones"](#registro-de-ampliaciones) (qué se
   agrega, para qué, de dónde sale y quién lo aprobó) y se registra en
   "Decisiones tomadas" de `CLAUDE.md`.
3. Todos los paquetes se cargan **solo** en el `pacman::p_load()` de
   `00_main.R` (ver `CLAUDE.md`). Los laboratorios cargan paquetes en cada
   script; en el taller no se copia esa práctica.

---

## Resumen

| Método | Lab | Paquete | Funciones principales | Decisiones a fijar | Uso posible en el taller |
| --- | --- | --- | --- | --- | --- |
| Tokenización y conteo | 11 | `tidytext`, `dplyr` | `unnest_tokens()`, `count()` | Unidad de documento (comunicado, minuta, párrafo) | Base de todo lo demás |
| Ley de Zipf | 11 | `ggplot2` | `count()`, `row_number()`, `scale_*_log10()` | — | Diagnóstico del corpus (anexo) |
| Palabras vacías y normalización | 11, 12 | `stopwords`, `stringi` | `stopwords("es", source = "snowball")`, `stopwords("en")`, `stri_trans_general(x, "Latin-ASCII")`, `anti_join()` | Lista de palabras vacías de dominio | Limpieza |
| Raíces (*stemming*) | 11 | `SnowballC` | `wordStem(word, language = "spanish")` | Raíz frente a lema | Exploración; el Lab 12 lo reemplaza por lemas |
| Términos compuestos (diccionario) | 12 | `stringr` | `str_replace_all()` con patrones `\\b...\\b` tolerantes a tildes | Diccionario propio del dominio | Unir "tasa de intervención", "meta de inflación", etc. |
| Lematización y filtro por categoría gramatical | 12 | `udpipe` | `udpipe_download_model()`, `udpipe_load_model()`, `udpipe_annotate()` | Categorías que se conservan (`upos`) | Limpieza previa a la DTM y a LDA |
| Palabras más frecuentes por grupo | 11 | `tidytext` | `count()`, `slice_max()`, `reorder_within()`, `scale_y_reordered()` | Agrupación (año, época, tipo de documento) | Descriptiva |
| TF-IDF | 11 | `tidytext` | `bind_tf_idf(word, grupo, n)` | Qué es el "documento" (grupo); frecuencia mínima | Palabras distintivas por época o por tipo de documento |
| Matriz documento-término (DTM) | 11, 12 | `tidytext`, `tm` | `cast_dtm()`, `tidy()` | Recorte del vocabulario por frecuencia de documento | Entrada de LDA |
| Bigramas | 11 | `tidytext`, `tidyr` | `unnest_tokens(..., token = "ngrams", n = 2)`, `separate()`, `unite()` | Filtrar con el vocabulario limpio | Expresiones frecuentes por época |
| Correlación entre palabras | 11 | `widyr` | `pairwise_cor(word, id)` | Mínimo de documentos por palabra | Con qué palabras aparece "inflación" |
| LDA (modelo de tópicos) | 12 | `topicmodels` | `LDA()` (VEM y Gibbs), `posterior()`, `tidy(matrix = "beta"/"gamma")` | K, α, δ, iteraciones, semilla | Atención de la Junta a cada tema en el tiempo |
| Lift de palabras por tópico | 12 | — | `beta / xbar` | Frecuencia mínima en el corpus | Nombrar los tópicos |
| Selección de hiperparámetros de LDA | 12 | `topicmodels` | perplejidad por *document completion* con CV, coherencia UMass | Rejilla de K × α × δ, número de pliegues | Elegir K, α, δ con criterio fuera de muestra |
| Validación de tópicos | 12 | — | documentos más representativos, cruce con etiquetas externas | Qué etiqueta externa | Sustentar el nombre de cada tópico con ejemplos (lo exige el enunciado) |
| Agregación de tópicos en el tiempo | 12 | `dplyr`, `ggplot2` | promedio de `gamma` por periodo, `geom_area()` / `geom_col()` | Periodo de agregación | Serie de atención por tema, para cruzar con las series macro |
| Word2Vec (skip-gram con muestreo negativo) | 13 | `word2vec` | `word2vec()`, `as.matrix()`, `predict(type = "nearest")` | Unidad de texto (ventana sin cruzar documentos), `dim`, `window`, `iter`, `negative`, `min_count` | Vecinos de las anclas antes y después del corte (H3c) |
| GloVe | 13 | `text2vec`, `Matrix` | `itoken()`, `create_vocabulary()`, `prune_vocabulary()`, `vocab_vectorizer()`, `create_tcm()`, `GlobalVectors$new()`, `fit_transform()` | Ventana, frecuencia mínima, `rank`, `x_max`, iteraciones | Alternativa o contraste de Word2Vec |
| Vecinos por coseno y analogías | 13 | `text2vec` | `sim2(method = "cosine", norm = "l2")` | Número de vecinos | Qué palabras se usan en contextos parecidos a un ancla |
| Vectores preentrenados (fastText `cc.es.300`) | 13 | `readr` | `read_csv()` de la matriz recortada | — | Solo como referencia: el archivo del lab está recortado al vocabulario CEPAL |
| Espacio de palabras en 3D | 13 | `stats`, `plotly` | `prcomp()`, `plot_ly(type = "scatter3d")` | Palabras y campos temáticos que se grafican | Exploración (interactivo; no sale como `.png` para el deck) |
| Temas como regiones del espacio y embeddings de documento | 13 | `stats` | `kmeans()` sobre vectores normalizados; promedio de vectores por documento (`colMeans()`) | Número de grupos, palabras frecuentes | Agrupar palabras o documentos por cercanía semántica |

---

## Convenciones comunes

- **Semilla:** el proyecto usa `2026`. Los laboratorios usan `20261028`; **no se
  copia**. En `topicmodels`, `set.seed()` no basta: la semilla va en
  `control = list(seed = 2026)`. Para la partición de pliegues y la división de
  palabras en mitades se usa `set.seed(2026)` justo antes.
- **Normalización de tildes:** función de los dos laboratorios, definida una
  sola vez (p. ej. en un script auxiliar) y reutilizada:

  ```r
  sin_tilde <- function(x) stringi::stri_trans_general(x, "Latin-ASCII")
  ```

  En el Lab 12 el orden importa: **primero se lematiza y después se quitan las
  tildes**, porque `udpipe` necesita el texto original para reconocer las
  palabras.
- **Palabras vacías:** las de *snowball* en español más las de inglés, sin
  tildes. A esto se suman listas propias (palabras de redacción genérica,
  nombres de meses, numerales romanos) que **se documentan en el script** y se
  registran en la bitácora: cambian los resultados.
- **Números:** los laboratorios eliminan todo token con dígitos
  (`!str_detect(word, "[0-9]")`). En los documentos de la Junta las cifras son
  contenido (tasas, inflación); si se eliminan, se dice explícitamente y se
  considera extraerlas aparte.
- **Gráficas:** los laboratorios usan `theme_classic()` y el color `#5D878E`.
  En el taller se usa el formato propio de `02_Scripts/00_formato_graficas.R`
  (ver `CLAUDE.md`); de los laboratorios se toma la construcción de cada
  figura, no el estilo.
- **Datos y rutas:** los laboratorios leen desde URL del repositorio del curso.
  En el taller todo se lee de `01_Datos/` con rutas relativas.

---

## 1. Tokenización, Zipf y limpieza (Lab 11, `02_tokens.R`)

**Qué hace.** Convierte cada texto en una fila por palabra y examina la
distribución de frecuencias antes y después de limpiar.

```r
tokens <- corpus %>%
  select(id, fecha, texto) %>%
  unnest_tokens(word, texto)          # minúsculas y sin puntuación por defecto

vacias <- tibble(word = sin_tilde(c(stopwords::stopwords("es", source = "snowball"),
                                    stopwords::stopwords("en"))))

limpios <- tokens %>%
  mutate(word = sin_tilde(word)) %>%
  anti_join(vacias, by = "word") %>%
  filter(!str_detect(word, "[0-9]")) %>%
  anti_join(dominio, by = "word")     # lista propia de palabras genéricas
```

- **Zipf:** `count(word, sort = TRUE)`, rango con `row_number()`, frecuencia
  relativa `n / sum(n)`, y gráfica log-log. Muestra que pocas palabras
  (casi todas vacías) concentran la mayoría de las apariciones: justifica la
  limpieza.
- **Diagnóstico de tildes:** el lab compara "países" frente a "paises" por
  década para mostrar que la misma palabra aparece escrita de dos formas.
- **Raíces:** `SnowballC::wordStem(word, language = "spanish")` agrupa
  variantes ("económico", "económica", "economía" → "econom"). El lab compara
  palabras distintas frente a raíces distintas. Es exploratorio: el Lab 12 usa
  lemas, que son legibles y no mezclan palabras distintas con la misma raíz.

## 2. Frecuencias y TF-IDF por grupo (Lab 11, `03_frecuencias.R`, `04_tfidf.R`)

- **Frecuencias por grupo:** `count(grupo, word)`, `slice_max(n, n = 8,
  with_ties = FALSE)` por grupo y barras con `reorder_within()` +
  `scale_y_reordered()` para ordenar dentro de cada panel.
- **TF-IDF:** `count(grupo, word) %>% bind_tf_idf(word, grupo, n)`. El
  "documento" del TF-IDF es el **grupo** (en el lab, la década), no el
  artículo:
  - `tf` = apariciones de la palabra en el grupo / palabras del grupo;
  - `idf` = log(número de grupos / grupos en que aparece la palabra);
  - `tf_idf = tf × idf`: alto para palabras frecuentes en un grupo y raras en
    los demás. Una palabra presente en todos los grupos tiene `idf = 0`.
  - El lab muestra que sin filtro dominan palabras rarísimas y por eso filtra
    `n >= 8` apariciones en el grupo antes de graficar.
- **En el taller:** grupos naturales son épocas de política monetaria, años o
  comunicados frente a minutas. Con pocos grupos, el `idf` toma pocos valores;
  declarar cuántos grupos hay.

## 3. Matriz documento-término (Labs 11 y 12, `05_dtm.R`, `01_limpieza.R`)

```r
dtm <- limpios %>%
  count(id, word) %>%
  cast_dtm(id, word, n)               # objeto DocumentTermMatrix de tm
```

- **Recorte del vocabulario (Lab 12):** se conservan las palabras que están en
  **5 o más documentos** y en **no más del 25 %** de ellos:

  ```r
  D <- n_distinct(lemas$id)
  vocabulario <- lemas %>%
    distinct(id, word) %>%
    count(word, name = "docs") %>%
    filter(docs >= 5, docs <= 0.25 * D)
  ```

  Las raras no aportan a los tópicos y las que están en casi todos los
  documentos no los distinguen. Los umbrales (5 y 25 %) son del corpus CEPAL
  (miles de resúmenes); con 394 documentos de la Junta hay que revisarlos y
  registrarlos.
- `tidy(dtm)` devuelve la DTM a formato largo (documento, término, conteo).

## 4. Bigramas y correlación entre palabras (Lab 11, `06_bigramas.R`)

- **Bigramas:** `unnest_tokens(bigrama, texto, token = "ngrams", n = 2)`,
  `separate(bigrama, into = c("palabra1", "palabra2"), sep = " ")` y se
  conservan solo los pares cuyas dos palabras están en el vocabulario limpio
  (así se descartan pares con palabras vacías). Conteo por grupo con
  `slice_max(n, n = 5)`. Sirve también para descubrir términos compuestos que
  conviene agregar al diccionario de la sección 5.
- **Correlación entre palabras:** coeficiente phi de aparición conjunta en los
  mismos documentos:

  ```r
  correlaciones <- limpios %>%
    distinct(id, word) %>%
    add_count(word) %>%
    filter(n >= 30) %>%               # palabras en al menos 30 documentos
    pairwise_cor(word, id, sort = TRUE)
  ```

  El lab la usa para ver con qué palabras aparece "inflacion". El script carga
  `igraph` y `ggraph` para una red de co-ocurrencias, pero no llega a
  dibujarla: la red **no** está cubierta (ver "Herramientas previstas").

## 5. Limpieza para modelos de tópicos (Lab 12, `01_limpieza.R`)

Es la limpieza completa que alimenta LDA, en este orden:

1. **Términos compuestos con un diccionario**, de la expresión más larga a la
   más corta (para que "tipo de cambio real" se reemplace antes que "tipo de
   cambio"). Cada vocal del patrón acepta tilde, y `\\b` evita reemplazar
   pedazos de palabras:

   ```r
   con_tildes <- function(x) {
     x %>%
       str_replace_all(c("a" = "[aá]", "e" = "[eé]", "i" = "[ií]", "o" = "[oó]", "u" = "[uú]")) %>%
       paste0("\\b", ., "\\b")
   }
   patrones <- setNames(terminos, con_tildes(names(terminos)))
   texto <- corpus %>% transmute(id, texto = str_replace_all(str_to_lower(texto), patrones))
   ```

   El diccionario del lab ya trae términos útiles aquí ("politica monetaria",
   "tipo de cambio", "producto interno bruto" → "pib", "estados unidos",
   "corto/mediano/largo plazo", "covid"). Para la Junta hay que agregar los
   propios (p. ej. "tasa de interés de intervención", "junta directiva",
   "meta de inflación", "inflación básica", "expectativas de inflación",
   "brecha del producto", "reserva federal").
2. **Lemas con `udpipe`** (modelo `spanish-gsd`, ~28 MB; el lab sube
   `options(timeout = 600)` para descargarlo):

   ```r
   ud <- udpipe_load_model(archivo_modelo)
   anotado <- udpipe_annotate(ud, x = texto$texto, doc_id = texto$id, parser = "none") %>%
     as_tibble()
   lemas <- anotado %>%
     filter(upos %in% c("NOUN", "ADJ", "VERB", "PROPN") | str_detect(token, "_")) %>%
     transmute(id = doc_id,
               word = sin_tilde(str_to_lower(if_else(str_detect(token, "_"), token, lemma))))
   ```

   Se conservan sustantivos, adjetivos, verbos y nombres propios; los
   compuestos (con guion bajo) no se lematizan. Luego palabras vacías, dígitos
   y tokens de un carácter.
3. **Exclusiones elegidas:** una lista de redacción genérica (verbos de
   artículo académico, meses, numerales) y otra de referencias geográficas. En
   la Junta la lista genérica será distinta (p. ej. "junta", "banco",
   "directiva", "reunion", "miembro", "decision" si aparecen en todos los
   documentos); se arma mirando las frecuencias y se documenta.
4. **Recorte del vocabulario y DTM** (sección 3).

## 6. LDA (Lab 12, `03_lda_default.R`, `05_lda.R`)

**Qué estima.** Cada documento es una mezcla de K tópicos (θ, `gamma`) y cada
tópico es una distribución sobre el vocabulario (φ, `beta`).

```r
# versión por defecto (VEM): solo K y la semilla
lda_default <- LDA(dtm, k = 4, control = list(seed = 2026))

# versión final del lab (Gibbs), con hiperparámetros elegidos en la sección 7
lda <- LDA(dtm, k = 12, method = "Gibbs",
           control = list(alpha = 0.1, delta = 1, iter = 1000, burnin = 200, seed = 2026))

theta <- posterior(lda)$topics             # documentos × tópicos
beta  <- tidy(lda, matrix = "beta")        # tópico, término, probabilidad (φ)
gamma <- tidy(lda, matrix = "gamma")       # documento, tópico, peso (θ)
```

- `alpha` controla cuán concentrada es la mezcla de tópicos de cada documento
  (pequeño: pocos tópicos por documento); `delta` (β en la notación de clase)
  controla cuán concentrada es cada distribución de palabras.
- **Lift**, para nombrar tópicos sin que dominen las palabras frecuentes en
  todo el corpus:

  ```r
  frecuencia <- tibble(term = colnames(dtm), total = colSums(as.matrix(dtm))) %>%
    mutate(xbar = total / sum(total))
  beta <- beta %>% left_join(frecuencia, by = "term") %>% mutate(lift = beta / xbar)
  ```

  `lift` = probabilidad de la palabra en el tópico / frecuencia en el corpus.
  Se grafica el top 8 de lift por tópico filtrando `total >= 30` (si no,
  dominan palabras rarísimas), junto con el top 6 por `beta` (las más
  probables).
- **Tópico principal de cada documento:** `slice_max(gamma, n = 1)` por
  documento.

## 7. Selección de hiperparámetros (Lab 12, `04_hiperparametros.R`)

Dos criterios que se miran juntos:

1. **Perplejidad por *document completion* con validación cruzada (3
   pliegues).** Para cada pliegue: se estima LDA con los otros dos; en cada
   documento de prueba se parten sus palabras al azar en dos mitades, se
   estima θ con la mitad A (`posterior(modelo, newdata = A)`) y se evalúa la
   probabilidad de la mitad B con θ·φ. Perplejidad = `exp(-Σ log p / N)`
   (menor es mejor). Rejilla del lab: K ∈ {4, 8, 12, 16, 20, 30} × α ∈ {0.1,
   0.5, 1} × δ ∈ {0.01, 0.1, 1}, Gibbs con 300 iteraciones. Se reporta, para
   cada K, el mejor par (α, δ) y el costo porcentual frente al mínimo global.
2. **Coherencia UMass** de las 10 palabras principales de cada tópico:
   Σ log((D(wᵢ, wⱼ) + 1) / D(wᵢ)), con D el número de documentos donde
   aparecen; más cercana a cero es más coherente. Se complementa con el **peso
   principal** (mediana del máximo de θ por documento: cuán concentrados
   quedan los documentos).

El lab no elige K por perplejidad mínima: fija K = 12 por el balance entre
perplejidad, coherencia e interpretabilidad, y después compara (α, δ) con K
fijo. En el taller, la regla de elección se declara **antes** de ver los
tópicos y se registra en "Decisiones tomadas". Las funciones `partir_mitades()`,
`perplejidad()` y `coherencia()` del lab se reutilizan tal cual (con la
semilla del proyecto). Ojo con el costo: la rejilla completa son 162 ajustes.

## 8. Validación e interpretación de tópicos (Lab 12, `05_lda.R`)

- **Nombrar cada tópico** con sus palabras de mayor lift y mayor probabilidad.
- **Leer los documentos más representativos:** `gamma %>% filter(topic == k)
  %>% slice_max(gamma, n = 5)` con su fecha y título. En el taller, esto da los
  ejemplos textuales que exige el enunciado.
- **Validación externa:** el lab compara el tópico principal de cada artículo
  con las etiquetas temáticas del repositorio (proporción de artículos con
  etiqueta "pobreza" dentro del tópico frente al resto). En la Junta no hay
  etiquetas, pero hay análogos: si el tópico de inflación pesa más en reuniones
  con inflación sobre la meta, o el de tasa de cambio en episodios de
  depreciación; o si el tópico coincide con la decisión anunciada.

## 9. Tópicos en el tiempo (Lab 12, `06_decadas.R`)

```r
por_periodo <- gamma %>%
  left_join(select(corpus, id, periodo), by = c("document" = "id")) %>%
  group_by(periodo, topic) %>%
  summarise(theta = mean(gamma), .groups = "drop")
```

Se grafica en paneles por tópico (`geom_col`) o como área apilada
(`geom_area(position = position_stack(reverse = TRUE))`) con los tópicos
ordenados por el periodo en que alcanzan su pico. En el taller, esta serie de
atención por tópico (por reunión, trimestre o año) es la que se cruza con las
series macroeconómicas.

## 10. Datos para embeddings (Lab 13, `01_datos.R`)

Reutiliza la limpieza del Lab 11 (palabras vacías de *snowball* en español e
inglés sin tildes, sin dígitos, lista de dominio). Dos detalles:

- **El orden de las palabras importa.** A diferencia de la DTM, los embeddings
  usan la secuencia: los tokens limpios se guardan en el orden del texto, con
  el `id` del documento.
- **Revisar la lista de palabras vacías con el método.** El lab saca "estado" y
  "estados" de las vacías porque en los resúmenes de la CEPAL son contenido
  (el Estado), no relleno. En el taller se hace la misma revisión con las
  anclas (p. ej. que ninguna ancla esté en la lista de vacías o de dominio).

## 11. Word2Vec (Lab 13, `02_word2vec.R`)

**Qué estima.** Un vector de `dim` números por palabra, entrenado para que el
vector de una palabra prediga las palabras de su ventana (*skip-gram*). Dos
palabras quedan cerca si aparecen en contextos parecidos, aunque nunca estén
juntas en la misma oración (similitud de segundo orden; `pairwise_cor()` solo
ve la aparición conjunta).

```r
# una cadena por documento: la ventana no cruza documentos
textos <- tokens %>%
  group_by(id) %>%
  summarise(texto = paste(word, collapse = " ")) %>%
  pull(texto)

set.seed(2026)
modelo_w2v <- word2vec(x = textos, type = "skip-gram", dim = 50, window = 5,
                       iter = 20, negative = 5, min_count = 5, threads = 1)

Wv <- as.matrix(modelo_w2v)
Wv <- Wv[rownames(Wv) != "</s>", ]   # token de fin de documento
predict(modelo_w2v, c("inflacion"), type = "nearest", top_n = 8)
```

- Especificación del lab: `dim = 50`, `window = 5`, `iter = 20`,
  `negative = 5`, `min_count = 5`. Con el corpus de la Junta (unas 177 mil
  palabras limpias en total) hay que revisarla y registrarla.
- **Semilla:** `word2vec()` no tiene argumento de semilla. El lab usa
  `set.seed()` antes de entrenar y `threads = 1`; con más de un hilo el
  resultado no se puede reproducir. En el taller: `set.seed(2026)` y
  `threads = 1` (el lab usa `123`; **no se copia**).
- `min_count` deja fuera del modelo las palabras con menos apariciones: una
  palabra rara no tiene vector.

## 12. GloVe (Lab 13, `03_glove.R`)

**Qué estima.** Vectores que reproducen el logaritmo de la matriz de
co-ocurrencias (cuántas veces dos palabras aparecen a menos de `window`
palabras una de otra).

```r
it <- itoken(split(tokens$word, tokens$id), progressbar = FALSE)  # tokens en orden, por documento
vocabulario <- create_vocabulary(it) %>% prune_vocabulary(term_count_min = 5)
X <- create_tcm(it, vocab_vectorizer(vocabulario), skip_grams_window = 5)

set.seed(2026)
glove <- GlobalVectors$new(rank = 50, x_max = 10)
W <- glove$fit_transform(X, n_iter = 50, convergence_tol = 1e-4, n_threads = 4)
W <- W + t(glove$components)         # vectores principales + de contexto
```

- El lab mide qué tan dispersa es la matriz (`nnzero()` de `Matrix`):
  `100 * (1 - nnzero(X) / prod(dim(X)))` % de ceros.
- El lab usa `n_threads = 4`; para reproducir los resultados conviene
  `n_threads = 1`.

## 13. Vecinos, analogías y vectores preentrenados (Lab 13, `04_vecinos.R`, `05_preentrenados.R`)

Funciones del lab, que se reutilizan tal cual con cualquier matriz de vectores
(filas = palabras):

```r
vecinos <- function(W, palabra, n = 8) {
  s <- sim2(W, W[palabra, , drop = FALSE], method = "cosine", norm = "l2")[, 1]
  s <- s[names(s) != palabra]
  round(head(sort(s, decreasing = TRUE), n), 2)
}

analogia <- function(W, a, b, c, n = 5) {   # a - b + c
  v <- W[a, ] - W[b, ] + W[c, ]
  s <- sim2(W, matrix(v, nrow = 1), method = "cosine", norm = "l2")[, 1]
  s <- s[!names(s) %in% c(a, b, c)]
  round(head(sort(s, decreasing = TRUE), n), 2)
}
```

- El lab compara los vecinos de una misma palabra con GloVe y con Word2Vec
  (`comparar()`): si los dos métodos coinciden, el vecino es más confiable.
- **Vectores preentrenados:** fastText en español (`cc.es.300`, Grave et al.
  2018), que el lab lee de un `.csv` **recortado al vocabulario de la CEPAL**.
  Muestran vecinos de "sentido común" del español general, no del corpus. Para
  usarlos con el vocabulario de la Junta habría que descargar el archivo
  completo (varios GB), lo que se registraría como ampliación.
- Los vecinos son una medida de texto: en el taller se validan con fragmentos
  de los documentos (lo exige el enunciado).

## 14. El espacio y los temas como regiones (Lab 13, `06_espacio.R`, `08_de_que_habla.R`)

- **Espacio en 3D:** `prcomp()` sobre los vectores de las palabras frecuentes
  más unos campos temáticos definidos a mano, y `plot_ly(..., type =
  "scatter3d")` con las palabras de fuera de los campos en gris. Reporta el %
  de varianza de los tres primeros componentes. Es interactivo: sirve para
  explorar, no para una figura del deck.
- **Temas como regiones:** `kmeans()` (`nstart = 25`, semilla antes) sobre los
  vectores **normalizados** (`M / sqrt(rowSums(M^2))`) de las palabras con 30 o
  más apariciones; cada grupo se describe con sus palabras más frecuentes.
- **Embeddings de documento:** el vector de un documento es el promedio de los
  vectores de sus palabras (`colMeans()`); se normalizan, se agrupan con
  `kmeans()` y cada grupo se lee con los documentos más cercanos a su centro
  (coseno con el centroide). El lab grafica el % de documentos de cada grupo
  por década: es el análogo de "tópicos en el tiempo" (sección 9) con
  embeddings.
- El lab no tiene `07_*.R`: `08_de_que_habla.R` lee `puntos_3d.rds`, que
  genera `06_espacio.R`.

---

## Herramientas previstas, no cubiertas en los laboratorios

Hacen falta en el taller y no se vieron en los Labs 11–13. Cada una se registra
en ["Registro de ampliaciones"](#registro-de-ampliaciones) antes de usarse.

| Herramienta | Por qué hace falta | Estado |
| --- | --- | --- |
| Extracción de texto de PDF (`pdftools::pdf_text()`) | Los documentos de la Junta vienen en PDF; los laboratorios partían de un `.csv` ya con texto | Registrada el 2026-11-10 |
| Descarga y manejo de series macro (lectura de `.xlsx`/`.csv` con `readxl`/`readr`; fechas con `lubridate`) | El enunciado exige complementar con series macroeconómicas | Registrada el 2026-11-18 (`readxl`; `readr` y `lubridate` ya vienen con `tidyverse`) |
| Relación medida de texto – variable macro (regresión lineal, `lm`/`fixest`, de laboratorios anteriores; ver catálogo del Taller 2) | Cuantificar cómo se asocia la atención a un tema con el contexto macro | Pendiente de decidir |
| Diccionarios de tono (p. ej. palabras *hawkish*/*dovish*) | Medir la orientación de la política, no solo el tema | Pendiente de decidir; no se vio en clase |
| Red de co-ocurrencias (`igraph`, `ggraph`) | Visualizar `pairwise_cor()`; el Lab 11 carga los paquetes pero no la dibuja | Pendiente de decidir |
| Embeddings de palabras (GloVe o Word2Vec) | Pregunta del equipo (2026-11-18): comparar de qué se hablaba antes y después de la crisis del petróleo de 2014 y cómo cambian las prioridades de la Junta | **Cubiertos en el Lab 13 (2026-11-21)**: pasan al catálogo (secciones 10 a 14) y no requieren ampliación. Su especificación en el taller (anclas por época, dimensión, ventana) se registra en "Decisiones tomadas" |

## Fuera del catálogo

No se usan, salvo que se registren como ampliación: alineación de espacios de
embeddings estimados por separado (p. ej. Procrustes), vectores preentrenados
completos (el Lab 13 solo usa un recorte al vocabulario CEPAL), modelos de
tópicos estructurales (`stm`), modelos de lenguaje o clasificadores
supervisados de texto, y análisis de sentimiento con léxicos genéricos.

## Registro de ampliaciones

| Fecha | Qué se agrega | Para qué | De dónde sale | Aprobado por |
| --- | --- | --- | --- | --- |
| 2026-11-10 | `pdftools::pdf_text()` | Extraer el texto de los 393 PDF de la Junta en `02_Scripts/01_extraer_texto.R`; los laboratorios partían de un `.csv` con el texto | Paquete `pdftools` (CRAN); previsto en "Herramientas previstas" | Samuel Escandón |
| 2026-11-10 | `gt` (`gt()`, `tab_header()`, `tab_spanner()`, `fmt_number()`, `gtsave()`) y Chrome/Chromium en modo headless para el `.png` | Exportar las tablas en el formato final de la diapositiva (`02_Scripts/00_formato_tablas.R`). Es presentación, no un método de análisis | `00_formato_tablas.R` del Taller 2 | Samuel Escandón |
| 2026-11-18 | `readxl::read_excel()` | Leer los `.xlsx` de series históricas del Banco de la República en `02_Scripts/06_series_macro.R` (las demás fuentes macro son `.csv`, que se leen con `readr`) | Paquete `readxl` (CRAN); previsto en "Herramientas previstas" | Santiago Muñoz Martínez (pidió el script) |
