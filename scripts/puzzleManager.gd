extends CanvasLayer

@export var levelPrompt: String = ""
@export var expectedOutput: Array = []
@export var levelVars: Dictionary = {}

var panel: ColorRect
var promptLabel: Label
var dropZone: VBoxContainer
var commandList: VBoxContainer
var outputLabel: Label
var runButton: Button

var isOpen: bool = false

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
	vbox.offset_left = 24.0
	vbox.offset_top = 24.0
	vbox.offset_right = -24.0
	vbox.offset_bottom = -24.0
	panel.add_child(vbox)

	promptLabel = Label.new()
	promptLabel.text = ""
	promptLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	promptLabel.custom_minimum_size = Vector2(0, 60)
	vbox.add_child(promptLabel)

	var hbox = HBoxContainer.new()
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(hbox)

	dropZone = VBoxContainer.new()
	dropZone.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dropZone.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dropZone.set_script(load("res://scripts/dropZone.gd"))
	hbox.add_child(dropZone)

	var sep = VSeparator.new()
	hbox.add_child(sep)

	commandList = VBoxContainer.new()
	commandList.custom_minimum_size = Vector2(260, 0)
	commandList.set_script(load("res://scripts/commandList.gd"))
	hbox.add_child(commandList)

	runButton = Button.new()
	runButton.text = "▶ Ejecutar"
	runButton.custom_minimum_size = Vector2(0, 40)
	runButton.pressed.connect(_onRun)
	vbox.add_child(runButton)

	outputLabel = Label.new()
	outputLabel.custom_minimum_size = Vector2(0, 80)
	outputLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(outputLabel)

func open(data: Dictionary):
	if isOpen:
		return
	isOpen = true

	levelPrompt = data.get("prompt", "")
	expectedOutput = data.get("expected_output", [])
	levelVars = data.get("variables", {})

	promptLabel.text = levelPrompt
	outputLabel.text = ""
	dropZone.clear()
	commandList.setup(data.get("available_commands", []), levelVars)
	panel.visible = true
	get_tree().get_first_node_in_group("player").set_physics_process(false)

func _onRun():
	var result = dropZone.execute(levelVars.duplicate())
	outputLabel.text = "Output:\n" + "\n".join(result)
	if result == expectedOutput:
		outputLabel.text += "\n\n✓ ¡Correcto!"
		var npcs = get_tree().get_nodes_in_group("npc")
		for npc in npcs:
			if npc.has_method("onPuzzleSolved"):
				npc.onPuzzleSolved()
	else:
		outputLabel.text += "\n\nEsperado: " + ", ".join(expectedOutput)

func close():
	isOpen = false
	panel.visible = false
	get_tree().get_first_node_in_group("player").set_physics_process(true)
