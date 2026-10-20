extends Control

# Titulo con forma de gato: orejas en la M, un gato doodle en la primera O y bigotes.
# Las letras caen al iniciar y reaccionan al mouse. Todo se dibuja por codigo.

const TITLE_TEXT := "MIAUGORITMOS"
const FONT_PATH := "res://assets/fonts/MotionControl-Bold.otf"
const FONT_SIZE := 60
const TRACKING := 4.0
# Altura de mayuscula como fraccion del ascent de la fuente, ajustar si no calza
const CAP_RATIO := 0.75
const EAR_ROOM := 40.0
const SIDE_ROOM := 70.0
const BOTTOM_ROOM := 14.0
# Cuadros por segundo del temblor de lineas estilo doodle
const DOODLE_FPS := 8.0

const CREAM := Color(0.98, 0.93, 0.80)
const DARK := Color(0.04, 0.09, 0.07)
const PINK := Color(1.0, 0.60, 0.72)

var font: Font
var timeAcc: float = 0.0
var letterX: Array[float] = []
var letterW: Array[float] = []
var lift: Array[float] = []
var totalW: float = 0.0
var capH: float = 0.0
var ascent: float = 0.0
var originX: float = 0.0
var baselineY: float = 0.0
var catIndex: int = -1

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists(FONT_PATH):
		font = load(FONT_PATH)
	else:
		font = ThemeDB.fallback_font
	_measureLetters()
	var descent: float = font.get_descent(FONT_SIZE)
	custom_minimum_size = Vector2(totalW + SIDE_ROOM * 2.0, EAR_ROOM + ascent + descent + BOTTOM_ROOM)

