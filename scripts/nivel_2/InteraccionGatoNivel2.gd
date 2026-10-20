extends Area2D

# ==========================================
# MGTS - NIVEL 2: INTERACCIÓN CON NPC GATO MÍSTICO
# SISTEMA DE DIÁLOGO IDÉNTICO AL NIVEL 3 (RETRATOS BIDIRECCIONALES Y ALTERNANCIA)
# ==========================================

signal dialogo_finalizado

@export var dialog_file: String = ""
@export var npc_nombre: String = "Gato Místico"
@export var npc_portrait: Texture2D

var jugador: CharacterBody2D = null
var letra_e: Label = null
var altar_objetivo: Node = null
var sprite_npc: Sprite2D = null

var jugador_cerca: bool = false
var dialogo_activo: bool = false
var dialogo_terminado: bool = false

var lineas_dialogo: Array = []
var lineas_outro: Array = []
var indice_linea: int = 0
var usando_outro: bool = false

# UI de Diálogo (Estilo Nivel 3)
var dialogo_canvas: CanvasLayer = null
var fondo_dialogo: ColorRect = null
var retrato_jugador: TextureRect = null
var retrato_npc: TextureRect = null
var caja_dialogo: PanelContainer = null
var label_hablante: Label = null
var label_texto: Label = null
var label_continuar: Label = null
var estilo_caja: StyleBoxFlat = null

const RADIO_DETECCION: float = 160.0

# Colores idénticos a Nivel 3
const COLOR_ILUMINADO: Color = Color.WHITE
const COLOR_OSCURO: Color = Color(0.32, 0.32, 0.35, 1.0)
const COLOR_PROTAGONISTA: Color = Color(0.65, 0.42, 1.0, 1.0)
const COLOR_NPC_CIAN: Color = Color(0.0, 0.87, 1.0, 1.0)
const COLOR_FONDO_CAJA: Color = Color(0.045, 0.065, 0.11, 0.97)

const MAPA_TEXTURAS_NPC = {
	"Constructor Bram": "res://assets/nivel_2/personajes/Gato_Constructor.png",
	"Gato Constructor": "res://assets/nivel_2/personajes/Gato_Constructor.png",
	"Rastreador Chikí": "res://assets/nivel_2/personajes/Gato_Rastreador.png",
	"Druida Sylva": "res://assets/nivel_2/personajes/Gata_Recolectora.png",
	"Guía Milo": "res://assets/nivel_2/personajes/Gato_Guia.png",
	"Guardabosques Kaelen": "res://assets/nivel_2/personajes/Gato_Guardabosques.png"
}

const MAPA_RETRATOS_NPC = {
	"Constructor Bram": "res://assets/nivel_2/personajes/retratos/Retrato_Constructor.png",
	"Gato Constructor": "res://assets/nivel_2/personajes/retratos/Retrato_Constructor.png",
	"Rastreador Chikí": "res://assets/nivel_2/personajes/retratos/Retrato_Rastreador.png",
	"Druida Sylva": "res://assets/nivel_2/personajes/retratos/Retrato_Recolectora.png",
	"Guía Milo": "res://assets/nivel_2/personajes/retratos/Retrato_Guia.png",
	"Guardabosques Kaelen": "res://assets/nivel_2/personajes/retratos/Retrato_Guardabosques.png"
}

func _ready() -> void:
	visible = true
	modulate.a = 1.0
	z_index = 2
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	_crear_sombra_suelo()
	_asegurar_textura_y_visibilidad()
	call_deferred("_resolver_referencias")
	_cargar_dialogo()
	_crear_ui_dialogo()

func _crear_sombra_suelo() -> void:
	if get_node_or_null("SombraSuelo"):
		return
	var sombra = Sprite2D.new()
	sombra.name = "SombraSuelo"
	var img = Image.create(140, 50, false, Image.FORMAT_RGBA8)
	for y in range(50):
		for x in range(140):
			var nx = (x - 70.0) / 70.0
			var ny = (y - 25.0) / 25.0
			var d = nx * nx + ny * ny
			if d <= 1.0:
				var a = (1.0 - d) * 0.55
				img.set_pixel(x, y, Color(0.01, 0.03, 0.05, a))
			else:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
	sombra.texture = ImageTexture.create_from_image(img)
	sombra.position = Vector2(0, -6)
	sombra.z_index = -1
	add_child(sombra)

