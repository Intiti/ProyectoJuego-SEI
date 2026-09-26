extends Control

@onready var playButton = $VBoxContainer/PlayButton
@onready var namePanel = $VBoxContainer/NamePanel
@onready var nameInput = $VBoxContainer/NamePanel/NameInput
@onready var errorLabel = $VBoxContainer/NamePanel/ErrorLabel

func _ready():
	_applyGlobalTheme()

func _applyGlobalTheme() -> void:
	var font = load("res://assets/MotionControl-Bold.otf")
	var globalTheme = Theme.new()
	globalTheme.default_font = font
	globalTheme.default_font_size = 20
	get_tree().root.theme = globalTheme

func _on_play_button_pressed() -> void:
	playButton.visible = false
	namePanel.visible = true
	nameInput.grab_focus()

func _on_confirm_button_pressed() -> void:
	var nombre = nameInput.text.strip_edges()
	if nombre.length() < 3:
		errorLabel.text = "El nombre debe tener al menos 3 caracteres."
		errorLabel.visible = true
		return
	errorLabel.visible = false
	GameData.playerName = nombre
	get_tree().change_scene_to_file("res://scenes/Intro.tscn")
