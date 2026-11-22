# Bitácora — 2026-11-22: renumeración de los scripts 08 y 09, guion con presentadores y revisión de entrega

## Resumen

Sesión de Santiago Muñoz Martínez (rama `SantiagoMunozM`) en la víspera de la entrega. Tuvo
dos partes.

1. **Guion del video y presentación final.** Se copió la transición de cada diapositiva al
   final de su bloque TEXTO en `04_Presentaciones/guion_presentacion.txt`, se corrigieron
   erratas de ortografía y se agregó el agradecimiento entre presentadores. Después se
   pusieron los nombres de los presentadores (Samuel 1 a 4, Santiago 5 a 7, Mateo 8 a 10,
   Douglas 11 a 13). Con ese guion se generaron una versión en PDF y otra en Word, y se
   reemplazaron las notas del orador de las diapositivas 1 a 13 de
   `08_Entregables/Presentación Final.pptx` (cabecera con presentador y duración, más el
   texto). Se omitió lo de «señalar», como pidió el usuario.
2. **Revisión administrativa y corrida de `00_main.R`.** Se revisó el README, se corrió
   `00_main.R` desde cero en una copia limpia del repositorio (sin `03_Resultados/`,
   `01_Datos/02_Procesados/` ni `01_Datos/03_Listos/`) y falló en `08_lda_oraciones.R`: ese
   script lee dos `.csv` de `09_antes_despues.R` y `00_main.R` lo ejecutaba antes. En la
   máquina del equipo no fallaba porque esos archivos ya existían de corridas anteriores. Se
   decidió invertir los números (el antes/después pasa a `08` y el LDA a `09`) para que la
   numeración siga el orden de ejecución, que es lo que exige `CLAUDE.md` («en el orden de su
   numeración»). Se renombraron scripts, subcarpetas de resultados y de notas, se
   actualizaron las referencias y se volvió a correr `00_main.R` completo desde cero: los
   once scripts terminan sin errores en 9,7 minutos.