# Mide cada letra para moverlas por separado, la primera O deja espacio para el gato
func _measureLetters() -> void:
	ascent = font.get_ascent(FONT_SIZE)
	capH = ascent * CAP_RATIO
	catIndex = TITLE_TEXT.find("O")
	var x: float = 0.0
	for i in TITLE_TEXT.length():
		var w: float = _catRadius() * 2.0 + 10.0
		if i != catIndex:
			w = font.get_string_size(TITLE_TEXT[i], HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x
		letterX.append(x)
		letterW.append(w)
		lift.append(0.0)
		x += w + TRACKING
	totalW = x - TRACKING

func _process(delta: float) -> void:
	timeAcc += delta
	originX = (size.x - totalW) * 0.5
	baselineY = EAR_ROOM + ascent
	_updateLift(delta)
	queue_redraw()

# La letra bajo el mouse sube un poco, con suavizado
func _updateLift(delta: float) -> void:
	var mouse: Vector2 = get_local_mouse_position()
	var inBand: bool = mouse.y > baselineY - capH - 10.0 and mouse.y < baselineY + 10.0
	for i in lift.size():
		var left: float = originX + letterX[i]
		var over: bool = inBand and mouse.x >= left and mouse.x <= left + letterW[i]
		lift[i] = lerpf(lift[i], 1.0 if over else 0.0, minf(delta * 12.0, 1.0))

func _draw() -> void:
	var accAlpha: float = clampf((timeAcc - 0.9) / 0.5, 0.0, 1.0)
	_drawWhiskers(accAlpha)
	_drawEars(accAlpha)
	_drawLetters()

func _alpha(c: Color, a: float) -> Color:
	return Color(c.r, c.g, c.b, c.a * a)

# Progreso de entrada de cada letra, escalonado por posicion
func _letterProgress(i: int) -> float:
	return clampf((timeAcc - float(i) * 0.07) / 0.5, 0.0, 1.0)

# Caida con rebote, flotacion suave y salto al pasar el mouse
func _letterOffsetY(i: int) -> float:
	var p: float = _letterProgress(i)
	var c1: float = 1.70158
	var c3: float = c1 + 1.0
	var v: float = 1.0 + c3 * pow(p - 1.0, 3.0) + c1 * pow(p - 1.0, 2.0)
	var drop: float = -120.0 * (1.0 - v)
	var bob: float = sin(timeAcc * 2.0 + float(i) * 0.45) * 2.0 * p
	return drop + bob - lift[i] * 10.0

# Primero sombras y contornos de todas, despues los rellenos, para que no se pisen
func _drawLetters() -> void:
	for i in TITLE_TEXT.length():
		if i == catIndex:
			continue
		var p: float = _letterProgress(i)
		var pos := Vector2(originX + letterX[i], baselineY + _letterOffsetY(i))
		draw_string(font, pos + Vector2(0, 5), TITLE_TEXT[i], HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, Color(0, 0, 0, 0.4 * p))
		draw_string_outline(font, pos, TITLE_TEXT[i], HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, 8, _alpha(DARK, p))
	for i in TITLE_TEXT.length():
		var p: float = _letterProgress(i)
		var pos := Vector2(originX + letterX[i], baselineY + _letterOffsetY(i))
		if i == catIndex:
			var center := Vector2(pos.x + letterW[i] * 0.5, pos.y - capH * 0.5)
			_drawCat(center, p, lift[i] > 0.5)
		else:
			draw_string(font, pos, TITLE_TEXT[i], HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, _alpha(CREAM, p))

# Pequeno temblor de linea que cambia pocas veces por segundo, da el look de dibujo a mano
func _jitter(i: int, frame: int) -> Vector2:
	var s: float = float(frame)
	return Vector2(sin(float(i) * 12.9898 + s * 78.233), cos(float(i) * 39.346 + s * 11.135)) * 1.1

func _catRadius() -> float:
	return capH * 0.62

# Gato doodle que hace de letra O: cara redonda, orejas, ojos que siguen al mouse
func _drawCat(center: Vector2, a: float, happy: bool) -> void:
	var r: float = _catRadius()
	var frame: int = int(timeAcc * DOODLE_FPS)
	draw_circle(center + Vector2(0, 5), r + 2.0, Color(0, 0, 0, 0.4 * a))
	_drawCatEar(center, r, -1.0, frame, a)
	_drawCatEar(center, r, 1.0, frame, a)
	var head := PackedVector2Array()
	for k in 28:
		var ang: float = TAU * float(k) / 28.0
		head.append(center + Vector2(cos(ang), sin(ang) * 0.9) * r + _jitter(k, frame))
	draw_colored_polygon(head, _alpha(CREAM, a))
	var outline := head.duplicate()
	outline.append(head[0])
	draw_polyline(outline, _alpha(DARK, a), 4.0, true)
	_drawCatFace(center, r, a, happy)

func _drawCatEar(center: Vector2, r: float, side: float, frame: int, a: float) -> void:
	var offset: int = 40 if side > 0.0 else 60
	var pts := PackedVector2Array([
		center + Vector2(side * r * 0.15, -r * 0.8) + _jitter(offset, frame),
		center + Vector2(side * r * 0.78, -r * 1.35) + _jitter(offset + 1, frame),
		center + Vector2(side * r * 0.85, -r * 0.45) + _jitter(offset + 2, frame)
	])
	var mid: Vector2 = (pts[0] + pts[1] + pts[2]) / 3.0
	var inner := PackedVector2Array([
		mid + (pts[0] - mid) * 0.5, mid + (pts[1] - mid) * 0.5, mid + (pts[2] - mid) * 0.5
	])
	draw_colored_polygon(pts, _alpha(CREAM, a))
	draw_colored_polygon(inner, _alpha(PINK, a))
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[0]]), _alpha(DARK, a), 4.0, true)

