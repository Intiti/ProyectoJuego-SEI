extends Node2D

# ─────────────────────────────────────────────────────────────────────────────
#  WorldPrompt — indicador flotante en el mundo para algo con lo que se puede
#  interactuar.
#
#  Dos estilos:
#    EXCLAIM → "!" rojo mientras el jugador está lejos; al acercarse se cambia
#              por una tecla [E] con la acción ("Hablar", "Interactuar").
#              Se usa para NPCs y objetos (pozo).
#    ARROW   → NO se ve de lejos. Al acercarse aparece una flecha ▼ apuntando
#              a la puerta + la tecla [E] + "Entrar". Se usa para edificios.
#
#  Uso (no usa class_name para no depender del escaneo del editor):
#      const WorldPromptScript = preload("res://scripts/common/ui/worldPrompt.gd")
#      var p = WorldPromptScript.new()
#      p.setup(WorldPromptScript.Marker.ARROW, "Entrar")   # ANTES de add_child
#      p.position = Vector2(478, 414)
#      add_child(p)
#      ...
#      p.setNear(true / false)     # según la distancia del jugador
#      p.queue_free()              # cuando ya no aplique
# ─────────────────────────────────────────────────────────────────────────────

enum Marker { EXCLAIM, ARROW }

const FONT_PATH := "res://assets/fonts/MotionControl-Bold.otf"
const CAP_SIZE  := 44.0

var markerType: int = Marker.EXCLAIM
var actionText: String = "Hablar"
var keyText: String = "E"

var _font: Font = null
var _body: Node2D
var _exclaim: Label
var _arrow: Node2D
var _cap: Node2D
var _near: bool = false
var _fadeTween: Tween = null

# Llamar antes de add_child()
func setup(type: int, action: String, key: String = "E") -> void:
	markerType = type
	actionText = action
	keyText = key

func _ready() -> void:
	z_index = 100
	z_as_relative = false
	_font = load(FONT_PATH)

	_body = Node2D.new()
	add_child(_body)

	if markerType == Marker.EXCLAIM:
		_buildExclaim()
		_buildCap(Vector2(0, 0), -52.0)
	else:
		_buildCap(Vector2(0, -34), -86.0)
		_buildArrow(Vector2(0, 10))

	_applyState(false)
	_startBob()

# ── Construcción ──────────────────────────────────────────────────────────────

func _makeLabel(txt: String, size: int, color: Color, outline: int) -> Label:
	var l := Label.new()
	l.text = txt
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if _font:
		l.add_theme_font_override("font", _font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	l.add_theme_constant_override("outline_size", outline)
	return l

func _buildExclaim() -> void:
	_exclaim = _makeLabel("!", 72, Color(1, 0.15, 0.15, 1), 10)
	_exclaim.size = Vector2(48, 90)
	_exclaim.position = Vector2(-24, -45)
	_body.add_child(_exclaim)

# Tecla [E] estilo "keycap" + texto de acción encima
func _buildCap(center: Vector2, textY: float) -> void:
	_cap = Node2D.new()
	_cap.position = center
	_body.add_child(_cap)

	var cap := Panel.new()
	cap.size = Vector2(CAP_SIZE, CAP_SIZE)
	cap.position = Vector2(-CAP_SIZE / 2.0, -CAP_SIZE / 2.0)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.96, 0.96, 0.96, 1)
	sb.border_color = Color(0.12, 0.12, 0.14, 1)
	sb.set_border_width_all(3)
	sb.border_width_bottom = 7   # "grosor" de la tecla
	sb.set_corner_radius_all(8)
	cap.add_theme_stylebox_override("panel", sb)
	_cap.add_child(cap)

	var keyLabel := _makeLabel(keyText, 28, Color(0.1, 0.1, 0.12, 1), 0)
	keyLabel.size = Vector2(CAP_SIZE, CAP_SIZE - 4)
	keyLabel.position = Vector2(-CAP_SIZE / 2.0, -CAP_SIZE / 2.0)
	_cap.add_child(keyLabel)

	var action := _makeLabel(actionText, 24, Color(1, 1, 1, 1), 8)
	action.size = Vector2(240, 32)
	action.position = Vector2(-120, textY - center.y - 16)
	_cap.add_child(action)

# Flecha ▼ dibujada con polígonos (no depende de que la fuente tenga el glifo)
func _buildArrow(center: Vector2) -> void:
	_arrow = Node2D.new()
	_arrow.position = center
	_body.add_child(_arrow)

	var outline := Polygon2D.new()
	outline.polygon = PackedVector2Array([Vector2(-22, -17), Vector2(22, -17), Vector2(0, 24)])
	outline.color = Color(0, 0, 0, 1)
	_arrow.add_child(outline)

	var fill := Polygon2D.new()
	fill.polygon = PackedVector2Array([Vector2(-15, -11), Vector2(15, -11), Vector2(0, 15)])
	fill.color = Color(1.0, 0.85, 0.2, 1)
	_arrow.add_child(fill)

func _startBob() -> void:
	var t := create_tween().set_loops()
	t.tween_property(_body, "position:y", -8.0, 0.5).set_trans(Tween.TRANS_SINE)
	t.tween_property(_body, "position:y", 0.0, 0.5).set_trans(Tween.TRANS_SINE)

# ── Estado cerca / lejos ──────────────────────────────────────────────────────

func setNear(near: bool) -> void:
	if near == _near:
		return
	_near = near
	_applyState(true)

func _applyState(animate: bool) -> void:
	if markerType == Marker.EXCLAIM:
		_exclaim.visible = not _near
		_cap.visible = _near
		if animate and _near:
			_cap.scale = Vector2(0.6, 0.6)
			create_tween().tween_property(_cap, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK)
	else:
		# ARROW: invisible de lejos, aparece con fade al acercarse
		if _fadeTween and _fadeTween.is_valid():
			_fadeTween.kill()
		if _near:
			_body.visible = true
			if animate:
				_body.modulate.a = 0.0
				_fadeTween = create_tween()
				_fadeTween.tween_property(_body, "modulate:a", 1.0, 0.18)
			else:
				_body.modulate.a = 1.0
		else:
			if animate:
				_fadeTween = create_tween()
				_fadeTween.tween_property(_body, "modulate:a", 0.0, 0.12)
				_fadeTween.tween_callback(func(): _body.visible = false)
			else:
				_body.visible = false
