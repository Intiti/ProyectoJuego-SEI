extends CanvasLayer

# ==========================================
# MANUAL DE REFERENCIA PYTHON — MIAUGORITMOS
# Disponible en la esquina superior derecha en Nivel 1, Nivel 2 y Nivel 3.
# Se oculta automáticamente en menús, pantallas finales y durante exámenes.
# ==========================================

const FONT_SIZE := 18

const CONTROLS := {
	"name": "Controles",
	"color": Color(0.30, 0.65, 0.75, 1.0),
	"entries": [
		{ "key": "← →  o  A D", "desc": "Moverse a la izquierda / derecha" },
		{ "key": "Espacio  o  W", "desc": "Saltar" },
		{ "key": "E", "desc": "Hablar con un NPC o interactuar con una terminal (cuando aparece la tecla E)" },
		{ "key": "E  (en un diálogo)", "desc": "Pasar al siguiente texto o mostrarlo completo" },
		{ "key": "Clic en bloque disponible", "desc": "Coloca el bloque en el siguiente espacio vacío del algoritmo" },
		{ "key": "Clic en bloque colocado", "desc": "Quita el bloque del algoritmo y lo devuelve a las opciones disponibles" },
		{ "key": "Botón 📖 Manual", "desc": "Abrir / cerrar este manual de referencia en cualquier momento" },
		{ "key": "", "desc": "" },
		{ "key": "Símbolo  !  rojo", "desc": "Un NPC o terminal necesita tu ayuda. Acércate y pulsa E" },
		{ "key": "Salida desbloqueada", "desc": "Avanza hacia la salida tras resolver el ejercicio de la zona" },
	]
}

const TIPS1 := {
	"name": "Consejos 1",
	"color": Color(0.75, 0.65, 0.20, 1.0),
	"items": [
		{
			"title": "Estructura de un algoritmo",
			"body": "Un algoritmo bien armado sigue este orden:\n\n  1. Inicialización / Entrada -> definir variables o leer con input()\n  2. Proceso (ciclos y decisiones) -> repetir con while o decidir con if/elif/else\n  3. Salida -> mostrar el resultado con print()\n\nSi salteas la entrada o inicialización, no tienes datos para procesar.\nSi salteas la salida, nadie ve el resultado."
		},
		{
			"title": "Orden de los if / elif / else",
			"body": "Python evalúa las condiciones de arriba hacia abajo y ejecuta solo el primer bloque que sea verdadero.\n\nPon primero el caso más específico (rango más estrecho) y después el más amplio, o de lo contrario el caso amplio \"atrapa\" todo y los elif de abajo nunca se ejecutan."
		},
		{
			"title": "El else no lleva condición",
			"body": "El else no tiene comparación: se ejecuta automáticamente cuando ninguno de los if/elif anteriores fue verdadero.\n\nÚsalo para el caso por defecto, como una alerta o valor inesperado."
		},
	]
}

const TIPS2 := {
	"name": "Consejos 2",
	"color": Color(0.65, 0.50, 0.15, 1.0),
	"items": [
		{
			"title": "Cómo evitar ciclos while infinitos",
			"body": "Todo ciclo while necesita que su variable de condición cambie dentro del bloque repetido:\n\n  1. Antes del while: inicializa la variable (ej: intentos = 0)\n  2. En el while: escribe la condición de continuación (ej: while intentos < 3:)\n  3. Dentro del while: actualiza la variable (ej: intentos = intentos + 1)"
		},
		{
			"title": "Variables y tipos con input()",
			"body": "input() siempre entrega texto. Si vas a comparar o calcular con números, convierte antes:\n\n  int(input())   -> número entero\n  float(input()) -> número decimal\n\nComparar texto con número (\"5\" == 5) siempre da False."
		},
		{
			"title": "print() muestra lo que le des",
			"body": "Puedes pasarle texto entre comillas, una variable, o varios separados por coma:\n\n  print(\"Acceso concedido\")\n  print(energia)\n  print(\"Resultado:\", total)"
		},
	]
}

