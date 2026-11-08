# Bitácora — 2026-11-08: configuración inicial, catálogo de métodos y verificación de los documentos

## Resumen

Objetivo: dejar el repositorio del Taller 3 listo para empezar el análisis,
reutilizando la organización y el flujo de trabajo del Taller 2, y conocer los
datos antes de escribir el primer script. No se corrió ningún análisis ni se
generaron resultados.

Desarrollo, en el orden en que ocurrió:

1. **Estructura y reglas.** Se replicó la estructura de carpetas del Taller 2,
   se creó el proyecto de R, se descomprimió `Comunicados_Minutas_Banrep.zip`
   en una carpeta dedicada dentro de `01_Datos/01_Crudos/`, se movió el
   enunciado a `07_Recursos/` y se escribieron `CLAUDE.md`, las tres skills
   (`bitacora-sesion`, `cerrar-sesion`, `registrar-hallazgo`) y `HANDOFF.md`,
   adaptados al nuevo encargo (texto de la Junta del BanRep y su relación con
   la macroeconomía).
2. **Catálogo de métodos.** Se leyeron los scripts de los Laboratorios 11 y 12
   (texto como datos, sobre los resúmenes de la Revista CEPAL) y se recopilaron
   sus métodos, paquetes y funciones en `07_Recursos/catalogo_metodos.md`, con
   el mismo esquema que el catálogo del Taller 2.
3. **Fechas y video.** El usuario confirmó la entrega el domingo 22 de
   noviembre de 2026 y un video de máximo 15 minutos.
4. **Fechas de las minutas.** Se extrajo el texto de los 394 PDF (fuera del
   repositorio, con `pdftotext`) y se verificó que el nombre de cada archivo es
   la fecha de la reunión, no la de publicación. En la verificación apareció un
   documento que no es una minuta y un cambio fuerte de formato en el tiempo.
5. **Informe técnico.** Por decisión del usuario, el documento que no es minuta
   se sacó de `minutas/` y se renombró; queda en los datos crudos, junto a las
   carpetas de comunicados y minutas.

## Archivos

- Creados:
  - `taller_03.Rproj`, `.gitignore`, `CLAUDE.md`, `HANDOFF.md`
  - `.claude/skills/{bitacora-sesion,cerrar-sesion,registrar-hallazgo}/SKILL.md`
  - `07_Recursos/heuristicas_retroalimentacion_taller1.md` (copia del Taller 2)
  - `07_Recursos/catalogo_metodos.md`
  - `01_Datos/01_Crudos/Comunicados_Minutas_Banrep/comunicados/` (194 PDF),
    `.../minutas/` (199 PDF) y
    `.../2020-04-30_informe_tecnico_mercados_capitales.pdf`
  - `.gitkeep` en las carpetas vacías: `01_Datos/02_Procesados`,
    `01_Datos/03_Listos`, `02_Scripts`, `03_Resultados/Tablas`,
    `03_Resultados/Figuras`, `04_Presentaciones`, `05_Notas`, `08_Entregables`
  - Carpeta `09_Conversaciones/` (ignorada por git)
  - Esta bitácora
- Modificados: `Problem_Set_3.pdf` se movió de la raíz a `07_Recursos/`.
- Eliminados: ninguno. El zip original sigue en la raíz, ignorado por git. La
  carpeta `excluidos/` se creó y se eliminó en la misma sesión (ver abajo).

## Detalle por archivo

### Estructura de carpetas, `taller_03.Rproj`, `.gitignore`
Misma estructura numerada del Taller 2. `taller_03.Rproj` es copia del
`taller_02.Rproj` (UTF-8, 2 espacios). `.gitignore` igual al del Taller 2 más
`.DS_Store` y el zip original, cuyo contenido ya está en `01_Crudos/`. No se
creó `10_Auditoria/`: en el Taller 2 surgió al final, para la auditoría previa a
la entrega.

