# Después del choque, «expectativas de inflación» es la palabra ancla cuyo contexto más cambia, y «inflación» se discute junto a la meta y la convergencia

- **Estado:** matizado (2026-11-21, contraste con Word2Vec): se sostiene en los dos métodos que las expectativas son el ancla que más cambia y que, después del corte, «inflación» va con meta y convergencia. El «anclaje / desanclaje» de las expectativas y el papel de la tasa de intervención como control solo aparecen con GloVe.
- **Tipo / fuente:** T; comunicados y minutas (solo la discusión de la Junta) en un solo modelo; descriptivo
- **Script de origen:** `02_Scripts/10_glove.R`
- **Última verificación:** 2026-11-21, con `02_Scripts/10_glove.R`

## Evidencia

- Tabla `03_Resultados/Tablas/10_glove/conjunto_glove_vecinos.png` (cifras en
  `conjunto_glove_vecinos.csv`); cada vecino con su coseno en
  `conjunto_glove_vecinos_detalle.csv`; fragmentos en
  `conjunto_glove_fragmentos.csv`.
- Medida: embeddings GloVe (Lab 13), 50 dimensiones, ventana de 5 palabras,
  documento = oración. Un solo modelo con 2007–2026. En la ventana 2009-10-30
  a 2019-10-29 cada ancla se marca por época, así que el modelo estima un
  vector «antes» y uno «después». Coseno promedio de tres semillas (2026, 2027
  y 2028). Épocas: 54 comunicados y 59 minutas antes, 53 y 53 después.
- Oraciones con cada ancla (antes / después, sumando las dos fuentes):
  inflación 479 / 474, expectativas de inflación 166 / 154, crecimiento
  658 / 246, tasa de intervención 256 / 230.

| Ancla | Vecinos antes (estables en las 3 semillas) | Vecinos después (estables) | Coseno antes–después |
| --- | --- | --- | --- |
| inflación | proyección, comportamiento, meta de inflación, mercado, resultado, proyectado, anual | meta, expectativa, convergencia, proyección, desviar, comportamiento | 0,56 |
| expectativas de inflación | anclar, analista, encontrar, inflación básica | anclaje, desanclaje, analista, meta, derivar | 0,31 |
| crecimiento | menor, sugerir, economía, proyección, PIB, actividad económica | bajo, proyectado, PIB, segundo | 0,59 |
| tasa de intervención | inalterada, puntos básicos, incrementar, decidir, apropiado, tasa de referencia | inalterada, decidir, puntos básicos, mayoría, unanimidad, incrementar, reducir | 0,71 |

- Coseno entre los dos vectores del ancla: 1 indica el mismo contexto en las
  dos épocas. «Expectativas de inflación» es la que más cambia (0,31) y «tasa
  de intervención» la que menos (0,71).
- Coincidencia con las correlaciones en la misma oración de `09` (phi): 5 de
  10 vecinos de «inflación» en cada época; 5 y 6 de «expectativas de
  inflación»; 4 y 4 de «crecimiento»; 7 y 7 de «tasa de intervención».
- Cada vecino está entre los 10 primeros de las tres semillas en 4 a 7 de 10
  casos por ancla y época. Los cosenos de los vecinos van de 0,35 a 0,73.
- **Robustez con Word2Vec** (skip-gram, mismo texto y anclas, promedio de 5
  entrenamientos; columna «Word2Vec» de la tabla y
  `conjunto_w2v_vecinos_detalle.csv`). Este método no se reproduce exactamente
  entre corridas: los cosenos varían en unos 0,01 a 0,03.

  | Ancla | Coseno GloVe | Coseno Word2Vec | Vecinos de Word2Vec en las 5 corridas (después) |
  | --- | --- | --- | --- |
  | inflación | 0,56 | 0,78 | meta, convergencia, diluir |
  | expectativas de inflación | 0,31 | 0,61 | derivar, papel, implícita |
  | crecimiento | 0,59 | 0,72 | contenido, socio, crecimiento económico, factible |
  | tasa de intervención | 0,71 | 0,69 | votación, inalterada, puntos básicos, decidir |

  Coinciden en que las expectativas son el ancla con el coseno más bajo y en
  que «inflación» va con meta y convergencia después del corte. Difieren en el
  resto del orden: con Word2Vec, «inflación» es el ancla que menos cambia y la
  tasa de intervención cambia más que inflación y crecimiento. De los 10
  vecinos de cada ancla y época, solo 1 a 4 están en las listas de los dos
  métodos.

## Ejemplos de los documentos

- «Inflación» con «proyección», antes. Comunicado del 2011-03-18: «Las
  proyecciones de inflación a finales de 2011 y 2012 continúan cerca del punto
  medio de este rango.»
- «Inflación» con «meta» y «desviar», después. Minuta del 2015-01-30:
  «Algunos miembros de la Junta consideran que el efecto de la devaluación
  puede inicialmente primar sobre el del menor crecimiento y desviar
  transitoriamente la inflación de la meta.» Comunicado del 2018-10-26: «La
  inflación observada y su convergencia esperada a la meta del 3%.»
- «Expectativas de inflación» con «anclaje», después. Minuta del 2015-07-31:
  «Tendría la ventaja de reforzar el anclaje de las expectativas de inflación
  a la meta, reducir la presión devaluacionista y contribuir a corregir el
  déficit en cuenta corriente.»
