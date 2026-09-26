extends PanelContainer

enum Type { INPUT, IF, ELSE, PRINT, ASSIGN, EXPR }

var blockType: Type
var config: Dictionary = {}
var isTemplate: bool = false
var indentLevel: int = 0

# Para bloques de alternativa: texto fijo visible y si es correcto
var displayText: String = ""
var isCorrect: bool = false

var label: Label

const FONT_SIZE := 17
const COLOR_INPUT  := Color(0.20, 0.45, 0.85, 1.0)
const COLOR_IF     := Color(0.65, 0.45, 0.08, 1.0)
const COLOR_ELSE   := Color(0.45, 0.15, 0.65, 1.0)
const COLOR_PRINT  := Color(0.12, 0.52, 0.30, 1.0)
const COLOR_ASSIGN := Color(0.50, 0.20, 0.20, 1.0)
const COLOR_EXPR   := Color(0.20, 0.55, 0.60, 1.0)

signal clicked(block)

# Setup para bloques de alternativa (panel de opciones)
func setupAlternative(type: Type, text: String, correct: bool, cfg: Dictionary = {}):
	blockType = type
	displayText = text
	isCorrect = correct
	config = cfg.duplicate()
	isTemplate = true
	indentLevel = 0
	custom_minimum_size = Vector2(220, 44)
	_buildNodes()
	_applyStyle()
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	gui_input.connect(_onGuiInput)

# Setup para bloques ya colocados en la zona (solo color + texto fijo, sin controles)
func setupPlaced(type: Type, text: String, cfg: Dictionary = {}, indent: int = 0):
	blockType = type
	displayText = text
	isCorrect = false
	config = cfg.duplicate()
	isTemplate = false
	indentLevel = indent
	custom_minimum_size = Vector2(220, 44)
	_buildNodes()
	_applyStyle()

func _onGuiInput(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)

func _applyStyle():
	var style = StyleBoxFlat.new()
	match blockType:
		Type.INPUT:  style.bg_color = COLOR_INPUT
		Type.IF:     style.bg_color = COLOR_IF
		Type.ELSE:   style.bg_color = COLOR_ELSE
		Type.PRINT:  style.bg_color = COLOR_PRINT
		Type.ASSIGN: style.bg_color = COLOR_ASSIGN
		Type.EXPR:   style.bg_color = COLOR_EXPR
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

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	add_child(hbox)

	label = Label.new()
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", FONT_SIZE)
	label.add_theme_color_override("font_color", Color(1, 1, 1))
	label.text = displayText
	hbox.add_child(label)

func execute(vars: Dictionary, inputQueue: Array = []) -> Dictionary:
	var out = []
	match blockType:
		Type.INPUT:
			var varName = config.get("var", "")
			var val = config.get("value", "")
			if varName != "":
				if inputQueue.size() > 0:
					vars[varName] = inputQueue.pop_front()
				elif val != "":
					vars[varName] = val
		Type.EXPR:
			var varName = config.get("var", "")
			if varName != "":
				var a = vars.get(config.get("expr_a", ""), 0)
				var b = vars.get(config.get("expr_b", ""), 0)
				var op = config.get("expr_op", "+")
				var result = 0.0
				match op:
					"+": result = float(str(a)) + float(str(b))
					"-": result = float(str(a)) - float(str(b))
					"*": result = float(str(a)) * float(str(b))
					"/":
						if float(str(b)) != 0.0:
							result = float(str(a)) / float(str(b))
						else:
							out.append("Error: division por cero")
				vars[varName] = int(result) if result == int(result) else result
		Type.ASSIGN:
			var varName = config.get("var", "")
			if varName != "":
				vars[varName] = config.get("assign_value", "")
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
			var leftRaw = vars.get(varName, "")
			var valueIsVar = config.get("value_is_var", false)
			var rightRaw = vars.get(rawVal, rawVal) if valueIsVar else rawVal.trim_prefix("\"").trim_suffix("\"")
			var cond = _compare(leftRaw, op, rightRaw)
			return {"output": out, "vars": vars, "condition": cond}
		Type.ELSE:
			return {"output": out, "vars": vars, "condition": false, "is_else": true}
	return {"output": out, "vars": vars, "condition": true}

func _compare(left, op: String, right) -> bool:
	var l = float(str(left)) if str(left).is_valid_float() else null
	var r = float(str(right)) if str(right).is_valid_float() else null
	if l != null and r != null:
		match op:
			"==": return l == r
			"!=": return l != r
			"<":  return l < r
			">":  return l > r
			"<=": return l <= r
			">=": return l >= r
	match op:
		"==": return str(left) == str(right)
		"!=": return str(left) != str(right)
	return false

func setLocked():
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style = StyleBoxFlat.new()
	match blockType:
		Type.INPUT:  style.bg_color = COLOR_INPUT.darkened(0.35)
		Type.IF:     style.bg_color = COLOR_IF.darkened(0.35)
		Type.ELSE:   style.bg_color = COLOR_ELSE.darkened(0.35)
		Type.PRINT:  style.bg_color = COLOR_PRINT.darkened(0.35)
		Type.ASSIGN: style.bg_color = COLOR_ASSIGN.darkened(0.35)
		Type.EXPR:   style.bg_color = COLOR_EXPR.darkened(0.35)
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
