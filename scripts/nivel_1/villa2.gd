extends Node2D

const WorldPromptScript = preload("res://scripts/common/ui/worldPrompt.gd")

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
	_showEscuelaPrompt()

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
	var fadeLayer = CanvasLayer.new()
	fadeLayer.layer = 10
	add_child(fadeLayer)
	var fadeRect = ColorRect.new()
	fadeRect.anchor_right = 1.0
	fadeRect.anchor_bottom = 1.0
	fadeRect.color = Color(0, 0, 0, 1)
	fadeLayer.add_child(fadeRect)

	var tween = create_tween()
	tween.tween_property(fadeRect, "color", Color(0, 0, 0, 0), 0.8)
	tween.tween_callback(func():
		fadeRect.queue_free()
		fadeLayer.queue_free()
	)

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

	var fadeLayer = CanvasLayer.new()
	fadeLayer.layer = 10
	add_child(fadeLayer)
	var fadeRect = ColorRect.new()
	fadeRect.anchor_right = 1.0
	fadeRect.anchor_bottom = 1.0
	fadeRect.color = Color(0, 0, 0, 0)
	fadeLayer.add_child(fadeRect)

	var tween = create_tween()
	tween.tween_property(fadeRect, "color", Color(0, 0, 0, 1), 0.8)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/nivel_1/Villa1.tscn"))

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

	var fadeLayer = CanvasLayer.new()
	fadeLayer.layer = 10
	add_child(fadeLayer)
	var fadeRect = ColorRect.new()
	fadeRect.anchor_right = 1.0
	fadeRect.anchor_bottom = 1.0
	fadeRect.color = Color(0, 0, 0, 0)
	fadeLayer.add_child(fadeRect)

	var tween = create_tween()
	tween.tween_property(fadeRect, "color", Color(0, 0, 0, 1), 0.8)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/nivel_1/Escuela.tscn"))
