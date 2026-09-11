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

var isOpen: bool = false
var _currentData: Dictionary = {}

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

	var cmdWrapper = VBoxContainer.new()
	cmdWrapper.custom_minimum_size = Vector2(280, 0)
	cmdWrapper.add_theme_constant_override("separation", 8)
	hbox.add_child(cmdWrapper)

	var cmdTitle = Label.new()
	cmdTitle.text = "Bloques disponibles"
	cmdTitle.add_theme_font_size_override("font_size", FONT_SIZE - 2)
	cmdTitle.add_theme_color_override("font_color", Color(0.5, 0.9, 0.6))
	cmdWrapper.add_child(cmdTitle)

	var cmdHint = Label.new()
	cmdHint.text = "Haz click para agregar"
	cmdHint.add_theme_font_size_override("font_size", FONT_SIZE - 4)
	cmdHint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	cmdWrapper.add_child(cmdHint)

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

func open(data: Dictionary):
	if isOpen:
		return
	isOpen = true
	_currentData = data

	levelPrompt = data.get("prompt", "")
	expectedOutput = data.get("expected_output", [])
	levelVars = data.get("variables", {})

	promptLabel.text = _colorizePrompt(levelPrompt)
	outputLabel.text = ""
	feedbackLabel.visible = false

	var prefilled = data.get("prefilled_blocks", [])
	dropZone.clear()
	dropZone.setup(levelVars, prefilled)

	commandList.setup(data.get("available_commands", []), levelVars)
	commandList.blockClicked.connect(_onBlockClicked)

	panel.visible = true

	var player = get_tree().get_first_node_in_group("player")
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	player.set_process_input(false)

func _onBlockClicked(blockType: int, vars: Dictionary):
	dropZone.addBlock(blockType, vars)
	_evaluateCurrent()

func _evaluateCurrent():
	var testCases = _currentData.get("test_cases", [])

	if testCases.is_empty():
		var inputQueue = []
		var result = dropZone.execute(levelVars.duplicate(), inputQueue)
		outputLabel.text = "Output: " + ", ".join(result)

		var correct = false
		if expectedOutput == ["any_non_empty"]:
			correct = result.size() > 0 and result[0].strip_edges() != ""
		else:
			correct = result == expectedOutput

		if correct:
			_onSuccess()
		return

	var allPassed = true
	var lines = []
	for idx in testCases.size():
		var tc = testCases[idx]
		var inputQueue: Array = tc.get("inputs", []).duplicate()
		var expected: Array = tc.get("expected_output", [])
		var result = dropZone.execute(levelVars.duplicate(), inputQueue)
		var passed = result == expected
		if not passed:
			allPassed = false
		var icon = "OK" if passed else "..."
		lines.append("Caso %d: %s" % [idx + 1, icon])

	outputLabel.text = "\n".join(lines)

	if allPassed:
		_onSuccess()

func _showError(message: String):
	feedbackLabel.text = "⚠ " + message
	feedbackLabel.add_theme_color_override("font_color", Color(1.0, 0.45, 0.35))
	feedbackLabel.visible = true
	var tween = feedbackLabel.create_tween()
	tween.tween_property(feedbackLabel, "modulate:a", 1.0, 0.0)
	tween.tween_interval(2.0)
	tween.tween_property(feedbackLabel, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): feedbackLabel.visible = false)
	dropZone.removeLastBlock()

func _onSuccess():
	outputLabel.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5))
	outputLabel.text += "\n\n¡Correcto!"
	_disableCommandList()
	var npcs = get_tree().get_nodes_in_group("npc")
	for npc in npcs:
		if npc.has_method("onPuzzleSolved"):
			npc.onPuzzleSolved()

func _disableCommandList():
	for child in commandList.get_children():
		if child is PanelContainer:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
			child.modulate.a = 0.4

func close():
	isOpen = false
	panel.visible = false
	if commandList.blockClicked.is_connected(_onBlockClicked):
		commandList.blockClicked.disconnect(_onBlockClicked)

	var player = get_tree().get_first_node_in_group("player")
	player.set_physics_process(true)
	player.set_process_unhandled_input(true)
	player.set_process_input(true)
