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
import os
import re
import unicodedata
from pathlib import Path
import pandas as pd
from PIL import Image
from pptx import Presentation
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.util import Inches, Pt

RAIZ = Path(__file__).resolve().parent.parent
PLANTILLA = RAIZ / "04_Presentaciones" / "plantilla_presentacion.pptx"
# BORRADOR_SALIDA permite escribir en otra ruta (p. ej. si el .pptx está abierto en PowerPoint)
SALIDA = Path(os.environ.get("BORRADOR_SALIDA", RAIZ / "04_Presentaciones" / "borrador_presentacion.pptx"))
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
    caja_texto(s, MARGEN, 0.55, ANCHO - 2 * MARGEN, 1.55, [texto], tam=40, color=color,
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
    # la figura ocupa todo el alto libre bajo el título; con su proporción, lo más ancha posible
    imagen(s, ruta, MARGEN, 2.15, ANCHO - 2 * MARGEN, 8.2)
    if frag_corto:
        caja_texto(s, MARGEN, 10.4, ANCHO - 2 * MARGEN, 0.8, [frag_corto], tam=18, color=GRIS, cursiva=True)
    notas(s, *nota)
    return s


notas(portada, "1", "0:15", "Presentación del equipo y de la pregunta.",
      "Pregunta: ¿cómo cambiaron los temas de interés de la Junta antes y después de la crisis del "
      "petróleo de 2014? (04_Presentaciones/hallazgos_y_figuras.txt)", "No aplica.")

# --- utilidades para leer cifras de los .csv y poner tildes ----------------------------
def leer(ruta):
    return pd.read_csv(ruta, encoding="utf-8")


def num(x, d=1, signo=False):
    """Cifra con coma decimal y punto de miles."""
    s = f"{x:+,.{d}f}" if signo else f"{x:,.{d}f}"
    return s.replace(",", "§").replace(".", ",").replace("§", ".").replace("-", "−")


def ic(a, b, d=1):
    return f"[{num(a, d)}; {num(b, d)}]"


def sin_tilde(x):
    return "".join(c for c in unicodedata.normalize("NFD", x) if unicodedata.category(c) != "Mn")


# tildes de las etiquetas: cada lema toma la escritura más frecuente en los fragmentos originales
# de 08 y 09; los compuestos se escriben con su expresión
TEXTOS = pd.concat([leer(TAB / "09_lda_oraciones" / "conjunto_lda_fragmentos.csv").astype(str).stack()] +
                   [leer(TAB / "08_antes_despues" / f).fragmento.astype(str) for f in
                    ["conjunto_fragmentos_temas.csv", "conjunto_fragmentos_anclas.csv",
                     "conjunto_palabras_seleccion_fragmentos.csv", "conjunto_bigramas_seleccion_fragmentos.csv"]])
CONTEO = pd.Series(re.findall(r"[a-záéíóúüñ]+", " ".join(TEXTOS).lower())).value_counts()
FORMA = {}
for palabra, _ in CONTEO.items():
    FORMA.setdefault(sin_tilde(palabra).replace("ñ", "n"), palabra)
COMPUESTOS = {"postura_politica": "postura de política", "fenomeno_nino": "fenómeno de El Niño",
              "cuenta_corriente": "cuenta corriente", "balanza_pagos": "balanza de pagos",
              "meta_inflacion": "meta de inflación", "largo_plazo": "largo plazo", "zona_euro": "zona euro"}
# lemas que no aparecen con tilde en los fragmentos, siglas y nombres propios
FORMA.update({"construccion": "construcción", "ipc": "IPC", "asia": "Asia", "america": "América",
              "proyeccion": "proyección"})


def etiqueta(lema):
    if lema in COMPUESTOS:
        return COMPUESTOS[lema]
    return " ".join(FORMA.get(p, p) for p in lema.split("_"))


# --- 1. Respuesta ----------------------------------------------------------------
s = nueva(OSCURO)
titulo(s, "Después del choque petrolero, la Junta dejó de hablar del mundo y del crédito y pasó a "
          "discutir cómo el choque entraba a Colombia", color="FFFFFF")
caja_texto(s, MARGEN, 3.2, 17.5, 7.6, [
    ("Entraron el déficit externo y la depreciación que se trasladaba a la inflación.", {}),
    ("Salieron la economía mundial, el crédito, el detalle de la actividad interna y el seguimiento "
     "de la inflación básica frente a la meta.", {}),
    ("El cambio aparece en comunicados y minutas, con tres fechas de corte, y se ve con más fuerza en "
     "los comunicados.", {}),
    ("Para la mesa: el comunicado es la lectura más directa de hacia dónde mira la Junta, y en 2026 vale "
     "la pena vigilar si reaparece el lenguaje de 2015.", {"negrita": True}),
], tam=28, color="FFFFFF", espacio=24)
notas(s, "1", "1:00",
      "Esta es la respuesta: cambió de qué habla la Junta, y el cambio se ve con más fuerza en los comunicados.",
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
    ("Medidas", "Tres medidas: un diccionario de temas fijado de antemano, un modelo de tópicos "
                "(LDA) y embeddings que miden el contexto de cada palabra."),
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
      "El corte lo fijó el petróleo, no el texto; leímos comunicados y minutas con tres medidas.",
      "Corte y ventanas: 03_Resultados/Tablas/08_antes_despues/conjunto_documentos_por_epoca.csv "
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
     "El déficit externo pasó de 2 % a 16 % del peso de los temas en cada reunión; la cuenta corriente, que "
     "antes no se mencionaba, aparece unas dos veces por cada mil palabras.",
     "Tópico 6: comunicados 2,3 → 16,4 % (+14,1 pp [11,4; 16,8]), minutas 2,6 → 12,0 % (+9,4 pp). "
     "Tópico 10: comunicados 16,1 → 5,5 % (−10,6 pp), minutas 13,5 → 4,2 % (−9,3 pp) "
     "(03_Resultados/Tablas/09_lda_oraciones/conjunto_lda_antes_despues.csv). «Cuenta corriente»: "
     "0 → 2,03 por 1.000 palabras en minutas y 0 → 1,41 en comunicados "
     "(03_Resultados/Tablas/08_antes_despues/conjunto_palabras_cambio_detalle.csv). Robusto.",
     "«Como resultado de la fuerte caída de los ingresos por exportaciones petroleras y del dinamismo "
     "de la demanda interna, el déficit en la cuenta corriente de la balanza de pagos del país se ha "
     "ampliado.» Comunicado del 20-02-2015."))

