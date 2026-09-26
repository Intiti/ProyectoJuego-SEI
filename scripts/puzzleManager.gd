extends CanvasLayer

@export var levelPrompt: String = ""
@export var expectedOutput: Array = []
@export var levelVars: Dictionary = {}

var panel: ColorRect
var promptLabel: RichTextLabel
var dropZone: VBoxContainer
var commandList: VBoxContainer
var outputLabel: Label
var feedbackLabel: Label
var stepLabel: Label

var isOpen: bool = false
var _currentData: Dictionary = {}
var _activeNpc: Node = null  # NPC que abrió este puzzle

var _steps: Array = []
var _currentStep: int = 0  # índice dentro de _steps (incluye fixed)

# Configuración del nivel
var showOutput: bool = true
var completeOnSteps: bool = false

# Nodos de slot en dropZone, uno por cada step (en orden)
# Cada entrada: { "type": "fixed"|"empty"|"filled", "node": Node, "arrow": Label|null }
var _slots: Array = []

const FONT_SIZE := 18

func _ready():
	add_to_group("puzzle")

	panel = ColorRect.new()
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.color = Color(0.14, 0.11, 0.06, 0.97)
	panel.visible = false
	add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.offset_left = 32.0
	vbox.offset_top = 32.0
	vbox.offset_right = -32.0
	vbox.offset_bottom = -32.0
	vbox.add_theme_constant_override("separation", 16)
	panel.add_child(vbox)

	var titleLabel = Label.new()
	titleLabel.text = "Instruccion del nivel"
	titleLabel.add_theme_font_size_override("font_size", FONT_SIZE + 2)
	titleLabel.add_theme_color_override("font_color", Color(0.9, 0.85, 1.0))
	vbox.add_child(titleLabel)

	promptLabel = RichTextLabel.new()
	promptLabel.bbcode_enabled = true
	promptLabel.custom_minimum_size = Vector2(0, 80)
	promptLabel.fit_content = true
	promptLabel.scroll_active = false
	promptLabel.add_theme_font_size_override("normal_font_size", FONT_SIZE)
	promptLabel.add_theme_color_override("default_color", Color(0.92, 0.92, 0.92))
	vbox.add_child(promptLabel)

	var hbox = HBoxContainer.new()
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 16)
	vbox.add_child(hbox)

	# --- Panel consola (izquierda) ---
	var consoleWrapper = PanelContainer.new()
	consoleWrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	consoleWrapper.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var consoleStyle = StyleBoxFlat.new()
	consoleStyle.bg_color = Color(0.07, 0.07, 0.10, 1.0)
	consoleStyle.border_color = Color(0.4, 0.7, 0.4, 0.8)
	consoleStyle.border_width_left = 2
	consoleStyle.border_width_right = 2
	consoleStyle.border_width_top = 2
	consoleStyle.border_width_bottom = 2
	consoleStyle.corner_radius_top_left = 6
	consoleStyle.corner_radius_top_right = 6
	consoleStyle.corner_radius_bottom_left = 6
	consoleStyle.corner_radius_bottom_right = 6
	consoleStyle.content_margin_left = 12
	consoleStyle.content_margin_right = 12
	consoleStyle.content_margin_top = 12
	consoleStyle.content_margin_bottom = 12
	consoleWrapper.add_theme_stylebox_override("panel", consoleStyle)
	hbox.add_child(consoleWrapper)

	var consoleInner = VBoxContainer.new()
	consoleInner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	consoleInner.size_flags_vertical = Control.SIZE_EXPAND_FILL
	consoleWrapper.add_child(consoleInner)

	var consoleTitle = Label.new()
	consoleTitle.text = "Consola"
	consoleTitle.add_theme_font_size_override("font_size", FONT_SIZE - 2)
	consoleTitle.add_theme_color_override("font_color", Color(0.5, 0.9, 0.5))
	consoleInner.add_child(consoleTitle)

	var scrollContainer = ScrollContainer.new()
	scrollContainer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scrollContainer.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	consoleInner.add_child(scrollContainer)

	dropZone = VBoxContainer.new()
	dropZone.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dropZone.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dropZone.set_script(load("res://scripts/dropZone.gd"))
	dropZone.add_theme_constant_override("separation", 4)
	scrollContainer.add_child(dropZone)

	var sep = VSeparator.new()
	hbox.add_child(sep)

	# --- Panel alternativas (derecha) ---
	var cmdWrapper = VBoxContainer.new()
	cmdWrapper.custom_minimum_size = Vector2(300, 0)
	cmdWrapper.add_theme_constant_override("separation", 8)
	hbox.add_child(cmdWrapper)

	var cmdTitle = Label.new()
	cmdTitle.text = "¿Cuál línea sigue?"
	cmdTitle.add_theme_font_size_override("font_size", FONT_SIZE - 2)
	cmdTitle.add_theme_color_override("font_color", Color(0.5, 0.9, 0.6))
	cmdWrapper.add_child(cmdTitle)

	stepLabel = Label.new()
	stepLabel.add_theme_font_size_override("font_size", FONT_SIZE - 4)
	stepLabel.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	cmdWrapper.add_child(stepLabel)

	commandList = VBoxContainer.new()
	commandList.size_flags_vertical = Control.SIZE_EXPAND_FILL
	commandList.set_script(load("res://scripts/commandList.gd"))
	cmdWrapper.add_child(commandList)

	feedbackLabel = Label.new()
	feedbackLabel.custom_minimum_size = Vector2(0, 36)
	feedbackLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedbackLabel.add_theme_font_size_override("font_size", FONT_SIZE - 1)
	feedbackLabel.visible = false
	cmdWrapper.add_child(feedbackLabel)

	outputLabel = Label.new()
	outputLabel.custom_minimum_size = Vector2(0, 60)
	outputLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	outputLabel.add_theme_font_size_override("font_size", FONT_SIZE)
	vbox.add_child(outputLabel)

