extends Node2D

const SPAWN_LEFT_X  := 80.0
const SPAWN_RIGHT_X := 1070.0
const SPAWN_Y       := 570.0

# Spawn especial al volver de Escuela (frente al sprite school)
const SPAWN_ESCUELA_X := 382.0

# Posicion del sprite school en la escena
const ESCUELA_POS     := Vector2(382, 474)
const INTERACT_RADIUS := 150.0

var escuelaLabel: Label = null
var escuelaLabelLayer: CanvasLayer = null
var escuela_nearby: bool = false
var escuelaInteracted: bool = false

func _ready():
	_applyGlobalTheme()
	_positionPlayer()
	_fadeIn()
	_buildExitTrigger()
	_showEscuelaExclamation()

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

# Simbolo "!" sobre la escuela
func _showEscuelaExclamation() -> void:
	escuelaLabelLayer = CanvasLayer.new()
	escuelaLabelLayer.layer = 0
	add_child(escuelaLabelLayer)

	escuelaLabel = Label.new()
	escuelaLabel.text = "!"
	escuelaLabel.add_theme_font_size_override("font_size", 64)
	escuelaLabel.add_theme_color_override("font_color", Color(1, 0, 0, 1))
	escuelaLabel.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	escuelaLabel.add_theme_constant_override("shadow_offset_x", 3)
	escuelaLabel.add_theme_constant_override("shadow_offset_y", 3)

	escuelaLabelLayer.add_child(escuelaLabel)
	_updateEscuelaLabelPosition()
	_floatLabel(escuelaLabel)

func _updateEscuelaLabelPosition() -> void:
	if not is_instance_valid(escuelaLabel):
		return
	var camera = get_viewport().get_camera_2d()
	var screenPos: Vector2
	if camera:
		screenPos = get_viewport().get_canvas_transform() * ESCUELA_POS
	else:
		screenPos = ESCUELA_POS
	escuelaLabel.position = screenPos + Vector2(0, -120)

func _floatLabel(label: Label) -> void:
	while is_instance_valid(label):
		_updateEscuelaLabelPosition()
		var camera = get_viewport().get_camera_2d()
		var screenPos: Vector2
		if camera:
			screenPos = get_viewport().get_canvas_transform() * ESCUELA_POS
		else:
			screenPos = ESCUELA_POS
		var baseY = screenPos.y + (-120)
		var t = create_tween()
		t.tween_property(label, "position:y", baseY - 12.0, 0.5).set_trans(Tween.TRANS_SINE)
		t.tween_property(label, "position:y", baseY, 0.5).set_trans(Tween.TRANS_SINE)
		await t.finished

# Deteccion de proximidad y entrada a Escuela
func _process(_delta) -> void:
	if escuelaInteracted:
		return
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	var dist = player.global_position.distance_to(ESCUELA_POS)
	escuela_nearby = dist < INTERACT_RADIUS
	if escuela_nearby and is_instance_valid(escuelaLabel):
		_updateEscuelaLabelPosition()

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

	if is_instance_valid(escuelaLabel):
		escuelaLabel.queue_free()
	if is_instance_valid(escuelaLabelLayer):
		escuelaLabelLayer.queue_free()

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
