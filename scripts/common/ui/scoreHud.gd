extends CanvasLayer

# ─────────────────────────────────────────────────────────────────────────────
#  ScoreHud — cuadro arriba a la izquierda (un solo color, dos filas):
#
#      Puntaje Villa Miaulemana:      120
#      Problemas resueltos:          3/10
#
#  Está OCULTO hasta que el jugador resuelve el primer problema (el del
#  alcalde). Ahí aparece con una animación. Se actualiza solo.
#  Los valores van en una columna ANCHA alineada a la derecha (VALUE_WIDTH),
#  así el cuadro no cambia de tamaño cuando el puntaje crece.
#
#  Uso (una línea en el _ready() de cada escena):
#      const ScoreHudScript = preload("res://scripts/common/ui/scoreHud.gd")
#      ...
#      add_child(ScoreHudScript.new())
#
#  Colores y anchos: constantes de abajo.
# ─────────────────────────────────────────────────────────────────────────────

const FONT_PATH := "res://assets/fonts/MotionControl-Bold.otf"

const COLOR_FILL    := Color(0.20, 0.16, 0.42, 1)   # violeta oscuro (fondo único)
const COLOR_BORDER  := Color(0.80, 0.75, 1.00, 1)   # borde lavanda claro
const COLOR_TEXT    := Color(1.00, 1.00, 1.00, 1)   # puntaje
const COLOR_TEXT_2  := Color(0.82, 0.78, 1.00, 1)   # problemas resueltos (más suave)
const COLOR_DIVIDER := Color(0.80, 0.75, 1.00, 0.35)

const MARGIN      := Vector2(16, 16)
const VALUE_WIDTH := 150.0     # ancho reservado para el número (súbelo si lo necesitas más grande)
const LABEL_GAP   := 16

var _font: Font = null
var _box: PanelContainer
var _scoreValue: Label
var _problemsValue: Label

var _unlocked: bool = false
var _shown: int = 0            # puntaje que se ve en pantalla ahora
var _target: int = 0           # puntaje real
var _problemsShown: int = 0
var _countTween: Tween = null
var _popTween: Tween = null

func _ready() -> void:
	layer = 1
	_font = load(FONT_PATH)
	_build()
	_shown = GameData.gatopuntos
	_target = _shown
	_problemsShown = GameData.solvedProblemsCount()
	_refreshTexts()
	# Si ya resolvió el primero antes (cambió de escena), aparece de inmediato
	_unlocked = GameData.firstProblemSolved()
	_box.visible = _unlocked
	GameData.gatopuntosChanged.connect(_onScoreChanged)
	# Que quede DETRÁS del diálogo y del puzzle (misma capa, se dibuja primero)
	call_deferred("_sendToBack")

func _sendToBack() -> void:
	var p := get_parent()
	if p:
		p.move_child(self, 0)

# ── Construcción ──────────────────────────────────────────────────────────────

func _makeLabel(size: int, color: Color, align: int) -> Label:
	var l := Label.new()
	l.horizontal_alignment = align
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _font:
		l.add_theme_font_override("font", _font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l

# Una fila: nombre a la izquierda (se estira) + valor a la derecha (ancho fijo)
func _makeRow(title: String, size: int, color: Color) -> Label:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", LABEL_GAP)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var titleLabel := _makeLabel(size, color, HORIZONTAL_ALIGNMENT_LEFT)
	titleLabel.text = title
	titleLabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(titleLabel)

	var value := _makeLabel(size, color, HORIZONTAL_ALIGNMENT_RIGHT)
	value.custom_minimum_size = Vector2(VALUE_WIDTH, 0)
	row.add_child(value)

	_box.get_child(0).add_child(row)
	return value

func _build() -> void:
	_box = PanelContainer.new()
	_box.position = MARGIN
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = COLOR_FILL
	sb.border_color = COLOR_BORDER
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(12)
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 8
	sb.content_margin_bottom = 9
	sb.shadow_color = Color(0, 0, 0, 0.35)
	sb.shadow_size = 6
	sb.shadow_offset = Vector2(0, 3)
	_box.add_theme_stylebox_override("panel", sb)
	add_child(_box)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_box.add_child(vbox)

	_scoreValue = _makeRow("Puntaje Villa Miaulemana:", 22, COLOR_TEXT)

	var divider := ColorRect.new()
	divider.color = COLOR_DIVIDER
	divider.custom_minimum_size = Vector2(0, 2)
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(divider)

	_problemsValue = _makeRow("Problemas resueltos:", 20, COLOR_TEXT_2)

func _refreshTexts() -> void:
	_scoreValue.text = str(_shown)
	_problemsValue.text = "%d/%d" % [_problemsShown, GameData.TOTAL_PROBLEMS]

# ── Actualización ─────────────────────────────────────────────────────────────
# Si hay un puzzle abierto (la pantalla lo tapa todo), esperamos a que se cierre
# para mostrar la aparición / animaciones y que el jugador sí las vea.

func _onScoreChanged(newValue: int) -> void:
	_target = newValue

func _process(_delta: float) -> void:
	if _puzzleOpen():
		return

	if not _unlocked:
		if GameData.firstProblemSolved():
			_unlocked = true
			_box.visible = true
			_problemsShown = GameData.solvedProblemsCount()
			_refreshTexts()
			_appear()
		return

	if _target != _shown:
		_animateScoreTo(_target)

	var solved := GameData.solvedProblemsCount()
	if solved != _problemsShown:
		_problemsShown = solved
		_refreshTexts()
		_pop()

func _puzzleOpen() -> bool:
	var pz = get_tree().get_first_node_in_group("puzzle")
	return pz != null and pz.get("isOpen") == true

func _animateScoreTo(value: int) -> void:
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
	_scoreValue.text = str(int(round(v)))

# Aparición del cuadro la primera vez (crece desde chiquito)
func _appear() -> void:
	await get_tree().process_frame   # esperar a que el contenedor calcule su tamaño
	_box.pivot_offset = _box.size / 2.0
	_box.scale = Vector2(0.4, 0.4)
	_box.modulate.a = 0.0
	if _popTween and _popTween.is_valid():
		_popTween.kill()
	_popTween = create_tween().set_parallel(true)
	_popTween.tween_property(_box, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK)
	_popTween.tween_property(_box, "modulate:a", 1.0, 0.2)

func _pop() -> void:
	_box.pivot_offset = _box.size / 2.0
	if _popTween and _popTween.is_valid():
		_popTween.kill()
	_box.scale = Vector2.ONE
	_popTween = create_tween()
	_popTween.tween_property(_box, "scale", Vector2(1.12, 1.12), 0.12).set_trans(Tween.TRANS_BACK)
	_popTween.tween_property(_box, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_SINE)
