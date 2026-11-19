# Bitácora — 2026-11-19: gráficas macro, alineación por reunión y fecha de corte (H1 y H2)

Sesión de Samuel Escandón, rama `SamuelEscandonC`.

## Resumen

Objetivo: cerrar H1 (series macro, descriptiva por periodo, cronología del
choque y regla de alineación) y H2 (fecha de corte antes/después del choque
petrolero de 2014) de `PLAN.md`. La pregunta del taller es «¿Cómo cambiaron los
temas de interés de la Junta del Banco de la República antes y después de la
crisis del petróleo de 2014 en Colombia?».

**Regla de H2:** el corte se fijó solo con las series macro y las decisiones de
tasa. En toda la sesión no se calculó ni se miró ninguna medida de texto. Del
corpus solo se usaron fechas, formato y número de palabras.

Desarrollo:

1. **Sincronización.** Se cambió a `SamuelEscandonC` y se trajo `main` (PR #3 de
   Santiago: pregunta, TRM, series macro y `PLAN.md`), sin conflictos.
2. **Inflación total y meta.** El xlsx de inflación solo traía tres medidas
   básicas; la meta del Banco se define sobre la inflación total. Se avisó al
   usuario con la URL de la página del Banco. El usuario descargó dos archivos
   (IPC total y «Meta e inflación anual»). Los guardó en la carpeta principal
   del repositorio y se copiaron a la de esta sesión. `06_series_macro.R` los
   lee y verifica.
3. **Formato.** Se agregaron `capa_periodos()`, `capa_corte()` y
   `colores_macro` a `00_formato_graficas.R`.
4. **`07_graficas_macro.R`.** Series mensuales, alineación por reunión, dos
   figuras, cuatro tablas y las reglas de corte. Cada figura y tabla se revisó
   a ojo; se corrigieron el pico del Brent (ver abajo) y tres rótulos que se
   cortaban o se montaban sobre las líneas.
5. **H2.** Se propusieron la candidata 2014-09-26 y dos reglas mecánicas. El
   usuario aprobó la regla (i), 2014-10-30. Se registró en `CLAUDE.md`, se
   dibujó en las dos figuras y se escribió la nota de hallazgo.
6. **Corrida completa.** Antes de llevar la rama a `main`, se corrió
   `00_main.R` completo: los siete scripts corren sin errores en 3,4 minutos.
   `main` no había avanzado. Frente a lo ya versionado, solo cambiaron los
   decimales 15 y 16 de los resultados del LDA (ruido de punto flotante) y los
   fines de línea de algunos `.csv`. Ninguna cifra de las notas de `05_Notas/`
   cambia.

Frente a los "Siguientes objetivos" de `HANDOFF.md`:
- Objetivo 1 (P1.1–P1.5): **cumplido**.
- Objetivo 2 (P2.1–P2.3): **cumplido**.
- Objetivo 3 (P3.1–P3.2, ventana y embeddings): no se trabajó. Queda para la
  siguiente sesión, con la recomendación de usar `pairwise_cor()` como medida
  principal.

## Archivos

- Creados:
  - `02_Scripts/07_graficas_macro.R`
  - `01_Datos/01_Crudos/IPC TOTAL_Variación_Porcentual_Anual.xlsx` y
    `01_Datos/01_Crudos/Meta e inflación anual.xlsx` (descargados por el
    usuario; sin modificar)
  - `01_Datos/03_Listos/macro_inflacion_total.rds`, `macro_meta.rds`,
    `macro_por_reunion.rds`
  - `03_Resultados/Figuras/07_graficas_macro/` (2 figuras) y
    `03_Resultados/Tablas/07_graficas_macro/` (4 tablas en `.png` y `.csv`)
  - `05_Notas/07_graficas_macro/M_cronologia_choque_petrolero.md`
  - Esta bitácora
- Modificados: `00_main.R`, `02_Scripts/00_formato_graficas.R`,
  `02_Scripts/00_funciones_texto.R`, `02_Scripts/06_series_macro.R`,
  `CLAUDE.md`, `PLAN.md`, `README.md`, `HANDOFF.md`, `05_Notas/README.md`.
  El usuario corrió `00_main.R`, que regeneró algunos `.rds` y `.png` de los
  scripts 01 a 06 sin cambios de contenido esperados.
- Eliminados: ninguno.

## Detalle por archivo

