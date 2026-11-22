# Notas de hallazgos

Índice de las notas de `05_Notas/`: una línea por nota, con su estado y la
pregunta que responde. Las notas se agrupan por el script del que se derivan.
Las reglas están en `CLAUDE.md` ("Notas de hallazgos").

| Nota | Estado | Pregunta que responde |
| --- | --- | --- |
| [01_extraer_texto/T_estructura_minuta.md](01_extraer_texto/T_estructura_minuta.md) | vigente | ¿Qué parte de cada minuta es discusión de la Junta y cuándo cambia el formato? |
| [03_frecuencias_tfidf/T_inflacion_sigue_episodios.md](03_frecuencias_tfidf/T_inflacion_sigue_episodios.md) | vigente | ¿Las medidas de texto se mueven en los episodios conocidos de inflación? (validación de las medidas) |
| [04_bigramas/T_votacion_minuta_vs_comunicado.md](04_bigramas/T_votacion_minuta_vs_comunicado.md) | vigente, pendiente de validación manual | ¿Qué dice la minuta sobre la votación que el comunicado no dice, y hacia dónde vota la minoría? |
| [07_graficas_macro/M_cronologia_choque_petrolero.md](07_graficas_macro/M_cronologia_choque_petrolero.md) | vigente | ¿Cómo y en qué orden llegó el choque petrolero de 2014 a la tasa de cambio, la inflación y la tasa de intervención, y dónde está el corte antes/después? |
| [09_antes_despues/T_cuenta_corriente_deficit_externo.md](09_antes_despues/T_cuenta_corriente_deficit_externo.md) | vigente | ¿Qué tema nuevo entra al vocabulario de la Junta después del choque? (cuenta corriente y déficit externo) |
| [09_antes_despues/T_devaluacion_tema_de_inflacion.md](09_antes_despues/T_devaluacion_tema_de_inflacion.md) | vigente | ¿Cambió la forma en que la Junta habla de la inflación? (devaluación, traslado, indexación, persistencia) |
| [09_antes_despues/T_atencion_temas_antes_despues.md](09_antes_despues/T_atencion_temas_antes_despues.md) | vigente (dos temas matizados) | ¿Cuánto cambió la atención a cada tema antes y después del corte, en comunicados y minutas? |
| [09_antes_despues/X_atencion_se_adelanta_a_las_series.md](09_antes_despues/X_atencion_se_adelanta_a_las_series.md) | matizado | ¿La atención al entorno externo y a la inflación se mueve antes, a la vez o después del Brent, la TRM y la inflación? |
| [08_lda_oraciones/T_choque_externo_llega_a_colombia.md](08_lda_oraciones/T_choque_externo_llega_a_colombia.md) | vigente | ¿Cómo cambia la forma en que la Junta habla del exterior? (de la economía mundial al déficit externo y la capacidad productiva; LDA) |
| [08_lda_oraciones/T_inflacion_de_meta_a_choques.md](08_lda_oraciones/T_inflacion_de_meta_a_choques.md) | vigente (choques: matizado en minutas) | ¿Cambia la forma en que la Junta discute la inflación? (de la inflación básica frente a la meta a la depreciación y los alimentos; LDA) |
| [08_lda_oraciones/T_decision_postura_sube.md](08_lda_oraciones/T_decision_postura_sube.md) | matizado | ¿Dedica la Junta más espacio a justificar su decisión de tasa después del choque? (LDA) |
| [08_lda_oraciones/T_actividad_credito_liquidez_bajan.md](08_lda_oraciones/T_actividad_credito_liquidez_bajan.md) | vigente | ¿Qué temas internos pierden espacio después del choque? (actividad, crédito y liquidez; LDA) |
| [10_glove/T_contexto_inflacion_expectativas.md](10_glove/T_contexto_inflacion_expectativas.md) | matizado (sensible al método: GloVe frente a Word2Vec) | ¿Cambió el contexto en que la Junta usa «inflación» y «expectativas de inflación»? (vecinos en un modelo GloVe, antes y después del corte) |

Resultados exploratorios sin nota (quedan en la bitácora del 2026-11-12):
vocabulario propio de la minuta frente al comunicado, vocabulario laboral y
fiscal desde 2021, cambio del nombre de la tasa en 2020 y los tópicos del LDA.