func _asegurar_textura_y_visibilidad() -> void:
	sprite_npc = get_node_or_null("Sprite2D") as Sprite2D
	if sprite_npc:
		sprite_npc.visible = true
		sprite_npc.modulate = Color(0.92, 0.96, 1.0)
		sprite_npc.z_index = 2
		sprite_npc.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		
		if sprite_npc.texture == null:
			var tex = _obtener_textura_segura()
			if tex:
				sprite_npc.texture = tex
				print("InteraccionGatoN2 [%s]: Textura asignada exitosamente al Sprite2D." % npc_nombre)

func _obtener_retrato_seguro() -> Texture2D:
	var ruta: String = MAPA_RETRATOS_NPC.get(npc_nombre, "")
	if ruta.is_empty():
		if "Chik" in npc_nombre or "Rastreador" in npc_nombre:
			ruta = "res://assets/nivel_2/personajes/retratos/Retrato_Rastreador.png"
		elif "Sylva" in npc_nombre or "Recolectora" in npc_nombre or "Druida" in npc_nombre:
			ruta = "res://assets/nivel_2/personajes/retratos/Retrato_Recolectora.png"
		elif "Milo" in npc_nombre or "Guia" in npc_nombre or "Guía" in npc_nombre:
			ruta = "res://assets/nivel_2/personajes/retratos/Retrato_Guia.png"
		elif "Kaelen" in npc_nombre or "Guardabosques" in npc_nombre:
			ruta = "res://assets/nivel_2/personajes/retratos/Retrato_Guardabosques.png"
		elif "Bram" in npc_nombre or "Constructor" in npc_nombre:
			ruta = "res://assets/nivel_2/personajes/retratos/Retrato_Constructor.png"
		else:
			var escena_nombre = get_tree().current_scene.name if get_tree().current_scene else ""
			if "Puente" in escena_nombre:
				ruta = "res://assets/nivel_2/personajes/retratos/Retrato_Constructor.png"
			elif "Sendero" in escena_nombre:
				ruta = "res://assets/nivel_2/personajes/retratos/Retrato_Rastreador.png"
			elif "Bayas" in escena_nombre:
				ruta = "res://assets/nivel_2/personajes/retratos/Retrato_Recolectora.png"
			elif "Linterna" in escena_nombre:
				ruta = "res://assets/nivel_2/personajes/retratos/Retrato_Guia.png"
			elif "Guardabosques" in escena_nombre:
				ruta = "res://assets/nivel_2/personajes/retratos/Retrato_Guardabosques.png"
	
	if not ruta.is_empty() and ResourceLoader.exists(ruta):
		var res = load(ruta) as Texture2D
		if res != null:
			return res
	return _obtener_textura_segura()

