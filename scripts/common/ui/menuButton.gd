extends Button

const CREAM := Color(0.98, 0.93, 0.80)
const DARK := Color(0.04, 0.09, 0.07)
const PINK := Color(1.0, 0.60, 0.72)
const GOLD := Color(1.0, 0.90, 0.55)
const FILL := Color(0.05, 0.16, 0.12, 0.88)
const BORDER_IDLE := Color(0.98, 0.93, 0.80, 0.55)
const PARTICLE_COLORS := [PINK, CREAM, GOLD]

const CORNER := 14
const BORDER := 4
const SHADOW_OFFSET := 5.0
const EAR_HEIGHT := 18.0
const HOVER_SCALE := 1.07
const PRESS_SCALE := Vector2(0.93, 0.88)
const APPEAR_TIME := 0.55
const BURST_COUNT := 16
const GRAVITY := 520.0
const SOUND_ENABLED := true

@export var appearDelay: float = 0.0

var timeAcc: float = 0.0
var appearClock: float = 0.0
var hoverAmount: float = 0.0
var scaleCur := Vector2.ONE
var scaleVel := Vector2.ZERO
var rotCur: float = 0.0
var rotVel: float = 0.0
var earCur: float = 0.0
var earVel: float = 0.0
var wiggleSide: float = 1.0
var wasActive: bool = false
var idlePhase: float = 0.0
var particles: Array = []
var bodyStyle := StyleBoxFlat.new()
var shadowStyle := StyleBoxFlat.new()

func _ready() -> void:
	idlePhase = randf() * TAU
	_hideNativeLook()
	_setupStyles()
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	button_down.connect(_onButtonDown)
	pressed.connect(_onPressed)

func _hideNativeLook() -> void:
	var empty := StyleBoxEmpty.new()
	for styleName in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
		add_theme_stylebox_override(styleName, empty)
	var clear := Color(0, 0, 0, 0)
	for colorName in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color", "font_disabled_color", "font_outline_color"]:
		add_theme_color_override(colorName, clear)

func _setupStyles() -> void:
	bodyStyle.set_corner_radius_all(CORNER)
	bodyStyle.set_border_width_all(BORDER)
	bodyStyle.anti_aliasing = true
	shadowStyle.set_corner_radius_all(CORNER)
	shadowStyle.anti_aliasing = true

func replayAppear(delay: float = 0.0) -> void:
	appearClock = 0.0
	appearDelay = delay
	scaleCur = Vector2.ONE
	scaleVel = Vector2.ZERO
	rotCur = 0.0
	rotVel = 0.0
	earCur = 0.0
	earVel = 0.0
	hoverAmount = 0.0
	particles.clear()
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _appearProgress() -> float:
	return clampf((appearClock - appearDelay) / APPEAR_TIME, 0.0, 1.0)

func _backOut(p: float) -> float:
	var c1: float = 1.70158
	var c3: float = c1 + 1.0
	return 1.0 + c3 * pow(p - 1.0, 3.0) + c1 * pow(p - 1.0, 2.0)

func _spring(cur: float, vel: float, target: float, stiffness: float, damping: float, dt: float) -> Vector2:
	var newVel: float = vel + ((target - cur) * stiffness - vel * damping) * dt
	return Vector2(cur + newVel * dt, newVel)

func _playTick(pitch: float) -> void:
	if SOUND_ENABLED:
		DJManager.playDialogBleepPitched(pitch)