func _colorizePrompt(text: String) -> String:
	var result = text
	result = result.replace("input()", "[color=#7eb8f7]input()[/color]")
	result = result.replace("print", "[color=#7defa0]print[/color]")
	result = result.replace("Si no", "[color=#c084fc]Si no[/color]")
	result = result.replace("Si el", "[color=#f0d060]Si[/color] el")
	return result

func open(data: Dictionary, npc: Node = null):
	if isOpen:
		return
	isOpen = true
	_currentData = data
	_activeNpc = npc

	levelPrompt = data.get("prompt", "")
	expectedOutput = data.get("expected_output", [])
	levelVars = data.get("variables", {})
	_steps = data.get("steps", [])
	showOutput = data.get("show_output", true)
	completeOnSteps = data.get("complete_on_steps", false)
	_currentStep = 0
	_slots = []

	promptLabel.text = _colorizePrompt(levelPrompt)
	outputLabel.text = ""
	outputLabel.visible = showOutput
	feedbackLabel.visible = false

	dropZone.clear()
	dropZone.setup(levelVars, [])

	# Construir todos los slots de una vez (fijos + vacíos bordeados)
	_buildAllSlots()

	# Apuntar la flecha al primer slot vacío y cargar sus alternativas
	_loadCurrentStep()

	panel.visible = true

	var player = get_tree().get_first_node_in_group("player")
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	player.set_process_input(false)

# Crea TODOS los slots en orden: fijos completos, vacíos bordeados para los que hay que elegir
func _buildAllSlots():
	for i in _steps.size():
		var step = _steps[i]
		var indent = step.get("indent", 0)

		# Contenedor de fila: flecha + bloque
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 4)
		dropZone.add_child(row)

		# Flecha (inicialmente invisible)
		var arrow = Label.new()
		arrow.text = "▶"
		arrow.add_theme_font_size_override("font_size", FONT_SIZE)
		arrow.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		arrow.custom_minimum_size = Vector2(20, 0)
		arrow.visible = false
		row.add_child(arrow)

		# Indentación
		if indent > 0:
			var spacer = Control.new()
			spacer.custom_minimum_size = Vector2(indent * 20, 0)
			row.add_child(spacer)

		if step.get("fixed", false):
			# Bloque fijo completo
			var block = preload("res://scenes/CommandBlock.tscn").instantiate()
			block.setupPlaced(_nameToType(step.get("type", "print")), step.get("text", ""), step.get("config", {}), indent)
			block.setLocked()
			row.add_child(block)
			_slots.append({"kind": "fixed", "row": row, "block": block, "arrow": arrow, "step_idx": i})
		else:
			# Slot vacío bordeado
			var emptySlot = _makeEmptySlot(step)
			row.add_child(emptySlot)
			_slots.append({"kind": "empty", "row": row, "slot_node": emptySlot, "arrow": arrow, "step_idx": i})

