extends Node2D

# Fondo interior Escuela
# Pared verde clara, pizarra grande al frente, ventana lateral, piso de linoleum

const W        := 1152.0
const H        := 648.0
const GROUND_Y := 610.0

# Paleta
const WALL_BASE  : Color = Color(0.76, 0.84, 0.72)   # pared verde clara
const WALL_DARK  : Color = Color(0.64, 0.74, 0.60)   # sombra pared
const WALL_LINE  : Color = Color(0.55, 0.66, 0.50)   # lineas pared

const FLOOR_BASE : Color = Color(0.62, 0.56, 0.48)   # linoleum base
const FLOOR_TILE : Color = Color(0.58, 0.52, 0.44)   # baldosa alternada
const FLOOR_LINE : Color = Color(0.45, 0.40, 0.33)   # junta de baldosa

const BOARD_BG   : Color = Color(0.13, 0.28, 0.18)   # pizarra verde oscuro
const BOARD_FRAM : Color = Color(0.28, 0.18, 0.08)   # marco madera pizarra
const BOARD_WRIT : Color = Color(0.85, 0.85, 0.85, 0.6) # tiza blanca
const BOARD_TRAY : Color = Color(0.22, 0.14, 0.06)   # repisa pizarra

const WIN_FRAME  : Color = Color(0.80, 0.70, 0.50)   # marco ventana
const WIN_GLASS  : Color = Color(0.72, 0.90, 1.00, 0.55)
const WIN_LIGHT  : Color = Color(1.00, 0.95, 0.75, 0.15)
const WIN_CROSS  : Color = Color(0.60, 0.50, 0.30)
const WIN_SILL   : Color = Color(0.70, 0.58, 0.38)

const CEIL_COL   : Color = Color(0.88, 0.90, 0.82)   # techo blancuzco
const OUTLINE    : Color = Color(0.25, 0.25, 0.22)
const LW         := 2.5

func _draw():
	_drawWall()
	_drawCeiling()
	_drawWindow()
	_drawBlackboard()
	_drawFloor()
	_drawSkirting()

# Pared verde lisa con lineas horizontales sutiles
func _drawWall():
	_solidRect(0, 0, W, GROUND_Y, WALL_BASE)
	# Lineas horizontales tipo panel
	var y := 80.0
	while y < GROUND_Y - 30:
		draw_line(Vector2(0, y), Vector2(W, y), WALL_LINE, 1.0)
		y += 60.0

# Techo blancuzco con rodapie superior
func _drawCeiling():
	_solidRect(0, 0, W, 72, CEIL_COL)
	draw_line(Vector2(0, 72), Vector2(W, 72), OUTLINE, LW)
	# Cornisa
	_solidRect(0, 68, W, 10, WALL_DARK)
	draw_line(Vector2(0, 68), Vector2(W, 68), OUTLINE, LW)

# Ventana a la derecha
func _drawWindow():
	var wx := 850.0
	var wy := 110.0
	var ww := 220.0
	var wh := 280.0
	var frameT := 10.0

	# Luz diagonal que entra
	draw_colored_polygon(PackedVector2Array([
		Vector2(wx + ww * 0.1, wy + wh),
		Vector2(wx + ww * 0.9, wy + wh),
		Vector2(wx + ww * 1.3, GROUND_Y),
		Vector2(wx - ww * 0.3, GROUND_Y)
	]), WIN_LIGHT)

	# Marco
	_solidRect(wx - frameT, wy - frameT, ww + frameT*2, wh + frameT*2, WIN_FRAME)
	# Vidrio
	_solidRect(wx, wy, ww, wh, WIN_GLASS)
	# Travesanos
	draw_line(Vector2(wx + ww*0.5, wy), Vector2(wx + ww*0.5, wy + wh), WIN_CROSS, 5.0)
	draw_line(Vector2(wx, wy + wh*0.45), Vector2(wx + ww, wy + wh*0.45), WIN_CROSS, 5.0)
	# Contorno
	_rectOutline(wx - frameT, wy - frameT, ww + frameT*2, wh + frameT*2, OUTLINE, LW)
	# Alfeizar
	_solidRect(wx - frameT - 6, wy + wh + frameT, ww + frameT*2 + 12, 14, WIN_SILL)
	_rectOutline(wx - frameT - 6, wy + wh + frameT, ww + frameT*2 + 12, 14, OUTLINE, LW)

# Pizarra grande centrada a la izquierda
func _drawBlackboard():
	var bx := 60.0
	var by := 90.0
	var bw := 680.0
	var bh := 320.0
	var frameT := 12.0

	# Marco de madera
	_solidRect(bx - frameT, by - frameT, bw + frameT*2, bh + frameT*2, BOARD_FRAM)
	_rectOutline(bx - frameT, by - frameT, bw + frameT*2, bh + frameT*2, OUTLINE, LW)

	# Superficie pizarra
	_solidRect(bx, by, bw, bh, BOARD_BG)

	# Rastros de tiza (lineas horizontales como texto borrado)
	for i in 5:
		var lineY : float = by + 60.0 + i * 50.0
		draw_line(Vector2(bx + 30, lineY), Vector2(bx + bw * (0.4 + i * 0.08), lineY), BOARD_WRIT, 2.0)
		draw_line(Vector2(bx + 30, lineY + 12), Vector2(bx + bw * (0.25 + i * 0.06), lineY + 12), BOARD_WRIT, 1.5)

	# Lineas guia horizontales en pizarra
	for i in 6:
		var gy : float = by + 40.0 + i * 46.0
		draw_line(Vector2(bx + 10, gy), Vector2(bx + bw - 10, gy), Color(0.3, 0.5, 0.35, 0.4), 1.0)

	# Contorno pizarra
	_rectOutline(bx, by, bw, bh, OUTLINE, LW)

	# Repisa inferior (porta-tizas)
	_solidRect(bx - frameT, by + bh + frameT, bw + frameT*2, 16, BOARD_TRAY)
	draw_line(Vector2(bx - frameT, by + bh + frameT),
		Vector2(bx + bw + frameT, by + bh + frameT), OUTLINE, LW)

# Piso de linoleum con baldosas
func _drawFloor():
	_solidRect(0, GROUND_Y - 8, W, H - GROUND_Y + 8, FLOOR_BASE)

	var tileW := 64.0
	var tileH := 32.0
	var y := GROUND_Y - 8.0
	var row := 0
	while y < H:
		var x := 0.0
		var col := 0
		while x < W:
			if (row + col) % 2 == 1:
				_solidRect(x, y, tileW, tileH, FLOOR_TILE)
			draw_line(Vector2(x, y), Vector2(x, y + tileH), FLOOR_LINE, 1.0)
			x += tileW
			col += 1
		draw_line(Vector2(0, y), Vector2(W, y), FLOOR_LINE, 1.5)
		y += tileH
		row += 1

# Rodapie entre pared y piso
func _drawSkirting():
	_solidRect(0, GROUND_Y - 20, W, 16, WALL_DARK)
	draw_line(Vector2(0, GROUND_Y - 20), Vector2(W, GROUND_Y - 20), OUTLINE, LW)
	draw_line(Vector2(0, GROUND_Y - 4),  Vector2(W, GROUND_Y - 4),  OUTLINE, LW)

# Helpers
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
