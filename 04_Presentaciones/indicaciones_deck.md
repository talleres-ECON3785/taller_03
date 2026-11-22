# Patrones de diseño a evitar

- Texto encima de los títulos
- Texto encima de las imagénes o sobrelapado con otros textos
- Títulos que siguen las siguientes estructuras
  - Un ":" en la mitad. Ej. *Reclaiming profitable growth: Strategic options for ACME Industrial*
  - Uso de "-" con negación. Ej. *Prices are rising - But not where you think*
  - *Its not this, its that.*
- Uso excesivo de *takeaway boxes* y que sus afirmaciones sean exageradas. Solo usar si llevan a la siguiente slide o si hay un hallazgo importante que no sea evidente del resto del contenido del slide (y que no sea el título porque ese es el hallazgo principal).
- Bordes con color en las cajas de una presentiación.
- Grupos de tres forzados para ir con la *rule of three*.
- Importancia inflada: no hay fórmula, solo se hacen demasiados juicios de que algo es muy importante sin necesidad
- Números muy grandes en todas las diapositivas, reservar para solo una o dos slides de impacto
- Subtítulos innecesarios que parecen más comentarios que realmente subtítulos, gastan espacio y atención de la audiencia, se prefiere un solo título claro que diga el mensaje directamente.
- Uso exagerado de imágenes - priorizar tablas y figuras.

# Figuras y tablas clave por tema

## Diagnóstico macro

- `macro_cronologia_choque.png`

## TF-IDF, Bigramas y Atención

- `conjunto_palabras_distintivas.png`
- `conjunto_temas_antes_despues.png`
- `conjunto_bigramas_cambio.png`

## LDA

- `conjunto_lda_theta_por_reunion_topicos_1_4.png`
- `conjunto_lda_theta_por_reunion_topicos_6_10.png`

# Orden de la presentación

1. Presentación de la pregunta de investigación
2. Resultados más importantes
   1. La junta pasó de hablar de inflación básica, actividad económica y la economía mundial a enfocarse en política fiscal, inflación por devaluación y el déficit externo.
   2. Las palabras más distintivas después de la crisis se centran en el déficit, la cuenta corriente, la devaluación y el sector externo colombiano (balanza de pagos); en cambio previo a la crisis se hablaba de vivienda, otras economías (europa), empleo y el sector financiero.
   3. La decisión y postura frente a la política monetaria es el tema con mayor cambio en su relevancia después de la crisis (en minutas), denotando una junta que justifica más sus decisiones tras el choque petrolero.
3. Contexto y diagnóstico macro - con la gráfica está bien, el choque lo explicamos durante la presentación
4. Palabras distintivas
5. Bigramas
6. Atención y temas
7. LDA temas 1 - 4
8. LDA temas 6 - 10
9. Word2Vec
10. Word2Vec
11. Robustez
    1. Cambio de formato
    2. Se presentaron los temas que persisten en tres semillas, 2 no fueron estables
    3. Para LDA y se probaron múltiples hiperparámetros y se escogieron los modelos que dieran mejor combinación de predicción (perplejidad) y legibilidad de los temas (coherencia).
    4. Los hallazgos son robustos a la ventana de tiempo evaluada y al punto de corte de la crisis
       1. Puntos de corte alternativos de 2014-09-26 y 2014-12-19
       2. Ventana alternativa usando corpus completo de 2007 a 2026.
