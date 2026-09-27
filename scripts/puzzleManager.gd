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
var _feedbackTween: Tween = null

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
var _celebrating: bool = false
var _tablonContinuar: bool = false
var _arrowOverlay: Label = null  # flecha dentro de la row activa

# Tracking de puntaje
var _errores: int = 0
var _rachaActual: int = 0
var _rachaMax: int = 0

const FONT_SIZE := 18
const COMPLETION_DURATION := 3.5

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
	titleLabel.add_theme_font_size_override("font_size", FONT_SIZE + 8)
	titleLabel.add_theme_color_override("font_color", Color(0.9, 0.85, 1.0))
	vbox.add_child(titleLabel)

	promptLabel = RichTextLabel.new()
	promptLabel.bbcode_enabled = true
	promptLabel.custom_minimum_size = Vector2(0, 80)
	promptLabel.fit_content = true
	promptLabel.scroll_active = false
	promptLabel.add_theme_font_size_override("normal_font_size", FONT_SIZE + 4)
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
	cmdTitle.add_theme_font_size_override("font_size", FONT_SIZE + 4)
	cmdTitle.add_theme_color_override("font_color", Color(0.5, 0.9, 0.6))
	cmdWrapper.add_child(cmdTitle)

	stepLabel = Label.new()
	stepLabel.add_theme_font_size_override("font_size", FONT_SIZE + 2)
	stepLabel.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	cmdWrapper.add_child(stepLabel)

	commandList = VBoxContainer.new()
	commandList.size_flags_vertical = Control.SIZE_EXPAND_FILL
	commandList.set_script(load("res://scripts/commandList.gd"))
	cmdWrapper.add_child(commandList)

	feedbackLabel = Label.new()
	feedbackLabel.custom_minimum_size = Vector2(0, 36)
	feedbackLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedbackLabel.add_theme_font_size_override("font_size", FONT_SIZE + 3)
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
	_errores = 0
	_rachaActual = 0
	_rachaMax = 0

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

		# Cada fila termina con la flecha. Al quedar al lado derecho,
		# nunca empuja ni desplaza horizontalmente el bloque.
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		dropZone.add_child(row)

		# Indentación primero, luego el bloque.
		if indent > 0:
			var spacer = Control.new()
			spacer.custom_minimum_size = Vector2(indent * 20, 0)
			row.add_child(spacer)


		if step.get("fixed", false):
			var block = preload("res://scenes/CommandBlock.tscn").instantiate()
			block.setupPlaced(_nameToType(step.get("type", "print")), step.get("text", ""), step.get("config", {}), indent)
			block.setLocked()
			row.add_child(block)
			_slots.append({"kind": "fixed", "row": row, "block": block, "step_idx": i})
		else:
			var emptySlot = _makeEmptySlot(step)
			row.add_child(emptySlot)
			_slots.append({"kind": "empty", "row": row, "slot_node": emptySlot, "step_idx": i})

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

