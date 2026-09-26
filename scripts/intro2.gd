extends Node2D

var pankoDialogLines = [
	{"speaker": "Jugador", "text": "¡Panko, ahí estás! ¡Te busqué por todos lados!"},
	{"speaker": "Panko", "text": "Miau."},
	{"speaker": "Panko", "text": "Miau miau."},
	{"speaker": "Jugador", "text": "Espera... ¿a dónde vas?"},
]

@onready var fadeRect = $FadeLayer/FadeRect
@onready var dialogBox = $DialogBox

func _ready():
	_applyGlobalTheme()
	fadeRect.color = Color(0, 0, 0, 1)
	_blockPlayer()
	dialogBox.cinematicDialogFinished.connect(_onDialogFinished)
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
	tween.tween_property(fadeRect, "color", Color(0, 0, 0, 0), 1.0)
	tween.tween_callback(_startDialog)

func _startDialog():
	dialogBox.openDirect(pankoDialogLines, "res://scenes/Player.tscn", "res://scenes/CAT.tscn")

func _onDialogFinished():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(true)
