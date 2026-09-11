extends VBoxContainer

signal blockClicked(blockType: int, vars: Dictionary)

func setup(commands: Array, vars: Dictionary):
	for c in get_children():
		c.queue_free()

	for cmd in commands:
		var type = _nameToType(cmd)
		var block = preload("res://scenes/CommandBlock.tscn").instantiate()
		block.setup(type, vars, true)
		block.clicked.connect(_onBlockClicked)
		add_child(block)

		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(0, 6)
		add_child(spacer)

func _onBlockClicked(block):
	blockClicked.emit(block.blockType, block.levelVars)

func _nameToType(name: String) -> int:
	match name:
		"input":  return 0
		"if":     return 1
		"else":   return 2
		"print":  return 3
		"assign": return 4
		"expr":   return 5
	return 3
