extends VBoxContainer

var blocks: Array = []
var levelVars: Dictionary = {}

func setup(vars: Dictionary):
	levelVars = vars

func clear():
	blocks = []
	for c in get_children():
		c.queue_free()

func _can_drop_data(_pos, data) -> bool:
	return data is Dictionary and data.has("block_type")

func _drop_data(_pos, data):
	# Si viene de otro bloque ya colocado dentro del dropzone, lo movemos
	var source = data.get("source", null)
	if source != null and is_instance_valid(source):
		# Buscamos el row que contiene ese bloque y lo eliminamos
		for row in get_children():
			if row is HBoxContainer:
				for child in row.get_children():
					if child == source:
						blocks.erase(source)
						row.queue_free()
						break

	_addBlock(data["block_type"], data["vars"])

func _addBlock(type: int, vars: Dictionary):
	var block = preload("res://scenes/CommandBlock.tscn").instantiate()
	block.setup(type, vars, false)

	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.add_child(block)

	var btn = Button.new()
	btn.text = "x"
	btn.custom_minimum_size = Vector2(30, 30)
	btn.add_theme_font_size_override("font_size", 14)
	row.add_child(btn)

	add_child(row)
	blocks.append(block)

	# Animacion juicy: escala desde 0 a 1
	block.scale = Vector2(0.5, 0.5)
	block.modulate.a = 0.0
	var tween = block.create_tween()
	tween.set_parallel(true)
	tween.tween_property(block, "scale", Vector2(1.0, 1.0), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(block, "modulate:a", 1.0, 0.12)

	btn.pressed.connect(func():
		# Animacion juicy al eliminar
		var t = block.create_tween()
		t.set_parallel(true)
		t.tween_property(block, "scale", Vector2(0.5, 0.5), 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		t.tween_property(row, "modulate:a", 0.0, 0.14)
		t.chain().tween_callback(func():
			blocks.erase(block)
			row.queue_free()
		)
	)

func execute(vars: Dictionary) -> Array:
	var output = []
	for block in blocks:
		var result = block.execute(vars)
		output.append_array(result["output"])
		vars = result["vars"]
	return output
