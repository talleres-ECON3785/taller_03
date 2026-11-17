# La minuta reveló hasta 2016 la votación que el comunicado no decía, y desde 2021 la mayoría de las decisiones son divididas

- **Estado:** vigente (clasificación automática, pendiente de validación manual)
- **Tipo / fuente:** T; comunicados y minutas; descriptivo
- **Script de origen:** `02_Scripts/04_bigramas.R`
- **Última verificación:** 2026-11-12, con `02_Scripts/04_bigramas.R` (corrida completa de `00_main.R`)

## Evidencia

- Tabla `03_Resultados/Tablas/04_bigramas/conjunto_votacion_comunicado_vs_minuta.png`.
- Tabla `03_Resultados/Tablas/04_bigramas/conjunto_votacion_por_anio.png` y
  figura `03_Resultados/Figuras/04_bigramas/conjunto_votacion_por_anio.png`.
- Por periodo: `03_Resultados/Tablas/04_bigramas/conjunto_votacion_por_periodo.csv`.
- Dirección del voto de la minoría:
  `03_Resultados/Tablas/04_bigramas/conjunto_minoria_por_anio.png`.
- Para validar: `03_Resultados/Tablas/04_bigramas/conjunto_votacion_validacion.csv`
  (oración de votación de cada documento) y
  `conjunto_votacion_muestra_validacion.csv` (muestra de 30 documentos).
- Efecto del formato: `03_Resultados/Tablas/04_bigramas/minutas_desacuerdo_por_formato.png`.

Medida: cada documento se clasifica como "unanimidad", "mayoría" o "sin
información" según las expresiones que usa en las oraciones que hablan de la
decisión («por unanimidad», «por mayoría», «la mayoría de los miembros»,
«grupo mayoritario», votos a favor o en contra). Búsqueda sobre el texto
extraído; en las minutas, sobre la discusión y la decisión de la Junta.

**Comunicado frente a minuta de la misma reunión** (188 reuniones con los dos
documentos, junio de 2007 a septiembre de 2026):

| El comunicado dice | Minuta: sin información | Minuta: unanimidad | Minuta: mayoría |
| --- | --- | --- | --- |
| Sin información | 23 | 36 | 32 |
| Unanimidad | 1 | 30 | 1 |
| Mayoría | 0 | 0 | 65 |

En 68 reuniones la minuta dice cómo se votó y el comunicado no. Los dos
documentos dicen lo mismo en 118 reuniones y se contradicen en 1.

**Decisiones por mayoría según la minuta, por periodo** (% de las minutas del
periodo; entre paréntesis, el mismo porcentaje según los comunicados):

| Periodo | Minutas | Mayoría, % |
| --- | --- | --- |
| P2 Crisis global y recortes (2008–11) | 26 | 15 (12) |
| P3 Normalización (2011–14) | 43 | 37 (5) |
| P4 Choque petrolero e inflación (2014–16) | 27 | 56 (8) |
| P5 Recortes y tasa estable (2016–20) | 30 | 50 (45) |
| P7 Alzas por inflación (2021–23) | 18 | 72 (61) |
| P8 Recortes (2023–25) | 12 | 92 (92) |
| P9 Pausa (2025–26) | 5 | 100 (100) |
| P10 Alzas de 2026 | 6 | 83 (83) |

**Dirección del voto de la minoría:** de 205 reuniones (la minuta o, si no
hay, el comunicado), 101 se clasifican como decididas por mayoría y en 66 se
pudo leer hacia dónde votó la minoría: 20 más restrictiva que la decisión, 39
más expansiva y 7 mixta. Por año, la dirección es codificable en todas las
reuniones por mayoría desde 2021 (6 de 6 en 2021 y en 2022, 5 de 5 en 2023, 8
de 8 en 2024, 7 de 7 en 2025 y 5 de 5 en 2026) y en 11 de 11 en 2017; antes de
2016 lo es en 9 de 36. En 2024 y 2025, 14 de las 15 minorías votaron por una
tasa más baja que la decidida.

## Ejemplos de los documentos

- Minuta del 27 de julio de 2012 (el comunicado de esa fecha no dice cómo se
  votó): "La mayoría de los miembros de la Junta consideró apropiado reducir la
  tasa de interés de intervención en 25 pb. [...] Otros miembros consideraron
  apropiado una reducción de 50 puntos básicos de la tasa de intervención del
  Banco".
- Minuta del 24 de febrero de 2017: "El grupo mayoritario votó por reducir la
  tasa 25 pb. [...] El grupo minoritario, reconociendo la importancia de un
  proceso de normalización gradual de la política monetaria, votó por mantener
  inalterada la tasa de referencia."
- Minuta del 16 de diciembre de 2022: "Cuatro directores votaron a favor de
  esta decisión. Un director votó por un incremento de 125 pb, y otro lo hizo
  por un aumento de 25 pb."

## Qué dice, en lenguaje intuitivo

Lo que se quiere conocer es si la Junta decidió dividida y hacia dónde quería
ir la minoría. La medida es lo que dicen los propios documentos sobre la
votación. Hay dos resultados. Primero, hasta 2016 el comunicado casi nunca
decía cómo se había votado y la minuta sí: quien solo leyera el comunicado no
sabía que más de la mitad de las decisiones de 2014 a 2016 fueron por mayoría.
Desde 2017 el comunicado ya lo dice. Segundo, las decisiones por mayoría son
la norma desde 2021: 72 % o más de las reuniones de cada periodo.

En la figura, cada barra es un año; el ocre son los documentos que reportan
mayoría, el verde los que reportan unanimidad y el gris los que no dicen nada.

## Por qué importa en el estudio

La votación es lo que la minuta agrega al comunicado de la forma más directa y
verificable, y la minuta llega unas dos semanas después de la reunión y antes
de la siguiente. Si la dirección del voto de la minoría (más restrictiva o más
expansiva que la decisión) dice algo sobre el siguiente movimiento de la tasa,
la mesa tendría una señal que hoy lee de manera informal. Esa relación no se
ha evaluado: aquí solo se muestra que la medida existe, cuántas reuniones cubre
y cómo cambia en el tiempo.

## Límites e incertidumbre

- **Es una clasificación automática sin revisión manual.** La muestra de 30
  documentos está por revisar; hasta entonces las cifras son provisionales.
- **Parte del cambio en el tiempo es de redacción.** Las palabras «votaron»,
  «votó» o «votos» aparecen en 2 % de las minutas del formato A (2007–2014) y
  en 83 % de las del formato E (desde 2023). En 2010 ninguna minuta trae
  información de votación. Un aumento de las decisiones por mayoría puede ser
  un cambio en cómo se reporta y no en cuánto se divide la Junta.
- El paso de 2016 a 2017 en los comunicados es un cambio en la política de
  comunicación, no en el entorno económico.
- La dirección de la minoría solo se lee cuando el texto da una cifra en puntos
  básicos o dice «mantener»: no es codificable en 35 de las 101 reuniones por
  mayoría, casi todas antes de 2016.
- El conteo de votos (por ejemplo, 4 a 3) solo se pudo leer en 36 documentos.
- 9 documentos usan «unanimidad» y «mayoría» a la vez y se clasifican como
  mayoría.
- Desde 2024 casi todas las decisiones son por mayoría: la variable
  "mayoría o unanimidad" apenas varía en los últimos tres años; la dirección
  de la minoría sí varía.

## Historial

- 2026-11-12: nota creada. Clasificación por expresiones y dirección de la
  minoría por lectura de las alternativas en puntos básicos; pendiente la
  validación manual con la muestra de 30 documentos.