# Mejillas, ojos, nariz y boca
func _drawCatFace(center: Vector2, r: float, a: float, happy: bool) -> void:
	for side in [-1.0, 1.0]:
		var sf: float = side
		draw_set_transform(center + Vector2(sf * r * 0.55, r * 0.22), 0.0, Vector2(r * 0.16, r * 0.09))
		draw_circle(Vector2.ZERO, 1.0, _alpha(PINK, 0.5 * a))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var look: Vector2 = get_local_mouse_position() - center
	var dir: Vector2 = look.normalized() * minf(look.length() / 200.0, 1.0)
	var cyc: float = fposmod(timeAcc, 3.6)
	var blinking: bool = cyc > 3.4
	for side in [-1.0, 1.0]:
		var sf: float = side
		var eye: Vector2 = center + Vector2(sf * r * 0.38, -r * 0.05) + dir * r * 0.07
		if happy:
			draw_polyline(PackedVector2Array([
				eye + Vector2(-r * 0.12, r * 0.05), eye + Vector2(0, -r * 0.08), eye + Vector2(r * 0.12, r * 0.05)
			]), _alpha(DARK, a), 2.5, true)
		elif blinking:
			draw_line(eye + Vector2(-r * 0.1, 0), eye + Vector2(r * 0.1, 0), _alpha(DARK, a), 2.5, true)
		else:
			draw_circle(eye, r * 0.1, _alpha(DARK, a))
	var nose: Vector2 = center + Vector2(0, r * 0.18)
	var noseShape := PackedVector2Array([
		nose + Vector2(-r * 0.11, -r * 0.05), nose + Vector2(r * 0.11, -r * 0.05), nose + Vector2(0, r * 0.07)
	])
	draw_colored_polygon(noseShape, _alpha(PINK, a))
	draw_polyline(PackedVector2Array([noseShape[0], noseShape[1], noseShape[2], noseShape[0]]), _alpha(DARK, a), 1.5, true)
	draw_polyline(PackedVector2Array([
		nose + Vector2(-r * 0.22, r * 0.18), nose + Vector2(-r * 0.11, r * 0.26), nose + Vector2(0, r * 0.15),
		nose + Vector2(r * 0.11, r * 0.26), nose + Vector2(r * 0.22, r * 0.18)
	]), _alpha(DARK, a), 2.0, true)

# Dos orejas sobre la M, la derecha se agita de vez en cuando
func _drawEars(a: float) -> void:
	var left: float = originX + letterX[0]
	var mw: float = letterW[0]
	var topY: float = baselineY - capH + _letterOffsetY(0)
	var phase: float = fposmod(timeAcc, 5.0)
	var flick: float = sin(phase * 32.0) * maxf(0.0, 1.0 - phase * 3.0) * 0.3
	_drawEar(Vector2(left + mw * 0.02, topY + 12.0), Vector2(left + mw * 0.50, topY + 12.0),
		Vector2(left + mw * 0.08, topY - 36.0), 0.0, a)
	_drawEar(Vector2(left + mw * 0.50, topY + 12.0), Vector2(left + mw * 0.98, topY + 12.0),
		Vector2(left + mw * 0.92, topY - 36.0), flick, a)

func _drawEar(b1: Vector2, b2: Vector2, apex: Vector2, flick: float, a: float) -> void:
	var pivot: Vector2 = (b1 + b2) * 0.5
	var pts := PackedVector2Array([b1 - pivot, apex - pivot, b2 - pivot])
	var center: Vector2 = (pts[0] + pts[1] + pts[2]) / 3.0
	var inner := PackedVector2Array([
		center + (pts[0] - center) * 0.5,
		center + (pts[1] - center) * 0.5,
		center + (pts[2] - center) * 0.5
	])
	draw_set_transform(pivot, flick, Vector2.ONE)
	draw_colored_polygon(pts, _alpha(CREAM, a))
	draw_colored_polygon(inner, _alpha(PINK, a))
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[0]]), _alpha(DARK, a), 4.0, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# Tres bigotes por lado, con un leve temblor
func _drawWhiskers(a: float) -> void:
	var y0: float = baselineY - capH * 0.45
	var leftX: float = originX - 8.0
	var rightX: float = originX + totalW + 8.0
	for k in 3:
		var spread: float = float(k - 1)
		var wiggle: float = sin(timeAcc * 1.6 + float(k)) * 3.0
		var ctrl := Vector2(26.0, spread * 5.0 - 5.0)
		var tip := Vector2(52.0, spread * 14.0 - 6.0 + wiggle)
		var leftStart := Vector2(leftX, y0 + spread * 9.0)
		var rightStart := Vector2(rightX, y0 + spread * 9.0)
		_drawWhisker(leftStart, leftStart + ctrl * Vector2(-1, 1), leftStart + tip * Vector2(-1, 1), a)
		_drawWhisker(rightStart, rightStart + ctrl, rightStart + tip, a)

# Curva cuadratica de 8 tramos
func _drawWhisker(start: Vector2, ctrl: Vector2, tip: Vector2, a: float) -> void:
	var pts := PackedVector2Array()
	for i in 9:
		var t: float = float(i) / 8.0
		pts.append(start.lerp(ctrl, t).lerp(ctrl.lerp(tip, t), t))
	draw_polyline(pts, _alpha(DARK, a), 4.5, true)
	draw_polyline(pts, _alpha(CREAM, a), 2.2, true)