func _process(delta: float) -> void:
	var dt: float = minf(delta, 0.033)
	timeAcc += dt
	appearClock += dt
	var appeared: bool = _appearProgress() >= 0.7
	var wantedFilter: int = Control.MOUSE_FILTER_STOP if appeared else Control.MOUSE_FILTER_IGNORE
	if mouse_filter != wantedFilter:
		mouse_filter = wantedFilter
	var active: bool = appeared and (is_hovered() or has_focus())
	if active and not wasActive:
		_onHoverEnter()
	wasActive = active
	hoverAmount = lerpf(hoverAmount, 1.0 if active else 0.0, minf(dt * 14.0, 1.0))
	var mode: int = get_draw_mode()
	var held: bool = mode == DRAW_PRESSED or mode == DRAW_HOVER_PRESSED
	var scaleTarget: Vector2 = Vector2.ONE * (1.0 + (HOVER_SCALE - 1.0) * hoverAmount)
	if held:
		scaleTarget = PRESS_SCALE
	var sx: Vector2 = _spring(scaleCur.x, scaleVel.x, scaleTarget.x, 340.0, 15.0, dt)
	var sy: Vector2 = _spring(scaleCur.y, scaleVel.y, scaleTarget.y, 340.0, 15.0, dt)
	scaleCur = Vector2(sx.x, sy.x)
	scaleVel = Vector2(sx.y, sy.y)
	var r: Vector2 = _spring(rotCur, rotVel, 0.0, 260.0, 9.0, dt)
	rotCur = r.x
	rotVel = r.y
	var e: Vector2 = _spring(earCur, earVel, 1.0 if active else 0.0, 380.0, 14.0, dt)
	earCur = e.x
	earVel = e.y
	_updateParticles(dt)
	queue_redraw()

func _onHoverEnter() -> void:
	scaleVel += Vector2(0.5, 1.1)
	rotVel += 2.2 * wiggleSide
	wiggleSide = -wiggleSide
	earVel += 5.0
	_burst(Vector2(size.x * 0.5, 0.0), 5, 40.0, 110.0, 80.0)
	_playTick(1.5)

func _onButtonDown() -> void:
	_playTick(0.7)

func _onPressed() -> void:
	scaleVel += Vector2(1.0, 1.4)
	_burst(size * 0.5, BURST_COUNT, 140.0, 300.0, 120.0)
	if not Input.is_action_pressed("ui_accept"):
		release_focus()

func _burst(origin: Vector2, count: int, speedMin: float, speedMax: float, upBias: float) -> void:
	for k in count:
		var ang: float = randf() * TAU
		var spd: float = randf_range(speedMin, speedMax)
		var life: float = randf_range(0.45, 0.85)
		particles.append({
			"pos": origin,
			"vel": Vector2(cos(ang), sin(ang)) * spd + Vector2(0.0, -upBias),
			"life": life,
			"maxLife": life,
			"size": randf_range(2.5, 5.0),
			"kind": randi() % 2,
			"angle": randf() * TAU,
			"spin": randf_range(-6.0, 6.0),
			"color": PARTICLE_COLORS[randi() % PARTICLE_COLORS.size()]
		})

func _updateParticles(dt: float) -> void:
	var i: int = particles.size() - 1
	while i >= 0:
		var p: Dictionary = particles[i]
		p.life = float(p.life) - dt
		if float(p.life) <= 0.0:
			particles.remove_at(i)
		else:
			var v: Vector2 = p.vel
			v.y += GRAVITY * dt
			v *= maxf(1.0 - 1.5 * dt, 0.0)
			p.vel = v
			p.pos = Vector2(p.pos) + v * dt
			p.angle = float(p.angle) + float(p.spin) * dt
		i -= 1

func _draw() -> void:
	var appearP: float = _appearProgress()
	if appearP > 0.0:
		var alpha: float = clampf(appearP * 2.0, 0.0, 1.0)
		var appearV: float = _backOut(appearP)
		var half: Vector2 = size * 0.5
		var bob: float = sin(timeAcc * 2.0 + idlePhase) * 1.5 * appearP
		var center: Vector2 = half + Vector2(0.0, bob - hoverAmount * 4.0 + (1.0 - appearV) * 36.0)
		var rect := Rect2(-half, size)
		draw_set_transform(center, rotCur, scaleCur * lerpf(0.55, 1.0, appearV))
		_drawShadow(rect, alpha)
		_drawEars(rect, alpha)
		_drawBody(rect, alpha)
		_drawLabel(rect, alpha)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_drawParticles()