# Busca el primer slot vacío a partir de _currentStep y apunta la flecha ahí.
# La flecha se inserta directamente en la row del slot activo para que:
#   - siempre quede junto al bloque correcto (sin cálculo de coordenadas globales)
#   - scrollee con el contenido y nunca se superponga fuera del área visible
func _loadCurrentStep(animate_arrow: bool = true):
	# Quitar la flecha del slot anterior (si existe)
	_removeArrow()

	while _currentStep < _steps.size():
		if not _steps[_currentStep].get("fixed", false):
			break
		_currentStep += 1

	if _currentStep >= _steps.size():
		if completeOnSteps:
			_onSuccess()
		else:
			_evaluateFull()
		return

	var totalChoices = 0
	var choiceNum = 0
	for i in _steps.size():
		if not _steps[i].get("fixed", false):
			totalChoices += 1
			if i < _currentStep:
				choiceNum += 1
	choiceNum += 1
	stepLabel.text = "Elección %d de %d" % [choiceNum, totalChoices]

	# Encontrar la row del slot activo
	var targetRow: HBoxContainer = null
	for slot in _slots:
		if slot["step_idx"] == _currentStep:
			targetRow = slot["row"]
			break

	if targetRow == null:
		return

	# Crear la flecha como hija de la row — se posiciona con el layout,
	# scrollea junto al contenido y no necesita coordenadas absolutas.
	_arrowOverlay = Label.new()
	_arrowOverlay.text = "◀"
	_arrowOverlay.add_theme_font_size_override("font_size", FONT_SIZE + 2)
	_arrowOverlay.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	_arrowOverlay.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.8))
	_arrowOverlay.add_theme_constant_override("outline_size", 3)
	_arrowOverlay.custom_minimum_size = Vector2(28, 44)
	_arrowOverlay.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_arrowOverlay.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_arrowOverlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_arrowOverlay.modulate.a = 0.0  # empieza invisible para animar entrada
	targetRow.add_child(_arrowOverlay)

	# Animar entrada de la flecha
	var tween = _arrowOverlay.create_tween()
	tween.set_parallel(true)
	if animate_arrow:
		_arrowOverlay.scale = Vector2(0.5, 0.5)
		tween.tween_property(_arrowOverlay, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_arrowOverlay, "modulate:a", 1.0, 0.20)

	var step = _steps[_currentStep]
	var alternatives = step.get("alternatives", []).duplicate()
	alternatives.shuffle()

	commandList.setup(alternatives)
	if commandList.alternativeChosen.is_connected(_onAlternativeChosen):
		commandList.alternativeChosen.disconnect(_onAlternativeChosen)
	commandList.alternativeChosen.connect(_onAlternativeChosen)

# Elimina la flecha actual de su row padre
func _removeArrow():
	if is_instance_valid(_arrowOverlay):
		_arrowOverlay.queue_free()
	_arrowOverlay = null

func _onAlternativeChosen(block):
	if block.isCorrect:
		var step = _steps[_currentStep]

		# Reemplazar el slot vacío por el bloque real
		for slot in _slots:
			if slot["step_idx"] == _currentStep and slot["kind"] == "empty":
				var row = slot["row"]
				# Quitar el slot vacío y poner el bloque real
				slot["slot_node"].queue_free()
				var placed = preload("res://scenes/CommandBlock.tscn").instantiate()
				placed.setupPlaced(block.blockType, block.displayText, block.config, step.get("indent", 0))
				placed.setLocked()
				row.add_child(placed)
				slot["kind"] = "filled"
				slot["block"] = placed
				slot.erase("slot_node")
				break

		_rachaActual += 1
		if _rachaActual > _rachaMax:
			_rachaMax = _rachaActual
		GameData.rachaGlobal += 1
		if GameData.rachaGlobal >= 3:
			_showStreakPopup(GameData.rachaGlobal)
		_showCorrect()
		_currentStep += 1
		_loadCurrentStep()
	else:
		_errores += 1
		_rachaActual = 0
		GameData.rachaGlobal = 0
		var hint = _steps[_currentStep].get("hint", "")
		if hint != "":
			_showError("Pista: " + hint)
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

func _showFeedback(message: String, color: Color, duration: float):
	if _feedbackTween != null and _feedbackTween.is_valid():
		_feedbackTween.kill()
	feedbackLabel.modulate.a = 1.0
	feedbackLabel.text = message
	feedbackLabel.add_theme_color_override("font_color", color)
	feedbackLabel.visible = true
	_feedbackTween = feedbackLabel.create_tween()
	_feedbackTween.tween_interval(duration)
	_feedbackTween.tween_property(feedbackLabel, "modulate:a", 0.0, 0.8)
	_feedbackTween.tween_callback(func(): feedbackLabel.visible = false)

func _showError(message: String):
	if _feedbackTween != null and _feedbackTween.is_valid():
		_feedbackTween.kill()
	feedbackLabel.modulate.a = 1.0
	feedbackLabel.text = message
	feedbackLabel.add_theme_color_override("font_color", Color(1.0, 0.45, 0.35))
	feedbackLabel.visible = true

