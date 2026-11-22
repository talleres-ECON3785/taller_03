# Bitácora — 2026-11-21 (6): diapositiva de embeddings y guion del video (H4)

Sesión de Samuel Escandón, rama `SamuelEscandonC`. Se trabajó en un worktree del agente y los
commits se empujan a `SamuelEscandonC`.

## Resumen

Objetivo: terminar el contenido del video del domingo 22 (H4 de `PLAN.md`, P4.5): incorporar los
embeddings de `10_glove.R` como diapositiva propia y escribir el guion que se lee en voz alta.

Desarrollo:

1. **Traer `main`** (commit `188f136`). `main` traía los embeddings de Santiago Muñoz Martínez
   (PR #10). Hubo conflictos en `00_main.R`, `README.md`, `HANDOFF.md`, `CLAUDE.md` y
   `05_Notas/README.md`; se resolvieron conservando lo de las dos ramas:
   - `00_main.R`: `10_glove.R` y `11_figuras_diapositiva.R` en la lista de scripts, en ese orden,
     y las carpetas de salida de los dos;
   - `README.md`: la sección de `10_glove.R` antes de la de `11` y del borrador;
   - `CLAUDE.md`: las dos filas de decisiones de `main` (Lab 13 y diseño de `10`) antes de la de
     `11`;
   - `05_Notas/README.md`: las dos notas nuevas;
   - `HANDOFF.md`: objetivos y estado reescritos para el trabajo combinado, y las dos entradas
     del registro conservadas.
   `PLAN.md` y `hallazgos_y_figuras.txt` se unieron sin conflicto.
2. **Figura nueva** en `11_figuras_diapositiva.R`: coseno antes–después de las cuatro anclas con
   GloVe y Word2Vec (`conjunto_glove_cosenos.png`).
3. **Deck** (`construir_borrador.py`):
   - la diapositiva PENDIENTE (PowerPoint 8) pasa a ser la de embeddings;
   - se actualizan «cómo lo medimos» (tres medidas) y la de alcance;
   - se agrega el apéndice A9 (tabla de vecinos de GloVe).
   El deck queda con 27 diapositivas: 13 principales y 14 de apéndice. Se exportó a PDF con
   LibreOffice, se revisaron todas las diapositivas principales y el validador de la skill `pptx`
   pasó.
4. **Guion** (`04_Presentaciones/guion_presentacion.txt`):
   - texto oral para las 13 diapositivas principales, con presentador, duración, qué señalar y la
     transición;
   - la tabla de tiempos y cinco preguntas probables con su diapositiva de respaldo.
   El generador copia cada bloque a las notas del orador.
5. **`hallazgos_y_figuras.txt`**: la sección 5 dice ahora en qué diapositivas entran los
   embeddings, y la sección 6 sigue el orden y las duraciones del guion.

No se corrió `00_main.R` ni los scripts 01 a 10 (instrucción del usuario): solo las secciones 1 a
3 de `00_main.R` y `11`.

Objetivos de `HANDOFF.md`:
- Objetivo 1 (H4, deck final y video): avanzó. El contenido y el guion están completos; faltan la
  revisión en PowerPoint, los nombres de los presentadores, la copia a `08_Entregables/` y la
  grabación.
- Objetivo 2 (H3d): no se trabajó.
- Objetivo 3 (`00_main.R` completo y PR): no se trabajó. El usuario abrirá el PR después de revisar.

## Archivos

- Creados:
  - `04_Presentaciones/guion_presentacion.txt`
  - `03_Resultados/Figuras/11_figuras_diapositiva/conjunto_glove_cosenos.png`
  - esta bitácora
- Modificados:
  - `02_Scripts/11_figuras_diapositiva.R`
  - `04_Presentaciones/construir_borrador.py`
  - `04_Presentaciones/borrador_presentacion.pptx`
  - `04_Presentaciones/hallazgos_y_figuras.txt`
  - `05_Notas/10_glove/T_contexto_inflacion_expectativas.md`
  - `README.md`
  - `HANDOFF.md`
  - en el commit del merge: `00_main.R`, `CLAUDE.md`, `05_Notas/README.md`, `README.md` y
    `HANDOFF.md`
- Eliminados: ninguno.

## Detalle por archivo

### `02_Scripts/11_figuras_diapositiva.R`

**Sección 5d (nueva).** Lee `03_Resultados/Tablas/10_glove/conjunto_glove_vecinos.csv`.

Qué muestra la figura:
- el coseno antes–después de cada ancla con los dos métodos, en un panel por método;
- las barras van de menor a mayor dentro de cada panel (`reorder_within`), porque el orden cambia
  con el método;
- «expectativas de inflación» va en verde-azulado (`paleta_categorica[3]`) y el resto en gris;
- una línea punteada en 1, rotulada «1 = mismo contexto».

Las etiquetas llevan tildes con `etiqueta()`. «tasa intervención» se nombra a mano como «tasa de
intervención», porque el compuesto no trae la preposición.

Medida:
- **Objeto de interés:** cuánto cambió el contexto de uso de cada palabra.
- **Medida:** coseno entre los vectores `ancla_antes` y `ancla_despues` de un mismo modelo
  (`10_glove.R`, sección 12 del catálogo, Lab 13).
- **Estimaciones (GloVe / Word2Vec):** expectativas de inflación 0,31 / 0,61; inflación
  0,56 / 0,78; crecimiento 0,59 / 0,72; tasa de intervención 0,71 / 0,69.
- **Muestra:** comunicados y la discusión de la Junta en las minutas, 2009-10-30 a 2019-10-29.

No se recalcula nada. Los `stopifnot()` comprueban que haya 8 filas y que los cosenos estén entre
−1 y 1.

### `04_Presentaciones/construir_borrador.py`

- **Utilidades.** Las funciones para leer cifras y poner tildes (`leer`, `num`, `ic`,
  `etiqueta`…) se movieron antes de la diapositiva 1, para usarlas en cualquier diapositiva. A las
  formas con tilde se agregó «proyección».
- **Diapositiva 8 (embeddings).** Muestra solo lo que sostienen los dos métodos:
  - figura de cosenos;
  - los vecinos estables de GloVe de «inflación» y «expectativas de inflación», es decir, los que
    no llevan asterisco porque se repiten en las tres semillas, leídos del `.csv`;
  - el matiz de que el «anclaje / desanclaje» solo aparece con GloVe;
  - el fragmento de la minuta del 2015-01-30 («desviar transitoriamente la inflación de la meta»).
  Se eligió ese fragmento en vez del de la minuta del 2015-07-31 porque ilustra «desviar» y
  «meta», dos vecinos que sí coinciden en los dos métodos. El de «anclaje» ilustraría un resultado
  de un solo método.
- **Otras diapositivas:**
  - «Cómo lo medimos»: el bloque de medidas nombra el diccionario, los tópicos y los embeddings.
  - Alcance: «Respaldado» incluye los embeddings, y «Requiere más análisis» dice que los
    embeddings cambian con el método.
- **Apéndice A9:** `conjunto_glove_vecinos.png` a todo el ancho.
- **Guion en las notas.** Al final, el generador:
  - lee `guion_presentacion.txt` y exige que tenga las 13 diapositivas principales;
  - antepone a las notas de cada una el presentador, la duración, el texto, qué señalar y la
    transición;
  - conserva debajo las cifras con su `.csv` y el fragmento completo.
  El guion vive en un solo archivo de texto y el deck lo copia, para que las dos versiones no se
  separen.

### `04_Presentaciones/guion_presentacion.txt`

**Contenido.** Texto oral para cada diapositiva principal: número, título, presentador, duración,
texto, qué señalar y transición. Al final van los tiempos por presentador y cinco preguntas
probables con su diapositiva de respaldo:
- el corte;
- el formato de las minutas;
- K y nombres de los tópicos;
- la confiabilidad de los embeddings;
- causalidad y predicción.

**Decisiones:**
- **Respuesta primero.** La respuesta y por qué le importa a la mesa se dicen antes del segundo
  75: portada de 0:20 y respuesta de 1:15.
- **Los métodos se explican sin jerga la primera vez** (diapositiva 3):
  - diccionario = contar las palabras de cada tema;
  - tópicos = un modelo agrupa las frases que hablan de lo mismo;
  - embeddings = un mapa donde quedan cerca las palabras que se usan en frases parecidas.
  En la diapositiva 8 se repite la idea de los vecinos.
- **Cifras.** Salen de las notas del orador del deck, que citan su `.csv`, y de las notas de
  `05_Notas/`. Se redondean para decirlas en voz alta (p. ej. 2,6 % → «tres por ciento»).
- **Sin lenguaje causal:** se usan «coincide», «se asocia» y «aparece». La diapositiva 11 dice
  explícitamente qué no se puede afirmar.
- **Duración** = (palabras del texto y de la transición) / 140 por minuto + 3 s por cambio,
  redondeado a 5 s:

  | Presentador   | Diapositivas | Duración |
  | ------------- | ------------ | -------- |
  | Presentador 1 | 1 a 4        | 3:45     |
  | Presentador 2 | 5 a 7        | 3:35     |
  | Presentador 3 | 8 a 10       | 3:40     |
  | Presentador 4 | 11 a 13      | 3:20     |
  | Total         | 13           | 14:20    |

  Para equilibrar se acortó la explicación del corte y de la cronología (Presentador 1), y se
  agregaron una frase de cierre en la diapositiva 11 y la señal concreta para la mesa en la 12
  (Presentador 4). Como el total no pasa de 14:30, no se quitó la diapositiva 3.

### `04_Presentaciones/hallazgos_y_figuras.txt`

- **Sección 5:** reemplaza «una línea en la diapositiva 7» por la diapositiva propia y dice qué
  entra en cada diapositiva. Las razones para no darle diapositiva propia se reemplazan por las
  razones del cambio.
- **Sección 6:** pasa a la numeración de PowerPoint y a las duraciones del guion.
- **Apéndice A9:** se agrega la figura nueva.

### `05_Notas/10_glove/T_contexto_inflacion_expectativas.md`

Se agregó la figura nueva a «Evidencia» y una línea en el historial. Las cifras coinciden con el
`.csv`. El estado no cambió (matizado).

### `README.md`

- Nueva fila de `conjunto_glove_cosenos.png` en el mapa de `11`, que ahora también lee de `10`.
- Párrafo sobre el guion en «Borrador de la presentación».

## Resultados nuevos (tablas, figuras, gráficos)

- `03_Resultados/Figuras/11_figuras_diapositiva/conjunto_glove_cosenos.png`.
  - **Qué comunica:** de las cuatro palabras ancla, «expectativas de inflación» es la que más
    cambió de contexto con los dos métodos.
  - **Datos:** el coseno de `10_glove.R`, sin recalcular.
  - **Rol:** figura de la diapositiva 8.
  - **Nota:** [T_contexto_inflacion_expectativas](../05_Notas/10_glove/T_contexto_inflacion_expectativas.md).

## Pendientes

- **Revisar el deck en PowerPoint.**
  - Codec Pro no está en LibreOffice, así que el PDF de revisión usa otra fuente.
  - Poner los nombres de los presentadores en el guion.
  - Cronometrar un ensayo: el guion estima 14:20 y deja 10 s de margen frente a 14:30.
- Pasar la versión final del deck a `08_Entregables/` y grabar el video (P4.5).
- H3d y `00_main.R` completo con los once scripts, siguen pendientes. El PR a `main` lo abre
  Samuel Escandón después de revisar.
- **Guion:** se dicen tres hechos de contexto que no vienen de un `.csv` del repositorio:
  - que la Reserva Federal empezó a subir tasas en esos años;
  - que Colombia exporta petróleo y por eso entraron menos dólares;
  - la definición de mercado bajista (umbral de 20 %), que sí está en `CLAUDE.md`.
