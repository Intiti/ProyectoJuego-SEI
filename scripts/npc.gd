extends CharacterBody2D

@export var dialogFile: String = ""
@export var needsHelp: bool = true

var playerNearby: bool = false

@onready var exclamation = $Exclamation
@onready var interactHint = $InteractHint

func _ready():
	add_to_group("npc")
	exclamation.visible = needsHelp
	interactHint.visible = false

func _on_detection_body_entered(body):
	if body.is_in_group("player"):
		playerNearby = true
		interactHint.visible = true

func _on_detection_body_exited(body):
	if body.is_in_group("player"):
		playerNearby = false
		interactHint.visible = false

# llamado desde dialogBox cuando el jugador presiona interact cerca del NPC
func tryStartDialog():
	if not playerNearby:
		return
	var dialogBox = get_tree().get_first_node_in_group("dialog_box")
	if dialogBox:
		dialogBox.open(dialogFile)