const BLOCKS := [
	{
		"name": "input()",
		"color": Color(0.20, 0.45, 0.85, 1.0),
		"desc": "Lee un valor ingresado por el usuario y lo guarda en una variable. Por defecto el valor llega como texto (String). Para usarlo como número hay que convertirlo:\n\n  int(input())   -> número entero, sin decimales (ej: 5, -3, 100)\n  float(input()) -> número con decimales (ej: 3.14, -0.5)\n\nSi no conviertes, no podrás hacer operaciones matemáticas con él.",
		"example": "clave = input(\"Clave: \")\ndato  = int(input(\"Energía: \"))"
	},
	{
		"name": "if",
		"color": Color(0.65, 0.45, 0.08, 1.0),
		"desc": "Ejecuta un bloque solo si se cumple una condición. Puedes encadenar condiciones extra con elif, que se revisan en orden si la anterior fue falsa. Operadores disponibles:\n\n  ==  igual a          !=  distinto de\n  >   mayor que        <   menor que\n  >=  mayor o igual    <=  menor o igual",
		"example": "if energia >= 10:\n    print(\"Núcleo cargado\")"
	},
	{
		"name": "elif",
		"color": Color(0.55, 0.32, 0.05, 1.0),
		"desc": "Agrega una condición extra después de un if. Solo se evalúa si el if (y los elif anteriores) fueron falsos. Puedes poner tantos elif como necesites. El primero que sea verdadero se ejecuta y los demás se saltan.",
		"example": "if temp > 80:\n    print(\"Crítico\")\nelif temp > 50:\n    print(\"Advertencia\")\nelse:\n    print(\"Estable\")"
	},
	{
		"name": "else",
		"color": Color(0.45, 0.15, 0.65, 1.0),
		"desc": "Se ejecuta cuando ninguna condición anterior (if ni elif) fue verdadera. Es el camino por defecto. Solo puede haber un else por bloque y siempre va al final.",
		"example": "if clave == \"miau\":\n    print(\"Puerta abierta\")\nelse:\n    print(\"Acceso bloqueado\")"
	},
	{
		"name": "while",
		"color": Color(0.52, 0.25, 0.82, 1.0),
		"desc": "Repite un bloque de instrucciones mientras su condición sea verdadera (True). Es fundamental actualizar la variable de control dentro del ciclo para que en algún momento la condición deje de cumplirse y el ciclo termine.",
		"example": "intentos = 0\nwhile clave != \"miau\" and intentos < 3:\n    clave = input(\"Clave: \")\n    intentos = intentos + 1"
	},
	{
		"name": "and / or / not",
		"color": Color(0.18, 0.55, 0.68, 1.0),
		"desc": "Operadores lógicos que combinan o invierten condiciones:\n\n  • and : Verdadero solo si AMBAS condiciones se cumplen.\n  • or  : Verdadero si AL MENOS UNA condición se cumple.\n  • not : Invierte el valor booleano (True pasa a False, y False pasa a True).",
		"example": "while not rescatado and intentos < 3:\n    if senal == \"gatito\" or senal == \"maullido\":\n        rescatado = True"
	},
	{
		"name": "Contadores",
		"color": Color(0.75, 0.42, 0.14, 1.0),
		"desc": "Variables que controlan el avance de un ciclo:\n\n  • Contador   : avanza en una cantidad fija (pasos = pasos + 1).\n  • Acumulador : suma valores variables (energia = energia + dato).\n  • Bandera    : booleano (True/False) que cambia de estado cuando ocurre un evento.",
		"example": "energia = energia + dato  # Acumulador\npasos = pasos + 1         # Contador\nrescatado = True          # Bandera"
	},
	{
		"name": "print",
		"color": Color(0.12, 0.52, 0.30, 1.0),
		"desc": "Muestra un valor o mensaje en la consola. Puedes imprimir texto entre comillas, variables, o varios elementos separados por coma.",
		"example": "print(\"Sistema estable\")\nprint(\"Energía total:\", energia)"
	},
]

