extends CanvasLayer

const FONT_SIZE := 20

# Datos de cada bloque: nombre, color, descripcion, ejemplo
const CONTROLS := {
	"name": "Controles",
	"color": Color(0.30, 0.65, 0.75, 1.0),
	"entries": [
		{ "key": "← →", "desc": "Moverse" },
		{ "key": "Espacio", "desc": "Saltar" },
		{ "key": "E", "desc": "Hablar con un NPC / entrar a un edificio marcado con [color=#ff4444]![/color]" },
	]
}

const TIPS := {
	"name": "Consejos",
	"color": Color(0.75, 0.65, 0.20, 1.0),
	"items": [
		{
			"title": "Estructura de un algoritmo",
			"body": "Un algoritmo bien armado sigue este orden:\n\n  1. Entrada   — leer los datos con input()\n  2. Proceso   — calcular o decidir\n  3. Salida    — mostrar el resultado con print()\n\nSi salteas la entrada, no tienes datos para procesar.\nSi salteas la salida, nadie ve el resultado."
		},
		{
			"title": "Orden de los if / elif / else",
			"body": "Python evalua las condiciones de arriba hacia abajo y ejecuta solo el primer bloque que sea verdadero.\n\nPon primero el caso mas especifico (rango mas estrecho) y despues el mas amplio, o de lo contrario el caso amplio \"atrapa\" todo y los elif de abajo nunca se ejecutan."
		},
		{
			"title": "El else no lleva condicion",
			"body": "El else no tiene comparacion: se ejecuta automaticamente cuando ninguno de los if/elif anteriores fue verdadero.\n\nUsalo para el caso por defecto, como un error o valor inesperado."
		},
		{
			"title": "Variables y tipos",
			"body": "input() siempre entrega texto. Si vas a comparar o calcular con numeros, convierte antes:\n\n  int(input())   -> entero\n  float(input()) -> decimal\n\nComparar texto con numero (\"5\" == 5) siempre da False."
		},
		{
			"title": "print() muestra lo que le des",
			"body": "Puedes pasarle texto entre comillas, una variable, o varios separados por coma:\n\n  print(\"Hola\")\n  print(nombre)\n  print(\"Resultado:\", total)\n\nLos valores separados por coma se imprimen juntos con un espacio entre ellos."
		},
	]
}

