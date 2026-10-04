extends Node2D

# Fondo dibujado a mano - cielo celeste, montanas, sol con :3 y bigotitos
# Dimensiones de la escena Main: 1152 x 648 aprox (ground en y=620)

const W := 1152.0
const H := 648.0
const GROUND_Y := 610.0

# Paleta paint
const SKY_TOP    : Color = Color(0.40, 0.75, 1.00)   # celeste cielo
const SKY_BOT    : Color = Color(0.65, 0.90, 1.00)   # celeste claro horizonte
const MOUNT1_COL : Color = Color(0.35, 0.58, 0.35)   # verde montana lejana
const MOUNT2_COL : Color = Color(0.27, 0.47, 0.27)   # verde oscuro montana cercana
const GROUND_COL : Color = Color(0.40, 0.65, 0.25)   # verde suelo
const SUN_COL    : Color = Color(1.00, 0.88, 0.20)   # amarillo sol
const SUN_OUTLINE: Color = Color(0.95, 0.70, 0.10)   # borde sol

func _draw():
	_drawSky()
	_drawMountains()
	_drawGround()
	_drawSun()

func _drawSky():
	# Gradiente cielo con bandas
	var bands := 24
	for i in bands:
		var t0 := float(i) / bands
		var t1 := float(i + 1) / bands
		var c0 : Color = SKY_TOP.lerp(SKY_BOT, t0)
		var c1 : Color = SKY_TOP.lerp(SKY_BOT, t1)
		var y0 := t0 * GROUND_Y
		var y1 := t1 * GROUND_Y
		# Color promedio de la banda
		var cAvg : Color = Color(
			(c0.r + c1.r) * 0.5,
			(c0.g + c1.g) * 0.5,
			(c0.b + c1.b) * 0.5
		)
		draw_colored_polygon(PackedVector2Array([
			Vector2(0, y0), Vector2(W, y0),
			Vector2(W, y1), Vector2(0, y1)
		]), cAvg)

func _drawMountains():
	# Montanas traseras (mas claras, mas altas)
	var m1 := PackedVector2Array([
		Vector2(0, GROUND_Y),
		Vector2(0, 380), Vector2(80, 280), Vector2(160, 380),
		Vector2(220, 300), Vector2(310, 200), Vector2(400, 310),
		Vector2(460, 240), Vector2(560, 160), Vector2(650, 250),
		Vector2(720, 190), Vector2(820, 300), Vector2(900, 220),
		Vector2(980, 310), Vector2(1060, 240), Vector2(1152, 330),
		Vector2(1152, GROUND_Y)
	])
	draw_colored_polygon(m1, MOUNT1_COL)

	# Montanas delanteras (mas oscuras, mas bajas)
	var m2 := PackedVector2Array([
		Vector2(0, GROUND_Y),
		Vector2(0, 460), Vector2(100, 370), Vector2(190, 450),
		Vector2(280, 380), Vector2(370, 460), Vector2(440, 390),
		Vector2(530, 480), Vector2(620, 400), Vector2(700, 470),
		Vector2(790, 390), Vector2(880, 460), Vector2(960, 400),
		Vector2(1050, 480), Vector2(1152, 410), Vector2(1152, GROUND_Y)
	])
	draw_colored_polygon(m2, MOUNT2_COL)

	# Nieve en picos de montanas traseras
	var picos := [
		Vector2(80, 280), Vector2(310, 200), Vector2(560, 160),
		Vector2(720, 190), Vector2(900, 220), Vector2(1060, 240)
	]
	var nieveCol : Color = Color(1, 1, 1, 0.9)
	for p in picos:
		var nieve := PackedVector2Array([
			p + Vector2(-22, 30), p, p + Vector2(22, 30)
		])
		draw_colored_polygon(nieve, nieveCol)

func _drawGround():
	# Franja de suelo verde
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, GROUND_Y - 10), Vector2(W, GROUND_Y - 10),
		Vector2(W, H), Vector2(0, H)
	]), GROUND_COL)

	# Pasto con puntas irregulares
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var pastoPts := PackedVector2Array([Vector2(0, GROUND_Y)])
	var x := 0.0
	while x <= W:
		var altura := rng.randf_range(4, 18)
		pastoPts.append(Vector2(x, GROUND_Y - altura))
		x += rng.randf_range(5, 14)
	pastoPts.append(Vector2(W, GROUND_Y))
	var grassCol : Color = Color(0.30, 0.55, 0.15)
	draw_colored_polygon(pastoPts, grassCol)

func _drawSun():
	var cx := 920.0
	var cy := 100.0
	var r  := 56.0

	# Rayos
	var rayCount := 12
	for i in rayCount:
		var angle := TAU * i / rayCount
		var inner := r + 8
		var outer := r + 28 + (12 if i % 2 == 0 else 0)
		var p1 := Vector2(cx + cos(angle) * inner, cy + sin(angle) * inner)
		var p2 := Vector2(cx + cos(angle) * outer, cy + sin(angle) * outer)
		draw_line(p1, p2, SUN_OUTLINE, 5.0, true)

	# Borde y circulo principal
	draw_circle(Vector2(cx, cy), r + 3, SUN_OUTLINE)
	draw_circle(Vector2(cx, cy), r, SUN_COL)

	_drawSunFace(cx, cy, r)

func _drawSunFace(cx: float, cy: float, r: float):
	var faceCol : Color = Color(0.60, 0.40, 0.05, 0.85)
	var thick := 3.2

	# Ojos: puntitos
	draw_circle(Vector2(cx - 16, cy - 10), 6.0, faceCol)
	draw_circle(Vector2(cx + 16, cy - 10), 6.0, faceCol)

	# Boca :3 - dos curvitas simetricas hacia abajo unidas en el centro
	_drawArc(cx - 9, cy + 14, 9, PI * 0.1, PI * 0.9, faceCol, thick)
	_drawArc(cx + 9, cy + 14, 9, PI * 0.1, PI * 0.9, faceCol, thick)

func _drawArc(cx: float, cy: float, rad: float, a_from: float, a_to: float, col: Color, width: float):
	var steps := 16
	var pts := PackedVector2Array()
	for i in steps + 1:
		var a : float = lerp(a_from, a_to, float(i) / steps)
		pts.append(Vector2(cx + cos(a) * rad, cy + sin(a) * rad))
	for i in pts.size() - 1:
		draw_line(pts[i], pts[i + 1], col, width, true)
