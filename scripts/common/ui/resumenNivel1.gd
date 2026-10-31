extends CanvasLayer

signal closed

const LeaderboardScript = preload("res://scripts/common/systems/LeaderboardNivel1.gd")
const FONT_PATH := "res://assets/fonts/MotionControl-Bold.otf"
const COLOR_HEADER := Color(1.0, 0.90, 0.55)
const COLOR_SOFT := Color(0.82, 0.78, 1.0)
const COLOR_ROW := Color(1, 1, 1, 0.08)
const COLOR_MINE := Color(1.0, 0.90, 0.55, 0.25)
const COLOR_TOP := [Color("#FFD84D"), Color("#DDE4EC"), Color("#E9A866")]
const FADE_TIME := 0.8
const BUTTON_FALLBACK := 10.0

var _font: Font = null
var _root: Control
var _black: ColorRect
var _panel: PanelContainer
var _standingTitle: Label
var _standingNote: Label
var _listBox: VBoxContainer
var _continueButton: Button
var _loading: bool = false
var _closing: bool = false

func _ready() -> void:
	layer = 60
	if ResourceLoader.exists(FONT_PATH):
		_font = load(FONT_PATH)
	_setPlayerFrozen(true)
	_build()
	_run()

func _setPlayerFrozen(frozen: bool) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(not frozen)

func _build() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)

	_black = ColorRect.new()
	_black.color = Color.BLACK
	_black.set_anchors_preset(Control.PRESET_FULL_RECT)
	_black.modulate.a = 0.0
	_root.add_child(_black)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(center)

	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(980, 0)
	_panel.modulate.a = 0.0
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.20, 0.16, 0.42, 1)
	sb.border_color = Color(0.80, 0.75, 1.00, 1)
	sb.set_border_width_all(4)
	sb.set_corner_radius_all(18)
	sb.content_margin_left = 32
	sb.content_margin_right = 32
	sb.content_margin_top = 20
	sb.content_margin_bottom = 22
	_panel.add_theme_stylebox_override("panel", sb)
	center.add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	_panel.add_child(vbox)

	vbox.add_child(_label("NIVEL 1 COMPLETADO", 40, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER))
	vbox.add_child(_label(GameData.playerName, 22, COLOR_HEADER, HORIZONTAL_ALIGNMENT_CENTER))

	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 40)
	vbox.add_child(columns)

	var stats := VBoxContainer.new()
	stats.custom_minimum_size = Vector2(320, 0)
	stats.add_theme_constant_override("separation", 14)
	columns.add_child(stats)
	stats.add_child(_statBlock("Puntaje obtenido", str(GameData.nivel1Resumen.get("score", 0))))
	stats.add_child(_statBlock("Mayor racha", str(GameData.nivel1Resumen.get("racha", 0))))
	stats.add_child(_statBlock("Problemas resueltos", "%d/%d" % [GameData.nivel1Resumen.get("problemas", 0), GameData.TOTAL_PROBLEMS]))

	var standing := VBoxContainer.new()
	standing.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	standing.add_theme_constant_override("separation", 8)
	columns.add_child(standing)

	_standingTitle = _label("Guardando tu puntaje...", 26, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT)
	_standingTitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	standing.add_child(_standingTitle)

	_standingNote = _label("", 16, COLOR_SOFT, HORIZONTAL_ALIGNMENT_LEFT)
	_standingNote.visible = false
	standing.add_child(_standingNote)

	_listBox = VBoxContainer.new()
	_listBox.add_theme_constant_override("separation", 5)
	standing.add_child(_listBox)

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(buttons)

	_continueButton = Button.new()
	_continueButton.text = "CONTINUAR"
	_continueButton.custom_minimum_size = Vector2(240, 52)
	_continueButton.add_theme_font_size_override("font_size", 24)
	_continueButton.disabled = true
	if _font != null:
		_continueButton.add_theme_font_override("font", _font)
	_continueButton.pressed.connect(_close)
	buttons.add_child(_continueButton)

