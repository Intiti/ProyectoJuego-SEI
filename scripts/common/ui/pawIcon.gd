extends Control

# ─────────────────────────────────────────────────────────────────────────────
#  PawIcon — patita de gato dibujada con formas (no depende de la fuente ni de
#  emojis). Se usa como "vida" en el examen.
#
#      var paw = PawIconScript.new()
#      paw.alive = true      # rosada = vida disponible
#      paw.alive = false     # gris oscura = vida perdida
# ─────────────────────────────────────────────────────────────────────────────

const ICON_SIZE := 30.0

const COLOR_ALIVE   := Color(1.0, 0.55, 0.72, 1)
const COLOR_DEAD    := Color(0.30, 0.26, 0.28, 1)
const COLOR_OUTLINE := Color(0.05, 0.03, 0.05, 1)

var alive: bool = true:
	set(value):
		alive = value
		queue_redraw()

func _init() -> void:
	custom_minimum_size = Vector2(ICON_SIZE, ICON_SIZE)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	var fill := COLOR_ALIVE if alive else COLOR_DEAD
	# Almohadilla grande + 4 deditos. Primero todo en negro (contorno), luego el relleno.
	_drawPaw(COLOR_OUTLINE, 2.0)
	_drawPaw(fill, 0.0)

func _drawPaw(color: Color, grow: float) -> void:
	_ellipse(Vector2(15, 21), Vector2(8.5 + grow, 6.5 + grow), color)
	_ellipse(Vector2(5.5, 12.5), Vector2(3.0 + grow, 3.8 + grow), color)
	_ellipse(Vector2(11, 7), Vector2(3.0 + grow, 4.0 + grow), color)
	_ellipse(Vector2(19, 7), Vector2(3.0 + grow, 4.0 + grow), color)
	_ellipse(Vector2(24.5, 12.5), Vector2(3.0 + grow, 3.8 + grow), color)

func _ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var pts := PackedVector2Array()
	var steps := 20
	for i in steps:
		var a := TAU * float(i) / float(steps)
		pts.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(pts, color)