func _showCorrect():
	_showFeedback("Correcto!", Color(0.4, 1.0, 0.5), 1.2)

func _showStreakPopup(n: int) -> void:
	# Colores ciclicos para el efecto arcoíris
	var colors: Array[Color] = [
		Color(1.0, 0.3, 0.3),
		Color(1.0, 0.7, 0.1),
		Color(0.3, 1.0, 0.4),
		Color(0.2, 0.8, 1.0),
		Color(0.8, 0.3, 1.0),
	]

	# Posición del jugador en pantalla
	var player = get_tree().get_first_node_in_group("player")
	var spawnPos: Vector2
	if player:
		spawnPos = get_viewport().get_canvas_transform() * player.global_position
		spawnPos += Vector2(0, -60)
	else:
		spawnPos = get_viewport().get_visible_rect().get_center() + Vector2(0, -80)

	var lbl = Label.new()
	lbl.text = "RACHA x%d" % n
	lbl.add_theme_font_size_override("font_size", 52)
	lbl.add_theme_color_override("font_color", colors[n % colors.size()])
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	lbl.add_theme_constant_override("shadow_offset_x", 3)
	lbl.add_theme_constant_override("shadow_offset_y", 3)
	lbl.position = spawnPos
	lbl.z_index = 100
	add_child(lbl)

	# Flota hacia arriba y se desvanece
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(lbl, "position:y", spawnPos.y - 100.0, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(lbl, "modulate:a", 0.0, 1.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(func(): lbl.queue_free())

func _onSuccess():
	if _celebrating:
		return
	_celebrating = true

	if showOutput:
		outputLabel.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5))
		outputLabel.text += "\n\n¡Correcto!"
	_disableCommandList()

	var npc = _activeNpc
	_activeNpc = null
	if is_instance_valid(npc) and npc.has_method("onPuzzleSolved"):
		npc.onPuzzleSolved()

	var puntaje = _calcularPuntaje()
	GameData.gatopuntos += puntaje

	# Lanzar celebración y tablón simultáneamente; esperar a que el jugador presione continuar
	await _playCompletionWithTablon(puntaje)

	_celebrating = false

	var outroLines: Array = _currentData.get("outro_lines", [])
	var playerScene: String = _currentData.get("player_scene", "")
	var npcScene: String = _currentData.get("npc_scene", "")

	if outroLines.size() > 0:
		_closeKeepPlayerFrozen()
		var dialogBox = get_tree().get_first_node_in_group("dialog_box")
		if dialogBox:
			var savedNpcTexture: Texture2D = dialogBox._npcPortraitTexture
			dialogBox.openDirect(outroLines, playerScene, npcScene, true, savedNpcTexture)
		else:
			close()
	else:
		close()

func _calcularPuntaje() -> int:
	# Contar slots rellenables
	var rellenables = 0
	for s in _steps:
		if not s.get("fixed", false):
			rellenables += 1
	var base = rellenables * 20

	# Penalizacion por errores (1 error: sin penalización, 2: 25%, 3+: 50%)
	var penalizacion = 0
	if _errores == 2:
		penalizacion = int(base * 0.25)
	elif _errores >= 3:
		penalizacion = int(base * 0.50)

	# Bonificacion por racha global (desde 3 correctas seguidas sin fallo entre puzzles)
	var bonus = 0
	if GameData.rachaGlobal >= 3:
		bonus = GameData.rachaGlobal * 5

	return max(0, base - penalizacion + bonus)

