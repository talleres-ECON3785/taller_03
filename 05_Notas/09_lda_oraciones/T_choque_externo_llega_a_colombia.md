# Después del choque, la Junta dejó de describir la economía mundial y pasó a discutir cómo el choque llega a Colombia: el déficit externo y la capacidad productiva

- **Estado:** vigente
- **Tipo / fuente:** T; comunicados y minutas (solo la discusión de la Junta); descriptivo
- **Script de origen:** `02_Scripts/09_lda_oraciones.R`
- **Última verificación:** 2026-11-21, con `02_Scripts/09_lda_oraciones.R`

## Evidencia

- Figura `03_Resultados/Figuras/09_lda_oraciones/conjunto_lda_antes_despues.png`.
- Tablas `03_Resultados/Tablas/09_lda_oraciones/conjunto_lda_antes_despues.png`
  (medias, diferencia, IC 95 % y lectura), `conjunto_lda_topicos.png` (palabras)
  y `conjunto_lda_fragmentos.png` (bloques representativos); los cuatro
  escenarios en `conjunto_lda_antes_despues_detalle.csv`.
- Modelo de tópicos (LDA) con K = 10 y α = 0,1, estimado con 1.619 bloques de
  texto de la ventana 2009-10-30 a 2019-10-29; 54 comunicados antes y 53
  después, 59 minutas antes y 53 después del corte del 2014-10-30.
- Peso medio del tópico en la reunión (en %), antes → después, y diferencia en
  puntos porcentuales con su IC 95 % (prueba t de Welch por reunión):

  | Tópico | Comunicados | Minutas |
  | --- | --- | --- |
  | 6. Déficit externo y capacidad productiva | 2,3 → 16,4; +14,1 [11,4; 16,8] | 2,6 → 12,0; +9,4 [6,9; 11,9] |
  | 10. Economía mundial | 16,1 → 5,5; −10,6 [−13,3; −7,9] | 13,5 → 4,2; −9,3 [−11,4; −7,2] |

- Lectura: «robusta» en los dos tópicos y las dos fuentes. El signo se
  mantiene con la muestra completa 2007–2026 (tópico 6: +10,0 y +7,8; tópico 10:
  −7,0 y −6,5) y con los cortes 2014-09-26 y 2014-12-19.

## Ejemplos de los documentos

- Tópico 6, comunicado 2017-08-31: «La debilidad de la actividad económica y el
  riesgo de una desaceleración más allá de la compatible con el deterioro en la
  dinámica del ingreso originado por la caída en los precios del petróleo».
- Tópico 6, comunicado 2018-04-27: «Los pronósticos del equipo técnico del
  Banco apuntan hacia un leve cierre del déficit en la cuenta corriente de la
  balanza de pagos como proporción del PIB».
- Tópico 10, minuta 2014-01-31: «En el cuarto trimestre de 2013 la actividad
  económica mundial continuó recuperándose gracias al mayor dinamismo de las
  economías desarrolladas, en especial de Estados Unidos. En la zona del euro
  los indicadores económicos sugieren un crecimiento…».
- Tópico 10, comunicado 2012-10-26: «La desaceleración observada en algunas de
  las economías emergentes de mayor tamaño parece estar estabilizándose».

## Qué dice, en lenguaje intuitivo

El modelo divide el texto de cada reunión en temas y estima qué parte del
texto dedica la Junta a cada uno. Antes del choque, unas 15 de cada 100
palabras de los comunicados describían la economía mundial (Estados Unidos,
la zona del euro, Asia, los emergentes) y apenas 2 hablaban del déficit
externo. Después, la proporción se invierte: el déficit de cuenta corriente,
la capacidad productiva y la debilidad de la actividad pasan a ocupar unas 16
de cada 100 palabras, y la economía mundial baja a unas 5. Las minutas
muestran lo mismo.

- **Objeto de interés:** qué parte de la conversación de la Junta se dedica al
  exterior y de qué manera.
- **Medida:** la proporción de cada tópico en el texto de la reunión (θ medio
  de sus bloques).
- **Estimación:** las diferencias de la tabla.

Para la mesa de renta fija: después de 2014, cuando la Junta habla del
exterior, ya no describe el ciclo mundial, sino sus efectos sobre Colombia
(el ingreso por el petróleo, el déficit externo, la financiación). Es la
lectura que hay que seguir en los comunicados para anticipar la postura.

## Por qué importa en el estudio