# Crea un bloque vacío con borde punteado que indica "aquí va algo"
func _makeEmptySlot(step: Dictionary) -> PanelContainer:
	var pc = PanelContainer.new()
	pc.custom_minimum_size = Vector2(220, 44)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.10, 0.14, 1.0)
	style.border_color = Color(0.55, 0.55, 0.65, 0.7)
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
	pc.add_theme_stylebox_override("panel", style)

	var lbl = Label.new()
	lbl.text = "_ _ _"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_color_override("font_color", Color(0.45, 0.45, 0.55))
	lbl.add_theme_font_size_override("font_size", FONT_SIZE - 2)
	pc.add_child(lbl)

	return pc

# Busca el primer slot vacío a partir de _currentStep y apunta la flecha ahí
func _loadCurrentStep():
	# Apagar todas las flechas
	for slot in _slots:
		slot["arrow"].visible = false

	# Buscar el primer slot "empty" desde _currentStep en adelante
	while _currentStep < _steps.size():
		if not _steps[_currentStep].get("fixed", false):
			break
		_currentStep += 1

	if _currentStep >= _steps.size():
		# Algunos niveles solo necesitan completar correctamente las líneas.
		# No ejecutamos ni mostramos output: la quest se completa directamente.
		if completeOnSteps:
			_onSuccess()
		else:
			_evaluateFull()
		return

	# Contar cuántos pasos de elección quedan
	var totalChoices = 0
	var choiceNum = 0
	for i in _steps.size():
		if not _steps[i].get("fixed", false):
			totalChoices += 1
			if i < _currentStep:
				choiceNum += 1
	choiceNum += 1

	stepLabel.text = "Elección %d de %d" % [choiceNum, totalChoices]

	# Encender flecha del slot actual
	for slot in _slots:
		if slot["step_idx"] == _currentStep:
			slot["arrow"].visible = true
			break

	# Cargar alternativas mezcladas
	var step = _steps[_currentStep]
	var alternatives = step.get("alternatives", []).duplicate()
	alternatives.shuffle()

	commandList.setup(alternatives)
	if commandList.alternativeChosen.is_connected(_onAlternativeChosen):
		commandList.alternativeChosen.disconnect(_onAlternativeChosen)
	commandList.alternativeChosen.connect(_onAlternativeChosen)

func _onAlternativeChosen(block):
	if block.isCorrect:
		var step = _steps[_currentStep]

		# Reemplazar el slot vacío por el bloque real
		for slot in _slots:
			if slot["step_idx"] == _currentStep and slot["kind"] == "empty":
				var row = slot["row"]
				# Quitar el slot vacío
				slot["slot_node"].queue_free()
				# Crear bloque colocado
				var placed = preload("res://scenes/CommandBlock.tscn").instantiate()
				placed.setupPlaced(block.blockType, block.displayText, block.config, step.get("indent", 0))
				placed.setLocked()
				row.add_child(placed)
				# Actualizar slot
				slot["kind"] = "filled"
				slot["block"] = placed
				slot.erase("slot_node")
				break

		_currentStep += 1
		_loadCurrentStep()
	else:
		_showError("Esa línea no es correcta. ¡Intenta de nuevo!")

func _evaluateFull():
	# Recoger todos los bloques en orden de los slots
	var vars = levelVars.duplicate()
	var inputQueue: Array = _currentData.get("inputs", []).duplicate()
	var blocks = _collectBlocks()
	var output = _runBlocks(blocks, vars, inputQueue)

	var testCases = _currentData.get("test_cases", [])
	if testCases.is_empty():
		var correct = false
		if expectedOutput == ["any_non_empty"]:
			correct = output.size() > 0 and output[0].strip_edges() != ""
		else:
			correct = output == expectedOutput
		if showOutput:
			outputLabel.text = "Output: " + ", ".join(output)
		if correct:
			_onSuccess()
		else:
			outputLabel.add_theme_color_override("font_color", Color(1.0, 0.5, 0.4))
	else:
		var allPassed = true
		var lines = []
		for idx in testCases.size():
			var tc = testCases[idx]
			var tcInput: Array = tc.get("inputs", []).duplicate()
			var expected: Array = tc.get("expected_output", [])
			var tcOut = _runBlocks(blocks, levelVars.duplicate(), tcInput)
			var passed = tcOut == expected
			if not passed:
				allPassed = false
			lines.append("Caso %d: %s" % [idx + 1, "OK" if passed else "..."])
		if showOutput:
			outputLabel.text = "\n".join(lines)
		if allPassed:
			_onSuccess()

