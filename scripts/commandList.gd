extends VBoxContainer

func setup(commands: Array, vars: Dictionary):
	for c in get_children():
		c.queue_free()

	for cmd in commands:
		var type = _nameToType(cmd)
		var block = preload("res://scenes/CommandBlock.tscn").instantiate()
		block.setup(type, vars, true)
		add_child(block)

		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(0, 6)
		add_child(spacer)

func _nameToType(name: String) -> int:
	match name:
		"input": return 0
		"if":    return 1
		"print": return 2
	return 2
