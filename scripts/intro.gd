extends Node2D

var introDialogLines = [
	{"speaker": "Jugador", "text": "¡PANKO!  ¡¿PANKO DÓNDE ESTÁS?!"},
	{"speaker": "Jugador", "text": "¿Dónde se metió este gato ahora? ¡PANKOO!"},
]

@onready var fadeRect = $FadeLayer/FadeRect
@onready var tutorialLabel = $TutorialLayer/TutorialLabel
@onready var dialogBox = $DialogBox

func _ready():
	_applyGlobalTheme()
	fadeRect.color = Color(0, 0, 0, 1)
	_blockPlayer()
	dialogBox.cinematicDialogFinished.connect(_onIntroDialogFinished)
	_fadeIn()

func _applyGlobalTheme() -> void:
	var font = load("res://assets/MotionControl-Bold.otf")
	var globalTheme = Theme.new()
	globalTheme.default_font = font
	globalTheme.default_font_size = 20
	get_tree().root.theme = globalTheme

func _blockPlayer():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)

func _fadeIn():
	var tween = create_tween()
	tween.tween_property(fadeRect, "color", Color(0, 0, 0, 0), 2.0)
	tween.tween_callback(_startDialog)

func _startDialog():
	dialogBox.openDirect(introDialogLines, "res://scenes/Player.tscn")

func _onIntroDialogFinished():
	tutorialLabel.visible = true
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(true)

func _on_exit_trigger_body_entered(body):
	if not body.is_in_group("player"):
		return
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Intro2.tscn")
