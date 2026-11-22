# CLAUDE.md: reglas del proyecto

## Contexto del proyecto

Taller 3 de Ciencia de Datos y Econometría Aplicada (ECON-3785, 2026-2, Universidad
de los Andes): **"¿De qué habla la Junta del Banco de la República?"**. Cliente
ficticio: la mesa de renta fija de un fondo de inversión. A diferencia de los
Talleres 1 y 2 (CheMarket, repositorios `taller1/` y `taller_02/` en carpetas
hermanas), este taller trabaja con **texto**: los comunicados y las minutas de la
Junta Directiva del Banco de la República (BanRep).

- **Encargo del cliente:** la mesa sigue los comunicados y minutas de cada
  reunión para interpretar las decisiones de política monetaria y sus
  argumentos, y quiere complementar ese seguimiento con un análisis sistemático
  de los documentos.
- **Qué quiere saber la mesa:**
  - qué patrones aparecen en la comunicación de la Junta;
  - cómo cambian a lo largo del tiempo;
  - cómo se relacionan con la evolución de las variables macroeconómicas;
  - qué aspectos del entorno económico reciben atención en las discusiones de
    la Junta y cómo se reflejan en sus comunicaciones.
- **Tarea:** analizar los comunicados y las minutas con las herramientas del
  curso y comunicar qué se puede aprender de ellos sobre la relación entre la
  comunicación del Banco y el contexto macroeconómico.
- **La pregunta la plantea el equipo.** El enunciado no fija una pregunta
  cerrada: la calificación depende en gran medida de la **originalidad de la
  pregunta**, de la creatividad y el rigor del análisis, y de que el trabajo
  aporte una **perspectiva propia** sobre la comunicación de la Junta y su
  relación con el contexto macroeconómico. La pregunta elegida se registra en
  "Decisiones tomadas" (fijada el 2026-11-18).
- **Pregunta del equipo (2026-11-18):** *¿Cómo cambiaron los temas de interés de
  la Junta del Banco de la República antes y después de la crisis del petróleo
  de 2014 en Colombia?*
  - **Historia macro** que la ordena: caída del precio del petróleo, aumento de
    la tasa de cambio (TRM) e impacto sobre la inflación. Las series cuentan la
    historia; la pregunta central es sobre los **temas** (prioridades y
    preocupaciones) de la Junta antes y después, no sobre las series.
  - **Método previsto:** embeddings de palabras (GloVe o Word2Vec) para ver de
    qué se hablaba antes y después y cómo cambian las prioridades. Se vieron
    en el Laboratorio 13 y están en el catálogo desde el 2026-11-21 (ver
    "Decisiones tomadas").
  - **Alcance:** la relación entre la historia macro y el cambio de temas es
    asociativa, no causal (ver "Asociación no es causalidad").
- **Dos fuentes de datos**, con roles distintos:
  - **Documentos de la Junta** (dados por el curso): comunicados y minutas en
    PDF. Son la fuente del texto.
  - **Series macroeconómicas** (las elige y consigue el equipo): deben
    justificarse (por qué esas variables), y documentarse su fuente, cobertura y
    transformaciones (ver "Datos").
- **Exigencias del enunciado sobre la evidencia:**
  - Las conclusiones deben estar sustentadas en los resultados del análisis
    **y** en el contenido de los documentos (ejemplos textuales que muestren
    qué captura cada medida).
  - Explicar la interpretación económica de los patrones encontrados.
  - Ser explícitos sobre el alcance de la evidencia: la relación entre texto y
    macroeconomía es, salvo diseño explícito, asociativa y no causal.
- **Entregables finales** (ver "Entregas y fechas"): (1) la presentación al
  cliente (slides y video), en `08_Entregables/`, sin código y estilo
  *answer-first* (ver "Entregable: presentación al cliente"); (2) el material de
  soporte, es decir, este repositorio reproducible, donde quedan documentados
  los detalles del procesamiento y del análisis.

### Entregas y fechas (instrucciones generales del curso)

Los enlaces de entrega están en Bloque Neón; el enunciado está en
`07_Recursos/Problem_Set_3.pdf`.

| Entrega                               | Qué se sube                                                                            | Fecha límite              |
| ------------------------------------- | -------------------------------------------------------------------------------------- | ------------------------- |
| Vídeo                                 | Los slides usados y un enlace al video (máximo 15 minutos)                             | Domingo 22 de noviembre   |
| Material de soporte                   | El repositorio reproducible (README, scripts, resultados, registro de conversaciones) | Domingo 22 de noviembre   |
| Vídeo para retroalimentación de pares | El mismo video, en el enlace de pares                                                  | Domingo 22 de noviembre   |
| Retroalimentación a compañeros        | Comentarios a los videos asignados                                                     | Por definir               |

- Las entregas del equipo vencen el **mismo día (domingo 22 de noviembre de
  2026)**. Planear el trabajo hacia atrás desde esa fecha: el video debe
  grabarse con las figuras y tablas ya finales y regeneradas por `00_main.R`.
- **El video dura máximo 15 minutos.**
- Se asume, como en los talleres anteriores, que el video para pares se sube el
  mismo día; la fecha de la retroalimentación a compañeros está por confirmar.
  Ninguna de las dos afecta el repositorio.

## Estructura del proyecto

- `01_Datos/01_Crudos/`      datos originales. NUNCA se modifican
  - `Comunicados_Minutas_Banrep/comunicados/`  194 comunicados en PDF (2007-01-26 a 2026-09-30)
  - `Comunicados_Minutas_Banrep/minutas/`      199 minutas en PDF (2007-06-15 a 2026-09-30)
  - `Comunicados_Minutas_Banrep/2020-04-30_informe_tecnico_mercados_capitales.pdf`  informe del equipo técnico que el zip traía entre las minutas
  - las series macroeconómicas descargadas se guardan aquí (hoy `brent_2000-26.csv`, `inflacion_variacion_anual_99_26.xlsx`, `tasa_cambio_real_70_26.xlsx` y `TRM.csv`, sueltos en esta carpeta; ver "Datos")
- `01_Datos/02_Procesados/`  datos limpios o transformados (p. ej. texto extraído de los PDF, series transformadas)
- `01_Datos/03_Listos/`      bases finales que ingresan al análisis (p. ej. corpus tokenizado, panel documento–macro)
- `02_Scripts/`              scripts de R
- `03_Resultados/`           Tablas/ y Figuras/ generadas, cada una con una subcarpeta por script (ver "Una carpeta de resultados por script")
- `04_Presentaciones/`       borradores de la presentación
- `05_Notas/`                notas de hallazgos: un `.md` por hallazgo principal, con
  referencia a sus tablas/figuras (ver "Notas de hallazgos")
- `06_Bitacoras/`            documentación de cada sesión de trabajo
- `07_Recursos/`             referencias externas y documentación (aquí está el
  enunciado, `Problem_Set_3.pdf`; las heurísticas derivadas de la
  retroalimentación del Taller 1, `heuristicas_retroalimentacion_taller1.md`;
  y el catálogo de métodos, librerías y funciones permitidos,
  `catalogo_metodos.md`)
- `08_Entregables/`          presentación final y video
- `09_Conversaciones/`       registro crudo (`.jsonl`) de las conversaciones con los agentes; en `.gitignore`, no se versiona (cada integrante guarda las suyas localmente; al final se unen por aparte)
- `.claude/skills/`          skills del proyecto (`bitacora-sesion`, `cerrar-sesion`, `registrar-hallazgo`; y las de terceros `ponytail`, `caveman`, `hallmark`, ver "Skills de terceros")
- `00_main.R`                (raíz) script maestro: corre todo el pipeline
- `HANDOFF.md`               (raíz) estado actual, siguientes objetivos y registro de sesiones
- `taller_03.Rproj`          proyecto de RStudio (raíz del proyecto)

## Reglas de trabajo

- Lenguaje principal: R. Utilice `tidyverse` cuando resulte apropiado.
- Explique lo que va a hacer ANTES de editar o crear archivos.
- Utilice rutas relativas ancladas a la carpeta del proyecto.
- Redacte los comentarios del código en español.
- **Semilla:** `set.seed(2026)` en cualquier análisis con componente aleatorio
  (modelos de tópicos, partición muestral, validación cruzada, bosques, etc.).
  En `topicmodels::LDA()` la semilla va además en `control = list(seed = 2026)`;
  no se copia la de los laboratorios (`20261028`).
- **Evaluación fuera de muestra:** si hay un componente predictivo (p. ej.
  predecir decisiones de tasa o variables macro a partir del texto), el
  desempeño se evalúa siempre fuera de muestra, nunca dentro de muestra. Con
  series de tiempo, la partición respeta el orden temporal (se entrena con el
  pasado y se evalúa con el futuro); no se usa partición aleatoria.
- Al cerrar una sesión, registre la sesión con la skill `bitacora-sesion` y
  después ciérrela con `cerrar-sesion` (commit, push y conversación; ver
  "Registro de sesión de trabajo").
- **Heurísticas de la retroalimentación del Taller 1:** antes de (i) definir la
  pregunta o una especificación, (ii) diseñar la estadística descriptiva,
  (iii) evaluar o interpretar un modelo, o (iv) redactar conclusiones,
  recomendaciones o diapositivas, lea
  `07_Recursos/heuristicas_retroalimentacion_taller1.md` y aplique las
  heurísticas pertinentes. Fueron escritas para CheMarket; aquí se aplican por
  analogía (p. ej. H1: declarar primero qué se quiere medir; H2: reconciliar
  medidas que se contradicen; H8: interpretar estadística y económicamente;
  H10: la conclusión se sigue de la evidencia). H7 (balance y cumplimiento del
  experimento) no aplica: no hay experimento. Si una decisión se aparta de una
  heurística, regístrelo en "Decisiones tomadas" con la razón.

### Reproducibilidad y salidas

Se mantienen las reglas del Taller 2, que incorporaron la retroalimentación del
Taller 1 (repositorio con 100/100). Son obligatorias:

- **`00_main.R` instala y carga todos los paquetes con `pacman`, una sola
  vez.** No se pide al usuario instalar librerías a mano. La lista única de
  paquetes del proyecto vive en el `pacman::p_load()` de `00_main.R`:

  ```r
  if (!require("pacman")) install.packages("pacman")
  pacman::p_load(tidyverse, ...)
  ```

  Los scripts de `02_Scripts/` **no** cargan paquetes (ni `library()` ni
  `p_load()`); en su lugar llevan el comentario
  `# los paquetes los carga 00_main.R con pacman`. Si un script nuevo
  necesita otro paquete, se agrega a ese `p_load()` con un comentario de para
  qué se usa. Para correr un script suelto (p. ej. al depurar), primero se
  ejecutan las secciones 1 a 3 de `00_main.R`. El README debe decir que basta
  con correr `00_main.R`.
- **`00_main.R` verifica las carpetas de salida una sola vez, al comienzo.**
  Borrar `03_Resultados/` (o cualquiera de sus subcarpetas) y correr
  `00_main.R` debe regenerar todo sin errores. Para eso, antes de ejecutar
  cualquier script, `00_main.R` recorre una lista única de carpetas de salida
  y crea las que falten:

  ```r
  carpetas_salida <- c(
    "01_Datos/02_Procesados", "01_Datos/03_Listos",
    "03_Resultados/Tablas", "03_Resultados/Figuras"
  )
  for (carpeta in carpetas_salida) {
    if (!dir.exists(carpeta)) dir.create(carpeta, recursive = TRUE)
  }
  ```

  La verificación vive **solo** en `00_main.R`: las funciones auxiliares
  (`guardar_figura()`, `guardar_tabla()`) y los scripts de análisis **no**
  llaman a `dir.create()`. Si un script nuevo escribe en una carpeta que no
  está en la lista, se agrega la carpeta a `carpetas_salida` en `00_main.R`.
  `01_Datos/01_Crudos/` no va en la lista: no es una salida y nunca se escribe
  en ella.