# Diccionario compatible con código previo por si algún script consulta manual_data
var manual_data: Dictionary = {}

var _toggle_btn: Button = null
var _panel: ColorRect = null
var main_panel: Control = null
var _isOpen: bool = false
var _selectedIdx: int = 0
var bloqueado_por_examen: bool = false


func _ready() -> void:
	layer = 30
	for b in BLOCKS:
		manual_data[str(b["name"])] = {
			"title": str(b["name"]),
			"desc": str(b["desc"]),
			"code": str(b["example"])
		}
	_buildButton()
	_buildPanel()
	main_panel = _panel
	_actualizar_visibilidad_segun_escena()


func _process(_delta: float) -> void:
	_actualizar_visibilidad_segun_escena()


func _actualizar_visibilidad_segun_escena() -> void:
	if _toggle_btn == null:
		return

	var ocultar: bool = bloqueado_por_examen
	var escena: Node = get_tree().current_scene if get_tree() != null else null
	if escena != null:
		var ruta: String = escena.scene_file_path
		if (
			ruta.contains("MainMenu")
			or ruta.contains("SelectLevel")
			or ruta.contains("nivel_0/Intro")
			or ruta.ends_with("Final.tscn")
			or ruta.contains("ExamenNivel3")
			or ruta.contains("/examen/")
		):
			ocultar = true

	# Respetar restricción de examen en Nivel 1 / Nivel 2 (cuando puzzleManager está en _examMode)
	if not ocultar and get_tree() != null:
		var pz: Node = get_tree().get_first_node_in_group("puzzle")
		if pz != null and bool(pz.get("isOpen")) and bool(pz.get("_examMode")):
			ocultar = true

	_toggle_btn.visible = not ocultar
	_toggle_btn.disabled = ocultar
	if ocultar and _isOpen:
		cerrar_manual()


func _input(event: InputEvent) -> void:
	if _isOpen and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			cerrar_manual()
			get_viewport().set_input_as_handled()
			return
	if not bloqueado_por_examen and InputMap.has_action("toggle_manual") and event.is_action_pressed("toggle_manual"):
		if _toggle_btn != null and _toggle_btn.visible:
			alternar_manual()


func _buildButton() -> void:
	_toggle_btn = Button.new()
	_toggle_btn.name = "BotonManualFlotante"
	_toggle_btn.text = "📖 Manual"
	_toggle_btn.add_theme_font_size_override("font_size", FONT_SIZE - 2)
	_toggle_btn.anchor_left   = 1.0
	_toggle_btn.anchor_right  = 1.0
	_toggle_btn.anchor_top    = 0.0
	_toggle_btn.anchor_bottom = 0.0
	_toggle_btn.offset_left   = -132.0
	_toggle_btn.offset_right  = -12.0
	_toggle_btn.offset_top    = 12.0
	_toggle_btn.offset_bottom = 48.0
	_toggle_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.24, 0.96)
	style.border_color = Color(0.58, 0.45, 0.88, 0.95)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left  = 10
	style.content_margin_right = 10
	_toggle_btn.add_theme_stylebox_override("normal", style)

	var styleHover := style.duplicate()
	styleHover.bg_color = Color(0.24, 0.20, 0.38, 0.98)
	styleHover.border_color = Color("#8BE9FD")
	_toggle_btn.add_theme_stylebox_override("hover", styleHover)

	var stylePressed := style.duplicate()
	stylePressed.bg_color = Color(0.12, 0.10, 0.20, 1.0)
	_toggle_btn.add_theme_stylebox_override("pressed", stylePressed)
	_toggle_btn.add_theme_color_override("font_color", Color("#F8F8F2"))

	_toggle_btn.pressed.connect(_onToggle)
	add_child(_toggle_btn)


