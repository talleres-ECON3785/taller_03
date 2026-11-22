# Después del choque, pierden espacio los temas internos del ciclo anterior: la actividad económica, el crédito y la provisión de liquidez

- **Estado:** vigente
- **Tipo / fuente:** T; comunicados y minutas (solo la discusión de la Junta); descriptivo
- **Script de origen:** `02_Scripts/08_lda_oraciones.R`
- **Última verificación:** 2026-11-21, con `02_Scripts/08_lda_oraciones.R`

## Evidencia

- Figura `03_Resultados/Figuras/08_lda_oraciones/conjunto_lda_antes_despues.png`.
- Tablas `03_Resultados/Tablas/08_lda_oraciones/conjunto_lda_antes_despues.png`,
  `conjunto_lda_topicos.png` y `conjunto_lda_fragmentos.png`; escenarios en
  `conjunto_lda_antes_despues_detalle.csv`.
- LDA con K = 10 y α = 0,1, ventana 2009-10-30 a 2019-10-29; 54 comunicados
  antes y 53 después, 59 minutas antes y 53 después del 2014-10-30.
- Peso medio del tópico en la reunión (en %), antes → después, y diferencia en
  puntos porcentuales con su IC 95 %, todas con lectura «robusta»:

  | Tópico | Comunicados | Minutas |
  | --- | --- | --- |
  | 1. Actividad económica interna | 15,2 → 11,6; −3,6 [−6,7; −0,5] | 14,8 → 7,9; −6,9 [−10,1; −3,6] |
  | 2. Crédito y sistema financiero | 10,7 → 1,5; −9,2 [−10,9; −7,5] | 12,3 → 3,3; −9,0 [−10,6; −7,3] |
  | 7. Seguimiento y provisión de liquidez | 14,2 → 8,1; −6,1 [−8,4; −3,8] | 9,4 → 3,5; −5,9 [−7,8; −4,0] |

## Ejemplos de los documentos

- Tópico 1, comunicado 2013-04-26: «Por el lado de la demanda, el consumo de
  los hogares habría crecido a una tasa menor, como se desprende de la
  evolución de los indicadores de comercio al por menor, de confianza de los
  hogares y de crédito».
- Tópico 2, comunicado 2012-04-30: «El crecimiento del crédito a los hogares
  permanece alto, especialmente el de consumo, lo que indica que los hogares
  han elevado significativamente su grado de endeudamiento».
- Tópico 7, comunicado 2012-08-24 (y casi igual en 2012-06-29 y 2012-11-23):
  «La Junta reitera que el Banco de la República cuenta con las herramientas y
  recursos suficientes para atender las necesidades de liquidez…».

## Qué dice, en lenguaje intuitivo

Antes del choque, la Junta dedicaba buena parte de su texto a describir la
economía interna indicador por indicador (consumo, industria, construcción,
ventas), a vigilar el crédito y el endeudamiento de los hogares, y a reiterar
que el Banco tenía liquidez disponible. Después del choque, el crédito casi
desaparece de los comunicados (de 11 a menos de 2 de cada 100 palabras) y los
otros dos temas pierden entre un cuarto y dos tercios de su espacio. Ese
espacio lo ocupan el déficit externo, la inflación por depreciación y la
justificación de la postura (ver las otras notas de esta carpeta).

- **Objeto de interés:** qué temas internos pierden lugar en la conversación.
- **Medida:** la proporción de cada tópico en el texto de la reunión.
- **Estimación:** las diferencias de la tabla.

## Por qué importa en el estudio

Completa el cuadro de qué se dejó de discutir. El ciclo 2010–2013 estuvo
marcado por el auge del crédito y por la provisión de liquidez después de la
crisis de 2008. Después del choque, la agenda la fijó el sector externo. Para
la mesa, el crédito dejó de ser un argumento de la Junta para mover la tasa en
2015–2019.

**Contraste con `09_antes_despues/`:** **consistente** con
`T_atencion_temas_antes_despues.md`, donde la atención a «Actividad económica»
cae alrededor de un tercio, de forma robusta. Reunión a reunión, el tópico 1 y
el tema del diccionario se mueven juntos: correlación de 0,53 [0,38; 0,65] en
los comunicados y 0,53 [0,38; 0,65] en las minutas (ventana; 107 y 112
reuniones; `03_Resultados/Tablas/08_lda_oraciones/conjunto_lda_vs_diccionario.png`).

## Límites e incertidumbre

- El tópico 7 está dominado por una fórmula que la Junta repitió en 2012; su
  caída refleja en buena parte el abandono de esa frase, no un cambio de
  análisis.
- Los tres tópicos tienen entre el 77 % y el 86 % de su peso en las minutas del
  formato A, pero caen igual en los comunicados, que no cambian de formato.
- El segundo fragmento del tópico 2 en `conjunto_lda_fragmentos.png` (minuta
  2010-07-23) es una enumeración de la discusión y no ilustra el crédito: se
  usa el del comunicado 2012-04-30.
- Asociación, no causalidad: la caída del crédito también responde al fin del
  ciclo de crédito anterior al choque.

## Historial

- 2026-11-21: nota creada con la primera corrida de `08_lda_oraciones.R`.
- 2026-11-21: contraste por reunión con el diccionario de `09` (P3a.9): consistente (r = 0,53 en las dos fuentes). Cifras sin cambios.