const BLOCKS := [
	{
		"name": "input()",
		"color": Color(0.20, 0.45, 0.85, 1.0),
		"desc": "Lee un valor del usuario y lo guarda en una variable. Por defecto el valor llega como texto (String). Para usarlo como numero hay que convertirlo:\n\n  int(input())   -> numero entero, sin decimales (ej: 5, -3, 100)\n  float(input()) -> numero con decimales (ej: 3.14, -0.5)\n\nSi no conviertes, no podras hacer operaciones matematicas con el.",
		"example": "edad   = int(input())\nprecio = float(input())\nnombre = input()"
	},
	{
		"name": "if",
		"color": Color(0.65, 0.45, 0.08, 1.0),
		"desc": "Ejecuta un bloque solo si se cumple una condicion. Puedes encadenar condiciones extra con elif, que se revisan en orden si la anterior fue falsa. Operadores disponibles:\n\n  ==  igual a\n  !=  distinto de\n  >   mayor que\n  <   menor que\n  >=  mayor o igual\n  <=  menor o igual",
		"example": "if nota >= 90:\n    print(\"Excelente\")"
	},
	{
		"name": "elif",
		"color": Color(0.55, 0.32, 0.05, 1.0),
		"desc": "Agrega una condicion extra despues de un if. Solo se evalua si el if (y los elif anteriores) fueron falsos. Puedes poner tantos elif como necesites. El primero que sea verdadero se ejecuta y los demas se saltan.",
		"example": "if color == \"rojo\":\n    print(\"Para\")\nelif color == \"amarillo\":\n    print(\"Precaucion\")\nelif color == \"verde\":\n    print(\"Sigue\")\nelse:\n    print(\"Color desconocido\")"
	},
	{
		"name": "else",
		"color": Color(0.45, 0.15, 0.65, 1.0),
		"desc": "Se ejecuta cuando ninguna condicion anterior (if ni elif) fue verdadera. Es el camino por defecto. Solo puede haber un else por bloque y siempre va al final.",
		"example": "if turno == \"dia\":\n    print(\"El sol brilla\")\nelif turno == \"tarde\":\n    print(\"Atardecer\")\nelse:\n    print(\"Es de noche\")"
	},
	{
		"name": "print",
		"color": Color(0.12, 0.52, 0.30, 1.0),
		"desc": "Muestra un valor en la consola. Puedes imprimir texto entre comillas, variables, o mezclarlos con el operador +. Para mezclar un numero con texto hay que convertirlo a String primero con str().",
		"example": "print(\"Hola\")\nprint(nombre)\nprint(\"Tu edad es: \", edad)"
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

	var extraSep = HSeparator.new()
	extraSep.custom_minimum_size = Vector2(0, 8)
	sidebar.add_child(extraSep)

	for extra in [CONTROLS, TIPS]:
		var ebtn = Button.new()
		ebtn.text = extra["name"]
		ebtn.add_theme_font_size_override("font_size", FONT_SIZE)
		ebtn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

		var es = StyleBoxFlat.new()
		es.bg_color = (extra["color"] as Color).darkened(0.3)
		es.border_color = extra["color"]
		es.border_width_left   = 3
		es.border_width_right  = 3
		es.border_width_top    = 3
		es.border_width_bottom = 3
		es.corner_radius_top_left     = 6
		es.corner_radius_top_right    = 6
		es.corner_radius_bottom_left  = 6
		es.corner_radius_bottom_right = 6
		es.content_margin_left  = 10
		es.content_margin_right = 10
		es.content_margin_top   = 8
		es.content_margin_bottom = 8
		ebtn.add_theme_stylebox_override("normal", es)

		var esHover = es.duplicate()
		esHover.bg_color = extra["color"]
		ebtn.add_theme_stylebox_override("hover", esHover)

		var modeName = extra["name"]
		ebtn.pressed.connect(func(): _selectMode(modeName))
		sidebar.add_child(ebtn)

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

	var detail = _getDetail()
	if detail == null:
		return

	var nameLabel = detail.get_node("BlockName")
	nameLabel.text = block["name"]
	nameLabel.add_theme_color_override("font_color", block["color"])

	detail.get_node("Desc").text = block["desc"]
	detail.get_node("DescTitle").text = "Para que sirve:"
	detail.get_node("ExTitle").visible = true
	detail.get_node("ExBox").visible = true
	detail.get_node_or_null("ExBox/ExLabel").text = block["example"]

func _getDetail() -> VBoxContainer:
	if _panel.has_node("HBoxContainer/Detail"):
		return _panel.get_node("HBoxContainer/Detail")
	for child in _panel.get_children():
		if child is HBoxContainer:
			for c2 in child.get_children():
				if c2 is VBoxContainer and c2.name == "Detail":
					return c2
	return null

func _selectMode(modeName: String) -> void:
	var detail = _getDetail()
	if detail == null:
		return

	var nameLabel = detail.get_node("BlockName")
	var descNode = detail.get_node("Desc")
	var descTitle = detail.get_node("DescTitle")
	var exTitle = detail.get_node("ExTitle")
	var exBox = detail.get_node("ExBox")

	if modeName == "Controles":
		nameLabel.text = CONTROLS["name"]
		nameLabel.add_theme_color_override("font_color", CONTROLS["color"])
		descTitle.text = "Teclas:"
		var lines = ""
		for entry in CONTROLS["entries"]:
			lines += "  " + entry["key"] + "  =  " + entry["desc"] + "\n"
		descNode.text = lines.strip_edges()
		exTitle.visible = false
		exBox.visible = false

	elif modeName == "Consejos":
		nameLabel.text = TIPS["name"]
		nameLabel.add_theme_color_override("font_color", TIPS["color"])
		descTitle.text = ""
		var allText = ""
		for item in TIPS["items"]:
			allText += "▸ " + item["title"] + "\n" + item["body"] + "\n\n"
		descNode.text = allText.strip_edges()
		exTitle.visible = false
		exBox.visible = false

func _onToggle() -> void:
	var dialogBox = get_tree().get_first_node_in_group("dialog_box")
	if dialogBox and dialogBox.isOpen and not _isOpen:
		return
	_isOpen = !_isOpen
	_panel.visible = _isOpen
