extends Node2D

var pankoDialogLines = [
	{"speaker": "Jugador", "text": "¡Panko, ahí estás! ¡Te busqué por todos lados!"},
	{"speaker": "Panko", "text": "Miau."},
	{"speaker": "Panko", "text": "Miau miau."},
	{"speaker": "Jugador", "text": "Espera... ¿a dónde vas? NI SE TE OCURRA SALTAR DENTRO DEL POZO"},
]

# Posición del pozo en la escena (debe coincidir con el nodo Pozo en Intro2.tscn)
const POZO_POS = Vector2(964, 489)
const INTERACT_RADIUS = 150.0

@onready var fadeRect = $FadeLayer/FadeRect
@onready var dialogBox = $DialogBox

var pozoLabel: Label = null
var pozoLabelLayer: CanvasLayer = null
var tutorialLabel: Node = null
var tutorialLayer: CanvasLayer = null
var pozoNearby: bool = false
var wellInteracted: bool = false

func _ready():
	_applyGlobalTheme()
	fadeRect.color = Color(0, 0, 0, 1)
	$FadeLayer.visible = true
	_blockPlayer()
	dialogBox.cinematicDialogFinished.connect(_onDialogFinished)
	_fadeIn()

func _applyGlobalTheme() -> void:
	var font = load("res://assets/MotionControl-Bold.otf")
	var globalTheme = Theme.new()
	globalTheme.default_font = font
	globalTheme.default_font_size = 20
	get_tree().root.theme = globalTheme

func _blockPlayer():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)

func _fadeIn():
	var tween = create_tween()
	tween.tween_property(fadeRect, "color", Color(0, 0, 0, 0), 1.0)
	tween.tween_callback(_startDialog)

func _startDialog():
	dialogBox.openDirect(pankoDialogLines, "res://scenes/Player.tscn", "res://scenes/CAT.tscn")

func _onDialogFinished():
	_animatePankoToWell()

# ─── Animación de Panko ───────────────────────────────────────────────────────

func _animatePankoToWell():
	var panko = get_node_or_null("PANKO")
	if not panko:
		_afterPankoGone()
		return

	var sprite = _findAnimatedSprite(panko)
	if sprite:
		if sprite.sprite_frames and sprite.sprite_frames.has_animation("RUN"):
			sprite.play("RUN")
		else:
			sprite.play(sprite.animation)

	var startPos: Vector2 = panko.position
	var endPos: Vector2 = POZO_POS
	var arcPeak: Vector2 = Vector2(
		(startPos.x + endPos.x) / 2.0,
		min(startPos.y, endPos.y) - 120.0
	)
	var duration := 1.4
	var elapsed := 0.0

	while elapsed < duration:
		elapsed += get_process_delta_time()
		var t := clampf(elapsed / duration, 0.0, 1.0)
		var inv := 1.0 - t
		panko.position = inv * inv * startPos + 2.0 * inv * t * arcPeak + t * t * endPos
		if sprite:
			sprite.flip_h = (endPos.x < startPos.x)
		await get_tree().process_frame

	_fadePankoOut(panko)

func _fadePankoOut(panko: Node):
	var sprite = _findAnimatedSprite(panko)
	var tween = create_tween()
	if sprite:
		tween.tween_property(sprite, "modulate:a", 0.0, 0.8)
	else:
		tween.tween_property(panko, "modulate:a", 0.0, 0.8)
	tween.tween_callback(func():
		panko.queue_free()
		_afterPankoGone()
	)

func _afterPankoGone():
	# Liberar al jugador
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(true)

	# Mostrar tutorial y símbolo "!" sobre el pozo
	_showTutorialHint()
	_showPozoExclamation()

# ─── Tutorial "pulsa E para interactuar" ──────────────────────────────────────

func _showTutorialHint():
	tutorialLayer = CanvasLayer.new()
	tutorialLayer.layer = 5
	add_child(tutorialLayer)

	# RichTextLabel para poder colorear el "(!)" en rojo
	var richLabel = RichTextLabel.new()
	richLabel.bbcode_enabled = true
	richLabel.text = "Pulsa  E  para interactuar con objetos marcados ([color=red]![/color])"
	richLabel.add_theme_font_size_override("normal_font_size", 32)
	richLabel.add_theme_font_size_override("bold_font_size", 32)
	richLabel.add_theme_color_override("default_color", Color(1, 1, 1, 1))
	richLabel.add_theme_constant_override("shadow_offset_x", 2)
	richLabel.add_theme_constant_override("shadow_offset_y", 2)
	richLabel.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	richLabel.fit_content = true
	richLabel.scroll_active = false
	richLabel.autowrap_mode = TextServer.AUTOWRAP_OFF

	richLabel.anchor_left   = 0.5
	richLabel.anchor_right  = 0.5
	richLabel.anchor_top    = 1.0
	richLabel.anchor_bottom = 1.0
	richLabel.offset_left   = -420.0
	richLabel.offset_right  = 420.0
	richLabel.offset_top    = -80.0
	richLabel.offset_bottom = -20.0
	richLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	tutorialLayer.add_child(richLabel)

	# Guardar referencia para parpadeo
	tutorialLabel = richLabel

	# Parpadeo suave
	_blinkLabel(tutorialLabel)

