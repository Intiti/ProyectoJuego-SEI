extends Node2D

# Fondo interior Panadería
# Pared de madera con tablas verticales, piso de madera, ventanas con luz
# Mismo enfoque que background.gd: solo draw_colored_polygon / draw_line / draw_circle

const W        := 1152.0
const H        := 648.0
const GROUND_Y := 610.0

# ── Paleta ──────────────────────────────────────────────────────────────────
const WALL_BASE  : Color = Color(0.42, 0.28, 0.14)   # madera pared base
const WALL_DARK  : Color = Color(0.30, 0.18, 0.08)   # tabla oscura
const WALL_MID   : Color = Color(0.50, 0.34, 0.18)   # tabla media
const WALL_LITE  : Color = Color(0.62, 0.44, 0.24)   # tabla clara
const WALL_GRAIN : Color = Color(0.24, 0.14, 0.06)   # veta madera

const FLOOR_BASE : Color = Color(0.55, 0.36, 0.16)   # piso madera base
const FLOOR_DARK : Color = Color(0.40, 0.24, 0.08)   # tabla piso oscura
const FLOOR_MID  : Color = Color(0.62, 0.42, 0.20)   # tabla piso media
const FLOOR_LITE : Color = Color(0.72, 0.52, 0.28)   # tabla piso clara
const FLOOR_LINE : Color = Color(0.28, 0.16, 0.05)   # borde tabla piso

const WIN_FRAME  : Color = Color(0.32, 0.20, 0.08)   # marco ventana
const WIN_GLASS  : Color = Color(0.72, 0.90, 1.00, 0.55)  # vidrio
const WIN_LIGHT  : Color = Color(1.00, 0.95, 0.75, 0.18)  # luz que entra
const WIN_CROSS  : Color = Color(0.25, 0.14, 0.05)   # travesaño
const WIN_SILL   : Color = Color(0.38, 0.24, 0.10)   # alféizar

const BEAM_COL   : Color = Color(0.26, 0.15, 0.06)   # vigas techo
const CEIL_COL   : Color = Color(0.36, 0.22, 0.10)   # techo
const OUTLINE    : Color = Color(0.18, 0.10, 0.03)

const LW := 2.5

func _draw():
	_drawWall()
	_drawCeiling()
	_drawWindows()
	_drawFloor()
	_drawSkirting()

# ── Pared de madera (tablas verticales) ──────────────────────────────────────
func _drawWall():
	# Fondo base de la pared
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, 0), Vector2(W, 0),
		Vector2(W, GROUND_Y), Vector2(0, GROUND_Y)
	]), WALL_BASE)

	# Tablas verticales con colores alternados
	var plankW := 48.0
	var cols : Array = [WALL_DARK, WALL_MID, WALL_LITE, WALL_MID, WALL_DARK, WALL_LITE]
	var idx := 0
	var x := 0.0
	while x < W:
		var col : Color = cols[idx % cols.size()]
		draw_colored_polygon(PackedVector2Array([
			Vector2(x + 1, 0), Vector2(x + plankW - 1, 0),
			Vector2(x + plankW - 1, GROUND_Y), Vector2(x + 1, GROUND_Y)
		]), col)
		# Veta de madera (línea sutil en cada tabla)
		var gx := x + plankW * 0.35
		draw_line(Vector2(gx, 30), Vector2(gx + 4, GROUND_Y - 40), WALL_GRAIN, 1.2)
		var gx2 := x + plankW * 0.72
		draw_line(Vector2(gx2, 60), Vector2(gx2 - 3, GROUND_Y - 80), WALL_GRAIN, 1.0)
		# Borde entre tablas
		draw_line(Vector2(x, 0), Vector2(x, GROUND_Y), OUTLINE, 1.8)
		x += plankW
		idx += 1

# ── Techo con vigas ───────────────────────────────────────────────────────────
func _drawCeiling():
	# Franja de techo
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, 0), Vector2(W, 0),
		Vector2(W, 72), Vector2(0, 72)
	]), CEIL_COL)
	draw_line(Vector2(0, 72), Vector2(W, 72), OUTLINE, LW)

	# Vigas horizontales de madera
	var beamH := 28.0
	var beamPositions : Array = [8.0, 44.0]
	for by : float in beamPositions:
		draw_colored_polygon(PackedVector2Array([
			Vector2(0, by), Vector2(W, by),
			Vector2(W, by + beamH), Vector2(0, by + beamH)
		]), BEAM_COL)
		# Vetas de viga
		for i in 6:
			var vx : float = W * float(i) / 6.0 + 30
			draw_line(Vector2(vx, by + 4), Vector2(vx + 60, by + beamH - 4), WALL_GRAIN, 1.5)
		draw_line(Vector2(0, by),          Vector2(W, by),          OUTLINE, 1.8)
		draw_line(Vector2(0, by + beamH),  Vector2(W, by + beamH),  OUTLINE, 1.8)

