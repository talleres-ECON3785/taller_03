---
name: registrar-hallazgo
description: Crea o actualiza una nota de hallazgo en 05_Notas/ (un .md por hallazgo principal, con referencia a tablas/figuras, ejemplos de los documentos de la Junta, explicación intuitiva e importancia en el estudio) y contrasta la evidencia nueva con las notas existentes, alertando de inmediato si algo es contradictorio. Usar cuando se genere o cambie un resultado (tabla, figura, medida de texto, estimación), cuando el usuario pida "registrar un hallazgo", "escribir la nota", "actualizar las notas" o "contrastar con lo anterior", y antes de dar por cerrado un análisis.
---

# Registrar hallazgo y contrastar evidencia

Mantiene `05_Notas/` como memoria analítica del taller. Las reglas de fondo
están en la sección "Notas de hallazgos" de `CLAUDE.md`; esta skill es el
procedimiento. Se invoca cuando se genera o cambia un resultado, no solo al
cerrar la sesión.

Básate solo en resultados que existan en `03_Resultados/`, en los documentos de
`01_Datos/01_Crudos/` y en lo ocurrido en la conversación. Si algo no es
inferible con certeza (la unidad o el periodo de una cifra, si dos medidas son
comparables, qué tipo de documento se usó), pregunta al usuario en vez de
adivinar.

## Paso 1: identificar el hallazgo y su evidencia

1. Identifica el resultado nuevo o modificado: qué tablas/figuras de
   `03_Resultados/` lo contienen y qué script de `02_Scripts/` las genera.
   Confirma que los archivos existen (`ls`); una cifra sin archivo de respaldo
   no entra a una nota.
2. Lee `05_Notas/README.md` (si existe) y busca si ya hay una nota sobre el
   mismo hallazgo. Si existe, se actualiza; si no, se crea.
3. Un hallazgo es un resultado que sostiene, matiza o contradice una conclusión
   del taller. Un resultado intermedio sin implicación para la pregunta del
   taller no necesita nota (queda en la bitácora).
4. Busca uno o más **fragmentos de los documentos** que ilustren qué captura la
   medida (con fecha y tipo de documento). Sin ejemplos textuales, la nota queda
   incompleta y se dice en el reporte.

## Paso 2: contrastar antes de escribir

Antes de crear o modificar la nota, contrasta el resultado nuevo con:

- las notas relacionadas de `05_Notas/` (las del mismo tipo y las
  transversales `X_`);
- las decisiones registradas en "Decisiones tomadas" de `CLAUDE.md`;
- los hechos conocidos de la política monetaria del periodo (p. ej. ciclos de
  la tasa de intervención, choques evidentes): una medida que no reacciona en
  episodios obvios es una señal de alerta.

Compara dirección, orden de magnitud, **fuente** (comunicados vs. minutas vs.
serie macro), periodo, frecuencia y regla de alineación temporal, y decisiones
de preprocesamiento (diccionario, stopwords, número de tópicos, semilla).

Clasifica el resultado:

| Clasificación | Qué significa | Qué se hace |
| --- | --- | --- |
| **Consistente** | Coincide con lo registrado. | Actualizar "Última verificación" e historial. |
| **Cambia (atribuible)** | Difiere de lo registrado y la diferencia se explica por un cambio deliberado y documentado (otra fuente, otro periodo, otra especificación). | Registrarlo en la nota con la atribución. No es una alerta. |
| **Contradictorio** | Choca con una nota previa sin explicación atribuible. | Alertar (Paso 3). |

Si no puedes distinguir entre "cambia (atribuible)" y "contradictorio", trátalo
como contradictorio y alerta.

## Paso 3: alertar si hay contradicción

Detén el registro y avisa al usuario **en ese momento**, sin esperar al cierre
de la sesión y sin resolverlo en silencio. La alerta lleva:

1. **Qué se contradice:** ruta de la nota o fuente previa y del resultado nuevo.
2. **Las cifras de ambos lados**, cada una con unidad, fuente, periodo y `n` de
   documentos.