func _statBlock(title: String, value: String) -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 0)
	box.add_child(_label(title, 18, COLOR_SOFT, HORIZONTAL_ALIGNMENT_LEFT))
	box.add_child(_label(value, 38, COLOR_HEADER, HORIZONTAL_ALIGNMENT_LEFT))
	return box

func _run() -> void:
	var fadeBlack := create_tween()
	fadeBlack.tween_property(_black, "modulate:a", 1.0, FADE_TIME)
	await fadeBlack.finished
	var fadePanel := create_tween()
	fadePanel.tween_property(_panel, "modulate:a", 1.0, 0.4)
	get_tree().create_timer(BUTTON_FALLBACK).timeout.connect(_enableButton)
	_loading = true
	await _loadStanding()
	_loading = false
	_enableButton()
	if _closing:
		queue_free()

func _enableButton() -> void:
	if is_instance_valid(_continueButton):
		_continueButton.disabled = false
		_continueButton.grab_focus()

func _loadStanding() -> void:
	if not GameData.nivel1SubmitDone:
		await GameData.nivel1Submitted
	if not GameData.nivel1SubmitOk:
		_standingTitle.text = "No se pudo conectar con el ranking."
		return
	_standingTitle.text = "Calculando tu posición..."
	var result: Dictionary = await LeaderboardScript.fetchAll()
	if not result["ok"]:
		_standingTitle.text = "No se pudo conectar con el ranking."
		return
	var standing: Dictionary = LeaderboardScript.buildStanding(result["rows"], GameData.playerName)
	if not standing["found"]:
		_standingTitle.text = "No encontramos tu puntaje en el ranking."
		return
	var rank: int = standing["rank"]
	var ties: int = standing["ties"]
	if ties > 0:
		_standingTitle.text = "Compartes el puesto %d con %d jugador%s" % [rank, ties, "" if ties == 1 else "es"]
	else:
		_standingTitle.text = "Quedaste en el puesto %d de %d" % [rank, standing["total"]]
	var runScore: int = GameData.nivel1Resumen.get("score", 0)
	if standing["score"] != runScore:
		_standingNote.text = "Tu mejor puntaje registrado: %d" % standing["score"]
		_standingNote.visible = true
	for row in standing["window"]:
		_listBox.add_child(_makeRow(row))

func _makeRow(row: Dictionary) -> Control:
	var rank: int = row["rank"]
	var color: Color = COLOR_TOP[rank - 1] if rank <= 3 else Color.WHITE

	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)

	var rankLabel := _label(str(rank), 22, color, HORIZONTAL_ALIGNMENT_CENTER)
	rankLabel.custom_minimum_size = Vector2(50, 0)
	h.add_child(rankLabel)

	var nameLabel := _label(row["name"], 22, color, HORIZONTAL_ALIGNMENT_LEFT)
	nameLabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(nameLabel)

	var scoreLabel := _label(str(row["score"]), 22, color, HORIZONTAL_ALIGNMENT_RIGHT)
	scoreLabel.custom_minimum_size = Vector2(110, 0)
	h.add_child(scoreLabel)

	var box := PanelContainer.new()
	var rsb := StyleBoxFlat.new()
	rsb.bg_color = COLOR_MINE if row["isMine"] else COLOR_ROW
	rsb.set_corner_radius_all(10)
	rsb.content_margin_left = 12
	rsb.content_margin_right = 14
	rsb.content_margin_top = 4
	rsb.content_margin_bottom = 4
	box.add_theme_stylebox_override("panel", rsb)
	box.add_child(h)
	return box

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
	_continueButton.disabled = true
	_setPlayerFrozen(false)
	var t := create_tween()
	t.tween_property(_root, "modulate:a", 0.0, 0.4)
	await t.finished
	closed.emit()
	if not _loading:
		queue_free()
