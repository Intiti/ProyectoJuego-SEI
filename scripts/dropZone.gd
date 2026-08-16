extends VBoxContainer

var blocks: Array = []
var levelVars: Dictionary = {}
var _shadowPlaceholder: Control = null

# Variable estática compartida entre todas las instancias de dropZone
# Así solo UN dropzone tiene el fantasma activo en cualquier momento
static var _activeDragZone: VBoxContainer = null
static var _activeDragData = null

func setup(vars: Dictionary):
	levelVars = vars

func clear():
	blocks = []
	for c in get_children():
		c.queue_free()
	_shadowPlaceholder = null

func _can_drop_data(pos, data) -> bool:
	if not (data is Dictionary and data.has("block_type")):
		_relinquishShadow()
		return false

	# Este dropzone reclama ser el activo — quita la sombra de cualquier otro
	if _activeDragZone != self:
		if _activeDragZone != null and is_instance_valid(_activeDragZone):
			_activeDragZone._removeShadow()
		_activeDragZone = self
		_activeDragData = data

	_updateShadow(pos, data)
	return true

func _drop_data(pos, data):
	_removeShadow()
	_activeDragZone = null
	_activeDragData = null

	var source = data.get("source", null)
	if source != null and is_instance_valid(source):
		for row in get_children():
			if row is HBoxContainer:
				for child in row.get_children():
					if child == source:
						blocks.erase(source)
						row.queue_free()
						break

	var insertIdx = _getInsertIndex(pos)
	_addBlockAt(data["block_type"], data["vars"], insertIdx)

func _relinquishShadow():
	# Solo quitar la sombra si somos el dropzone activo
	if _activeDragZone == self:
		_removeShadow()
		_activeDragZone = null

func _removeShadow():
	if _shadowPlaceholder != null and is_instance_valid(_shadowPlaceholder):
		_shadowPlaceholder.queue_free()
	_shadowPlaceholder = null

func _updateShadow(pos: Vector2, data: Dictionary):
	var idx = _getInsertIndex(pos)

	# Crear sombra si no existe — copia visual del bloque que se arrastra
	if _shadowPlaceholder == null or not is_instance_valid(_shadowPlaceholder):
		_shadowPlaceholder = _makeShadow(data)
		add_child(_shadowPlaceholder)

	# Mover al slot correcto sin contar la sombra misma
	var target = min(idx, get_child_count() - 1)
	if _shadowPlaceholder.get_index() != target:
		move_child(_shadowPlaceholder, target)

func _makeShadow(data: Dictionary) -> Control:
	# Crear una copia visual real del bloque, semitransparente
	var block = preload("res://scenes/CommandBlock.tscn").instantiate()
	block.setup(data["block_type"], data["vars"], false)
	block.modulate.a = 0.45
	block.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Deshabilitar input en todos los hijos para que no interfieran
	_disableInput(block)

	var wrapper = HBoxContainer.new()
	wrapper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrapper.add_child(block)
	# Espacio equivalente al botón X para que el ancho coincida
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(36, 0)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrapper.add_child(spacer)
	return wrapper

func _disableInput(node: Node):
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_disableInput(child)

func _getInsertIndex(pos: Vector2) -> int:
	for i in get_child_count():
		var child = get_child(i)
		if child == _shadowPlaceholder:
			continue
		if pos.y < child.position.y + child.size.y * 0.5:
			return i
	return get_child_count()

func _addBlockAt(type: int, vars: Dictionary, idx: int = -1):
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

	if idx >= 0 and idx < get_child_count():
		add_child(row)
		move_child(row, idx)
	else:
		add_child(row)

	blocks.append(block)

	block.scale = Vector2(0.5, 0.5)
	block.modulate.a = 0.0
	var tween = block.create_tween()
	tween.set_parallel(true)
	tween.tween_property(block, "scale", Vector2(1.0, 1.0), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(block, "modulate:a", 1.0, 0.12)

	btn.pressed.connect(func():
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
	var i = 0
	while i < blocks.size():
		var block = blocks[i]
		var result = block.execute(vars)
		output.append_array(result["output"])
		vars = result["vars"]

		if not result.get("is_else", false) and i + 1 < blocks.size():
			var nextBlock = blocks[i + 1]
			if nextBlock.blockType == nextBlock.Type.ELSE:
				if not result.get("condition", true):
					output.append_array(nextBlock.execute_else(vars))
				i += 2
				continue
		i += 1
	return output
