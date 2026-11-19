# Bitácora — 2026-11-18: pregunta del taller y TRM diaria

## Resumen

Sesión de Santiago Muñoz Martínez (rama `SantiagoMunozM`) con dos partes.

1. El equipo fijó la pregunta del taller: **«¿Cómo cambiaron los temas de
   interés de la Junta del Banco de la República antes y después de la crisis
   del petróleo de 2014 en Colombia?»**. Las series macro (caída del petróleo,
   aumento de la TRM, efecto sobre la inflación) cuentan la historia y se
   relacionan con los cambios de temas; el método previsto son embeddings de
   palabras (GloVe o Word2Vec). La pregunta y el método quedaron registrados en
   `CLAUDE.md`, `README.md`, `HANDOFF.md` y el catálogo de métodos.
2. Se integró al script `06_series_macro.R` el procesamiento de la TRM diaria
   descargada de SUAMECA.

Frente a los "Siguientes objetivos" del handoff: se cumplió el 1 (fijar la
pregunta) en lo que corresponde a la pregunta; queda abierto su diseño
(corte, tipo de documento, especificación de embeddings). Avanzó el 3 (la TRM
nominal ya está procesada). No se trabajó el 2 (validar la votación).

## Archivos

- Creados: `06_Bitacoras/2026-11-18_pregunta-y-trm.md`;
  `01_Datos/03_Listos/macro_trm.rds` (generado por el script).
- Modificados: `CLAUDE.md`, `README.md`, `HANDOFF.md`,
  `07_Recursos/catalogo_metodos.md`, `02_Scripts/06_series_macro.R`.
- Agregado a los datos crudos por el usuario (sin editar):
  `01_Datos/01_Crudos/TRM.csv`.
- Eliminados: ninguno.

## Detalle por archivo

### `CLAUDE.md`
- "Contexto": la pregunta, la historia macro, el método previsto y el alcance
  asociativo, no causal. Se quitó el "pendiente: definirla".
- "Decisiones tomadas": dos filas. La primera registra la pregunta y lo que
  falta definir (fecha de corte antes/después, tipo de documento, paquete y
  especificación de los embeddings, papel de LDA frente a los embeddings) y los
  riesgos: corpus pequeño (unas 177 mil palabras tras la limpieza) para
  entrenar embeddings y partirlo en dos épocas, cambios de formato de las
  minutas que pueden confundirse con cambio de temas, y relación asociativa. La
  segunda registra la TRM nominal y quedó marcada como resuelta.
- "Definición de variables": fila nueva `trm_cop_usd` con fuente, URL, fecha de
  consulta, cobertura y transformaciones.

### `07_Recursos/catalogo_metodos.md`
Los embeddings estaban en "Fuera del catálogo". Se agregaron a "Herramientas
previstas" como elegidos por el equipo y **sin registrar**: no se usan hasta
que se anoten en "Registro de ampliaciones" con paquete, funciones y
aprobación. Decisión de fondo: se respeta la regla de que ningún método fuera
del catálogo se usa sin registro previo.

### `02_Scripts/06_series_macro.R`
Se lee `TRM.csv` con `read_csv(skip = 1, col_names = c("fecha", "trm_cop_usd"))`
(el encabezado original es largo y trae un BOM), se convierten las fechas con
`ymd()` y se filtra desde 2000-01-01, igual que las demás series. Se guarda
`macro_trm.rds`. El auto-chequeo agrega: fechas únicas, sin `NA` y numérica.
Intuición: la TRM se trata como las otras series, solo se filtra; no se
transforma ni se alinea todavía.

### `README.md` y `HANDOFF.md`
README: sección "Pregunta de investigación", fila de `TRM.csv` en la tabla de
fuentes, cifras en el script 06 y nota sobre la fecha de la TRM. HANDOFF:
objetivos reescritos (ver abajo).

## Series nuevas

**TRM (`trm_cop_usd`).**
- Fuente: Banco de la República, SUAMECA,
  <https://suameca.banrep.gov.co/estadisticas-economicas/informacionSerie/1/tasa_cambio_peso_colombiano_trm_dolar_usd>,
  consultada el 2026-11-18.
- Qué es: pesos colombianos por dólar. Es la tasa de cambio nominal de la
  historia de la pregunta.
- Cobertura: diaria calendario, 1991-11-27 a 2026-11-19 en el archivo; 9.820
  días entre 2000-01-01 y 2026-11-19 tras el filtro (se descartan 2.957 días
  anteriores a 2000). Sin vacíos ni fechas repetidas. Fines de semana y
  festivos repiten el último valor.
- Rol: contexto macro de la pregunta; no es una medida de texto.
- Salvedad: el archivo llega a 2026-11-19, un día posterior a la consulta. La
  fecha es el día de vigencia; al alinear con las reuniones hay que confirmar
  desde qué fecha se conoce cada valor.

## Resultados nuevos (tablas, figuras, gráficos)

Ninguno. No se generaron tablas ni figuras, por lo que no hubo notas de
hallazgo que crear ni contrastar.

## Pendientes

- **Diseño de la pregunta** (objetivo 1): registrar los embeddings como
  ampliación del catálogo (paquete, función, aprobación del equipo); decidir
  la fecha de corte antes/después (candidato: el periodo P4, que abre el
  2014-09-26 y se fijó antes de ver medidas de texto), el tipo de documento y
  cómo comparar las dos épocas, antes de ver resultados.
- **`PLAN.md` y alineación** (objetivo 2): ahora es posible crearlo; falta la
  regla de alineación de las series con las reuniones y confirmar desde cuándo
  se conoce cada valor de la TRM.
- Validar a mano la votación (30 documentos): sigue pendiente; su relevancia
  para la nueva pregunta está por decidir.
- Bloqueos que siguen abiertos: roles, redacción de "festivos" del Brent
  (README y `CLAUDE.md`) y convención del pipe.
