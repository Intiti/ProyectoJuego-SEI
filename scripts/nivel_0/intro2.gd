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

const WorldPromptScript = preload("res://scripts/common/ui/worldPrompt.gd")
const TutorialHintScript = preload("res://scripts/common/ui/tutorialHint.gd")
const ScoreHudScript = preload("res://scripts/common/ui/scoreHud.gd")
const FaderScript = preload("res://scripts/common/ui/sceneFader.gd")
const PozoSecuenciaScript = preload("res://scripts/nivel_0/pozoSecuencia.gd")

# Dónde flota el indicador respecto al centro del pozo
const POZO_PROMPT_OFFSET := Vector2(0, -80)

var pozoPrompt: Node2D = null
var hint = null
var pozoNearby: bool = false
var wellInteracted: bool = false

func _ready():
	_applyGlobalTheme()
	fadeRect.color = Color(0, 0, 0, 1)
	$FadeLayer.visible = true
	_blockPlayer()
	add_child(ScoreHudScript.new())
	dialogBox.cinematicDialogFinished.connect(_onDialogFinished)
	_fadeIn()

func _applyGlobalTheme() -> void:
	var font = load("res://assets/fonts/MotionControl-Bold.otf")
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
	dialogBox.openDirect(pankoDialogLines, "res://scenes/common/actors/Player.tscn", "res://scenes/common/actors/CAT.tscn")

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
	_showPozoPrompt()

# ─── Tutorial de interacción ─────────────────────────────────────────────────
# Dos mensajes según la distancia, para que quede claro QUÉ hacer y CUÁNDO:
#   lejos  → "Acércate al pozo (!)"
#   cerca  → "Pulsa [E] para interactuar"

func _farHintText() -> String:
	return "Acércate al pozo  (%s)" % TutorialHintScript.bang()

func _nearHintText() -> String:
	return "Pulsa  %s  para interactuar" % TutorialHintScript.key("E")

func _showTutorialHint():
	hint = TutorialHintScript.new()
	hint.setup(_farHintText())
	add_child(hint)

# ─── Indicador sobre el pozo: "!" de lejos, tecla [E] de cerca ────────────────

func _showPozoPrompt():
	pozoPrompt = WorldPromptScript.new()
	pozoPrompt.setup(WorldPromptScript.Marker.EXCLAIM, "Interactuar")
	pozoPrompt.position = POZO_POS + POZO_PROMPT_OFFSET
	add_child(pozoPrompt)

# ─── Detección de interacción con el pozo ─────────────────────────────────────

func _process(_delta):
	if wellInteracted:
		return

	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	# Verificar si el jugador está cerca del pozo
	var dist = player.global_position.distance_to(POZO_POS)
	var nowNearby = dist < INTERACT_RADIUS
	if nowNearby != pozoNearby:
		pozoNearby = nowNearby
		if is_instance_valid(pozoPrompt):
			pozoPrompt.setNear(pozoNearby)
		if is_instance_valid(hint):
			hint.setText(_nearHintText() if pozoNearby else _farHintText())

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

	# Ocultar UI de tutorial e indicador
	if is_instance_valid(pozoPrompt):
		pozoPrompt.queue_free()
	if is_instance_valid(hint):
		hint.dismiss()

	# Bloquear al jugador
	_blockPlayer()

	var player = get_tree().get_first_node_in_group("player")
	if player:
		var sequence = PozoSecuenciaScript.new()
		add_child(sequence)
		await sequence.play(player)

	FaderScript.coverNow(self)
	get_tree().change_scene_to_file("res://scenes/nivel_1/Main.tscn")

# ─── Utilidades ───────────────────────────────────────────────────────────────

func _findAnimatedSprite(node: Node) -> AnimatedSprite2D:
	if node is AnimatedSprite2D:
		return node
	for child in node.get_children():
		var result = _findAnimatedSprite(child)
		if result:
			return result
	return null
