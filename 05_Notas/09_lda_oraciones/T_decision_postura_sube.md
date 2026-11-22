# Después del choque, la justificación de la decisión de tasa ocupa mucho más espacio en las minutas; en los comunicados el aumento es pequeño

- **Estado:** matizado (robusto por signo, pero en los comunicados el IC del escenario principal toca el cero y en las minutas puede pesar el formato)
- **Tipo / fuente:** T; comunicados y minutas (solo la discusión de la Junta); descriptivo
- **Script de origen:** `02_Scripts/09_lda_oraciones.R`
- **Última verificación:** 2026-11-21, con `02_Scripts/09_lda_oraciones.R`

## Evidencia

- Figura `03_Resultados/Figuras/09_lda_oraciones/conjunto_lda_antes_despues.png`.
- Tablas `03_Resultados/Tablas/09_lda_oraciones/conjunto_lda_antes_despues.png`,
  `conjunto_lda_topicos.png` y `conjunto_lda_fragmentos.png`; escenarios en
  `conjunto_lda_antes_despues_detalle.csv`.
- LDA con K = 10 y α = 0,1, ventana 2009-10-30 a 2019-10-29; 54 comunicados
  antes y 53 después, 59 minutas antes y 53 después del 2014-10-30.
- Tópico 3, «Decisión y postura de política monetaria» (palabras de mayor
  lift: necesario, macroeconómico, senda, postura de política, estabilidad,
  ajuste, compromiso). Peso medio en la reunión (en %), antes → después:
  - comunicados: 5,5 → 8,3; +2,8 pp [−0,1; 5,6];
  - minutas: 12,2 → 30,5; +18,4 pp [13,2; 23,6].
- Lectura «robusta» por la regla del signo: en los comunicados, +4,7 con la
  muestra completa y +2,8 y +3,0 con los cortes alternativos; en las minutas,
  +14,2, +19,0 y +17,4.

## Ejemplos de los documentos

- Comunicado 2016-04-29: «Con el fin de asegurar de que la inflación converja
  a la meta en 2017 y contribuir a la reducción en el déficit de la cuenta
  corriente, la Junta Directiva decidió aumentar en 50 pb la tasa de interés
  de referencia».
- Minuta 2011-05-30: «Teniendo en cuenta todos estos factores y los rezagos con
  los que las acciones de política monetaria afectan el gasto agregado y la
  inflación, la Junta consideró que el ajuste hacia una política monetaria
  menos expansiva debe continuar».
- Comunicado 2011-11-25: «la Junta considera prudente aumentar 25 puntos
  básicos la tasa de interés de intervención y cree que con ese movimiento se
  alcanza una postura monetaria que contribuye a maximizar el crecimiento del
  producto y el empleo…».

## Qué dice, en lenguaje intuitivo

Este tópico reúne el razonamiento de la decisión: qué postura es necesaria,
qué ajuste, qué compromiso con la meta. En las minutas, ese razonamiento pasa
de ocupar unas 12 de cada 100 palabras de la discusión de la Junta a unas 30.
En los comunicados también sube, pero poco (de unas 6 a unas 8 de cada 100
palabras).

- **Objeto de interés:** cuánto espacio dedica la Junta a justificar su decisión.
- **Medida:** la proporción del tópico 3 en el texto de la reunión.
- **Estimación:** las diferencias anteriores.

## Por qué importa en el estudio

Después del choque, la Junta tuvo que justificar alzas de tasa con una
economía que se desaceleraba (alzas contra la inflación desde 2015-09-25) y
después recortes con la inflación todavía alta (primer recorte el 2016-12-16,
apertura del periodo P5). Esa tensión, contener la
inflación por la depreciación sin ahogar una actividad debilitada, pide más
argumentación de la postura, y las minutas la registran. Para la mesa, la
minuta posterior al choque es más informativa sobre la función de reacción de
la Junta que antes.

## Límites e incertidumbre

- **Formato:** las minutas del formato B (desde 2014-05-30) tienen menos texto
  de discusión (unas 23 mil palabras después del corte, frente a 44 mil antes),
  y el párrafo de la decisión pesa proporcionalmente más en un texto corto.
  Parte del +18,4 puede venir de ahí. El tópico tiene el 66 % de su peso en el
  formato B, sin llegar a la alerta del 70 %. En la serie por reunión
  (`03_Resultados/Figuras/09_lda_oraciones/conjunto_lda_theta_por_reunion_topicos_1_4.png`),
  el salto de las minutas empieza con el cambio de formato del 2014-05-30, unos
  meses antes del corte, y se mantiene alto hasta 2018; en los comunicados no
  hay salto en esa fecha. Eso refuerza que parte del aumento en las minutas es
  de formato.
- **Comunicados:** el signo se mantiene en los cuatro escenarios, pero en el
  principal el IC va de −0,1 a 5,6. La evidencia en los comunicados es débil.
- El tópico 5 (decisión y votación: unanimidad, mayoría, subasta) no se repite
  con las otras semillas, así que no se interpreta. Parte del vocabulario de la
  decisión puede repartirse entre los tópicos 3 y 5.
- Asociación, no causalidad.

## Historial

- 2026-11-21: nota creada con la primera corrida de `09_lda_oraciones.R`.
- 2026-11-21: la serie por reunión 2007–2019 (P3a.10) muestra que el salto de las minutas coincide con el cambio de formato A→B; se agrega a los límites. Estado sin cambios (matizado).
