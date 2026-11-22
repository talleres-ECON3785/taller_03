# La atención al entorno externo superó su máximo previo antes de la primera alza de la tasa; la discusión de la inflación por depreciación llegó después

- **Estado:** matizado (asociativo; depende de una media móvil y de la regla de comparación)
- **Tipo / fuente:** X; comunicados, minutas (solo la discusión de la Junta) y decisiones de tasa; asociativo
- **Script de origen:** `02_Scripts/11_figuras_diapositiva.R` (lee resultados de `08` y `09`)
- **Última verificación:** 2026-11-21, con `02_Scripts/11_figuras_diapositiva.R`

## Evidencia

Tabla `03_Resultados/Tablas/11_figuras_diapositiva/conjunto_verificacion_antes_alzas.csv`.

Regla, fijada antes de ver el resultado:
- en cada medida y fuente, se calcula la media móvil de las últimas 5 reuniones;
- se toma su máximo en los 5 años antes del corte (2009-10-30 a 2014-10-29);
- se busca la primera reunión desde el corte en que la media móvil lo supera;
- se compara esa fecha con la primera alza del ciclo, el 2015-09-25.

| Medida | Fuente | Máximo antes del corte | Primera reunión que lo supera | Frente a la primera alza |
| --- | --- | --- | --- | --- |
| Entorno externo (por 1.000 palabras) | Comunicados | 23,7 (2012-10-26) | 2014-12-19 | 9,2 meses antes |
| Entorno externo (por 1.000 palabras) | Minutas | 20,1 (2012-10-26) | 2015-03-20 | 6,2 meses antes |
| Tópico 4, inflación por depreciación (% de la reunión) | Comunicados | 20,6 (2010-04-30) | 2015-11-27 | 2,1 meses después |
| Tópico 4, inflación por depreciación (% de la reunión) | Minutas | 21,5 (2010-02-26) | nunca | — |

- Según la regla, la figura de verificación (`conjunto_cambio_antes_alzas.png`) se genera solo si
  las dos medidas superan su máximo antes de la alza en comunicados y en minutas. No se cumple, así
  que no se generó.
- La figura de la presentación es
  `03_Resultados/Figuras/11_figuras_diapositiva/conjunto_externo_macro_2013_2018.png`.

## Ejemplos de los documentos

- Comunicado del 2014-10-30, primera reunión después del corte: «El precio internacional del
  petróleo ha caído y se encuentra por debajo del pronóstico que tenía el equipo técnico.»
- Comunicado del 2015-09-25, día de la primera alza: «El traslado de parte de la devaluación del
  peso a los precios al consumidor y la mayor intensidad del fenómeno de El Niño hacen más lenta la
  convergencia de la inflación a la meta…»

## Qué dice, en lenguaje intuitivo

- La pregunta es si el discurso de la Junta cambió antes de que empezara a subir la tasa.
- Para el entorno externo, sí: la Junta ya hablaba del exterior más que en cualquier momento de los
  cinco años anteriores entre seis y nueve meses antes de la primera alza.
- La explicación de la inflación por la depreciación tomó otro camino:
  - en los comunicados superó su máximo previo dos meses después de la primera alza;
  - en las minutas nunca lo superó, porque en 2010 la Junta ya discutía choques de precios con
    intensidad.
- El discurso se movió primero con el petróleo, y la discusión del traslado a precios acompañó a
  las alzas, no las anticipó.

## Por qué importa en el estudio

Matiza `05_Notas/09_antes_despues/X_atencion_se_adelanta_a_las_series.md`:
- se sostiene que la atención al exterior se movió con el choque y antes de la política;
- no se sostiene que toda la discusión del choque se adelantara a las alzas.

Para la mesa, la señal temprana fue la atención al exterior, no el lenguaje de traslado a precios.

## Límites e incertidumbre

- Asociación en un solo episodio.
- El umbral (el máximo de cinco años) es exigente para el tópico 4, que tuvo un nivel alto en
  2008–2010 por otro episodio de inflación. Con otro umbral, la fecha podría cambiar.
- La media móvil de 5 reuniones puede desplazar las fechas unas pocas reuniones.

## Historial

- 2026-11-21: nota creada con la primera corrida de `11_figuras_diapositiva.R`. Matiza la nota
  `X_atencion_se_adelanta_a_las_series.md` de `09` y es consistente con ella (la atención a la
  inflación en comunicados llegó después del pico).
