# Después del choque, la Junta dedicó un tercio menos de su texto a la actividad económica y más al frente fiscal; el aumento del entorno externo y de la inflación es claro en los comunicados y débil en las minutas

- **Estado:** vigente (actividad y fiscal: robustos; entorno externo: robusto en comunicados y matizado en minutas; inflación: matizada)
- **Tipo / fuente:** T; comunicados y minutas (solo la discusión de la Junta); descriptivo
- **Script de origen:** `02_Scripts/09_antes_despues.R`
- **Última verificación:** 2026-11-21, con `02_Scripts/09_antes_despues.R`

## Evidencia

- Figura `03_Resultados/Figuras/09_antes_despues/conjunto_temas_antes_despues.png`.
- Tablas `03_Resultados/Tablas/09_antes_despues/conjunto_temas_antes_despues.png`
  (medias, diferencia, IC 95 % y lectura), `conjunto_temas_robustez.png` (cuatro
  escenarios) y `conjunto_fragmentos_temas.png`; cifras por reunión en
  `conjunto_temas_por_reunion.csv`.

Medida: palabras del diccionario `temas` (fijado a priori en
`00_funciones_texto.R`) por cada 1.000 palabras de cada reunión; media por
época y diferencia después − antes con IC 95 % de la prueba t de Welch, con la
reunión como unidad. Épocas: 2009-10-30 a 2014-10-29 y 2014-10-30 a
2019-10-29.

| Tema | Comunicados (54 → 53 reuniones) | Minutas (59 → 53 reuniones) | Lectura |
| --- | --- | --- | --- |
| Actividad económica | 24,3 → 17,8; −6,4 [−8,8; −4,1] | 23,3 → 15,5; −7,9 [−10,7; −5,0] | Robusta |
| Fiscal | 1,6 → 4,1; +2,5 [1,5; 3,4] | 1,7 → 2,6; +0,9 [0,0; 1,7] | Robusta |
| Entorno externo | 15,4 → 21,9; +6,5 [3,6; 9,4] | 12,7 → 14,7; +2,1 [−0,8; 4,9] | Robusta en comunicados; matizada en minutas |
| Inflación | 18,0 → 22,1; +4,1 [1,5; 6,7] | 18,7 → 19,4; +0,7 [−2,1; 3,5] | Matizada |
| Mercado laboral | 0,9 → 0,3; −0,7 [−1,1; −0,2] | 1,5 → 1,0; −0,5 [−1,1; 0,1] | Matizada |
| Riesgo e incertidumbre | 3,4 → 4,7; +1,2 [0,0; 2,5] | 4,5 → 4,9; +0,4 [−1,0; 1,8] | Robusta (signo), pequeña |

Robustez (`conjunto_temas_robustez.png`): con los cortes 2014-09-26 y
2014-12-19 todos los signos se mantienen. Lo que vuelve «matizados» a entorno
externo, inflación y mercado laboral es la **muestra completa 2007–2026**, cuyo
«después» incluye la pandemia y 2021–2026: entorno externo en minutas −1,7
[−3,7; 0,2], inflación en minutas −2,4 [−4,4; −0,4] y en comunicados −0,6
[−2,6; 1,5]. Ninguno cambia de signo entre minutas y comunicados, así que
ninguno se marca como artefacto del formato de las minutas.

## Ejemplos de los documentos

- Actividad, antes (comunicado del 2012-07-27): «Si bien el consumo y la
  inversión serán la principal fuente del crecimiento del PIB en 2012, estos
  componentes de la demanda interna crecerán menos que el año anterior…»
- Fiscal, después (comunicado del 2016-02-19): «…los recortes anunciados de
  gasto público y el firme compromiso del Gobierno Nacional de presentar una
  reforma tributaria estructural este año, contribuyen a reducir el déficit de
  cuenta corriente y las presiones inflacionarias.»
- Entorno externo, después (minuta del 2015-11-27): «…el inminente incremento
  de la tasa de interés de la Reserva Federal de los Estados Unidos tiende a
  fortalecer el dólar y a disminuir los precios del petróleo, resultando en una
  devaluación mayor del peso y en consecuentes presiones sobre las
  expectativas de inflación.»
- Inflación, después (comunicado del 2015-08-21): «El traslado de parte de la
  devaluación del peso a los precios al consumidor y la persistencia del
  fenómeno de El Niño pueden hacer más lenta la convergencia de la inflación a
  la meta…»

## Qué dice, en lenguaje intuitivo

Lo que se quiere conocer es a qué temas dedica la Junta su texto. La medida
cuenta, en cada reunión, cuántas de cada 1.000 palabras pertenecen a cada
tema, y compara el promedio de las reuniones de los cinco años anteriores con
el de los cinco posteriores al 30 de octubre de 2014. La caída de la actividad
económica es la más grande y clara: un tercio menos en minutas y una cuarta
parte menos en comunicados. El frente fiscal sube en ambos. El entorno externo
y la inflación suben en los comunicados (+42 % y +23 %), pero en las minutas el
aumento es pequeño y su intervalo incluye el cero.

## Por qué importa en el estudio

Es la medida de «prioridades» más directa de la pregunta. La lectura
económica: antes del choque la Junta discutía sobre todo el ritmo de la
demanda interna (la economía crecía y la tasa se normalizaba); después, el
espacio se lo llevan el choque externo, sus efectos sobre el peso y los
precios, y la respuesta fiscal del Gobierno. Que el entorno externo y la
inflación suban más en el comunicado que en la minuta sugiere que la Junta
usó el comunicado para explicar el choque al mercado: para la mesa, el
comunicado es donde se lee primero el cambio de prioridades.

## Límites e incertidumbre

- El diccionario es fijo y no ve sinónimos ni contexto: «déficit» está en
  Fiscal aunque después de 2014 casi siempre se refiere a la cuenta corriente
  (ver [T_cuenta_corriente_deficit_externo](T_cuenta_corriente_deficit_externo.md));
  parte del aumento fiscal es, en realidad, externo.
- Entorno externo e inflación dependen de la ventana: con toda la muestra el
  resultado cambia porque 2020–2026 trae otros episodios.
- Las minutas tienen la mitad de palabras después del corte por su cambio de
  formato; la medida está normalizada por extensión, pero la composición del
  texto (qué secciones quedan) también cambió.
- Diferencias de medias por reunión: asociativo, sin control de otros cambios
  simultáneos; el IC no corrige por dependencia entre reuniones consecutivas.

## Historial

- 2026-11-21: nota creada con la primera corrida de `09_antes_despues.R`.
  Consistente con
  [T_inflacion_sigue_episodios](../03_frecuencias_tfidf/T_inflacion_sigue_episodios.md):
  la atención a la inflación sube en 2015–2016.
- 2026-11-21: corregida la lectura de «Entorno externo» en la tabla: robusta en comunicados y matizada en minutas, como en `03_Resultados/Tablas/09_antes_despues/conjunto_temas_antes_despues.csv` (antes decía «Matizada» para toda la fila). Cifras sin cambios.
