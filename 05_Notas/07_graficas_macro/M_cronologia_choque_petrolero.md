# El choque petrolero de 2014 llegó a la inflación en unos dos años: el Brent cayó desde junio de 2014, el peso se depreció hasta febrero de 2016 y la inflación tocó su pico en julio de 2016, cuando la Junta terminó de subir la tasa

- **Estado:** vigente
- **Tipo / fuente:** M; series macro (Brent de FRED; TRM, meta y decisiones de tasa del Banco de la República; inflación del DANE); descriptivo
- **Script de origen:** `02_Scripts/07_graficas_macro.R`
- **Última verificación:** 2026-11-19, con `02_Scripts/07_graficas_macro.R`

## Evidencia

- Figura `03_Resultados/Figuras/07_graficas_macro/macro_cronologia_choque.png`
  (zoom 2013–2017) y `macro_series_2007_2026.png` (2007–2026).
- Tabla `03_Resultados/Tablas/07_graficas_macro/macro_cronologia.png` (y `.csv`).
- Tabla `03_Resultados/Tablas/07_graficas_macro/macro_descriptiva.png` (por periodo).
- Tabla `03_Resultados/Tablas/07_graficas_macro/macro_cortes_candidatos.png`
  (fecha de corte y alternativas).

Cronología (cada hito definido con una regla sobre las series):

| Fecha | Hito | Valor |
| --- | --- | --- |
| 2014-06-19 | Pico del Brent (cierre más alto de 2014) | 115,2 USD por barril |
| 2014-07-25 | Inicio de la depreciación (TRM más baja de 2014) | 1.846 pesos por dólar |
| 2014-10-30 | **Corte antes/después**: primera reunión con el Brent 20 % o más por debajo de su máximo de 12 meses | Brent 86,9 USD (−24,6 %) |
| 2015-09-25 | Primera alza de la tasa de intervención | +25 pb, a 4,75 % |
| 2016-01-20 | Valle del Brent (más bajo de 2015–2016) | 26,0 USD por barril |
| 2016-02-12 | Pico de la TRM (más alta de 2015–2016) | 3.435 pesos por dólar |
| 2016-07-29 | Última alza del ciclo | +25 pb, a 7,75 % |
| 2016-07 | Pico de la inflación total | 8,97 % anual |

Del pico al valle, el Brent cayó un 77 % (de 115,2 a 26,0 dólares) y la TRM
subió un 86 % (de 1.846 a 3.435 pesos). Son cálculos con los valores de la
tabla.

Por periodo de política monetaria (`macro_descriptiva`), entre P3
(2011-02 a 2014-09) y P4 (2014-09 a 2016-12):
- **Brent:** de 110,1 a 51,3 dólares en promedio.
- **TRM:** de 1.858 a 2.810 pesos en promedio.
- **Inflación total:** de 2,8 % a 5,8 % en promedio.
- **Brecha frente a la meta del 3 %:** de −0,2 a 2,8 puntos porcentuales.
- **Meses con la inflación fuera del rango meta (2 % a 4 %):** de 14 % a 81 %.

## Ejemplos de los documentos

Las dos decisiones que abren y cierran el ciclo de alzas, citadas de los
comunicados del día de la reunión:

- Comunicado del 25 de septiembre de 2015: "La Junta Directiva del Banco de la
  República en su sesión de hoy decidió incrementar la tasa de interés de
  intervención en 25 pb y la situó en 4,75%."
- Comunicado del 29 de julio de 2016: "La Junta Directiva del Banco de la
  República en su sesión de hoy decidió incrementar la tasa de interés de
  intervención en 25pb y la situó en 7,75%."

Entre esas dos fechas la Junta subió la tasa en 11 reuniones. La del 30 de
octubre de 2015 no tiene comunicado en los datos y se lee de la minuta. Esta
nota no usa ninguna medida de texto: las citas solo documentan las decisiones
de tasa.

## Qué dice, en lenguaje intuitivo

Colombia exporta petróleo. Cuando el precio del barril se desplomó a partir de
mediados de 2014, entraron menos dólares al país y el peso perdió casi la mitad
de su valor frente al dólar en año y medio. Un peso más débil encarece todo lo
importado, y con rezago la inflación subió desde menos del 3 % hasta casi el
9 % a mediados de 2016, el triple de la meta. La Junta empezó a subir la tasa en
septiembre de 2015, más de un año después de que el petróleo empezara a caer,
y paró en julio de 2016, el mismo mes en que la inflación tocó su techo.

En la figura de la cronología, cada panel es una serie. Los puntos marcan los
hitos y la franja gris es el ciclo de alzas. La línea negra vertical es la
fecha que separa el "antes" y el "después" para comparar de qué habla la
Junta.

## Por qué importa en el estudio

Ordena la pregunta del taller. El choque tuvo tres etapas: el precio del
petróleo, la tasa de cambio y la inflación. Si los temas de la Junta cambian
después del corte, lo esperable es ver primero el entorno externo y el
petróleo, luego la tasa de cambio y su traspaso a los precios, y al final las
expectativas de inflación y la respuesta de la tasa.

Para la mesa de renta fija, la cronología muestra que la respuesta de la tasa
llegó cuando la depreciación ya estaba en los precios, no cuando cayó el
petróleo. Es una descripción de la secuencia, no una evaluación de la política.

La fecha de corte (2014-10-30) se fijó solo con estas series y con las
decisiones de tasa, antes de mirar cualquier medida de texto: es la primera
reunión en que la Junta tenía un Brent 20 % o más por debajo de su máximo
reciente. Las alternativas para la robustez son el 2014-09-26 (apertura de P4)
y el 2014-12-19 (primera reunión con la TRM depreciada más de 20 % anual).

## Límites e incertidumbre

- **Es una secuencia, no una cadena causal demostrada.** En 2015–2016 pudieron
  pesar otros choques sobre la inflación (los documentos de la Junta mencionan,
  por ejemplo, el fenómeno de El Niño); estas series no los separan del traspaso
  de la tasa de cambio.
- **Los hitos dependen de las ventanas elegidas.** Si el pico del Brent se busca
  en 2013–2014 cae en febrero de 2013; se usa 2014 porque es el año de la caída.
- **La alineación por reunión supone que el IPC se publica el día 8 del mes
  siguiente.** Eso afecta qué dato de inflación tenía la Junta en cada reunión,
  no la cronología mensual.
- **El corte no coincide con el cambio de formato de las minutas (2014-05-30),
  pero está cerca:** quedan 5 minutas del formato B antes del corte. Además, en
  una ventana de 5 años las minutas tienen la mitad de palabras después del
  corte. Cualquier comparación de temas en minutas debe normalizar por
  extensión y contrastarse con los comunicados, que están equilibrados.

## Historial

- 2026-11-19: nota creada con la cronología de `07_graficas_macro.R` y el corte
  aprobado (2014-10-30).
