extends VBoxContainer

# bloques colocados en orden
var blocks: Array = []
var levelVars: Dictionary = {}

func setup(vars: Dictionary):
	levelVars = vars

func clear():
	blocks = []
	for c in get_children():
		c.queue_free()

# acepta drops de bloques
func _can_drop_data(_pos, data) -> bool:
	return data is Dictionary and data.has("block_type")

func _drop_data(_pos, data):
	_addBlock(data["block_type"], data["vars"])

func _addBlock(type: int, vars: Dictionary):
	var block = preload("res://scenes/CommandBlock.tscn").instantiate()
	block.setup(type, vars, false)
	# boton para eliminar el bloque
	var btn = Button.new()
	btn.text = "x"
	btn.custom_minimum_size.x = 24
	var row = HBoxContainer.new()
	row.add_child(block)
	row.add_child(btn)
	add_child(row)
	blocks.append(block)
	btn.pressed.connect(func():
		blocks.erase(block)
		row.queue_free()
	)

# ejecuta todos los bloques en orden y retorna el output
func execute(vars: Dictionary) -> Array:
	var output = []
	var i = 0
	while i < blocks.size():
		var block = blocks[i]
		var result = block.execute(vars)
		output.append_array(result["output"])
		vars = result["vars"]

		# si es IF, el siguiente bloque solo corre si la condicion es true
		if block.blockType == block.Type.IF:
			i += 1
			if i < blocks.size() and result.get("condition", false):
				var inner = blocks[i].execute(vars)
				output.append_array(inner["output"])
				vars = inner["vars"]
		else:
			i += 1
	return output
