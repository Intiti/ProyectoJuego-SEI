extends Node2D

const SPAWN_LEFT_X  := 80.0
const SPAWN_RIGHT_X := 1070.0
const SPAWN_Y       := 570.0

func _ready():
	_applyGlobalTheme()
	_positionPlayer()
	_fadeIn()
	_buildExitTriggers()

func _applyGlobalTheme() -> void:
	var font = load("res://assets/MotionControl-Bold.otf")
	var theme = Theme.new()
	theme.default_font = font
	theme.default_font_size = 20
	get_tree().root.theme = theme

func _positionPlayer() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var x = SPAWN_RIGHT_X if GameData.spawnSide == "right" else SPAWN_LEFT_X
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

# ─── Triggers de salida (ambos lados → vuelve a Villa1 frente a la panadería) ─

func _buildExitTriggers() -> void:
	# Salida izquierda
	_makeExitArea(Vector2(16, 400))
	# Salida derecha
	_makeExitArea(Vector2(1136, 400))

func _makeExitArea(pos: Vector2) -> void:
	var exitArea = Area2D.new()
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(32, 400)
	shape.shape = rect
	exitArea.add_child(shape)
	exitArea.position = pos
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

	# Siempre spawnear frente a la panadería en Villa1
	GameData.spawnSide = "panaderia"

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
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/Villa1.tscn"))
