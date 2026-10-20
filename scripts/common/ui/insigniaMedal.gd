extends Control
# Medalla de insignia dibujada por código: disco de oro/plata/bronce con una
# carita de gatito estilo doodle (trazo temblorosito, hecho a mano).
#   tier:   0 = bronce, 1 = plata, 2 = oro
#   face:   0 = sonrisa, 1 = guiño (+ brillito), 2 = corona
#   locked: true = medalla gris con "?" (aún no se consigue)

const INK := Color("#3B2A20")
const FUR := Color("#FFF4DF")
const PINK := Color("#FF9EB5")
const RIBBON := Color("#E0566E")

const TIER_COLORS := {
	0: {"rim": Color("#8C5A2B"), "disc": Color("#CD7F32"), "light": Color("#EDAE70")},
	1: {"rim": Color("#6F7C89"), "disc": Color("#C0C8D0"), "light": Color("#F1F5F9")},
	2: {"rim": Color("#B8860B"), "disc": Color("#FFC93C"), "light": Color("#FFE98A")},
}
const LOCKED_COLORS := {"rim": Color("#40454D"), "disc": Color("#6B717B"), "light": Color("#8D939D")}

var tier: int = 0:
	set(value):
		tier = value
		queue_redraw()
var face: int = 0:
	set(value):
		face = value
		queue_redraw()
var locked: bool = false:
	set(value):
		locked = value
		queue_redraw()