Objetivos que traía `HANDOFF.md`: (1) deck final y video: la presentación final ya está en
`08_Entregables/` con las notas del orador y los nombres; faltan el ensayo cronometrado y la
grabación. (2) Robustez común H3d: no se trabajó. (3) Corrida completa de `00_main.R` y PR:
la corrida se hizo (con la corrección del orden); el PR de `SamuelEscandonC` ya estaba
fusionado en `main` (PR #11) y queda por abrir el de `SantiagoMunozM`.

## Archivos

- Creados: `06_Bitacoras/2026-11-22_renumeracion-scripts-y-guion.md`;
  `04_Presentaciones/guion_presentacion.pdf` y `guion_presentacion.docx`;
  `08_Entregables/Presentación Final.pptx` (venía sin versionar).
- Renombrados (`git mv`, 65 archivos): `02_Scripts/09_antes_despues.R` →
  `08_antes_despues.R`; `02_Scripts/08_lda_oraciones.R` → `09_lda_oraciones.R`; y sus
  subcarpetas en `03_Resultados/Tablas/`, `03_Resultados/Figuras/` y `05_Notas/`.
- Modificados: `00_main.R`, `02_Scripts/00_funciones_texto.R`, `02_Scripts/08_antes_despues.R`,
  `02_Scripts/09_lda_oraciones.R`, `02_Scripts/10_glove.R`, `02_Scripts/11_figuras_diapositiva.R`,
  `04_Presentaciones/guion_presentacion.txt`, `04_Presentaciones/construir_borrador.py`,
  `04_Presentaciones/hallazgos_y_figuras.txt`, `04_Presentaciones/borrador_presentacion.pptx`
  (solo las rutas de las notas), las notas de `05_Notas/` que citan esos scripts,
  `05_Notas/README.md`, `README.md`, `PLAN.md`, `CLAUDE.md`, `HANDOFF.md`.
- Eliminados: ninguno.

## Detalle por archivo

### `04_Presentaciones/guion_presentacion.txt`
- Se copió la TRANSICIÓN al final de cada TEXTO (diapositivas 1 a 12; la 13 no tiene), con una
  línea en blanco de separación. Las líneas TRANSICIÓN siguen donde estaban, porque el
  generador del deck las lee.
- Erratas corregidas: «de antemano», «cómo cambian», «intervención», «desacelerarse»,
  «periodos», «importante», «petrolero.», «este análisis», «preasignadas», y dos giros
  («el resultado de que…», «atención a la inflación»).
- Tres cambios de presentador (4→5, 7→8, 10→11) llevan ahora la línea de agradecimiento del
  que entra, p. ej. «Santiago: Gracias, Samuel.».
- Los nombres reemplazan a «Presentador 1 a 4» en cabeceras, transiciones, la frase de
  introducción y la tabla de tiempos. **La tabla de tiempos no se recalculó** con las palabras
  agregadas (transiciones duplicadas en TEXTO y agradecimientos): sigue en 14:20 estimados.

### `04_Presentaciones/guion_presentacion.pdf` y `.docx`
Versiones para leer el guion. Una diapositiva por bloque: título, presentador y duración, texto
a leer en letra grande y la línea SEÑALAR en gris pequeño; al final, tiempos por presentador y
preguntas probables. Se generaron con scripts temporales (HTML impreso con Chrome sin
cabeceras para el PDF; `python-docx` para el Word) **que no están en el repositorio**: si el
`.txt` cambia, hay que regenerarlas. El Word se revisó solo por su texto, no visualmente.

### `08_Entregables/Presentación Final.pptx`
Se reemplazaron las notas del orador de las diapositivas 1 a 13 con «Presentador: <nombre> ·
Duración: <m:ss>» y el texto del guion en párrafos. Esto **reemplaza las notas anteriores
completas**, incluidas las secciones GUION/SEÑALAR/TRANSICIÓN y la «Frase» y las «Cifras clave
(fuente)» que traían; se hicieron copias de respaldo en el directorio temporal de la sesión.
Las diapositivas 14 a 27 (apéndice) no cambiaron, salvo las rutas de las notas (ver abajo). El
archivo se editó con `python-pptx` en un entorno temporal (no está entre las dependencias del
repositorio). Quedó anotado que la diapositiva 1 tiene un cuadro de forma libre con el texto
«z», probablemente un glifo de la plantilla; no se verificó en PowerPoint.

### Renumeración: `08_antes_despues.R` y `09_lda_oraciones.R`
- **Causa del fallo:** el LDA lee `conjunto_temas_por_reunion.csv` y
  `conjunto_documentos_por_epoca.csv` de las tablas del antes/después. `09_antes_despues.R` no
  lee nada del LDA, así que bastaba con ejecutarlo primero. Se prefirió renumerar a mover una
  línea de `00_main.R` porque `CLAUDE.md` pide que la lista siga la numeración, y así el
  número de un script es siempre mayor que el de los scripts de los que lee.
- **Cómo se hizo:** `git mv` con un nombre temporal para el intercambio; reemplazo de los
  nombres completos con un marcador intermedio (un primer intento con `@@…@@` borró el nombre
  porque Perl lo interpretó como variable; se revirtió con `git checkout` y se rehízo con otro
  marcador); inversión de las abreviaturas («`08`», «`09`», «script 09») línea por línea en
  los documentos vigentes, dejando igual las listas que nombran ambos números.
- **Qué no se tocó:** las filas históricas de «Decisiones tomadas» de `CLAUDE.md`, las
  bitácoras anteriores y el registro de sesiones de `HANDOFF.md`, que conservan los nombres
  viejos. En su lugar se agregó una fila a «Decisiones tomadas» con la equivalencia y la causa.
  Los hitos de `PLAN.md` conservan sus letras (H3a = LDA, H3b = antes/después).
- **`00_main.R`:** se reordenaron las listas `carpetas_salida` y `scripts`.
- **`construir_borrador.py`:** rutas actualizadas y variable `d09` renombrada a `d08`; solo se
  comprobó que compila, no se volvió a ejecutar. Las notas del orador de
  `borrador_presentacion.pptx` y de `Presentación Final.pptx` (13 y 7 diapositivas) se
  actualizaron con las rutas nuevas.

### `README.md`
Secciones del mapa en orden de los scripts (la de `05` estaba al final); nombres nuevos;
«Estado» y «Pregunta de investigación» al día (corte 2014-10-30, ventana de 5 años,
comunicados y minutas, métodos); regla de la TRM como está fijada en `CLAUDE.md`; tiempo de
ejecución medido (9,7 minutos con los once scripts); requisitos de Python y archivos del guion;
descripción de `04_Presentaciones/` y `08_Entregables/`.

### `HANDOFF.md`
Nombres nuevos en las secciones vigentes; objetivo 3 reescrito (PR de `SantiagoMunozM`);
estado del pipeline con la corrida completa; entrada nueva en el registro (abajo).

## Resultados nuevos (tablas, figuras, gráficos)

Ninguno: la sesión no cambió cifras. Los 188 archivos de `03_Resultados/` que genera una
corrida desde cero tienen los mismos nombres que los versionados. De los 95 `.csv`, 20 difieren
en bytes; en los de `07`, `08` y `11` que se midieron la diferencia máxima es de 4e-13 (coma
flotante); en `05` no se midió. Los de `10` difieren por la columna de Word2Vec, que el
proyecto ya declara como no reproducible (diferencia hasta 0,0115 en el coseno de GloVe/Word2Vec y
78 celdas de texto en el detalle de vecinos de Word2Vec). Por eso no se creó ni cambió ninguna
nota de hallazgos; las notas solo cambian de ruta.

## Pendientes

- **Video:** ensayo cronometrado (el guion estima 14:20 y no cuenta las líneas agregadas),
  grabación y enlace del video (no está en el repositorio).
- **Registro de conversaciones:** juntar los `.jsonl` de los cuatro integrantes fuera de git
  (`09_Conversaciones/` está ignorada).
- **PR:** abrir el de `SantiagoMunozM` hacia `main` (decisión del integrante).
- **`PLAN.md`:** P3d.1 a P3d.3 y P4.1 a P4.5 siguen sin marcar.
- **Sin confirmar:** el cuadro «z» de la portada; la advertencia de ggplot (`position_stack()`)
  de una figura que no se identificó; que los PDF/Word del guion se mantengan al día (no hay
  script en el repositorio).
- **Semilla:** `08_antes_despues.R`, `03_frecuencias_tfidf.R` y `11_figuras_diapositiva.R` no
  llaman a `set.seed(2026)`; no usan nada aleatorio.
