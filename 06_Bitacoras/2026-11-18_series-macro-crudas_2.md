# Bitácora — 2026-11-18: incorporación de las primeras series macro

## Resumen

Santiago Muñoz Martínez (rama `SantiagoMunozM`) agregó tres archivos crudos de
series macroeconómicas a `01_Datos/01_Crudos/` y pidió documentar su fuente y
leerlos con un script del pipeline, filtrados desde 2000 y guardados como `.rds`
en `01_Datos/03_Listos/`. Se escribió `02_Scripts/06_series_macro.R`, se
registraron las fuentes en el README y en `CLAUDE.md`, y se registró `readxl`
como ampliación del catálogo.

Después se revisó la calidad de la serie del Brent:

- Los 500 días hábiles sin precio de FRED son los mismos que trae la fuente
  primaria (EIA, serie `RBRTE`). Se descargó y comparó el archivo
  `PET_PRI_SPT_S1_D.xlsx` y las fechas y valores coinciden en los 6.511 días con
  dato. El equipo decidió **quedarse con FRED** y no versionar el archivo de la
  EIA (se retiró de `01_Crudos/`).
- Los fines de semana no tienen precio ni fila en el crudo.
- Desde 2007 los huecos parecen feriados bancarios de Londres; entre 2000 y 2006
  hay 335 de los 500 y no se explican por feriados. No se encontró una nota
  oficial que lo confirme.

De los "Siguientes objetivos" del handoff: el objetivo 3 avanzó en su parte de
documentar los tres crudos (fuente, cobertura, transformaciones); no se fijó la
pregunta (1) ni se validó la votación (2).

## Archivos

- Creados: `02_Scripts/06_series_macro.R`;
  `01_Datos/03_Listos/macro_brent.rds`, `macro_inflacion.rds`, `macro_tcr.rds`
  (se generan con el script).
- Modificados: `00_main.R`, `README.md`, `CLAUDE.md`,
  `07_Recursos/catalogo_metodos.md`.
- Sin versionar todavía: los tres crudos de `01_Datos/01_Crudos/`
  (`brent_2000-26.csv`, `inflacion_variacion_anual_99_26.xlsx`,
  `tasa_cambio_real_70_26.xlsx`), agregados por el usuario.
- Eliminados: ninguno.

## Detalle por archivo

### `02_Scripts/06_series_macro.R`

Lee los tres crudos y guarda un `.rds` por fuente, solo con fechas desde
2000-01-01. No transforma ni alinea las series con las reuniones.

- **Brent** (`brent_usd`): se lee con `read_csv()`. Se eliminan 500 filas sin
  precio (lunes a viernes) y no se rellenan. Quedan 6.511 días, de 2000-01-04 a
  2026-11-17.
- **Inflación y tasa de cambio real:** los xlsx del Banco de la República traen
  los nombres de las series en la fila 3 de la hoja "Series de datos", la fecha
  como serial de Excel en la columna 1, un punto "." donde falta el dato y una
  nota al pie en la última fila. La función `leer_banrep()` convierte la fecha
  (origen 1899-12-30), descarta las filas no numéricas y filtra desde 2000.
  Quedan 322 meses (2000-01-31 a 2026-10-31) en cada archivo. La serie FMI de
  tasa de cambio real tiene un `NA` después de 2000.
- **Supuesto:** el formato de los xlsx (nombres en la fila 3, fecha en la
  columna 1) no cambia. El `stopifnot()` final verifica que no haya fechas
  anteriores a 2000 ni duplicadas y que las series sean numéricas.

### `00_main.R`

Se agregó `readxl` al `p_load()` y el script a la lista `scripts`. No hay
subcarpeta de resultados porque el script no genera tablas ni figuras.

### `README.md` y `CLAUDE.md`

README: tabla de fuentes macro (archivo, series, fuente con URL, fecha de
consulta, frecuencia y cobertura), transformaciones, dos salvedades (la fecha
mensual es el fin del mes de referencia, no la de publicación; los datos del
Banco de la República traen las revisiones al 2026-11-18) y entrada en el mapa
script → resultados. `CLAUDE.md`: filas en "Definición de variables" para el
Brent, las tres medidas de inflación y los seis índices de tasa de cambio real,
y una fila en "Decisiones tomadas".

### `07_Recursos/catalogo_metodos.md`

`readxl::read_excel()` se registró en "Registro de ampliaciones", con
aprobación atribuida a Santiago Muñoz Martínez por pedir el script. `readr` y
`lubridate` ya vienen con `tidyverse`.

## Medidas y series

Ninguna medida de texto. Las series entran sin transformar:

- **Inflación anual** (núcleo 15, sin alimentos ni regulados, sin alimentos):
  variación porcentual anual del IPC, DANE con cálculos del Banco de la
  República, mensual.
- **Índices de tasa de cambio real** (FMI, IPC NT, IPC T, IPP NT, IPP T,
  competidores): Banco de la República, mensual.
- **Brent** (`DCOILBRENTEU`): dólares por barril, FRED (datos de la EIA),
  diaria.

Todavía no se decidió cuáles entran al análisis ni su rol; eso depende de la
pregunta.

## Pendientes

- Corregir la palabra "festivos" en el README y en `CLAUDE.md`: los 500 días sin
  precio del Brent no son todos festivos (335 caen entre 2000 y 2006). Se
  propuso al usuario y quedó sin confirmar.
- Revisar si alguna reunión de la Junta cae en un día sin precio del Brent
  (sobre todo en 2007); el arrastre del último precio le asignaría un precio de
  hasta 11 días atrás.
- Citar la EIA como fuente primaria del Brent en el README (opcional).
- Escribir la regla de alineación temporal entre reuniones y series (último dato
  publicado a la fecha de la reunión) cuando se fije la pregunta.
- Versionar los tres crudos de `01_Crudos/` en el commit de cierre.
- Se mantienen los objetivos 1 y 2 del handoff (fijar la pregunta; validar la
  votación).
