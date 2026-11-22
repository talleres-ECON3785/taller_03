# Después del choque, la Junta dejó de hablar de la inflación como seguimiento de la inflación básica dentro del rango meta y pasó a hablar de choques: depreciación y alimentos

- **Estado:** vigente (inflación básica: robusta; inflación por choques: robusta en comunicados y matizada en minutas)
- **Tipo / fuente:** T; comunicados y minutas (solo la discusión de la Junta); descriptivo
- **Script de origen:** `02_Scripts/08_lda_oraciones.R`
- **Última verificación:** 2026-11-21, con `02_Scripts/08_lda_oraciones.R`

## Evidencia

- Figura `03_Resultados/Figuras/08_lda_oraciones/conjunto_lda_antes_despues.png`.
- Tablas `03_Resultados/Tablas/08_lda_oraciones/conjunto_lda_antes_despues.png`,
  `conjunto_lda_topicos.png` y `conjunto_lda_fragmentos.png`; escenarios en
  `conjunto_lda_antes_despues_detalle.csv`.
- LDA con K = 10 y α = 0,1, ventana 2009-10-30 a 2019-10-29; 54 comunicados
  antes y 53 después, 59 minutas antes y 53 después del 2014-10-30.
- Peso medio del tópico en la reunión (en %), antes → después, y diferencia en
  puntos porcentuales con su IC 95 %:

  | Tópico | Comunicados | Minutas |
  | --- | --- | --- |
  | 4. Inflación por depreciación y alimentos | 5,1 → 15,8; +10,8 [7,9; 13,6], robusta | 7,5 → 9,6; +2,0 [−0,6; 4,7], matizada |
  | 8. Inflación básica y expectativas frente a la meta | 11,5 → 4,6; −6,9 [−9,0; −4,8], robusta | 12,2 → 5,4; −6,8 [−9,5; −4,1], robusta |

- El tópico 4 en las minutas es «matizado»: sube con los dos cortes
  alternativos (+1,8 y +3,0), pero con la muestra completa 2007–2026 baja
  (−0,5 [−2,6; 1,6]).

## Ejemplos de los documentos

- Tópico 4, comunicado 2015-08-21: «La transmisión de la depreciación nominal a
  los precios al consumidor y el incremento en los costos de las materias
  primas importadas, así como la menor dinámica en la oferta de alimentos,
  explican en gran parte la aceleración de la inflación en lo corrido del año».
- Tópico 4, comunicado 2016-03-18: «Pese a tratarse de choques temporales, la
  magnitud de la devaluación del peso y la fortaleza del fenómeno de El Niño…».
- Tópico 8, comunicado 2010-06-18: «La mayoría de los indicadores de inflación
  básica […] continúan en la parte baja del rango meta de inflación de largo
  plazo fijado por la Junta (3% más o menos 1%). Las expectativas de inflación
  siguieron cayendo».
- Tópico 8, minuta 2011-02-25: «Los indicadores de inflación básica se
  mantuvieron estables, y su promedio permanece en la mitad inferior del rango
  meta».

## Qué dice, en lenguaje intuitivo

La inflación está presente en toda la década, pero se discute de forma
distinta. Antes del choque, la Junta revisaba cada mes si la inflación básica
y las expectativas seguían dentro del rango meta: un seguimiento rutinario de
una inflación controlada. Después, ese seguimiento pierde más de la mitad de
su espacio y lo ocupa la explicación de por qué sube la inflación: la
devaluación del peso que se traslada a los precios, los alimentos y El Niño.
En los comunicados este segundo tema se triplica (de 5 a 16 de cada 100
palabras).

- **Objeto de interés:** de qué manera discute la Junta la inflación.
- **Medida:** la proporción de dos tópicos de inflación en el texto de la reunión.
- **Estimación:** las diferencias de la tabla.

## Por qué importa en el estudio

Es el canal de la historia macro de la pregunta: el petróleo cae, la TRM sube
y la depreciación pasa a los precios (ver
`07_graficas_macro/M_cronologia_choque_petrolero.md`). La Junta lo nombra
explícitamente y lo trata como choque de oferta («choques temporales»), lo que
explica que aceptara una inflación fuera del rango durante un tiempo antes de
subir la tasa. Para la mesa: después de 2014, la señal de inflación en los
comunicados viene de la depreciación y de los alimentos, no de la inflación
básica.

**Contraste con `09_antes_despues/`:**
- **Consistente** con `T_devaluacion_tema_de_inflacion.md` (devaluación,
  traslado, indexación y persistencia ganan peso después del corte).
- **Cambia (atribuible)** frente a `T_atencion_temas_antes_despues.md`: allí el
  tema «Inflación» del diccionario sube poco y es «matizado» (+4,1 por 1.000
  palabras en comunicados, +0,7 en minutas). El LDA lo explica: el diccionario
  suma dos conversaciones que se mueven en direcciones opuestas (tópico 4
  sube, tópico 8 baja), así que su total cambia poco (heurística H2).
- **Consistente, reunión a reunión:** la suma de los tópicos 4 y 8 sigue al
  tema «Inflación» del diccionario (correlación de 0,71 [0,60; 0,79] en los
  comunicados y 0,73 [0,63; 0,80] en las minutas; ventana, 107 y 112 reuniones;
  `03_Resultados/Tablas/08_lda_oraciones/conjunto_lda_vs_diccionario.png`). Por
  separado, el tópico 8 casi no se mueve con el diccionario en los comunicados
  (0,10 [−0,09; 0,29]): allí el diccionario lo empuja sobre todo la inflación
  por choques (tópico 4: 0,61).

## Límites e incertidumbre

- Asociación, no causalidad: en la ventana también estuvo El Niño de
  2015–2016, que el tópico 4 junta con la depreciación; el modelo no separa
  los dos choques.
- En las minutas, el aumento del tópico 4 es pequeño y su IC incluye el cero;
  la conclusión firme para las minutas es la caída del tópico 8.
- El tópico 8 tiene el 80 % de su peso en las minutas del formato A, pero cae
  igual en los comunicados.
- Dos de los tres fragmentos más representativos del tópico 4 son de
  comunicados casi idénticos (2016-03-18 y 2016-04-29): la Junta repite
  fórmulas entre reuniones.

## Historial

- 2026-11-21: nota creada con la primera corrida de `08_lda_oraciones.R`.
- 2026-11-21: contraste por reunión con el diccionario de `09` (P3a.9): consistente (r = 0,71 y 0,73 con la suma de 4 y 8). Cifras sin cambios.
- 2026-11-21: contraste con los embeddings (`10_glove.R`, [T_contexto_inflacion_expectativas](../10_glove/T_contexto_inflacion_expectativas.md)): consistente. «Inflación» pasa de vecinos de seguimiento (proyección, resultado) a meta, convergencia y desviar; el tópico 8 (inflación básica frente a la meta) baja y la discusión pasa al desvío por choques.
