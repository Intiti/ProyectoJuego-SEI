extends CharacterBody2D

@export var dialogFile: String = ""
@export var needsHelp: bool = true
@export var npcSprite: Texture2D
@export var solvedFlag: String = ""  # nombre de la propiedad en GameData a poner true al resolver

var playerNearby: bool = false

# "!" rojo como hijo 2D directo del NPC (coordenadas mundo, se mueve con el NPC)
var _exclamLabel: Label = null

func _ready():
	add_to_group("npc")
	if npcSprite:
		$Sprite2D.texture = npcSprite

	# Si el puzzle de este NPC ya fue resuelto en una sesión anterior
	# (el jugador cambió de villa y volvió), no mostrar "!"
	if dialogFile != "" and GameData.isSolved(dialogFile):
		needsHelp = false

	if needsHelp:
		_createExclamation()

func _createExclamation():
	_exclamLabel = Label.new()
	_exclamLabel.text = "!"
	_exclamLabel.add_theme_font_size_override("font_size", 80)
	_exclamLabel.add_theme_color_override("font_color", Color(1, 0, 0, 1))
	_exclamLabel.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	_exclamLabel.add_theme_constant_override("shadow_offset_x", 3)
	_exclamLabel.add_theme_constant_override("shadow_offset_y", 3)
	# Offset local: centrado sobre el sprite (que mide ~140px en world space)
	_exclamLabel.position = Vector2(-16, -155)
	add_child(_exclamLabel)
	_floatExclam()

func _floatExclam():
	if not is_instance_valid(_exclamLabel):
		return
	var baseY: float = _exclamLabel.position.y
	while is_instance_valid(_exclamLabel):
		var t = create_tween()
		t.tween_property(_exclamLabel, "position:y", baseY - 12.0, 0.5).set_trans(Tween.TRANS_SINE)
		t.tween_property(_exclamLabel, "position:y", baseY, 0.5).set_trans(Tween.TRANS_SINE)
		await t.finished

func _on_detection_body_entered(body):
	if body.is_in_group("player"):
		playerNearby = true

func _on_detection_body_exited(body):
	if body.is_in_group("player"):
		playerNearby = false

func _unhandled_input(event):
	# Sin problema pendiente: no hay interacción posible
	if not needsHelp:
		return
	if not playerNearby:
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_E or event.physical_keycode == KEY_E or event.is_action("interact"):
		get_viewport().set_input_as_handled()
		tryStartDialog()

func onPuzzleSolved():
	needsHelp = false
	if is_instance_valid(_exclamLabel):
		_exclamLabel.queue_free()
		_exclamLabel = null
	# Persistir que este NPC fue resuelto para cuando el jugador vuelva a la escena
	if dialogFile != "":
		GameData.markSolved(dialogFile)
	if solvedFlag != "" and GameData.get(solvedFlag) != null:
		GameData.set(solvedFlag, true)

func tryStartDialog():
	if not playerNearby or not needsHelp:
		return
	if dialogFile == "":
		push_error("NPC '" + name + "' no tiene dialogFile asignado.")
		return
	var dialogBox = get_tree().get_first_node_in_group("dialog_box")
	if not dialogBox or dialogBox.isOpen:
		return
	var puzzle = get_tree().get_first_node_in_group("puzzle")
	if puzzle and puzzle.isOpen:
		return
	dialogBox.openWithNpc(dialogFile, self)