- «Tasa de intervención» con «inalterada», en las dos épocas. Comunicado del
  2010-12-17: «…decidió mantener inalterada la tasa de interés de
  intervención.» Minuta del 2017-01-27: «La Junta Directiva decidió por
  mayoría mantener inalterada la tasa de interés de intervención y la mantuvo
  en 7,5%.»
- El fragmento de «expectativas de inflación» con «anclar» antes del corte
  solo aparece dentro de enumeraciones largas de las minutas; no se cita.

## Qué dice, en lenguaje intuitivo

Lo que se quiere conocer es si la Junta usa las mismas palabras de otra manera
después del choque. La medida pone cada palabra en un mapa donde las palabras
que se usan en frases parecidas quedan cerca; sus «vecinos» son las palabras
de uso más parecido, aunque no aparezcan en la misma oración. Antes de 2014,
«inflación» estaba cerca de palabras de seguimiento de cifras y pronósticos
(proyección, resultado, mercado, anual). Después quedó cerca de meta,
convergencia y desviar: la inflación pasó a discutirse como una desviación
frente a la meta y su regreso a ella. Las expectativas son, con los dos
métodos, la palabra cuyo contexto más cambia. En qué dirección depende del
método: con GloVe pasan a discutirse en términos de anclaje y desanclaje; con
Word2Vec, en términos de cómo se miden (las que se derivan de los papeles de
deuda pública). La tasa de intervención conserva su vocabulario de decisión,
al que se suma el de la votación (mayoría, unanimidad).

## Por qué importa en el estudio

Confirma, con una medida distinta, el hallazgo de que la inflación no recibió
más espacio sino otro tipo de discusión
([T_devaluacion_tema_de_inflacion](../09_antes_despues/T_devaluacion_tema_de_inflacion.md),
[T_inflacion_de_meta_a_choques](../08_lda_oraciones/T_inflacion_de_meta_a_choques.md)).
La interpretación económica: con la depreciación de 2014–2016 empujando los
precios, el riesgo para la Junta dejó de ser el nivel de la inflación y pasó a
ser que el choque se volviera persistente y desanclara las expectativas. El
cambio más grande, con los dos métodos, está en «expectativas de inflación»,
que es el canal por el que un choque transitorio se vuelve persistente. Que
las expectativas se discutan como anclaje (GloVe) o según cómo se miden en el
mercado de deuda (Word2Vec) son dos caras de la misma preocupación: la Junta
siguió de cerca las expectativas que surgen de los TES para detectar un
desanclaje. Para la mesa, la atención a las expectativas de mercado y al
anclaje es una señal de que la Junta teme efectos de segunda ronda, la
preocupación que acompañó el ciclo de alzas de 2015–2016.

## Límites e incertidumbre

- **Sensible al método.** Con Word2Vec no aparecen «anclaje» ni «desanclaje»
  entre los vecinos de las expectativas, y la tasa de intervención no es el
  ancla que menos cambia, así que no sirve de control. Solo se concluye lo que
  coincide en los dos métodos. Los vecinos de una sola lista son ilustrativos.

- «Devaluación», «indexación» y «persistencia», que `09` muestra como
  palabras nuevas, no aparecen entre los vecinos de «inflación»: son poco
  frecuentes (menos de 1,4 por 1.000 palabras) y no llegan a estar entre las
  10 más cercanas. La medida capta el marco (desvío frente a la meta,
  convergencia, anclaje), no el mecanismo palabra por palabra.
- Comunicados y minutas van juntos en un solo modelo, porque separados quedan
  muy pocas oraciones por época. Por eso no se puede usar el comunicado como
  control del cambio de formato de las minutas (2014-05-30). El cruce con phi,
  que sí separa las dos fuentes, va en la misma dirección.
- Los vecinos dependen de la semilla: entre 3 y 6 de cada 10 cambian con otra
  semilla (marcados con * en la tabla). Solo se interpretan los estables.
- Una palabra menos frecuente tiene un vector más ruidoso, y eso baja el
  coseno antes–después. «Expectativas de inflación» es el ancla con menos
  oraciones. Aun así, el orden no sigue solo a la frecuencia: «inflación», la
  más frecuente, cambia más que «tasa de intervención».
- Parte del contexto «antes» viene de frases repetidas entre reuniones (p. ej.
  el cierre «La Junta seguirá haciendo un cuidadoso monitoreo… de las
  proyecciones de la inflación»).
- «Crecimiento» después del corte tiene solo 4 vecinos estables; su cambio
  hacia «bajo» y «proyectado» no se interpreta solo.
- Asociación, no causalidad. Es un solo episodio, y en la ventana también
  ocurrió El Niño de 2015–2016.

## Historial

- 2026-11-21: nota creada con la primera corrida de `10_glove.R`. Contraste:
  consistente con las correlaciones phi de `09` y con los tópicos 4 y 8 de
  `08` en la dirección del cambio; las palabras de mecanismo (devaluación,
  indexación) no aparecen entre los vecinos.
- 2026-11-21: matizada con el contraste de Word2Vec que agrega `10_glove.R`
  (confirmado por Santiago Muñoz Martínez). El título pasa de «desvío frente a
  la meta y anclaje» a lo que coincide en los dos métodos; el anclaje de las
  expectativas y el papel de control de la tasa de intervención quedan como
  resultados de un solo método.