### `02_Scripts/06_series_macro.R`
Lee los dos archivos nuevos con la función `leer_banrep()` que ya existía:
- **`macro_inflacion_total.rds`:** fecha (fin de mes) e `inflacion_total`, 322
  meses desde 2000.
- **`macro_meta.rds`:** una fila por año, con `meta`, `rango_inf` y
  `rango_sup`.
  - El archivo repite la meta en cada mes; se deja una fila por año.
  - El rango no viene como serie. Se construye con la nota del propio archivo:
    ±0,5 pp entre 2003 y 2009 y ±1 pp desde 2010.

Verificaciones con `stopifnot()`:
- La inflación total coincide con cuatro cifras conocidas: dic-2014 3,66 %,
  dic-2015 6,77 %, jul-2016 8,97 % y dic-2022 13,12 %, con tolerancia de
  ±0,05 pp.
- La inflación que trae el archivo de la meta es la misma serie.
- Hay una meta por año de 2000 a 2026, y es 3 % desde 2010.

Meta de los años del corpus: 4 % en 2007 y 2008, 5 % en 2009 y 3 % desde 2010.
Por pedido del usuario, la meta sale de este archivo y no de los comunicados.

### `02_Scripts/00_formato_graficas.R`
- **`capa_periodos()`:** sombreado gris tenue alternado de los periodos P1–P10,
  con rótulos opcionales. Con facetas, los rótulos van solo en el panel que se
  indique.
- **`capa_corte()`:** línea vertical continua con rótulo. Se distingue de los
  cortes de formato, que son punteados.
- **`colores_macro`:** un color fijo por serie, para que cada una conserve su
  color en todas las figuras. Brent en azul, TRM en ocre, inflación total en
  verde-azulado, núcleo 15 en gris punteado y la meta en gris oscuro.

### `02_Scripts/00_funciones_texto.R`
Nueva sección 7 con `corte_crisis` (2014-10-30) y `cortes_alternativos`
(2014-09-26 y 2014-12-19). Viven aquí porque H3 los va a usar en el análisis de
texto.

### `02_Scripts/07_graficas_macro.R`
Solo lee las series macro, las decisiones de tasa y los metadatos del corpus.

**Series mensuales:**
- Brent: promedio mensual de los días con cotización.
- TRM: promedio mensual de lunes a viernes. El archivo repite el valor del
  viernes el fin de semana y, sin este filtro, ese valor pesaría el triple.
- Variación anual en % de cada una.
- Brecha de inflación: inflación total (y núcleo 15) menos la meta del año del
  dato, en puntos porcentuales.

**Alineación por reunión (P1.4).** Regla escrita en `CLAUDE.md` antes de
aplicarla. A cada una de las 205 reuniones se le asigna el último dato que la
Junta tenía:
- **Brent:** el cierre del día hábil anterior.
- **TRM:** la vigente el día de la reunión.
- **Inflación:** el último mes publicado.
  - **Supuesto:** el IPC del mes m se publica el día 8 del mes m+1. Es
    conservador, porque el DANE suele publicar entre el 4 y el 8.
  - Intuición: nunca darle a la Junta un dato que todavía no tenía.
- **Máximo del Brent:** el de los 12 meses previos.

El resultado se guarda en `macro_por_reunion.rds` para H3 y H4. Verificaciones:
205 filas, sin vacíos, el Brent siempre anterior a la reunión y el dato de
inflación de 8 a 70 días antes.

**Hitos de la cronología.** Cada uno se define con una regla, no a ojo:
- pico del Brent: cierre más alto de 2014;
- valle del Brent: más bajo de 2015–2016;
- inicio de la depreciación: TRM más baja de 2014;
- pico de la TRM: más alta de 2015–2016;
- pico de la inflación: mes más alto de 2015–2017;
- primera y última alza del ciclo de 2015–2016: leídas de las decisiones de los
  comunicados.

Corrección en la revisión visual: con la ventana 2013–2014, el pico del Brent
caía en febrero de 2013, lejos del comienzo de la caída. Se cambió a 2014 y
ahora es el 2014-06-19 (115,2 USD).

El script verifica que la primera alza sea el 2015-09-25 y la última el
2016-07-29, ambas con comunicado. La alza del 2015-10-30 no tiene comunicado en
los datos y se lee de la minuta.

