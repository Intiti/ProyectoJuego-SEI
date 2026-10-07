extends Node2D

const WorldPromptScript = preload("res://scripts/common/ui/worldPrompt.gd")
const ScoreHudScript = preload("res://scripts/common/ui/scoreHud.gd")
const FaderScript = preload("res://scripts/common/ui/sceneFader.gd")
const ExitMarkerScript = preload("res://scripts/common/ui/exitMarker.gd")

# Texto de la flecha del borde derecho (hacia Villa2)
const EXIT_RIGHT_LABEL := ""

# X donde aparece el jugador según de dónde viene
const SPAWN_LEFT_X   := 80.0
const SPAWN_RIGHT_X  := 1070.0
const SPAWN_Y        := 570.0

# Spawn especial al volver de Panadería (frente a la puerta)
const SPAWN_PANADERIA_X := 478.0

# Posición de la panadería en la escena (Sprite2D "pan.png")
const PANADERIA_POS   := Vector2(478, 464)
const INTERACT_RADIUS := 150.0

# Flecha ▼ + tecla [E] que aparece SOLO cuando el jugador está cerca de la puerta
var panaderiaPrompt: Node2D = null
var panadering_nearby: bool = false
var panaderiaInteracted: bool = false

func _ready():
	_applyGlobalTheme()
	_positionPlayer()
	_fadeIn()
	_buildExitTrigger()
	_showPanaderiaPrompt()
	add_child(ScoreHudScript.new())
	_buildExitMarker()

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
	if GameData.spawnSide == "panaderia":
		x = SPAWN_PANADERIA_X
	elif GameData.spawnSide == "right":
		x = SPAWN_RIGHT_X
	else:
		x = SPAWN_LEFT_X
	player.position = Vector2(x, SPAWN_Y)

func _fadeIn() -> void:
	FaderScript.fadeIn(self, 0.8)

# ─── Flecha del borde derecho (→ Villa2) ──────────────────────────────────────

func _buildExitMarker() -> void:
	var m = ExitMarkerScript.new()
	m.setup(ExitMarkerScript.Side.RIGHT, EXIT_RIGHT_LABEL)
	add_child(m)

# ─── Trigger de salida hacia Villa2 (borde derecho) ───────────────────────────

func _buildExitTrigger() -> void:
	var exitArea = Area2D.new()
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(32, 400)
	shape.shape = rect
	exitArea.add_child(shape)
	exitArea.position = Vector2(1136, 400)
	add_child(exitArea)
	exitArea.body_entered.connect(_on_exit_body_entered)

func _on_exit_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	_goToVilla2()

func _goToVilla2() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)

	GameData.spawnSide = "left"

	FaderScript.fadeOutAndChange(self, "res://scenes/nivel_1/Villa2.tscn", 0.8)

# ─── Flecha de entrada ▼ (aparece al acercarse) ───────────────────────────────
# Offset desde PANADERIA_POS hasta el punto donde apunta la flecha (la puerta).
# Si la flecha queda muy alta/baja o corrida, ajusta este valor.
const PANADERIA_PROMPT_OFFSET := Vector2(0, -50)

func _showPanaderiaPrompt() -> void:
	panaderiaPrompt = WorldPromptScript.new()
	panaderiaPrompt.setup(WorldPromptScript.Marker.ARROW, "Entrar")
	panaderiaPrompt.position = PANADERIA_POS + PANADERIA_PROMPT_OFFSET
	add_child(panaderiaPrompt)

# ─── Detección de proximidad y entrada a Panadería ───────────────────────────

func _process(_delta) -> void:
	if panaderiaInteracted:
		return
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	var dist = player.global_position.distance_to(PANADERIA_POS)
	var nowNearby = dist < INTERACT_RADIUS
	if nowNearby != panadering_nearby:
		panadering_nearby = nowNearby
		if is_instance_valid(panaderiaPrompt):
			panaderiaPrompt.setNear(panadering_nearby)

func _unhandled_input(event) -> void:
	if panaderiaInteracted:
		return
	if not panadering_nearby:
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_E or event.physical_keycode == KEY_E or event.is_action("interact"):
		get_viewport().set_input_as_handled()
		_enterPanaderia()

func _enterPanaderia() -> void:
	panaderiaInteracted = true

	if is_instance_valid(panaderiaPrompt):
		panaderiaPrompt.queue_free()

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)

	# Entramos siempre por la izquierda de Panadería
	GameData.spawnSide = "left"

	FaderScript.fadeOutAndChange(self, "res://scenes/nivel_1/Panaderia.tscn", 0.8)
