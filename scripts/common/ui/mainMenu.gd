extends Control

const DevPanelScript := preload("res://scripts/common/ui/devPanel.gd")
const InsigniasScreenScript := preload("res://scripts/common/ui/insigniasScreen.gd")

@onready var playButton = $VBoxContainer/PlayButton
@onready var badgesButton = $VBoxContainer/BadgesButton
@onready var namePanel = $VBoxContainer/NamePanel
@onready var nameInput = $VBoxContainer/NamePanel/NameInput
@onready var errorLabel = $VBoxContainer/NamePanel/ErrorLabel
@onready var confirmButton = $VBoxContainer/NamePanel/ConfirmButton

var busy: bool = false

func _ready():
	_applyGlobalTheme()
	add_child(DevPanelScript.new())
	DJManager.playMusic("menu")

func _applyGlobalTheme() -> void:
	var font = load("res://assets/fonts/MotionControl-Bold.otf")
	var globalTheme = Theme.new()
	globalTheme.default_font = font
	globalTheme.default_font_size = 20
	get_tree().root.theme = globalTheme

func _on_play_button_pressed() -> void:
	if busy:
		return
	busy = true
	await get_tree().create_timer(0.28).timeout
	var fadeOut := create_tween()
	fadeOut.tween_property(playButton, "modulate:a", 0.0, 0.15)
	await fadeOut.finished
	playButton.visible = false
	badgesButton.visible = false
	namePanel.modulate.a = 0.0
	namePanel.visible = true
	nameInput.grab_focus()
	await get_tree().process_frame
	namePanel.pivot_offset = namePanel.size * 0.5
	namePanel.scale = Vector2(0.85, 0.85)
	var fadeIn := create_tween().set_parallel(true)
	fadeIn.tween_property(namePanel, "modulate:a", 1.0, 0.2)
	fadeIn.tween_property(namePanel, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	confirmButton.replayAppear(0.12)
	busy = false

func _on_badges_button_pressed() -> void:
	if busy:
		return
	add_child(InsigniasScreenScript.new())

func _on_confirm_button_pressed() -> void:
	if busy:
		return
	var nombre = nameInput.text.strip_edges()
	if nombre.length() < 3:
		errorLabel.text = "El nombre debe tener al menos 3 caracteres."
		errorLabel.visible = true
		return
	errorLabel.visible = false
	busy = true
	GameData.playerName = nombre
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/nivel_0/Intro.tscn")
