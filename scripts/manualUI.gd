extends CanvasLayer

const FONT_SIZE := 20

# Datos de cada bloque: nombre, color, descripcion, ejemplo
const BLOCKS := [
	{
		"name": "input()",
		"color": Color(0.20, 0.45, 0.85, 1.0),
		"desc": "Lee un valor externo y lo guarda en una variable. Sirve para recibir datos del usuario o del entorno.",
		"example": "nombre = input()\nprint(nombre)"
	},
	{
		"name": "if",
		"color": Color(0.65, 0.45, 0.08, 1.0),
		"desc": "Ejecuta un bloque de código solo si se cumple una condición. Si la condición es falsa, ese bloque se salta.",
		"example": "if edad >= 18:\n    print(\"adulto\")"
	},
	{
		"name": "else",
		"color": Color(0.45, 0.15, 0.65, 1.0),
		"desc": "Se ejecuta cuando la condición del 'if' anterior fue falsa. Es el camino alternativo.",
		"example": "if edad >= 18:\n    print(\"adulto\")\nelse:\n    print(\"menor\")"
	},
	{
		"name": "print",
		"color": Color(0.12, 0.52, 0.30, 1.0),
		"desc": "Muestra un valor o texto en la consola. Es la forma de ver el resultado de tu programa.",
		"example": "print(\"Hola\")\nprint(resultado)"
	},
	{
		"name": "asignar",
		"color": Color(0.50, 0.20, 0.20, 1.0),
		"desc": "Guarda un valor fijo en una variable. A diferencia de input(), el valor lo escribes tú directamente.",
		"example": "vidas = 3\nnombre = \"Miau\""
	},
	{
		"name": "expr",
		"color": Color(0.20, 0.55, 0.60, 1.0),
		"desc": "Calcula una operacion matematica entre dos variables o numeros y guarda el resultado.",
		"example": "total = precio + impuesto\ndif = a - b"
	},
]

var _panel: ColorRect
var _isOpen: bool = false
var _selectedIdx: int = 0

func _ready() -> void:
	layer = 20
	_buildButton()
	_buildPanel()

func _buildButton() -> void:
	var btn = Button.new()
	btn.text = "Manual"
	btn.add_theme_font_size_override("font_size", FONT_SIZE - 2)
	btn.anchor_left   = 1.0
	btn.anchor_right  = 1.0
	btn.anchor_top    = 0.0
	btn.anchor_bottom = 0.0
	btn.offset_left   = -120.0
	btn.offset_right  = -12.0
	btn.offset_top    = 12.0
	btn.offset_bottom = 48.0
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.22, 0.95)
	style.border_color = Color(0.55, 0.55, 0.75, 0.9)
	style.border_width_left   = 2
	style.border_width_right  = 2
	style.border_width_top    = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left     = 6
	style.corner_radius_top_right    = 6
	style.corner_radius_bottom_left  = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left  = 10
	style.content_margin_right = 10
	btn.add_theme_stylebox_override("normal", style)

	var styleHover = style.duplicate()
	styleHover.bg_color = Color(0.22, 0.22, 0.35, 0.97)
	btn.add_theme_stylebox_override("hover", styleHover)

	btn.pressed.connect(_onToggle)
	add_child(btn)

