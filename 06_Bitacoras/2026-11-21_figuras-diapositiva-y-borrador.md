# Bitácora — 2026-11-21 (5): documento de hallazgos, figuras para diapositiva y borrador del deck (H4)

Sesión de Samuel Escandón, rama `SamuelEscandonC`. Se trabajó en un worktree del agente al día
con `main`, y los commits se empujan a `SamuelEscandonC`.

## Resumen

Objetivo: preparar la presentación del domingo 22 (H4 de `PLAN.md`) a partir de los resultados
de `07`, `08` y `09`, sin volver a correr el análisis.

Desarrollo:

1. **Documento de hallazgos** (`04_Presentaciones/hallazgos_y_figuras.txt`, commit `3ca42e4`,
   ya en `SamuelEscandonC`). Incluye:
   - el mensaje principal y seis hallazgos en el orden de la historia;
   - para cada hallazgo, cifras verificadas contra los `.csv`, la convergencia entre el LDA y el
     diccionario, la robustez, un fragmento y la figura recomendada con su legibilidad;
   - el alcance de la evidencia, las implicaciones para 2026, el espacio de los embeddings, el
     orden de las diapositivas y el apéndice.
   Al prepararlo aparecieron dos discrepancias entre las notas de `09` y sus `.csv`; se
   corrigieron en esta sesión (ver más abajo).
2. **Figuras para diapositiva** (`02_Scripts/11_figuras_diapositiva.R`). Son versiones 16:9 con
   letra grande de figuras de `07`, `08` y `09`, más una verificación: si el discurso cambió antes
   de la primera alza de la tasa.
3. **Borrador del deck** (`04_Presentaciones/borrador_presentacion.pptx`). Lo genera
   `04_Presentaciones/construir_borrador.py` con `python-pptx` sobre la plantilla del equipo.
   Tiene 13 diapositivas principales (portada y 1 a 12) y un apéndice de 12 (divisor y 11
   figuras). El guion va en las notas del orador.
4. **Correcciones de notas:**
   - «déficit» en comunicados: 2,14 → 2,12;
   - la lectura de «Entorno externo»: robusta en comunicados y matizada en minutas.

No se corrió `00_main.R`: solo las secciones 1 a 3 y `11`. Los scripts 01 a 10 no se tocaron.