func _obtener_textura_segura() -> Texture2D:
	var ruta: String = MAPA_TEXTURAS_NPC.get(npc_nombre, "")
	if ruta.is_empty():
		if "Chik" in npc_nombre or "Rastreador" in npc_nombre:
			ruta = "res://assets/nivel_2/personajes/Gato_Rastreador.png"
		elif "Sylva" in npc_nombre or "Recolectora" in npc_nombre or "Druida" in npc_nombre:
			ruta = "res://assets/nivel_2/personajes/Gata_Recolectora.png"
		elif "Milo" in npc_nombre or "Guia" in npc_nombre or "Guía" in npc_nombre:
			ruta = "res://assets/nivel_2/personajes/Gato_Guia.png"
		elif "Kaelen" in npc_nombre or "Guardabosques" in npc_nombre:
			ruta = "res://assets/nivel_2/personajes/Gato_Guardabosques.png"
		elif "Bram" in npc_nombre or "Constructor" in npc_nombre:
			ruta = "res://assets/nivel_2/personajes/Gato_Constructor.png"
		else:
			var escena_nombre = get_tree().current_scene.name if get_tree().current_scene else ""
			if "Puente" in escena_nombre:
				ruta = "res://assets/nivel_2/personajes/Gato_Constructor.png"
			elif "Sendero" in escena_nombre:
				ruta = "res://assets/nivel_2/personajes/Gato_Rastreador.png"
			elif "Bayas" in escena_nombre:
				ruta = "res://assets/nivel_2/personajes/Gata_Recolectora.png"
			elif "Linterna" in escena_nombre:
				ruta = "res://assets/nivel_2/personajes/Gato_Guia.png"
			elif "Guardabosques" in escena_nombre:
				ruta = "res://assets/nivel_2/personajes/Gato_Guardabosques.png"
	
	if not ruta.is_empty() and ResourceLoader.exists(ruta):
		var res = load(ruta) as Texture2D
		if res != null:
			return res
	
	if npc_portrait != null:
		return npc_portrait
	
	var global_path = ProjectSettings.globalize_path(ruta)
	if FileAccess.file_exists(global_path):
		var img = Image.new()
		if img.load(global_path) == OK:
			return ImageTexture.create_from_image(img)
	
	return null

func _resolver_referencias() -> void:
	jugador = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if jugador == null:
		var root = get_parent()
		if root:
			jugador = root.get_node_or_null("Player") as CharacterBody2D
	
	letra_e = get_node_or_null("LetraE") as Label
	altar_objetivo = get_parent().get_node_or_null("AltarRunico") if get_parent() else null
	
	if letra_e:
		letra_e.visible = false
		letra_e.z_index = 10
	
	var tex_retrato = _obtener_retrato_seguro()
	if retrato_npc and tex_retrato:
		retrato_npc.texture = tex_retrato
	
	print("InteraccionGatoN2 [%s]: Referencias resueltas. Retrato = %s" % [npc_nombre, str(tex_retrato)])

func _cargar_dialogo() -> void:
	if dialog_file.is_empty():
		return
	if not FileAccess.file_exists(dialog_file):
		push_warning("InteraccionGatoN2: No se encontró archivo de diálogo: " + dialog_file)
		return
	var file = FileAccess.open(dialog_file, FileAccess.READ)
	if file == null:
		return
	var texto = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var err = json.parse(texto)
	if err == OK:
		var data = json.get_data()
		lineas_dialogo = data.get("lines", [])
		lineas_outro = data.get("outro_lines", [])
		if data.has("npc_name"):
			npc_nombre = data.get("npc_name")