3. **Hipótesis de la causa**, distinguiendo: extracción de texto,
   preprocesamiento, diccionario, semilla o número de tópicos, frecuencia o
   alineación temporal, datos distintos o error de código.
4. **Qué verificar** para resolverlo (un chequeo concreto, con el script o la
   tabla donde mirar).

Mientras el usuario no decida:

- **No sobrescribas** la nota anterior ni cambies su estado.
- Deja la evidencia nueva en el "Historial" de la nota o en una nota propia
  marcada como pendiente de conciliar, y dilo en el reporte.
- Con la decisión del usuario: marca la nota previa como `matizado` o
  `reemplazado` (con enlace a la nota que la sustituye) y, si cambió una
  conclusión, regístralo en "Decisiones tomadas" de `CLAUDE.md`.

## Paso 4: escribir o actualizar la nota

Nombre: `05_Notas/<script>/<tipo>_<slug>.md`, en la subcarpeta del script del
que se deriva el hallazgo, con `<tipo>` = `T` (texto), `M` (macro) o `X`
(relación texto–macro), slug en minúsculas con guion bajo (p. ej.
`T_atencion_inflacion.md`). Una nota por hallazgo, no por sesión. La nota solo
habla de lo que se sabe con los resultados de su script; si otro script lo
matiza, se registra en la subcarpeta de ese script.

Estructura:

```markdown
# <Hallazgo, enunciado como conclusión>

- **Estado:** vigente | matizado | reemplazado (con enlace a la nota que lo reemplaza)
- **Tipo / fuente:** T, M o X; comunicados, minutas, serie macro o combinación; descriptivo, predictivo o asociativo
- **Script de origen:** `02_Scripts/<script>.R`
- **Última verificación:** YYYY-MM-DD, con el script que lo genera

## Evidencia
Rutas exactas de las tablas/figuras en `03_Resultados/` y el script de
`02_Scripts/` que las produce. Cifras clave con unidad, periodo y `n` de
documentos.

## Ejemplos de los documentos
Fragmentos textuales (con fecha y tipo de documento) que muestren qué captura
la medida.

## Qué dice, en lenguaje intuitivo
Qué muestra la figura o tabla, cómo leerla y qué significa para la mesa de
renta fija, para alguien sin formación técnica. Distingue objeto de interés,
medida y estimación.

## Por qué importa en el estudio
Qué parte de la pregunta del taller responde, la interpretación económica del
patrón y qué implica para el seguimiento que hace la mesa del Banco de la
República.

## Límites e incertidumbre
Qué no permite afirmar (asociación no es causalidad; sensibilidad a decisiones
de preprocesamiento; cambios de formato de los documentos), y qué evidencia
adicional haría falta.

## Historial
- YYYY-MM-DD: qué cambió y por qué.
```

Reglas de redacción (de `CLAUDE.md`):

- Sin juicios de "bueno" o "malo" sobre resultados y sin entusiasmo por
  coeficientes, métricas o significancia. Reporta magnitud e incertidumbre.
- Sin código. Sin nombres de variables del código en la explicación intuitiva.
- Una relación entre texto y macro es asociativa salvo que un diseño explícito
  sostenga lo contrario. El nombre de un tópico es una interpretación: se
  justifica con sus palabras más representativas y con ejemplos.
- Antes de cerrar la nota, repasa las heurísticas pertinentes de
  `07_Recursos/heuristicas_retroalimentacion_taller1.md`.

## Paso 5: actualizar el índice

Actualiza `05_Notas/README.md` (créalo con la primera nota): una fila por nota
con su archivo, estado, tipo/fuente y la pregunta que responde. Si cambió el
estado de una nota, actualiza también su fila. No edites las filas de otras
notas.

## Cierre

Termina con un reporte corto: notas creadas o actualizadas (rutas), la
clasificación de cada contraste (consistente, cambia, contradictorio) y, si hubo
alertas, qué quedó pendiente de decisión del usuario. Esta skill no hace commit:
los cambios se versionan con `cerrar-sesion` al cerrar la sesión (en la rama
del integrante, nunca en `main`).