# Recoge los bloques en el orden de los slots (ignora flechas y spacers)
func _collectBlocks() -> Array:
	var result = []
	for slot in _slots:
		if slot.has("block"):
			result.append(slot["block"])
	return result

func _runBlocks(blocks: Array, vars: Dictionary, inputQueue: Array) -> Array:
	var output = []
	var i = 0
	while i < blocks.size():
		var b = blocks[i]
		if not b.has_method("execute"):
			i += 1
			continue
		var res = b.execute(vars, inputQueue)
		vars = res.get("vars", vars)
		output.append_array(res.get("output", []))
		if b.blockType == 1: # IF
			var cond = res.get("condition", false)
			i += 1
			while i < blocks.size() and blocks[i].indentLevel > b.indentLevel:
				if cond:
					var inner = blocks[i].execute(vars, inputQueue)
					vars = inner.get("vars", vars)
					output.append_array(inner.get("output", []))
				i += 1
		else:
			i += 1
	return output

func _showError(message: String):
	feedbackLabel.text = "⚠ " + message
	feedbackLabel.add_theme_color_override("font_color", Color(1.0, 0.45, 0.35))
	feedbackLabel.visible = true
	var tween = feedbackLabel.create_tween()
	tween.tween_property(feedbackLabel, "modulate:a", 1.0, 0.0)
	tween.tween_interval(2.0)
	tween.tween_property(feedbackLabel, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): feedbackLabel.visible = false)

func _onSuccess():
	if showOutput:
		outputLabel.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5))
		outputLabel.text += "\n\n¡Correcto!"
	_disableCommandList()
	var npc = _activeNpc
	_activeNpc = null
	# Marcar al NPC resuelto YA, antes del await, para que no pueda
	# reactivarse si el jugador pulsa E durante el segundo de espera
	if is_instance_valid(npc) and npc.has_method("onPuzzleSolved"):
		npc.onPuzzleSolved()
	var outroLines: Array = _currentData.get("outro_lines", [])
	var playerScene: String = _currentData.get("player_scene", "")
	var npcScene: String = _currentData.get("npc_scene", "")
	await get_tree().create_timer(1.0).timeout
	if outroLines.size() > 0:
		_closeKeepPlayerFrozen()
		var dialogBox = get_tree().get_first_node_in_group("dialog_box")
		if dialogBox:
			var savedNpcTexture: Texture2D = dialogBox._npcPortraitTexture
			dialogBox.openDirect(outroLines, playerScene, npcScene, true, savedNpcTexture)
	else:
		close()

func _disableCommandList():
	for child in commandList.get_children():
		if child is PanelContainer:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
			child.modulate.a = 0.4

# Cierra el panel del puzzle pero NO reactiva al jugador.
# Usar cuando se va a abrir un diálogo de outro inmediatamente después;
# el diálogo se encargará de devolver el control al jugador al cerrarse.
func _closeKeepPlayerFrozen():
	isOpen = false
	panel.visible = false
	if commandList.alternativeChosen.is_connected(_onAlternativeChosen):
		commandList.alternativeChosen.disconnect(_onAlternativeChosen)

func close():
	isOpen = false
	panel.visible = false
	if commandList.alternativeChosen.is_connected(_onAlternativeChosen):
		commandList.alternativeChosen.disconnect(_onAlternativeChosen)
	var player = get_tree().get_first_node_in_group("player")
	player.set_physics_process(true)
	player.set_process_unhandled_input(true)
	player.set_process_input(true)

func _nameToType(name: String) -> int:
	match name:
		"input":  return 0
		"if":     return 1
		"else":   return 2
		"print":  return 3
		"assign": return 4
		"expr":   return 5
	return 3