func _crear_ui_dialogo() -> void:
	dialogo_canvas = CanvasLayer.new()
	dialogo_canvas.layer = 15
	add_child(dialogo_canvas)
	
	fondo_dialogo = ColorRect.new()
	fondo_dialogo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fondo_dialogo.color = Color(0.02, 0.04, 0.08, 0.6)
	fondo_dialogo.visible = false
	dialogo_canvas.add_child(fondo_dialogo)
	
	# Retrato del Jugador (Izquierda, estilo Nivel 3)
	retrato_jugador = TextureRect.new()
	retrato_jugador.position = Vector2(90, 130)
	retrato_jugador.size = Vector2(300, 310)
	retrato_jugador.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	retrato_jugador.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	retrato_jugador.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	var tex_jugador: Texture2D = null
	var rutas_jugador = [
		"res://assets/nivel_3/personajes/09919c97-0761-4ec0-abaf-848cac69190d.png",
		"res://assets/player/player_portrait.png",
		"res://icon.png"
	]
	for ruta in rutas_jugador:
		if ResourceLoader.exists(ruta):
			tex_jugador = load(ruta)
			break
	if tex_jugador:
		retrato_jugador.texture = tex_jugador
	retrato_jugador.visible = false
	dialogo_canvas.add_child(retrato_jugador)
	
	# Retrato del NPC (Derecha, estilo Nivel 3, centrado en pantalla de 1152)
	retrato_npc = TextureRect.new()
	retrato_npc.position = Vector2(762, 130)
	retrato_npc.size = Vector2(300, 310)
	retrato_npc.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	retrato_npc.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	retrato_npc.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var ret_tex = _obtener_retrato_seguro()
	if ret_tex:
		retrato_npc.texture = ret_tex
	elif npc_portrait:
		retrato_npc.texture = npc_portrait
	elif sprite_npc and sprite_npc.texture:
		retrato_npc.texture = sprite_npc.texture
	retrato_npc.visible = false
	dialogo_canvas.add_child(retrato_npc)
	
	# Caja de Diálogo (Centrada abajo)
	caja_dialogo = PanelContainer.new()
	caja_dialogo.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	caja_dialogo.offset_left = 110
	caja_dialogo.offset_right = -110
	caja_dialogo.offset_top = -225
	caja_dialogo.offset_bottom = -30
	
	estilo_caja = StyleBoxFlat.new()
	estilo_caja.bg_color = COLOR_FONDO_CAJA
	estilo_caja.border_color = COLOR_NPC_CIAN
	estilo_caja.set_border_width_all(3)
	estilo_caja.set_corner_radius_all(16)
	estilo_caja.content_margin_left = 26
	estilo_caja.content_margin_top = 18
	estilo_caja.content_margin_right = 26
	estilo_caja.content_margin_bottom = 18
	caja_dialogo.add_theme_stylebox_override("panel", estilo_caja)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	caja_dialogo.add_child(vbox)
	
	label_hablante = Label.new()
	label_hablante.add_theme_font_size_override("font_size", 22)
	label_hablante.add_theme_color_override("font_color", COLOR_NPC_CIAN)
	vbox.add_child(label_hablante)
	
	label_texto = Label.new()
	label_texto.add_theme_font_size_override("font_size", 19)
	label_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(label_texto)
	
	var fila_footer = HBoxContainer.new()
	fila_footer.mouse_filter = Control.MOUSE_FILTER_PASS
	vbox.add_child(fila_footer)
	
	label_continuar = Label.new()
	label_continuar.text = "Presiona E, Espacio o haz clic para continuar"
	label_continuar.add_theme_font_size_override("font_size", 14)
	label_continuar.add_theme_color_override("font_color", Color(0.68, 0.73, 0.82))
	label_continuar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila_footer.add_child(label_continuar)
	
	var btn_avanzar = Button.new()
	btn_avanzar.text = "Continuar ➔"
	btn_avanzar.custom_minimum_size = Vector2(140, 32)
	btn_avanzar.mouse_filter = Control.MOUSE_FILTER_STOP
	btn_avanzar.focus_mode = Control.FOCUS_ALL
	btn_avanzar.pressed.connect(avanzar_dialogo)
	fila_footer.add_child(btn_avanzar)
	
	caja_dialogo.visible = false
	caja_dialogo.mouse_filter = Control.MOUSE_FILTER_STOP
	caja_dialogo.gui_input.connect(_on_caja_dialogo_gui_input)
	fondo_dialogo.mouse_filter = Control.MOUSE_FILTER_STOP
	fondo_dialogo.gui_input.connect(_on_caja_dialogo_gui_input)
	dialogo_canvas.add_child(caja_dialogo)

func _on_caja_dialogo_gui_input(event: InputEvent) -> void:
	if dialogo_activo and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		avanzar_dialogo()

func _process(_delta: float) -> void:
	if jugador == null:
		jugador = get_tree().get_first_node_in_group("player") as CharacterBody2D
		return
	
	var dist = global_position.distance_to(jugador.global_position)
	var cerca_ahora = dist < RADIO_DETECCION
	
	if cerca_ahora != jugador_cerca:
		jugador_cerca = cerca_ahora
		if letra_e:
			letra_e.visible = cerca_ahora and not dialogo_activo and not dialogo_terminado

