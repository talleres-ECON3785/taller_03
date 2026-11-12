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
  "Decisiones tomadas" (**pendiente: definirla**).
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
  - las series macroeconómicas descargadas se guardan aquí, en una subcarpeta propia
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
- `.claude/skills/`          skills del proyecto (`bitacora-sesion`, `cerrar-sesion`, `registrar-hallazgo`)
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
  (**pendiente: crearlo una vez definida la pregunta**). Los "Siguientes
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

## Regla metodológica: herramientas del curso, medidas validadas con el texto

- El enunciado pide usar **las herramientas del curso**. **Catálogo cerrado
  de métodos:** el trabajo se limita a los métodos, paquetes y funciones de
  `07_Recursos/catalogo_metodos.md`, recopilados de los Laboratorios 11 y 12:
  tokenización y limpieza (`tidytext`, `stopwords`, `stringi`, `SnowballC`),
  términos compuestos por diccionario y lemas (`udpipe`), frecuencias y TF-IDF,
  matriz documento-término (`tm`), bigramas y correlación entre palabras
  (`widyr`), y LDA (`topicmodels`) con lift, perplejidad por *document
  completion*, coherencia UMass y validación con documentos representativos.
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
  inflación (**por decidir**): tasa de intervención, inflación total y
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
  indicar la regla de alineación temporal.
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

## Análisis descartados

<!-- Especificaciones, variables o enfoques que se probaron y abandonaron, con
     la razón, para no repetir procedimientos ya infructuosos. -->

| Fecha | Análisis/especificación descartada | Razón |
| ----- | ---------------------------------- | ----- |

## Definición de variables

<!-- Definición operativa de cada variable usada en el análisis: qué incluye,
     unidades, frecuencia, periodo, fuente y transformaciones. -->

| Variable | Definición | Fuente | Cobertura y frecuencia | Transformaciones |
| -------- | ---------- | ------ | ---------------------- | ---------------- |
| `fecha` | Fecha del documento, tomada del nombre del archivo (`YYYY-MM-DD`). | Nombre de los PDF | 2007-01 a 2026-09; por reunión | Ninguna |
| `tipo_documento` | `comunicado` o `minuta`, según la carpeta y el nombre del archivo. | Nombre de los PDF | Igual | Ninguna |

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
