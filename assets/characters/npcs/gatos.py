"""Gatos doodle del Nivel 1 (mismo estilo que gato_sin_fondo.png). Uso: python3 gatos.py <carpeta_npcs> <salida>"""
import sys, math, os
from PIL import Image, ImageFilter
sys.path.insert(0, os.path.dirname(__file__))
from gato_doodle import Pen, rot, bezier, OUTLINE, LINE_W, SS

def recolor(base, fur, outline=OUTLINE[:3], patches=(), interior=None):
    px = base.load(); out = base.copy(); op = out.load()
    eroded = base.getchannel('A').filter(ImageFilter.MinFilter(9)).load() if interior else None
    for y in range(base.height):
        for x in range(base.width):
            r, g, b, a = px[x, y]
            if a == 0: continue
            t = max(0.0, min(1.0, ((r+g+b)/3.0 - 40) / 205.0))
            fc = fur
            for (cx, cy, rx, ry, col) in patches:
                if ((x-cx)/rx)**2 + ((y-cy)/ry)**2 <= 1.0: fc = col
            c = [outline[i] + (fc[i]-outline[i])*t for i in range(3)]
            if interior and eroded[x, y] > 0 and t < 0.8:
                k = min(1.0, (0.8 - t) / 0.5)
                c = [c[i]*(1-k) + interior[i]*k for i in range(3)]
            op[x, y] = (int(c[0]), int(c[1]), int(c[2]), a)
    return out

def finish(cat, pen):
    f = cat.copy(); f.alpha_composite(pen.im.resize(cat.size, Image.LANCZOS)); return f

def flower(pen, cx, cy, petal=(255,226,80,255), center=(240,130,40,255), r=4.6):
    for i in range(5):
        a = math.radians(i*72 - 90)
        pen.ellipse(cx + 5.2*math.cos(a), cy + 5.2*math.sin(a), r, r*0.85, fill=petal, w=1.7)
    pen.ellipse(cx, cy, 3.6, 3.6, fill=center, w=1.7)

# ---------------- Alcalde Boris (ver gato_doodle.py) ----------------
def alcalde(base):
    from gato_doodle import alcalde as _a
    return None

# ---------------- Gato panadero (naranja + sombrero de paja) ----------------
def panadero(base):
    cat = recolor(base, (246, 164, 58), patches=[(24, 88, 4.5, 3, (255, 236, 215)), (62, 88, 4.5, 3, (255, 236, 215))])
    pen = Pen(base.size, seed=11)
    HX, HY, TILT = 46, 57, -6
    STRAW = (236, 206, 140, 255); STRAW_D = (196, 160, 90, 255)
    brim = [(HX + 28*math.cos(a), HY + 6.2*math.sin(a)) for a in [i*2*math.pi/48 for i in range(48)]]
    pen.poly(rot(brim, TILT, HX, HY), STRAW)
    crown = [(HX + 15.5*math.cos(a), HY - 1 - 17*math.sin(a)) for a in [i*math.pi/24 for i in range(25)]]
    pen.poly(rot(crown, TILT, HX, HY), STRAW)
    band = rot([(HX-15.4, HY-3), (HX-14.6, HY-10), (HX+14.6, HY-10), (HX+15.4, HY-3)], TILT, HX, HY)
    pen.poly(band, (205, 45, 55, 255), w=2.0)
    for k in (-9, -3, 3, 9):   # trenzado de la paja
        pen.stroke(rot([(HX+k, HY-12), (HX+k*1.15, HY-17)], TILT, HX, HY), w=1.2, color=STRAW_D)
    for k in (-18, -9, 0, 9, 18):
        pen.stroke(rot([(HX+k, HY+1.5), (HX+k*1.02, HY+4.6)], TILT, HX, HY), w=1.1, color=STRAW_D)
    return finish(cat, pen)