func _buildPanel() -> void:
	_panel = ColorRect.new()
	_panel.name = "PanelManualOriginal"
	_panel.anchor_right  = 1.0
	_panel.anchor_bottom = 1.0
	_panel.color = Color(0.04, 0.05, 0.09, 0.97)
	_panel.visible = false
	add_child(_panel)

	var headerTitle := Label.new()
	headerTitle.text = "📖 MANUAL DE REFERENCIA PYTHON — MIAUGORITMOS"
	headerTitle.add_theme_font_size_override("font_size", FONT_SIZE + 2)
	headerTitle.add_theme_color_override("font_color", Color("#8BE9FD"))
	headerTitle.offset_left = 24.0
	headerTitle.offset_top = 18.0
	headerTitle.offset_right = 680.0
	headerTitle.offset_bottom = 52.0
	_panel.add_child(headerTitle)

	var closeBtn := Button.new()
	closeBtn.name = "BotonCerrarManual"
	closeBtn.text = "✕  Cerrar"
	closeBtn.add_theme_font_size_override("font_size", FONT_SIZE - 2)
	closeBtn.anchor_left   = 1.0
	closeBtn.anchor_right  = 1.0
	closeBtn.anchor_top    = 0.0
	closeBtn.anchor_bottom = 0.0
	closeBtn.offset_left   = -140.0
	closeBtn.offset_right  = -12.0
	closeBtn.offset_top    = 12.0
	closeBtn.offset_bottom = 48.0
	closeBtn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var closeStyle := StyleBoxFlat.new()
	closeStyle.bg_color = Color(0.35, 0.12, 0.16, 0.95)
	closeStyle.border_color = Color("#FF6B6B")
	closeStyle.set_border_width_all(2)
	closeStyle.set_corner_radius_all(8)
	closeBtn.add_theme_stylebox_override("normal", closeStyle)

	var closeHover := closeStyle.duplicate()
	closeHover.bg_color = Color(0.50, 0.16, 0.22, 0.98)
	closeBtn.add_theme_stylebox_override("hover", closeHover)
	closeBtn.add_theme_color_override("font_color", Color("#FFF0F0"))

	closeBtn.pressed.connect(cerrar_manual)
	_panel.add_child(closeBtn)

	var hbox := HBoxContainer.new()
	hbox.name = "HBoxContainer"
	hbox.anchor_right  = 1.0
	hbox.anchor_bottom = 1.0
	hbox.offset_left   = 24.0
	hbox.offset_top    = 64.0
	hbox.offset_right  = -24.0
	hbox.offset_bottom = -20.0
	hbox.add_theme_constant_override("separation", 20)
	_panel.add_child(hbox)

	var sidebarScroll := ScrollContainer.new()
	sidebarScroll.custom_minimum_size = Vector2(215, 0)
	hbox.add_child(sidebarScroll)

	var sidebar := VBoxContainer.new()
	sidebar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sidebar.add_theme_constant_override("separation", 8)
	sidebarScroll.add_child(sidebar)

	var sideTitle := Label.new()
	sideTitle.text = "Bloques de Python"
	sideTitle.add_theme_font_size_override("font_size", FONT_SIZE)
	sideTitle.add_theme_color_override("font_color", Color(0.75, 0.78, 1.0))
	sidebar.add_child(sideTitle)

	for i in range(BLOCKS.size()):
		var block: Dictionary = BLOCKS[i]
		var btn := Button.new()
		btn.text = str(block["name"])
		btn.add_theme_font_size_override("font_size", FONT_SIZE - 1)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

		var s := StyleBoxFlat.new()
		s.bg_color = (block["color"] as Color).darkened(0.3)
		s.border_color = block["color"]
		s.set_border_width_all(3)
		s.set_corner_radius_all(6)
		s.content_margin_left   = 10
		s.content_margin_right  = 10
		s.content_margin_top    = 6
		s.content_margin_bottom = 6
		btn.add_theme_stylebox_override("normal", s)

		var sHover := s.duplicate()
		sHover.bg_color = block["color"]
		btn.add_theme_stylebox_override("hover", sHover)
		btn.add_theme_color_override("font_color", Color.WHITE)

		var idx: int = i
		btn.pressed.connect(func() -> void: _selectBlock(idx))
		sidebar.add_child(btn)

	var extraSep := HSeparator.new()
	extraSep.custom_minimum_size = Vector2(0, 6)
	sidebar.add_child(extraSep)

	var guideTitle := Label.new()
	guideTitle.text = "Guía y Consejos"
	guideTitle.add_theme_font_size_override("font_size", FONT_SIZE - 1)
	guideTitle.add_theme_color_override("font_color", Color(0.75, 0.78, 1.0))
	sidebar.add_child(guideTitle)

	for extra in [CONTROLS, TIPS1, TIPS2]:
		var ebtn := Button.new()
		ebtn.text = str(extra["name"])
		ebtn.add_theme_font_size_override("font_size", FONT_SIZE - 1)
		ebtn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

		var es := StyleBoxFlat.new()
		es.bg_color = (extra["color"] as Color).darkened(0.3)
		es.border_color = extra["color"]
		es.set_border_width_all(3)
		es.set_corner_radius_all(6)
		es.content_margin_left   = 10
		es.content_margin_right  = 10
		es.content_margin_top    = 6
		es.content_margin_bottom = 6
		ebtn.add_theme_stylebox_override("normal", es)

		var esHover := es.duplicate()
		esHover.bg_color = extra["color"]
		ebtn.add_theme_stylebox_override("hover", esHover)
		ebtn.add_theme_color_override("font_color", Color.WHITE)

		var modeName: String = str(extra["name"])
		ebtn.pressed.connect(func() -> void: _selectMode(modeName))
		sidebar.add_child(ebtn)

	var sep := VSeparator.new()
	hbox.add_child(sep)

	var detailScroll := ScrollContainer.new()
	detailScroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detailScroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_child(detailScroll)

	var detail := VBoxContainer.new()
	detail.name = "Detail"
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail.add_theme_constant_override("separation", 14)
	detailScroll.add_child(detail)

	var blockNameLabel := Label.new()
	blockNameLabel.name = "BlockName"
	blockNameLabel.add_theme_font_size_override("font_size", FONT_SIZE + 8)
	detail.add_child(blockNameLabel)

	var descTitle := Label.new()
	descTitle.name = "DescTitle"
	descTitle.text = "Para qué sirve:"
	descTitle.add_theme_font_size_override("font_size", FONT_SIZE - 2)
	descTitle.add_theme_color_override("font_color", Color(0.65, 0.72, 0.85))
	detail.add_child(descTitle)

	var descLabel := Label.new()
	descLabel.name = "Desc"
	descLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	descLabel.add_theme_font_size_override("font_size", FONT_SIZE)
	descLabel.add_theme_color_override("font_color", Color(0.92, 0.94, 0.98))
	detail.add_child(descLabel)

	var exTitle := Label.new()
	exTitle.name = "ExTitle"
	exTitle.text = "Ejemplo en Python:"
	exTitle.add_theme_font_size_override("font_size", FONT_SIZE - 2)
	exTitle.add_theme_color_override("font_color", Color(0.65, 0.72, 0.85))
	detail.add_child(exTitle)

	var exBox := PanelContainer.new()
	exBox.name = "ExBox"
	var exStyle := StyleBoxFlat.new()
	exStyle.bg_color = Color(0.07, 0.10, 0.15, 1.0)
	exStyle.border_color = Color("#36C8E8")
	exStyle.set_border_width_all(2)
	exStyle.set_corner_radius_all(8)
	exStyle.content_margin_left   = 16
	exStyle.content_margin_right  = 16
	exStyle.content_margin_top    = 12
	exStyle.content_margin_bottom = 12
	exBox.add_theme_stylebox_override("panel", exStyle)
	detail.add_child(exBox)

	var exLabel := Label.new()
	exLabel.name = "ExLabel"
	exLabel.add_theme_font_size_override("font_size", FONT_SIZE)
	exLabel.add_theme_color_override("font_color", Color(0.55, 0.96, 0.72))
	exBox.add_child(exLabel)

	_selectBlock(0)


