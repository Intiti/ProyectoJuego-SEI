extends PanelContainer

enum Type { INPUT, IF, ELSE, PRINT }

var blockType: Type
var config: Dictionary = {}
var levelVars: Dictionary = {}
var isTemplate: bool = false

var innerDropZone = null
var label: Label
var paramContainer: HBoxContainer

const FONT_SIZE := 17
const COLOR_INPUT := Color(0.20, 0.45, 0.85, 1.0)
const COLOR_IF    := Color(0.65, 0.45, 0.08, 1.0)
const COLOR_ELSE  := Color(0.45, 0.15, 0.65, 1.0)
const COLOR_PRINT := Color(0.12, 0.52, 0.30, 1.0)

func setup(type: Type, vars: Dictionary, template: bool = false):
	blockType = type
	levelVars = vars
	isTemplate = template
	custom_minimum_size = Vector2(220, 44)
	_buildNodes()
	_buildUI()
	_applyStyle()

func _applyStyle():
	var style = StyleBoxFlat.new()
	match blockType:
		Type.INPUT: style.bg_color = COLOR_INPUT
		Type.IF:    style.bg_color = COLOR_IF
		Type.ELSE:  style.bg_color = COLOR_ELSE
		Type.PRINT: style.bg_color = COLOR_PRINT
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	add_theme_stylebox_override("panel", style)

func _buildNodes():
	for c in get_children():
		c.queue_free()

	var vbox = VBoxContainer.new()
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.add_theme_constant_override("separation", 6)
	add_child(vbox)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(hbox)

	label = Label.new()
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", FONT_SIZE)
	label.add_theme_color_override("font_color", Color(1, 1, 1))
	hbox.add_child(label)

	paramContainer = HBoxContainer.new()
	paramContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	paramContainer.add_theme_constant_override("separation", 6)
	hbox.add_child(paramContainer)

	# Subzona interior: solo si NO es template y es IF o ELSE
	if not isTemplate and (blockType == Type.IF or blockType == Type.ELSE):
		_buildInnerZone(vbox)

func _buildInnerZone(vbox: VBoxContainer):
	var ifBody = HBoxContainer.new()
	vbox.add_child(ifBody)

	var indent = ColorRect.new()
	indent.custom_minimum_size = Vector2(18, 0)
	indent.color = Color(1, 1, 1, 0.15)
	ifBody.add_child(indent)

	var innerPanel = PanelContainer.new()
	innerPanel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	innerPanel.custom_minimum_size = Vector2(0, 80)
	var innerStyle = StyleBoxFlat.new()
	innerStyle.bg_color = Color(0.08, 0.08, 0.12, 0.85)
	if blockType == Type.IF:
		innerStyle.border_color = Color(0.9, 0.75, 0.3, 0.6)
	else:
		innerStyle.border_color = Color(0.75, 0.4, 0.9, 0.6)
	innerStyle.border_width_left = 2
	innerStyle.border_width_right = 2
	innerStyle.border_width_top = 2
	innerStyle.border_width_bottom = 2
	innerStyle.corner_radius_top_left = 4
	innerStyle.corner_radius_top_right = 4
	innerStyle.corner_radius_bottom_left = 4
	innerStyle.corner_radius_bottom_right = 4
	innerStyle.content_margin_left = 10
	innerStyle.content_margin_right = 10
	innerStyle.content_margin_top = 10
	innerStyle.content_margin_bottom = 10
	innerPanel.add_theme_stylebox_override("panel", innerStyle)
	ifBody.add_child(innerPanel)

	var innerVBox = VBoxContainer.new()
	innerVBox.add_theme_constant_override("separation", 4)
	innerPanel.add_child(innerVBox)

	var hint = Label.new()
	hint.text = "  si verdadero:" if blockType == Type.IF else "  si no:"
	hint.add_theme_font_size_override("font_size", FONT_SIZE - 3)
	if blockType == Type.IF:
		hint.add_theme_color_override("font_color", Color(0.9, 0.75, 0.3, 0.8))
	else:
		hint.add_theme_color_override("font_color", Color(0.75, 0.4, 0.9, 0.8))
	innerVBox.add_child(hint)

	innerDropZone = VBoxContainer.new()
	innerDropZone.set_script(load("res://scripts/dropZone.gd"))
	innerDropZone.custom_minimum_size = Vector2(0, 60)
	innerDropZone.size_flags_vertical = Control.SIZE_EXPAND_FILL
	innerVBox.add_child(innerDropZone)