# ---------------- Don Plateado (gato viejo) ----------------
def plateado(base):
    cat = recolor(base, (166, 168, 178), patches=[(43, 88, 15, 10, (216, 217, 225))])
    pen = Pen(base.size, seed=21)
    WHITE = (244, 244, 248, 255)
    for ex in (33, 53):   # cejas pobladas y canosas
        s = 1 if ex == 33 else -1
        pen.poly([(ex-9, 66), (ex-6, 62.5), (ex-1, 61.5), (ex+5, 63), (ex+9, 66.5), (ex+3, 65.8), (ex-3, 65.6)], WHITE, w=1.6)
        pen.stroke([(ex-7, 63.5), (ex-10, 60.5)], w=1.3, color=OUTLINE)
        pen.stroke([(ex+6, 64), (ex+9.5, 61.5)], w=1.3, color=OUTLINE)
    # arrugas junto a los ojos
    for (x0, y0, dx) in ((21.5, 77, 1), (72.5, 77, -1)):
        pen.stroke([(x0, y0), (x0+3*dx, y0+2.2), (x0+6*dx, y0+2.8)], w=1.2, color=(70, 70, 80, 255))
        pen.stroke([(x0+0.5*dx, y0+4), (x0+3.4*dx, y0+5.5)], w=1.2, color=(70, 70, 80, 255))
    # anteojos redondos
    GL = (70, 70, 84, 255)
    for ex in (33, 53):
        pen.ellipse(ex, 74, 8.2, 8.2, fill=(220, 240, 255, 18), w=1.9, color=GL)
    pen.stroke([(41.2, 73), (43, 71.8), (44.8, 73)], w=1.8, color=GL, wobble=False)
    pen.stroke([(24.8, 73.5), (19.5, 70)], w=1.7, color=GL, wobble=False)
    # bufanda tejida
    SC = (150, 62, 70, 255); SC2 = (236, 214, 176, 255)
    pen.poly([(30, 99), (47, 105.5), (64, 99), (65, 108), (47, 114), (29, 108)], SC, w=2.4)
    for xs in (35, 42, 49, 56):
        pen.stroke([(xs, 101.5 + abs(xs-47)*0.1), (xs+0.8, 111.5 - abs(xs-47)*0.1)], w=1.8, color=SC2, wobble=False)
    pen.poly([(38, 110), (49, 111), (51, 135), (40, 137)], SC, w=2.4)
    for ys in (117, 124, 131):
        pen.stroke([(39, ys), (50.5, ys+0.6)], w=1.8, color=SC2, wobble=False)
    for xf in (41.5, 45, 48.5):
        pen.stroke([(xf, 136.5), (xf+0.3, 141)], w=1.4, color=SC, wobble=False)
    return finish(cat, pen)

# ---------------- Competidores (negro con bandana blanca + blanco con bandana negra) ----------------
def bandana(pen, color, side):
    top = bezier((19, 63), (47, 56.5), (76, 63.5), 30)
    bot = bezier((19, 70), (47, 63.5), (76, 70.5), 30)
    pen.poly(top + bot[::-1], color, w=2.0, wobble=False)
    kx = 76.5 if side == 'R' else 18.5
    d = 1 if side == 'R' else -1
    pen.poly([(kx, 66.5), (kx+d*12, 60), (kx+d*10, 66)], color, w=1.8)
    pen.poly([(kx, 66.5), (kx+d*12, 74), (kx+d*9, 68)], color, w=1.8)
    pen.ellipse(kx, 66.5, 3.2, 3.2, fill=color, w=1.8)

def competidores(base):
    # gato negro (atrás) con bandana BLANCA
    blk = recolor(base, (46, 46, 56), outline=(8, 8, 10), interior=(215, 215, 228))
    pen = Pen(base.size, seed=31)
    for ex in (33, 53):
        pen.ellipse(ex, 74, 3.0, 3.0, fill=(250, 214, 30, 255), outline=False)
    bandana(pen, (246, 246, 250, 255), 'L')
    blk = finish(blk, pen)
    # gato blanco (adelante) con bandana NEGRA
    wht = recolor(base, (252, 252, 252))
    pen2 = Pen(base.size, seed=32)
    bandana(pen2, (34, 34, 40, 255), 'R')
    wht = finish(wht, pen2)
    canvas = Image.new('RGBA', base.size, (0, 0, 0, 0))
    canvas.alpha_composite(blk)
    canvas.alpha_composite(wht, (22, 18))
    return canvas

