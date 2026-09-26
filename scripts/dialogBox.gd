extends CanvasLayer

const letterSpeed = 0.04
const playerName = "Jugador"

var lines: Array = []
var currentLine: int = 0
var isTyping: bool = false
var isOpen: bool = false
var fullText: String = ""
var puzzleData: Dictionary = {}

var overlay: ColorRect
var leftPortrait: TextureRect
var rightPortrait: TextureRect
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

	leftPortrait = TextureRect.new()
	leftPortrait.position = Vector2(160, 280)
	leftPortrait.size = Vector2(128, 128)
	leftPortrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	leftPortrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	leftPortrait.visible = false
	add_child(leftPortrait)

	rightPortrait = TextureRect.new()
	rightPortrait.position = Vector2(864, 280)
	rightPortrait.size = Vector2(128, 128)
	rightPortrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rightPortrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rightPortrait.visible = false
	add_child(rightPortrait)

	panel = Panel.new()
	panel.anchor_left = 0.1
	panel.anchor_top = 0.75
	panel.anchor_right = 0.9
	panel.anchor_bottom = 0.97
	panel.visible = false
	var panelStyle = StyleBoxFlat.new()
	panelStyle.bg_color = Color(0, 0, 0, 1)
	panel.add_theme_stylebox_override("panel", panelStyle)

	var dialogTheme = Theme.new()
	dialogTheme.default_font = load("res://assets/MotionControl-Bold.otf")
	dialogTheme.default_font_size = 24
	panel.theme = dialogTheme

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

	# Cargar retratos desde escenas (primer frame de AnimatedSprite2D)
	if parsed.has("npc_scene"):
		rightPortrait.texture = _getFirstFrameFromScene(parsed["npc_scene"])
	if parsed.has("player_scene"):
		leftPortrait.texture = _getFirstFrameFromScene(parsed["player_scene"])

	overlay.visible = true
	panel.visible = true
	leftPortrait.visible = true
	rightPortrait.visible = true
	get_tree().get_first_node_in_group("player").set_physics_process(false)
	showLine()

# Instancia la escena, busca el AnimatedSprite2D y extrae el AtlasTexture del frame 0
func _getFirstFrameFromScene(scenePath: String) -> Texture2D:
	var packed = load(scenePath)
	if not packed:
		push_error("No se pudo cargar la escena: " + scenePath)
		return null

	var instance = packed.instantiate()

	# Buscar AnimatedSprite2D en la escena (puede ser hijo directo o anidado)
	var animSprite = _findAnimatedSprite(instance)

	var texture: Texture2D = null
	if animSprite and animSprite.sprite_frames:
		var frames = animSprite.sprite_frames
		var animName = animSprite.animation if animSprite.animation != "" else "default"
		if frames.has_animation(animName) and frames.get_frame_count(animName) > 0:
			texture = frames.get_frame_texture(animName, 0)

	instance.queue_free()
	return texture

func _findAnimatedSprite(node: Node) -> AnimatedSprite2D:
	if node is AnimatedSprite2D:
		return node
	for child in node.get_children():
		var result = _findAnimatedSprite(child)
		if result:
			return result
	return null

func showLine():
	var lineData = lines[currentLine]
	var isPlayer = lineData["speaker"] == playerName

	speakerLabel.text = lineData["speaker"]
	fullText = lineData["text"]
	continueHint.visible = false
	dialogLabel.text = ""

	leftPortrait.modulate.a = 1.0 if isPlayer else 0.4
	rightPortrait.modulate.a = 0.4 if isPlayer else 1.0

	isTyping = true
	typeText()

func typeText():
	for i in fullText.length():
		if not isTyping:
			break
		dialogLabel.text = fullText.substr(0, i + 1)
		await get_tree().create_timer(letterSpeed).timeout
	dialogLabel.text = fullText
	isTyping = false
	continueHint.visible = true

func _input(event):
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if not event.is_action("interact"):
		return

	var puzzle = get_tree().get_first_node_in_group("puzzle")
	if puzzle and puzzle.isOpen:
		return

	get_viewport().set_input_as_handled()

	if isOpen:
		if isTyping:
			isTyping = false
		else:
			nextLine()
	else:
		var npcs = get_tree().get_nodes_in_group("npc")
		for npc in npcs:
			npc.tryStartDialog()

func nextLine():
	currentLine += 1
	if currentLine >= lines.size():
		closeDialog()
	else:
		showLine()

func closeDialog():
	isOpen = false
	overlay.visible = false
	panel.visible = false
	leftPortrait.visible = false
	rightPortrait.visible = false
	get_tree().get_first_node_in_group("player").set_physics_process(true)
	if not puzzleData.is_empty():
		var puzzle = get_tree().get_first_node_in_group("puzzle")
		if puzzle:
			puzzle.open(puzzleData)