func _getDetail() -> VBoxContainer:
	if _panel == null:
		return null
	return _panel.find_child("Detail", true, false) as VBoxContainer


func _selectBlock(idx: int) -> void:
	if idx < 0 or idx >= BLOCKS.size():
		return
	_selectedIdx = idx
	var block: Dictionary = BLOCKS[idx]

	var detail := _getDetail()
	if detail == null:
		return

	var nameLabel := detail.get_node("BlockName") as Label
	nameLabel.text = str(block["name"])
	nameLabel.add_theme_color_override("font_color", block["color"])

	(detail.get_node("Desc") as Label).text = str(block["desc"])
	(detail.get_node("DescTitle") as Label).text = "Para qué sirve:"
	(detail.get_node("ExTitle") as Control).visible = true
	(detail.get_node("ExBox") as Control).visible = true
	var exLbl := detail.get_node_or_null("ExBox/ExLabel") as Label
	if exLbl != null:
		exLbl.text = str(block["example"])


func _on_topic_selected(topic_key: String) -> void:
	for i in range(BLOCKS.size()):
		if str(BLOCKS[i]["name"]) == topic_key:
			_selectBlock(i)
			return


func _selectMode(modeName: String) -> void:
	var detail := _getDetail()
	if detail == null:
		return

	var nameLabel := detail.get_node("BlockName") as Label
	var descNode := detail.get_node("Desc") as Label
	var descTitle := detail.get_node("DescTitle") as Label
	var exTitle := detail.get_node("ExTitle") as Control
	var exBox := detail.get_node("ExBox") as Control

	if modeName == "Controles":
		nameLabel.text = str(CONTROLS["name"])
		nameLabel.add_theme_color_override("font_color", CONTROLS["color"])
		descTitle.text = "Acciones y controles:"
		var lines := ""
		for entry in CONTROLS["entries"]:
			if str(entry["key"]) == "":
				lines += "\n"
			else:
				lines += "  • " + str(entry["key"]) + "  →  " + str(entry["desc"]) + "\n"
		descNode.text = lines.strip_edges()
		exTitle.visible = false
		exBox.visible = false

	elif modeName == "Consejos 1" or modeName == "Consejos 2":
		var tipSet: Dictionary = TIPS1 if modeName == "Consejos 1" else TIPS2
		nameLabel.text = str(tipSet["name"])
		nameLabel.add_theme_color_override("font_color", tipSet["color"])
		descTitle.text = ""
		var allText := ""
		for item in tipSet["items"]:
			allText += "▸ " + str(item["title"]) + "\n" + str(item["body"]) + "\n\n"
		descNode.text = allText.strip_edges()
		exTitle.visible = false
		exBox.visible = false


