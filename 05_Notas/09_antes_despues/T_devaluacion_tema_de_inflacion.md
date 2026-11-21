# Después del choque, la Junta habla de la inflación en términos de devaluación, traslado a precios, indexación y persistencia

- **Estado:** vigente
- **Tipo / fuente:** T; comunicados y minutas (solo la discusión de la Junta); descriptivo
- **Script de origen:** `02_Scripts/09_antes_despues.R`
- **Última verificación:** 2026-11-21, con `02_Scripts/09_antes_despues.R`

## Evidencia

- Figura `03_Resultados/Figuras/09_antes_despues/conjunto_palabras_distintivas.png`.
- Tablas `03_Resultados/Tablas/09_antes_despues/comunicados_palabras_robustez.png`,
  `minutas_palabras_robustez.png` y `conjunto_fragmentos_palabras.png`;
  detalle en `conjunto_palabras_cambio_detalle.csv`.
- Correlaciones de las anclas `inflacion` y `expectativas_inflacion`:
  `03_Resultados/Tablas/09_antes_despues/minutas_correlaciones_anclas.png` y
  `comunicados_correlaciones_anclas.png`.

Épocas: 2009-10-30 a 2014-10-29 frente a 2014-10-30 a 2019-10-29; n = 59 y 53
minutas, 54 y 53 comunicados.

| Término | Minutas antes → después (por 1.000 palabras) | Comunicados antes → después |
| --- | --- | --- |
| devaluación | 0,02 → 1,34 | 0,03 → 0,85 |
| depreciación | 0,09 → 0,30 | 0,03 → 1,24 |
| indexación | 0,00 → 0,69 | 0,00 → 1,11 |
| persistencia | 0,07 → 0,91 | 0,07 → 0,78 |
| convergencia | 0,23 → 1,64 | 0,17 → 1,96 |

- Lectura **robusta** para devaluación, indexación, persistencia y
  convergencia: misma dirección en los dos tipos de documento, con la muestra
  completa y con los dos cortes alternativos (tablas de robustez).
- Correlaciones en la misma oración (phi), minutas: antes del corte,
  «inflación» aparece con «proyección» (0,35), «cuidadoso» (0,29) y
  «monitoreo» (0,29), palabras de una frase de cierre repetida («La Junta
  seguirá haciendo un cuidadoso monitoreo…»); después, con «meta» (0,34),
  «convergencia» (0,30), «persistencia» (0,20) e «indexación» (0,17). En
  común entre las dos épocas: 2 de 8 palabras. En comunicados el patrón es el
  mismo (después: meta 0,51, convergencia 0,39, transitorio 0,31).
- «Expectativas de inflación» pasa de «credibilidad», «autoridad» y «largo
  plazo» (antes) a «anclaje», «anclado» e «indexación» (después) en las
  minutas.

## Ejemplos de los documentos

- Comunicado del 2015-09-25: «El traslado de parte de la devaluación del peso
  a los precios al consumidor y la mayor intensidad del fenómeno de El Niño
  hacen más lenta la convergencia de la inflación a la meta, tanto por su
  impacto directo sobre los precios y las expectativas de inflación como por
  la probable activación de mecanismos de indexación.»
- Minuta del 2015-01-30: «Algunos miembros de la Junta consideran que el
  efecto de la devaluación puede inicialmente primar sobre el del menor
  crecimiento y desviar transitoriamente la inflación de la meta.»
- Minuta del 2015-06-24: «…el buen anclaje de las expectativas de inflación y
  los excesos de capacidad instalada que se generarán como consecuencia de la
  desaceleración del producto permiten prever que la inflación convergerá a
  la meta…»

## Qué dice, en lenguaje intuitivo

Lo que se quiere conocer es cómo cambió la forma en que la Junta razona sobre
la inflación. Dos medidas lo muestran: qué palabras ganan peso después del
corte y con qué palabras aparece «inflación» en la misma oración. Antes de
2014 la inflación aparecía en frases generales de seguimiento. Después aparece
junto a la devaluación del peso, su traslado a los precios, el riesgo de
indexación y la persistencia, y junto a la meta y la convergencia hacia ella.
La Junta pasó de vigilar la inflación a explicar un mecanismo concreto:
devaluación → precios → expectativas.

## Por qué importa en el estudio

Es el canal de la historia macro (Brent → TRM → inflación) contado por la
propia Junta. La interpretación económica: con un peso que se depreció un 86 %
entre julio de 2014 y febrero de 2016 (ver
[M_cronologia_choque_petrolero](../07_graficas_macro/M_cronologia_choque_petrolero.md)),
el riesgo central dejó de ser el nivel de la inflación y pasó a ser que el
choque de precios se volviera persistente por indexación y desanclara las
expectativas. Para la mesa, las palabras «persistencia», «indexación» y
«anclaje» son señales de la preocupación que precedió al ciclo de alzas de
2015–2016.

## Límites e incertidumbre

- La correlación de la época «antes» está dominada por una frase de cierre
  repetida; parte del cambio es de redacción. El contraste se sostiene en las
  palabras nuevas (indexación, persistencia, devaluación), que no son de
  redacción.
- Asociación, no causalidad: la Junta describe el canal, pero el texto no
  mide cuánto pesó en la decisión.
- Las correlaciones se calculan con oraciones de una sola época y un umbral de
  10 oraciones; con pocas oraciones (p. ej. «tasa de cambio»: 21 antes y 14
  después en minutas) son ruidosas.
- Los embeddings (10) deberían mostrar que los vecinos de «inflación» pasan
  de palabras de seguimiento a palabras de traslado y persistencia.

## Historial

- 2026-11-21: nota creada con la primera corrida de `09_antes_despues.R`.
