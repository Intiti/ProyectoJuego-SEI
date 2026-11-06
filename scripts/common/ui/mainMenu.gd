extends Control

const DevPanelScript := preload("res://scripts/common/ui/devPanel.gd")
const InsigniasScreenScript := preload("res://scripts/common/ui/insigniasScreen.gd")
const LeaderboardScreenScript := preload("res://scripts/common/ui/leaderboardScreen.gd")
const FormularioAliasScript := preload("res://scripts/common/ui/formularioAlias.gd")
const MenuButtonScript := preload("res://scripts/common/ui/menuButton.gd")

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
	#if OS.is_debug_build():
		#add_child(DevPanelScript.new())
	DJManager.playMusic("menu")
	_crearBotonCarpetaJson()

# Botón abajo a la derecha: abre la carpeta donde se guardan los JSON
# (reporte_jugador.json, insignias.json, progreso/ranking del nivel 3, etc.).
func _crearBotonCarpetaJson() -> void:
	var btn := Button.new()
	btn.set_script(MenuButtonScript)
	btn.text = "CARPETA JSON"
	btn.add_theme_font_size_override("font_size", 20)
	btn.anchor_left = 1.0
	btn.anchor_right = 1.0
	btn.anchor_top = 1.0
	btn.anchor_bottom = 1.0
	btn.offset_left = -240.0
	btn.offset_right = -20.0
	btn.offset_top = -68.0
	btn.offset_bottom = -20.0
	btn.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	btn.grow_vertical = Control.GROW_DIRECTION_BEGIN
	btn.set("appearDelay", 2.45)
	btn.pressed.connect(_on_open_json_folder_pressed)
	add_child(btn)

func _on_open_json_folder_pressed() -> void:
	if busy:
		return
	var ruta: String = ProjectSettings.globalize_path("user://")
	DirAccess.make_dir_recursive_absolute(ruta)
	var err: int = OS.shell_open(ruta)
	if err != OK:
		push_error("No se pudo abrir la carpeta %s (error %d)" % [ruta, err])

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

func _onAliasConfirmado(alias: String, characterName: String) -> void:
	GameData.resetRun()
	GameData.assignAlias(alias, characterName)
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

func _on_quit_button_pressed() -> void:
	if busy:
		return
	get_tree().quit()

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