### `01_Datos/01_Crudos/Comunicados_Minutas_Banrep/`
El zip trae `Datos/comunicados/` y `Datos/minutas/` más una carpeta
`__MACOSX/` con metadatos de macOS (archivos `._*`), que se descartó. Los
nombres siguen el patrón `YYYY-MM-DD_comunicado.pdf` y `YYYY-MM-DD_minuta.pdf`.
Documentos por año: 11–12 hasta 2017 y 8 desde 2018, consistente con el paso a
8 reuniones de política al año.

**Verificación de fechas (minutas).** Se buscó en el texto de cada minuta la
fecha de la reunión ("reunión ... del 15 de junio de 2007", "El 15 de junio de
2007 se celebró / se llevó a cabo...") y se comparó con el nombre:

- 169 de 200 minutas declaran la fecha de la reunión y en todas coincide con el
  nombre. La de `2012-01-30` dice "30 de Enero de 2011" en el título y 2012 en
  el cuerpo: errata del documento, el nombre es correcto.
- Las 29 minutas desde `2023-03-30` no traen ninguna fecha en el texto (el
  formato nuevo empieza con un titular de la decisión). Todas tienen un
  comunicado con la misma fecha; como el comunicado sale el día de la reunión,
  su nombre también es la fecha de la reunión.
- Ningún documento dice cuándo se publicó la minuta. Si el análisis necesita el
  momento en que la minuta llega al mercado, el rezago se consulta aparte.
- Cruce comunicados–minutas: 188 fechas con los dos documentos; 12 minutas sin
  comunicado (a 21–56 días del comunicado más cercano: reuniones cuyo
  comunicado no está en el zip) y 6 comunicados sin minuta (enero a mayo de
  2007, antes de la primera minuta, y `2019-08-30`).

**Documento que no es minuta.** El archivo `minutas/2020-04-30_minuta.pdf` es
un informe del equipo técnico de 34 páginas, "Determinantes de las dinámicas de
los mercados de capitales" (documento de trabajo, versión pública), con
información hasta el 23 de abril de 2020. Mide unos 87 mil caracteres, frente a
3 mil a 30 mil de las minutas, y es el único caso así (se revisaron los
documentos más largos y más cortos de las dos carpetas). Por decisión del
usuario se movió y renombró a
`Comunicados_Minutas_Banrep/2020-04-30_informe_tecnico_mercados_capitales.pdf`.
Primero se puso en una carpeta `excluidos/`, pero el usuario pidió quitarla
porque sugería que el documento no se va a usar; queda junto a las carpetas
`comunicados/` y `minutas/`, fuera del corpus de minutas pero disponible. Solo
se movió y renombró: el contenido no se tocó. Minutas: 200 → 199; la reunión del
2020-04-30 queda sin minuta.

**Cambio de formato.** Mediana de caracteres por minuta (sin el informe
técnico): 11–23 mil en 2007–2013, 7–10 mil en 2014–2018, unos 3 mil en
2019–2020, 6 mil en 2021–2022 y 8–10 mil en 2023–2026. En las minutas leídas,
la de 2016-02-19 aún trae una sección con la visión del equipo técnico y la de
2020-01-31 ya solo reseña la discusión de la Junta. Cualquier medida de texto
sobre minutas debe normalizarse por extensión y leerse con estos cortes en
mente; falta ubicar en qué reunión cambia cada formato.

La verificación se hizo con un script temporal fuera del repositorio; en el
pipeline quedará reproducible cuando exista `01_extraer_texto.R`.

### `CLAUDE.md`
Base: el del Taller 2. Se conservaron las reglas de reproducibilidad
(`00_main.R` con `pacman`, carpetas de salida, una carpeta de resultados por
script, tablas en formato final), el flujo de versiones por rama, las
bitácoras, `HANDOFF.md`, las notas de hallazgos y las skills. Cambios:
- **Contexto:** nuevo cliente (mesa de renta fija) y encargo; la pregunta la
  define el equipo y su originalidad pesa en la calificación. Entregas el
  domingo 22 de noviembre de 2026; video de máximo 15 minutos.
- **Regla metodológica:** catálogo cerrado de métodos (Labs 11 y 12) con
  registro de ampliaciones; validar cada medida con ejemplos de los
  documentos; no mezclar comunicados y minutas sin decirlo; alinear con la
  información disponible a la fecha de la reunión; asociación no es
  causalidad; descartar cambios de formato antes de leer tendencias.
- **Semilla:** `2026`, también dentro de `control = list(seed = ...)` en
  `LDA()`; no se usa la de los laboratorios (`20261028`).
- **Notas de hallazgos:** prefijos T (texto), M (macro) y X (relación
  texto–macro), con una sección obligatoria de "Ejemplos de los documentos".
- **Datos, restricciones de muestra y decisiones:** inventario de los PDF,
  resultado de la verificación de fechas, el informe técnico, el cambio de
  formato y las decisiones de la sesión.

### `07_Recursos/catalogo_metodos.md`
Recopila, con el código de los laboratorios y una nota de aplicación a la
Junta:
- **Lab 11:** tokenización (`unnest_tokens`), ley de Zipf, palabras vacías
  (*snowball* español e inglés) y tildes (`stri_trans_general`), raíces
  (`wordStem`, solo exploratorio), frecuencias por grupo, TF-IDF
  (`bind_tf_idf`, con el grupo como documento y filtro de 8 apariciones),
  matriz documento-término (`cast_dtm`), bigramas y correlación entre palabras
  (`pairwise_cor`, palabras en 30 o más documentos).
- **Lab 12:** diccionario de términos compuestos (del más largo al más corto,
  tolerante a tildes), lemas con `udpipe` (sustantivos, adjetivos, verbos y
  nombres propios; primero lematizar, después quitar tildes), exclusiones
  genéricas y geográficas, recorte del vocabulario a palabras en 5 o más
  documentos y en no más del 25 %; LDA (`topicmodels`, VEM y Gibbs), lift
  (probabilidad en el tópico / frecuencia en el corpus), elección de
  hiperparámetros por perplejidad de *document completion* con validación
  cruzada de 3 pliegues y coherencia UMass, validación con documentos
  representativos y etiquetas externas, y agregación de tópicos en el tiempo.
- **Herramientas previstas, no vistas en clase:** `pdftools`, lectura de las
  series macro, regresiones texto–macro, diccionarios de tono y la red de
  co-ocurrencias (el Lab 11 carga `igraph`/`ggraph` pero no la dibuja).
- **Advertencias para el taller:** los labs eliminan tokens con dígitos (en la
  Junta las cifras son contenido) y sus umbrales y rejillas están pensados para
  miles de resúmenes, no para 393 documentos.

### Skills
- `cerrar-sesion`: copia con "Taller 2" → "Taller 3"; es genérica.
- `bitacora-sesion`: las reglas sobre escala `ln(Revenue)` y CATE se
  reemplazaron por reglas de fuente, periodo, preprocesamiento y asociación.
- `registrar-hallazgo`: reescrita para el nuevo tipo de notas; el contraste se
  hace contra notas previas y hechos conocidos de la política monetaria, en
  lugar del Taller 1.

### `HANDOFF.md`
Creado con la fecha de entrega, tres siguientes objetivos, el estado actual y
el registro de esta sesión.

## Pendientes

- Definir la pregunta del taller, las series macro (con fuente, cobertura,
  frecuencia y transformaciones) y los roles de los integrantes.
- Crear `PLAN.md` y registrar en el catálogo las primeras ampliaciones
  (`pdftools`, lectura de las series macro).
- Crear `00_main.R`, los scripts de formato (traídos del Taller 2) y
  `01_extraer_texto.R`, que debe reproducir la verificación de fechas y la
  separación del informe técnico.
- Ubicar en qué reunión cambia cada formato de las minutas.
- Fecha de la retroalimentación a compañeros (no afecta el repositorio).
- Primer commit: `main` no tiene commits y el remoto está vacío; se hará en la
  rama `SantiagoMunozM` con `cerrar-sesion`.
