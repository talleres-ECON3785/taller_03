# Después del choque petrolero, la Junta incorporó a su vocabulario el déficit de cuenta corriente y la balanza de pagos, que antes casi no mencionaba

- **Estado:** vigente
- **Tipo / fuente:** T; comunicados y minutas (solo la discusión de la Junta); descriptivo
- **Script de origen:** `02_Scripts/09_antes_despues.R`
- **Última verificación:** 2026-11-21, con `02_Scripts/09_antes_despues.R`

## Evidencia

- Figura `03_Resultados/Figuras/09_antes_despues/conjunto_palabras_distintivas.png`.
- Tablas `03_Resultados/Tablas/09_antes_despues/minutas_palabras_robustez.png`,
  `comunicados_palabras_robustez.png` y `conjunto_fragmentos_palabras.png`
  (cifras en los `.csv` del mismo nombre y en `conjunto_palabras_cambio_detalle.csv`).
- Correlaciones: `03_Resultados/Tablas/09_antes_despues/minutas_correlaciones_anclas.png`
  y `comunicados_correlaciones_anclas.png`.

Épocas: antes = 2009-10-30 a 2014-10-29; después = 2014-10-30 a 2019-10-29.
n = 59 minutas antes y 53 después; 54 comunicados antes y 53 después.

| Término | Minutas antes → después (por 1.000 palabras) | Comunicados antes → después |
| --- | --- | --- |
| cuenta corriente | 0,00 → 2,03 (0 → 47 apariciones) | 0,00 → 1,41 (0 → 43) |
| déficit | 0,02 → 2,21 (1 → 51) | 0,03 → 2,14 (1 → 65) |
| balanza de pagos | 0,00 → 0,87 | razón después/antes 30,05 |

- Razón de frecuencias después / antes (con 0,5 apariciones sumadas a cada
  lado): cuenta corriente 180 en minutas y 84 en comunicados; déficit 65 y 42.
- **Robusta:** la dirección se mantiene en los dos tipos de documento, con la
  muestra completa 2007–2026 (cuenta corriente: razón 2,72 en minutas) y con
  los cortes 2014-09-26 (178) y 2014-12-19 (178).
- Después del corte, «déficit» aparece en las minutas sobre todo junto a
  «cuenta corriente» (correlación phi 0,92 en la misma oración) y «balanza de
  pagos» (0,57), y luego «vulnerabilidad» (0,29) y «financiamiento» (0,24).
  Antes del corte, «déficit» aparece en una sola oración de las minutas.

## Ejemplos de los documentos

- Comunicado del 2015-02-20: «Como resultado de la fuerte caída de los
  ingresos por exportaciones petroleras y del dinamismo de la demanda interna,
  el déficit en la cuenta corriente de la balanza de pagos del país se ha
  ampliado.»
- Minuta del 2015-05-22: «Con respecto al nivel alcanzado por el déficit en la
  cuenta corriente de la balanza de pagos, señalaron que ésta es una de las
  fuentes de mayor vulnerabilidad para la economía colombiana…»
- Minuta del 2016-03-18: «Los datos de cierre del déficit en la cuenta
  corriente de la balanza de pagos muestran una leve mejora en millones de
  dólares pero su nivel sigue exigiendo un ajuste…»

## Qué dice, en lenguaje intuitivo

Lo que se quiere conocer es si la Junta empezó a preocuparse por el
desequilibrio externo del país. La medida es cuántas veces aparecen estas
palabras por cada 1.000 palabras de texto, antes y después del 30 de octubre
de 2014. El resultado es un cambio de nivel, no de grado: en los cinco años
anteriores la Junta prácticamente no mencionaba la cuenta corriente, y en los
cinco años siguientes la menciona unas dos veces por cada 1.000 palabras, en
las minutas y en los comunicados. Los fragmentos muestran que la menciona como
consecuencia de la caída de los ingresos petroleros y como fuente de
vulnerabilidad.

## Por qué importa en el estudio

Responde directamente a la pregunta del taller: un tema nuevo entra a la agenda
de la Junta después del choque. La interpretación económica es que la caída
del petróleo redujo las exportaciones y amplió el déficit externo, y la Junta
lo incorporó como argumento de sus decisiones (el ajuste del gasto y de la
demanda interna). Para la mesa de renta fija, después de 2014 el déficit de
cuenta corriente pasó a ser parte del razonamiento de la Junta y no solo de
los reportes técnicos.

## Límites e incertidumbre

- Es un conteo de palabras: dice de qué se habla, no qué peso tiene en la
  decisión.
- El cambio aparece en comunicados y minutas, así que no se explica por el
  cambio de formato de las minutas (2014-05-30); aun así, cambios de redacción
  del comunicado (más párrafos sobre el contexto externo) pueden contribuir.
- La relación con la caída del Brent es asociativa: el corte se fijó con el
  Brent y la cuenta corriente también responde a otros factores.
- Falta confirmar con el LDA (08) y los embeddings (10) si aparece un tema o
  un vecindario «externo» nuevo después del corte.

## Historial

- 2026-11-21: nota creada con la primera corrida de `09_antes_despues.R`.