# --- 5. Crédito y actividad ----------------------------------------------------------------
diapositiva_figura(
    "El crédito y el detalle de la actividad interna perdieron espacio en la discusión",
    D11 / "conjunto_lda_credito_actividad_1_2.png",
    "«El crecimiento del crédito a los hogares permanece alto…» Comunicado, 30-04-2012",
    ("2", "1:00",
     "Lo que dominaba en 2010–2013 casi desaparece: el crédito pasa de 11 % a menos de 2 % del "
     "peso de los temas en cada reunión.",
     "Tópico 2: comunicados 10,7 → 1,5 % (−9,2 pp [−10,9; −7,5]), minutas 12,3 → 3,3 % (−9,0 pp). "
     "Tópico 1: comunicados 15,2 → 11,6 % (−3,6 pp), minutas 14,8 → 7,9 % (−6,9 pp) "
     "(03_Resultados/Tablas/09_lda_oraciones/conjunto_lda_antes_despues.csv). Tema «Actividad "
     "económica» del diccionario: −6,4 y −7,9 por 1.000 palabras "
     "(03_Resultados/Tablas/08_antes_despues/conjunto_temas_antes_despues.csv). Robusto. Salvedad: "
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
    ("2", "1:15",
     "La inflación no recibió más espacio, recibió otra discusión: indexación, persistencia, traslado.",
     "Tópico 4: comunicados 5,1 → 15,8 % (+10,8 pp [7,9; 13,6], robusto), minutas 7,5 → 9,6 % "
     "(+2,0 pp [−0,6; 4,7], matizado). Tópico 8: comunicados 11,5 → 4,6 % (−6,9 pp), minutas "
     "12,2 → 5,4 % (−6,8 pp), robusto (03_Resultados/Tablas/09_lda_oraciones/conjunto_lda_antes_despues.csv). "
     "Palabras: «indexación» 0 → 1,11 por 1.000 en comunicados; en minutas «inflación» pasa de "
     "aparecer con proyección y monitoreo a meta, convergencia, persistencia e indexación "
     "(03_Resultados/Figuras/11_figuras_diapositiva/minutas_correlaciones_inflacion.png, en el apéndice).",
     "«El traslado de parte de la devaluación del peso a los precios al consumidor y la mayor "
     "intensidad del fenómeno de El Niño hacen más lenta la convergencia de la inflación a la meta, "
     "tanto por su impacto directo sobre los precios y las expectativas de inflación como por la "
     "probable activación de mecanismos de indexación.» Comunicado del 25-09-2015."))

# --- 7. Embeddings --------------------------------------------------------------------------
# solo lo que sostienen GloVe y Word2Vec; los vecinos se leen de la tabla de 10_glove.R
glove = leer(TAB / "10_glove" / "conjunto_glove_vecinos.csv").set_index("ancla")


def estables(lista):
    """Vecinos sin asterisco (los que se repiten en las tres semillas), con tildes."""
    return ", ".join(etiqueta(v.strip().replace(" ", "_")) for v in lista.split(",") if "*" not in v)


s = nueva()
titulo(s, "Las expectativas de inflación son la palabra cuyo contexto más cambió, y la inflación pasó a "
          "discutirse junto a la meta")
imagen(s, D11 / "conjunto_glove_cosenos.png", MARGEN, 2.3, 11.2, 7.6, centrar=False)
bloques_vec = [("Vecinos estables antes → después (GloVe)", {"tam": 18, "color": GRIS, "espacio": 12})]
for ancla, nombre in [("inflacion", "«inflación»"), ("expectativas inflacion", "«expectativas de inflación»")]:
    bloques_vec += [(nombre, {"negrita": True, "tam": 22, "espacio": 4}),
                    ("Antes: " + estables(glove.loc[ancla, "lista_antes"]), {"tam": 19, "espacio": 4}),
                    ("Después: " + estables(glove.loc[ancla, "lista_despues"]), {"tam": 19, "espacio": 16})]
caja_texto(s, 12.5, 2.4, 6.6, 6.6, bloques_vec)
caja_texto(s, 12.5, 9.05, 6.6, 1.1, ["El «anclaje / desanclaje» de las expectativas solo aparece con GloVe."],
           tam=16, color=GRIS)
caja_texto(s, MARGEN, 10.4, ANCHO - 2 * MARGEN, 0.8,
           ["«…el efecto de la devaluación puede inicialmente primar sobre el del menor crecimiento y desviar "
            "transitoriamente la inflación de la meta.» Minuta, 30-01-2015"], tam=18, color=GRIS, cursiva=True)
notas(s, "3", "1:15",
      "Una tercera medida, que mira el contexto de cada palabra, confirma que la inflación cambió de discusión.",
      f"Coseno antes–después, GloVe / Word2Vec: expectativas de inflación "
      f"{num(glove.loc['expectativas inflacion', 'coseno_antes_despues'], 2)} / "
      f"{num(glove.loc['expectativas inflacion', 'coseno_w2v'], 2)}; inflación "
      f"{num(glove.loc['inflacion', 'coseno_antes_despues'], 2)} / {num(glove.loc['inflacion', 'coseno_w2v'], 2)}; "
      f"crecimiento {num(glove.loc['crecimiento', 'coseno_antes_despues'], 2)} / "
      f"{num(glove.loc['crecimiento', 'coseno_w2v'], 2)}; tasa de intervención "
      f"{num(glove.loc['tasa intervencion', 'coseno_antes_despues'], 2)} / "
      f"{num(glove.loc['tasa intervencion', 'coseno_w2v'], 2)} "
      "(03_Resultados/Tablas/10_glove/conjunto_glove_vecinos.csv). Coinciden en que las expectativas son el "
      "ancla que más cambia y en que «inflación» va con meta y convergencia; el orden del resto y el "
      "«anclaje» dependen del método (05_Notas/10_glove/T_contexto_inflacion_expectativas.md).",
      "«Algunos miembros de la Junta consideran que el efecto de la devaluación puede inicialmente primar "
      "sobre el del menor crecimiento y desviar transitoriamente la inflación de la meta.» Minuta del 30-01-2015.")

# --- 8. Texto frente a macro ----------------------------------------------------------------
diapositiva_figura(
    "La atención al exterior se movió con el petróleo, y la discusión de la inflación por "
    "depreciación llegó con las alzas",
    D11 / "conjunto_externo_macro_2013_2018.png",
    "«El precio internacional del petróleo ha caído y se encuentra por debajo del pronóstico que tenía "
    "el equipo técnico.» Comunicado, 30-10-2014",
    ("3", "1:15",
     "El texto se movió con el petróleo y tocó su máximo antes que la TRM y la inflación; la discusión "
     "de la inflación por depreciación llegó con las alzas, no antes.",
     "Máximos de la atención al entorno externo: minutas 2015-06-24, comunicados 2015-09-25; mínimo "
     "del Brent 2016-01-29; máximo de la TRM 2016-02-19; máximo de la inflación 2016-08-31 "
     "(03_Resultados/Tablas/08_antes_despues/conjunto_cronologia_texto_macro.csv). Verificación: el "
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
    D11 / "conjunto_temas_antes_despues.png",
    "«…contribuir a la reducción en el déficit de la cuenta corriente, la Junta Directiva decidió "
    "aumentar en 50 pb…» Comunicado, 29-04-2016",
    ("3", "1:00",
     "Para leer el cambio de agenda, el comunicado; para entender la deliberación, la minuta.",
     "Entorno externo: +6,5 por 1.000 palabras [3,6; 9,4] en comunicados (robusto) y +2,1 [−0,8; 4,9] "
     "en minutas (matizado) (03_Resultados/Tablas/08_antes_despues/conjunto_temas_antes_despues_detalle.csv). "
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
            "Se ve con el diccionario, los tópicos y los embeddings, en comunicados y minutas, con tres fechas de corte.",
        ]),
        ("Requiere más análisis", [
            "Causalidad: en la ventana también hubo El Niño, la Reserva Federal y el fin del ciclo de crédito.",
            "Si el texto se adelanta a las series: un solo episodio, con media móvil.",
            "Lo que cambia solo en minutas puede venir de su cambio de formato de mayo de 2014.",
            "Los embeddings cambian según el método (GloVe o Word2Vec); solo se usa lo que coincide.",
        ])]):
    x = MARGEN + i * 9.25
    caja = s.shapes.add_shape(1, Inches(x), Inches(2.75), Inches(8.95), Inches(7.6))
    caja.fill.solid()
    caja.fill.fore_color.rgb = rgb(CAJA)
    caja.line.fill.background()
    caja.shadow.inherit = False
    caja_texto(s, x + 0.4, 3.05, 8.15, 7.1,
               [(cab, {"negrita": True, "tam": 30, "espacio": 18})] + [(t, {"tam": 24, "espacio": 16}) for t in items])
