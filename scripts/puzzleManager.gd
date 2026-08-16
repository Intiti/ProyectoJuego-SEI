extends CanvasLayer

@export var levelPrompt: String = ""
@export var expectedOutput: Array = []
@export var levelVars: Dictionary = {}

var panel: ColorRect
var promptLabel: RichTextLabel
var dropZone: VBoxContainer
var commandList: VBoxContainer
var outputLabel: Label
var runButton: Button

var isOpen: bool = false

const FONT_SIZE := 18

func _ready():
	add_to_group("puzzle")

	panel = ColorRect.new()
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.color = Color(0.08, 0.08, 0.12, 0.95)
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

	# Drop Zone con rectangulo visible
	var dropWrapper = PanelContainer.new()
	dropWrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dropWrapper.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var dropStyle = StyleBoxFlat.new()
	dropStyle.bg_color = Color(0.1, 0.12, 0.18, 1.0)
	dropStyle.border_color = Color(0.4, 0.5, 0.8, 0.8)
	dropStyle.border_width_left = 2
	dropStyle.border_width_right = 2
	dropStyle.border_width_top = 2
	dropStyle.border_width_bottom = 2
	dropStyle.corner_radius_top_left = 6
	dropStyle.corner_radius_top_right = 6
	dropStyle.corner_radius_bottom_left = 6
	dropStyle.corner_radius_bottom_right = 6
	dropStyle.content_margin_left = 12
	dropStyle.content_margin_right = 12
	dropStyle.content_margin_top = 12
	dropStyle.content_margin_bottom = 12
	dropWrapper.add_theme_stylebox_override("panel", dropStyle)
	hbox.add_child(dropWrapper)

	var dropInner = VBoxContainer.new()
	dropInner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dropInner.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dropWrapper.add_child(dropInner)

	var dropTitle = Label.new()
	dropTitle.text = "Arrastra los bloques aqui"
	dropTitle.add_theme_font_size_override("font_size", FONT_SIZE - 2)
	dropTitle.add_theme_color_override("font_color", Color(0.5, 0.6, 0.9))
	dropInner.add_child(dropTitle)

	dropZone = VBoxContainer.new()
	dropZone.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dropZone.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dropZone.set_script(load("res://scripts/dropZone.gd"))
	dropInner.add_child(dropZone)

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

	commandList = VBoxContainer.new()
	commandList.size_flags_vertical = Control.SIZE_EXPAND_FILL
	commandList.set_script(load("res://scripts/commandList.gd"))
	cmdWrapper.add_child(commandList)

	runButton = Button.new()
	runButton.text = "Ejecutar"
	runButton.custom_minimum_size = Vector2(0, 48)
	runButton.add_theme_font_size_override("font_size", FONT_SIZE + 2)
	runButton.pressed.connect(_onRun)
	vbox.add_child(runButton)

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

	levelPrompt = data.get("prompt", "")
	expectedOutput = data.get("expected_output", [])
	levelVars = data.get("variables", {})

	promptLabel.text = _colorizePrompt(levelPrompt)
	outputLabel.text = ""
	dropZone.clear()
	commandList.setup(data.get("available_commands", []), levelVars)
	panel.visible = true

	# Bloquear jugador completamente
	var player = get_tree().get_first_node_in_group("player")
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	player.set_process_input(false)

func _onRun():
	var result = dropZone.execute(levelVars.duplicate())
	outputLabel.text = "Output:\n" + "\n".join(result)
	if result == expectedOutput:
		outputLabel.text += "\n\nCorrecto!"
		outputLabel.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5))
		var npcs = get_tree().get_nodes_in_group("npc")
		for npc in npcs:
			if npc.has_method("onPuzzleSolved"):
				npc.onPuzzleSolved()
	else:
		outputLabel.text += "\n\nEsperado: " + ", ".join(expectedOutput)
		outputLabel.add_theme_color_override("font_color", Color(1.0, 0.5, 0.4))

func close():
	isOpen = false
	panel.visible = false

	# Desbloquear jugador
	var player = get_tree().get_first_node_in_group("player")
	player.set_physics_process(true)
	player.set_process_unhandled_input(true)
	player.set_process_input(true)