func set_bloqueado_examen(bloqueado: bool) -> void:
	bloqueado_por_examen = bloqueado
	if bloqueado and _panel != null:
		_isOpen = false
		_panel.visible = false
	_actualizar_visibilidad_segun_escena()


func set_visibilidad_boton_flotante(mostrar: bool) -> void:
	if _toggle_btn != null:
		_toggle_btn.visible = mostrar and not bloqueado_por_examen


func abrir_manual() -> void:
	if bloqueado_por_examen or _panel == null:
		return
	_isOpen = true
	_panel.visible = true
	var dj: Node = get_node_or_null("/root/DJManager")
	if dj != null and dj.has_method("play_sfx"):
		dj.call("play_sfx", "ui_abrir")


func cerrar_manual() -> void:
	if _panel == null:
		return
	_isOpen = false
	_panel.visible = false
	var dj: Node = get_node_or_null("/root/DJManager")
	if dj != null and dj.has_method("play_sfx"):
		dj.call("play_sfx", "ui_cerrar")


func alternar_manual() -> void:
	if _isOpen:
		cerrar_manual()
	else:
		abrir_manual()


func _onToggle() -> void:
	if bloqueado_por_examen:
		return
	var dialogBox: Node = get_tree().get_first_node_in_group("dialog_box")
	if dialogBox != null and dialogBox.get("isOpen") == true and not _isOpen:
		return
	alternar_manual()