notas(s, "4", "1:00",
      "Es asociación en un solo episodio; el formato de las minutas y El Niño son las salvedades.",
      "04_Presentaciones/hallazgos_y_figuras.txt, sección 3.", "No aplica.")

# --- 11. 2026 --------------------------------------------------------------------------------
diapositiva_figura(
    "En 2026 la Junta vuelve a subir tasas, y la mesa puede vigilar si reaparece el lenguaje de 2015",
    D11 / "macro_series_2007_2026.png",
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
notas(s, "4", "1:00", "Probar si los temas anticipan la decisión, validar la votación y repetirlo en 2021–2023.",
      "04_Presentaciones/hallazgos_y_figuras.txt, sección 4 (preguntas abiertas).", "No aplica.")

# --- Apéndice ---------------------------------------------------------------------------------
s = nueva(OSCURO)
titulo(s, "Apéndice", color="FFFFFF")
notas(s, "—", "—", "Material de soporte para preguntas.", "—", "—")
def tabla(s, x, y, anchos, filas, tam=20, destacar=(), alto_fila=0.62):
    """Tabla nativa sin bordes: encabezado oscuro y filas alternas. `destacar`: índices de filas en negrita."""
    gf = s.shapes.add_table(len(filas), len(anchos), Inches(x), Inches(y), Inches(sum(anchos)),
                            Inches(alto_fila * len(filas)))
    tbl = gf.table
    gf._element.graphic.graphicData.tbl[0][-1].text = "{2D5ABB26-0587-4C30-8999-92F81FD0307C}"  # sin estilo ni rejilla
    for j, w in enumerate(anchos):
        tbl.columns[j].width = Inches(w)
    for i, fila in enumerate(filas):
        tbl.rows[i].height = Inches(alto_fila)
        for j, valor in enumerate(fila):
            c = tbl.cell(i, j)
            c.fill.solid()
            c.fill.fore_color.rgb = rgb(OSCURO if i == 0 else ("D4D4D4" if i in destacar else (CAJA if i % 2 else CLARO)))
            c.margin_left = c.margin_right = Inches(0.12)
            c.margin_top = c.margin_bottom = Inches(0.05)
            c.vertical_anchor = MSO_ANCHOR.MIDDLE
            tf = c.text_frame
            tf.word_wrap = True
            p = tf.paragraphs[0]
            p.alignment = PP_ALIGN.LEFT if j == 0 or isinstance(valor, str) and not re.match(r"^[−+\d\[]", valor) else PP_ALIGN.CENTER
            r = p.add_run()
            r.text = str(valor)
            r.font.name = CUERPO_FUENTE
            r.font.size = Pt(tam)
            r.font.bold = i == 0 or i in destacar
            r.font.color.rgb = rgb("FFFFFF" if i == 0 else TEXTO)
    return gf


def titulo_apendice(s, texto):
    caja_texto(s, MARGEN, 0.45, ANCHO - 2 * MARGEN, 1.6, [texto], tam=34, fuente=TITULO_FUENTE)


def nota_apendice(s, ruta, como_leer):
    s.notes_slide.notes_text_frame.text = (f"Tabla o figura completa: {ruta.relative_to(RAIZ).as_posix()}\n\n"
                                           f"Cómo leerla: {como_leer}")


def apendice_cortes():
    ruta = TAB / "07_graficas_macro" / "macro_cortes_candidatos.csv"
    d = leer(ruta)
    filas = [["Regla", "Reunión", "Brent frente a su máximo de 12 meses (%)", "TRM, variación anual (%)",
              "Inflación total (%)"]]
    destacar = []
    for _, r in d.iterrows():
        if "aprobado" in r.regla:
            destacar.append(len(filas))
            aprobado = r
        filas.append([r.regla, r.reunion, num(r.brent_vs_max, 1, True), num(r.var_trm, 1, True), num(r.inflacion_total)])
    s = nueva()
    titulo_apendice(s, f"El corte del {aprobado.reunion} es la primera reunión en que el Brent estaba "
                       f"{num(-aprobado.brent_vs_max)} % por debajo de su máximo de 12 meses")
    tabla(s, MARGEN, 2.5, [7.6, 2.4, 3.0, 2.6, 2.6], filas, tam=21, destacar=destacar, alto_fila=1.25)
    caja_texto(s, MARGEN, 8.0, ANCHO - 2 * MARGEN, 2.5, [
        "Datos que la Junta tenía el día de cada reunión: Brent del día hábil anterior, TRM del día e inflación del "
        "último mes publicado. El corte se fijó solo con las series y las decisiones de tasa, antes de mirar el texto; "
        "las otras dos fechas se usan como cortes alternativos de robustez."], tam=21, color=GRIS)
    nota_apendice(s, TAB / "07_graficas_macro" / "macro_cortes_candidatos.png",
                  "cada fila es una regla para fechar el inicio del choque; en negrita, la aprobada. La tabla completa "
                  "trae también el nivel del Brent, la TRM y la brecha frente a la meta.")


def apendice_documentos():
    ruta = TAB / "08_antes_despues" / "conjunto_documentos_por_epoca.csv"
    d = leer(ruta)
    filas = [["Escenario y documento", "Reuniones antes", "Reuniones después", "Palabras antes", "Palabras después"]]
    destacar = []
    for _, r in d.iterrows():
        escenario = re.split(r"[:,]", r.escenario)[0]
        documento = "comunicados" if r.fuente == "Comunicados" else "minutas (discusión)"
        if escenario == "Principal":
            destacar.append(len(filas))
        filas.append([f"{escenario} · {documento}", num(r.reuniones_antes, 0), num(r.reuniones_despues, 0),
                      num(r.palabras_antes, 0), num(r.palabras_despues, 0)])
    p = d[d.escenario.str.startswith("Principal")].set_index("fuente")
    caida = 100 * (1 - p.loc["Minutas: discusión de la Junta", "palabras_despues"] /
                   p.loc["Minutas: discusión de la Junta", "palabras_antes"])
    s = nueva()
    titulo_apendice(s, f"Los comunicados quedan equilibrados a cada lado del corte y las minutas tienen "
                       f"{num(caida, 0)} % menos palabras después, por su cambio de formato")
    tabla(s, MARGEN, 2.45, [7.4, 2.7, 2.7, 2.7, 2.7], filas, tam=21, destacar=destacar, alto_fila=0.8)
    caja_texto(s, MARGEN, 9.85, ANCHO - 2 * MARGEN, 1.0, [
        "En negrita, el escenario principal (corte 2014-10-30, 5 años a cada lado); los otros tres son de robustez. "
        "Palabras: todas las del texto; en las minutas, solo la discusión de la Junta."], tam=18, color=GRIS)
    nota_apendice(s, TAB / "08_antes_despues" / "conjunto_documentos_por_epoca.png",
                  "cada fila es un tipo de documento en un escenario; por eso toda medida se normaliza por 1.000 "
                  "palabras. La tabla completa trae las fechas de la primera y la última reunión de cada época.")


def apendice_seleccion():
    ruta = TAB / "09_lda_oraciones" / "conjunto_lda_seleccion.csv"
    d = leer(ruta)
    filas = [["Número de tópicos (K)", "α con menor perplejidad", "Perplejidad", "Por encima del mínimo (%)",
              "Coherencia media"]]
    destacar = []
    for _, r in d.iterrows():
        if r.elegido == "Sí":
            destacar.append(len(filas))
            elegido = r
        filas.append([str(int(r.K)), num(r.alpha, 2), num(r.perplejidad), num(r.costo_pct), num(r.coherencia)])
    s = nueva()
    titulo_apendice(s, f"K = {int(elegido.K)} es el menor número de tópicos a menos del 5 % de la perplejidad "
                       f"mínima, y su coherencia no es la peor")
    tabla(s, MARGEN, 2.5, [4.0, 3.6, 3.4, 3.6, 3.6], filas, tam=22, destacar=destacar, alto_fila=0.95)
    caja_texto(s, MARGEN, 8.4, ANCHO - 2 * MARGEN, 2.2, [
        "Regla fijada antes de ver los tópicos: para cada K se toma el α con menor perplejidad (document completion, "
        "3 pliegues); se elige el K más pequeño a menos del 5 % del mínimo, salvo que su coherencia UMass media sea la "
        "peor. Menor perplejidad es mejor; la coherencia más cercana a cero, también."], tam=21, color=GRIS)
    nota_apendice(s, TAB / "09_lda_oraciones" / "conjunto_lda_seleccion.png",
                  "cada fila es un número de tópicos con su mejor α; en negrita, el elegido. La rejilla completa de K y α "
                  "está en conjunto_lda_rejilla.csv.")


def apendice_topicos():
    ruta = TAB / "09_lda_oraciones" / "conjunto_lda_topicos.csv"
    d = leer(ruta)
    d["num"] = d.topico.str.extract(r"^(\d+)\.").astype(float)
    estables = d[d.se_repite == "Sí"].sort_values("num")
    captura = {1: "Indicadores de la demanda interna: consumo, construcción, industria",
               2: "Crédito a los hogares, cartera y endeudamiento",
               3: "La justificación de la postura y del ajuste de la tasa",
               4: "La inflación explicada por la devaluación, los alimentos y El Niño",
               6: "El ajuste al choque: déficit externo y capacidad productiva",
               7: "Fórmulas de seguimiento y de provisión de liquidez",
               8: "La inflación básica y las expectativas frente al rango meta",
               10: "El ciclo mundial: Europa, Asia, América Latina, emergentes"}
    filas = [["Tópico", "Palabras de mayor lift", "Qué captura"]]
    for _, r in estables.iterrows():
        palabras = [etiqueta(p.strip()) for p in r.top_lift.split(",")][:5]
        filas.append([r.topico, ", ".join(palabras), captura[int(r.num)]])
    s = nueva()
    titulo_apendice(s, "Cada tópico estable tiene un vocabulario propio que sostiene su nombre")
    tabla(s, MARGEN, 2.2, [5.6, 6.0, 6.6], filas, tam=20, alto_fila=0.84)
    inestables = [str(int(n)) for n in d[d.se_repite == "No"].topico.str.extract(r"(\d+)")[0].astype(float)]
    alerta = estables[estables.alerta.notna()].num.astype(int).astype(str).tolist()
    caja_texto(s, MARGEN, 9.95, ANCHO - 2 * MARGEN, 1.0, [
        f"Los tópicos {' y '.join(inestables)} no se repiten con otras semillas y no se interpretan. "
        f"Con alerta de formato o de época (más del 70 % de su peso en un formato de minuta): {', '.join(alerta)}."],
        tam=18, color=GRIS)
    nota_apendice(s, TAB / "09_lda_oraciones" / "conjunto_lda_topicos.png",
                  "cada fila es un tópico estable; las palabras de mayor lift son las más propias del tópico "
                  "frente al resto, y la última columna es la interpretación que justifica su nombre.")


def apendice_diccionario():
    ruta = TAB / "09_lda_oraciones" / "conjunto_lda_vs_diccionario.csv"
    d = leer(ruta)
    temas = [("Actividad económica", "1", "tópico 1"), ("Inflación", "4 + 8", "tópicos 4 + 8"),
             ("Entorno externo", "6 + 10", "tópicos 6 + 10")]
    s = nueva()
    titulo_apendice(s, "El diccionario y los tópicos se mueven juntos en actividad e inflación; en el "
                       "entorno externo, solo en las minutas")
    for i, (tema, et, rotulo) in enumerate(temas):
        x = MARGEN + i * 6.15
        caja = s.shapes.add_shape(1, Inches(x), Inches(2.55), Inches(5.85), Inches(5.4))
        caja.fill.solid()
        caja.fill.fore_color.rgb = rgb(CAJA)
        caja.line.fill.background()
        caja.shadow.inherit = False
        bloques = [(tema, {"negrita": True, "tam": 26, "espacio": 0}), (rotulo.capitalize(), {"tam": 20, "color": GRIS, "espacio": 12})]
        for fuente, corto in [("Comunicados", "Comunicados"), ("Minutas: discusión de la Junta", "Minutas")]:
            r = d[(d.tema == tema) & (d.etiqueta.astype(str) == et) & (d.fuente == fuente)].iloc[0]
            bloques += [(num(r.r, 2), {"tam": 60, "fuente": TITULO_FUENTE, "espacio": 0}),
                        (f"{corto}, IC 95 % {ic(r.r_inf, r.r_sup, 2)}; {int(r.reuniones)} reuniones", {"tam": 19, "espacio": 12})]
        caja_texto(s, x + 0.3, 2.75, 5.3, 5.3, bloques)
    caja_texto(s, MARGEN, 8.35, ANCHO - 2 * MARGEN, 2.3, [
        "Correlación por reunión, en la ventana de 5 años a cada lado del corte, entre el peso de los tópicos y la "
        "atención al tema del diccionario. El diccionario suma conversaciones que se mueven en direcciones opuestas "
        "(la inflación por depreciación sube y la inflación básica baja; el déficit externo sube y la economía "
        "mundial baja); el modelo de tópicos las separa."], tam=22, color=TEXTO)
    nota_apendice(s, TAB / "09_lda_oraciones" / "conjunto_lda_vs_diccionario.png",
                  "cada cifra es la correlación de Pearson por reunión entre el peso del tópico (o la suma de dos) y el "
                  "tema del diccionario; cerca de 1, las dos medidas suben y bajan juntas.")


def apendice_robustez():
    ruta = TAB / "09_lda_oraciones" / "conjunto_lda_antes_despues_detalle.csv"
    d = leer(ruta)
    d["num"] = d.topico.str.extract(r"^(\d+)\.").astype(float)
    principal = d[d.escenario.str.startswith("Principal")]
    filas = [["Tópico", "Comunicados (pp)", "Dirección", "Minutas (pp)", "Dirección"]]
    robustos = 0
    for num_t in sorted(principal.num.dropna().unique()):
        fila = None
        lecturas = []
        for fuente in ["Comunicados", "Minutas: discusión de la Junta"]:
            todos = d[(d.num == num_t) & (d.fuente == fuente)]
            p = todos[todos.escenario.str.startswith("Principal")].iloc[0]
            mismo = all((todos.diferencia > 0) == (p.diferencia > 0))
            lecturas.append("Robusto" if mismo else "Matizado")
            celda = f"{num(p.diferencia, 1, True)} {ic(p.dif_inf, p.dif_sup)}"
            fila = [p.topico] if fila is None else fila
            fila += [celda, lecturas[-1]]
        robustos += all(l == "Robusto" for l in lecturas)
        filas.append(fila)
    s = nueva()
    titulo_apendice(s, f"{robustos} de los {len(filas) - 1} tópicos estables mantienen la dirección del cambio en "
                       f"los cuatro escenarios, en comunicados y en minutas")
    tabla(s, MARGEN, 2.35, [6.4, 3.6, 2.2, 3.6, 2.4], filas, tam=21, alto_fila=0.8)
    caja_texto(s, MARGEN, 9.75, ANCHO - 2 * MARGEN, 1.1, [
        "Diferencia después − antes del peso medio del tópico en la reunión, en puntos porcentuales, con IC 95 %, en el "
        "escenario principal (corte 2014-10-30, 5 años a cada lado). «Robusto»: el signo se mantiene con la muestra "
        "completa 2007–2026 y con los cortes 2014-09-26 y 2014-12-19."], tam=17, color=GRIS)
    nota_apendice(s, TAB / "09_lda_oraciones" / "conjunto_lda_antes_despues.png",
                  "cada fila es un tópico; un número positivo dice que el tópico pesa más después del corte. La "
                  "columna de dirección dice si los otros tres escenarios dan el mismo signo.")


def recortar(texto, clave, max_palabras=30):
    """Hasta `max_palabras` alrededor de la primera palabra que contiene `clave`."""
    pal = texto.split()
    if len(pal) <= max_palabras:
        return texto
    i = next((k for k, p in enumerate(pal) if clave.lower() in p.lower()), 0)
    ini = max(0, min(i - 8, len(pal) - max_palabras))
    fragmento = " ".join(pal[ini:ini + max_palabras])
    return ("…" if ini > 0 else "") + fragmento + ("…" if ini + max_palabras < len(pal) else "")


def apendice_fragmentos():
    d08 = TAB / "08_antes_despues"
    anclas = leer(d08 / "conjunto_fragmentos_anclas.csv")
    temas = leer(d08 / "conjunto_fragmentos_temas.csv")
    palabras = leer(d08 / "conjunto_palabras_seleccion_fragmentos.csv")

    def de_palabras(term, fuente):
        r = palabras[(palabras.termino == term) & (palabras.fuente == fuente)].iloc[0]
        doc = "comunicado" if fuente == "Comunicados" else "minuta"
        return f"{doc} {r.fecha_fragmento}", r.fragmento

    def de_anclas(ancla, fuente, epoca):
        r = anclas[(anclas.ancla == ancla) & (anclas.fuente == fuente) & (anclas.epoca == epoca)].iloc[0]
        return r.documento, r.fragmento

    def de_temas(tema, fuente, epoca):
        r = temas[(temas.tema == tema) & (temas.fuente == fuente) & (temas.epoca == epoca)].iloc[0]
        return r.documento, r.fragmento

    tarjetas = [
        ("Déficit externo", "Después", de_anclas("deficit", "Comunicados", "Después"), "déficit"),
        ("Entorno externo", "Después", de_temas("Entorno externo", "junta", "Después"), "Reserva"),
        ("Inflación por depreciación", "Después", de_palabras("indexacion", "Comunicados"), "devaluación"),
        ("Economía mundial", "Antes", de_palabras("europa", "Comunicados"), "Europa"),
        ("Crédito", "Antes", de_palabras("credito", "Comunicados"), "crédito"),
        ("Seguimiento de la inflación", "Antes", de_palabras("monitoreo", "Minutas: discusión de la Junta"), "monitoreo"),
    ]
    s = nueva()
    titulo_apendice(s, "En los documentos, la Junta pasa del ciclo mundial y el crédito al déficit externo y la devaluación")
    for i, (tema, epoca, (doc, texto), clave) in enumerate(tarjetas):
        x = MARGEN + (i % 3) * 6.15
        y = 2.5 + (i // 3) * 4.15
        caja = s.shapes.add_shape(1, Inches(x), Inches(y), Inches(5.85), Inches(3.9))
        caja.fill.solid()
        caja.fill.fore_color.rgb = rgb(CAJA)
        caja.line.fill.background()
        caja.shadow.inherit = False
        caja_texto(s, x + 0.25, y + 0.2, 5.35, 3.6, [
            (tema, {"negrita": True, "tam": 24, "espacio": 2}),
            (f"{epoca} del corte · {doc}", {"tam": 17, "color": GRIS, "espacio": 8}),
            (f"«{recortar(texto, clave)}»", {"tam": 20, "cursiva": True}),
        ])
    nota_apendice(s, d08 / "conjunto_fragmentos_temas.png",
                  "cada tarjeta es una cita textual de la época en que el tema es más frecuente; las tarjetas de arriba "
                  "son de después del corte y las de abajo de antes. Fuentes: conjunto_fragmentos_anclas.csv, "
                  "conjunto_fragmentos_temas.csv y conjunto_palabras_seleccion_fragmentos.csv.")


def apendice_macro(periodos, titulo_txt):
    ruta = TAB / "07_graficas_macro" / "macro_descriptiva.csv"
    d = leer(ruta)
    d = d[d.periodo.isin(periodos)]
    filas = [["Periodo", "Brent medio (USD por barril)", "TRM media (pesos por dólar)", "Inflación media (%)",
              "Meses fuera del rango meta (%)"]]
    destacar = []
    for _, r in d.iterrows():
        if r.periodo in ("P3", "P4", "P10"):
            destacar.append(len(filas))
        anios = r.inicio[:4] if r.inicio[:4] == r.fin[:4] else f"{r.inicio[:4]}–{r.fin[2:4]}"
        filas.append([f"{r.periodo} {r['nombre']} ({anios})", num(r.brent_media),
                      num(r.trm_media, 0), num(r.inf_media), num(r.fuera_rango, 0)])
    s = nueva()
    titulo_apendice(s, titulo_txt(d))
    tabla(s, MARGEN, 2.5, [6.6, 2.9, 2.9, 2.9, 2.9], filas, tam=22, destacar=destacar, alto_fila=1.0)
    caja_texto(s, MARGEN, 9.9, ANCHO - 2 * MARGEN, 1.0, [
        "Promedios mensuales de cada periodo de política monetaria; en negrita, P3, P4 (choque petrolero) y P10 "
        "(2026). Fuentes: FRED (Brent), Banco de la República (TRM, meta), DANE (inflación)."], tam=17, color=GRIS)
    nota_apendice(s, TAB / "07_graficas_macro" / "macro_descriptiva.png",
                  "cada fila es un periodo de política monetaria abierto por un cambio de dirección de la tasa; la "
                  "tabla completa trae también mínimos, máximos, variaciones y la brecha frente a la meta.")


def titulo_macro_1(d):
    p3, p4 = d.set_index("periodo").loc["P3"], d.set_index("periodo").loc["P4"]
    return (f"En el choque (P4) el Brent bajó de {num(p3.brent_media, 0)} a {num(p4.brent_media, 0)} dólares y "
            f"la inflación media subió de {num(p3.inf_media)} % a {num(p4.inf_media)} %")


def titulo_macro_2(d):
    p10 = d.set_index("periodo").loc["P10"]
    fuera = "en todos los meses" if p10.fuera_rango == 100 else f"el {num(p10.fuera_rango, 0)} % de los meses"
    return (f"En 2026 (P10) la inflación media es {num(p10.inf_media)} % y está fuera del rango meta {fuera}, "
            f"con el Brent en {num(p10.brent_media, 0)} dólares")


apendice = [
    apendice_cortes,
    apendice_documentos,
    apendice_seleccion,
    apendice_topicos,
    apendice_diccionario,
    apendice_robustez,
    apendice_fragmentos,
    ("A6. Peso de los tópicos 6 a 10 por reunión, 2007 a 2019", FIG / "09_lda_oraciones" / "conjunto_lda_theta_por_reunion_topicos_6_10.png"),
    lambda: apendice_macro(["P1", "P2", "P3", "P4", "P5"], titulo_macro_1),
    lambda: apendice_macro(["P6", "P7", "P8", "P9", "P10"], titulo_macro_2),
    ("A8. Palabras que acompañan a «inflación» en las minutas", D11 / "minutas_correlaciones_inflacion.png"),
    ("A8. Palabras que más ganan y más pierden peso", D11 / "conjunto_palabras_10_10.png"),
    ("A9. Vecinos de cada palabra ancla antes y después del corte (GloVe, con Word2Vec como robustez)",
     TAB / "10_glove" / "conjunto_glove_vecinos.png"),
]
for elemento in apendice:
    if callable(elemento):
        elemento()
        continue
    t, ruta = elemento
    s = nueva()
    caja_texto(s, MARGEN, 0.45, ANCHO - 2 * MARGEN, 1.0, [t], tam=32, fuente=TITULO_FUENTE)
    imagen(s, ruta, MARGEN, 1.6, ANCHO - 2 * MARGEN, 9.25)
    notas(s, "—", "—", "Apéndice.", f"Fuente: {ruta.relative_to(RAIZ).as_posix()}", "—")

# --- guion en las notas del orador -----------------------------------------------------------
# el texto que se lee en voz alta vive en guion_presentacion.txt; aquí se antepone a las notas
guion = (RAIZ / "04_Presentaciones" / "guion_presentacion.txt").read_text(encoding="utf-8")
patron = (r"DIAPOSITIVA (\d+) · .*?\n(Presentador: .*?)\nTEXTO\n(.*?)\nSEÑALAR\n(.*?)\n"
          r"TRANSICIÓN\n(.*?)\n\n")
bloques_guion = re.findall(patron, guion, re.S)
assert len(bloques_guion) == 13, "el guion debe tener las 13 diapositivas principales"
for n, cab, texto, senalar, trans in bloques_guion:
    tf = prs.slides[int(n) - 1].notes_slide.notes_text_frame
    previas = tf.text.split("\n\n", 1)[1]  # sin la línea de presentador y duración del generador
    tf.text = (f"{cab}\n\nGUION\n{' '.join(texto.split())}\n\nSEÑALAR\n{' '.join(senalar.split())}"
               f"\n\nTRANSICIÓN\n{' '.join(trans.split())}\n\n{previas}")

prs.save(SALIDA)
print("Guardado:", SALIDA, "-", len(prs.slides), "diapositivas")
