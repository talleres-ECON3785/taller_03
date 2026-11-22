# -*- coding: utf-8 -*-
"""
Construye 04_Presentaciones/borrador_presentacion.pptx a partir de la
plantilla del equipo (04_Presentaciones/plantilla_presentacion.pptx).

- Portada: la diapositiva 1 de la plantilla, con sus textos reemplazados.
- Resto: diapositivas nuevas sobre el diseño en blanco de la plantilla, con
  sus colores (fondo F2F2F2 y 1A1A1A, texto 1A1A1A) y fuentes (Codec Pro en
  títulos, Montserrat en el texto).
- Las figuras y tablas se insertan tal como las exporta el pipeline de R
  (03_Resultados/), escaladas sin deformarse.
- El guion va en las notas del orador.

Uso, desde la raíz del proyecto:  python 04_Presentaciones/construir_borrador.py
Contenido: 04_Presentaciones/hallazgos_y_figuras.txt. No es parte de 00_main.R:
es un borrador de la presentación, no un resultado del análisis.
"""
from pathlib import Path
from PIL import Image
from pptx import Presentation
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.util import Inches, Pt

RAIZ = Path(__file__).resolve().parent.parent
PLANTILLA = RAIZ / "04_Presentaciones" / "plantilla_presentacion.pptx"
SALIDA = RAIZ / "04_Presentaciones" / "borrador_presentacion.pptx"
FIG = RAIZ / "03_Resultados" / "Figuras"
TAB = RAIZ / "03_Resultados" / "Tablas"

CLARO, OSCURO, TEXTO, GRIS, CAJA = "F2F2F2", "1A1A1A", "1A1A1A", "4D4D4D", "E3E3E3"
TITULO_FUENTE, CUERPO_FUENTE = "Codec Pro", "Montserrat"
ANCHO, ALTO = 20.0, 11.25
MARGEN = 0.9


def rgb(h):
    return RGBColor.from_string(h)


prs = Presentation(PLANTILLA)

# --- dejar solo la portada de la plantilla -----------------------------------
ids = prs.slides._sldIdLst
for sld in list(ids)[1:]:
    prs.part.drop_rel(sld.rId)
    ids.remove(sld)

portada = prs.slides[0]
for sh in list(portada.shapes):
    if sh.name == "Freeform 11":  # logotipo de la empresa ficticia
        sh._element.getparent().remove(sh._element)


def poner_texto(forma, texto, tam=None):
    """Reemplaza el texto de una caja de la plantilla conservando el formato del primer run."""
    tf = forma.text_frame
    p0 = tf.paragraphs[0]
    for p in tf.paragraphs[1:]:
        p._p.getparent().remove(p._p)
    for r in p0.runs[1:]:
        r._r.getparent().remove(r._r)
    p0.runs[0].text = texto
    if tam:
        p0.runs[0].font.size = Pt(tam)


formas = {sh.name: sh for sh in portada.shapes}
poner_texto(formas["TextBox 8"], "¿DE QUÉ HABLA", 104)
poner_texto(formas["TextBox 7"], "LA JUNTA?", 104)
poner_texto(formas["TextBox 6"], "Los temas de la Junta del Banco de la República antes y después "
            "del choque petrolero de 2014. Informe para la mesa de renta fija.", 24)
poner_texto(formas["TextBox 12"], "Taller 3 · ECON-3785", 20)
formas["TextBox 12"].left = formas["TextBox 6"].left  # sin el logotipo, el rótulo se alinea con el texto
formas["TextBox 12"].width = Inches(6)
formas["TextBox 6"].top = Inches(8.45)

DISENO_BLANCO = [l for l in prs.slide_layouts if l.name == "Blank"][0]


# --- utilidades ----------------------------------------------------------------
def nueva(fondo=CLARO):
    s = prs.slides.add_slide(DISENO_BLANCO)
    for ph in list(s.placeholders):
        ph._element.getparent().remove(ph._element)
    s.background.fill.solid()
    s.background.fill.fore_color.rgb = rgb(fondo)
    return s


