extends Control

@onready var playButton = $VBoxContainer/PlayButton
@onready var namePanel = $VBoxContainer/NamePanel
@onready var nameInput = $VBoxContainer/NamePanel/NameInput
@onready var errorLabel = $VBoxContainer/NamePanel/ErrorLabel

var skipButton: Button

func _ready():
	_applyGlobalTheme()
	_createSkipButton()
	# ── Música del menú principal ──────────────────────────────────────────
	DJManager.playMusic("menu")

func _applyGlobalTheme() -> void:
	var font = load("res://assets/MotionControl-Bold.otf")
	var globalTheme = Theme.new()
	globalTheme.default_font = font
	globalTheme.default_font_size = 20
	get_tree().root.theme = globalTheme

func _createSkipButton() -> void:
	skipButton = Button.new()
	skipButton.text = "Omitir intro"
	skipButton.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	skipButton.custom_minimum_size = Vector2(200, 40)
	skipButton.add_theme_font_size_override("font_size", 16)
	skipButton.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	skipButton.pressed.connect(_on_skip_button_pressed)
	$VBoxContainer.add_child(skipButton)

func _on_play_button_pressed() -> void:
	playButton.visible = false
	skipButton.visible = false
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

func _on_skip_button_pressed() -> void:
	GameData.playerName = "Player"
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
