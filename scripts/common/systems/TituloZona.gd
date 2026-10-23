extends Node

const FONT_PATH := "res://assets/fonts/MotionControl-Bold.otf"
const LAYER := 90
const SKIP_DELAY := 0.8
const START_DELAY := 0.25
const LETTER_STAGGER := 0.04
const LETTER_APPEAR := 0.5
const HOLD_TIME := 1.3
const FADE_OUT := 0.55
const BACKDROP_FADE := 0.35
const MAX_TEXT_WIDTH := 1000.0
const BASE_FONT_SIZE := 80
const MIN_FONT_SIZE := 34
const BAND_HEIGHT := 250.0

const LEVELS := {
	1: {"theme": "village"},
	2: {"theme": "forest"},
	3: {"theme": "lab"},
}

const THEMES := {
	"village": {"fill": "#FFE9A8", "outline": "#7A4B1E", "accent": "#F2B84B", "band": "#4A2C12", "anim": "bounce", "particles": "motas", "glow": false},
	"forest": {"fill": "#C8F2A8", "outline": "#1F4D2B", "accent": "#7DDB78", "band": "#0E2A18", "anim": "rise", "particles": "luciernagas", "glow": true},
	"lab": {"fill": "#D8FBFF", "outline": "#0B4A66", "accent": "#38D6FF", "band": "#061826", "anim": "flicker", "particles": "chispas", "glow": true},
}

const PARTICLES := {
	"motas": {"amount": 28, "dir": Vector2(0, -1), "spread": 25.0, "speedMin": 8.0, "speedMax": 22.0, "scaleMin": 2.0, "scaleMax": 4.0, "life": 4.0},
	"luciernagas": {"amount": 34, "dir": Vector2(0, -1), "spread": 180.0, "speedMin": 6.0, "speedMax": 22.0, "scaleMin": 2.0, "scaleMax": 5.0, "life": 3.5},
	"esporas": {"amount": 30, "dir": Vector2(0, -1), "spread": 20.0, "speedMin": 12.0, "speedMax": 30.0, "scaleMin": 2.0, "scaleMax": 4.0, "life": 3.5},
	"nieve": {"amount": 40, "dir": Vector2(0, 1), "spread": 15.0, "speedMin": 18.0, "speedMax": 40.0, "scaleMin": 2.0, "scaleMax": 4.0, "life": 5.0},
	"chispas": {"amount": 40, "dir": Vector2(0, -1), "spread": 180.0, "speedMin": 30.0, "speedMax": 110.0, "scaleMin": 1.5, "scaleMax": 3.0, "life": 1.6},
	"cascada": {"amount": 36, "dir": Vector2(0, 1), "spread": 3.0, "speedMin": 140.0, "speedMax": 260.0, "scaleMin": 1.5, "scaleMax": 2.5, "life": 1.4},
	"viento": {"amount": 30, "dir": Vector2(1, 0), "spread": 6.0, "speedMin": 160.0, "speedMax": 320.0, "scaleMin": 1.5, "scaleMax": 3.0, "life": 2.5},
	"polvo": {"amount": 24, "dir": Vector2(0, 1), "spread": 30.0, "speedMin": 6.0, "speedMax": 16.0, "scaleMin": 2.0, "scaleMax": 3.0, "life": 5.0},
}

var _font: Font = null
var _layer: CanvasLayer = null
var _root: Control = null
var _dim: ColorRect = null
var _band: ColorRect = null
var _lineTop: ColorRect = null
var _lineBottom: ColorRect = null
var _kicker: Label = null
var _letters: Array = []
var _anim: String = "bounce"
var _t: float = 0.0
var _appearEnd: float = 0.0
var _fadeStart: float = 0.0
var _player: Node = null
var _playerWasProcessing: bool = false
var _shown: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(false)
	if ResourceLoader.exists(FONT_PATH):
		_font = load(FONT_PATH)
	else:
		_font = ThemeDB.fallback_font
	get_tree().scene_changed.connect(_onSceneChanged)

func _onSceneChanged() -> void:
	_dismiss()
	var scene := get_tree().current_scene
	if scene == null:
		return
	var path: String = scene.scene_file_path
	var lower := path.to_lower()
	if lower.ends_with("mainmenu.tscn"):
		_shown.clear()
		return
	if lower.ends_with("/nivel_3/final.tscn"):
		_shown.erase(3)
		return
	var level := _resolveLevel(lower)
	if level == 0 or _shown.has(level):
		return
	_shown[level] = true
	_showCard(level)

func _resolveLevel(lowerPath: String) -> int:
	var dir := lowerPath.get_base_dir()
	if dir.ends_with("/scenes/nivel_1"):
		return 1
	var level := 0
	if dir.ends_with("/scenes/nivel_2"):
		level = 2
	elif dir.ends_with("/scenes/nivel_3"):
		level = 3
	else:
		return 0
	var first := lowerPath.get_file().substr(0, 1)
	if not first.is_valid_int():
		return 0
	return level

