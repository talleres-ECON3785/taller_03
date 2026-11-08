# Heurísticas a partir de la retroalimentación del Taller 1

Fuente: rúbricas y comentarios del profesor en
`Comentarios para Vídeo_ Taller 1 - ...pdf` y
`Comentarios para Material de soporte_ Taller 1 - ...pdf` (esta misma carpeta).
Este documento convierte las correcciones de **método y de argumentación** en
principios accionables para el Taller 2. Las correcciones sobre **código,
carpetas, tablas y figuras** están en `CLAUDE.md` (sección "Reproducibilidad y
salidas").

## Calificaciones del Taller 1 (para ubicar dónde se perdieron puntos)

| Criterio (video)                         | Puntaje   | Qué faltó                                                                 |
| ---------------------------------------- | --------- | ------------------------------------------------------------------------- |
| Parte A. Análisis exploratorio           | 12.6 / 18 | Descriptiva covariable–resultado; estimando no declarado                  |
| Parte A. Análisis predictivo             | 9 / 18    | Especificación sin justificar; importancia de variables; RMSE sin interpretar |
| Parte A. Recomendaciones                 | 9 / 9     | —                                                                         |
| Parte B. Validación del experimento      | 12.6 / 18 | No se verificó el cumplimiento de la asignación                           |
| Parte B. Análisis causal                 | 14.4 / 18 | Estimando ambiguo; no se concilió nivel vs. logaritmo                     |
| Parte B. Recomendaciones                 | 6.3 / 9   | Recomendación inconsistente con la evidencia ("todavía no")               |
| Presentación                             | 10 / 10   | —                                                                         |
| **Total video**                          | **73.9 / 100** |                                                                      |
| **Material de soporte (repositorio)**    | **100 / 100** | Sin penalización, pero con mejoras pedidas para el Taller 2 (ver `CLAUDE.md`) |

Lo que se perdió está en el **razonamiento**: el porqué de cada decisión, qué
número responde la pregunta y si la recomendación se sigue de la evidencia. La
forma (presentación y repositorio) obtuvo el puntaje completo.

---

## H1. Primero el estimando; todo lo demás es complemento etiquetado

**Corrección:** "Estimaron *unos efectos*, no *el* efecto." Se alternó entre
diferencias en dólares y en porcentaje sin decir cuál respondía la pregunta.
"¿Cuál es el parámetro causal de interés para ustedes?"

**Principio:** una pregunta de negocio tiene **un** parámetro de interés. Se
declara antes de estimar, se justifica con la decisión que informa y se
mantiene a lo largo de toda la presentación. Cualquier otra cifra se presenta
explícitamente como complemento ("robustez", "mecanismo", "contexto").

**Cómo aplicarlo en el Taller 2:**
- Escribir en una diapositiva temprana (y en la bitácora) el estimando de cada
  parte, en palabras y en escala:
  - Parte A: el objetivo es predecir `ln(Revenue)`; no hay parámetro causal.
  - Parte B: ATE y CATE(x) de `easier_signup` sobre `ln(Revenue)` (cambio
    proporcional aproximado del gasto). El ITT en dólares del Taller 1 es la
    referencia de comparación, no el estimando.
- Cada número en una diapositiva debe poder etiquetarse con la escala (dólares
  vs. log/porcentaje) y el rol (estimando principal vs. complemento).
- Preguntarse: "si la mesa directiva solo recordara un número, ¿cuál es y qué
  decisión cambia?".

## H2. Si dos especificaciones se contradicen, reconcilie antes de concluir

**Corrección:** "¿Cómo concilian el hecho de que la estimación lin-lin afirme
que el efecto en términos nominales es estadísticamente significativo y la
especificación log-lin asevere lo contrario? En su exposición no lo argumentan
adecuadamente."

**Principio:** dos estimaciones que discrepan responden preguntas distintas. La
discrepancia es un hallazgo y hay que explicar su mecanismo, no esconderla ni
elegir la que convenga.

**Cómo aplicarlo en el Taller 2** (es la pregunta central del taller):
- El efecto en nivel es una diferencia de **medias aritméticas** y es sensible a
  la cola alta. El efecto en log es una diferencia de **medias de logaritmos**
  (≈ cambio proporcional de la media geométrica, el usuario "típico"). En el
  Taller 1 las medianas eran casi idénticas y la diferencia estaba en el p99, lo
  que es consistente con: "el tratamiento no mueve al usuario típico, pero sí a
  unos pocos usuarios de gasto muy alto".
- Usar la Parte B para **probar** esa explicación: ¿los CATE identifican un
  subgrupo con efecto grande? ¿El efecto en nivel desaparece si se excluye la
  cola? ¿Qué muestran los cuantiles de cada grupo?
- En la presentación: una diapositiva que diga explícitamente por qué los dos
  números no se contradicen y cuál guía la decisión (H1).
- Distinguir siempre si una diferencia con el Taller 1 viene de la
  transformación, del método o de ambos (regla de `CLAUDE.md`).

## H3. La estadística descriptiva sirve para generar hipótesis sobre el resultado

**Corrección:** la descriptiva se limitó a la diferencia de medias entre
registrados y no registrados y a la cola pesada. "El uso adecuado es ver cómo
están relacionadas las covariables con la variable resultado, pues eso es lo que
nos permite conjeturar hipótesis." La relación gasto–tiempo quedó relegada al
final como hallazgo adicional.

**Principio:** antes de modelar, mostrar cómo varía el resultado con **cada**
covariable. Esas relaciones son las hipótesis que el modelo debe confirmar o
matizar.

**Cómo aplicarlo en el Taller 2:**
- Al inicio del análisis, describir `ln(Revenue)` según `time_spent`,
  `past_sessions`, `device_type`, `os_type`, `is_returning_user` y `sign_up`:
  ¿crece el gasto con el tiempo en sesión?, ¿con las sesiones previas, o cae?,
  ¿cambia por dispositivo o sistema operativo?, ¿hay interacciones visibles
  (p. ej. la pendiente del tiempo difiere por dispositivo)?
- Estas preguntas deben quedar respondidas en la presentación antes de los
  modelos, y conectadas con lo que se espera que encuentren los árboles
  (quiebre en 5 minutos, interacciones, posibles moderadores de HTE).
- En el experimento, la misma lógica por brazo sugiere moderadores candidatos
  para la Parte B (descriptivo, no prueba de HTE).

## H4. Toda especificación se justifica desde la descriptiva y el conocimiento del negocio

**Corrección:** "No veo la especificación del modelo en ninguna diapositiva,
pero pareciera que adicionaron cada variable de forma lineal solamente. ¿Por
qué?" Faltó explorar formas no lineales e interacciones sugeridas por la
descriptiva.

**Principio:** cada elección de forma funcional, variable o hiperparámetro
responde a "¿por qué esto tiene sentido para predecir el gasto?". La
especificación se muestra en la presentación (ecuación o diagrama, sin código).

**Cómo aplicarlo en el Taller 2:**
- Mostrar la especificación del benchmark lineal y justificar cada término. Si
  la descriptiva sugiere no linealidades (quiebre en 5 min, log del tiempo),
  decidir y registrar si el benchmark las incluye: un benchmark solo lineal
  infla la ventaja aparente de los árboles.
- Para los árboles, explicar qué se espera que capturen (no linealidades,
  interacciones) y cómo se eligieron los hiperparámetros (validación cruzada en
  entrenamiento).
- Justificar `ln(Revenue)` con la distribución (asimetría, cola alta) y con la
  pregunta de negocio (efectos proporcionales), no solo porque lo exige el enunciado.

## H5. La importancia de una variable se mide por cuánto mejora la predicción fuera de muestra

**Corrección:** "Lo ideal hubiese sido añadir variables de forma secuencial y
observar la disminución sobre el RMSE como indicador de la importancia de cada
variable." Se pasó directo de la media incondicional al modelo con todo.

**Principio:** mostrar la escalera de modelos, de la media incondicional al
modelo completo, con el RMSE fuera de muestra en cada paso. La caída en RMSE
atribuible a cada variable es la evidencia de su aporte predictivo.

**Cómo aplicarlo en el Taller 2:**
- Construir la tabla o figura escalonada (naive → + `time_spent` → +
  `past_sessions` → … → completo) para el lineal y, cuando se pueda, para el
  árbol o bosque. El orden debe estar justificado (p. ej. por la descriptiva) y
  hay que advertir que el aporte marginal depende del orden.
- Complementar con la importancia de variables propia de los árboles
  (impureza o permutación), presentada como **uso del modelo**, no como efecto
  causal.
- Responder explícitamente "¿qué variables son más útiles para predecir?" con
  esta evidencia.

## H6. El error fuera de muestra se interpreta en las unidades del negocio

**Corrección:** "Mencionaron que el modelo tenía un error 15% menor a la media
incondicional, pero, si no fuese en términos relativos sino en valores
nominales, ¿cómo podría haberse interpretado dicho valor?"

**Principio:** todo RMSE se traduce a una frase que entienda la mesa directiva:
"en promedio, la predicción del gasto de un usuario se desvía en ≈ X dólares
(frente a un gasto medio de Y)". La mejora relativa frente a la referencia
ingenua es un complemento.

**Cómo aplicarlo en el Taller 2:**
- RMSE en `ln(Revenue)`: interpretarlo como un error proporcional aproximado
  (un RMSE de 0.3 en log equivale a desviaciones típicas de ~30–35% del gasto) y
  aclarar la aproximación.
- Para comparar con el RMSE en dólares del Taller 1, hay que llevar las
  predicciones a la misma escala (retransformación de `ln` a nivel con
  corrección por sesgo, p. ej. *smearing* de Duan) o reportar cada RMSE solo en
  su escala. La elección se registra en "Decisiones tomadas".
- Siempre acompañar con el RMSE de la referencia ingenua en la misma escala y
  con el gasto medio, para dar orden de magnitud.

## H7. Validar el experimento es verificar balance y también cumplimiento

**Corrección:** "Garantizaron el balance en las covariables, pero no
verificaron el cumplimiento perfecto en la asignación. Si este supuesto no se
satisface, las personas estarían autoseleccionándose." Además: "no es necesario
que la proporción de tratamiento y control sea 50/50 [...] Lo que importa es que
los grupos estén balanceados en sus covariables y que el cumplimiento en la
asignación haya sido perfecto."

**Principio:** un experimento es válido si (1) la asignación produjo grupos
comparables (balance) y (2) la asignación determinó el tratamiento recibido
(cumplimiento). Las dos cosas se muestran. Un reparto desigual entre brazos no
es un problema de validez: solo afecta la precisión.

**Cómo aplicarlo en el Taller 2:**
- Mostrar la tabla cruzada `easier_signup` × `sign_up` (en el Taller 1 la
  correspondencia fue perfecta: primer estadio = 1) y decir qué implica: no hay
  autoselección y ITT = LATE.
- Mantener la tabla de balance. Para los árboles causales, la probabilidad de
  tratamiento es conocida por diseño; si el paquete lo permite, usarla en vez de
  estimarla, y registrar la decisión.
- No describir un reparto distinto de 50/50 como amenaza a la validez.

## H8. Interpretar cada estimación estadística y económicamente

**Corrección (rúbrica B.3 y A.3):** se pide interpretar "estadística y
económicamente" los coeficientes.

**Principio:** cada estimación clave se reporta con tres cosas: magnitud en
unidades del negocio, incertidumbre (IC) y relevancia económica (comparada con
la línea base o con el costo de la intervención). "No significativo" no basta.
Hay que decir si el intervalo descarta efectos económicamente relevantes.

**Cómo aplicarlo en el Taller 2:**
- ATE en log: "≈ X% de cambio en el gasto, IC [a, b]" y su traducción
  aproximada a dólares sobre el gasto medio.
- Cada CATE o grupo: estimación + intervalo + tamaño del grupo. Un grupo con
  efecto grande e intervalo ancho no es evidencia suficiente para focalizar
  (multiplicidad, sobreajuste: ver `CLAUDE.md`).

## H9. Discutir generalización y supuestos de atribución

**Rúbrica B.4:** "Se discute sobre la generalización de los resultados y sobre
los supuestos necesarios para atribuir la decisión del registro al cambio en el
diseño de la página."

**Principio:** decir explícitamente a quién aplica el resultado (validez
externa) y bajo qué supuestos el efecto se atribuye a la intervención
(aleatorización, cumplimiento, no interferencia entre usuarios, mismo periodo).

**Cómo aplicarlo en el Taller 2:**
- Reusar la prueba de representatividad del Taller 1 (experimento vs.
  histórico, F = 0.65, p = 0.712) para defender la extrapolación del ATE.
- Para los CATE: un subgrupo con efecto distinto solo generaliza si ese
  subgrupo existe en proporción similar en la población de CheMarket. Comparar
  su tamaño en ambas bases.

## H10. La recomendación debe seguirse de la evidencia, sin aplazamientos vacíos

**Corrección:** "¿Por qué dicen que no se debe escalar el registro *todavía*?
Si no encontraron efectos positivos estadística y económicamente, pueden
afirmar directamente que no se escale. No es claro qué datos o evidencia
adicional necesitan para tomar una decisión de sí o no, pues sus otros pasos a
seguir buscan evaluar ya no el registro, sino otras variables."

**Principio:** la recomendación es sí o no a la decisión planteada, con el grado
de confianza explícito. Solo se pide más evidencia si se puede decir **qué
evidencia, sobre la misma decisión, y qué resultado la cambiaría**. Los
próximos pasos sobre otras palancas son una sección aparte, no una condición de
la recomendación.

**Cómo aplicarlo en el Taller 2:**
- Formular la recomendación en una frase: "Escalar / no escalar el registro
  facilitado [para todos | solo para el grupo G]", seguida de la evidencia que la
  sostiene.
- Si se recomienda focalizar en un subgrupo, la evidencia de HTE debe ser formal
  (muestras separadas o calibración) y el beneficio debe ser económicamente
  relevante. Si no lo es, decir que la heterogeneidad no cambia la decisión.
- Si se pide un nuevo experimento, especificar: población, brazo, métrica,
  tamaño del efecto que cambiaría la decisión.
- Separar las secciones "Decisión respaldada" y "Preguntas abiertas".

## H11. Mantener lo que funcionó (puntaje completo)

- **Presentación (10/10):** recomendación como primer mensaje, títulos que
  dicen la conclusión, argumentos MECE, honestidad sobre la incertidumbre,
  figuras y tablas autocontenidas (no pantallazos de software), todos los
  integrantes exponen por igual y el video dura **máximo 15 minutos**.
- **Recomendación Parte A (9/9):** argumentar el sesgo por variable omitida
  (intención de compra, nivel de ingresos difieren entre registrados y no
  registrados) y por qué hace falta evidencia causal. En el Taller 2 el
  equivalente es: patrones de los árboles en la base observacional son
  predictivos, no causales.
- **Repositorio (100/100):** README con objetivo, estructura, ejecución y mapa
  script → resultado; nombres informativos; registro de la conversación en
  `.json`.

---

## Lista de chequeo rápida (antes de cerrar un análisis o una diapositiva)

1. ¿Está declarado el estimando y en qué escala está cada número? (H1)
2. Si hay dos resultados que parecen contradecirse, ¿está explicada la razón? (H2)
3. ¿La descriptiva muestra la relación de cada covariable con el resultado? (H3)
4. ¿Cada elección de especificación o hiperparámetro tiene un porqué? (H4)
5. ¿La importancia de variables se apoya en caídas de RMSE fuera de muestra? (H5)
6. ¿El RMSE está traducido a unidades del negocio? (H6)
7. ¿Se mostraron balance **y** cumplimiento del experimento? (H7)
8. ¿Cada estimación tiene magnitud, IC y lectura económica? (H8)
9. ¿Se discuten generalización y supuestos de atribución? (H9)
10. ¿La recomendación es un sí/no coherente con la evidencia, y cada "falta
    evidencia" dice cuál y qué la cambiaría? (H10)
