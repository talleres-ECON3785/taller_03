# Hasta abril de 2019, menos de un tercio de cada minuta es discusión de la Junta

- **Estado:** vigente
- **Tipo / fuente:** T; minutas; descriptivo
- **Script de origen:** `02_Scripts/01_extraer_texto.R`
- **Última verificación:** 2026-11-12, con `02_Scripts/01_extraer_texto.R` (corrida completa de `00_main.R`)

## Evidencia

- Tabla `03_Resultados/Tablas/01_extraer_texto/minutas_cortes_formato.png` (y `.csv`).
- Figura `03_Resultados/Figuras/01_extraer_texto/minutas_palabras_por_seccion.png`.
- Detalle por documento: `03_Resultados/Tablas/01_extraer_texto/conjunto_metadatos_documentos.csv`.

Las 199 minutas (junio de 2007 a septiembre de 2026) tienen cinco formatos,
identificados por sus encabezados de sección. Palabras por minuta (mediana):

| Formato | Primera reunión | Minutas | Total | Equipo técnico | Discusión de la Junta | % del texto que es de la Junta |
| --- | --- | --- | --- | --- | --- | --- |
| A. Antecedentes del equipo técnico + discusión + decisión | 2007-06-15 | 83 | 2.835 | 1.736 | 761 | 26,8 |
| B. Síntesis del equipo técnico + discusión + decisión | 2014-05-30 | 55 | 1.383 | 823 | 414 | 29,9 |
| C. Discusión + decisión, sin equipo técnico | 2019-06-21 | 9 | 457 | 0 | 403 | 88,2 |
| D. Texto corrido, sin secciones | 2020-07-31 | 23 | 919 | 0 | 919 | 100,0 |
| E. Titular con la decisión + texto corrido | 2023-03-30 | 29 | 1.448 | 0 | 1.448 | 100,0 |

"Discusión de la Junta" son las secciones «Discusión y opciones de política» y
«Decisión de política» en los formatos A a C, y todo el cuerpo en D y E. El
resto del texto en A a C es la visión del equipo técnico y el preámbulo con la
lista de asistentes.

## Ejemplos de los documentos

- Minuta del 26 de abril de 2019 (última del formato B): "A continuación, se
  presenta una síntesis de la visión del equipo técnico del Banco de la
  República sobre la situación macroeconómica (sección 1) y posteriormente se
  reseñan las principales discusiones de política monetaria consideradas por la
  Junta Directiva (sección 2)."
- Minuta del 21 de junio de 2019 (primera del formato C): "A continuación, se
  reseñan las principales discusiones de política monetaria consideradas por la
  Junta Directiva (sección 1)."
- Minuta del 31 de julio de 2020 (primera del formato D), sin encabezados: "En
  su reunión del 31 julio la Junta Directiva evaluó las últimas cifras
  disponibles sobre la actividad económica nacional e internacional. A
  continuación, se señalan los principales elementos de la discusión de
  política monetaria."

## Qué dice, en lenguaje intuitivo

Lo que se quiere conocer es cuánto de cada minuta recoge lo que discutieron los
miembros de la Junta. La medida es el número de palabras de las secciones de
discusión y decisión frente al total. El resultado: entre 2007 y abril de 2019
la mayor parte de la minuta era un resumen del equipo técnico sobre inflación,
crecimiento y contexto externo; la discusión de la Junta ocupaba entre 27 % y
30 % del texto. Desde junio de 2019 la minuta solo trae la discusión.

En la figura, cada barra es una minuta: la parte gris clara es el equipo
técnico y la ocre es la Junta. La minuta se acorta mucho en 2014 y en 2019,
pero la parte ocre no cae igual: pasa de unas 760 palabras a unas 400, y desde
2021 crece hasta unas 1.450.

## Por qué importa en el estudio

Condiciona cualquier medida sobre minutas. Una frecuencia o un tópico calculado
con el texto completo mezcla, hasta 2019, lo que dijo el equipo técnico con lo
que discutió la Junta, y una tendencia puede venir de la salida de esa sección
y no de un cambio en la discusión. Por eso las medidas del taller se reportan
con la discusión de la Junta y, al lado, con el texto completo. Para la mesa,
el documento que lee hoy como "minuta" no es comparable, sin esta separación,
con el de hace diez años.

## Límites e incertidumbre

- La separación depende de encontrar los encabezados; se verificó que los cinco
  formatos son contiguos en el tiempo y que las 199 minutas quedan clasificadas.
- En los formatos D y E no hay secciones: todo el cuerpo cuenta como discusión
  de la Junta, aunque sus primeros párrafos repiten los datos que ya traía el
  comunicado. La versión "solo Junta" no es igual de limpia antes y después de
  2020; falta separar esos párrafos de contexto.
- La frontera del periodo P6 (2020-03-27) queda dentro del formato C, a cuatro
  meses del corte del formato D: una diferencia entre P5 y P6 en las minutas
  puede ser de formato.
- No dice nada todavía sobre el contenido de la discusión, solo sobre su
  extensión.

## Historial

- 2026-11-12: nota creada. Primera medición, con la extracción de `pdftools` y
  la separación por encabezados de sección.