func _showCard(level: int) -> void:
	var theme: Dictionary = THEMES[LEVELS[level]["theme"]]
	var vp: Vector2 = get_viewport().get_visible_rect().size
	var fill := Color(theme["fill"])
	var outline := Color(theme["outline"])
	var accent := Color(theme["accent"])
	var bandColor := Color(theme["band"])
	_anim = theme["anim"]

	_layer = CanvasLayer.new()
	_layer.layer = LAYER
	add_child(_layer)

	_root = Control.new()
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_root)
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_dim = ColorRect.new()
	_dim.color = Color(bandColor, 0.62)
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dim.modulate.a = 0.0
	_root.add_child(_dim)
	_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var cy := vp.y * 0.5
	_band = ColorRect.new()
	_band.color = Color(bandColor, 0.85)
	_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_band.position = Vector2(0, cy - BAND_HEIGHT * 0.5)
	_band.size = Vector2(vp.x, BAND_HEIGHT)
	_band.modulate.a = 0.0
	_root.add_child(_band)

	var lineWidth := vp.x * 0.62
	_lineTop = _makeLine(accent, lineWidth, Vector2((vp.x - lineWidth) * 0.5, cy - BAND_HEIGHT * 0.5 + 8.0))
	_lineBottom = _makeLine(accent, lineWidth, Vector2((vp.x - lineWidth) * 0.5, cy + BAND_HEIGHT * 0.5 - 12.0))

	_addParticles(String(theme["particles"]), accent, vp)

	_kicker = _makeText("NIVEL %d" % level, 28, accent, outline, vp.x, cy - 96.0)
	_kicker.modulate.a = 0.0

	_buildLetters(GameData.levelName(level), fill, outline, accent, bool(theme["glow"]), vp, cy)

	_t = 0.0
	_appearEnd = START_DELAY + float(maxi(_letters.size() - 1, 0)) * LETTER_STAGGER + LETTER_APPEAR + 0.15
	_fadeStart = _appearEnd + HOLD_TIME
	_freezePlayer()
	set_process(true)
	_process(0.0)

func _makeLine(color: Color, width: float, pos: Vector2) -> ColorRect:
	var line := ColorRect.new()
	line.color = color
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.position = pos
	line.size = Vector2(width, 3.0)
	line.pivot_offset = Vector2(width * 0.5, 1.5)
	line.scale.x = 0.0
	_root.add_child(line)
	return line

func _makeText(text: String, fontSize: int, color: Color, outline: Color, width: float, y: float) -> Label:
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", _font)
	label.add_theme_font_size_override("font_size", fontSize)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", outline)
	label.add_theme_constant_override("outline_size", 6)
	label.position = Vector2(0, y)
	label.size = Vector2(width, fontSize * 1.3)
	_root.add_child(label)
	return label

func _buildLetters(title: String, fill: Color, outline: Color, accent: Color, glow: bool, vp: Vector2, cy: float) -> void:
	_letters.clear()
	var fontSize := BASE_FONT_SIZE
	while fontSize > MIN_FONT_SIZE and _font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, fontSize).x > MAX_TEXT_WIDTH:
		fontSize -= 2
	var widths: Array[float] = []
	var total := 0.0
	for ch in title:
		var w := _font.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT, -1, fontSize).x
		widths.append(w)
		total += w
	var height := _font.get_height(fontSize)
	var x := (vp.x - total) * 0.5
	var y := cy - height * 0.5 - 4.0
	var visibleIndex := 0
	for i in title.length():
		var ch := title[i]
		if ch != " ":
			var label := Label.new()
			label.text = ch
			label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			label.add_theme_font_override("font", _font)
			label.add_theme_font_size_override("font_size", fontSize)
			label.add_theme_color_override("font_color", fill)
			label.add_theme_color_override("font_outline_color", outline)
			label.add_theme_constant_override("outline_size", maxi(6, int(fontSize * 0.18)))
			if glow:
				label.add_theme_color_override("font_shadow_color", Color(accent, 0.38))
				label.add_theme_constant_override("shadow_offset_x", 0)
				label.add_theme_constant_override("shadow_offset_y", 0)
				label.add_theme_constant_override("shadow_outline_size", int(fontSize * 0.55))
			else:
				label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.55))
				label.add_theme_constant_override("shadow_offset_x", 0)
				label.add_theme_constant_override("shadow_offset_y", 5)
			label.position = Vector2(x, y)
			label.pivot_offset = Vector2(widths[i] * 0.5, height * 0.5)
			label.modulate.a = 0.0
			_root.add_child(label)
			_letters.append({
				"label": label,
				"base": Vector2(x, y),
				"delay": START_DELAY + float(visibleIndex) * LETTER_STAGGER,
				"index": visibleIndex,
				"tilt": (_noise(visibleIndex, 3) - 0.5) * 0.12,
			})
			visibleIndex += 1
		x += widths[i]

