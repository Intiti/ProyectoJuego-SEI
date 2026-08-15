extends VBoxContainer

# columna derecha con los bloques disponibles (templates)
func setup(commands: Array, vars: Dictionary):
	for c in get_children():
		c.queue_free()

	for cmd in commands:
		var type = _nameToType(cmd)
		var block = preload("res://scenes/CommandBlock.tscn").instantiate()
		block.setup(type, vars, true)  # true = es template, no se mueve
		add_child(block)

func _nameToType(name: String) -> int:
	match name:
		"input": return 0   # Type.INPUT
		"if":    return 1   # Type.IF
		"print": return 2   # Type.PRINT
	return 2
