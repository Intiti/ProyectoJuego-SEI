extends CanvasLayer

# ─────────────────────────────────────────────────────────────────────────────
#  ScoreHud — cuadrito colorido "SCORE" en la esquina superior izquierda.
#  Muestra GameData.gatopuntos y se actualiza solo (con animación de conteo)
#  cuando cambian los puntos.
#
#  Uso (una línea en el _ready() de cada escena):
#      const ScoreHudScript = preload("res://scripts/common/ui/scoreHud.gd")
#      ...
#      add_child(ScoreHudScript.new())
#
#  Colores: cambia las constantes COLOR_* de abajo.
# ─────────────────────────────────────────────────────────────────────────────

const FONT_PATH := "res://assets/fonts/MotionControl-Bold.otf"

const COLOR_BORDER := Color(0.10, 0.08, 0.16, 1)   # marco oscuro
const COLOR_HEADER := Color(1.00, 0.30, 0.55, 1)   # franja "SCORE" (rosado fuerte)
const COLOR_BODY   := Color(1.00, 0.85, 0.25, 1)   # fondo del número (amarillo)
const COLOR_VALUE  := Color(0.16, 0.10, 0.22, 1)   # número

const MARGIN := Vector2(16, 16)

var _font: Font = null
var _box: PanelContainer
var _valueLabel: Label
var _shown: int = 0            # número que se ve en pantalla ahora
var _target: int = 0           # puntaje real
var _countTween: Tween = null
var _popTween: Tween = null

func _ready() -> void:
	layer = 1
	_font = load(FONT_PATH)
	_build()
	_shown = GameData.gatopuntos
	_target = _shown
	_valueLabel.text = str(_shown)
	GameData.gatopuntosChanged.connect(_onScoreChanged)
	# Que quede DETRÁS del diálogo y del puzzle (misma capa, se dibuja primero)
	call_deferred("_sendToBack")

func _sendToBack() -> void:
	var p := get_parent()
	if p:
		p.move_child(self, 0)

# ── Construcción ──────────────────────────────────────────────────────────────

func _makeLabel(txt: String, size: int, color: Color, outline: int) -> Label:
	var l := Label.new()
	l.text = txt
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _font:
		l.add_theme_font_override("font", _font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if outline > 0:
		l.add_theme_color_override("font_outline_color", COLOR_BORDER)
		l.add_theme_constant_override("outline_size", outline)
	return l

func _build() -> void:
	_box = PanelContainer.new()
	_box.position = MARGIN
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var outer := StyleBoxFlat.new()
	outer.bg_color = COLOR_BORDER
	outer.set_corner_radius_all(12)
	outer.set_content_margin_all(4)
	outer.shadow_color = Color(0, 0, 0, 0.35)
	outer.shadow_size = 6
	outer.shadow_offset = Vector2(0, 3)
	_box.add_theme_stylebox_override("panel", outer)
	add_child(_box)
	_box.resized.connect(func(): _box.pivot_offset = _box.size / 2.0)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_box.add_child(vbox)

	# Franja de arriba: "SCORE"
	var header := PanelContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hs := StyleBoxFlat.new()
	hs.bg_color = COLOR_HEADER
	hs.corner_radius_top_left = 8
	hs.corner_radius_top_right = 8
	hs.content_margin_left = 20
	hs.content_margin_right = 20
	hs.content_margin_top = 3
	hs.content_margin_bottom = 3
	header.add_theme_stylebox_override("panel", hs)
	vbox.add_child(header)
	header.add_child(_makeLabel("SCORE", 20, Color(1, 1, 1, 1), 6))

	# Cuerpo: el número
	var body := PanelContainer.new()
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.custom_minimum_size = Vector2(120, 0)
	var bs := StyleBoxFlat.new()
	bs.bg_color = COLOR_BODY
	bs.corner_radius_bottom_left = 8
	bs.corner_radius_bottom_right = 8
	bs.content_margin_left = 20
	bs.content_margin_right = 20
	bs.content_margin_top = 2
	bs.content_margin_bottom = 4
	body.add_theme_stylebox_override("panel", bs)
	vbox.add_child(body)
	_valueLabel = _makeLabel("0", 34, COLOR_VALUE, 0)
	body.add_child(_valueLabel)

# ── Actualización ─────────────────────────────────────────────────────────────
# Si hay un puzzle abierto (la pantalla lo tapa todo), esperamos a que se cierre
# para mostrar la animación y que el jugador sí la vea.

func _onScoreChanged(newValue: int) -> void:
	_target = newValue

func _process(_delta: float) -> void:
	if _target == _shown:
		return
	if _puzzleOpen():
		return
	_animateTo(_target)

func _puzzleOpen() -> bool:
	var pz = get_tree().get_first_node_in_group("puzzle")
	return pz != null and pz.get("isOpen") == true

func _animateTo(value: int) -> void:
	if _countTween and _countTween.is_valid():
		_countTween.kill()
	var start := _shown
	_shown = value   # evita relanzar la animación en el siguiente frame
	_countTween = create_tween()
	_countTween.tween_method(_setShownText, float(start), float(value), 0.8) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if value > start:
		_pop()

func _setShownText(v: float) -> void:
	_valueLabel.text = str(int(round(v)))

func _pop() -> void:
	if _popTween and _popTween.is_valid():
		_popTween.kill()
	_box.scale = Vector2.ONE
	_popTween = create_tween()
	_popTween.tween_property(_box, "scale", Vector2(1.18, 1.18), 0.12).set_trans(Tween.TRANS_BACK)
	_popTween.tween_property(_box, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_SINE)