def caja_texto(s, x, y, w, h, parrafos, tam=22, color=TEXTO, fuente=CUERPO_FUENTE, negrita=False,
               cursiva=False, alinear=PP_ALIGN.LEFT, ancla=MSO_ANCHOR.TOP, espacio=6):
    """`parrafos`: lista de textos o de (texto, dict de opciones)."""
    tb = s.shapes.add_textbox(Inches(x), Inches(y), Inches(w), Inches(h))
    tf = tb.text_frame
    tf.word_wrap = True
    tf.vertical_anchor = ancla
    tf.margin_left = tf.margin_right = Inches(0.05)
    for i, par in enumerate(parrafos):
        texto, op = (par, {}) if isinstance(par, str) else par
        p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        p.alignment = op.get("alinear", alinear)
        p.space_after = Pt(op.get("espacio", espacio))
        r = p.add_run()
        r.text = texto
        f = r.font
        f.name = op.get("fuente", fuente)
        f.size = Pt(op.get("tam", tam))
        f.bold = op.get("negrita", negrita)
        f.italic = op.get("cursiva", cursiva)
        f.color.rgb = rgb(op.get("color", color))
    return tb


def titulo(s, texto, color=TEXTO):
    caja_texto(s, MARGEN, 0.55, ANCHO - 2 * MARGEN, 1.9, [texto], tam=40, color=color,
               fuente=TITULO_FUENTE, ancla=MSO_ANCHOR.TOP)


def imagen(s, ruta, x, y, w_max, h_max, centrar=True):
    """Inserta una imagen conservando su proporción, dentro del rectángulo dado."""
    w_px, h_px = Image.open(ruta).size
    escala = min(w_max / w_px, h_max / h_px)
    w, h = w_px * escala, h_px * escala
    x0 = x + (w_max - w) / 2 if centrar else x
    s.shapes.add_picture(str(ruta), Inches(x0), Inches(y), Inches(w), Inches(h))
    return x0, y, w, h


def fragmento(s, texto, y=9.95, x=MARGEN, w=ANCHO - 2 * MARGEN):
    caja_texto(s, x, y, w, 1.0, [texto], tam=20, color=GRIS, cursiva=True)


def notas(s, presentador, duracion, frase, cifras, frag):
    s.notes_slide.notes_text_frame.text = (
        f"Presentador: {presentador}. Duración: {duracion}.\n\n"
        f"Frase: {frase}\n\n"
        f"Cifras clave (fuente):\n{cifras}\n\n"
        f"Fragmento completo: {frag}"
    )


def diapositiva_figura(texto_titulo, ruta, frag_corto, nota):
    s = nueva()
    titulo(s, texto_titulo)
    imagen(s, ruta, MARGEN, 2.55, ANCHO - 2 * MARGEN, 7.25)
    if frag_corto:
        fragmento(s, frag_corto)
    notas(s, *nota)
    return s


notas(portada, "1", "0:15", "Presentación del equipo y de la pregunta.",
      "Pregunta: ¿cómo cambiaron los temas de interés de la Junta antes y después de la crisis del "
      "petróleo de 2014? (04_Presentaciones/hallazgos_y_figuras.txt)", "No aplica.")

# --- 1. Respuesta ----------------------------------------------------------------
s = nueva(OSCURO)
titulo(s, "Después del choque petrolero, la Junta dejó de hablar del mundo y del crédito y pasó a "
          "discutir cómo el choque entraba a Colombia", color="FFFFFF")
caja_texto(s, MARGEN, 3.6, 16.5, 6.5, [
    ("Entraron el déficit externo y la depreciación que se trasladaba a la inflación.", {}),
    ("Salieron la economía mundial, el crédito, el detalle de la actividad interna y el seguimiento "
     "de la inflación básica frente a la meta.", {}),
    ("El cambio aparece en comunicados y minutas, con tres fechas de corte, y se leyó primero en "
     "los comunicados.", {}),
], tam=30, color="FFFFFF", espacio=26)
notas(s, "1", "1:00",
      "Esta es la respuesta: cambió de qué habla la Junta, y el cambio se vio primero en los comunicados.",
      "Mensaje principal de 04_Presentaciones/hallazgos_y_figuras.txt, sección 1. Cifras en las "
      "diapositivas siguientes.", "No aplica (diapositiva de síntesis).")

