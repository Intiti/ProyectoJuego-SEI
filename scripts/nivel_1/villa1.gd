extends Node2D

# X donde aparece el jugador según de dónde viene
const SPAWN_LEFT_X   := 80.0
const SPAWN_RIGHT_X  := 1070.0
const SPAWN_Y        := 570.0

# Spawn especial al volver de Panadería (frente a la puerta)
const SPAWN_PANADERIA_X := 478.0

# Posición de la panadería en la escena (Sprite2D "pan.png")
const PANADERIA_POS   := Vector2(478, 464)
const INTERACT_RADIUS := 150.0

var panaderiaLabel: Label = null
var panaderiaLabelLayer: CanvasLayer = null
var panadering_nearby: bool = false
var panaderiaInteracted: bool = false

func _ready():
	_applyGlobalTheme()
	_positionPlayer()
	_fadeIn()
	_buildExitTrigger()
	_showPanaderiaExclamation()

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
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/nivel_1/Villa2.tscn"))

# ─── Símbolo "!" sobre la panadería ──────────────────────────────────────────

func _showPanaderiaExclamation() -> void:
	panaderiaLabelLayer = CanvasLayer.new()
	panaderiaLabelLayer.layer = 0
	add_child(panaderiaLabelLayer)

	panaderiaLabel = Label.new()
	panaderiaLabel.text = "!"
	panaderiaLabel.add_theme_font_size_override("font_size", 64)
	panaderiaLabel.add_theme_color_override("font_color", Color(1, 0, 0, 1))
	panaderiaLabel.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	panaderiaLabel.add_theme_constant_override("shadow_offset_x", 3)
	panaderiaLabel.add_theme_constant_override("shadow_offset_y", 3)

	panaderiaLabelLayer.add_child(panaderiaLabel)
	_updatePanaderiaLabelPosition()
	_floatLabel(panaderiaLabel)

func _updatePanaderiaLabelPosition() -> void:
	if not is_instance_valid(panaderiaLabel):
		return
	var camera = get_viewport().get_camera_2d()
	var screenPos: Vector2
	if camera:
		screenPos = get_viewport().get_canvas_transform() * PANADERIA_POS
	else:
		screenPos = PANADERIA_POS
	panaderiaLabel.position = screenPos + Vector2(80, -120)

func _floatLabel(label: Label) -> void:
	var baseOffset := Vector2(80, -120)
	while is_instance_valid(label):
		_updatePanaderiaLabelPosition()
		var camera = get_viewport().get_camera_2d()
		var screenPos: Vector2
		if camera:
			screenPos = get_viewport().get_canvas_transform() * PANADERIA_POS
		else:
			screenPos = PANADERIA_POS
		var baseY = screenPos.y + baseOffset.y
		var t = create_tween()
		t.tween_property(label, "position:y", baseY - 12.0, 0.5).set_trans(Tween.TRANS_SINE)
		t.tween_property(label, "position:y", baseY, 0.5).set_trans(Tween.TRANS_SINE)
		await t.finished

# ─── Detección de proximidad y entrada a Panadería ───────────────────────────

func _process(_delta) -> void:
	if panaderiaInteracted:
		return
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	var dist = player.global_position.distance_to(PANADERIA_POS)
	panadering_nearby = dist < INTERACT_RADIUS
	if panadering_nearby and is_instance_valid(panaderiaLabel):
		_updatePanaderiaLabelPosition()

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

	if is_instance_valid(panaderiaLabel):
		panaderiaLabel.queue_free()
	if is_instance_valid(panaderiaLabelLayer):
		panaderiaLabelLayer.queue_free()

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)

	# Entramos siempre por la izquierda de Panadería
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
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/nivel_1/Panaderia.tscn"))
