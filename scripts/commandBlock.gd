extends PanelContainer

enum Type { INPUT, IF, PRINT }

var blockType: Type
var config: Dictionary = {}
var levelVars: Dictionary = {}
var isTemplate: bool = false

var label: Label
var paramContainer: HBoxContainer

func setup(type: Type, vars: Dictionary, template: bool = false):
	blockType = type
	levelVars = vars
	isTemplate = template
	custom_minimum_size = Vector2(200, 40)
	_buildNodes()
	_buildUI()

func _buildNodes():
	for c in get_children():
		c.queue_free()

	var hbox = HBoxContainer.new()
	hbox.anchor_right = 1.0
	hbox.anchor_bottom = 1.0
	add_child(hbox)

	label = Label.new()
	label.custom_minimum_size = Vector2(70, 0)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(label)

	paramContainer = HBoxContainer.new()
	paramContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(paramContainer)

func _buildUI():
	label.text = _typeName()
	for c in paramContainer.get_children():
		c.queue_free()

	match blockType:
		Type.INPUT:
			_addVarSelector()
		Type.IF:
			_addVarSelector()
			_addOpSelector()
			_addValueInput()
		Type.PRINT:
			_addValueInput()

func _typeName() -> String:
	match blockType:
		Type.INPUT: return "input()"
		Type.IF:    return "if"
		Type.PRINT: return "print"
	return ""

func _addVarSelector():
	var opt = OptionButton.new()
	for varName in levelVars.keys():
		opt.add_item(varName)
	opt.item_selected.connect(func(i): config["var"] = opt.get_item_text(i))
	if opt.item_count > 0:
		config["var"] = opt.get_item_text(0)
	paramContainer.add_child(opt)

func _addOpSelector():
	var opt = OptionButton.new()
	opt.add_item("==")
	opt.add_item("!=")
	opt.item_selected.connect(func(i): config["op"] = opt.get_item_text(i))
	config["op"] = "=="
	paramContainer.add_child(opt)

func _addValueInput():
	var edit = LineEdit.new()
	edit.placeholder_text = "valor"
	edit.custom_minimum_size.x = 80
	edit.text_changed.connect(func(t): config["value"] = t)
	paramContainer.add_child(edit)

func execute(vars: Dictionary) -> Dictionary:
	var out = []
	match blockType:
		Type.INPUT:
			var varName = config.get("var", "")
			if varName and vars.has(varName):
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
			return {"output": out, "vars": vars, "condition": cond}
	return {"output": out, "vars": vars, "condition": true}

func _get_drag_data(_pos):
	if isTemplate:
		var clone = duplicate()
		clone.isTemplate = false
		clone.setup(blockType, levelVars, false)
		set_drag_preview(clone)
		return {"block_type": blockType, "vars": levelVars}
	return null
