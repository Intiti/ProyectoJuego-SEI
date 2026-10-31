extends Control

signal aliasConfirmado(alias: String, characterName: String)
signal cancelado

const FORM_URL := "https://docs.google.com/forms/d/e/1FAIpQLSefZ_I9H848v9HQzGtbuXFn7cfk6cu5p4AXsK79eCVIAvr66Q/viewform?usp=dialog"
const FONT_PATH := "res://assets/fonts/MotionControl-Bold.otf"
const ALIAS_PREFIX := "P"
const ALIAS_CHARS := "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
const ALIAS_LENGTH := 5
const NAME_MIN_LENGTH := 3
const NAME_MAX_LENGTH := 10

var alias: String = ""
var _font: Font = null
var _startButton: Button = null
var _hintLabel: Label = null
var _copyButton: Button = null
var _center: CenterContainer = null
var _panel: PanelContainer = null
var _nameInput: LineEdit = null
var _nameError: Label = null

func _ready() -> void:
	if ResourceLoader.exists(FONT_PATH):
		_font = load(FONT_PATH)
	alias = generateAlias()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	position = Vector2.ZERO
	size = get_viewport_rect().size
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
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	_center = CenterContainer.new()
	_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_center)

	var vbox := _newPanel()

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

func _newPanel() -> VBoxContainer:
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(720, 0)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.20, 0.16, 0.42, 1)
	sb.border_color = Color(0.80, 0.75, 1.00, 1)
	sb.set_border_width_all(4)
	sb.set_corner_radius_all(18)
	sb.content_margin_left = 32
	sb.content_margin_right = 32
	sb.content_margin_top = 24
	sb.content_margin_bottom = 26
	_panel.add_theme_stylebox_override("panel", sb)
	_center.add_child(_panel)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	_panel.add_child(vbox)
	return vbox

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

func _onNameChanged(text: String) -> void:
	var filtered := ""
	for c in text:
		if c.to_upper() != c.to_lower() or c.is_valid_int() or c == " ":
			filtered += c
	if filtered != text:
		var col := _nameInput.caret_column
		_nameInput.text = filtered
		_nameInput.caret_column = mini(col, filtered.length())
	_nameError.text = ""

func _start() -> void:
	_center.remove_child(_panel)
	_panel.queue_free()
	var vbox := _newPanel()
	vbox.add_child(_label("TU PERSONAJE", 38, Color.WHITE))
	vbox.add_child(_label("¿Cómo quieres que se llame tu personaje?", 22, Color(0.82, 0.78, 1.0)))
	vbox.add_child(_label("Opcional: de %d a %d caracteres. Si lo dejas vacío, serás \"%s\"." % [NAME_MIN_LENGTH, NAME_MAX_LENGTH, GameData.DEFAULT_CHARACTER_NAME], 18, Color(0.82, 0.78, 1.0)))

	_nameInput = LineEdit.new()
	_nameInput.max_length = NAME_MAX_LENGTH
	_nameInput.placeholder_text = GameData.DEFAULT_CHARACTER_NAME
	_nameInput.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_nameInput.custom_minimum_size = Vector2(380, 64)
	_nameInput.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_nameInput.add_theme_font_size_override("font_size", 34)
	if _font != null:
		_nameInput.add_theme_font_override("font", _font)
	_nameInput.text_changed.connect(_onNameChanged)
	_nameInput.text_submitted.connect(func(_t: String): _confirmName())
	vbox.add_child(_nameInput)

	_nameError = _label("", 18, Color(1.0, 0.55, 0.55))
	vbox.add_child(_nameError)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 14)
	vbox.add_child(row)
	var skip := _button("OMITIR", 200)
	skip.pressed.connect(_skipName)
	row.add_child(skip)
	var go := _button("EMPEZAR", 280)
	go.pressed.connect(_confirmName)
	row.add_child(go)
	_nameInput.grab_focus()

func _skipName() -> void:
	aliasConfirmado.emit(alias, "")

func _confirmName() -> void:
	var chosenName: String = _nameInput.text.strip_edges()
	if chosenName != "" and chosenName.length() < NAME_MIN_LENGTH:
		_nameError.text = "El nombre debe tener entre %d y %d caracteres." % [NAME_MIN_LENGTH, NAME_MAX_LENGTH]
		_nameInput.grab_focus()
		return
	aliasConfirmado.emit(alias, chosenName)

func _cancel() -> void:
	cancelado.emit()
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.15)
	await t.finished
	queue_free()