- **Las series macroeconómicas deben poder reconstruirse.** Si se descargan con
  código (API o URL estable), el script de descarga queda en el pipeline; si se
  descargan a mano, el archivo crudo se versiona en `01_Datos/01_Crudos/` y su
  fuente exacta (URL, fecha de consulta, nombre de la serie) se documenta en
  "Definición de variables" y en el README.
- **La extracción de texto de los PDF es parte del pipeline.** El texto se
  extrae con código desde `01_Datos/01_Crudos/` (p. ej. con `pdftools`) y se
  guarda en `02_Procesados/`; no se copia ni se edita texto a mano. Si la
  extracción es lenta, el script puede reutilizar el resultado guardado, pero
  debe poder regenerarlo desde cero.
- **Una carpeta de resultados por script.** Todo script que genere al menos
  una figura o tabla guarda sus salidas en su propia subcarpeta, con el nombre
  del script sin `.R`: `03_Resultados/Figuras/<script>/` y
  `03_Resultados/Tablas/<script>/`. Así cada archivo se rastrea a su script por
  la ruta. Reglas:
  - El script define `carpeta_salida <- "<nombre_del_script>"` al comienzo y
    la pasa a `guardar_figura(nombre, grafica, carpeta)` y
    `guardar_tabla(nombre, tabla, datos, carpeta)`; no escribe en la raíz de
    `Figuras/` ni de `Tablas/`. Lo mismo vale para los `.csv` que se escriben
    con `write_csv()`.
  - Cada subcarpeta se agrega a `carpetas_salida` en `00_main.R` en la misma
    sesión en que se crea el script.
  - Si se renombra un script, se renombra su subcarpeta (con `git mv`) y se
    actualizan `00_main.R`, el README y las notas de `05_Notas/` que citen sus
    rutas. Los scripts de formato (`00_formato_*.R`) no tienen subcarpeta: no
    generan resultados.
  - Si dos scripts producen una misma figura o tabla, solo uno la genera; el
    otro la lee.
- **Las tablas se exportan en el formato final de la diapositiva.** La tabla
  que entra a la presentación sale tal cual del código: encabezados,
  decimales, etiquetas en español, notas al pie y colores incluidos. No se
  reformatean tablas fuera de R ni se pegan pantallazos de la consola.
- **`00_main.R` es el único punto de entrada.** Vive en la raíz del proyecto
  y sigue la estructura de los talleres anteriores: (1) verifica que el
  directorio de trabajo es la raíz (que haya un archivo `.Rproj`, con cualquier
  nombre, y la carpeta `02_Scripts/`); (2) carga los paquetes con `pacman`;
  (3) verifica las carpetas de salida; (4) lista los scripts en el orden de su
  numeración; (5) ejecuta cada uno con `source(script, local = new.env(),
  encoding = "UTF-8")`. Regenera todos los datos procesados, tablas y figuras
  que usa la presentación. Cada script nuevo se agrega a la lista `scripts`
  en la misma sesión en que se crea. Los scripts de formato
  (`00_formato_*.R`) no van en la lista: los cargan con `source()` los scripts
  que los usan.

#### Formato de las tablas

El formato de las tablas vive en un único lugar: `02_Scripts/00_formato_tablas.R`
(traído del Taller 2 y adaptado el 2026-11-10: usa `gt` y genera el `.png` con
Chrome/Chromium en modo headless). Ese script no genera tablas, solo define el
estilo y la función de exportación (`guardar_tabla()`).

- Todo script que produzca tablas para la presentación empieza con
  `source("02_Scripts/00_formato_tablas.R")` y exporta con `guardar_tabla()`.
  No se redefine el estilo dentro de un script de análisis.
- Estilo coherente con las figuras: encabezados con la paleta del proyecto,
  texto en español y sin nombres de variables del código, número de decimales
  fijo por tipo de cifra, unidades explícitas (puntos porcentuales, %, número
  de documentos) y una nota que declare la fuente (comunicados, minutas, serie
  macro), el periodo y el `n` de documentos.
- Se exporta en un formato que se inserta directamente en las diapositivas
  (`.png` de alta resolución) y además en `.csv` con las cifras sin formato,
  para trazabilidad.
- **Nombres de archivo:** `03_Resultados/Tablas/<script>/<fuente>_<contenido>.<ext>`,
  con `<fuente>` = `comunicados`, `minutas`, `macro` o `conjunto` (texto y
  macro combinados).

#### README

Se mantiene lo que obtuvo el puntaje completo en el Taller 1: objetivo del
proyecto, estructura de carpetas, instrucciones de ejecución (solo
`00_main.R`, con `pacman` instalando lo necesario), **fuentes de los datos**
(documentos y series macro, con cobertura y transformaciones) y un **mapa
completo script → tablas/figuras**, de forma que cada elemento de las
diapositivas se pueda rastrear al script que lo genera. El README se actualiza
en la misma sesión en que se agrega o renombra un script o un resultado.

### Flujo de versiones: una rama por integrante (obligatorio para los agentes)

Repositorio: `https://github.com/talleres-ECON3785/taller_03`. Cada integrante
tiene su propia rama, creada desde `main`, con la convención nombre + primer
apellido + inicial del segundo (la misma de los correos de Uniandes):

| Integrante                | Rama                |
| ------------------------- | ------------------- |
| Samuel Escandón           | `SamuelEscandonC`   |
| Douglas Plazas Guzmán     | `DouglasPlazasG`    |
| Mateo Olmos Becerra       | `MateoOlmosB`       |
| Santiago Muñoz Martínez   | `SantiagoMunozM`    |

Reglas que los agentes siguen **siempre**, sin excepción:

1. **Al empezar la sesión, identificar la rama del integrante.** Revisar
   `git branch --show-current` y `git config user.name`. Si el agente está en
   `main` o en la rama de otro integrante, cambia a la rama de quien trabaja
   (`git switch <rama>`) antes de editar cualquier archivo. Si no es inferible
   con certeza quién trabaja, pregunta; no adivina.
2. **Sincronizar con `main` al empezar:** `git fetch origin` y, si `main`
   avanzó, traer sus cambios a la rama del integrante (`git merge origin/main`)
   antes de trabajar, para reducir conflictos. Si hay conflictos, se muestran al
   usuario y se resuelven con él.
3. **Todo el trabajo se hace, se commitea y se empuja en la rama del
   integrante** (`git push origin <rama>`). La skill `cerrar-sesion` hace
   este commit y push al cerrar cada sesión.
4. **Nunca commitear ni hacer push directamente a `main`.** Llevar los cambios
   a `main` es una decisión del integrante, no del agente: se hace solo cuando el
   usuario lo pide explícitamente, preferiblemente con un pull request desde su
   rama (`gh pr create --base main --head <rama>`), después de sincronizar la
   rama con `main` y de comprobar que `00_main.R` corre sin errores.
5. No crear ramas adicionales por tarea ni trabajar en la rama de otro
   integrante sin que el usuario lo pida.

### Registro de sesión de trabajo

- Cada sesión de trabajo debe quedar documentada en un archivo `.md` en
  `06_Bitacoras/` y sus cambios versionarse en la rama del integrante (ver
  "Flujo de versiones").
  Nombre: `YYYY-MM-DD_slug-descriptivo.md`.
- Estructura de cada bitácora:
  - **Resumen:** objetivo y desarrollo de la sesión, al inicio.
  - **Archivos:** lista de archivos creados, modificados y eliminados.
  - **Detalle por archivo:** explicación de los cambios en cada archivo
    involucrado, con las decisiones de implementación, los supuestos usados y la
    intuición en lenguaje natural de cada decisión.
  - Para las medidas que se construyen a partir del texto (p. ej. un
    diccionario, un índice de tono, la proporción de un tópico) o de las series
    (p. ej. una brecha o una variación anual), explicar cada una por aparte y a
    detalle: citar la fuente (recurso de `07_Recursos/`, paper o documentación),
    cómo se calcula y qué rol cumple en el análisis.
  - **Resultados nuevos (tablas, figuras, gráficos):** para cada uno, qué busca
    comunicar, cómo se generan los datos que lo alimentan y qué rol cumple
    dentro del taller. Se omite si la sesión no generó resultados.
  - **Pendientes:** lo que quedó sin hacer, los supuestos sin confirmar y el
    siguiente paso.
- Las bitácoras son el insumo de las sesiones posteriores: deben permitir
  entender qué ya se hizo y qué quedó pendiente, para mantener un desarrollo
  coherente del taller. Consúltelas cuando necesite el detalle de una sesión
  (el punto de entrada es `HANDOFF.md`).
- Las decisiones metodológicas relevantes también se registran en las tablas
  "Decisiones tomadas" / "Análisis descartados" de este archivo, y se actualiza
  `HANDOFF.md`.

### `HANDOFF.md`: resumen orientado a lo que sigue

`HANDOFF.md` (raíz) resume las bitácoras para retomar el trabajo sin leerlas
todas. Las bitácoras explican el porqué; el handoff dice dónde estamos y qué
sigue.

- **Al iniciar una sesión:** después de ubicarse en la rama del integrante (ver
  "Flujo de versiones"), lea `HANDOFF.md` antes que cualquier otro archivo y
  proponga trabajar en el primero de sus "Siguientes objetivos" que no esté
  asignado a otro integrante, salvo que el usuario indique otra cosa.
- **Al cerrar una sesión** (lo hace la skill `bitacora-sesion`), después de
  escribir la bitácora, actualice las tres secciones:
  - **Siguientes objetivos:** se reescribe con **dos a tres** tareas concretas,
    en orden de prioridad. Cada una lleva el archivo que debe producirse, un
    criterio de terminado verificable y, si aplica, el integrante a cargo.
    Debajo van los bloqueos o preguntas abiertas para el equipo. Si un objetivo
    no se terminó, se mantiene y se anota en el registro qué avanzó y qué lo
    impidió.
  - **Estado actual:** se reescribe para reflejar qué existe y funciona hoy
    (datos, scripts, resultados). No es un historial.
  - **Registro de sesiones:** se agrega una entrada arriba (la más reciente
    primero), de tres a cinco líneas: quién trabajó y en qué rama, qué se hizo,
    el enlace a la bitácora y, al final, los **dos a tres siguientes
    objetivos** que quedaron al cerrar. Las entradas anteriores no se editan.
- **Plan de implementación:** cuando exista, vivirá en `PLAN.md` (raíz),
  organizado en hitos con tareas numeradas (`Pk.n`) y casillas de verificación
  (creado el 2026-11-18). Los "Siguientes
  objetivos" se derivan de los próximos pasos sin marcar del plan, citando el
  número de paso, y el registro de cada sesión indica qué pasos del plan avanzó
  o cerró. Las casillas se marcan `[x]` en la misma sesión en que se termina la
  tarea.
