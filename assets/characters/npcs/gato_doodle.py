"""
Generador de gatos doodle (mismo estilo que gato_sin_fondo.png).
Usa la base de contorno negro y le cambia el color del pelaje y le dibuja accesorios.
Uso:  python3 gato_doodle.py base.png salida.png
"""
import sys, math, random
from PIL import Image, ImageDraw

SS = 8                      # supersampling para trazos suaves
OUTLINE = (30, 30, 34, 255)  # color del contorno (igual al de la base)
LINE_W = 3.1                 # grosor del contorno en px del sprite final

def recolor(base, fur):
    """Cambia el blanco del pelaje por `fur` conservando contorno, rayas y bordes suavizados."""
    px = base.load()
    out = base.copy(); op = out.load()
    for y in range(base.height):
        for x in range(base.width):
            r, g, b, a = px[x, y]
            if a == 0: continue
            L = (r + g + b) / 3.0
            t = max(0.0, min(1.0, (L - 40) / (245 - 40)))
            nr = OUTLINE[0] + (fur[0] - OUTLINE[0]) * t
            ng = OUTLINE[1] + (fur[1] - OUTLINE[1]) * t
            nb = OUTLINE[2] + (fur[2] - OUTLINE[2]) * t
            op[x, y] = (int(nr), int(ng), int(nb), a)
    return out

class Pen:
    def __init__(self, size, seed=3):
        self.im = Image.new('RGBA', (size[0]*SS, size[1]*SS), (0, 0, 0, 0))
        self.d = ImageDraw.Draw(self.im)
        self.rnd = random.Random(seed)
    def P(self, x, y):  # punto con temblor mínimo "a mano alzada"
        j = 0.35
        return ((x + self.rnd.uniform(-j, j)) * SS, (y + self.rnd.uniform(-j, j)) * SS)
    def stroke(self, pts, w=LINE_W, color=OUTLINE, closed=False, wobble=True):
        P = [self.P(*p) if wobble else (p[0]*SS, p[1]*SS) for p in pts]
        if closed: P = P + [P[0]]
        W = w * SS
        self.d.line(P, fill=color, width=int(W), joint='curve')
        for (x, y) in P:
            self.d.ellipse([x-W/2, y-W/2, x+W/2, y+W/2], fill=color)
    def poly(self, pts, fill, outline=True, w=LINE_W, wobble=True):
        P = [self.P(*p) if wobble else (p[0]*SS, p[1]*SS) for p in pts]
        self.d.polygon(P, fill=fill)
        if outline:
            self.stroke([(x/SS, y/SS) for x, y in P], w=w, closed=True, wobble=False)
    def ellipse(self, cx, cy, rx, ry, fill=None, outline=True, w=LINE_W, color=OUTLINE):
        pts = [(cx + rx*math.cos(a), cy + ry*math.sin(a)) for a in [i*2*math.pi/48 for i in range(48)]]
        if fill: self.d.polygon([(x*SS, y*SS) for x, y in pts], fill=fill)
        if outline: self.stroke(pts, w=w, color=color, closed=True)

def rot(pts, ang_deg, cx, cy):
    a = math.radians(ang_deg); c, s = math.cos(a), math.sin(a)
    return [(cx + (x-cx)*c - (y-cy)*s, cy + (x-cx)*s + (y-cy)*c) for x, y in pts]

def bezier(p0, p1, p2, n=24):
    return [((1-t)**2*p0[0] + 2*(1-t)*t*p1[0] + t*t*p2[0], (1-t)**2*p0[1] + 2*(1-t)*t*p1[1] + t*t*p2[1])
            for t in [i/(n-1) for i in range(n)]]

def alcalde(base_path, out_path, fur=(184, 198, 222)):
    base = Image.open(base_path).convert('RGBA')
    cat = recolor(base, fur)
    pen = Pen(base.size)

    # ---- Chistera (centrada entre las orejas, ladeada) ----
    HX, HY, TILT = 47, 57, -7
    HAT = (46, 46, 58, 255)
    # copa
    crown = [(-16, 0), (-14.5, -40), (14.5, -40), (16, 0)]
    crown = [(HX+x, HY+y) for x, y in crown]
    crown = rot(crown, TILT, HX, HY)
    pen.poly(crown, HAT)
    # tapa superior
    top = [(HX + 14.5*math.cos(a), HY - 40 + 3.2*math.sin(a)) for a in [i*2*math.pi/36 for i in range(36)]]
    pen.poly(rot(top, TILT, HX, HY), (78, 78, 92, 255))
    # cinta roja
    band = [(-15.6, -5), (-15.2, -13), (15.2, -13), (15.6, -5)]
    band = rot([(HX+x, HY+y) for x, y in band], TILT, HX, HY)
    pen.poly(band, (205, 45, 55, 255), w=2.2)
    # brillo
    shine = rot([(HX-9, HY-34), (HX-9.4, HY-17)], TILT, HX, HY)
    pen.stroke(shine, w=1.6, color=(150, 150, 170, 255))
    # ala
    brim = [(HX + 25*math.cos(a), HY + 4.6*math.sin(a)) for a in [i*2*math.pi/48 for i in range(48)]]
    pen.poly(rot(brim, TILT, HX, HY), HAT)

    # ---- Monóculo en el ojo derecho + cadena ----
    ex, ey = 53, 74
    pen.ellipse(ex, ey, 9.2, 9.2, fill=(220, 240, 255, 28), w=5.2)          # borde oscuro
    pen.ellipse(ex, ey, 9.2, 9.2, fill=None, w=2.6, color=(236, 186, 48, 255))  # aro dorado
    pen.stroke([(ex-4, ey-5.5), (ex-6.2, ey-2)], w=1.3, color=(255, 255, 255, 235), wobble=False)  # reflejo
    chain = bezier((ex+6.5, ey+6.5), (ex+17, ey+22), (57, 104))
    pen.stroke(chain, w=1.7, color=(200, 150, 30, 255), wobble=False)

    # ---- Corbatín ----
    bx, by = 46, 107
    RED = (205, 45, 55, 255)
    pen.poly([(bx, by), (bx-15, by-8), (bx-14, by+8)], RED, w=2.4)
    pen.poly([(bx, by), (bx+15, by-8), (bx+14, by+8)], RED, w=2.4)
    pen.ellipse(bx, by, 4.2, 5.2, fill=(170, 30, 42, 255), w=2.4)

    # ---- Medalla de alcalde ----
    mx, my = 46, 119
    BLUE = (40, 100, 205, 255)
    pen.poly([(bx-6, by+5), (bx-1.5, by+6), (mx+2, my-1), (mx-5, my-3)], BLUE, w=1.8)
    pen.poly([(bx+6, by+5), (bx+1.5, by+6), (mx-2, my-1), (mx+5, my-3)], BLUE, w=1.8)
    pen.ellipse(mx, my+2, 6.4, 6.4, fill=(246, 196, 48, 255), w=2.4)
    pen.ellipse(mx, my+2, 3.0, 3.0, fill=(255, 226, 120, 255), outline=False)

    layer = pen.im.resize(base.size, Image.LANCZOS)
    final = cat.copy(); final.alpha_composite(layer)
    final.save(out_path)
    return final

if __name__ == '__main__':
    alcalde(sys.argv[1], sys.argv[2])