func _blinkLabel(label: Node):
	while is_instance_valid(label):
		var t = create_tween()
		t.tween_property(label, "modulate:a", 0.2, 0.6)
		t.tween_property(label, "modulate:a", 1.0, 0.6)
		await t.finished

# ─── Símbolo "!" sobre el pozo (en CanvasLayer para que no se mueva con la cámara) ──

func _showPozoExclamation():
	# Usamos un CanvasLayer para que el "!" aparezca en coordenadas de pantalla
	# y no se desplace si hay cámara activa
	pozoLabelLayer = CanvasLayer.new()
	pozoLabelLayer.layer = 4
	add_child(pozoLabelLayer)

	pozoLabel = Label.new()
	pozoLabel.text = "!"
	pozoLabel.add_theme_font_size_override("font_size", 64)
	pozoLabel.add_theme_color_override("font_color", Color(1, 0, 0, 1))
	pozoLabel.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	pozoLabel.add_theme_constant_override("shadow_offset_x", 3)
	pozoLabel.add_theme_constant_override("shadow_offset_y", 3)

	pozoLabelLayer.add_child(pozoLabel)

	# Posicionar el label convirtiendo las coordenadas del mundo a pantalla
	_updatePozoLabelPosition()

	# Animación de flotación
	_floatLabel(pozoLabel)

func _updatePozoLabelPosition():
	if not is_instance_valid(pozoLabel):
		return
	var camera = get_viewport().get_camera_2d()
	var screenPos: Vector2
	if camera:
		screenPos = get_viewport().get_canvas_transform() * POZO_POS
	else:
		screenPos = POZO_POS
	pozoLabel.position = screenPos + Vector2(-16, -120)

func _floatLabel(label: Label):
	var baseOffset := Vector2(-16, -120)
	while is_instance_valid(label):
		_updatePozoLabelPosition()
		var camera = get_viewport().get_camera_2d()
		var screenPos: Vector2
		if camera:
			screenPos = get_viewport().get_canvas_transform() * POZO_POS
		else:
			screenPos = POZO_POS
		var baseY = screenPos.y + baseOffset.y
		var t = create_tween()
		t.tween_property(label, "position:y", baseY - 12.0, 0.5).set_trans(Tween.TRANS_SINE)
		t.tween_property(label, "position:y", baseY, 0.5).set_trans(Tween.TRANS_SINE)
		await t.finished

# ─── Detección de interacción con el pozo ─────────────────────────────────────

func _process(_delta):
	if wellInteracted:
		return

	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	# Verificar si el jugador está cerca del pozo
	var dist = player.global_position.distance_to(POZO_POS)
	pozoNearby = dist < INTERACT_RADIUS

	# Actualizar posición del "!" si hay cámara que se mueve
	if pozoNearby and is_instance_valid(pozoLabel):
		_updatePozoLabelPosition()

func _unhandled_input(event):
	if wellInteracted:
		return
	if not pozoNearby:
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	# Aceptar KEY_E directamente O el action "interact" (si está mapeado)
	if event.keycode == KEY_E or event.physical_keycode == KEY_E or event.is_action("interact"):
		get_viewport().set_input_as_handled()
		_onWellInteract()

func _onWellInteract():
	wellInteracted = true

	# Ocultar UI de tutorial y "!"
	if is_instance_valid(pozoLabel):
		pozoLabel.queue_free()
	if is_instance_valid(pozoLabelLayer):
		pozoLabelLayer.queue_free()
	if is_instance_valid(tutorialLabel):
		tutorialLabel.queue_free()
	if is_instance_valid(tutorialLayer):
		tutorialLayer.queue_free()

	# Bloquear al jugador
	_blockPlayer()

	# Fade a negro y cambiar a Main
	$FadeLayer.visible = true
	var tween = create_tween()
	tween.tween_property(fadeRect, "color", Color(0, 0, 0, 1), 1.0)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
	)

# ─── Utilidades ───────────────────────────────────────────────────────────────

func _findAnimatedSprite(node: Node) -> AnimatedSprite2D:
	if node is AnimatedSprite2D:
		return node
	for child in node.get_children():
		var result = _findAnimatedSprite(child)
		if result:
			return result
	return null
