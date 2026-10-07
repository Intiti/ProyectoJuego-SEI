extends Node2D

# ─────────────────────────────────────────────────────────────────────────────
#  ExitMarker — flecha ">>" parpadeante en el borde de la pantalla que le dice
#  al jugador "por aquí se pasa a la siguiente zona" (o "por aquí se sale").
#
#  Uso (no usa class_name):
#      const ExitMarkerScript = preload("res://scripts/common/ui/exitMarker.gd")
#      var m = ExitMarkerScript.new()
#      m.setup(ExitMarkerScript.Side.RIGHT, "Villa 2")        # ANTES de add_child
#      add_child(m)
#      # o empezar escondida (ej. hasta hablar con el alcalde):
#      m.setup(ExitMarkerScript.Side.RIGHT, "Villa 2", false)
#      ...
#      m.setActive(true)    # mostrar con animación
#
#  Se ubica sola en el borde indicado; si necesitas moverla, cambia EDGE_Y /
#  EDGE_INSET abajo.
# ─────────────────────────────────────────────────────────────────────────────

enum Side { LEFT, RIGHT }

const FONT_PATH  := "res://assets/fonts/MotionControl-Bold.otf"
const SCREEN_W   := 1152.0
const EDGE_INSET := 52.0     # distancia del centro de la flecha al borde de pantalla
const EDGE_Y     := 500.0    # altura de la flecha (un poco sobre la cabeza del jugador)
const LABEL_W    := 260.0

const COLOR_FILL    := Color(1.0, 0.85, 0.2, 1)
const COLOR_OUTLINE := Color(0, 0, 0, 1)

var side: int = Side.RIGHT
var labelText: String = ""

var _font: Font = null
var _body: Node2D
var _bobTween: Tween = null
var _fadeTween: Tween = null
var _active: bool = true

# Llamar antes de add_child()
func setup(sideValue: int, text: String = "", startActive: bool = true) -> void:
	side = sideValue
	labelText = text
	_active = startActive

func _ready() -> void:
	z_index = 100
	z_as_relative = false
	_font = load(FONT_PATH)

	var dir := 1.0 if side == Side.RIGHT else -1.0
	position = Vector2(SCREEN_W - EDGE_INSET if side == Side.RIGHT else EDGE_INSET, EDGE_Y)

	_body = Node2D.new()
	add_child(_body)

	# Dos chevrones ">>" (Line2D: borde negro grueso debajo, amarillo encima)
	for offsetX in [-14.0, 10.0]:
		_body.add_child(_makeChevron(Vector2(offsetX * dir, 0), dir, 20.0, COLOR_OUTLINE))
		_body.add_child(_makeChevron(Vector2(offsetX * dir, 0), dir, 10.0, COLOR_FILL))

	if labelText != "":
		_body.add_child(_makeText(dir))

	# Vaivén hacia el borde (invita a ir hacia allá)
	_bobTween = create_tween().set_loops()
	_bobTween.tween_property(_body, "position:x", 9.0 * dir, 0.45).set_trans(Tween.TRANS_SINE)
	_bobTween.tween_property(_body, "position:x", 0.0, 0.45).set_trans(Tween.TRANS_SINE)

	_applyState(false)

func _makeChevron(pos: Vector2, dir: float, width: float, color: Color) -> Line2D:
	var l := Line2D.new()
	l.position = pos
	l.points = PackedVector2Array([Vector2(-8 * dir, -20), Vector2(8 * dir, 0), Vector2(-8 * dir, 20)])
	l.width = width
	l.default_color = color
	l.joint_mode = Line2D.LINE_JOINT_ROUND
	l.begin_cap_mode = Line2D.LINE_CAP_ROUND
	l.end_cap_mode = Line2D.LINE_CAP_ROUND
	return l

func _makeText(dir: float) -> Label:
	var l := Label.new()
	l.text = labelText
	l.size = Vector2(LABEL_W, 36)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# El texto se alinea hacia el interior de la pantalla para que no se salga
	if side == Side.RIGHT:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		l.position = Vector2(34 - LABEL_W, -76)
	else:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		l.position = Vector2(-34, -76)
	if _font:
		l.add_theme_font_override("font", _font)
	l.add_theme_font_size_override("font_size", 26)
	l.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	l.add_theme_color_override("font_outline_color", COLOR_OUTLINE)
	l.add_theme_constant_override("outline_size", 9)
	return l

# ── Mostrar / ocultar ─────────────────────────────────────────────────────────

func setActive(on: bool) -> void:
	if on == _active:
		return
	_active = on
	_applyState(true)

func _applyState(animate: bool) -> void:
	if _fadeTween and _fadeTween.is_valid():
		_fadeTween.kill()
	if _active:
		visible = true
		if animate:
			modulate.a = 0.0
			scale = Vector2(0.6, 0.6)
			_fadeTween = create_tween().set_parallel(true)
			_fadeTween.tween_property(self, "modulate:a", 1.0, 0.2)
			_fadeTween.tween_property(self, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK)
		else:
			modulate.a = 1.0
	else:
		if animate:
			_fadeTween = create_tween()
			_fadeTween.tween_property(self, "modulate:a", 0.0, 0.15)
			_fadeTween.tween_callback(func(): visible = false)
		else:
			visible = false