**Reglas de corte (H2).** Calculadas con las series diarias y con las
alineadas, buscando desde el 2014-01-01 para no tomar la crisis de 2008:
- **(i):** Brent 20 % o más por debajo de su máximo de 12 meses.
- **(ii):** depreciación anual de la TRM mayor que 20 %.

El script verifica que la regla (i) dé `corte_crisis` y la (ii) la alternativa
`depreciacion_trm`; si las series cambian, se detiene. También cuenta, para
cada corte, las minutas del formato B anteriores y las reuniones y palabras de
la Junta a cada lado en una ventana de 5 años. Son metadatos, no medidas de
texto.

### `CLAUDE.md`
- "Alineación temporal": la regla de alineación (P1.4).
- "Definición de variables": `inflacion_total`, la meta y su rango, la brecha,
  y el Brent y la TRM mensuales con sus variaciones.
- "Decisiones tomadas": fila del corte, con la regla, las cifras, las
  alternativas y la salvedad del formato.

### `PLAN.md`, `README.md`, `00_main.R`
- `PLAN.md`: casillas P1.1–P1.5 y P2.1–P2.3 marcadas. En P1.2 se anota que la
  serie principal es la inflación total.
- `README.md`: las dos fuentes nuevas, las transformaciones y la alineación, y
  el mapa de `07`.
- `00_main.R`: `07` en `scripts` y sus dos carpetas en `carpetas_salida`.

## Resultados nuevos (tablas, figuras, gráficos)

Todos sostienen la nota
[05_Notas/07_graficas_macro/M_cronologia_choque_petrolero.md](../05_Notas/07_graficas_macro/M_cronologia_choque_petrolero.md).

- **`macro_series_2007_2026.png`.** Cuenta la historia completa: las tres
  series, la meta escalonada con su rango, los periodos sombreados y la línea
  del corte.
- **`macro_cronologia_choque.png`.** Es la figura que cuenta el choque, pensada
  para leerse a media pantalla. Va del pico del Brent (2014-06-19) a la última
  alza (2016-07-29) y al pico de la inflación (julio de 2016, 8,97 %). Muestra
  el ciclo de alzas como franja gris y el corte como línea negra.
- **`macro_descriptiva`.** Media, mínimo, máximo y variación de cada serie por
  periodo, con la brecha frente a la meta y el % de meses fuera del rango meta.
  P3 y P4 van resaltados. De P3 a P4: el Brent promedio pasa de 110,1 a 51,3
  USD, la TRM de 1.858 a 2.810 y la brecha de −0,2 a 2,8 pp.
- **`macro_cronologia`.** Cada hito con fecha, valor y la cita del comunicado
  cuando es una decisión de tasa.
- **`macro_cortes_candidatos` y `conjunto_ventanas_corte`.** Insumo de H2 y de
  la ventana de H3:
  - Candidata 2014-09-26 (Brent −17,4 %).
  - Regla (i), 2014-10-30 (−24,6 %), aprobada.
  - Regla (ii), 2014-12-19 (TRM +20,0 %).
  - En 5 años, los comunicados quedan equilibrados (54 y 53 reuniones; unas
    29.700 y 30.600 palabras).
  - Las minutas no: unas 43.800 palabras antes y 23.100 después, por el cambio
    de formato.

## Pendientes

- **H3 (siguiente objetivo).** Recomendación de la sesión: usar
  `pairwise_cor()` de `widyr` (catálogo, Lab 11, sección 4) como medida
  principal antes/después, y los embeddings solo como complemento, con su
  ampliación registrada antes de usarlos.
  - Razón: `pairwise_cor()` está en el catálogo, es transparente y con este
    corpus es más estable que entrenar dos modelos de embeddings.
  - Hay que agregar `widyr` al `p_load()`.
  - Usar `corte_crisis` y `cortes_alternativos` de `00_funciones_texto.R`.
  - Normalizar por extensión y contrastar minutas con comunicados.
- **Archivos en la carpeta principal.** El usuario dejó los dos xlsx también en
  `01_Datos/01_Crudos/` de la carpeta principal, que está en `main` y sin
  versionar. Al traer esta rama a esa carpeta, git puede negarse a sobrescribir
  esos archivos sin seguimiento: hay que borrarlos o moverlos antes.
- **Supuesto sin confirmar:** que el IPC se publica el día 8 del mes siguiente.
- **Redacción pendiente de sesiones anteriores:** el README y `CLAUDE.md` aún
  llaman "festivos" a los días sin cotización del Brent.