Objetivos de `HANDOFF.md`:
- Objetivo 1 (H4, deck): avanzó. Existe el borrador, pero no la versión final ni el video.
- Objetivo 2 (Word2Vec): no se trabajó; está a cargo de otro integrante.
- Objetivo 3 (PR de `SantiagoMunozM`): ya estaba hecho en `main` (PR #8) al empezar.

## Archivos

- **Creados:**
  - `02_Scripts/11_figuras_diapositiva.R`;
  - `03_Resultados/Figuras/11_figuras_diapositiva/` (6 figuras);
  - `03_Resultados/Tablas/11_figuras_diapositiva/conjunto_verificacion_antes_alzas.csv`;
  - `04_Presentaciones/hallazgos_y_figuras.txt` (ya commiteado),
    `04_Presentaciones/construir_borrador.py`, `04_Presentaciones/borrador_presentacion.pptx` y
    `04_Presentaciones/plantilla_presentacion.pptx`;
  - `05_Notas/11_figuras_diapositiva/X_externo_antes_de_las_alzas.md`;
  - esta bitácora.
- **Modificados:**
  - `00_main.R`, `02_Scripts/00_formato_graficas.R` y `README.md`;
  - `05_Notas/README.md` y tres notas de `05_Notas/09_antes_despues/`;
  - `CLAUDE.md`, `HANDOFF.md`.
- **Eliminados:** ninguno.

## Detalle por archivo

### `02_Scripts/11_figuras_diapositiva.R`

Solo lee resultados guardados: los `.csv` de `08` y `09`, `macro_por_reunion.rds` y
`tokens_anotados.rds` (este último solo para las tildes de las etiquetas). No vuelve a estimar
el LDA. Todas las figuras miden 13,33 × 7,5 pulgadas y usan `tema_diapositiva`.

1. **LDA por diapositiva.** Tres figuras: tópicos 6 y 10, 1 y 2, y 4 y 8.
   - Paneles tópico × tipo de documento, con escala propia por panel.
   - Barras antes y después con el valor en %, e IC 95 % de la media.
   - Datos del escenario principal de `conjunto_lda_antes_despues_detalle.csv`.
2. **Texto frente a macro, 2013–2018.**
   - Atención al entorno externo, como media móvil de las últimas 5 reuniones, por tipo de
     documento.
   - Brent, TRM e inflación total por reunión, con la regla de alineación.
   - Marcas: el corte, el ciclo de alzas sombreado (2015-09-25 a 2016-07-29) y los extremos con
     su fecha. Los extremos se leen de `conjunto_cronologia_texto_macro.csv` de `09`, no se
     recalculan.
   - Las series macro usan grises y verde para no repetir el azul y el ocre de comunicados y
     minutas.
3. **Palabras distintivas, 10 y 10**, con la misma regla de `09` (mínimo de 20 apariciones).
   Etiquetas con tildes:
   - un compuesto se muestra con su expresión del diccionario («cuenta corriente», «balanza de
     pagos»);
   - cada palabra toma su escritura más frecuente en el texto original;
   - «termino» se fija a mano como «término», porque su forma más frecuente es el verbo
     «terminó».
4. **Correlaciones de «inflación» y «expectativas de inflación»** en las minutas, antes y
   después (las 8 palabras de mayor phi, del `.csv` de `09`).
5. **Verificación del momento del cambio.** Medida y regla, fijadas antes de ver el resultado:
   - Objeto de interés: si el discurso cambió antes de la primera alza.
   - Medida: la media móvil de 5 reuniones (solo reuniones pasadas) del tópico 4 del LDA (% de la
     reunión) y del tema «Entorno externo» del diccionario (por 1.000 palabras), por tipo de
     documento.
   - Umbral: el máximo de esa media móvil en los 5 años antes del corte. Se reporta la primera
     reunión desde el corte que lo supera.
   - La figura solo se genera si las dos medidas lo superan antes del 2015-09-25 en comunicados
     y en minutas.
   - Resultado: no se cumple y la figura no se generó (detalle en la nota
     `X_externo_antes_de_las_alzas.md`).
6. **Chequeos con `stopifnot()`:** 12 filas de LDA, 40 palabras con las cuatro etiquetas con
   tilde pedidas, 32 correlaciones y 4 filas de verificación con máximos finitos.

Se revisó cada figura. Ajustes hechos a partir de la revisión:
- títulos descriptivos (la conclusión va en el título de la diapositiva);
- fechas de los extremos que se recortaban o pisaban líneas;
- eje x con marcas en enero;
- «balanza dé pagos»: la primera regla de tildes prefería cualquier forma con tilde;
- el título de la figura de correlaciones, que no cabía.

### `02_Scripts/00_formato_graficas.R`

Dos objetos nuevos, que no cambian las figuras existentes:
- `colores_macro_diapositiva`: Brent en `gris_texto`, TRM en `gris_secundario` e inflación en el
  verde-azulado de la paleta;
- `tema_diapositiva`: letra de 15 a 22 puntos.

Viven en el script de formato porque `CLAUDE.md` no permite redefinir colores ni tamaños dentro
de un script de análisis.

### `04_Presentaciones/construir_borrador.py` y `borrador_presentacion.pptx`

Construcción:
- **Plantilla.** Es una exportación de Canva de 20 × 11,25 pulgadas. Sus diseños con marcadores
  (portada, título solo, título y contenido) están dimensionados para 10 × 7,5 pulgadas, así que
  sus marcadores caerían en la mitad izquierda.
- **Portada.** Es la diapositiva 1 de la plantilla, con sus textos reemplazados y sin el
  logotipo de la empresa ficticia.
- **Demás diapositivas.** Van sobre el diseño en blanco de la plantilla, con sus colores (fondo
  `F2F2F2`; `1A1A1A` en la respuesta, el cierre y el divisor del apéndice) y sus fuentes (Codec
  Pro en títulos, Montserrat en el texto).
- **Figuras.** Se insertan con su proporción y por debajo del título.
- **Texto.** Cuerpo de 24 a 30 puntos en una diapositiva de 20 pulgadas, y fragmento de 20
  puntos en cursiva bajo la figura.

Orden: portada y diapositivas 1 a 12 según el encargo; la 4 une el déficit externo y la cuenta
corriente. Otras decisiones:
- **Diapositiva 6.** Las correlaciones de «inflación» no caben legibles junto al LDA y pasan al
  apéndice (A8).
- **Diapositiva 8.** Como la verificación no se sostiene para la inflación por depreciación, el
  título dice que la atención al exterior se movió con el petróleo y que la discusión de la
  inflación por depreciación llegó con las alzas.
- **Diapositiva 7 (embeddings).** Lleva el cuadro «PENDIENTE» y un título provisional.

Tiempos por presentador, con 13:45 en total:

| Presentador | Diapositivas | Tiempo |
| --- | --- | --- |
| 1 | portada y 1 a 3 | 3:30 |
| 2 | 4 a 6 | 4:00 |
| 3 | 7 a 9 | 3:15 |
| 4 | 10 a 12 | 3:00 |

Verificación del deck:
- se exportó a PDF con LibreOffice y se revisaron todas las diapositivas;
- por código, ninguna forma se sale de la diapositiva ni queda sobre el título;
- el validador de la skill `pptx` pasa contra la plantilla.

Salvedad: LibreOffice no tiene Codec Pro y la sustituye, así que el ajuste exacto del texto
puede variar en PowerPoint.

### Notas de `05_Notas/`

- `09_antes_despues/T_cuenta_corriente_deficit_externo.md`: «déficit» en comunicados después
  del corte pasa a 2,12 por 1.000 palabras (65 apariciones sobre 30.601 palabras), la cifra del
  `.csv`.
- `09_antes_despues/T_atencion_temas_antes_despues.md`: «Entorno externo» queda robusta en
  comunicados y matizada en minutas; se actualizan el estado y el índice.
- `09_antes_despues/X_atencion_se_adelanta_a_las_series.md`: línea de historial con el resultado
  de la verificación y enlace a la nota nueva.
- `11_figuras_diapositiva/X_externo_antes_de_las_alzas.md`: nota nueva, en estado matizado.

## Resultados nuevos (tablas, figuras, gráficos)

- Las 6 figuras de `03_Resultados/Figuras/11_figuras_diapositiva/` (mapa en `README.md`). Son
  versiones para diapositiva de resultados que ya tenían nota en `08` y `09`; no cambian cifras.
- `conjunto_verificacion_antes_alzas.csv`: el momento del cambio frente a la primera alza. Nota:
  [X_externo_antes_de_las_alzas](../05_Notas/11_figuras_diapositiva/X_externo_antes_de_las_alzas.md).
  - Entorno externo: supera su máximo de 2009–2014 el 2014-12-19 en comunicados y el 2015-03-20
    en minutas, antes de la alza.
  - Tópico 4: lo supera el 2015-11-27 en comunicados, después de la alza, y nunca en minutas.
  - Es asociativo. Matiza la nota de `09` sobre el adelanto del texto y no la contradice.

## Pendientes

- Correr `00_main.R` completo (con `11`) y regenerar el deck antes de grabar.
- Embeddings (script 10, otro integrante): reemplazar la diapositiva 7 y su título provisional.
- Revisar el deck en PowerPoint, porque Codec Pro no está en LibreOffice. Pasar a `08_Entregables/`
  la versión final y grabar el video (máximo 15 minutos).
- El documento `hallazgos_y_figuras.txt` todavía menciona las dos discrepancias como pendientes;
  ya se corrigieron en las notas.
