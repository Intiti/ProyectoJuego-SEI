extends Node2D

const WorldPromptScript = preload("res://scripts/common/ui/worldPrompt.gd")
const ScoreHudScript = preload("res://scripts/common/ui/scoreHud.gd")
const FaderScript = preload("res://scripts/common/ui/sceneFader.gd")
const ExitMarkerScript = preload("res://scripts/common/ui/exitMarker.gd")
const ResumenScript = preload("res://scripts/common/ui/resumenNivel1.gd")

# Texto de la flecha del borde izquierdo (de vuelta a Villa1)
const EXIT_LEFT_LABEL := ""
const EXIT_RIGHT_LABEL := "Al Bosque Profundo"

var _exitRightMarker = null

const SPAWN_LEFT_X  := 80.0
const SPAWN_RIGHT_X := 1070.0
const SPAWN_Y       := 570.0

# Spawn especial al volver de Escuela (frente al sprite school)
const SPAWN_ESCUELA_X := 382.0

# Posicion del sprite school en la escena
const ESCUELA_POS     := Vector2(382, 474)
const INTERACT_RADIUS := 150.0

# Flecha ▼ + tecla [E] que aparece SOLO cuando el jugador está cerca de la puerta
var escuelaPrompt: Node2D = null
var escuela_nearby: bool = false
var escuelaInteracted: bool = false

func _ready():
	_applyGlobalTheme()
	_positionPlayer()
	_fadeIn()
	_buildExitTrigger()
	_buildRightExitTrigger()
	_showEscuelaPrompt()
	add_child(ScoreHudScript.new())
	_buildExitMarker()
	_buildRightExitMarker()
	GameData.problemsChanged.connect(_onProblemsChanged)
	call_deferred("_connectResumen")

func _connectResumen() -> void:
	var dialogBox = get_tree().get_first_node_in_group("dialog_box")
	if dialogBox:
		dialogBox.cinematicDialogFinished.connect(_onCinematicDialogFinished)

func _onCinematicDialogFinished() -> void:
	if GameData.nivel1Terminado and not GameData.nivel1ResumenMostrado:
		GameData.nivel1ResumenMostrado = true
		var resumen = ResumenScript.new()
		add_child(resumen)

func _applyGlobalTheme() -> void:
	var font = load("res://assets/fonts/MotionControl-Bold.otf")
	var theme = Theme.new()
	theme.default_font = font
	theme.default_font_size = 20
	get_tree().root.theme = theme

func _positionPlayer() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var x: float
	if GameData.spawnSide == "escuela":
		x = SPAWN_ESCUELA_X
	elif GameData.spawnSide == "right":
		x = SPAWN_RIGHT_X
	else:
		x = SPAWN_LEFT_X
	player.position = Vector2(x, SPAWN_Y)

func _fadeIn() -> void:
	FaderScript.fadeIn(self, 0.8)

# Flecha del borde izquierdo (← Villa1)
func _buildExitMarker() -> void:
	var m = ExitMarkerScript.new()
	m.setup(ExitMarkerScript.Side.LEFT, EXIT_LEFT_LABEL)
	add_child(m)

# Trigger de salida hacia Villa1 (borde izquierdo)
func _buildExitTrigger() -> void:
	var exitArea = Area2D.new()
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(32, 400)
	shape.shape = rect
	exitArea.add_child(shape)
	exitArea.position = Vector2(16, 400)
	add_child(exitArea)
	exitArea.body_entered.connect(_on_exit_body_entered)

func _on_exit_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	_goToVilla1()

func _goToVilla1() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)

	GameData.spawnSide = "right"

	FaderScript.fadeOutAndChange(self, "res://scenes/nivel_1/Villa1.tscn", 0.8)

# ─── Salida derecha hacia Nivel 2 (Bosque Profundo) ──────────────────────────

func _buildRightExitMarker() -> void:
	var canPass = GameData.isSolved("res://dialogs/nivel_1/npc_guardia_villa2.json")
	_exitRightMarker = ExitMarkerScript.new()
	_exitRightMarker.setup(ExitMarkerScript.Side.RIGHT, EXIT_RIGHT_LABEL, canPass)
	add_child(_exitRightMarker)

func _buildRightExitTrigger() -> void:
	var exitArea = Area2D.new()
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(32, 400)
	shape.shape = rect
	exitArea.add_child(shape)
	exitArea.position = Vector2(1136, 400)
	add_child(exitArea)
	exitArea.body_entered.connect(_on_right_exit_body_entered)

func _on_right_exit_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if not GameData.isSolved("res://dialogs/nivel_1/npc_guardia_villa2.json"):
		return
	_goToBosque()

func _goToBosque() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)
	FaderScript.fadeOutAndChange(self, "res://scenes/nivel_2/1SenderoDeLasHuellas.tscn", 0.8)

func _onProblemsChanged() -> void:
	if is_instance_valid(_exitRightMarker) and GameData.isSolved("res://dialogs/nivel_1/npc_guardia_villa2.json"):
		_exitRightMarker.setActive(true)

# ─── Flecha de entrada ▼ (aparece al acercarse) ───────────────────────────────
# Offset desde ESCUELA_POS hasta el punto donde apunta la flecha (la puerta).
# Si la flecha queda muy alta/baja o corrida, ajusta este valor.
const ESCUELA_PROMPT_OFFSET := Vector2(0, -50)

func _showEscuelaPrompt() -> void:
	escuelaPrompt = WorldPromptScript.new()
	escuelaPrompt.setup(WorldPromptScript.Marker.ARROW, "Entrar")
	escuelaPrompt.position = ESCUELA_POS + ESCUELA_PROMPT_OFFSET
	add_child(escuelaPrompt)

# Deteccion de proximidad y entrada a Escuela
func _process(_delta) -> void:
	if escuelaInteracted:
		return
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	var dist = player.global_position.distance_to(ESCUELA_POS)
	var nowNearby = dist < INTERACT_RADIUS
	if nowNearby != escuela_nearby:
		escuela_nearby = nowNearby
		if is_instance_valid(escuelaPrompt):
			escuelaPrompt.setNear(escuela_nearby)

func _unhandled_input(event) -> void:
	if escuelaInteracted:
		return
	if not escuela_nearby:
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_E or event.physical_keycode == KEY_E or event.is_action("interact"):
		get_viewport().set_input_as_handled()
		_enterEscuela()

func _enterEscuela() -> void:
	escuelaInteracted = true

	if is_instance_valid(escuelaPrompt):
		escuelaPrompt.queue_free()

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)

	GameData.spawnSide = "left"

	FaderScript.fadeOutAndChange(self, "res://scenes/nivel_1/Escuela.tscn", 0.8)
