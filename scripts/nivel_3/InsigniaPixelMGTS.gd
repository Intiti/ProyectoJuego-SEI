extends Control
# Iconos nativos de 8x8 píxeles, ampliados sin interpolación.
var clave: String = ""
var nivel: int = 3
const FIGURAS: Dictionary = {
	"insignia_e3_1": [".###....","##.##...","##.##...",".###....","..#.....","..###...","..#.....","..##...."],
	"insignia_e3_2": ["...##...","..####..",".######.","...##...","..####..","...##...","...##...","........"],
	"insignia_e3_3": ["##....##","###..###","..####..","...##...","..####..","###..###","##....##","........"],
	"insignia_e3_4": ["...##...","..#..#..","..#..#..","..#..#..","..####..",".######.",".######.","..####.."],
	"insignia_e3_5": ["..##....","..###...","...##.##","####.###","###.####","##.##...","...###..","....##.."],
	"insignia_e3_6": ["##....##",".######.","..#..#..","...##...","..#..#..",".######.","##....##","........"],
	"insignia_e3_7": [".######.",".##..##.",".##..##.",".######.","..####..","..####..","...##...","........"],
	"insignia_e3_8": ["..####..",".##..##.","##....##","##.##.##","##.##.##","##....##",".##..##.","..####.."],
	"insignia_e3_9": [".#....#.","..#..#..","...##...","...##...","..####..","...##...","...##...","..####.."],
	"insignia_e3_10": ["##....##","###..###","########","##.##.##","########",".##..##.","..####..","........"],
	"insignia_examen_final": [".##..##.","..####..","..####..",".######.","##.##.##",".######.","..####..","...##..."]
}
const COLORES: Array[Color] = [Color("#FBBF24"), Color("#38BDF8"), Color("#A78BFA"), Color("#FB7185"), Color("#34D399"), Color("#2DD4BF"), Color("#F97316"), Color("#818CF8"), Color("#E879F9"), Color("#60A5FA"), Color("#FDE047")]
func _draw() -> void:
	var indice: int = maxi(0, FIGURAS.keys().find(clave))
	var color: Color = COLORES[indice % COLORES.size()]
	var unidad: float = floorf(minf(size.x, size.y) / 12.0)
	var origen := (size - Vector2(12, 12) * unidad) / 2.0
	draw_rect(Rect2(origen, Vector2(12, 12) * unidad), Color("#0F172A"))
	draw_rect(Rect2(origen + Vector2.ONE * unidad, Vector2(10, 10) * unidad), color.darkened(0.65))
	var filas: Array = FIGURAS.get(clave, ["...##...","..####..",".######.","########",".######.","..####..","...##...","........"])
	for y in range(8):
		for x in range(8):
			if filas[y][x] == "#":
				draw_rect(Rect2(origen + Vector2(x + 2, y + 2) * unidad, Vector2.ONE * unidad), color)
