# HANDOFF

Resumen accionable del Taller 3 para retomar el trabajo. El detalle de cada
sesión está en `06_Bitacoras/`; aquí solo va lo necesario para saber dónde
estamos y qué sigue. Las reglas para mantener este archivo están en
`CLAUDE.md` (sección "`HANDOFF.md`").

**Fecha de entrega (video de máximo 15 minutos, slides y material de soporte):
domingo 22 de noviembre de 2026.**

## Siguientes objetivos

<!-- Dos a tres tareas concretas, en orden de prioridad, cada una con el
     archivo que debe producirse, un criterio de terminado verificable y, si
     aplica, el integrante a cargo. Cuando exista el plan de implementación,
     cada objetivo cita el paso del plan del que sale. Se reescribe al cerrar
     cada sesión. -->

1. **Definir la pregunta del taller y las series macro.**
   - Archivo: fila nueva en "Decisiones tomadas" de `CLAUDE.md` con la
     pregunta, y tabla "Definición de variables" con cada serie (por qué,
     fuente, cobertura, frecuencia, transformaciones).
   - *Terminado cuando:* la pregunta es una sola oración que la mesa de renta
     fija entendería, y cada serie tiene fuente con URL.
2. **`PLAN.md` y ampliaciones del catálogo.** El catálogo
   (`07_Recursos/catalogo_metodos.md`, Labs 11 y 12) ya existe.
   - Archivos: `PLAN.md` con hitos y tareas `Pk.n`; filas en el "Registro de
     ampliaciones" del catálogo al menos para `pdftools` y la lectura de las
     series macro.
   - *Terminado cuando:* cada análisis previsto en el plan usa una herramienta
     del catálogo o una ampliación registrada.
3. **Base del pipeline: `00_main.R`, formato y extracción de texto.**
   - Archivos: `00_main.R`; `02_Scripts/00_formato_graficas.R` y
     `00_formato_tablas.R` (traídos del Taller 2 y adaptados);
     `02_Scripts/01_extraer_texto.R` (texto de los 194 comunicados y las 199
     minutas a `02_Procesados/`, con fecha y tipo de documento tomados del
     nombre).
   - *Terminado cuando:* `00_main.R` corre desde cero, reporta cuántos PDF no
     tienen texto extraíble y la base tiene 393 documentos (sin el informe
     técnico del 2020-04-30).

**Bloqueos y preguntas abiertas:**

- Roles de los integrantes en el Taller 3.
- Fecha de la retroalimentación a compañeros (no afecta el repositorio).
- Las minutas cambian mucho de extensión y formato (de 11–23 mil caracteres en
  2007–2013 a unos 3 mil en 2019–2020); falta ubicar los cortes exactos antes
  de leer tendencias.
- Si la pregunta depende de cuándo llega la minuta al mercado, hay que
  conseguir las fechas de publicación por fuera: los documentos no las traen.

## Estado actual

- **Estructura:** carpetas numeradas como en el Taller 2 (`01_Datos` a
  `09_Conversaciones`), `taller_03.Rproj`, `.gitignore`, `CLAUDE.md` y las
  skills `bitacora-sesion`, `cerrar-sesion` y `registrar-hallazgo`.
- **Datos:** los 394 PDF de la Junta en
  `01_Datos/01_Crudos/Comunicados_Minutas_Banrep/` (194 comunicados,
  2007-01-26 a 2026-09-30; 199 minutas, 2007-06-15 a 2026-09-30). El informe
  técnico que el zip traía como minuta del 2020-04-30 está aparte, en la misma
  carpeta, como `2020-04-30_informe_tecnico_mercados_capitales.pdf`.
  El nombre de cada archivo es la fecha de la reunión. Aún no hay series macro.
- **Recursos:** `07_Recursos/Problem_Set_3.pdf` y
  `07_Recursos/heuristicas_retroalimentacion_taller1.md` (copiada del Taller 2)
  y `07_Recursos/catalogo_metodos.md` (métodos de los Labs 11 y 12).
- **Scripts y resultados:** ninguno todavía.
- **Git:** primer commit en la rama `SantiagoMunozM`; `main` sigue sin
  commits. Remoto `https://github.com/talleres-ECON3785/taller_03.git`.

## Registro de sesiones

### 2026-11-08: configuración inicial, catálogo de métodos y verificación de los documentos

- Santiago Muñoz Martínez (`SantiagoMunozM`). Se replicó la estructura del
  Taller 2, se descomprimieron los documentos en
  `01_Datos/01_Crudos/Comunicados_Minutas_Banrep/` y se escribieron
  `CLAUDE.md`, las tres skills y este handoff. Se armó el catálogo de métodos
  de los Labs 11 y 12, se registró la entrega (22 de noviembre, video de 15
  minutos) y se verificó que el nombre de cada archivo es la fecha de la
  reunión. El informe técnico que venía como minuta del 2020-04-30 se sacó de
  `minutas/` y se renombró.
- Bitácora: [2026-11-08_configuracion-inicial.md](06_Bitacoras/2026-11-08_configuracion-inicial.md)
- **Siguientes objetivos:** (1) definir la pregunta y las series macro;
  (2) `PLAN.md` y ampliaciones del catálogo; (3) `00_main.R`, formato y
  extracción de texto.