func _buildPanel() -> void:
	_panel = ColorRect.new()
	_panel.anchor_right  = 1.0
	_panel.anchor_bottom = 1.0
	_panel.color = Color(0.04, 0.04, 0.06, 0.97)
	_panel.visible = false
	add_child(_panel)

	# Boton cerrar
	var closeBtn = Button.new()
	closeBtn.text = "X  Cerrar"
	closeBtn.add_theme_font_size_override("font_size", FONT_SIZE - 2)
	closeBtn.anchor_left   = 1.0
	closeBtn.anchor_right  = 1.0
	closeBtn.anchor_top    = 0.0
	closeBtn.anchor_bottom = 0.0
	closeBtn.offset_left   = -140.0
	closeBtn.offset_right  = -12.0
	closeBtn.offset_top    = 12.0
	closeBtn.offset_bottom = 48.0
	closeBtn.pressed.connect(_onToggle)
	_panel.add_child(closeBtn)

	# Layout principal: sidebar izquierda + detalle derecha
	var hbox = HBoxContainer.new()
	hbox.anchor_right  = 1.0
	hbox.anchor_bottom = 1.0
	hbox.offset_left   = 24.0
	hbox.offset_top    = 70.0
	hbox.offset_right  = -24.0
	hbox.offset_bottom = -24.0
	hbox.add_theme_constant_override("separation", 20)
	_panel.add_child(hbox)

	# --- Sidebar con botones de bloques ---
	var sidebar = VBoxContainer.new()
	sidebar.custom_minimum_size = Vector2(200, 0)
	sidebar.add_theme_constant_override("separation", 10)
	hbox.add_child(sidebar)

	var sideTitle = Label.new()
	sideTitle.text = "Bloques"
	sideTitle.add_theme_font_size_override("font_size", FONT_SIZE)
	sideTitle.add_theme_color_override("font_color", Color(0.75, 0.75, 1.0))
	sidebar.add_child(sideTitle)

	for i in BLOCKS.size():
		var block = BLOCKS[i]
		var btn = Button.new()
		btn.text = block["name"]
		btn.add_theme_font_size_override("font_size", FONT_SIZE)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

		var s = StyleBoxFlat.new()
		s.bg_color = (block["color"] as Color).darkened(0.3)
		s.border_color = block["color"]
		s.border_width_left   = 3
		s.border_width_right  = 3
		s.border_width_top    = 3
		s.border_width_bottom = 3
		s.corner_radius_top_left     = 6
		s.corner_radius_top_right    = 6
		s.corner_radius_bottom_left  = 6
		s.corner_radius_bottom_right = 6
		s.content_margin_left  = 10
		s.content_margin_right = 10
		s.content_margin_top   = 8
		s.content_margin_bottom = 8
		btn.add_theme_stylebox_override("normal", s)

		var sHover = s.duplicate()
		sHover.bg_color = block["color"]
		btn.add_theme_stylebox_override("hover", sHover)

		var idx = i
		btn.pressed.connect(func(): _selectBlock(idx))
		sidebar.add_child(btn)

	# Separador vertical
	var sep = VSeparator.new()
	hbox.add_child(sep)

	# --- Panel de detalle ---
	var detail = VBoxContainer.new()
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail.add_theme_constant_override("separation", 16)
	hbox.add_child(detail)
	detail.name = "Detail"

	# Los nodos de detalle se reemplazaran en _selectBlock
	# Los creamos vacios para que existan desde el inicio
	var blockNameLabel = Label.new()
	blockNameLabel.name = "BlockName"
	blockNameLabel.add_theme_font_size_override("font_size", FONT_SIZE + 8)
	detail.add_child(blockNameLabel)

	var descTitle = Label.new()
	descTitle.name = "DescTitle"
	descTitle.text = "Para que sirve:"
	descTitle.add_theme_font_size_override("font_size", FONT_SIZE - 2)
	descTitle.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	detail.add_child(descTitle)

	var descLabel = Label.new()
	descLabel.name = "Desc"
	descLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	descLabel.add_theme_font_size_override("font_size", FONT_SIZE)
	descLabel.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	detail.add_child(descLabel)

	var exTitle = Label.new()
	exTitle.name = "ExTitle"
	exTitle.text = "Ejemplo:"
	exTitle.add_theme_font_size_override("font_size", FONT_SIZE - 2)
	exTitle.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	detail.add_child(exTitle)

	var exBox = PanelContainer.new()
	exBox.name = "ExBox"
	var exStyle = StyleBoxFlat.new()
	exStyle.bg_color = Color(0.08, 0.10, 0.12, 1.0)
	exStyle.border_color = Color(0.3, 0.3, 0.4, 0.8)
	exStyle.border_width_left   = 2
	exStyle.border_width_right  = 2
	exStyle.border_width_top    = 2
	exStyle.border_width_bottom = 2
	exStyle.corner_radius_top_left     = 6
	exStyle.corner_radius_top_right    = 6
	exStyle.corner_radius_bottom_left  = 6
	exStyle.corner_radius_bottom_right = 6
	exStyle.content_margin_left   = 16
	exStyle.content_margin_right  = 16
	exStyle.content_margin_top    = 12
	exStyle.content_margin_bottom = 12
	exBox.add_theme_stylebox_override("panel", exStyle)
	detail.add_child(exBox)

	var exLabel = Label.new()
	exLabel.name = "ExLabel"
	exLabel.add_theme_font_size_override("font_size", FONT_SIZE)
	exLabel.add_theme_color_override("font_color", Color(0.6, 1.0, 0.7))
	exBox.add_child(exLabel)

	# Seleccionar el primero por defecto
	_selectBlock(0)

func _selectBlock(idx: int) -> void:
	_selectedIdx = idx
	var block = BLOCKS[idx]

	var detail = _panel.get_node("HBoxContainer/Detail") if _panel.has_node("HBoxContainer/Detail") else null
	if detail == null:
		# fallback: buscar por nombre
		for child in _panel.get_children():
			if child is HBoxContainer:
				for c2 in child.get_children():
					if c2 is VBoxContainer and c2.name == "Detail":
						detail = c2
						break

	if detail == null:
		return

	var nameLabel = detail.get_node("BlockName")
	nameLabel.text = block["name"]
	nameLabel.add_theme_color_override("font_color", block["color"])

	detail.get_node("Desc").text = block["desc"]
	detail.get_node_or_null("ExBox/ExLabel").text = block["example"]

func _onToggle() -> void:
	_isOpen = !_isOpen
	_panel.visible = _isOpen