Responde a la pregunta del taller con una medida distinta del diccionario. El
choque petrolero redujo el ingreso nacional y amplió el déficit de cuenta
corriente, que llegó a ser una preocupación explícita de la política monetaria.
El comunicado 2016-04-29 justifica un alza de tasa «con el fin de asegurar que
la inflación converja a la meta en 2017 y contribuir a la reducción en el
déficit de la cuenta corriente» (ver `T_decision_postura_sube.md`). La Junta
pasó de mirar afuera a mirar cómo lo de afuera entra al país.

**Contraste con `08_antes_despues/`:**
- **Consistente** con `T_cuenta_corriente_deficit_externo.md`: el déficit y la
  balanza de pagos entran al vocabulario después del corte.
- **Cambia (atribuible)** frente a `T_atencion_temas_antes_despues.md`: allí el
  tema «Entorno externo» sube (+6,5 por 1.000 palabras en comunicados, robusto;
  matizado en minutas). La diferencia viene de la medida: el diccionario
  junta la economía mundial con el petróleo, la tasa de cambio, la cuenta
  corriente y la depreciación, y el LDA los separa en «Economía mundial»
  (baja) y en los tópicos 4 y 6 (suben). Las dos medidas son coherentes en la
  dirección del cambio antes/después; el LDA muestra su composición
  (heurística H2).
- **Reunión a reunión, coherentes solo en las minutas** (P3a.9; ventana, 107
  comunicados y 112 minutas; `03_Resultados/Tablas/09_lda_oraciones/conjunto_lda_vs_diccionario.png`).
  La suma de los tópicos 6 y 10 se mueve con el tema «Entorno externo» del
  diccionario en las minutas (correlación de 0,39 [0,23; 0,54]), pero no en los
  comunicados (0,04 [−0,15; 0,23]). Hipótesis: en los comunicados, el tema del
  diccionario lo dominan palabras genéricas («internacional», «externo»,
  «mundial»), algunas de las cuales bajan después del corte y otras suben; el
  LDA las reparte entre varios tópicos y el conteo no sigue a ninguno en
  particular. Para seguir
  el sector externo reunión a reunión en los comunicados, el diccionario es
  demasiado genérico; para el antes/después, las dos medidas coinciden.

## Límites e incertidumbre

- Asociación, no causalidad: el cambio coincide con el choque, pero en la
  ventana también hubo otros eventos (normalización de la Reserva Federal,
  desaceleración de China, El Niño de 2015–2016).
- El nombre de cada tópico es una interpretación sostenida por sus palabras y
  sus fragmentos. El tópico 6 junta el déficit externo con la capacidad
  productiva y la debilidad de la actividad: es el diagnóstico de ajuste de la
  economía después del choque, no solo el sector externo.
- El primer fragmento del tópico 6 en `conjunto_lda_fragmentos.png`
  (comunicado 2019-07-26) incluye la lista de asistentes: para la presentación
  se usan los otros dos.
- El tópico 10 tiene el 84 % de su peso en las minutas del formato A, pero su
  caída es igual en los comunicados, que no cambian de formato.
- La hipótesis sobre las palabras genéricas no está verificada con un resultado
  guardado: faltan los conteos de esas palabras por época y cómo se reparten
  entre tópicos en la matriz β del modelo.
- El modelo se estimó con la ventana; fuera de ella, los pesos salen del mismo
  modelo (muestra completa) y la estructura de tópicos puede no describir bien
  2020–2026.

## Historial

- 2026-11-21: nota creada con la primera corrida de `09_lda_oraciones.R`.
- 2026-11-21 (pendiente de conciliar, P3a.9): reunión a reunión, la suma de los tópicos 6 y 10 se correlaciona con el tema «Entorno externo» del diccionario en las minutas (0,39 [0,23; 0,54]) pero no en los comunicados (0,04 [−0,15; 0,23]; ventana, 107 y 112 reuniones; `03_Resultados/Tablas/09_lda_oraciones/conjunto_lda_vs_diccionario.png`). La frase «las dos medidas son coherentes» del contraste con `08` queda en revisión; las cifras antes/después de esta nota no cambian.
- 2026-11-21: con la confirmación de Santiago Muñoz Martínez, el contraste con `08` se matiza: coherentes en la dirección antes/después y, reunión a reunión, solo en las minutas. Estado sin cambios (vigente): las cifras antes/después no cambian.