# --- 2. Cómo lo medimos ------------------------------------------------------------
s = nueva()
titulo(s, "Comparamos cinco años antes y cinco después de la primera reunión con el petróleo en "
          "mercado bajista")
bloques = [
    ("Corte", "30 de octubre de 2014: primera reunión en que el Brent estaba 20 % o más por debajo "
              "de su máximo de 12 meses. Se fijó con las series, antes de mirar el texto."),
    ("Ventana", "Cinco años a cada lado: 54 y 53 comunicados, 59 y 53 minutas. Robustez con toda "
                "la muestra 2007–2026 y con cortes en septiembre y diciembre de 2014."),
    ("Documentos", "Comunicados y minutas por separado. De las minutas solo se usa la discusión "
                   "de la Junta; los comunicados controlan el cambio de formato de 2014."),
    ("Medidas", "Palabras y temas de un diccionario fijado de antemano, y un modelo de tópicos "
                "(LDA) estimado con bloques de oraciones."),
]
for i, (cab, cuerpo) in enumerate(bloques):
    x = MARGEN + (i % 2) * 9.25
    y = 2.9 + (i // 2) * 3.55
    caja = s.shapes.add_shape(1, Inches(x), Inches(y), Inches(8.95), Inches(3.25))
    caja.fill.solid()
    caja.fill.fore_color.rgb = rgb(CAJA)
    caja.line.fill.background()
    caja.shadow.inherit = False
    caja_texto(s, x + 0.35, y + 0.3, 8.25, 2.8, [(cab, {"negrita": True, "tam": 28}), (cuerpo, {"tam": 24})],
               espacio=10)
notas(s, "1", "1:00",
      "El corte lo fijó el petróleo, no el texto; leímos comunicados y minutas con dos medidas.",
      "Corte y ventanas: 03_Resultados/Tablas/09_antes_despues/conjunto_documentos_por_epoca.csv "
      "(54/53 comunicados, 59/53 minutas; minutas 43.788 y 23.104 palabras). Regla del corte: "
      "«Decisiones tomadas» de CLAUDE.md (2026-11-19).", "No aplica.")

# --- 3. Cronología macro -------------------------------------------------------------
s = nueva()
titulo(s, "La caída del petróleo llegó a la inflación en dos años, a través de la depreciación del peso")
imagen(s, FIG / "07_graficas_macro" / "macro_cronologia_choque.png", 9.6, 2.45, 9.5, 8.45)
for i, (cifra, texto) in enumerate([
        ("−77 %", "Brent, de junio de 2014 a enero de 2016"),
        ("+86 %", "TRM, de julio de 2014 a febrero de 2016"),
        ("8,97 %", "Inflación en julio de 2016, con meta de 3 %")]):
    caja_texto(s, MARGEN, 2.75 + i * 2.15, 8.2, 2.0,
               [(cifra, {"tam": 66, "fuente": TITULO_FUENTE, "espacio": 0}), (texto, {"tam": 24})])
fragmento(s, "«…decidió incrementar la tasa de interés de intervención en 25 pb y la situó en "
             "4,75%.» Comunicado, 25-09-2015", y=9.4, w=8.4)
notas(s, "1", "1:15", "El Brent cayó 77 %, el peso se depreció 86 % y la inflación llegó a 9 %.",
      "Brent 115,2 → 26,0 USD (2014-06-19 a 2016-01-20); TRM 1.846 → 3.435 (2014-07-25 a 2016-02-12); "
      "inflación 8,97 % en julio de 2016; primera alza 2015-09-25 y última 2016-07-29 "
      "(03_Resultados/Tablas/07_graficas_macro/macro_cronologia.csv).",
      "«La Junta Directiva del Banco de la República en su sesión de hoy decidió incrementar la tasa de "
      "interés de intervención en 25 pb y la situó en 4,75%.» Comunicado del 25-09-2015.")

D11 = FIG / "11_figuras_diapositiva"

# --- 4. Déficit externo ------------------------------------------------------------------
diapositiva_figura(
    "Después del choque, la Junta pasó de describir la economía mundial a discutir el déficit externo "
    "de Colombia",
    D11 / "conjunto_lda_externo_6_10.png",
    "«…el déficit en la cuenta corriente de la balanza de pagos del país se ha ampliado.» "
    "Comunicado, 20-02-2015",
    ("2", "1:15",
     "El déficit externo pasó de 2 % a 16 % del peso de los comunicados; la cuenta corriente, que "
     "antes no se mencionaba, aparece unas dos veces por cada mil palabras.",
     "Tópico 6: comunicados 2,3 → 16,4 % (+14,1 pp [11,4; 16,8]), minutas 2,6 → 12,0 % (+9,4 pp). "
     "Tópico 10: comunicados 16,1 → 5,5 % (−10,6 pp), minutas 13,5 → 4,2 % (−9,3 pp) "
     "(03_Resultados/Tablas/08_lda_oraciones/conjunto_lda_antes_despues.csv). «Cuenta corriente»: "
     "0 → 2,03 por 1.000 palabras en minutas y 0 → 1,41 en comunicados "
     "(03_Resultados/Tablas/09_antes_despues/conjunto_palabras_cambio_detalle.csv). Robusto.",
     "«Como resultado de la fuerte caída de los ingresos por exportaciones petroleras y del dinamismo "
     "de la demanda interna, el déficit en la cuenta corriente de la balanza de pagos del país se ha "
     "ampliado.» Comunicado del 20-02-2015."))

# --- 5. Crédito y actividad ----------------------------------------------------------------
diapositiva_figura(
    "El crédito y el detalle de la actividad interna perdieron espacio en la discusión",
    D11 / "conjunto_lda_credito_actividad_1_2.png",
    "«El crecimiento del crédito a los hogares permanece alto…» Comunicado, 30-04-2012",
    ("2", "1:15",
     "Lo que dominaba en 2010–2013 casi desaparece: el crédito pasa de 11 % a menos de 2 % de los "
     "comunicados.",
     "Tópico 2: comunicados 10,7 → 1,5 % (−9,2 pp [−10,9; −7,5]), minutas 12,3 → 3,3 % (−9,0 pp). "
     "Tópico 1: comunicados 15,2 → 11,6 % (−3,6 pp), minutas 14,8 → 7,9 % (−6,9 pp) "
     "(03_Resultados/Tablas/08_lda_oraciones/conjunto_lda_antes_despues.csv). Tema «Actividad "
     "económica» del diccionario: −6,4 y −7,9 por 1.000 palabras "
     "(03_Resultados/Tablas/09_antes_despues/conjunto_temas_antes_despues.csv). Robusto. Salvedad: "
     "el fin del ciclo de crédito de 2010–2013 también explica la caída.",
     "«El crecimiento del crédito a los hogares permanece alto, especialmente el de consumo, lo que "
     "indica que los hogares han elevado significativamente su grado de endeudamiento.» Comunicado "
     "del 30-04-2012."))

# --- 6. Inflación --------------------------------------------------------------------------
diapositiva_figura(
    "La Junta pasó de vigilar la inflación básica frente a la meta a explicar el traslado de la "
    "depreciación a los precios",
    D11 / "conjunto_lda_inflacion_4_8.png",
    "«El traslado de parte de la devaluación del peso a los precios al consumidor… la probable "
    "activación de mecanismos de indexación.» Comunicado, 25-09-2015",
    ("2", "1:30",
     "La inflación no recibió más espacio, recibió otra discusión: indexación, persistencia, traslado.",
     "Tópico 4: comunicados 5,1 → 15,8 % (+10,8 pp [7,9; 13,6], robusto), minutas 7,5 → 9,6 % "
     "(+2,0 pp [−0,6; 4,7], matizado). Tópico 8: comunicados 11,5 → 4,6 % (−6,9 pp), minutas "
     "12,2 → 5,4 % (−6,8 pp), robusto (03_Resultados/Tablas/08_lda_oraciones/conjunto_lda_antes_despues.csv). "
     "Palabras: «indexación» 0 → 1,11 por 1.000 en comunicados; en minutas «inflación» pasa de "
     "aparecer con proyección y monitoreo a meta, convergencia, persistencia e indexación "
     "(03_Resultados/Figuras/11_figuras_diapositiva/minutas_correlaciones_inflacion.png, en el apéndice).",
     "«El traslado de parte de la devaluación del peso a los precios al consumidor y la mayor "
     "intensidad del fenómeno de El Niño hacen más lenta la convergencia de la inflación a la meta, "
     "tanto por su impacto directo sobre los precios y las expectativas de inflación como por la "
     "probable activación de mecanismos de indexación.» Comunicado del 25-09-2015."))

# --- 7. Embeddings (pendiente) ------------------------------------------------------------
s = nueva()
titulo(s, "Contexto de las palabras clave antes y después del corte (pendiente de los embeddings)")
caja = s.shapes.add_shape(1, Inches(MARGEN), Inches(2.6), Inches(ANCHO - 2 * MARGEN), Inches(6.6))
caja.fill.solid()
caja.fill.fore_color.rgb = rgb("BFBFBF")
caja.line.fill.background()
caja.shadow.inherit = False
caja_texto(s, MARGEN, 2.6, ANCHO - 2 * MARGEN, 6.6, ["PENDIENTE: figura de embeddings (script 10)"],
           tam=36, color=TEXTO, alinear=PP_ALIGN.CENTER, ancla=MSO_ANCHOR.MIDDLE)
caja_texto(s, MARGEN, 9.5, ANCHO - 2 * MARGEN, 1.2,
           ["Debería mostrar que los vecinos de «inflación» pasan de proyección y monitoreo a devaluación, "
            "traslado, indexación y persistencia, en comunicados y minutas."], tam=24, color=GRIS)
notas(s, "3", "0:45", "PENDIENTE: depende del resultado del script 10. Título provisional.",
      "Qué confirmaría y qué contradiría: 04_Presentaciones/hallazgos_y_figuras.txt, sección 5.",
      "PENDIENTE.")

# --- 8. Texto frente a macro ----------------------------------------------------------------
diapositiva_figura(
    "La atención al exterior se movió con el petróleo, y la discusión de la inflación por "
    "depreciación llegó con las alzas",
    D11 / "conjunto_externo_macro_2013_2018.png",
    "«El precio internacional del petróleo ha caído y se encuentra por debajo del pronóstico que tenía "
    "el equipo técnico.» Comunicado, 30-10-2014",
    ("3", "1:30",
     "El texto se movió con el petróleo y tocó su máximo antes que la TRM y la inflación; la discusión "
     "de la inflación por depreciación llegó con las alzas, no antes.",
     "Máximos de la atención al entorno externo: minutas 2015-06-24, comunicados 2015-09-25; mínimo "
     "del Brent 2016-01-29; máximo de la TRM 2016-02-19; máximo de la inflación 2016-08-31 "
     "(03_Resultados/Tablas/09_antes_despues/conjunto_cronologia_texto_macro.csv). Verificación: el "
     "entorno externo supera su máximo de 2009–2014 el 2014-12-19 (comunicados) y el 2015-03-20 "
     "(minutas), antes de la primera alza; el tópico de inflación por depreciación lo supera el "
     "2015-11-27 en comunicados, después de la primera alza, y nunca en minutas "
     "(03_Resultados/Tablas/11_figuras_diapositiva/conjunto_verificacion_antes_alzas.csv). "
     "Lectura asociativa, un solo episodio.",
     "«El precio internacional del petróleo ha caído y se encuentra por debajo del pronóstico que tenía "
     "el equipo técnico.» Comunicado del 30-10-2014."))

# --- 9. Comunicado frente a minuta ----------------------------------------------------------
diapositiva_figura(
    "El comunicado registró el cambio de agenda con más fuerza que la minuta",
    FIG / "09_antes_despues" / "conjunto_temas_antes_despues.png",
    "«…contribuir a la reducción en el déficit de la cuenta corriente, la Junta Directiva decidió "
    "aumentar en 50 pb…» Comunicado, 29-04-2016",
    ("3", "1:00",
     "Para leer el cambio de agenda, el comunicado; para entender la deliberación, la minuta.",
     "Entorno externo: +6,5 por 1.000 palabras [3,6; 9,4] en comunicados (robusto) y +2,1 [−0,8; 4,9] "
     "en minutas (matizado) (03_Resultados/Tablas/09_antes_despues/conjunto_temas_antes_despues_detalle.csv). "
     "Tópico 4: +10,8 pp en comunicados y +2,0 pp en minutas. En las minutas sube la justificación de "
     "la postura (tópico 3, 12,2 → 30,5 %), en parte por formato. En P4 el 56 % de las minutas reporta "
     "decisión por mayoría, frente al 8 % de los comunicados (05_Notas/04_bigramas/T_votacion_minuta_vs_comunicado.md).",
     "«Con el fin de asegurar de que la inflación converja a la meta en 2017 y contribuir a la "
     "reducción en el déficit de la cuenta corriente, la Junta Directiva decidió aumentar en 50 pb la "
     "tasa de interés de referencia.» Comunicado del 29-04-2016."))

# --- 10. Alcance de la evidencia -----------------------------------------------------------
s = nueva()
titulo(s, "La evidencia respalda el cambio de temas y deja abiertas su causa y su repetición")
for i, (cab, items) in enumerate([
        ("Respaldado", [
            "Entraron el déficit externo y la depreciación como causa de la inflación.",
            "Salieron la economía mundial, el crédito y la inflación básica frente a la meta.",
            "Se ve con palabras y con tópicos, en comunicados y minutas, con tres fechas de corte.",
        ]),
        ("Requiere más análisis", [
            "Causalidad: en la ventana también hubo El Niño, la Reserva Federal y el fin del ciclo de crédito.",
            "Si el texto se adelanta a las series: un solo episodio, con media móvil.",
            "Lo que cambia solo en minutas puede venir de su cambio de formato de mayo de 2014.",
        ])]):
    x = MARGEN + i * 9.25
    caja = s.shapes.add_shape(1, Inches(x), Inches(2.75), Inches(8.95), Inches(7.6))
    caja.fill.solid()
    caja.fill.fore_color.rgb = rgb(CAJA)
    caja.line.fill.background()
    caja.shadow.inherit = False
    caja_texto(s, x + 0.4, 3.05, 8.15, 7.1,
               [(cab, {"negrita": True, "tam": 30, "espacio": 20})] + [(t, {"tam": 25, "espacio": 22}) for t in items])
notas(s, "4", "1:00",
      "Es asociación en un solo episodio; el formato de las minutas y El Niño son las salvedades.",
      "04_Presentaciones/hallazgos_y_figuras.txt, sección 3.", "No aplica.")

# --- 11. 2026 --------------------------------------------------------------------------------
diapositiva_figura(
    "En 2026 la Junta vuelve a subir tasas, y la mesa puede vigilar si reaparece el lenguaje de 2015",
    FIG / "07_graficas_macro" / "macro_series_2007_2026.png",
    "«…decidió por mayoría incrementar en 100 puntos básicos (pbs) la tasa de interés de política "
    "monetaria a 10,25%.» Comunicado, 30-01-2026",
    ("4", "1:15",
     "Hipótesis, no pronóstico: si reaparecen indexación, persistencia y anclaje de expectativas, la "
     "discusión se parece a la de 2015; esta vez el petróleo sube y el peso se aprecia.",
     "P10 (desde 2026-01-30): 4 alzas y 2 reuniones sin cambio; inflación media 5,8 % (5,3 % a 6,3 %), "
     "fuera del rango en todos los meses; Brent medio 96,3 USD (+60 % en el periodo); TRM media 3.475 "
     "(−8,7 %) (03_Resultados/Tablas/07_graficas_macro/macro_descriptiva.csv; "
     "03_Resultados/Tablas/01_extraer_texto/conjunto_periodos.csv). Señales a vigilar: palabras de "
     "traslado y persistencia, tópico de inflación por choques frente al de inflación básica, sector "
     "externo y votación (83 % de minutas por mayoría en P10).",
     "«La Junta Directiva del Banco de la República decidió por mayoría incrementar en 100 puntos "
     "básicos (pbs) la tasa de interés de política monetaria a 10,25%.» Comunicado del 30-01-2026."))

# --- 12. Próximos pasos ----------------------------------------------------------------------
s = nueva(OSCURO)
titulo(s, "Próximos pasos para convertir esta lectura en una herramienta de seguimiento", color="FFFFFF")
caja_texto(s, MARGEN, 3.3, 17.0, 6.5, [
    "Probar fuera de muestra si los temas del comunicado anticipan la siguiente decisión de tasa.",
    "Repetir la medición en el choque inflacionario de 2021–2023 y en el ciclo actual.",
    "Validar a mano la votación y la dirección del voto de la minoría.",
    "Separar el efecto del petróleo del de El Niño en la discusión de la inflación.",
], tam=30, color="FFFFFF", espacio=26)
notas(s, "4", "0:45", "Probar si los temas anticipan la decisión, validar la votación y repetirlo en 2021–2023.",
      "04_Presentaciones/hallazgos_y_figuras.txt, sección 4 (preguntas abiertas).", "No aplica.")

# --- Apéndice ---------------------------------------------------------------------------------
s = nueva(OSCURO)
titulo(s, "Apéndice", color="FFFFFF")
notas(s, "—", "—", "Material de soporte para preguntas.", "—", "—")
apendice = [
    ("A1. Fechas de corte candidatas y datos que tenía la Junta", TAB / "07_graficas_macro" / "macro_cortes_candidatos.png"),
    ("A1. Documentos a cada lado del corte, por escenario", TAB / "09_antes_despues" / "conjunto_documentos_por_epoca.png"),
    ("A2. Selección del número de tópicos (K) y de α", TAB / "08_lda_oraciones" / "conjunto_lda_seleccion.png"),
    ("A3. Palabras de cada tópico", TAB / "08_lda_oraciones" / "conjunto_lda_topicos.png"),
    ("A3. Tópicos frente al diccionario, reunión a reunión", TAB / "08_lda_oraciones" / "conjunto_lda_vs_diccionario.png"),
    ("A4. Robustez del modelo de tópicos en cuatro escenarios", TAB / "08_lda_oraciones" / "conjunto_lda_antes_despues.png"),
    ("A5. Fragmentos de cada tema por época y documento", TAB / "09_antes_despues" / "conjunto_fragmentos_temas.png"),
    ("A6. Peso de los tópicos 6 a 10 por reunión, 2007 a 2019", FIG / "08_lda_oraciones" / "conjunto_lda_theta_por_reunion_topicos_6_10.png"),
    ("A7. Brent, TRM e inflación por periodo de política monetaria", TAB / "07_graficas_macro" / "macro_descriptiva.png"),
    ("A8. Palabras que acompañan a «inflación» en las minutas", D11 / "minutas_correlaciones_inflacion.png"),
    ("A8. Palabras que más ganan y más pierden peso", D11 / "conjunto_palabras_10_10.png"),
]
for t, ruta in apendice:
    s = nueva()
    caja_texto(s, MARGEN, 0.45, ANCHO - 2 * MARGEN, 1.0, [t], tam=32, fuente=TITULO_FUENTE)
    imagen(s, ruta, MARGEN, 1.6, ANCHO - 2 * MARGEN, 9.25)
    notas(s, "—", "—", "Apéndice.", f"Fuente: {ruta.relative_to(RAIZ).as_posix()}", "—")

prs.save(SALIDA)
print("Guardado:", SALIDA, "-", len(prs.slides), "diapositivas")