func _init() -> void:
	custom_minimum_size = Vector2(96, 96)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	var s: float = minf(size.x, size.y) / 100.0
	if s <= 0.0:
		return
	draw_set_transform((size - Vector2(100, 100) * s) * 0.5, 0.0, Vector2(s, s))
	var pal: Dictionary = LOCKED_COLORS if locked else TIER_COLORS[clampi(tier, 0, 2)]
	var center := Vector2(50, 44)

	# Cintas (detrás del disco)
	var ribbonColor: Color = Color("#4B5058") if locked else RIBBON
	for side in [0, 1]:
		var pts := PackedVector2Array([Vector2(30, 66), Vector2(48, 78), Vector2(38, 99), Vector2(31, 90), Vector2(22, 95)])
		if side == 1:
			for i in pts.size():
				pts[i].x = 100.0 - pts[i].x
		draw_colored_polygon(pts, ribbonColor)
		var outline := PackedVector2Array(pts)
		outline.append(pts[0])
		draw_polyline(outline, INK, 2.0, true)

	# Disco
	draw_circle(center + Vector2(0, 2.5), 41.0, Color(0, 0, 0, 0.25))
	draw_circle(center, 40.0, pal["rim"])
	draw_circle(center, 35.0, pal["disc"])
	draw_arc(center, 30.0, deg_to_rad(195), deg_to_rad(285), 18, pal["light"], 3.0, true)
	draw_arc(center, 35.5, 0.0, TAU, 56, Color(0, 0, 0, 0.25), 1.2, true)
	draw_arc(center, 40.5, 0.0, TAU, 56, INK, 2.2, true)

	if locked:
		var font: Font = get_theme_default_font()
		draw_string(font, Vector2(0, 62), "?", HORIZONTAL_ALIGNMENT_CENTER, 100.0, 46, Color("#2B2F36"))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return

	_drawCatFace()
	if face == 1:
		_drawSparkle(Vector2(76, 21), 8.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _line(points: Array, width: float = 2.2) -> void:
	draw_polyline(PackedVector2Array(points), INK, width, true)

func _drawCatFace() -> void:
	# Orejas
	var earL := PackedVector2Array([Vector2(27, 40), Vector2(26, 16), Vector2(44, 29)])
	var earR := PackedVector2Array([Vector2(73, 40), Vector2(74, 16), Vector2(56, 29)])
	draw_colored_polygon(earL, FUR)
	draw_colored_polygon(earR, FUR)
	draw_colored_polygon(PackedVector2Array([Vector2(30, 33), Vector2(30, 23), Vector2(39, 29)]), PINK)
	draw_colored_polygon(PackedVector2Array([Vector2(70, 33), Vector2(70, 23), Vector2(61, 29)]), PINK)
	_line([earL[0], earL[1], earL[2]])
	_line([earR[0], earR[1], earR[2]])

	# Cabeza (óvalo temblorosito, como dibujado a mano)
	var head := PackedVector2Array()
	var count := 30
	for i in count:
		var a: float = TAU * float(i) / float(count)
		var wob: float = 1.0 + 0.035 * sin(a * 3.0 + 1.3) + 0.02 * sin(a * 5.0 + 0.4)
		head.append(Vector2(50.0 + cos(a) * 25.0 * wob, 47.0 + sin(a) * 21.0 * wob))
	draw_colored_polygon(head, FUR)
	var headLine := PackedVector2Array(head)
	headLine.append(head[0])
	draw_polyline(headLine, INK, 2.4, true)

	# Ojos
	match face:
		0:
			_drawEye(Vector2(41, 45))
			_drawEye(Vector2(59, 45))
		1:
			_drawEye(Vector2(41, 45))
			_line([Vector2(55, 47), Vector2(59, 42), Vector2(63, 47)])
		_:
			_line([Vector2(37, 47), Vector2(41, 42), Vector2(45, 47)])
			_line([Vector2(55, 47), Vector2(59, 42), Vector2(63, 47)])

	# Cachetes, nariz, boquita "w" y bigotes
	draw_circle(Vector2(35, 54), 3.4, Color(PINK, 0.5))
	draw_circle(Vector2(65, 54), 3.4, Color(PINK, 0.5))
	draw_colored_polygon(PackedVector2Array([Vector2(47.5, 51.5), Vector2(52.5, 51.5), Vector2(50, 55)]), PINK)
	_line([Vector2(47.5, 51.5), Vector2(52.5, 51.5), Vector2(50, 55), Vector2(47.5, 51.5)], 1.2)
	draw_arc(Vector2(46.6, 56.0), 3.4, 0.0, PI, 8, INK, 1.8, true)
	draw_arc(Vector2(53.4, 56.0), 3.4, 0.0, PI, 8, INK, 1.8, true)
	for dir in [-1.0, 1.0]:
		_line([Vector2(50.0 + dir * 13.0, 53.0), Vector2(50.0 + dir * 28.0, 49.5)], 1.4)
		_line([Vector2(50.0 + dir * 13.0, 56.0), Vector2(50.0 + dir * 29.0, 57.0)], 1.4)
		_line([Vector2(50.0 + dir * 12.5, 59.0), Vector2(50.0 + dir * 26.0, 64.0)], 1.4)

	# Coronita para el oro
	if face == 2:
		var crown := PackedVector2Array([Vector2(40, 30), Vector2(41, 15), Vector2(46, 22), Vector2(50, 12), Vector2(54, 22), Vector2(59, 15), Vector2(60, 30)])
		draw_colored_polygon(crown, Color("#FFE066"))
		var crownLine := PackedVector2Array(crown)
		crownLine.append(crown[0])
		draw_polyline(crownLine, INK, 2.0, true)
		for tip in [Vector2(41, 15), Vector2(50, 12), Vector2(59, 15)]:
			draw_circle(tip, 2.0, RIBBON)

func _drawEye(pos: Vector2) -> void:
	draw_circle(pos, 3.3, INK)
	draw_circle(pos + Vector2(1.0, -1.1), 1.1, Color.WHITE)

func _drawSparkle(pos: Vector2, r: float) -> void:
	var star := PackedVector2Array([
		pos + Vector2(0, -r), pos + Vector2(r * 0.28, -r * 0.28),
		pos + Vector2(r, 0), pos + Vector2(r * 0.28, r * 0.28),
		pos + Vector2(0, r), pos + Vector2(-r * 0.28, r * 0.28),
		pos + Vector2(-r, 0), pos + Vector2(-r * 0.28, -r * 0.28),
	])
	draw_colored_polygon(star, Color.WHITE)
	var line := PackedVector2Array(star)
	line.append(star[0])
	draw_polyline(line, INK, 1.4, true)
