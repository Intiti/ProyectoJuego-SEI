extends Control

# Fondo de bosque sin arboles: degradado, rayos de luz, niebla y luciernagas.
# Todo se dibuja por codigo, no usa imagenes.

const FIREFLY_COUNT := 28
const SHAFT_COUNT := 5
const MIST_COUNT := 6
const SOFT_STEPS := 16

var timeAcc: float = 0.0
var fireflies: Array = []
var shafts: Array = []
var mists: Array = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_buildFireflies()
	_buildShafts()
	_buildMists()

func _process(delta: float) -> void:
	timeAcc += delta
	queue_redraw()

# Posiciones normalizadas, se escalan al tamano de pantalla al dibujar
func _buildFireflies() -> void:
	for i in FIREFLY_COUNT:
		fireflies.append({
			"base": Vector2(randf(), randf_range(0.25, 0.95)),
			"phase": randf() * TAU,
			"blinkSpeed": randf_range(0.6, 1.4),
			"driftSpeed": Vector2(randf_range(0.2, 0.6), randf_range(0.2, 0.5)),
			"driftRange": Vector2(randf_range(15.0, 45.0), randf_range(10.0, 30.0)),
			"radius": randf_range(1.6, 2.8)
		})

func _buildShafts() -> void:
	for i in SHAFT_COUNT:
		shafts.append({
			"x": (float(i) + randf_range(0.1, 0.9)) / float(SHAFT_COUNT),
			"width": randf_range(0.04, 0.09),
			"phase": randf() * TAU,
			"speed": randf_range(0.2, 0.5)
		})

func _buildMists() -> void:
	for i in MIST_COUNT:
		var dir: float = 1.0 if randf() > 0.5 else -1.0
		mists.append({
			"y": randf_range(0.45, 0.95),
			"speed": randf_range(8.0, 22.0) * dir,
			"offset": randf() * 2000.0,
			"radius": randf_range(180.0, 320.0)
		})

func _draw() -> void:
	_drawGradient()
	_drawShafts()
	_drawMist()
	_drawFireflies()
	_drawVignette()

# Degradado vertical en dos tramos
func _drawGradient() -> void:
	var top := Color(0.02, 0.09, 0.09)
	var mid := Color(0.05, 0.20, 0.15)
	var bottom := Color(0.02, 0.07, 0.05)
	_drawVBand(0.0, size.y * 0.55, top, mid)
	_drawVBand(size.y * 0.55, size.y, mid, bottom)

func _drawVBand(y1: float, y2: float, c1: Color, c2: Color) -> void:
	var pts := PackedVector2Array([
		Vector2(0, y1), Vector2(size.x, y1),
		Vector2(size.x, y2), Vector2(0, y2)
	])
	draw_polygon(pts, PackedColorArray([c1, c1, c2, c2]))

# Rayos de luz inclinados que se desvanecen hacia abajo
func _drawShafts() -> void:
	for s in shafts:
		var sway: float = sin(timeAcc * float(s.speed) + float(s.phase))
		var alpha: float = 0.07 + 0.04 * sway
		var x: float = size.x * float(s.x) + sway * 20.0
		var halfW: float = size.x * float(s.width)
		var slant: float = size.y * 0.35
		var topCol := Color(0.85, 1.0, 0.7, alpha)
		var botCol := Color(0.85, 1.0, 0.7, 0.0)
		var pts := PackedVector2Array([
			Vector2(x - halfW * 0.4, 0.0), Vector2(x + halfW * 0.4, 0.0),
			Vector2(x + halfW + slant, size.y), Vector2(x - halfW + slant, size.y)
		])
		draw_polygon(pts, PackedColorArray([topCol, topCol, botCol, botCol]))

# Manchas alargadas de niebla que se deslizan despacio
func _drawMist() -> void:
	for m in mists:
		var span: float = size.x + 800.0
		var x: float = fposmod(float(m.offset) + timeAcc * float(m.speed), span) - 400.0
		var y: float = size.y * float(m.y) + sin(timeAcc * 0.2 + float(m.offset)) * 12.0
		_softBlob(Vector2(x, y), float(m.radius), Vector2(2.4, 0.5), Color(0.55, 0.85, 0.7, 0.16))

func _drawFireflies() -> void:
	for f in fireflies:
		var blink: float = pow(maxf(sin(timeAcc * float(f.blinkSpeed) + float(f.phase)), 0.0), 2.0)
		if blink <= 0.01:
			continue
		var base: Vector2 = f.base
		var speed: Vector2 = f.driftSpeed
		var drift: Vector2 = f.driftRange
		var pos := Vector2(
			size.x * base.x + sin(timeAcc * speed.x + float(f.phase)) * drift.x,
			size.y * base.y + cos(timeAcc * speed.y + float(f.phase)) * drift.y
		)
		var r: float = f.radius
		_softBlob(pos, r * 5.0, Vector2.ONE, Color(0.8, 1.0, 0.4, 0.25 * blink))
		draw_circle(pos, r, Color(1.0, 1.0, 0.7, 0.9 * blink))

# Circulos concentricos simulan un borde suave, color.a es la opacidad en el centro
func _softBlob(center: Vector2, radius: float, squash: Vector2, color: Color) -> void:
	draw_set_transform(center, 0.0, squash)
	var layer := Color(color.r, color.g, color.b, color.a / float(SOFT_STEPS))
	for i in SOFT_STEPS:
		draw_circle(Vector2.ZERO, radius * (1.0 - float(i) / float(SOFT_STEPS)), layer)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# Bordes oscuros para enfocar el centro
func _drawVignette() -> void:
	var edge := Color(0.0, 0.03, 0.03, 0.55)
	var clear := Color(0.0, 0.03, 0.03, 0.0)
	var w: float = size.x
	var h: float = size.y
	var bx: float = w * 0.22
	var by: float = h * 0.25
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(bx, 0), Vector2(bx, h), Vector2(0, h)]),
		PackedColorArray([edge, clear, clear, edge]))
	draw_polygon(PackedVector2Array([Vector2(w, 0), Vector2(w - bx, 0), Vector2(w - bx, h), Vector2(w, h)]),
		PackedColorArray([edge, clear, clear, edge]))
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(w, 0), Vector2(w, by), Vector2(0, by)]),
		PackedColorArray([edge, edge, clear, clear]))
	draw_polygon(PackedVector2Array([Vector2(0, h), Vector2(w, h), Vector2(w, h - by), Vector2(0, h - by)]),
		PackedColorArray([edge, edge, clear, clear]))