func _buildUI():
	label.text = _typeLabel(isTemplate)
	for c in paramContainer.get_children():
		c.queue_free()

	# template: solo el nombre, sin parametros ni selectores
	if isTemplate:
		return

	match blockType:
		Type.INPUT:
			_buildInputRow()
		Type.IF:
			_addVarSelector()
			_addOpSelector()
			_addIfValueSelector()
		Type.ELSE:
			pass
		Type.PRINT:
			_addPrintSelector()

func _buildInputRow():
	var hbox = label.get_parent()
	hbox.remove_child(label)
	hbox.remove_child(paramContainer)

	var opt = OptionButton.new()
	opt.add_theme_font_size_override("font_size", FONT_SIZE - 1)
	for varName in levelVars.keys():
		opt.add_item(varName)
	opt.item_selected.connect(func(i): config["var"] = opt.get_item_text(i))
	if opt.item_count > 0:
		config["var"] = opt.get_item_text(0)
	hbox.add_child(opt)

	var edit = LineEdit.new()
	edit.placeholder_text = "valor"
	edit.custom_minimum_size.x = 80
	edit.add_theme_font_size_override("font_size", FONT_SIZE - 1)
	edit.text_changed.connect(func(t): config["input_value"] = t)
	hbox.add_child(edit)

	label.text = "= input()"
	hbox.add_child(label)
	hbox.add_child(paramContainer)

func _typeLabel(template: bool = false) -> String:
	# en template: nombre compacto con parentesis
	# en instancia: solo la palabra clave
	if template:
		match blockType:
			Type.INPUT: return "input()"
			Type.IF:    return "if ()"
			Type.ELSE:  return "else ()"
			Type.PRINT: return "print()"
	else:
		match blockType:
			Type.INPUT: return "input()"
			Type.IF:    return "if"
			Type.ELSE:  return "else"
			Type.PRINT: return "print"
	return ""

func _addVarSelector():
	var opt = OptionButton.new()
	opt.add_theme_font_size_override("font_size", FONT_SIZE - 1)
	for varName in levelVars.keys():
		opt.add_item(varName)
	opt.item_selected.connect(func(i): config["var"] = opt.get_item_text(i))
	if opt.item_count > 0:
		config["var"] = opt.get_item_text(0)
	paramContainer.add_child(opt)

func _addOpSelector():
	var opt = OptionButton.new()
	opt.add_theme_font_size_override("font_size", FONT_SIZE - 1)
	opt.add_item("==")
	opt.add_item("!=")
	opt.item_selected.connect(func(i): config["op"] = opt.get_item_text(i))
	config["op"] = "=="
	paramContainer.add_child(opt)

func _addPrintSelector():
	var opt = OptionButton.new()
	opt.add_theme_font_size_override("font_size", FONT_SIZE - 1)
	# primero las variables disponibles
	for varName in levelVars.keys():
		opt.add_item(varName)
	# luego opcion texto literal
	opt.add_item("\"texto...\"")
	opt.item_selected.connect(func(i):
		var selected = opt.get_item_text(i)
		if selected == "\"texto...\"":
			config["value"] = ""
			_showTextInput()
		else:
			config["value"] = selected
			_hideTextInput()
	)
	if opt.item_count > 0:
		var first = opt.get_item_text(0)
		config["value"] = first if first != "\"texto...\"" else ""
	paramContainer.add_child(opt)

var _textEdit: LineEdit = null

func _showTextInput():
	if _textEdit != null:
		return
	_textEdit = LineEdit.new()
	_textEdit.placeholder_text = "valor"
	_textEdit.custom_minimum_size.x = 80
	_textEdit.add_theme_font_size_override("font_size", FONT_SIZE - 1)
	_textEdit.text_changed.connect(func(t): config["value"] = t)
	paramContainer.add_child(_textEdit)