# ---------------- Miette (gata francesa) ----------------
def miette(base):
    cat = recolor(base, (250, 230, 200), patches=[(25, 85, 5.5, 3.6, (248, 178, 178)), (62, 85, 5.5, 3.6, (248, 178, 178))])
    pen = Pen(base.size, seed=41)
    NAVY = (40, 56, 124, 255)
    # pestañas
    for ex, angs in ((33, (-128, -152)), (53, (-52, -28))):
        for ang in angs:
            a = math.radians(ang)
            x0, y0 = ex + 3.2*math.cos(a), 74 + 3.2*math.sin(a)
            pen.stroke([(x0, y0), (x0 + 4.4*math.cos(a), y0 + 4.4*math.sin(a))], w=1.4, wobble=False)
    pen.ellipse(60.5, 83.2, 0.9, 0.9, fill=OUTLINE, w=0.8)        # lunar
    # boina ladeada con rabito
    BX, BY, T = 47, 55, -14
    body = [(BX + 25*math.cos(a), BY - 3 + 9.5*math.sin(a) - 2.5*math.cos(a)) for a in [i*2*math.pi/48 for i in range(48)]]
    pen.poly(rot(body, T, BX, BY), NAVY)
    pen.poly(rot([(BX-1.6, BY-12.2), (BX+1.2, BY-17), (BX+3.2, BY-12.2)], T, BX, BY), NAVY, w=2.0)
    pen.stroke(rot([(BX-14, BY-5), (BX-6, BY-10)], T, BX, BY), w=1.5, color=(110, 126, 200, 255), wobble=False)
    pen.stroke(rot([(BX-21, BY+1.2), (BX+19, BY+3.4)], T, BX, BY), w=2.0, color=(26, 38, 92, 255), wobble=False)
    # pañuelo a rayas rojas y blancas
    RED = (205, 45, 55, 255); WH = (250, 250, 250, 255)
    pen.poly([(30, 99), (47, 105.5), (64, 99), (65, 108), (47, 114), (29, 108)], WH, w=2.4)
    for xs in (34, 41, 48, 55, 61):
        pen.stroke([(xs, 101.5 + abs(xs-47)*0.1), (xs+0.8, 111.5 - abs(xs-47)*0.1)], w=2.6, color=RED, wobble=False)
    pen.poly([(61, 106), (72, 112), (68, 123), (58, 114)], WH, w=2.2)
    pen.stroke([(63.5, 108), (60.5, 115)], w=2.2, color=RED, wobble=False)
    pen.stroke([(68, 110.5), (65, 119)], w=2.2, color=RED, wobble=False)
    return finish(cat, pen)

# ---------------- Rosalinda (gata rosada con flor en la oreja) ----------------
def rosalinda(base):
    cat = recolor(base, (248, 178, 200), patches=[(25, 85, 5.5, 3.6, (240, 118, 152)), (62, 85, 5.5, 3.6, (240, 118, 152))])
    pen = Pen(base.size, seed=51)
    pen.poly([(22, 63), (15, 66), (20, 70), (27, 62)], (92, 176, 84, 255), w=1.8)   # hojita
    flower(pen, 28, 55)
    return finish(cat, pen)

if __name__ == '__main__':
    npcs, out = sys.argv[1], sys.argv[2]
    base = Image.open(os.path.join(npcs, 'gato_sin_fondo.png')).convert('RGBA')
    from gato_doodle import alcalde as _alc
    os.makedirs(out, exist_ok=True)
    _alc(os.path.join(npcs, 'gato_sin_fondo.png'), os.path.join(out, 'alcalde.png'))
    for name, fn in (('gato_granjero', panadero), ('don_plateado', plateado), ('competidores', competidores),
                     ('miette', miette), ('rosalinda', rosalinda)):
        fn(base).save(os.path.join(out, name + '.png'))
    print("ok")
