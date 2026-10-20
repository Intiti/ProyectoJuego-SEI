extends Container

# ==========================================
# MGTS - NIVEL 3
# INSIGNIAS GANADAS EN LA VENTANA FINAL
# Compatible con GridContainer y HBoxContainer
# ==========================================

@export var imagenes_insignias: Array[Texture2D] = []

@export var nombres_insignias: Array[String] = [
	"Explorador Subterráneo",
	"Maestro de Ciclos",
	"Lógica Pura (Sin Ayuda)",
	"Ingeniero del Complejo",
	"Evaluación Superada",
	"Héroe de Panko"
]

@export var insignias_desbloqueadas: Array[bool] = [
	false,
	false,
	false,
	false,
	false,
	false
]

const RUTA_TEXTURA_INSIGNIA_DEFECTO: String = "res://assets/nivel_3/texture/916efaf3-ae1c-4116-ad1e-967078a8ab24.png"
const COLOR_DESBLOQUEADA: Color = Color(1, 1, 1, 1)
const COLOR_SIN_AYUDA: Color = Color(1.15, 1.08, 0.72, 1)
const COLOR_BLOQUEADA: Color = Color(0.25, 0.25, 0.25, 0.65)

var nodos_insignias: Array[TextureRect] = []


const IconoPixel = preload("res://scripts/nivel_3/InsigniaPixelMGTS.gd")
var filas_generales: VBoxContainer = null
var columnas_generales: int = 0

func _ready() -> void:
	for hijo in get_children():
		if hijo is TextureRect:
			nodos_insignias.append(hijo)
			hijo.hide()
	if get_class() == "GridContainer":
		set("columns", 1)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	filas_generales = VBoxContainer.new()
	filas_generales.name = "InsigniasDeTodosLosNiveles"
	filas_generales.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	filas_generales.add_theme_constant_override("separation", 8)
	add_child(filas_generales)
	resized.connect(_ajustar_filas_generales)
	actualizar_insignias()


func _ajustar_filas_generales() -> void:
	var nuevas: int = clampi(int(size.x / 64.0), 1, 6)
	if nuevas != columnas_generales:
		actualizar_insignias.call_deferred()


func obtener_o_crear_nodos_insignias() -> void:
	nodos_insignias.clear()
	for hijo in get_children():
		if hijo is TextureRect:
			nodos_insignias.append(hijo as TextureRect)

	# Si el contenedor en Final.tscn no tenía nodos hijos, crear las 6 insignias
	if nodos_insignias.is_empty():
		var tex_defecto: Texture2D = null
		if ResourceLoader.exists(RUTA_TEXTURA_INSIGNIA_DEFECTO):
			tex_defecto = load(RUTA_TEXTURA_INSIGNIA_DEFECTO) as Texture2D

		for i in range(6):
			var icono := TextureRect.new()
			icono.name = "Insignia" + str(i + 1)
			icono.custom_minimum_size = Vector2(54, 54)
			icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icono.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			if tex_defecto != null:
				icono.texture = tex_defecto
			add_child(icono)
			nodos_insignias.append(icono)


func sincronizar_con_puntajes() -> void:
	var sistema_puntos: Node = get_node_or_null("/root/PuntajesNivel3")
	if sistema_puntos == null:
		return

	if sistema_puntos.has_method("obtener_estado_insignias"):
		var estados: Array = sistema_puntos.call("obtener_estado_insignias")
		if estados.size() == 6:
			insignias_desbloqueadas.clear()
			for e in estados:
				insignias_desbloqueadas.append(bool(e))

	if sistema_puntos.has_method("obtener_nombres_insignias"):
		var nombres: Array = sistema_puntos.call("obtener_nombres_insignias")
		if nombres.size() == 6:
			nombres_insignias.clear()
			for n in nombres:
				nombres_insignias.append(str(n))


func actualizar_insignias() -> void:
	if filas_generales == null:
		return
	var sistema: Node = get_node_or_null("/root/PuntajesNivel3")
	if sistema == null or not sistema.has_method("obtener_resumen_general"):
		return
	var resumen: Dictionary = sistema.call("obtener_resumen_general")
	var insignias: Array = []
	for item in resumen.get("insignias", []):
		if int(item.get("nivel", 0)) != 3:
			insignias.append(item)
	if sistema.has_method("obtener_catalogo_insignias_nivel3"):
		insignias.append_array(sistema.call("obtener_catalogo_insignias_nivel3"))
	columnas_generales = clampi(int(size.x / 64.0), 1, 6)
	for fila in filas_generales.get_children():
		filas_generales.remove_child(fila)
		fila.queue_free()
	if insignias.is_empty():
		var mensaje := Label.new()
		mensaje.text = "Aún no hay insignias desbloqueadas."
		mensaje.add_theme_font_size_override("font_size", 15)
		mensaje.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		mensaje.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		filas_generales.add_child(mensaje)
		return
	var fila_actual: HBoxContainer = null
	for i in range(insignias.size()):
		if i % columnas_generales == 0:
			var centro := CenterContainer.new()
			centro.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			filas_generales.add_child(centro)
			fila_actual = HBoxContainer.new()
			fila_actual.add_theme_constant_override("separation", 8)
			centro.add_child(fila_actual)
		var info: Dictionary = insignias[i]
		var icono: Control = null
		var ruta: String = str(info.get("textura", ""))
		if not ruta.is_empty() and ResourceLoader.exists(ruta):
			var textura = load(ruta)
			if textura is Texture2D:
				var imagen := TextureRect.new()
				imagen.texture = textura
				imagen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				imagen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				icono = imagen
		if icono == null:
			var pixel := IconoPixel.new()
			pixel.clave = str(info.get("icono", info.id))
			pixel.nivel = int(info.nivel)
			icono = pixel
		icono.custom_minimum_size = Vector2(56, 56)
		icono.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icono.mouse_filter = Control.MOUSE_FILTER_STOP
		var desbloqueada: bool = bool(info.get("desbloqueada", true))
		icono.modulate = Color.WHITE if desbloqueada else Color(0.30, 0.30, 0.30, 0.65)
		icono.tooltip_text = "Nivel %d · %s · %s\n%s\n%s" % [int(info.nivel), str(info.nombre), "Obtenida" if desbloqueada else "Pendiente", str(info.get("descripcion", "")), str(info.get("condicion", "Recompensa registrada por el nivel correspondiente."))]
		fila_actual.add_child(icono)


func desbloquear_insignia(indice: int) -> void:
	if indice < 0:
		return
	while insignias_desbloqueadas.size() <= indice:
		insignias_desbloqueadas.append(false)
	insignias_desbloqueadas[indice] = true
	actualizar_insignias()
