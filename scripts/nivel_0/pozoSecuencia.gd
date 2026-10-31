extends Node

const EFFECT_SHADER_PATH := "res://assets/shaders/psicodelico.gdshader"
const DREAM_SHADER_PATH := "res://assets/shaders/suenoFondo.gdshader"
const DREAM_BACKGROUND_PATH := ""
const JUMP_ANIMATION := &"jump"
const DREAM_LAYER := 3
const EFFECT_LAYER := 5

const DISTORT_TIME := 2.0
const DISTORT_INTENSITY := 1.2
const SWIRL_TWIST := 6.0
const BLACKOUT_DELAY := 0.8
const FADE_IN_TIME := 1.0
const COLOR_IN_TIME := 1.8
const FLOAT_TIME := 2.5
const DESCENT_TIME := 2.6
const EXIT_HOLD_TIME := 0.3
const FADE_OUT_TIME := 0.8

const DREAM_PLAYER_X := 576.0
const OFF_SCREEN_MARGIN := 40.0
const FLOAT_Y := 350.0
const BOB_AMPLITUDE := 16.0
const BOB_SPEED := 2.0
const INTENSITY_DREAM := 0.45
const INTENSITY_FALL := 0.2

var bobAmount: float = 1.0
var dreamBaseY: float = FLOAT_Y

var _player: Node2D = null
var _realSprite: AnimatedSprite2D = null
var _dreamPlayer: Node2D = null
var _dreamSprite: AnimatedSprite2D = null
var _material: ShaderMaterial = null
var _viewportSize := Vector2(1152, 648)
var _elapsed: float = 0.0
var _offScreenY: float = 0.0

func play(player: Node2D) -> void:
	_player = player
	_realSprite = player.get_node_or_null("Sprite2D") as AnimatedSprite2D
	if _realSprite == null:
		return
	_viewportSize = get_viewport().get_visible_rect().size
	_buildEffectLayer()
	_setColorAmount(0.0)

	var distort := create_tween().set_parallel(true)
	distort.tween_method(_setIntensity, 0.0, DISTORT_INTENSITY, DISTORT_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	distort.tween_method(_setSwirl, 0.0, SWIRL_TWIST, DISTORT_TIME)
	distort.tween_method(_setFade, 0.0, 1.0, DISTORT_TIME - BLACKOUT_DELAY).set_delay(BLACKOUT_DELAY)
	await distort.finished

	_player.visible = false
	_buildDreamStage()
	_setSwirl(0.0)
	_setIntensity(INTENSITY_DREAM)

	var reveal := create_tween().set_parallel(true)
	reveal.tween_method(_setFade, 1.0, 0.0, FADE_IN_TIME)
	reveal.tween_method(_setColorAmount, 0.0, 1.0, COLOR_IN_TIME)
	await reveal.finished

	await get_tree().create_timer(FLOAT_TIME).timeout

	var descent := create_tween().set_parallel(true)
	descent.tween_property(self, "dreamBaseY", _offScreenY, DESCENT_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	descent.tween_property(self, "bobAmount", 0.0, DESCENT_TIME * 0.3)
	descent.tween_method(_setIntensity, INTENSITY_DREAM, INTENSITY_FALL, DESCENT_TIME)
	await descent.finished

	await get_tree().create_timer(EXIT_HOLD_TIME).timeout

	var leave := create_tween()
	leave.tween_method(_setFade, 0.0, 1.0, FADE_OUT_TIME)
	await leave.finished

func _process(delta: float) -> void:
	_elapsed += delta
	var focus: Node2D = null
	if _dreamPlayer != null:
		var bob: float = sin(_elapsed * BOB_SPEED) * BOB_AMPLITUDE * bobAmount
		_dreamPlayer.position = Vector2(DREAM_PLAYER_X, dreamBaseY + bob)
		focus = _dreamSprite
	elif _realSprite != null:
		focus = _realSprite
	if focus != null and _material != null:
		_material.set_shader_parameter("center", focus.global_position / _viewportSize)

func _buildEffectLayer() -> void:
	var layer := CanvasLayer.new()
	layer.layer = EFFECT_LAYER
	add_child(layer)
	var rect := ColorRect.new()
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_material = ShaderMaterial.new()
	_material.shader = load(EFFECT_SHADER_PATH)
	_material.set_shader_parameter("aspect", _viewportSize.x / _viewportSize.y)
	rect.material = _material
	layer.add_child(rect)
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _buildDreamStage() -> void:
	var layer := CanvasLayer.new()
	layer.layer = DREAM_LAYER
	add_child(layer)

	var background := _makeDreamBackground()
	layer.add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_dreamPlayer = Node2D.new()
	_dreamPlayer.position = Vector2(DREAM_PLAYER_X, FLOAT_Y)
	_dreamSprite = AnimatedSprite2D.new()
	_dreamSprite.sprite_frames = _realSprite.sprite_frames
	_dreamSprite.position = _realSprite.position
	_dreamSprite.scale = _realSprite.scale
	_dreamPlayer.add_child(_dreamSprite)
	layer.add_child(_dreamPlayer)

	var frames := _dreamSprite.sprite_frames
	if frames != null and frames.has_animation(JUMP_ANIMATION):
		_dreamSprite.animation = JUMP_ANIMATION
		_dreamSprite.frame = frames.get_frame_count(JUMP_ANIMATION) - 1
		_dreamSprite.pause()
	_offScreenY = _computeOffScreenY()

func _computeOffScreenY() -> float:
	var halfHeight: float = 240.0
	var frames := _dreamSprite.sprite_frames
	if frames != null and frames.has_animation(JUMP_ANIMATION):
		var texture := frames.get_frame_texture(JUMP_ANIMATION, frames.get_frame_count(JUMP_ANIMATION) - 1)
		if texture != null:
			halfHeight = texture.get_height() * absf(_dreamSprite.scale.y) * 0.5
	return _viewportSize.y + halfHeight + absf(_dreamSprite.position.y) + OFF_SCREEN_MARGIN

func _makeDreamBackground() -> Control:
	var background: Control
	if DREAM_BACKGROUND_PATH != "" and ResourceLoader.exists(DREAM_BACKGROUND_PATH):
		var textureRect := TextureRect.new()
		textureRect.texture = load(DREAM_BACKGROUND_PATH)
		textureRect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		textureRect.stretch_mode = TextureRect.STRETCH_SCALE
		background = textureRect
	else:
		var rect := ColorRect.new()
		var material := ShaderMaterial.new()
		material.shader = load(DREAM_SHADER_PATH)
		rect.material = material
		background = rect
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return background

func _setIntensity(value: float) -> void:
	if _material != null:
		_material.set_shader_parameter("intensity", value)

func _setSwirl(value: float) -> void:
	if _material != null:
		_material.set_shader_parameter("swirl", value)

func _setFade(value: float) -> void:
	if _material != null:
		_material.set_shader_parameter("fade", value)

func _setColorAmount(value: float) -> void:
	if _material != null:
		_material.set_shader_parameter("colorAmount", value)
