extends Control

const DevPanelScript := preload("res://scripts/common/ui/devPanel.gd")
const InsigniasScreenScript := preload("res://scripts/common/ui/insigniasScreen.gd")
const LeaderboardScreenScript := preload("res://scripts/common/ui/leaderboardScreen.gd")
const FormularioAliasScript := preload("res://scripts/common/ui/formularioAlias.gd")

@onready var playButton = $VBoxContainer/PlayButton
@onready var badgesButton = $VBoxContainer/BadgesButton
@onready var rankingButton = $VBoxContainer/RankingButton
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
	var form := FormularioAliasScript.new()
	form.aliasConfirmado.connect(_onAliasConfirmado)
	form.cancelado.connect(func(): busy = false)
	add_child(form)

func _onAliasConfirmado(alias: String) -> void:
	GameData.resetRun()
	GameData.playerName = alias
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/nivel_0/Intro.tscn")

func _on_badges_button_pressed() -> void:
	if busy:
		return
	add_child(InsigniasScreenScript.new())

func _on_ranking_button_pressed() -> void:
	if busy:
		return
	add_child(LeaderboardScreenScript.new())

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
	GameData.resetRun()
	GameData.playerName = nombre
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/nivel_0/Intro.tscn")
