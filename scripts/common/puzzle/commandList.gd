extends VBoxContainer

# Emite el bloque de alternativa seleccionado (puede ser correcto o incorrecto)
signal alternativeChosen(block)

# Llena el panel con las alternativas del paso actual
# alternatives: Array de Dictionaries con claves:
#   "type": String (input/if/else/print/assign/expr)
#   "text": String (texto visible en el bloque)
#   "correct": bool
#   "config": Dictionary (datos de ejecución, solo para el correcto)
func setup(alternatives: Array):
	for c in get_children():
		c.queue_free()

	for alt in alternatives:
		var type = _nameToType(alt.get("type", "print"))
		var block = preload("res://scenes/common/ui/CommandBlock.tscn").instantiate()
		block.setupAlternative(
			type,
			alt.get("text", ""),
			alt.get("correct", false),
			alt.get("config", {})
		)
		block.clicked.connect(_onBlockClicked)
		add_child(block)

		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(0, 6)
		add_child(spacer)

func _onBlockClicked(block):
	alternativeChosen.emit(block)

func _nameToType(name: String) -> int:
	match name:
		"input":  return 0
		"if":     return 1
		"else":   return 2
		"print":  return 3
		"assign": return 4
		"expr":   return 5
		"elif":   return 6
	return 3