- **Conflictos entre ramas:** como cada integrante actualiza `HANDOFF.md` en su
  rama, al traer `main` pueden chocar las entradas del registro. Se resuelven
  conservando todas las entradas, ordenadas por fecha, y reescribiendo
  "Siguientes objetivos" y "Estado actual" para que reflejen el trabajo
  combinado.

### Notas de hallazgos (`05_Notas/`)

`05_Notas/` es la memoria analítica del taller: recopila **qué se encontró y por
qué importa**, mientras que las bitácoras (`06_Bitacoras/`) registran **qué se
hizo en cada sesión**. Quien arme la presentación debe poder leer solo las notas
y reconstruir los mensajes principales.

- **Una nota por hallazgo principal**, no por sesión. Un hallazgo es un
  resultado que sostiene (o matiza, o contradice) una conclusión del taller.
  Nombre: `<tipo>_<slug>.md`, con `<tipo>` = `T` (texto: patrones de la
  comunicación), `M` (macro: contexto económico) o `X` (relación texto–macro).
- **Las notas se agrupan por el script del que se derivan:**
  `05_Notas/<script>/<tipo>_<slug>.md`. Una nota solo habla de lo que se sabe
  con los resultados de su script; si otro script matiza o cambia el hallazgo,
  se registra en la subcarpeta de ese script y se enlaza. Cada nota declara su
  "Script de origen".
- **Una nota se crea o actualiza en la misma sesión en que el resultado que la
  sostiene se genera o cambia.** No se espera al cierre ni a la presentación.
- **Estructura de cada nota:**

  ```markdown
  # <Hallazgo, enunciado como conclusión>

  - **Estado:** vigente | matizado | reemplazado (con enlace a la nota que lo reemplaza)
  - **Tipo / fuente:** T, M o X; comunicados, minutas, serie macro o combinación; descriptivo, predictivo o asociativo
  - **Script de origen:** `02_Scripts/<script>.R`
  - **Última verificación:** YYYY-MM-DD, con el script que lo genera

  ## Evidencia
  Referencias a una o más tablas/figuras en `03_Resultados/` (ruta exacta) y el
  script de `02_Scripts/` que las produce. Las cifras clave se citan con su
  unidad, periodo y `n` de documentos.

  ## Ejemplos de los documentos
  Uno o más fragmentos textuales (con fecha y tipo de documento) que muestren
  qué está capturando la medida. Lo exige el enunciado.

  ## Qué dice, en lenguaje intuitivo
  Explicación para alguien sin formación técnica: qué muestra la figura o la
  tabla, cómo leerla y qué significa para la mesa de renta fija.

  ## Por qué importa en el estudio
  Qué parte de la pregunta del taller responde e interpretación económica del
  patrón. Qué implica para el seguimiento que hace la mesa.

  ## Límites e incertidumbre
  Qué no permite afirmar (p. ej. asociación no es causalidad; sensibilidad al
  diccionario o al número de tópicos), y qué evidencia adicional haría falta.

  ## Historial
  Una línea por cambio de estado o de cifras: fecha, qué cambió y por qué.
  ```

- Las notas siguen las reglas de redacción del proyecto: sin juicios de "bueno"
  o "malo", sin entusiasmo por métricas ni significancia, sin código, y con las
  heurísticas pertinentes aplicadas. Solo se cita lo que está en
  `03_Resultados/` o en los documentos crudos: una cifra sin archivo de
  respaldo no entra a una nota.
- `05_Notas/README.md` es el índice: una línea por nota con su estado y la
  pregunta que responde. Se crea con la primera nota y se actualiza cada vez que
  se crea o cambia el estado de una nota.

#### Contrastar la evidencia nueva con lo ya registrado

Cada vez que un resultado nuevo se genera o se modifica (un script nuevo, un
cambio de especificación, un diccionario o un número de tópicos distinto, una
corrida distinta de `00_main.R`), el agente, antes de darlo por cerrado:

1. **Lee `05_Notas/README.md` y las notas relacionadas.**
2. **Contrasta** el resultado nuevo con lo que ya dicen las notas: misma
   dirección y orden de magnitud, mismo periodo y fuente, mismas conclusiones.
   Contrasta también con los hechos conocidos de la política monetaria (p. ej.
   ciclos de subidas y bajadas de la tasa de intervención): una medida de texto
   que no se mueve en episodios evidentes es una señal de alerta.
3. **Si todo es consistente**, actualiza "Última verificación" de la nota y lo
   deja en el historial.
4. **Si algo es contradictorio, alerta al usuario de inmediato**, sin esperar al
   cierre de sesión y sin resolverlo en silencio. La alerta indica: (i) qué nota
   o resultado previo se contradice (con la ruta), (ii) las cifras de ambos lados
   con su unidad, periodo y fuente, (iii) hipótesis de la causa (p. ej. cambio en
   la extracción de texto, en el preprocesamiento, en el diccionario, en la
   semilla o el número de tópicos, en la frecuencia o alineación temporal, o un
   error de código), y (iv) qué verificar para resolverlo.
5. **Mientras el usuario no decida**, no se sobrescribe la nota anterior: se marca
   su estado como `matizado` o `reemplazado` solo con su confirmación, se deja la
   evidencia nueva en una nota propia o en el historial, y se registra la
   decisión en "Decisiones tomadas" si cambia una conclusión.

La skill `registrar-hallazgo` (`.claude/skills/registrar-hallazgo/SKILL.md`)
implementa este procedimiento: se invoca al generar o cambiar un resultado, y
`bitacora-sesion` verifica al registrar la sesión que cada resultado nuevo tenga su nota.

### Skills de cierre de sesión: `bitacora-sesion` y `cerrar-sesion`

El cierre se divide en dos skills, que se corren en este orden. Las dos
preguntan al usuario cuando algo no es inferible con certeza (p. ej. quién del
equipo trabajó en la sesión) en vez de adivinar.

