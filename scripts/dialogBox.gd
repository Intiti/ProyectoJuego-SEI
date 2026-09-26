extends CanvasLayer

const letterSpeed = 0.04

var lines: Array = []
var currentLine: int = 0
var isTyping: bool = false
var isOpen: bool = false
var fullText: String = ""
var puzzleData: Dictionary = {}
var isCinematic: bool = false
var _activeNpc: Node = null
var _npcPortraitTexture: Texture2D = null
# Cuando es true, closeDialog reactiva al jugador aunque isCinematic sea true.
# Se usa para diálogos de outro del puzzle donde el jugador llegó congelado.
var _restorePlayerOnClose: bool = false

signal cinematicDialogFinished

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
	leftPortrait.position = Vector2(60, 60)
	leftPortrait.size = Vector2(512, 512)
	leftPortrait.expand_mode = 3
	leftPortrait.stretch_mode = 4
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

# Llamado desde npc.gd — guarda referencia al NPC activo
func openWithNpc(jsonPath: String, npc: Node):
	_activeNpc = npc
	if npc.get("npcSprite") != null and npc.npcSprite:
		_npcPortraitTexture = npc.npcSprite
	else:
		_npcPortraitTexture = null
	open(jsonPath)

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
	isCinematic = false
	puzzleData = parsed.get("puzzle", {})
	# Propagar al puzzleData los campos de raíz que puzzleManager necesita
	if not puzzleData.is_empty():
		if parsed.has("outro_lines"):
			puzzleData["outro_lines"] = parsed["outro_lines"]
		if parsed.has("npc_scene"):
			puzzleData["npc_scene"] = parsed["npc_scene"]
		if parsed.has("player_scene"):
			puzzleData["player_scene"] = parsed["player_scene"]

	if _npcPortraitTexture:
		rightPortrait.texture = _npcPortraitTexture
	elif parsed.has("npc_scene"):
		rightPortrait.texture = _getFirstFrameFromScene(parsed["npc_scene"])
	if parsed.has("player_scene"):
		leftPortrait.texture = _getFirstFrameFromScene(parsed["player_scene"])

	overlay.visible = true
	panel.visible = true
	leftPortrait.visible = true
	rightPortrait.visible = true
	get_tree().get_first_node_in_group("player").set_physics_process(false)
	showLine()

func openDirect(dialogLines: Array, playerScene: String = "", npcScene: String = "", restorePlayer: bool = false):
	if isOpen:
		return
	_activeNpc = null
	lines = dialogLines
	currentLine = 0
	isOpen = true
	isCinematic = true
	_restorePlayerOnClose = restorePlayer
	puzzleData = {}

	if playerScene != "":
		leftPortrait.texture = _getFirstFrameFromScene(playerScene)
	if npcScene != "":
		rightPortrait.texture = _getFirstFrameFromScene(npcScene)

	overlay.visible = true
	panel.visible = true
	leftPortrait.visible = playerScene != "" or npcScene != ""
	rightPortrait.visible = playerScene != "" or npcScene != ""
	get_tree().get_first_node_in_group("player").set_physics_process(false)
	showLine()

func _getFirstFrameFromScene(scenePath: String) -> Texture2D:
	var packed = load(scenePath)
	if not packed:
		push_error("No se pudo cargar la escena: " + scenePath)
		return null

	var instance = packed.instantiate()
	var animSprite = _findAnimatedSprite(instance)

	var texture: Texture2D = null
	if animSprite and animSprite.sprite_frames:
		var frames = animSprite.sprite_frames
		var animName = animSprite.animation if animSprite.animation != "" else "default"
		if frames.has_animation(animName) and frames.get_frame_count(animName) > 0:
			texture = frames.get_frame_texture(animName, 0)

	# Fallback: buscar Sprite2D normal
	if not texture:
		var sprite = _findSprite2D(instance)
		if sprite:
			texture = sprite.texture

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

func _findSprite2D(node: Node) -> Sprite2D:
	if node is Sprite2D:
		return node
	for child in node.get_children():
		var result = _findSprite2D(child)
		if result:
			return result
	return null

func showLine():
	var lineData = lines[currentLine]
	var isPlayer = lineData["speaker"] == "Jugador"
	var displaySpeaker = lineData["speaker"]
	if isPlayer:
		displaySpeaker = GameData.playerName

	speakerLabel.text = displaySpeaker
	fullText = lineData["text"].replace("{nombre}", GameData.playerName)
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
	if not isOpen:
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var isInteract = event.keycode == KEY_E or event.physical_keycode == KEY_E \
		or event.is_action("interact")
	if not isInteract:
		return

	var puzzle = get_tree().get_first_node_in_group("puzzle")
	if puzzle and puzzle.isOpen:
		return

	get_viewport().set_input_as_handled()

	if isTyping:
		isTyping = false
	else:
		nextLine()

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
	if isCinematic:
		isCinematic = false
		puzzleData = {}
		_activeNpc = null
		var shouldRestore = _restorePlayerOnClose
		_restorePlayerOnClose = false
		if shouldRestore:
			var player = get_tree().get_first_node_in_group("player")
			if player:
				player.set_physics_process(true)
				player.set_process_unhandled_input(true)
				player.set_process_input(true)
		emit_signal("cinematicDialogFinished")
		return
	get_tree().get_first_node_in_group("player").set_physics_process(true)
	if not puzzleData.is_empty():
		var puzzle = get_tree().get_first_node_in_group("puzzle")
		var dataToOpen = puzzleData
		var npcRef = _activeNpc
		puzzleData = {}
		_activeNpc = null
		if puzzle:
			puzzle.open(dataToOpen, npcRef)
