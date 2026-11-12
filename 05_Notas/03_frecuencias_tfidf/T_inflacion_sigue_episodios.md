# La atención a la inflación en los textos sigue los episodios conocidos de inflación

- **Estado:** vigente
- **Tipo / fuente:** T; comunicados y minutas (discusión de la Junta); descriptivo. Sirve de validación de las medidas de texto, no es todavía una relación texto–macro
- **Script de origen:** `02_Scripts/03_frecuencias_tfidf.R`
- **Última verificación:** 2026-11-12, con `02_Scripts/03_frecuencias_tfidf.R` (corrida completa de `00_main.R`)

## Evidencia

- Figura `03_Resultados/Figuras/03_frecuencias_tfidf/conjunto_temas_por_anio.png`.
- Cifras por año: `03_Resultados/Tablas/03_frecuencias_tfidf/conjunto_temas_por_anio.csv`.
- Tabla por periodo: `03_Resultados/Tablas/03_frecuencias_tfidf/conjunto_temas_por_periodo.png`.
- Comparación con el texto completo de la minuta:
  `03_Resultados/Figuras/03_frecuencias_tfidf/minutas_temas_junta_vs_completo.png`.

Medida: apariciones de once palabras del tema "inflación" (inflación,
inflación básica, total y de alimentos, expectativas de inflación, meta de
inflación, pronóstico de inflación, IPC, inflacionario, precio, indexación)
por cada 1.000 palabras del texto, por año. La lista se fijó antes de ver la
serie. n = 194 comunicados y 199 minutas, 2007 a 2026.

| Años | Comunicados (por 1.000 palabras) | Minutas, discusión de la Junta |
| --- | --- | --- |
| 2008–2010 | 24 a 29 | 25 a 32 |
| 2012–2013 | 13 | 12 a 13 |
| 2015–2017 | 23 a 28 | 18 a 23 |
| 2019–2020 | 11 a 13 | 11 a 12 |
| 2022–2023 | 22 a 23 | 20 a 22 |
| 2024–2026 | 20 a 22 | 17 a 19 |

Por periodo, en comunicados: 15,5 en P3 (2011–14), 23,5 en P4 (2014–16), 10,9
en P6 (2020–21) y 22,3 en P7 (2021–23).

## Ejemplos de los documentos

- Minuta del 19 de febrero de 2016 (medida alta): los miembros ven con
  "especial preocupación el desanclaje de las expectativas de inflación de la
  meta y el fuerte aumento de la inflación en un contexto de incertidumbre
  sobre el grado de indexación en las decisiones de precios y salarios".
- Minuta del 30 de junio de 2020 (medida baja): "Los directores destacaron la
  reducción en todos los indicadores de inflación. La variación del IPC se
  ubicó por debajo de la meta (2,85%), y se dio una caída fuerte en el
  indicador de inflación sin alimentos (1,84%)."
- Minuta del 16 de diciembre de 2022 (medida alta): "En noviembre la inflación
  anual total fue 12,5% y la inflación básica (sin alimentos ni regulados)
  8,8%, superando en ambos casos los pronósticos del equipo técnico".

## Qué dice, en lenguaje intuitivo

Lo que se quiere conocer es cuánta atención le presta la Junta a la inflación.
La medida es qué tan seguido aparecen las palabras de inflación en sus
documentos. El resultado: la medida sube en los años en que la inflación en
Colombia estuvo alta (2008, 2015–2017, 2022–2023) y baja cuando estuvo cerca o
por debajo de la meta (2012–2013, 2019–2020). Se mueve de forma parecida en los
comunicados y en la discusión de la Junta de las minutas.

Se lee en el primer panel de la figura: la línea azul son los comunicados y la
ocre las minutas; las líneas punteadas marcan los cambios de formato de las
minutas.

## Por qué importa en el estudio

Es una comprobación de que contar palabras, con la limpieza de este proyecto,
captura algo real: una medida de texto que no se moviera en 2015–2016 ni en
2022–2023 sería una señal de alerta. Que el patrón aparezca también en los
comunicados, cuyo formato cambia menos, hace menos probable que sea un efecto
del formato de las minutas. No es un hallazgo sobre la relación entre texto y
macroeconomía: los episodios se contrastan con hechos conocidos, no con una
serie de inflación, que todavía no se ha incorporado.

## Límites e incertidumbre

- Es un conteo de una lista de palabras, sensible a qué palabras entran
  ("precio" es la más general de la lista).
- La frecuencia es anual: no permite decir si la atención se adelanta o sigue
  a los datos de inflación. Eso requiere medir por reunión y alinear con la
  inflación conocida a la fecha de cada reunión.
- Atención no es preocupación: la medida también es alta cuando la Junta habla
  de que la inflación baja (2009–2010).
- En el mismo ejercicio, el grupo "riesgo e incertidumbre" no sube en 2020 (5
  a 6 por 1.000 frente a 3 a 8 el resto de años) y el "entorno externo" sube en
  2015 en comunicados (30) mucho más que en la discusión de la Junta (18): no
  todos los grupos de palabras se comportan como el de inflación.

## Historial

- 2026-11-12: nota creada, como validación de las medidas de texto. Sin series
  macroeconómicas.
