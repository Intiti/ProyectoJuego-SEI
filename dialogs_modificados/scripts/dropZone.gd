extends VBoxContainer

var blocks: Array = []
var levelVars: Dictionary = {}

const INDENT_PX := 28

func setup(vars: Dictionary, prefilled: Array = []):
	levelVars = vars
	add_to_group("drop_zone")
	for entry in prefilled:
		_addPrefilledBlock(entry)

func _addPrefilledBlock(entry: Dictionary):
	var typeStr = entry.get("type", "")
	var typeEnum = _typeStrToEnum(typeStr)
	if typeEnum < 0:
		return

	var block = preload("res://scenes/CommandBlock.tscn").instantiate()
	block.setup(typeEnum, levelVars, false, 0)

	var varName = entry.get("var", "")
	if varName != "":
		block.config["var"] = varName
		_selectVarInBlock(block, varName)

	block.setLocked()

	var row = _makeRow(block, 0, false)
	add_child(row)
	blocks.append({"block": block, "indent": 0, "locked": true})

func _selectVarInBlock(block: Node, varName: String):
	for child in block.get_children():
		_selectVarRecursive(child, varName)

func _selectVarRecursive(node: Node, varName: String):
	if node is OptionButton:
		for i in node.item_count:
			if node.get_item_text(i) == varName:
				node.select(i)
				return
	for child in node.get_children():
		_selectVarRecursive(child, varName)

func _typeStrToEnum(s: String) -> int:
	var cb = preload("res://scenes/CommandBlock.tscn").instantiate()
	var result = -1
	match s:
		"input":  result = cb.Type.INPUT
		"if":     result = cb.Type.IF
		"else":   result = cb.Type.ELSE
		"print":  result = cb.Type.PRINT
		"assign": result = cb.Type.ASSIGN
		"expr":   result = cb.Type.EXPR
	cb.queue_free()
	return result

func clear():
	blocks = []
	for c in get_children():
		c.queue_free()

func addBlock(type: int, vars: Dictionary):
	var indent = _computeNextIndent(type)

	var block = preload("res://scenes/CommandBlock.tscn").instantiate()
	block.setup(type, vars, false, indent)

	var row = _makeRow(block, indent, true)
	add_child(row)
	blocks.append({"block": block, "indent": indent, "locked": false})

	block.scale = Vector2(0.85, 0.85)
	block.modulate.a = 0.0
	var tween = block.create_tween()
	tween.set_parallel(true)
	tween.tween_property(block, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(block, "modulate:a", 1.0, 0.10)

func _computeNextIndent(incomingType: int) -> int:
	var cbRef = preload("res://scenes/CommandBlock.tscn").instantiate()
	var IF_TYPE = cbRef.Type.IF
	var ELSE_TYPE = cbRef.Type.ELSE
	cbRef.queue_free()

	if blocks.is_empty():
		return 0

	var lastEntry = blocks[blocks.size() - 1]
	var lastBlock = lastEntry["block"]
	var lastIndent = lastEntry["indent"]

	if lastBlock.blockType == IF_TYPE or lastBlock.blockType == ELSE_TYPE:
		if incomingType != ELSE_TYPE:
			return lastIndent + 1

	if incomingType == ELSE_TYPE:
		for i in range(blocks.size() - 1, -1, -1):
			var entry = blocks[i]
			if entry["block"].blockType == IF_TYPE and entry["indent"] == lastIndent:
				return entry["indent"]
			if entry["indent"] < lastIndent:
				break
		return max(0, lastIndent - 1)

	return lastIndent

func _makeRow(block: Node, indent: int, removable: bool) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)

	if indent > 0:
		var indentSpacer = Control.new()
		indentSpacer.custom_minimum_size = Vector2(indent * INDENT_PX, 0)
		row.add_child(indentSpacer)

	row.add_child(block)

	if removable:
		var btn = Button.new()
		btn.text = "x"
		btn.custom_minimum_size = Vector2(30, 30)
		btn.add_theme_font_size_override("font_size", 14)
		btn.pressed.connect(func():
			removeLastBlock()
		)
		row.add_child(btn)
	else:
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(34, 0)
		row.add_child(spacer)

	return row

func removeLastBlock():
	for i in range(blocks.size() - 1, -1, -1):
		if not blocks[i]["locked"]:
			var row = _getRowForBlockIndex(i)
			if row != null:
				blocks.remove_at(i)
				row.queue_free()
			return

func _getRowForBlockIndex(blockIdx: int) -> HBoxContainer:
	var count = 0
	for child in get_children():
		if child is HBoxContainer:
			if count == blockIdx:
				return child
			count += 1
	return null

func execute(vars: Dictionary, inputQueue: Array = []) -> Array:
	var output = []
	var skipUntilIndent := -1
	var i = 0
	while i < blocks.size():
		var entry = blocks[i]
		var block = entry["block"]
		var indent = entry["indent"]

		if skipUntilIndent >= 0:
			if indent > skipUntilIndent:
				i += 1
				continue
			else:
				if block.blockType == block.Type.ELSE and indent == skipUntilIndent:
					skipUntilIndent = -1
					i += 1
					continue
				skipUntilIndent = -1

		var result = block.execute(vars, inputQueue)
		output.append_array(result["output"])
		vars = result["vars"]

		if block.blockType == block.Type.IF:
			if not result.get("condition", true):
				skipUntilIndent = indent
		elif block.blockType == block.Type.ELSE:
			skipUntilIndent = indent

		i += 1
	return output