1. **`bitacora-sesion`** (`.claude/skills/bitacora-sesion/SKILL.md`). Se invoca
   al terminar una sesión (pidiendo "registrar la sesión", "escribir la
   bitácora" o "actualizar el handoff"). Usa el modelo de la sesión, porque
   requiere juicio y el historial de la conversación. Hace tres cosas:
   - Escribe la bitácora de la sesión en `06_Bitacoras/` con la estructura de
     arriba. Para ubicarse lee `HANDOFF.md` y solo la última bitácora; abre
     otras únicamente si necesita más contexto.
   - Verifica que cada resultado nuevo tenga su nota en `05_Notas/` (invoca
     `registrar-hallazgo` si falta).
   - Actualiza `HANDOFF.md`: siguientes objetivos (dos a tres, del plan de
     implementación cuando exista), estado actual y una entrada nueva en el
     registro de sesiones (ver "`HANDOFF.md`").

   Al terminar, indica que el siguiente paso es `cerrar-sesion`; no hace commit.
2. **`cerrar-sesion`** (`.claude/skills/cerrar-sesion/SKILL.md`). Se invoca
   después de la anterior (pidiendo "cerrar sesión", "hacer el commit", "subir
   los cambios" o "guardar la conversación"). Es mecánica y corre con
   `model: haiku` en su frontmatter. Hace dos cosas:
   - Hace commit de la bitácora y de los cambios de la sesión, y push **a la
     rama del integrante**, nunca a `main` (ver "Flujo de versiones").
   - Copia el registro crudo (`.jsonl`) de la conversación a
     `09_Conversaciones/`. Esa carpeta está en `.gitignore`: las conversaciones
     se guardan localmente y **no se suben a GitHub**.

**Cómo se entregan las conversaciones:** cada integrante acumula sus `.jsonl` en
su copia local de `09_Conversaciones/`. Al final del taller, el equipo las une
por aparte, fuera del flujo de git, para entregarlas con el material de
soporte. Los agentes no deben versionar esa carpeta, quitarla del `.gitignore`
ni intentar unir las conversaciones de otros integrantes.

## Skills de terceros: `ponytail`, `caveman`, `hallmark`

Están copiadas en `.claude/skills/` (versionadas) para que todos los
integrantes las tengan sin instalar nada. Se invocan con `/ponytail`,
`/caveman` y `/hallmark`. Ninguna reemplaza las reglas de este archivo: si
chocan, **gana CLAUDE.md**.

- **`ponytail`** (programar con el menor cambio que resuelva la tarea). **Es
  el modo por defecto en nivel `full`**: todo agente lo activa al empezar la
  sesión y lo mantiene hasta que el usuario diga "stop ponytail" o "normal
  mode". Cambiar de nivel solo lo hace el usuario (`/ponytail lite|ultra`).
  Aplica al escribir, corregir o refactorizar scripts de R y al elegir
  dependencias: reutilizar lo que ya existe, no agregar paquetes por pocas
  líneas, no construir funcionalidad no pedida. Variantes: `/ponytail-review`
  (revisar un cambio), `/ponytail-audit` (auditar el repo), `/ponytail-debt`
  (listar los `shortcut:`). Límites:
  - No recorta lo que este archivo exige: `set.seed(2026)`, carpetas por script,
    formato de figuras y tablas, `00_main.R`, README, bitácora, notas y
    validación de las medidas con ejemplos del texto.
  - Las decisiones de método (pregunta, medidas, series, alineación) no se
    "simplifican" por cuenta del agente: se ajustan al catálogo de
    `07_Recursos/catalogo_metodos.md` y las cambia el equipo.
  - Los comentarios del código y los `shortcut:` van en español.
  - El auto-chequeo que pide la skill para lógica nueva es un `stopifnot()` al
    final del script, sin paquetes de pruebas nuevos.
  - Los dos cierres de línea que pide la skill (qué omitió, qué riesgo) van en
    el chat, no en los archivos del repo.

- **`caveman`** (respuestas breves en el chat). **Es la forma por defecto en
  que habla el agente**: todo agente activa la skill al empezar la sesión y la
  mantiene hasta que el usuario diga "stop caveman" o "normal mode". Solo
  afecta el tono de lo que el agente le dice al usuario en la conversación; se
  sigue respondiendo en español. Reglas para este proyecto:
  - **No se usa** en nada que se guarde fuera del chat: bitácoras, notas de
    hallazgos, `README.md`, `HANDOFF.md`, `CLAUDE.md`, comentarios de código,
    mensajes de commit y de PR, diapositivas ni guion del video se escriben en
    español completo y con la estructura que pide este archivo.
  - Se sale de caveman, en prosa completa, para: advertencias, acciones
    irreversibles o hacia afuera (commit, push, borrar, sobrescribir), preguntas
    u opciones al usuario, y cuando el usuario esté confundido o repita la
    pregunta.
  - "Explique lo que va a hacer ANTES de editar o crear archivos" se cumple con
    una línea antes de la tarea, como pide la propia skill.
  - Las alertas de contradicción de evidencia (ver "Contrastar la evidencia
    nueva") y las explicaciones de interpretación económica van completas: la
    brevedad no puede quitar cifras, unidades, periodos ni la salvedad
    "asociación no es causalidad".

- **`hallmark`** (diseño de páginas que se ven diseñadas, no generadas). En
  este proyecto se usa para los **borradores de la presentación**: un deck
  en HTML (una pantalla = una diapositiva, una idea por pantalla) guardado en
  `04_Presentaciones/`. Reglas del borrador:
  - Sigue los principios de la skill (todo color y tipografía como token en
    `:root`, una dirección visual definida, sin plantillas genéricas) y,
    además, "Entregable: presentación al cliente" de este archivo: título que
    comunica la conclusión, *answer-first*, sin código.
  - Los tokens de color son la paleta del proyecto (`paleta_categorica` y los
    grises de `00_formato_graficas.R`); no se inventa otra, para que las figuras
    y el deck se vean como una sola familia.
  - Las figuras y tablas entran como los `.png` exportados por el pipeline
    (`03_Resultados/`), sin redibujarlas ni retocarlas en el HTML. Las cifras
    del texto del slide salen de `03_Resultados/` o de las notas de
    `05_Notas/`; ninguna se escribe de memoria.
  - Es un **borrador**: la presentación final y el video salen de las figuras
    regeneradas por `00_main.R`. Sobre un borrador existente solo se usa
    `/hallmark redesign <ruta>` o `/hallmark audit <ruta>` si el usuario lo
    nombra.
  - No aplica a las figuras ni a las tablas (siguen `00_formato_graficas.R` y
    `00_formato_tablas.R`).

## Regla metodológica: herramientas del curso, medidas validadas con el texto

- El enunciado pide usar **las herramientas del curso**. **Catálogo cerrado
  de métodos:** el trabajo se limita a los métodos, paquetes y funciones de
  `07_Recursos/catalogo_metodos.md`, recopilados de los Laboratorios 11, 12 y
  13: tokenización y limpieza (`tidytext`, `stopwords`, `stringi`, `SnowballC`),
  términos compuestos por diccionario y lemas (`udpipe`), frecuencias y TF-IDF,
  matriz documento-término (`tm`), bigramas y correlación entre palabras
  (`widyr`), LDA (`topicmodels`) con lift, perplejidad por *document
  completion*, coherencia UMass y validación con documentos representativos, y
  embeddings de palabras: Word2Vec (`word2vec`), GloVe (`text2vec`), vecinos
  por coseno, analogías, `kmeans()` sobre vectores y embeddings de documento.
  Lea ese documento antes de escribir un script de análisis y use las
  funciones y convenciones que ahí se fijan.
- **Ampliar el catálogo:** lo que no se vio en los laboratorios (extracción de
  PDF con `pdftools`, lectura de series macro, regresiones texto–macro,
  diccionarios de tono) está en "Herramientas previstas" del catálogo y se
  documenta en su "Registro de ampliaciones" **antes de usarse**, con registro
  en "Decisiones tomadas". Sin ese registro, no se usa. La elección concreta de
  qué métodos entran al taller también se registra en "Decisiones tomadas".
- **Toda medida construida a partir del texto se valida con el texto.** Una
  frecuencia, un tono, un tópico o un índice solo entra a la presentación si
  va acompañado de ejemplos de los documentos que muestren qué captura (lo
  exige el enunciado). Para los tópicos, se reportan sus palabras más
  representativas y fragmentos de documentos con alta proporción del tópico, y
  el nombre que se les asigna se justifica con esos ejemplos.
- **Comunicados y minutas no son intercambiables.** Tienen propósito, extensión,
  frecuencia y estructura distintos (el comunicado anuncia la decisión el día de
  la reunión; la minuta resume la discusión y se publica después). Cada
  análisis declara qué tipo de documento usa, y cualquier comparación entre los
  dos lo hace explícito. Los dos tipos de documento se fechan con la fecha de
  la reunión (ver "Datos"); la fecha de publicación solo está en 31 minutas,
  con un rezago mediano de 14 días frente a la reunión.
- **Alineación temporal.** Los documentos son irregulares (8 a 12 reuniones por
  año) y las series macro tienen su propia frecuencia y rezago de publicación.
  Al cruzarlas, documentar la regla de alineación (p. ej. el último dato
  disponible a la fecha de la reunión, no el dato revisado posterior) para no
  usar información que la Junta no tenía.
  **Regla fijada el 2026-11-19 (paso P1.4 de `PLAN.md`; la aplica
  `07_graficas_macro.R` y la guarda en `01_Datos/03_Listos/macro_por_reunion.rds`,
  una fila por reunión):** a cada reunión se le asigna el último dato que la
  Junta tenía ese día.
  - Brent: el cierre del día hábil anterior a la reunión (último día con
    cotización antes de la fecha).
  - TRM: la vigente el día de la reunión (el Banco la publica el día hábil
    anterior).
  - Inflación total y núcleo 15: el IPC del mes m se publica a comienzos del
    mes m+1. **Supuesto:** publicado el día 8 del mes m+1 (conservador: el DANE
    suele publicar entre el 4 y el 8). Una reunión usa el último mes cuyo día
    8 siguiente es igual o anterior a la fecha de la reunión.
  - Brecha frente a la meta: inflación del mes del dato menos la meta del año
    de ese mes (en enero, el dato es de diciembre y usa la meta del año
    anterior).
  - Variaciones anuales en la reunión: Brent frente al último cierre de un año
    antes; TRM frente a la del mismo día de un año antes. Máximo del Brent en
    los 12 meses previos: cierres desde un año antes hasta el día anterior.
  Las series son las versiones actuales de los archivos, no las que se
  publicaron en su momento: el IPC y la TRM no se revisan, y el Brent de FRED
  tampoco, así que la diferencia no debería importar.
- **Asociación no es causalidad.** Que una medida de texto se mueva con una
  variable macro no muestra que una cause la otra: la Junta reacciona al
  contexto y también lo anticipa. Las afirmaciones causales requieren un
  diseño que las sostenga y se registran en "Decisiones tomadas".
- **Cuidado con los cambios de formato.** El número de documentos por año cambia
  (de 11–12 reuniones anuales a 8 desde 2018) y el formato de los documentos
  puede cambiar con el tiempo. Antes de interpretar una tendencia, descartar que
  venga de un cambio de formato o de extensión (p. ej. normalizar por número de
  palabras).
- Distinga siempre tres cosas al reportar un resultado: el **objeto de
  interés** (lo que se quiere conocer, p. ej. cuánta atención recibe la
  inflación), la **medida o estimador** (p. ej. la proporción de un tópico, un
  diccionario) y la **estimación** (el número obtenido).

## Datos

- El flujo es Crudos, Procesados, Listos. Nunca en sentido inverso.
- Reporte siempre cuántos documentos (u observaciones) se pierden al limpiar o
  filtrar, y por qué (p. ej. PDF escaneados sin texto extraíble, documentos
  duplicados).
- **Documentos de la Junta** (de `Comunicados_Minutas_Banrep.zip`,
  descomprimido el 2026-11-08 sin los metadatos `__MACOSX/` de macOS):
  - `01_Datos/01_Crudos/Comunicados_Minutas_Banrep/comunicados/`: 194 PDF,
    nombre `YYYY-MM-DD_comunicado.pdf`, de 2007-01-26 a 2026-09-30.
  - `01_Datos/01_Crudos/Comunicados_Minutas_Banrep/minutas/`: 199 PDF (el zip traía
    200; ver abajo el informe técnico), nombre
    `YYYY-MM-DD_minuta.pdf`, de 2007-06-15 a 2026-09-30.
  - La fecha del nombre del archivo es la llave para cruzar documentos entre sí
    y con las series macro. **Verificado el 2026-11-08: en las minutas es la
    fecha de la reunión, no la de publicación.**
    - 169 de 200 minutas dicen la fecha de la reunión en el encabezado o en la
      primera frase ("El 15 de junio de 2007 se celebró... la reunión"), y en
      todas coincide con el nombre. La minuta `2012-01-30` dice "30 de Enero de
      2011" en el título, pero el cuerpo dice 2012: es una errata del documento
      y el nombre es correcto.
    - Las 29 minutas de 2023-03-30 en adelante no traen ninguna fecha en el
      texto (el formato nuevo empieza con un titular de la decisión). Todas
      tienen un comunicado con la misma fecha, y el comunicado sale el día de la
      reunión; así que su nombre también es la fecha de la reunión.
    - **Solo 31 minutas dicen cuándo se publicaron** (verificado el
      2026-11-10 con `01_extraer_texto.R`): cierran con ciudad y fecha
      ("Bogotá D. C., enero 05 de 2009"), entre 2007-06-15 y 2017-07-27. En
      ellas el rezago frente a la reunión es de 14 días (mediana; mínimo 12,
      máximo 17). Queda en la columna `fecha_cierre_minuta` de
      `corpus_texto.rds`. Las otras 168 no traen esa fecha: si el análisis
      necesita cuándo llegó cada minuta al mercado (p. ej. reacción de
      precios), se supone el rezago de 14 días y se declara, o se consulta
      aparte y se registra como fuente. Las minutas de 2012 a 2019 traen
      además "Última modificación" de la página web, que puede ser posterior
      a la publicación y no se usa como fecha.
    - Los 131 comunicados que traen "Fecha de publicación" (hasta 2019-01)
      coinciden con la fecha del nombre del archivo.
    - Cruce comunicados–minutas: 188 fechas tienen los dos documentos; 11
      minutas no tienen comunicado (12 antes de sacar el informe técnico) (a unos 21–56 días del comunicado más
      cercano: reuniones cuyo comunicado no está en el zip) y 6 comunicados no
      tienen minuta (los 5 de enero a mayo de 2007, porque las minutas empiezan
      en junio de 2007, y `2019-08-30`).
  - **El zip traía como `minutas/2020-04-30_minuta.pdf` un documento que no es
    una minuta.** Es un informe del equipo técnico de 34 páginas,
    "Determinantes de las dinámicas de los mercados de capitales" (documento de
    trabajo, versión pública), con información hasta el 23 de abril de 2020.
    Mide unos 87 mil caracteres, frente a 3 mil a 30 mil de las minutas. Por
    decisión del usuario (2026-11-08) se movió a
    `Comunicados_Minutas_Banrep/2020-04-30_informe_tecnico_mercados_capitales.pdf`,
    fuera de `minutas/`, para que no se procese como minuta. Sigue disponible
    como documento aparte (p. ej. como muestra de lo que el equipo técnico
    presenta a la Junta). La reunión del 2020-04-30 queda sin minuta.
  - Documentos por año: 11–12 hasta 2017 y 8 desde 2018 (2026 llega hasta
    septiembre).
  - **El formato de las minutas cambia en el tiempo.** Mediana de caracteres
    por minuta: 11–23 mil en 2007–2013, 7–10 mil en 2014–2018, unos 3 mil en
    2019–2020, 6 mil en 2021–2022 y 8–10 mil en 2023–2026. En las minutas
    revisadas, la de 2016-02-19 aún trae una sección con la visión del equipo
    técnico y la de 2020-01-31 ya solo reseña la discusión de la Junta.
    **Cortes ubicados el 2026-11-10** (`01_extraer_texto.R`, tabla
    `03_Resultados/Tablas/01_extraer_texto/minutas_cortes_formato.png`):
    formato A desde 2007-06-15 (antecedentes del equipo técnico + discusión +
    decisión), B desde 2014-05-30 (síntesis del equipo técnico + discusión +
    decisión), C desde 2019-06-21 (sin sección del equipo técnico), D desde
    2020-07-31 (texto corrido) y E desde 2023-03-30 (titular con la decisión).
    En A y B solo 27–30 % del texto es discusión de la Junta. Toda medida de texto sobre minutas se
    normaliza por extensión y se interpreta teniendo en cuenta estos cortes
    (ver "Cuidado con los cambios de formato").
- **Series macroeconómicas:** las elige el equipo. Para cada una se documenta
  en "Definición de variables": por qué se eligió, fuente (con URL), cobertura,
  frecuencia y transformaciones (p. ej. variación anual, brecha frente a la meta
  de inflación). Candidatas naturales para un banco central con meta de
  inflación (**por decidir**; con la pregunta del 2026-11-18, la historia se
  cuenta con el precio del petróleo, la tasa de cambio y la inflación; ver
  "Decisiones tomadas"): tasa de intervención, inflación total y
  básica, expectativas de inflación, meta de inflación, crecimiento del PIB o
  ISE, desempleo, tasa de cambio, tasa de la Fed, precio del petróleo.

## Formato de las gráficas

Se mantiene el formato de los talleres anteriores para que las figuras se vean
como una sola familia. El formato debe vivir en un único lugar,
`02_Scripts/00_formato_graficas.R` (traído del Taller 2 y adaptado el
2026-11-10); ese script no genera figuras,
solo define paleta, tema y exportación.

- **Regla:** cualquier script que produzca figuras debe empezar con
  `source("02_Scripts/00_formato_graficas.R")` y usar lo que ahí se define.
  No redefina colores, temas ni tamaños dentro de un script de análisis: si
  algo del formato debe cambiar, cámbielo en `00_formato_graficas.R` para que
  el cambio aplique a todas las figuras a la vez.
- **Paleta:** `paleta_categorica`, terna sobria de azul (`#2B5FA3`), ocre
  (`#B8863B`) y verde-azulado (`#0E8A6C`), distinguibles entre sí incluso con
  daltonismo. Los grises (`gris_texto`, `gris_secundario`, `gris_nota`,
  `gris_grilla`) son estructura, no categorías. Una misma categoría conserva su
  color en todas las figuras (p. ej. comunicados siempre del mismo color y
  minutas del otro; cada tópico siempre con el mismo color).
- **Tema:** `tema_presentacion` (más `tema_paneles` si la gráfica usa facetas).
- **Título:** describe qué muestra la figura, en español y sin tecnicismos del
  código. La regla de "el título comunica la conclusión" aplica a los títulos de
  las diapositivas, no a los de las figuras.
- **Subtítulo:** declara siempre la fuente de la figura (comunicados, minutas,
  serie macro y su fuente) y el periodo.
- **Nota al pie (`caption`):** reporta el `n` de documentos y, cuando hay una
  línea de referencia, qué marca. En series de tiempo con texto y macro,
  indicar la regla de alineación temporal. **Las fuentes van siempre en el
  último renglón** (decidido el 2026-11-21): primero la información relevante
  para leer la figura (qué marcan el sombreado y las líneas, `n`, regla de
  alineación) y al final las fuentes de los datos. **Una oración por renglón**
  (decidido el 2026-11-21): el `caption` se arma con
  `paste(oracion_1, oracion_2, ..., sep = "\n")` y `guardar_figura()` parte cada
  renglón por aparte según el ancho de la figura, para mejorar la legibilidad.
- **Series de tiempo:** el eje x es la fecha de la reunión; se sugiere marcar
  episodios de referencia (p. ej. ciclos de la tasa de intervención, pandemia)
  con sombreado gris tenue, definidos una sola vez en el script de formato.
- **Nombres de archivo:** `03_Resultados/Figuras/<script>/<fuente>_<contenido>.png`,
  con `<fuente>` = `comunicados`, `minutas`, `macro` o `conjunto`.
- **Exportación:** siempre con `guardar_figura()` (9×6 pulgadas, 300 dpi, fondo
  blanco explícito). `guardar_figura()` no crea carpetas: asume que
  `00_main.R` ya verificó `03_Resultados/Figuras/`.
- La figura que entra a la diapositiva es la exportada, sin retoques manuales:
  si algo debe verse distinto en la presentación, se cambia en el código.
- Las nubes de palabras no reemplazan una medida: si se usan, acompañan una
  tabla o figura cuantitativa.

## Primero el diseño, después los resultados

- No emita juicios sobre si un resultado es "bueno" o "malo".
- No exprese entusiasmo por una métrica, un coeficiente ni por su significancia.
- Mientras el diseño no esté resuelto (pregunta, medidas, series, alineación),
  lo único relevante es si la especificación es correcta.
- Una correlación alta entre texto y macro no implica que la medida capture lo
  que se cree: reporte la magnitud, la incertidumbre y los ejemplos textuales.

## Integrantes

| Nombre                    | Rol / responsabilidad | Contacto                                                          |
| ------------------------- | --------------------- | ----------------------------------------------------------------- |
| Samuel Escandón           | Por definir           | [s.escandoc@uniandes.edu.co](mailto:s.escandoc@uniandes.edu.co)   |
| Douglas Plazas Guzmán     | Por definir           | [d.plazasg@uniandes.edu.co](mailto:d.plazasg@uniandes.edu.co)     |
| Mateo Olmos Becerra       | Por definir           | [m.olmosb@uniandes.edu.co](mailto:m.olmosb@uniandes.edu.co)       |
| Santiago Muñoz Martínez   | Por definir           | [s.munozm234@uniandes.edu.co](mailto:s.munozm234@uniandes.edu.co) |

<!-- Mismo equipo del Taller 2; confirmar la conformación del grupo y asignar
     roles para el Taller 3. -->

## Decisiones tomadas

<!-- Registro acumulado de decisiones metodológicas y su justificación, para no
     perder de vista por qué se hizo algo varias semanas después. -->

| Fecha      | Decisión | Justificación |
| ---------- | -------- | ------------- |
| (heredada) | Estructura de carpetas, `00_main.R` con `pacman`, una carpeta de resultados por script, tablas en formato final, notas de hallazgos, bitácoras, `HANDOFF.md` y una rama por integrante, como en el Taller 2. | Es el flujo que ya conoce el equipo y que incorporó la retroalimentación del Taller 1 (repositorio con 100/100). |
| (heredada) | Las conversaciones con los agentes (`.jsonl`) se guardan localmente en `09_Conversaciones/` (ignorada por git) y al final se unen por aparte. | Igual que en el Taller 2: evita conflictos y subir registros crudos, y cumple con el registro que pide la rúbrica. |
| 2026-11-08 | Los métodos, paquetes y funciones se limitan al catálogo `07_Recursos/catalogo_metodos.md` (Labs 11 y 12: limpieza, TF-IDF, DTM, bigramas, correlación entre palabras, LDA con selección de hiperparámetros y validación). Toda ampliación se documenta primero en su "Registro de ampliaciones". | Son las herramientas de texto vistas en clase, como pide el enunciado; mismo esquema que el Taller 2. |
| 2026-11-08 | El PDF `minutas/2020-04-30_minuta.pdf` se mueve a `Comunicados_Minutas_Banrep/` con el nombre `2020-04-30_informe_tecnico_mercados_capitales.pdf`; no entra al corpus de minutas, pero se conserva en los datos crudos por si se usa aparte. | Es un informe del equipo técnico, no una minuta (ver "Datos"); con 87 mil caracteres distorsionaría cualquier medida de texto sobre minutas. Excepción a "nunca se modifica `01_Crudos/`", autorizada por el usuario: se movió y renombró, sin editar su contenido. |
| 2026-11-08 | Los PDF del zip se guardan en `01_Datos/01_Crudos/Comunicados_Minutas_Banrep/{comunicados,minutas}/`, sin la carpeta `__MACOSX/`; el zip original queda en la raíz, ignorado por git. | Una carpeta dedicada separa los documentos de la Junta de las series macro que se agregarán después; `__MACOSX/` solo contiene metadatos de macOS. |
| 2026-11-10 | Ampliación del catálogo: `pdftools::pdf_text()` para extraer el texto de los PDF y `gt` (con Chrome en modo headless) para exportar las tablas. Aprobado por Samuel Escandón; registrado en "Registro de ampliaciones" de `07_Recursos/catalogo_metodos.md`. | Los documentos vienen en PDF y los laboratorios partían de un `.csv`; `gt` es el formato de tablas del Taller 2 (presentación, no método de análisis). |
| 2026-11-10 | Decisiones **provisionales** de la sesión exploratoria (scripts `01` a `05`), a revisar cuando se fije la pregunta: (i) diez periodos a priori, abiertos por la primera reunión que cambia la dirección de la tasa (`00_funciones_texto.R`; cita de cada decisión en `03_Resultados/Tablas/01_extraer_texto/conjunto_periodos.csv`); (ii) cinco formatos de minuta (cortes en 2014-05-30, 2019-06-21, 2020-07-31 y 2023-03-30) y dos versiones del texto de las minutas: completo y solo la discusión de la Junta, que es la que importa para la pregunta; el preámbulo de asistentes no entra a ningún análisis; (iii) «tasa de intervención» y «tasa de política» se unen en `tasa_intervencion`; «tasa de referencia» queda como token aparte (31 % de sus menciones está en una oración con un referente externo) y las variantes seguidas de un banco central externo pasan a `tasa_externa`; (iv) los tokens con dígitos se eliminan y las cifras no se extraen; (v) no se amplió la lista de palabras vacías de dominio; (vi) recorte de vocabulario para LDA: palabras en 5 o más documentos y en no más del 75 %; (vii) LDA exploratorio en minutas con K = 6 y K = 10, por defecto (VEM) y con Gibbs y los hiperparámetros del Lab 12, sin selección de hiperparámetros. | Conocer el corpus antes de elegir la pregunta. Los periodos se fijaron antes de ver las medidas de texto. El LDA por defecto estima un alfa mayor que 100 y no separa tópicos, por lo que se agregó la versión con Gibbs del catálogo. Nada de esto es todavía una medida del taller. |
| 2026-11-10 | **Regla de las fronteras de los periodos.** Cada periodo lo abre la primera reunión cuya decisión cambia la dirección de la tasa respecto del ciclo anterior, verificada contra la decisión que anuncia el comunicado (no contra el resto del texto): P1 2007-01-26 (alza), P2 2008-12-19 (primer recorte), P3 2011-02-25 (primera alza), P5 2016-12-16 (primer recorte), P6 2020-03-27 (primer recorte de la pandemia; citado de la minuta porque los datos no traen comunicados entre 2020-01-31 y 2020-05-29), P7 2021-09-30 (primera alza), P8 2023-12-19 (primer recorte), P9 2025-06-27 (primera de cinco reuniones sin cambio en 9,25 %) y P10 2026-01-30 (primera alza). **P4 (2014-09-26) es el único periodo de P1 a P8 que abre con una pausa**: la primera reunión que mantiene la tasa en 4,5 % después de las alzas de abril a agosto de 2014; se usa porque ninguna decisión de tasa marca el comienzo del choque petrolero y las alzas contra la inflación solo empiezan en 2015-09-25. P9 también abre con una pausa, por definición. | Fronteras definidas por un hecho observable y fechado, fijadas antes de ver las medidas de texto. Frente a la propuesta inicial cambiaron P2 (antes 2008-09), P3 (antes 2011-01), P4 (antes 2014-07) y P6. Tabla con las citas: `03_Resultados/Tablas/01_extraer_texto/conjunto_periodos.png`. |
| 2026-11-10 | **Desviación de lo previsto: LDA con muestreo de Gibbs además del LDA por defecto.** La sesión exploratoria debía usar solo el LDA por defecto de `topicmodels` (VEM, K y semilla). Ese modelo estimó α = 114,3 con K = 6 y α = 87,7 con K = 10 y dejó todas las minutas con un peso casi igual en todos los tópicos (θ cerca de 1/K): no separa temas. Se agregó el LDA con Gibbs del catálogo (sección 6) con α = 0,1, δ = 1, 1.000 iteraciones y 200 de calentamiento. **α y δ son los del Lab 12, sin seleccionar para este corpus**; K = 6 y K = 10 tampoco se eligieron con ningún criterio. Los tópicos no se nombran. | Sin la versión con Gibbs no había tópicos preliminares que revisar. Resultado exploratorio: con la minuta entera como documento, los tópicos separan épocas y formatos, no temas; no es una medida del taller. Queda en la bitácora, sin nota de hallazgo. |
| 2026-11-10 | **Token `tasa_externa`.** Cualquier forma de nombrar una tasa de política («tasa de [interés de] intervención / política [monetaria] / referencia») que va seguida de «de / en» y un banco central o país externo (Reserva Federal, Fed, BCE, Banco Central Europeo, Estados Unidos, EE. UU., bancos centrales, Banco de Inglaterra, Banco de Japón) se reemplaza por `tasa_externa` antes de unir las demás variantes en `tasa_intervencion` (`unificar_tasas()` en `00_funciones_texto.R`). | «Tasa de política» también nombra la tasa de otros bancos centrales (p. ej. «tasa de interés de política de la Reserva Federal», comunicado 2019-06-21): 9–15 % de sus menciones está en una oración con un referente externo y 2–5 % lo lleva pegado. Sin este token, esas menciones contarían como la tasa del Banco de la República. Conteos en `03_Resultados/Tablas/02_limpiar_texto/conjunto_variantes_tasa.png`. |
| 2026-11-18 | **Primeras series macro y ampliación `readxl`.** Se incorporan tres fuentes descargadas a mano (inflación anual y tasa de cambio real del Banco de la República; Brent de FRED), todas desde 2000-01-01, guardadas como `.rds` en `03_Listos/` por `06_series_macro.R`. `readxl::read_excel()` se registra en el catálogo y se agrega al `p_load()`. Es un paso de datos: no decide qué series entran al análisis ni cómo se alinean con las reuniones. | Los archivos se descargaron a mano, así que el crudo se versiona y la fuente exacta (URL y fecha de consulta) queda en "Definición de variables" y en el README, como exige "Reproducibilidad". Aprobado por Santiago Muñoz Martínez al pedir el script. |
| 2026-11-18 | **Paso 4 de la limpieza descarta símbolos, no solo dígitos.** En `02_limpiar_texto.R` un token solo se conserva si cumple `^[a-zñ_]+(-[a-zñ_]+)*$` (letras, `_` de los compuestos y guion interno), y el guion final se quita antes de filtrar (verbos cortados a fin de renglón, «registrar-» → «registrar»). Quedan fuera restos de formato como «-ar», «*estar», «m/n» y «#juntabanrep». Los guiones internos se conservan («minero-energetico», «sub-canasta»). | Medido antes del cambio: 383 tokens (0,2 %) con símbolos y 122 términos afectados. Efecto: 176.750 → 176.622 tokens limpios y 3.884 → 3.807 términos distintos; el paso 4 pasa de quitar 50 a 164 tokens en minutas completas. Es un cambio mecánico, sin juicio de contenido; no se tocaron las listas de palabras vacías. Las tablas que sostienen las tres notas de `05_Notas/` no cambiaron. |
| 2026-11-18 | **Pregunta del taller:** «¿Cómo cambiaron los temas de interés de la Junta del Banco de la República antes y después de la crisis del petróleo de 2014 en Colombia?». Las series macro (caída del precio del petróleo, aumento de la TRM, efecto sobre la inflación) cuentan la historia y se relacionan con los cambios de temas. Método previsto: embeddings de palabras (GloVe o Word2Vec) para comparar de qué se hablaba antes y después. **Pendiente de definir:** la fecha de corte antes/después (candidato de partida: el periodo P4, que abre el 2014-09-26 y ya está fijado a priori, sin ver medidas de texto; el Brent empieza a caer a mediados de 2014), el tipo de documento (comunicados, minutas o ambos; en minutas, la versión «solo discusión de la Junta»), el paquete de embeddings y su especificación (dimensión, ventana, unidad de texto, cómo comparar dos épocas) y el papel de LDA (ya en el catálogo) frente a los embeddings. | Pregunta acordada por el equipo y comunicada por Santiago Muñoz Martínez. **Los embeddings (GloVe/Word2Vec) están en "Fuera del catálogo" de `07_Recursos/catalogo_metodos.md`**: según la regla metodológica no se usan hasta registrarlos en su "Registro de ampliaciones" con paquete, función y aprobación del equipo. Riesgos a vigilar: (i) el corpus es pequeño (unas 177 mil palabras tras la limpieza, en total) para entrenar embeddings y partirlo en dos épocas; (ii) los cambios de formato de las minutas (ver "Datos") pueden confundirse con cambio de temas; (iii) la historia macro es asociativa, no causal. |
| 2026-11-18 | **Falta la TRM nominal (resuelto el 2026-11-18: `TRM.csv`, SUAMECA, procesada en `06_series_macro.R`).** Había descargadas tres fuentes (Brent diario de FRED, inflación anual y *tasa de cambio real*; ver "Definición de variables"). La pregunta habla de la TRM (tasa de cambio nominal, COP/USD), que no está descargada: se consigue y documenta (fuente con URL y fecha de consulta) o se justifica usar la tasa de cambio real. | La pregunta menciona explícitamente el aumento de la TRM; el índice de tasa de cambio real no es la misma serie. |
| 2026-11-19 | **Fecha de corte antes/después del choque petrolero: 2014-10-30 (H2 de `PLAN.md`).** Regla (i): primera reunión de la Junta en que el Brent que tenía (cierre del día hábil anterior) estaba 20 % o más por debajo de su máximo de los 12 meses previos, buscando desde el 2014-01-01. El primer día en que se cumple es el 2014-10-02 y la primera reunión, el 2014-10-30 (Brent 86,9 USD, −24,6 % frente al máximo; TRM 2.045, +8,6 % anual; inflación total 2,9 %). «Antes» = reuniones anteriores al 2014-10-30; «después» = desde esa fecha. **Cortes alternativos para la robustez de H4:** (a) 2014-09-26, apertura de P4 (primera reunión sin alza tras el ciclo de abril a agosto de 2014; Brent −17,4 %); (b) 2014-12-19, primera reunión con depreciación anual de la TRM mayor que 20 % (+20,0 %; Brent −48,9 %). Las fechas viven en `corte_crisis` y `cortes_alternativos` (`00_funciones_texto.R`); `07_graficas_macro.R` recalcula las reglas y se detiene si dejan de coincidir. **Salvedad de formato:** el corte no coincide con el cambio de formato de las minutas (A → B el 2014-05-30): antes del corte quedan 5 minutas del formato B (4 con la alternativa (a) y 7 con la (b)). En una ventana de 5 años, los comunicados quedan equilibrados (54 reuniones y unas 29.700 palabras antes; 53 y unas 30.600 después), pero las minutas no (59 reuniones y unas 43.800 palabras de la discusión de la Junta antes; 53 y unas 23.100 después): la diferencia es de formato y hay que normalizar por extensión. | Fijado solo con las series macro alineadas por reunión y con las decisiones de tasa, sin mirar ninguna medida de texto, para que el antes/después no se elija donde más cambia el texto. Se prefiere la regla (i) porque usa la variable de la pregunta (el precio del petróleo) con el umbral convencional de un mercado bajista: la apertura de P4 marca el fin de las alzas de 2014, que respondían a la demanda interna y no al petróleo, y la depreciación de la TRM es el canal de transmisión, no el choque. Solo una reunión cambia de lado frente a la apertura de P4. Aprobado por Samuel Escandón. Tablas: `03_Resultados/Tablas/07_graficas_macro/macro_cortes_candidatos.png` y `conjunto_ventanas_corte.png`. |
| 2026-11-21 | **Medidas antes/después del corte (H3 de `PLAN.md`), acordadas por el equipo.** H3 se divide en cuatro partes, cada una con su script para trabajar en paralelo: **H3a** `08_antes_despues.R` (TF-IDF de palabras distintivas antes y después, atención a cada tema del diccionario `temas` por 1.000 palabras y por reunión, y bigramas más frecuentes; minutas —solo discusión de la Junta— y comunicados por separado); **H3b** `09_lda_oraciones.R` (un solo LDA para 2007–2026 con párrafos o bloques de 60 a 100 palabras como documento, sin verbos, K ∈ {6, 8, 10, 12, 15} con Gibbs α = 0,1 y δ = 0,1, el K más pequeño a menos del 5 % de la perplejidad mínima salvo que su coherencia UMass media sea la peor, y diferencia de θ por reunión antes/después con IC 95 %); **H3c** `10_word2vec.R` (un solo modelo Word2Vec con las anclas marcadas por época, contrastado con `pairwise_cor()`); **H3d** robustez común (cortes alternativos, comunicados como control del formato, ventana de 5 años a cada lado). La interpretación pasa a H4. Reemplaza el hito H3 del 2026-11-21 (LDA con la minuta entera y K por suma de rangos), que no se había ejecutado ni registrado como regla. | En `05`, con la minuta entera como documento, los tópicos separaban épocas y formatos; un LDA antes/después así mostraría «cambio» por construcción. Por eso la unidad baja a párrafo o bloque, se estima un solo modelo y el cambio se mide en θ. Las tres medidas se contrastan entre sí (heurística H2). TF-IDF, bigramas, `pairwise_cor()` y LDA ya están en el catálogo; **Word2Vec sigue pendiente de ampliación** y no se usa hasta registrarlo. La regla de selección de K de H3b se registra aparte, con sus resultados, antes de ver los tópicos. Comunicada por Samuel Escandón. |
| 2026-11-21 | **Diseño de `09_antes_despues.R` (H3b de `PLAN.md`; reemplaza el antiguo H3a `08_antes_despues.R`: el 08 queda para el LDA y el 10 para los embeddings).** Épocas: 5 años a cada lado del 2014-10-30 (2009-10-30 a 2019-10-29); robustez en tablas con la muestra completa 2007–2026 y los dos cortes alternativos. Minutas solo con la discusión de la Junta y comunicados en paralelo como control de formato. Medida principal de palabras y bigramas: razón de frecuencias por 1.000 palabras, después / antes, con +0,5 a cada lado; mínimos de 20 apariciones (palabras) y 10 (bigramas); TF-IDF de dos grupos como complemento. Atención por tema: diccionario `temas` sin cambios, media por reunión y diferencia con IC 95 % (t de Welch). Correlaciones: `pairwise_cor()` con la **oración de udpipe** como documento (no `partir_oraciones()`) y mínimo de 10 oraciones; se agregó el ancla `precio_petroleo`. Regla de lectura fijada antes de ver resultados: «posible artefacto de formato» si un cambio en minutas va en contra de los comunicados; «robusta» si la dirección se mantiene en los tres escenarios de robustez; «matizada» si no. `widyr` entra al `p_load()` (ya en el catálogo). | Con dos épocas, el idf solo vale 0 o log(2), así que el TF-IDF no ordena las palabras compartidas. La oración de udpipe reutiliza los lemas y el vocabulario limpio de `02` sin volver a lematizar. `precio_petroleo` se agrega porque el diccionario de compuestos une «precio(s) del petróleo» y «petroleo» solo queda en 21 y 7 oraciones de las minutas. Pedido por Samuel Escandón. |
| 2026-11-21 | **Diseño del LDA: H3a, `08_lda_oraciones.R`** (corrige la numeración de las dos filas anteriores: H3a = LDA en `08`, H3b = `09_antes_despues.R`, H3c = `10_word2vec.R`). Documento: bloques de oraciones consecutivas de udpipe que se cierran al llegar a un umbral de palabras. El umbral se fija antes del modelo, sin ver tópicos: el más pequeño de {60, 80, 100} cuya mediana de palabras útiles por bloque (limpias, sin verbos y después del recorte de 5 bloques y 75 %) es de 20 o más. Resultado: 60 palabras (1.619 bloques en la ventana; mediana de 23 palabras útiles; en las minutas, mediana de 9 bloques por reunión antes del corte y 6 después). Tabla: `03_Resultados/Tablas/08_lda_oraciones/conjunto_lda_umbral_bloques.png`. Un solo modelo con la discusión de la Junta en las minutas y los comunicados, sin verbos, **estimado con la ventana principal (2009-10-30 a 2019-10-29)**; el vocabulario y la selección de K y α también se calculan en la ventana, y fuera de ella θ sale de `posterior()` (muestra completa, bordes de los cortes alternativos y figura 2007–2026). Esto reemplaza el «un solo LDA para 2007–2026» de la fila de medidas del 2026-11-21: así queda coherente con `09`, donde toda medida calculada con los datos (razón de frecuencias, TF-IDF, bigramas, atención) se calcula dentro de la muestra de cada escenario, y solo el diccionario fijo se usa en 2007–2026. Matriz del modelo: 1.619 bloques × 656 términos. **Resultado de la selección (2026-11-21): K = 10 y α = 0,1** (perplejidad 240,3, 3,0 % sobre el mínimo de K = 15; coherencia media −69,6; K = 15 tiene la peor coherencia, −76,3). La rejilla de validación cruzada usa 300 iteraciones, como el Lab 12. 8 de los 10 tópicos se repiten con las semillas 2027 y 2028. **Nombres (P3a.7, aprobados por Santiago Muñoz Martínez el 2026-11-21, con las palabras de mayor lift y β y los 3 bloques de mayor θ):** 1 Actividad económica interna, 2 Crédito y sistema financiero, 3 Decisión y postura de política monetaria, 4 Inflación por depreciación y alimentos, 6 Déficit externo y capacidad productiva, 7 Seguimiento y provisión de liquidez, 8 Inflación básica y expectativas frente a la meta, 10 Economía mundial; 5 y 9 no se nombran. **Salvedad de la alerta de formato:** en la ventana, el formato B (desde 2014-05-30) casi coincide con la época «después», así que «más del 70 % en un formato» no separa formato de época; se informa como «posible artefacto de formato o de época», y lo decide el contraste con los comunicados (regla de lectura de `09`). Tabla: `03_Resultados/Tablas/08_lda_oraciones/conjunto_lda_seleccion.png`. **Contraste con el diccionario de `09` (P3a.9, 2026-11-21):** equivalencias fijadas antes de calcular (Actividad económica = tópico 1; Inflación = 4 y 8; Entorno externo = 6 y 10); correlación por reunión en la ventana de 0,53 en actividad, de 0,71 y 0,73 en inflación (4 + 8) y, en entorno externo (6 + 10), de 0,39 en las minutas y 0,04 en los comunicados. Con la confirmación de Santiago Muñoz Martínez, la nota `05_Notas/08_lda_oraciones/T_choque_externo_llega_a_colombia.md` se matizó: las dos medidas coinciden en la dirección antes/después y, reunión a reunión, solo en las minutas (tabla `conjunto_lda_vs_diccionario.png`). **Figuras por reunión recortadas a 2007–2019** (decisión de Santiago Muñoz Martínez): desde 2020 entra la pandemia, otro choque que habría que explicar aparte; el `.csv` de θ por reunión sigue con 2007–2026. **Regla de selección, fijada antes de ver tópicos:** Gibbs con δ = 0,1, rejilla K ∈ {6, 8, 10, 12, 15} × α ∈ {0,05; 0,1; 0,5; 1}, perplejidad por *document completion* con 3 pliegues aleatorios por bloque y coherencia UMass. Para cada K se toma el α con menor perplejidad; se elige el K más pequeño a menos del 5 % de la perplejidad mínima, y si su coherencia media es la peor de los K, se pasa al siguiente K que cumpla. El modelo final (semilla 2026) se repite con las semillas 2027 y 2028: solo se nombran los tópicos cuyo β tiene una correlación de 0,8 o más con algún tópico de cada una de las otras dos estimaciones. Un tópico con más del 70 % de su peso en un solo formato de minuta se marca como posible artefacto de formato. Medida: θ promedio por reunión, antes frente a después, con IC 95 %. Si no alcanza el tiempo (3 horas), K = 10 y α = 0,1, y se declara. | Combina la versión del equipo (párrafos, un solo modelo, θ por reunión) con la rejilla de α, la prueba de semillas y la alerta de formato de la versión anterior de `PLAN.md`. Las funciones del LDA viven en `08`; a `00_funciones_texto.R` solo pasan `asignar_epoca()` y `escenarios` (definiciones del diseño, que comparten `08`, `09` y `10`). Con la minuta entera, los tópicos separaban formatos (ver `05`), y el corte (2014-10-30) casi coincide con el cambio de formato A→B (2014-05-30). α se selecciona porque el valor del Lab 12 no está calibrado para este corpus. Las semillas adicionales se agregan porque, con documentos cortos, los tópicos pueden ser inestables. Acordado por Santiago Muñoz Martínez. Detalle en `PLAN.md`, pasos P3a.1 a P3a.12. |
| 2026-11-21 | **Lab 13 al catálogo: embeddings de palabras.** Se agregan a `07_Recursos/catalogo_metodos.md` (secciones 10 a 14) los métodos del Laboratorio 13: Word2Vec skip-gram (`word2vec::word2vec()`, `as.matrix()`, `predict(type = "nearest")`), GloVe (`text2vec`: `itoken()`, `create_vocabulary()`, `create_tcm()`, `GlobalVectors$new()`), vecinos por coseno y analogías (`sim2()`), PCA con `plotly` para explorar, `kmeans()` sobre vectores normalizados y embeddings de documento (promedio de vectores). Los embeddings dejan de ser ampliación; siguen fuera la alineación de espacios estimados por separado (Procrustes) y los vectores preentrenados completos. Reproducibilidad: `word2vec()` no tiene argumento de semilla, así que se usa `set.seed(2026)` antes de entrenar y `threads = 1`, como el lab (que usa la semilla 123). La especificación de H3c quedó en la fila siguiente (al final se usó GloVe, con `text2vec` en el `p_load()`). | El Lab 13 se vio en clase, así que estos métodos son herramientas del curso, como pide el enunciado. Pedido por Santiago Muñoz Martínez. |
| 2026-11-21 | **Diseño de embeddings: H3c, `10_glove.R`** (fijado antes de ver los vecinos). **Método: GloVe (`text2vec`), no Word2Vec.** Se programó primero con `word2vec::word2vec()` (skip-gram del Lab 13), pero ese paquete no usa la semilla de R: con `set.seed()` y `threads = 1`, cinco corridas iguales dieron 12 a 18 palabras distintas entre los 10 vecinos de cada ancla y época (solo 5 a 8 se repetían en las cinco) y el coseno antes–después varió hasta 0,06. GloVe con `n_threads = 1` da exactamente el mismo resultado en cada corrida (verificado). Un solo modelo GloVe con la especificación del Lab 13 (`rank = 50`, `x_max = 10`, ventana 5, `term_count_min = 5`, 50 iteraciones), entrenado con 2007–2026 y con comunicados y discusión de la Junta juntos. Documento = oración de udpipe con las palabras limpias de `tokens_anotados.rds` (la misma unidad de `pairwise_cor()` en `09`). En la ventana principal (2009-10-30 a 2019-10-29) cada ancla se reemplaza por `ancla_antes` / `ancla_despues`, para tener dos vectores en el mismo espacio sin alinear modelos. **Anclas:** las de `09` con 30 o más oraciones en cada época, sumando las dos fuentes (`conjunto_anclas_oraciones.csv`): `inflacion` (479/474), `expectativas_inflacion` (166/154), `crecimiento` (658/246) y `tasa_intervencion` (256/230); quedan fuera `deficit` (2/115), `tasa_cambio` (25/36) y `petroleo`/`precio_petroleo`. Los vecinos excluyen el ancla sin marca, que es la misma palabra fuera de la ventana. Semillas 2026, 2027 y 2028: se promedia el coseno, se reportan los 10 vecinos del promedio y se marcan los que no están en el top 10 de alguna semilla. Medidas: vecinos por época, coseno entre `ancla_antes` y `ancla_despues`, y cuántos vecinos coinciden con las 8 palabras phi de `09`. Reemplaza P3c.2 a P3c.8 de `PLAN.md` (sin Jaccard: lo reemplaza el coseno antes–después). **Robustez con Word2Vec (agregada el mismo día):** `10_glove.R` también estima Word2Vec skip-gram con el mismo texto y las mismas anclas (5 entrenamientos promediados; no se reproduce exactamente, se declara en la tabla) y guarda `conjunto_w2v_vecinos_detalle.csv` y la columna de coseno «Word2Vec». Coinciden en que las expectativas son el ancla que más cambia (0,31 y 0,61) y en meta y convergencia como vecinos de «inflación» después del corte; el anclaje de las expectativas y el papel de control de la tasa solo aparecen con GloVe, así que la nota `T_contexto_inflacion_expectativas.md` pasó a «matizado» (confirmado por Santiago Muñoz Martínez). `word2vec` vuelve al `p_load()`. | Versión mínima por el tiempo de entrega: una sola tabla que pone a prueba el hallazgo 4 («la inflación no recibió más espacio, recibió otra discusión») con una medida de segundo orden que `pairwise_cor()` no captura. Por separado, comunicados y minutas quedan con muy pocas oraciones por ancla y época. Acordado por Santiago Muñoz Martínez. |
| 2026-11-21 | **Figuras para diapositiva (`11_figuras_diapositiva.R`) y verificación del momento del cambio.** `11` solo lee resultados guardados de `07`, `08` y `09` y los redibuja en 16:9 con letra grande; las cifras no cambian. En `00_formato_graficas.R` se agregan `tema_diapositiva` y `colores_macro_diapositiva` (Brent y TRM en grises, inflación en verde-azulado), para que las series macro no repitan el azul y el ocre de comunicados y minutas. Verificación, regla fijada antes de ver el resultado: la media móvil de 5 reuniones del tópico 4 del LDA y del tema «Entorno externo», por tipo de documento, se compara con su máximo de los 5 años antes del corte; la figura solo se genera si las dos medidas lo superan antes de la primera alza (2015-09-25) en comunicados y en minutas. Resultado: el entorno externo lo supera antes (2014-12-19 y 2015-03-20) y el tópico 4 después (2015-11-27) o nunca (minutas), así que la figura no se generó. El borrador del deck (`04_Presentaciones/borrador_presentacion.pptx`) lo arma `04_Presentaciones/construir_borrador.py` con `python-pptx`, fuera de `00_main.R`. | Pedido por Samuel Escandón para la presentación del 22 de noviembre. La verificación matiza `05_Notas/09_antes_despues/X_atencion_se_adelanta_a_las_series.md` (nota nueva en `05_Notas/11_figuras_diapositiva/`). El deck es un borrador, no un resultado del análisis, por eso no entra al pipeline. |
| 2026-11-22 | **Renumeración: `08_antes_despues.R` y `09_lda_oraciones.R` (antes `09_antes_despues.R` y `08_lda_oraciones.R`).** Se invirtieron los números de los dos scripts, con sus subcarpetas de `03_Resultados/Tablas/`, `03_Resultados/Figuras/` y `05_Notas/` (`git mv`), y se actualizaron `00_main.R`, el README, `PLAN.md`, los scripts, el borrador del deck y el estado vigente de `HANDOFF.md`. **Las filas anteriores de esta tabla, las bitácoras y el registro de sesiones de `HANDOFF.md` conservan los nombres viejos: donde digan `08_lda_oraciones` léase `09_lda_oraciones`, y donde digan `09_antes_despues`, `08_antes_despues`.** Los hitos de `PLAN.md` conservan sus letras (H3a = LDA, H3b = antes/después). | El LDA lee resultados de `09_antes_despues.R` (`conjunto_temas_por_reunion.csv` y `conjunto_documentos_por_epoca.csv`) y se ejecutaba antes: con las carpetas de resultados borradas, `00_main.R` se detenía en el LDA. Un `00_main.R` que ejecuta los scripts «en el orden de su numeración» exige que el número de un script sea mayor que el de los scripts de los que lee. Verificado el 2026-11-22 con una corrida completa desde cero en una copia del repositorio. Pedido por Santiago Muñoz Martínez. |

## Análisis descartados

<!-- Especificaciones, variables o enfoques que se probaron y abandonaron, con
     la razón, para no repetir procedimientos ya infructuosos. -->

| Fecha | Análisis/especificación descartada | Razón |
| ----- | ---------------------------------- | ----- |
| 2026-11-21 | LDA con la minuta entera como documento (antiguo H3 `08_lda.R`: K × α con suma de rangos, solo minutas). | En `05` los tópicos con la minuta entera separaban épocas y formatos. Un antes/después así mostraría cambio por construcción. Lo reemplaza H3a (`08_lda_oraciones.R`). |

## Definición de variables

<!-- Definición operativa de cada variable usada en el análisis: qué incluye,
     unidades, frecuencia, periodo, fuente y transformaciones. -->

| Variable | Definición | Fuente | Cobertura y frecuencia | Transformaciones |
| -------- | ---------- | ------ | ---------------------- | ---------------- |
| `fecha` | Fecha del documento, tomada del nombre del archivo (`YYYY-MM-DD`). | Nombre de los PDF | 2007-01 a 2026-09; por reunión | Ninguna |
| `tipo_documento` | `comunicado` o `minuta`, según la carpeta y el nombre del archivo. | Nombre de los PDF | Igual | Ninguna |
| `brent_usd` | Precio spot del petróleo Brent, Europa, en dólares por barril. Se descargó como contexto externo de un país exportador de petróleo; su uso en el análisis no está decidido. | FRED, serie `DCOILBRENTEU` (<https://fred.stlouisfed.org/series/DCOILBRENTEU>), consultada el 2026-11-18; archivo `brent_2000-26.csv` | Diaria, días hábiles, 2000-01-04 a 2026-11-17 | Filtro desde 2000-01-01; se eliminan 500 días sin cotización (`06_series_macro.R`) |
| Inflación anual: `Inflación núcleo 15, anual`, `Inflación sin alimentos ni regulados, anual`, `Inflación sin alimentos, anual` | Variación porcentual anual del IPC en tres medidas (la núcleo 15 y las dos sin alimentos). Objeto de interés potencial: la inflación que sigue el Banco frente a la meta. | DANE, con cálculos del Banco de la República (<https://uba.banrep.gov.co/htmlcommons/SeriesHistoricas/precios-inflacion.html>), consultada el 2026-11-18; archivo `inflacion_variacion_anual_99_26.xlsx` | Mensual, 1999-01 a 2026-10; fecha = fin del mes de referencia | Filtro desde 2000-01-01 (322 meses); sin más transformaciones |
| `trm_cop_usd` | Tasa Representativa del Mercado (TRM): pesos colombianos por dólar. Es la tasa de cambio nominal de la historia de la pregunta (aumento de la TRM tras la caída del petróleo de 2014). | Banco de la República, SUAMECA (<https://suameca.banrep.gov.co/estadisticas-economicas/informacionSerie/1/tasa_cambio_peso_colombiano_trm_dolar_usd>), consultada el 2026-11-18; archivo `TRM.csv` | Diaria calendario (incluye fines de semana y festivos, que repiten el último valor), 1991-11-27 a 2026-11-19 en el archivo; 2000-01-01 a 2026-11-19 tras el filtro (9.820 días) | Filtro desde 2000-01-01 (`06_series_macro.R`); sin vacíos ni fechas duplicadas |
| Índices de tasa de cambio real: `... FMI`, `... IPC NT`, `... IPC T`, `... IPP NT`, `... IPP T`, `... de competidores` | Índices de tasa de cambio real del Banco de la República (NT = no transables, T = transables). Contexto externo y de competitividad. | Banco de la República (<https://uba.banrep.gov.co/htmlcommons/SeriesHistoricas/tasas-cambio-sector-externo.html>), consultada el 2026-11-18; archivo `tasa_cambio_real_70_26.xlsx` | Mensual, 1970-01 a 2026-10; fecha = fin del mes de referencia | Filtro desde 2000-01-01 (322 meses); los vacíos del archivo (".") quedan como `NA` |
| `inflacion_total` | Variación porcentual anual del IPC total al consumidor. Es la medida sobre la que el Banco define la meta: serie principal de inflación frente a la meta. | DANE, con cálculos del Banco de la República. Página de precios e inflación (<https://uba.banrep.gov.co/htmlcommons/SeriesHistoricas/precios-inflacion.html>), pestaña «IPC total» > «Variación porcentual anual», serie «Inflación total, anual»; consultada el 2026-11-19; archivo `IPC TOTAL_Variación_Porcentual_Anual.xlsx` | Mensual, 1955-07 a 2026-10 en el archivo; 2000-01 a 2026-10 tras el filtro (322 meses); fecha = fin del mes de referencia | Filtro desde 2000-01-01 (`06_series_macro.R`). Verificada contra cifras conocidas (dic-2014 3,66 %, dic-2015 6,77 %, jul-2016 8,97 %, dic-2022 13,12 %; tolerancia ±0,05 pp) |
| `meta`, `rango_inf`, `rango_sup` | Meta de inflación de cada año (punto, %) y su rango admisible. | Banco de la República. Misma página, pestaña «Meta e inflación anual», serie «Meta de inflación»; consultada el 2026-11-19; archivo `Meta e inflación anual.xlsx` | Anual, 2000 a 2026 (el archivo la repite en cada mes) | Una fila por año (`macro_meta.rds`). El rango no viene como serie: se construye con la nota del archivo, ±0,5 pp entre 2003 y 2009 y ±1 pp desde 2010 (sin rango antes de 2003). Meta: 4 % en 2007 y 2008, 5 % en 2009, 3 % desde 2010 |
| `brecha`, `brecha_nucleo15` | Inflación total (o núcleo 15) menos la meta del año del dato, en puntos porcentuales. | Cálculo propio (`07_graficas_macro.R`) | Mensual y por reunión | Por reunión, con la regla de alineación de «Alineación temporal» |
| Brent y TRM mensuales; `var_brent`, `var_trm` | Promedio mensual del Brent (días con cotización) y de la TRM (días de lunes a viernes, para no darle triple peso al valor del viernes que el archivo repite el fin de semana); variación anual en %. | Cálculo propio (`07_graficas_macro.R`) | Mensual (figuras) y por reunión | Por reunión: Brent del día hábil anterior y TRM del día, frente a un año antes; `brent_vs_max`: Brent frente a su máximo de los 12 meses previos (%) |

## Restricciones de muestra

<!-- Criterios de exclusión aplicados y el N resultante en cada paso, para que
     el N reportado sea verificable. -->

| Criterio de exclusión | N antes | N después |
| --------------------- | ------- | --------- |
| Archivos del zip que son PDF de comunicados (sin `__MACOSX/`) | — | 194 |
| Archivos del zip que son PDF de minutas (sin `__MACOSX/`)     | — | 200 |
| Minutas sin el informe técnico `2020-04-30` (movido fuera de `minutas/`) | 200 | 199 |

## Entregable: presentación al cliente

<!-- Lineamientos del enunciado para la presentación final, estilo "McKinsey way". -->

- **Empezar por la conclusión:** mensaje principal primero, seguido por los
  argumentos y la evidencia que lo sustentan.
- **Contar una historia** alrededor de lo que la mesa quiere entender: qué
  revela la comunicación de la Junta, cómo se relaciona con el contexto
  macroeconómico y por qué importa.
- **Una idea por slide:** el título comunica la conclusión que se desprende del
  análisis, no el método (evitar títulos como "LDA" o "Resultados").
- **Sustentar la interpretación:** integrar las figuras y los resultados con
  ejemplos de los documentos que permitan entender qué están capturando.
- **Ser claros sobre la incertidumbre:** distinguir las conclusiones
  respaldadas por la evidencia de las que requieren análisis adicional.
- **Cerrar con implicaciones y próximos pasos:** qué aporta el trabajo al
  seguimiento que hace la mesa del Banco de la República y qué preguntas quedan
  abiertas.
- Concentrar la presentación en resultados, implicaciones y recomendaciones;
  los detalles del procesamiento y del análisis quedan en el material de
  soporte (este repositorio).
- La calificación depende en gran medida de la **originalidad de la pregunta**,
  la creatividad y el rigor del análisis, y de una **perspectiva propia**
  sobre la comunicación de la Junta.
- **No incluir código en la presentación.**
- Tablas y figuras autocontenidas, exportadas desde el código en su formato
  final; nunca pantallazos del software.
- Video: todos los integrantes exponen de forma equitativa y la duración **no
  excede los 15 minutos**.
- Antes de cerrar la presentación, pase la lista de chequeo de
  `07_Recursos/heuristicas_retroalimentacion_taller1.md`, en lo que aplique.

## Estado actual

El estado de avance (qué existe hoy, qué sigue y el registro de sesiones) se
lleva en `HANDOFF.md`, no aquí. Ver la sección "`HANDOFF.md`" en "Reglas de
trabajo".

## Reglas estrictas

<!-- Acciones que requieren autorización previa del equipo antes de ejecutarse. -->

- No modificar ni sobrescribir archivos en `01_Datos/01_Crudos/` (incluidos los
  PDF de la Junta).
- No eliminar ni mover archivos fuera de la estructura del proyecto sin autorización.
- No introducir métodos o paquetes de estimación fuera de las herramientas del
  curso sin autorización del equipo (ver "Regla metodológica").
- No reportar una medida de texto sin ejemplos de los documentos que la
  sustenten.
- No evaluar desempeño predictivo dentro de muestra ni omitir `set.seed(2026)`.
- No incluir código en la presentación final.
- No commitear ni hacer push a `main`: todo cambio va a la rama del integrante
  y llega a `main` solo cuando el integrante lo pide (ver "Flujo de versiones").
