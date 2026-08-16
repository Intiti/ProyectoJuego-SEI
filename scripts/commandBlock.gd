extends PanelContainer

enum Type { INPUT, IF, PRINT }

var blockType: Type
var config: Dictionary = {}
var levelVars: Dictionary = {}
var isTemplate: bool = false

# Para bloques IF: zona interior
var innerDropZone = null

var label: Label
var paramContainer: HBoxContainer

const FONT_SIZE := 17

const COLOR_INPUT  := Color(0.20, 0.45, 0.85, 1.0)
const COLOR_IF     := Color(0.65, 0.45, 0.08, 1.0)
const COLOR_PRINT  := Color(0.12, 0.52, 0.30, 1.0)

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
		Type.INPUT:  style.bg_color = COLOR_INPUT
		Type.IF:     style.bg_color = COLOR_IF
		Type.PRINT:  style.bg_color = COLOR_PRINT
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

	# Zona interior del IF
	if blockType == Type.IF:
		var ifBody = HBoxContainer.new()
		vbox.add_child(ifBody)

		var indent = ColorRect.new()
		indent.custom_minimum_size = Vector2(18, 0)
		indent.color = Color(1, 1, 1, 0.15)
		ifBody.add_child(indent)

		var innerPanel = PanelContainer.new()
		innerPanel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var innerStyle = StyleBoxFlat.new()
		innerStyle.bg_color = Color(0.08, 0.08, 0.12, 0.85)
		innerStyle.border_color = Color(0.9, 0.75, 0.3, 0.6)
		innerStyle.border_width_left = 2
		innerStyle.border_width_right = 2
		innerStyle.border_width_top = 2
		innerStyle.border_width_bottom = 2
		innerStyle.corner_radius_top_left = 4
		innerStyle.corner_radius_top_right = 4
		innerStyle.corner_radius_bottom_left = 4
		innerStyle.corner_radius_bottom_right = 4
		innerStyle.content_margin_left = 8
		innerStyle.content_margin_right = 8
		innerStyle.content_margin_top = 6
		innerStyle.content_margin_bottom = 6
		innerPanel.add_theme_stylebox_override("panel", innerStyle)
		ifBody.add_child(innerPanel)

		var innerVBox = VBoxContainer.new()
		innerVBox.add_theme_constant_override("separation", 4)
		innerPanel.add_child(innerVBox)

		var hint = Label.new()
		hint.text = "  si verdadero:"
		hint.add_theme_font_size_override("font_size", FONT_SIZE - 3)
		hint.add_theme_color_override("font_color", Color(0.9, 0.75, 0.3, 0.8))
		innerVBox.add_child(hint)

		innerDropZone = VBoxContainer.new()
		innerDropZone.set_script(load("res://scripts/dropZone.gd"))
		innerDropZone.custom_minimum_size = Vector2(0, 40)
		innerVBox.add_child(innerDropZone)

func _buildUI():
	# En template, input() solo muestra "input()" sin parámetros
	# En drop zone, muestra "var = input"
	if blockType == Type.INPUT and isTemplate:
		label.text = "input()"
		label.custom_minimum_size = Vector2(0, 0)
		# Sin paramContainer en template para INPUT
		return

	label.text = _typeName()
	for c in paramContainer.get_children():
		c.queue_free()

	match blockType:
		Type.INPUT:
			# Selector de variable a la IZQUIERDA del label
			# Reordenar: primero var selector, luego "= input()"
			# El label ya fue agregado, lo reusamos pero cambiamos el orden
			# En su lugar, vaciar paramContainer y poner el selector antes del label
			_buildInputRow()
		Type.IF:
			_addVarSelector()
			_addOpSelector()
			_addValueInput()
		Type.PRINT:
			_addValueInput()

func _buildInputRow():
	# Para input en drop zone: [varSelector] = input()
	# El label dirá "= input()" y el selector irá antes
	# Pero el label ya está en hbox antes de paramContainer
	# Solución: poner el selector en paramContainer y poner el label después
	# Limpiamos y reconstruimos el hbox
	var hbox = label.get_parent()
	# Quitar label del hbox temporalmente
	hbox.remove_child(label)
	hbox.remove_child(paramContainer)

	# 1. Selector de variable
	var opt = OptionButton.new()
	opt.add_theme_font_size_override("font_size", FONT_SIZE - 1)
	for varName in levelVars.keys():
		opt.add_item(varName)
	opt.item_selected.connect(func(i): config["var"] = opt.get_item_text(i))
	if opt.item_count > 0:
		config["var"] = opt.get_item_text(0)
	hbox.add_child(opt)

	# 2. Label "= input()"
	label.text = "= input()"
	label.custom_minimum_size = Vector2(0, 0)
	hbox.add_child(label)

	# 3. paramContainer vacío al final (por si acaso)
	hbox.add_child(paramContainer)

func _typeName() -> String:
	match blockType:
		Type.INPUT: return "input()"
		Type.IF:    return "if"
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
			# Ya está capturado en vars desde levelVars
			pass
		Type.PRINT:
			var val = config.get("value", "")
			if vars.has(val):
				out.append(str(vars[val]))
			else:
				out.append(val.trim_prefix("\"").trim_suffix("\""))
		Type.IF:
			var varName = config.get("var", "")
			var op = config.get("op", "==")
			var val = config.get("value", "").trim_prefix("\"").trim_suffix("\"")
			var varVal = str(vars.get(varName, ""))
			var cond = (varVal == val) if op == "==" else (varVal != val)
			if cond and innerDropZone != null:
				var innerResult = innerDropZone.execute(vars)
				out.append_array(innerResult)
			return {"output": out, "vars": vars, "condition": cond}
	return {"output": out, "vars": vars, "condition": true}

func _get_drag_data(_pos):
	# Tanto templates como bloques ya colocados pueden arrastrarse
	var clone = duplicate()
	clone.isTemplate = false
	clone.setup(blockType, levelVars, false)
	set_drag_preview(clone)
	if isTemplate:
		return {"block_type": blockType, "vars": levelVars, "source": null}
	else:
		return {"block_type": blockType, "vars": levelVars, "source": self}