# Lanza la celebración de arcoíris + texto flotante y el tablón simultáneamente.
# El tablón sube desde abajo junto con el texto "MIAUGORITMO COMPLETADO".
# Retorna cuando el jugador presiona Continuar.
func _playCompletionWithTablon(puntaje: int) -> void:
	panel.move_to_front()
	commandList.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var rellenables = 0
	for s in _steps:
		if not s.get("fixed", false):
			rellenables += 1
	var base = rellenables * 20
	var penalizacion = 0
	if _errores == 2:
		penalizacion = int(base * 0.25)
	elif _errores >= 3:
		penalizacion = int(base * 0.50)
	var bonus = 0
	if GameData.rachaGlobal >= 3:
		bonus = GameData.rachaGlobal * 5

	var rainbowBlocks: Array = []
	for slot in _slots:
		if slot.has("block") and is_instance_valid(slot["block"]):
			rainbowBlocks.append(slot["block"])

	# --- Contenedor raíz de la celebración (cubre todo el panel) ---
	var celebration = Control.new()
	celebration.name = "CompletionCelebration"
	celebration.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	celebration.mouse_filter = Control.MOUSE_FILTER_PASS
	panel.add_child(celebration)

	# --- Tablón negro que sube desde abajo (panel vertical centrado) ---
	var tablonW = panel.size.x * 0.58
	var tablonH = panel.size.y * 0.55
	var tablonX = (panel.size.x - tablonW) * 0.5
	var tablonTargetY = panel.size.y - tablonH - (panel.size.y * 0.14)

	var tablon = PanelContainer.new()
	var tablonStyle = StyleBoxFlat.new()
	tablonStyle.bg_color = Color(0.04, 0.04, 0.07, 0.97)
	tablonStyle.border_color = Color(0.55, 0.30, 0.85, 1.0)
	tablonStyle.border_width_left = 3
	tablonStyle.border_width_right = 3
	tablonStyle.border_width_top = 3
	tablonStyle.border_width_bottom = 3
	tablonStyle.corner_radius_top_left = 12
	tablonStyle.corner_radius_top_right = 12
	tablonStyle.corner_radius_bottom_left = 12
	tablonStyle.corner_radius_bottom_right = 12
	tablonStyle.content_margin_left = 24
	tablonStyle.content_margin_right = 24
	tablonStyle.content_margin_top = 20
	tablonStyle.content_margin_bottom = 20
	tablon.add_theme_stylebox_override("panel", tablonStyle)
	tablon.position = Vector2(tablonX, panel.size.y)
	tablon.size = Vector2(tablonW, tablonH)
	tablon.mouse_filter = Control.MOUSE_FILTER_STOP
	celebration.add_child(tablon)

	var tablonTween = tablon.create_tween()
	tablonTween.tween_property(tablon, "position:y", tablonTargetY, 0.65).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# --- Contenido del tablón ---
	var tablonVbox = VBoxContainer.new()
	tablonVbox.add_theme_constant_override("separation", 14)
	tablon.add_child(tablonVbox)

	# Título animado dentro del tablón: HBoxContainer para las letras
	var textContainer = HBoxContainer.new()
	textContainer.alignment = BoxContainer.ALIGNMENT_CENTER
	textContainer.add_theme_constant_override("separation", 0)
	textContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textContainer.custom_minimum_size = Vector2(0, 60)
	tablonVbox.add_child(textContainer)

	var message = "MIAUGORITMO COMPLETADO"
	var letters: Array = []
	for i in message.length():
		var letterSlot = Control.new()
		letterSlot.custom_minimum_size = Vector2(22, 60)
		textContainer.add_child(letterSlot)

		var letter = Label.new()
		letter.text = message.substr(i, 1)
		letter.position = Vector2(0, 0)
		letter.size = Vector2(22, 60)
		letter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		letter.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		letter.add_theme_font_size_override("font_size", FONT_SIZE + 8)
		letter.add_theme_color_override("font_color", Color.WHITE)
		letter.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.08, 1.0))
		letter.add_theme_constant_override("outline_size", 4)
		letter.mouse_filter = Control.MOUSE_FILTER_IGNORE
		letterSlot.add_child(letter)
		letters.append(letter)

	var sep1 = HSeparator.new()
	tablonVbox.add_child(sep1)

	# Puntaje base (siempre se muestra)
	var lblBase = Label.new()
	lblBase.text = "Puntaje base  (%d bloques × 20):  %d pts" % [rellenables, base]
	lblBase.add_theme_font_size_override("font_size", FONT_SIZE + 2)
	lblBase.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	tablonVbox.add_child(lblBase)

	# Penalización — solo si hubo errores
	if penalizacion > 0:
		var pct = "25%" if _errores == 2 else "50%"
		var lblPen = Label.new()
		lblPen.text = "Penalización  (%d errores, -%s):  -%d pts" % [_errores, pct, penalizacion]
		lblPen.add_theme_font_size_override("font_size", FONT_SIZE + 2)
		lblPen.add_theme_color_override("font_color", Color(1.0, 0.45, 0.35))
		tablonVbox.add_child(lblPen)

	# Bonus racha — solo si aplica
	if bonus > 0:
		var lblBonus = Label.new()
		lblBonus.text = "Bonus racha  (racha de %d):  +%d pts" % [GameData.rachaGlobal, bonus]
		lblBonus.add_theme_font_size_override("font_size", FONT_SIZE + 2)
		lblBonus.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		tablonVbox.add_child(lblBonus)

	var sep2 = HSeparator.new()
	tablonVbox.add_child(sep2)

	# Total
	var lblTotal = Label.new()
	lblTotal.text = "Total:  %d pts   (Gatopuntos acumulados: %d)" % [puntaje, GameData.gatopuntos]
	lblTotal.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lblTotal.add_theme_font_size_override("font_size", FONT_SIZE + 4)
	lblTotal.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))
	tablonVbox.add_child(lblTotal)

	# Botón continuar
	var btn = Button.new()
	btn.text = "Continuar"
	btn.add_theme_font_size_override("font_size", FONT_SIZE + 6)
	btn.custom_minimum_size = Vector2(220, 52)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_tablonContinuar = false
	btn.pressed.connect(func(): _tablonContinuar = true)
	tablonVbox.add_child(btn)

	# --- Loop de animación: arcoíris en bloques + serpiente en título, hasta Continuar ---
	var startTime = Time.get_ticks_msec()
	while not _tablonContinuar:
		var elapsed = float(Time.get_ticks_msec() - startTime) / 1000.0
		var hueBase = fmod(elapsed * 0.22, 1.0)

		for i in rainbowBlocks.size():
			var block = rainbowBlocks[i]
			if not is_instance_valid(block):
				continue
			var hue = fmod(hueBase + float(i) / max(1.0, float(rainbowBlocks.size())) * 0.75, 1.0)
			var color = Color.from_hsv(hue, 0.78, 0.92)
			var style = StyleBoxFlat.new()
			style.bg_color = color
			style.border_color = Color.from_hsv(fmod(hue + 0.12, 1.0), 0.45, 1.0)
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
			block.add_theme_stylebox_override("panel", style)

		for i in letters.size():
			var letter: Label = letters[i]
			var wave = sin(elapsed * 7.0 - float(i) * 0.55) * 6.0
			letter.position.y = wave
			var letterHue = fmod(hueBase + float(i) / max(1.0, float(letters.size())) * 0.85, 1.0)
			letter.add_theme_color_override("font_color", Color.from_hsv(letterHue, 0.72, 1.0))

		# El borde del tablón también cicla de color
		tablonStyle.border_color = Color.from_hsv(fmod(hueBase * 1.5, 1.0), 0.65, 1.0)
		tablon.add_theme_stylebox_override("panel", tablonStyle)

		await get_tree().process_frame

	celebration.queue_free()

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
	_removeArrow()
	panel.visible = false
	if commandList.alternativeChosen.is_connected(_onAlternativeChosen):
		commandList.alternativeChosen.disconnect(_onAlternativeChosen)

func close():
	isOpen = false
	_removeArrow()
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
		"elif":   return 6
	return 3
