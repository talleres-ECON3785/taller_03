# La atención al entorno externo subió en cuanto empezó a caer el Brent y tocó su máximo meses antes que el mínimo del Brent y el pico de la TRM; la atención a la inflación en las minutas se adelantó al pico de la inflación

- **Estado:** matizado (asociativo; depende de una media móvil y de la serie de texto)
- **Tipo / fuente:** X; comunicados, minutas (solo la discusión de la Junta) y series macro (Brent de FRED, TRM del Banco de la República, IPC del DANE); asociativo
- **Script de origen:** `02_Scripts/09_antes_despues.R`
- **Última verificación:** 2026-11-21, con `02_Scripts/09_antes_despues.R`

## Evidencia

- Figura `03_Resultados/Figuras/09_antes_despues/conjunto_temas_macro_por_reunion.png`
  (por reunión, 2007–2026; texto como media móvil de las últimas 5 reuniones;
  series macro con el último dato que la Junta tenía el día de la reunión,
  regla de `CLAUDE.md`).
- Tabla `03_Resultados/Tablas/09_antes_despues/conjunto_cronologia_texto_macro.png`
  (extremos de cada serie entre 2013 y 2018).

| Reunión | Evento | Valor |
| --- | --- | --- |
| 2015-06-24 | Máximo de la atención al entorno externo, minutas | 21,9 por 1.000 palabras |
| 2015-09-25 | Máximo de la atención al entorno externo, comunicados | 34,0 por 1.000 palabras |
| 2015-10-30 | Máximo de la atención a la inflación, minutas | 30,0 por 1.000 palabras |
| 2016-01-29 | Mínimo del Brent | 33,0 dólares por barril |
| 2016-02-19 | Máximo de la TRM | 3.338 pesos por dólar |
| 2016-08-31 | Máximo de la inflación total | 9,0 % |
| 2017-07-27 | Máximo de la atención a la inflación, comunicados | 32,1 por 1.000 palabras |

n = 194 comunicados y 199 minutas; 205 reuniones con datos macro.

En la figura, la atención al entorno externo de los comunicados salta en las
reuniones inmediatamente posteriores al corte (de unos 15 a más de 30 por
1.000 palabras entre fines de 2014 y 2015), a la vez que cae el Brent; en las
minutas el salto es menor y empieza desde un valle a mediados de 2014.

## Ejemplos de los documentos

- Comunicado del 2014-10-30 (primera reunión después del corte): «El precio
  internacional del petróleo ha caído y se encuentra por debajo del pronóstico
  que tenía el equipo técnico.»
- Minuta del 2014-11-28: «La fuerte caída en los precios internacionales del
  petróleo y otros productos básicos consolida un escenario de debilidad del
  entorno externo colombiano que afectará de manera negativa su desempeño a lo
  largo de 2015.»
- Comunicado del 2015-12-18: «…aumentos adicionales de la tasa de cambio,
  relacionados en buena parte con la caída del precio del petróleo, ejercen
  nuevas presiones sobre la inflación.»

## Qué dice, en lenguaje intuitivo

La figura pone, una debajo de otra, la atención de la Junta al entorno externo
y a la inflación y las tres series del choque. La atención al exterior sube
en cuanto el petróleo empieza a caer y llega a su punto más alto a mediados o
finales de 2015, antes de que el petróleo toque fondo y el dólar llegue a su
máximo (comienzos de 2016). En las minutas, la atención a la inflación llega a
su punto más alto en octubre de 2015, diez meses antes del pico de la
inflación. La Junta no esperó a ver el máximo de las series para hablar de
ellas: discutió el choque mientras se desarrollaba y anticipó su traslado a
precios.

## Por qué importa en el estudio

Relaciona el cambio de temas con la historia macro. Es coherente con un banco
central con meta de inflación que mira hacia adelante: el texto se mueve con
el inicio del choque (caída del Brent) y antes de sus efectos más fuertes
(TRM e inflación). Para la mesa, el texto de la Junta puede adelantar
preocupaciones que las cifras todavía no muestran.

## Límites e incertidumbre

- Asociación, no causalidad, y no es un modelo de rezagos: es una cronología
  de extremos sobre una media móvil de 5 reuniones (que suaviza y desplaza
  las fechas unas pocas reuniones).
- En los comunicados, la atención a la inflación tocó su máximo en 2017-07-27,
  después del pico de la inflación: el adelanto no se sostiene en los dos
  tipos de documento.
- Un solo episodio: no permite generalizar a otros choques.

## Historial

- 2026-11-21: nota creada con la primera corrida de `09_antes_despues.R`.
  Consistente con la cronología de
  [M_cronologia_choque_petrolero](../07_graficas_macro/M_cronologia_choque_petrolero.md)
  (valle del Brent en enero de 2016, pico de la TRM en febrero de 2016, pico de
  la inflación en julio de 2016; aquí con las fechas de las reuniones en que
  la Junta tenía esos datos).