func _drawShadow(rect: Rect2, alpha: float) -> void:
	shadowStyle.bg_color = Color(0, 0, 0, 0.4 * alpha)
	var shadowRect := Rect2(rect.position + Vector2(0.0, SHADOW_OFFSET + hoverAmount * 3.0), rect.size)
	draw_style_box(shadowStyle, shadowRect)

func _drawBody(rect: Rect2, alpha: float) -> void:
	var fill: Color = FILL.lerp(CREAM, hoverAmount)
	fill.a = lerpf(FILL.a, 1.0, hoverAmount) * alpha
	var border: Color = BORDER_IDLE.lerp(DARK, hoverAmount)
	border.a *= alpha
	bodyStyle.bg_color = fill
	bodyStyle.border_color = border
	draw_style_box(bodyStyle, rect)

func _drawLabel(rect: Rect2, alpha: float) -> void:
	var font: Font = get_theme_font("font")
	var fontSize: int = get_theme_font_size("font_size")
	var textSize: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fontSize)
	var baseline: float = rect.position.y + (rect.size.y + font.get_ascent(fontSize) - font.get_descent(fontSize)) * 0.5
	var pos := Vector2(rect.position.x + (rect.size.x - textSize.x) * 0.5, baseline)
	var shadowAlpha: float = 0.35 * (1.0 - hoverAmount) * alpha
	draw_string(font, pos + Vector2(0.0, 2.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fontSize, Color(0, 0, 0, shadowAlpha))
	var col: Color = CREAM.lerp(DARK, hoverAmount)
	col.a *= alpha
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fontSize, col)

func _drawEars(rect: Rect2, alpha: float) -> void:
	if earCur < 0.02:
		return
	var h: float = EAR_HEIGHT * earCur
	var top: float = rect.position.y + 6.0
	var leftX: float = rect.position.x
	var rightX: float = rect.end.x
	_drawEar(Vector2(leftX + 12.0, top), Vector2(leftX + 44.0, top), Vector2(leftX + 16.0, top - h - 6.0), alpha)
	_drawEar(Vector2(rightX - 44.0, top), Vector2(rightX - 12.0, top), Vector2(rightX - 16.0, top - h - 6.0), alpha)

func _drawEar(b1: Vector2, b2: Vector2, apex: Vector2, alpha: float) -> void:
	var pts := PackedVector2Array([b1, apex, b2])
	var mid: Vector2 = (b1 + apex + b2) / 3.0
	var inner := PackedVector2Array([mid + (b1 - mid) * 0.5, mid + (apex - mid) * 0.5, mid + (b2 - mid) * 0.5])
	var cream := Color(CREAM.r, CREAM.g, CREAM.b, alpha)
	var pink := Color(PINK.r, PINK.g, PINK.b, alpha)
	var dark := Color(DARK.r, DARK.g, DARK.b, alpha)
	draw_colored_polygon(pts, cream)
	draw_colored_polygon(inner, pink)
	draw_polyline(PackedVector2Array([b1, apex, b2, b1]), dark, 4.0, true)

func _drawParticles() -> void:
	for p in particles:
		var t: float = float(p.life) / float(p.maxLife)
		var c: Color = p.color
		c.a *= clampf(t * 1.6, 0.0, 1.0)
		var s: float = float(p.size) * (0.4 + 0.6 * t)
		var pos: Vector2 = p.pos
		if int(p.kind) == 0:
			draw_circle(pos, s, c)
		else:
			_drawSparkle(pos, s * 1.8, float(p.angle), c)

func _drawSparkle(center: Vector2, radius: float, angle: float, color: Color) -> void:
	var pts := PackedVector2Array()
	for k in 8:
		var a: float = angle + TAU * float(k) / 8.0
		var rad: float = radius if k % 2 == 0 else radius * 0.3
		pts.append(center + Vector2(cos(a), sin(a)) * rad)
	draw_colored_polygon(pts, color)