func _unhandled_input(event: InputEvent) -> void:
	# Si el diálogo está activo, permitir avanzar SIEMPRE sin importar la distancia al NPC
	if dialogo_activo:
		var es_avanzar = event.is_action_pressed("interact") or \
			event.is_action_pressed("ui_accept") or \
			event.is_action_pressed("ui_cancel") or \
			(event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_E or event.keycode == KEY_SPACE or event.keycode == KEY_ENTER or event.keycode == KEY_ESCAPE)) or \
			(event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)
		
		if es_avanzar:
			get_viewport().set_input_as_handled()
			avanzar_dialogo()
		return
	
	if not jugador_cerca:
		return
	if dialogo_terminado and not dialogo_activo:
		return
	
	var es_interaccion = event.is_action_pressed("interact") or \
		(event is InputEventKey and event.pressed and event.keycode == KEY_E and not event.echo) or \
		(event is InputEventKey and event.pressed and event.keycode == KEY_SPACE and not event.echo)
	
	if es_interaccion:
		get_viewport().set_input_as_handled()
		if lineas_dialogo.size() > 0:
			iniciar_dialogo(false)

func iniciar_dialogo(usar_outro: bool = false) -> void:
	usando_outro = usar_outro
	dialogo_activo = true
	indice_linea = 0
	
	if letra_e:
		letra_e.visible = false
	if jugador:
		jugador.set_physics_process(false)
		jugador.velocity = Vector2.ZERO
	
	if retrato_npc:
		var tex_ret = _obtener_retrato_seguro()
		if tex_ret:
			retrato_npc.texture = tex_ret
	
	fondo_dialogo.visible = true
	caja_dialogo.visible = true
	retrato_jugador.visible = true
	retrato_npc.visible = true
	
	mostrar_linea_actual()

func mostrar_linea_actual() -> void:
	var lista: Array = lineas_outro if usando_outro else lineas_dialogo
	if indice_linea >= lista.size():
		finalizar_dialogo()
		return
	
	var data = lista[indice_linea]
	var hablante: String = data.get("speaker", "???")
	var texto: String = data.get("text", "")
	
	label_hablante.text = hablante.to_upper()
	label_texto.text = texto
	
	# Alternancia idéntica al Nivel 3: Ilumina al hablante activo y oscurece al oyente
	if hablante == "Jugador" or hablante == "Protagonista":
		retrato_jugador.modulate = COLOR_ILUMINADO
		retrato_npc.modulate = COLOR_OSCURO
		label_hablante.add_theme_color_override("font_color", COLOR_PROTAGONISTA)
		if estilo_caja:
			estilo_caja.border_color = COLOR_PROTAGONISTA
	else:
		retrato_npc.modulate = COLOR_ILUMINADO
		retrato_jugador.modulate = COLOR_OSCURO
		label_hablante.add_theme_color_override("font_color", COLOR_NPC_CIAN)
		if estilo_caja:
			estilo_caja.border_color = COLOR_NPC_CIAN

func avanzar_dialogo() -> void:
	indice_linea += 1
	mostrar_linea_actual()

func finalizar_dialogo() -> void:
	dialogo_activo = false
	fondo_dialogo.visible = false
	caja_dialogo.visible = false
	retrato_jugador.visible = false
	retrato_npc.visible = false
	
	if jugador:
		jugador.set_physics_process(true)
		jugador.set_process_unhandled_input(true)
		jugador.set_process_input(true)
	
	if not usando_outro:
		dialogo_terminado = true
		dialogo_finalizado.emit()
		if altar_objetivo == null:
			altar_objetivo = get_parent().get_node_or_null("AltarRunico") if get_parent() else null
		if altar_objetivo and altar_objetivo.has_method("activar_altar"):
			altar_objetivo.activar_altar()
		print("InteraccionGatoN2 [%s]: Diálogo finalizado. Altar desbloqueado." % npc_nombre)
	else:
		print("InteraccionGatoN2 [%s]: Diálogo outro completado." % npc_nombre)