func _addParticles(kind: String, color: Color, vp: Vector2) -> void:
	if not PARTICLES.has(kind):
		return
	var preset: Dictionary = PARTICLES[kind]
	var particles := CPUParticles2D.new()
	particles.amount = int(preset["amount"])
	particles.lifetime = float(preset["life"])
	particles.preprocess = float(preset["life"])
	particles.position = vp * 0.5
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = vp * 0.5
	particles.direction = preset["dir"]
	particles.spread = float(preset["spread"])
	particles.initial_velocity_min = float(preset["speedMin"])
	particles.initial_velocity_max = float(preset["speedMax"])
	particles.gravity = Vector2.ZERO
	particles.scale_amount_min = float(preset["scaleMin"]) * 2.5
	particles.scale_amount_max = float(preset["scaleMax"]) * 2.5
	var ramp := Gradient.new()
	ramp.set_color(0, Color(color, 0.0))
	ramp.set_color(1, Color(color, 0.0))
	ramp.add_point(0.5, Color(color, 0.85))
	particles.color_ramp = ramp
	particles.emitting = true
	_layer.add_child(particles)

func _freezePlayer() -> void:
	_player = get_tree().get_first_node_in_group("player")
	if _player == null:
		return
	_playerWasProcessing = _player.is_physics_processing()
	_player.set_physics_process(false)
	if _player is CharacterBody2D:
		_player.velocity = Vector2.ZERO

func _releasePlayer() -> void:
	if _player != null and is_instance_valid(_player) and _playerWasProcessing:
		_player.set_physics_process(true)
	_player = null
	_playerWasProcessing = false

func _dismiss() -> void:
	set_process(false)
	_letters.clear()
	if _layer != null and is_instance_valid(_layer):
		_layer.queue_free()
	_layer = null
	_root = null
	_releasePlayer()

func _unhandled_input(event: InputEvent) -> void:
	if _layer == null or _t < SKIP_DELAY or _t >= _fadeStart:
		return
	var pressed: bool = false
	if event is InputEventKey:
		pressed = event.pressed and not event.echo
	elif event is InputEventMouseButton:
		pressed = event.pressed
	if pressed:
		_fadeStart = _t
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	if _layer == null:
		return
	_t += delta
	var backdrop := clampf(_t / BACKDROP_FADE, 0.0, 1.0)
	_dim.modulate.a = backdrop
	_band.modulate.a = backdrop
	var lineProgress := _easeOutCubic(clampf((_t - 0.1) / 0.5, 0.0, 1.0))
	_lineTop.scale.x = lineProgress
	_lineBottom.scale.x = lineProgress
	_kicker.modulate.a = clampf((_t - 0.2) / 0.4, 0.0, 1.0)
	for letter in _letters:
		_animateLetter(letter)
	var fade := clampf((_t - _fadeStart) / FADE_OUT, 0.0, 1.0)
	_root.modulate.a = 1.0 - fade
	if fade >= 1.0:
		_dismiss()

func _animateLetter(letter: Dictionary) -> void:
	var label: Label = letter["label"]
	var local: float = _t - float(letter["delay"])
	var index: int = letter["index"]
	var p := clampf(local / LETTER_APPEAR, 0.0, 1.0)
	var alpha := p
	var offset := Vector2.ZERO
	match _anim:
		"bounce":
			offset.y = (1.0 - _easeOutBack(p)) * -80.0
		"rise":
			offset.y = (1.0 - _easeOutCubic(p)) * 36.0
			if p >= 1.0:
				offset.y += sin(_t * 2.0 + float(index) * 0.55) * 3.5
		"wind":
			offset.x = (1.0 - _easeOutCubic(p)) * -90.0
			if p >= 1.0:
				offset.x += sin(_t * 1.6 + float(index) * 0.45) * 5.0
				offset.y += cos(_t * 1.3 + float(index) * 0.45) * 2.0
		"flicker":
			if local < 0.0:
				alpha = 0.0
			elif local > 0.45:
				alpha = 1.0
				if _noise(index + 17, int(_t * 9.0)) > 0.965:
					alpha = 0.5
			else:
				alpha = 1.0 if _noise(index, int(local * 24.0)) > 0.45 else 0.15
		"glitch":
			if local < 0.0:
				alpha = 0.0
			elif local > 0.45:
				alpha = 1.0
				if _noise(index + 5, int(_t * 10.0)) > 0.94:
					offset.x = (_noise(index + 9, int(_t * 10.0)) - 0.5) * 18.0
					alpha = 0.75
			else:
				alpha = 1.0 if _noise(index, int(local * 24.0)) > 0.4 else 0.1
				offset.x = (_noise(index + 3, int(local * 24.0)) - 0.5) * 14.0
		"chalk":
			label.rotation = float(letter["tilt"])
			offset.y = (1.0 - _easeOutCubic(p)) * 10.0
	label.position = Vector2(letter["base"]) + offset
	label.modulate.a = alpha

func _noise(a: int, b: int) -> float:
	var v := sin(float(a) * 12.9898 + float(b) * 78.233) * 43758.5453
	return v - floorf(v)

func _easeOutCubic(x: float) -> float:
	return 1.0 - pow(1.0 - x, 3.0)

func _easeOutBack(x: float) -> float:
	var c1 := 1.70158
	var c3 := c1 + 1.0
	return 1.0 + c3 * pow(x - 1.0, 3.0) + c1 * pow(x - 1.0, 2.0)
