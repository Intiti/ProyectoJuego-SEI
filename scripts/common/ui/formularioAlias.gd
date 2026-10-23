extends Control

signal aliasConfirmado(alias: String)
signal cancelado

const FORM_URL := "https://docs.google.com/forms/d/e/1FAIpQLSefZ_I9H848v9HQzGtbuXFn7cfk6cu5p4AXsK79eCVIAvr66Q/viewform?usp=dialog"
const FONT_PATH := "res://assets/fonts/MotionControl-Bold.otf"
const ALIAS_PREFIX := "P"
const ALIAS_CHARS := "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
const ALIAS_LENGTH := 5

var alias: String = ""
var _font: Font = null
var _startButton: Button = null
var _hintLabel: Label = null
var _copyButton: Button = null

func _ready() -> void:
	if ResourceLoader.exists(FONT_PATH):
		_font = load(FONT_PATH)
	alias = generateAlias()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.18)

static func generateAlias() -> String:
	var result := ALIAS_PREFIX
	for i in ALIAS_LENGTH:
		result += ALIAS_CHARS[randi() % ALIAS_CHARS.length()]
	return result

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		_cancel()

func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.06, 0.05, 0.88)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(720, 0)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.20, 0.16, 0.42, 1)
	sb.border_color = Color(0.80, 0.75, 1.00, 1)
	sb.set_border_width_all(4)
	sb.set_corner_radius_all(18)
	sb.content_margin_left = 32
	sb.content_margin_right = 32
	sb.content_margin_top = 24
	sb.content_margin_bottom = 26
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	panel.add_child(vbox)

	vbox.add_child(_label("ANTES DE EMPEZAR", 38, Color.WHITE))
	vbox.add_child(_label("Antes de empezar el juego, resuelve este formulario.", 22, Color(0.82, 0.78, 1.0)))
	vbox.add_child(_label("Tu alias de jugador será:", 22, Color(0.82, 0.78, 1.0)))
	vbox.add_child(_label(alias, 64, Color(1.0, 0.90, 0.55)))
	vbox.add_child(_label("Anótalo o cópialo: lo necesitarás en el formulario.", 18, Color(0.82, 0.78, 1.0)))

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 14)
	vbox.add_child(row)
	_copyButton = _button("COPIAR ALIAS", 240)
	_copyButton.pressed.connect(_copyAlias)
	row.add_child(_copyButton)
	var formButton := _button("IR AL FORMULARIO", 300)
	formButton.pressed.connect(_openForm)
	row.add_child(formButton)

	_hintLabel = _label("", 18, Color(0.55, 0.95, 0.65))
	vbox.add_child(_hintLabel)

	var row2 := HBoxContainer.new()
	row2.alignment = BoxContainer.ALIGNMENT_CENTER
	row2.add_theme_constant_override("separation", 14)
	vbox.add_child(row2)
	var back := _button("VOLVER", 200)
	back.pressed.connect(_cancel)
	row2.add_child(back)
	_startButton = _button("COMENZAR JUEGO", 320)
	_startButton.disabled = true
	_startButton.pressed.connect(_start)
	row2.add_child(_startButton)
	formButton.grab_focus()

func _label(text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if _font != null:
		l.add_theme_font_override("font", _font)
	return l

func _button(text: String, width: float) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(width, 52)
	b.add_theme_font_size_override("font_size", 24)
	if _font != null:
		b.add_theme_font_override("font", _font)
	return b

func _copyAlias() -> void:
	DisplayServer.clipboard_set(alias)
	_copyButton.text = "¡COPIADO!"

func _openForm() -> void:
	var err := OS.shell_open(FORM_URL)
	if err != OK:
		push_error("formularioAlias: no se pudo abrir %s (error %d)" % [FORM_URL, err])
		_hintLabel.text = "No se pudo abrir el navegador. Copia este enlace: " + FORM_URL
		_hintLabel.add_theme_color_override("font_color", Color(1.0, 0.55, 0.55))
	else:
		_hintLabel.text = "Cuando termines el formulario, presiona COMENZAR JUEGO."
	_startButton.disabled = false

func _start() -> void:
	aliasConfirmado.emit(alias)

func _cancel() -> void:
	cancelado.emit()
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.15)
	await t.finished
	queue_free()
