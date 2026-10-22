extends Control

const LeaderboardScript = preload("res://scripts/common/systems/LeaderboardNiveles.gd")
const FONT_PATH := "res://assets/fonts/MotionControl-Bold.otf"
const MAX_ROWS := 10
const LEVELS := [1, 2, 3]
const COL_POS := 70.0
const COL_SCORE := 150.0
const COL_STREAK := 190.0
const COLOR_HEADER := Color(1.0, 0.90, 0.55)
const COLOR_SOFT := Color(0.82, 0.78, 1.0)
const COLOR_ROW := Color(1, 1, 1, 0.08)
const COLOR_MINE := Color(1.0, 0.90, 0.55, 0.25)
const COLOR_TOP := [Color("#FFD84D"), Color("#DDE4EC"), Color("#E9A866")]

var _font: Font = null
var _statusLabel: Label
var _rowsBox: VBoxContainer
var _levelLabel: Label
var _closing: bool = false
var _level: int = 1
var _requestId: int = 0

func _ready() -> void:
	if ResourceLoader.exists(FONT_PATH):
		_font = load(FONT_PATH)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.18)
	_load()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		_close()

func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.06, 0.05, 0.88)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(800, 0)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.20, 0.16, 0.42, 1)
	sb.border_color = Color(0.80, 0.75, 1.00, 1)
	sb.set_border_width_all(4)
	sb.set_corner_radius_all(18)
	sb.content_margin_left = 28
	sb.content_margin_right = 28
	sb.content_margin_top = 20
	sb.content_margin_bottom = 22
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	vbox.add_child(_label("RANKING", 40, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER))
	_levelLabel = _label(GameData.levelName(_level).to_upper(), 20, COLOR_HEADER, HORIZONTAL_ALIGNMENT_CENTER)
	vbox.add_child(_levelLabel)
	vbox.add_child(_buildLevelTabs())
	vbox.add_child(_makeRow("#", "Nombre", "Puntaje", "Mayor racha", COLOR_HEADER, 18, false, false))

	_rowsBox = VBoxContainer.new()
	_rowsBox.add_theme_constant_override("separation", 6)
	_rowsBox.custom_minimum_size = Vector2(0, 320)
	vbox.add_child(_rowsBox)

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(buttons)

	var back := Button.new()
	back.text = "VOLVER"
	back.custom_minimum_size = Vector2(200, 52)
	back.add_theme_font_size_override("font_size", 24)
	if _font != null:
		back.add_theme_font_override("font", _font)
	back.pressed.connect(_close)
	buttons.add_child(back)
	back.grab_focus()

func _buildLevelTabs() -> Control:
	var tabs := HBoxContainer.new()
	tabs.alignment = BoxContainer.ALIGNMENT_CENTER
	tabs.add_theme_constant_override("separation", 12)
	var group := ButtonGroup.new()
	for level in LEVELS:
		var tab := Button.new()
		tab.text = "NIVEL %d" % level
		tab.toggle_mode = true
		tab.button_group = group
		tab.button_pressed = level == _level
		tab.custom_minimum_size = Vector2(150, 44)
		tab.add_theme_font_size_override("font_size", 20)
		if _font != null:
			tab.add_theme_font_override("font", _font)
		tab.pressed.connect(_selectLevel.bind(level))
		tabs.add_child(tab)
	return tabs

func _selectLevel(level: int) -> void:
	if level == _level:
		return
	_level = level
	_levelLabel.text = GameData.levelName(level).to_upper()
	_load()

func _clearRows() -> void:
	for child in _rowsBox.get_children():
		child.queue_free()

func _load() -> void:
	_requestId += 1
	var myRequest := _requestId
	_clearRows()
	_showStatus("Cargando...")
	var result: Dictionary = await LeaderboardScript.fetchTop(_level, MAX_ROWS)
	if _closing or not is_inside_tree() or myRequest != _requestId:
		return
	_clearRows()
	if not result["ok"]:
		_showStatus("No se pudo conectar con el ranking.")
		return
	var rows: Array = result["rows"]
	if rows.is_empty():
		_showStatus("Aún no hay puntajes. ¡Sé el primero!")
		return
	for row in rows:
		var rank: int = row["rank"]
		var color: Color = COLOR_TOP[rank - 1] if rank <= 3 else Color.WHITE
		_rowsBox.add_child(_makeRow(
			str(rank),
			row["name"],
			str(row["score"]),
			str(row["streak"]),
			color,
			22,
			true,
			row["isMine"]
		))

func _showStatus(text: String) -> void:
	_statusLabel = _label(text, 22, COLOR_SOFT, HORIZONTAL_ALIGNMENT_CENTER)
	_rowsBox.add_child(_statusLabel)

func _makeRow(rank: String, playerName: String, score: String, streak: String, color: Color, fontSize: int, boxed: bool, mine: bool) -> Control:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)

	var rankLabel := _label(rank, fontSize, color, HORIZONTAL_ALIGNMENT_CENTER)
	rankLabel.custom_minimum_size = Vector2(COL_POS, 0)
	h.add_child(rankLabel)

	var nameLabel := _label(playerName, fontSize, color, HORIZONTAL_ALIGNMENT_LEFT)
	nameLabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(nameLabel)

	var scoreLabel := _label(score, fontSize, color, HORIZONTAL_ALIGNMENT_RIGHT)
	scoreLabel.custom_minimum_size = Vector2(COL_SCORE, 0)
	h.add_child(scoreLabel)

	var streakLabel := _label(streak, fontSize, color, HORIZONTAL_ALIGNMENT_RIGHT)
	streakLabel.custom_minimum_size = Vector2(COL_STREAK, 0)
	h.add_child(streakLabel)

	if not boxed:
		return h

	var row := PanelContainer.new()
	var rsb := StyleBoxFlat.new()
	rsb.bg_color = COLOR_MINE if mine else COLOR_ROW
	rsb.set_corner_radius_all(10)
	rsb.content_margin_left = 12
	rsb.content_margin_right = 14
	rsb.content_margin_top = 6
	rsb.content_margin_bottom = 6
	row.add_theme_stylebox_override("panel", rsb)
	row.add_child(h)
	return row

func _label(text: String, fontSize: int, color: Color, align: int) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = align
	l.clip_text = true
	if _font != null:
		l.add_theme_font_override("font", _font)
	l.add_theme_font_size_override("font_size", fontSize)
	l.add_theme_color_override("font_color", color)
	return l

func _close() -> void:
	if _closing:
		return
	_closing = true
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.15)
	await t.finished
	queue_free()
