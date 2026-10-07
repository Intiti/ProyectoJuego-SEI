extends CharacterBody2D

const WorldPromptScript = preload("res://scripts/common/ui/worldPrompt.gd")

@export var dialogFile: String = ""
@export var needsHelp: bool = true
@export var npcSprite: Texture2D
@export var solvedFlag: String = ""  # nombre de la propiedad en GameData a poner true al resolver

var playerNearby: bool = false

# Indicador sobre el NPC: "!" de lejos, tecla [E] "Hablar" al acercarse
var _prompt: Node2D = null

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
	_prompt = WorldPromptScript.new()
	_prompt.setup(WorldPromptScript.Marker.EXCLAIM, "Hablar")
	# Centro del indicador sobre la cabeza del NPC (coordenadas locales)
	_prompt.position = Vector2(0, -115)
	add_child(_prompt)
	if playerNearby:
		_prompt.setNear(true)

func _removePrompt():
	if is_instance_valid(_prompt):
		_prompt.queue_free()
	_prompt = null

func _on_detection_body_entered(body):
	if body.is_in_group("player"):
		playerNearby = true
		if is_instance_valid(_prompt) and needsHelp:
			_prompt.setNear(true)

func _on_detection_body_exited(body):
	if body.is_in_group("player"):
		playerNearby = false
		if is_instance_valid(_prompt):
			_prompt.setNear(false)

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
	_removePrompt()
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