func _hideTextInput():
	if _textEdit != null:
		_textEdit.queue_free()
		_textEdit = null

func _addIfValueSelector():
	var opt = OptionButton.new()
	opt.add_theme_font_size_override("font_size", FONT_SIZE - 1)
	# variables disponibles primero
	for varName in levelVars.keys():
		opt.add_item(varName)
	# luego texto literal
	opt.add_item("\"texto...\"")
	opt.item_selected.connect(func(i):
		var selected = opt.get_item_text(i)
		if selected == "\"texto...\"":
			config["value"] = ""
			config["value_is_var"] = false
			_showTextInput()
		else:
			config["value"] = selected
			config["value_is_var"] = true
			_hideTextInput()
	)
	if opt.item_count > 0:
		var first = opt.get_item_text(0)
		if first == "\"texto...\"":
			config["value"] = ""
			config["value_is_var"] = false
		else:
			config["value"] = first
			config["value_is_var"] = true
	paramContainer.add_child(opt)

func _addValueInput():
	var edit = LineEdit.new()
	edit.placeholder_text = "valor"
	edit.custom_minimum_size.x = 90
	edit.add_theme_font_size_override("font_size", FONT_SIZE - 1)
	edit.text_changed.connect(func(t): config["value"] = t)
	paramContainer.add_child(edit)

func execute(vars: Dictionary) -> Dictionary:
	var out = []
	match blockType:
		Type.INPUT:
			var varName = config.get("var", "")
			var inputVal = config.get("input_value", "")
			if varName != "" and inputVal != "":
				vars[varName] = inputVal
		Type.PRINT:
			var val = config.get("value", "")
			if vars.has(val):
				out.append(str(vars[val]))
			else:
				out.append(val.trim_prefix("\"").trim_suffix("\""))
		Type.IF:
			var varName = config.get("var", "")
			var op = config.get("op", "==")
			var rawVal = config.get("value", "")
			var varVal = str(vars.get(varName, ""))
			var val = str(vars.get(rawVal, rawVal.trim_prefix("\"").trim_suffix("\""))) if config.get("value_is_var", false) else rawVal.trim_prefix("\"").trim_suffix("\"")
			var cond = (varVal == val) if op == "==" else (varVal != val)
			if cond and innerDropZone != null:
				var innerResult = innerDropZone.execute(vars)
				out.append_array(innerResult)
			return {"output": out, "vars": vars, "condition": cond}
		Type.ELSE:
			return {"output": out, "vars": vars, "condition": false, "is_else": true}
	return {"output": out, "vars": vars, "condition": true}

func execute_else(vars: Dictionary) -> Array:
	if innerDropZone != null:
		return innerDropZone.execute(vars)
	return []

func _get_drag_data(_pos):
	var clone = duplicate()
	clone.isTemplate = false
	clone.setup(blockType, levelVars, false)
	set_drag_preview(clone)
	if isTemplate:
		return {"block_type": blockType, "vars": levelVars, "source": null}
	else:
		return {"block_type": blockType, "vars": levelVars, "source": self}

func setLocked():
	# bloquear drag
	set_drag_forwarding(Callable(), Callable(), Callable())
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# deshabilitar todos los controles interactivos
	_disableChildren(self)

	# estilo borde gris piedra
	var style = StyleBoxFlat.new()
	match blockType:
		Type.INPUT: style.bg_color = COLOR_INPUT.darkened(0.35)
		Type.IF:    style.bg_color = COLOR_IF.darkened(0.35)
		Type.ELSE:  style.bg_color = COLOR_ELSE.darkened(0.35)
		Type.PRINT: style.bg_color = COLOR_PRINT.darkened(0.35)
	style.border_color = Color(0.55, 0.55, 0.55, 1.0)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	add_theme_stylebox_override("panel", style)

func _disableChildren(node: Node):
	if node is Control and node != self:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if node is BaseButton:
			node.disabled = true
		if node is LineEdit:
			node.editable = false
		if node is OptionButton:
			node.disabled = true
	for child in node.get_children():
		_disableChildren(child)
