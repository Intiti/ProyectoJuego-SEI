extends CanvasLayer

const LETTER_SPEED = 0.04
const PLAYER_NAME = "Jugador"

var lines: Array = []
var currentLine: int = 0
var isTyping: bool = false
var isOpen: bool = false
var fullText: String = ""
var puzzleData: Dictionary = {}

var overlay: ColorRect
var leftSprite: TextureRect
var rightSprite: TextureRect
var panel: Panel
var speakerLabel: Label
var dialogLabel: Label
var continueHint: Label

func _ready():
	add_to_group("dialog_box")

	overlay = ColorRect.new()
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.color = Color(0, 0, 0, 0.75)
	overlay.visible = false
	add_child(overlay)

	leftSprite = TextureRect.new()
	leftSprite.anchor_top = 1.0
	leftSprite.anchor_bottom = 1.0
	leftSprite.offset_left = 40.0
	leftSprite.offset_right = 180.0
	leftSprite.offset_top = -220.0
	leftSprite.offset_bottom = -26.0
	leftSprite.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	leftSprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	leftSprite.visible = false
	add_child(leftSprite)

	rightSprite = TextureRect.new()
	rightSprite.anchor_left = 1.0
	rightSprite.anchor_right = 1.0
	rightSprite.anchor_top = 1.0
	rightSprite.anchor_bottom = 1.0
	rightSprite.offset_left = -180.0
	rightSprite.offset_right = -40.0
	rightSprite.offset_top = -220.0
	rightSprite.offset_bottom = -26.0
	rightSprite.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	rightSprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rightSprite.visible = false
	add_child(rightSprite)

	panel = Panel.new()
	panel.anchor_left = 0.1
	panel.anchor_top = 0.75
	panel.anchor_right = 0.9
	panel.anchor_bottom = 0.97
	panel.visible = false
	add_child(panel)

	speakerLabel = Label.new()
	speakerLabel.anchor_right = 1.0
	speakerLabel.offset_left = 12.0
	speakerLabel.offset_top = 8.0
	speakerLabel.offset_right = -12.0
	speakerLabel.offset_bottom = 30.0
	panel.add_child(speakerLabel)

	dialogLabel = Label.new()
	dialogLabel.anchor_right = 1.0
	dialogLabel.anchor_bottom = 1.0
	dialogLabel.offset_left = 12.0
	dialogLabel.offset_top = 34.0
	dialogLabel.offset_right = -12.0
	dialogLabel.offset_bottom = -28.0
	dialogLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(dialogLabel)

	continueHint = Label.new()
	continueHint.anchor_right = 1.0
	continueHint.anchor_top = 1.0
	continueHint.anchor_bottom = 1.0
	continueHint.offset_top = -24.0
	continueHint.offset_right = -10.0
	continueHint.offset_bottom = -4.0
	continueHint.text = "▼ E"
	continueHint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	continueHint.visible = false
	panel.add_child(continueHint)

func open(jsonPath: String):
	if isOpen:
		return
	var file = FileAccess.open(jsonPath, FileAccess.READ)
	if not file:
		push_error("No se pudo abrir: " + jsonPath)
		return

	var parsed = JSON.parse_string(file.get_as_text())
	file.close()

	lines = parsed["lines"]
	currentLine = 0
	isOpen = true
	puzzleData = parsed.get("puzzle", {})

	if parsed.has("npc_portrait"):
		rightSprite.texture = load(parsed["npc_portrait"])
	if parsed.has("player_portrait"):
		leftSprite.texture = load(parsed["player_portrait"])

	overlay.visible = true
	panel.visible = true
	leftSprite.visible = true
	rightSprite.visible = true
	get_tree().get_first_node_in_group("player").set_physics_process(false)
	_showLine()

func _showLine():
	var lineData = lines[currentLine]
	var isPlayer = lineData["speaker"] == PLAYER_NAME

	speakerLabel.text = lineData["speaker"]
	fullText = lineData["text"]
	continueHint.visible = false
	dialogLabel.text = ""

	leftSprite.modulate.a = 1.0 if isPlayer else 0.4
	rightSprite.modulate.a = 0.4 if isPlayer else 1.0

	isTyping = true
	_typeText()

func _typeText():
	for i in fullText.length():
		if not isTyping:
			break
		dialogLabel.text = fullText.substr(0, i + 1)
		await get_tree().create_timer(LETTER_SPEED).timeout
	dialogLabel.text = fullText
	isTyping = false
	continueHint.visible = true

func _input(event):
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if not event.is_action("interact"):
		return

	get_viewport().set_input_as_handled()

	if isOpen:
		if isTyping:
			isTyping = false
		else:
			_nextLine()
	else:
		var npcs = get_tree().get_nodes_in_group("npc")
		for npc in npcs:
			npc.tryStartDialog()

func _nextLine():
	currentLine += 1
	if currentLine >= lines.size():
		_closeDialog()
	else:
		_showLine()

func _closeDialog():
	isOpen = false
	overlay.visible = false
	panel.visible = false
	leftSprite.visible = false
	rightSprite.visible = false
	get_tree().get_first_node_in_group("player").set_physics_process(true)
	if not puzzleData.is_empty():
		var puzzle = get_tree().get_first_node_in_group("puzzle")
		if puzzle:
			puzzle.open(puzzleData)