# ── Ventanas ──────────────────────────────────────────────────────────────────
func _drawWindows():
	# Tres ventanas grandes distribuidas
	var winData : Array = [
		Vector2(95,  110),
		Vector2(460, 110),
		Vector2(830, 110),
	]
	for pos : Vector2 in winData:
		_drawWindow(pos.x, pos.y, 200, 280)

func _drawWindow(wx: float, wy: float, ww: float, wh: float):
	var frameT := 10.0  # grosor marco

	# Luz que entra por la ventana (haz diagonal)
	draw_colored_polygon(PackedVector2Array([
		Vector2(wx + ww * 0.1, wy + wh),
		Vector2(wx + ww * 0.9, wy + wh),
		Vector2(wx + ww * 1.3, GROUND_Y),
		Vector2(wx - ww * 0.3, GROUND_Y)
	]), WIN_LIGHT)

	# Marco exterior
	_solidRect(wx - frameT, wy - frameT, ww + frameT*2, wh + frameT*2, WIN_FRAME)

	# Vidrio
	_solidRect(wx, wy, ww, wh, WIN_GLASS)

	# Travesaños (cruz)
	draw_line(Vector2(wx + ww*0.5, wy), Vector2(wx + ww*0.5, wy + wh), WIN_CROSS, 5.0)
	draw_line(Vector2(wx, wy + wh*0.45), Vector2(wx + ww, wy + wh*0.45), WIN_CROSS, 5.0)

	# Contorno marco
	_rectOutline(wx - frameT, wy - frameT, ww + frameT*2, wh + frameT*2, OUTLINE, LW)

	# Alféizar (repisa bajo la ventana)
	_solidRect(wx - frameT - 6, wy + wh + frameT, ww + frameT*2 + 12, 14, WIN_SILL)
	_rectOutline(wx - frameT - 6, wy + wh + frameT, ww + frameT*2 + 12, 14, OUTLINE, LW)

# ── Piso de madera (tablas horizontales con perspectiva) ─────────────────────
func _drawFloor():
	# Base del piso
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, GROUND_Y - 8), Vector2(W, GROUND_Y - 8),
		Vector2(W, H), Vector2(0, H)
	]), FLOOR_BASE)

	# Tablas horizontales (distintos anchos y colores para naturalidad)
	var floorCols : Array = [FLOOR_DARK, FLOOR_MID, FLOOR_LITE, FLOOR_MID, FLOOR_DARK, FLOOR_LITE, FLOOR_MID]
	var plankH := 28.0
	var y := GROUND_Y - 8.0
	var idx := 0
	while y < H:
		var col : Color = floorCols[idx % floorCols.size()]
		draw_colored_polygon(PackedVector2Array([
			Vector2(0, y + 1), Vector2(W, y + 1),
			Vector2(W, y + plankH - 1), Vector2(0, y + plankH - 1)
		]), col)
		# Vetas horizontales dentro de la tabla
		var gy : float = y + plankH * 0.4
		draw_line(Vector2(20, gy), Vector2(W - 20, gy + 3), FLOOR_LINE, 1.0)
		# Junta entre tablas
		draw_line(Vector2(0, y), Vector2(W, y), FLOOR_LINE, 2.0)
		# Nudos de madera ocasionales
		if idx % 3 == 1:
			var kx : float = W * (0.2 + float(idx % 5) * 0.15)
			draw_circle(Vector2(kx, y + plankH * 0.5), 5.0, FLOOR_LINE)
			draw_circle(Vector2(kx, y + plankH * 0.5), 3.0, col)
		y += plankH
		idx += 1

# ── Rodapié (zócalo entre pared y piso) ──────────────────────────────────────
func _drawSkirting():
	_solidRect(0, GROUND_Y - 22, W, 18, BEAM_COL)
	draw_line(Vector2(0, GROUND_Y - 22), Vector2(W, GROUND_Y - 22), OUTLINE, LW)
	draw_line(Vector2(0, GROUND_Y - 4),  Vector2(W, GROUND_Y - 4),  OUTLINE, LW)

# ── Helpers ───────────────────────────────────────────────────────────────────
func _solidRect(x: float, y: float, w: float, h: float, col: Color):
	draw_colored_polygon(PackedVector2Array([
		Vector2(x, y), Vector2(x+w, y),
		Vector2(x+w, y+h), Vector2(x, y+h)
	]), col)

func _rectOutline(x: float, y: float, w: float, h: float, col: Color, lw: float):
	draw_polyline(PackedVector2Array([
		Vector2(x, y), Vector2(x+w, y),
		Vector2(x+w, y+h), Vector2(x, y+h), Vector2(x, y)
	]), col, lw, true)
