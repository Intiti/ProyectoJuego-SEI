extends PanelContainer

# ==========================================
# MGTS - PANTALLA FINAL DE FELICITACIÓN
# Compatible con ambas variantes de Final.tscn
# ==========================================

@export_file("*.tscn") var escena_menu: String = "res://scenes/common/ui/MainMenu.tscn"
@export_file("*.tscn") var escena_inicio: String = "res://scenes/Nivel_3/1Entrada del Laboratorio.tscn"

@onready var nombre_juego: Label = get_node_or_null("ContenidoFinal/EncabezadoFinal/NombreJuego") as Label
@onready var estado_final: Label = get_node_or_null("ContenidoFinal/EncabezadoFinal/EstadoFinal") as Label
@onready var icono_trofeo: TextureRect = get_node_or_null("ContenidoFinal/IconoTrofeo") as TextureRect
@onready var titulo_final: Label = get_node_or_null("ContenidoFinal/TituloFinal") as Label
@onready var subtitulo_final: Label = get_node_or_null("ContenidoFinal/SubtituloFinal") as Label
@onready var mensaje_final: Label = get_node_or_null("ContenidoFinal/MensajeFinal") as Label

@onready var puntos_nivel_1: Label = get_node_or_null("ContenidoFinal/PuntosNivel1") as Label
@onready var puntos_nivel_2: Label = get_node_or_null("ContenidoFinal/PuntosNivel2") as Label
@onready var puntos_nivel_3: Label = get_node_or_null("ContenidoFinal/PuntosNivel3") as Label
@onready var puntos_totales: Label = get_node_or_null("ContenidoFinal/PuntosTotales") as Label

@onready var oscurecer_fondo: CanvasItem = get_node_or_null("../OscurecerFondo") as CanvasItem
@onready var abrazo_final: CanvasItem = get_node_or_null("../AbrazoFinal") as CanvasItem

@onready var sistema_puntos: Node = get_node_or_null("/root/PuntajesNivel3")
@onready var dj_manager: Node = get_node_or_null("/root/DJManager")

var titulo_insignias: Label = null
var contenedor_insignias: Node = null
var boton_jugar_nuevo: Button = null
var boton_volver_menu: Button = null
var resumen_ejercicios: Label = null
var ranking_general: Label = null
var contenido_resumen: VBoxContainer = null


func _ready() -> void:
	_resolver_nodos_compatibles()
	hide()
	if oscurecer_fondo != null:
		oscurecer_fondo.hide()
	if abrazo_final != null:
		abrazo_final.hide()

	_configurar_panel_general()
	configurar_textos()
	conectar_botones()
	actualizar_puntos_finales()
	print("MGTS: ventana final preparada.")


func _resolver_nodos_compatibles() -> void:
	titulo_insignias = get_node_or_null("ContenidoFinal/TituloInsignias") as Label
	if titulo_insignias == null:
		titulo_insignias = get_node_or_null("ContenidoFinal/SeccionInsignias/TituloInsignias") as Label

	contenedor_insignias = get_node_or_null("ContenidoFinal/InsigniasGanadas")
	if contenedor_insignias == null:
		contenedor_insignias = get_node_or_null("ContenidoFinal/SeccionInsignias/InsigniasGanadas")

	boton_jugar_nuevo = get_node_or_null("ContenidoFinal/BotonesFinal/BotonReiniciar") as Button
	if boton_jugar_nuevo == null:
		boton_jugar_nuevo = get_node_or_null("ContenidoFinal/BotonesFinales/BotonJugarNuevo") as Button

	boton_volver_menu = get_node_or_null("ContenidoFinal/BotonesFinal/BotonMenu") as Button
	if boton_volver_menu == null:
		boton_volver_menu = get_node_or_null("ContenidoFinal/BotonesFinales/BotonVolverMenu") as Button


func configurar_textos() -> void:
	if nombre_juego != null:
		nombre_juego.text = "MIAUGORITMOS (MGTS)"
	if estado_final != null:
		estado_final.text = "RESUMEN GENERAL"
	if titulo_final != null:
		titulo_final.text = "RESUMEN DE MIAUGORITMOS"
	if subtitulo_final != null:
		subtitulo_final.text = "¡Has rescatado a Panko!"
	if mensaje_final != null:
		mensaje_final.text = (
			"¡HAS RESCATADO A PANKO!\n"
			+ "Superaste el complejo subterráneo dominando condicionales, operadores lógicos y ciclos en Python."
		)
	if titulo_insignias != null:
		titulo_insignias.text = "INSIGNIAS OBTENIDAS (Pasa el cursor sobre cada insignia)"
	if boton_jugar_nuevo != null:
		boton_jugar_nuevo.text = "Jugar de nuevo"
	if boton_volver_menu != null:
		boton_volver_menu.text = "Volver al menú"


func conectar_botones() -> void:
	if boton_jugar_nuevo != null:
		if not boton_jugar_nuevo.pressed.is_connected(jugar_de_nuevo):
			boton_jugar_nuevo.pressed.connect(jugar_de_nuevo)
	else:
		push_warning("MGTS: no se encontró botón de reinicio en VentanaFinal.")

	if boton_volver_menu != null:
		if not boton_volver_menu.pressed.is_connected(volver_al_menu):
			boton_volver_menu.pressed.connect(volver_al_menu)
	else:
		push_warning("MGTS: no se encontró botón de menú en VentanaFinal.")


func mostrar_final() -> void:
	mostrar_ventana_final()


func mostrar_ventana_final() -> void:
	# La escena del rescate confirma este estado; abrir un panel no lo inventa.
	if sistema_puntos == null or not sistema_puntos.has_method("obtener_resumen_general") or not bool(sistema_puntos.call("obtener_resumen_general").niveles[2].get("rescate_confirmado", false)):
		hide()
		return
	if dj_manager != null and dj_manager.has_method("play_music"):
		dj_manager.call("play_music", "victoria")
	if oscurecer_fondo != null:
		oscurecer_fondo.show()
	if abrazo_final != null:
		abrazo_final.show()
	actualizar_puntos_finales()
	show()


func actualizar_puntos_finales() -> void:
	if sistema_puntos == null or not sistema_puntos.has_method("obtener_resumen_general"):
		if titulo_final != null:
			titulo_final.text = "RESUMEN DE MIAUGORITMOS"
		return
	var resumen: Dictionary = sistema_puntos.call("obtener_resumen_general")
	var completo: bool = bool(resumen.juego_completo)
	if titulo_final != null:
		titulo_final.text = "¡FELICIDADES, COMPLETASTE MIAUGORITMOS!" if completo else "RESUMEN DE MIAUGORITMOS"
	if estado_final != null:
		estado_final.text = "JUEGO COMPLETADO" if completo else "PROGRESO PENDIENTE"
	if mensaje_final != null:
		mensaje_final.text = "¡Panko está a salvo!" if bool(resumen.niveles[2].get("rescate_confirmado", false)) else "Continúa la aventura para rescatar a Panko."
	var etiquetas: Array = [puntos_nivel_1, puntos_nivel_2, puntos_nivel_3]
	for i in range(3):
		var datos: Dictionary = resumen.niveles[i]
		var progreso: String = "%d/%d ejercicios" % [int(datos.completados), int(datos.total)] if datos.get("completados") != null and datos.get("total") != null else "progreso pendiente"
		var puntos: String = "%d puntos" % int(datos.puntos) if datos.get("puntos") != null else "puntaje pendiente"
		if etiquetas[i] != null:
			etiquetas[i].show()
			etiquetas[i].text = "Nivel %d · %s · %s" % [i + 1, progreso, puntos]
	if puntos_totales != null:
		puntos_totales.text = "PUNTAJE TOTAL DE MIAUGORITMOS: %d PUNTOS" % int(resumen.puntos) if resumen.puntos != null else "PUNTAJE TOTAL DE MIAUGORITMOS: PENDIENTE\nSubtotal disponible: %d puntos" % int(resumen.subtotal_conocido)
	if resumen_ejercicios != null:
		resumen_ejercicios.text = "Total: %d/%d ejercicios" % [int(resumen.completados), int(resumen.total)] if resumen.progreso_completo else "Ejercicios registrados: %d/%d · otros niveles pendientes" % [int(resumen.completados), int(resumen.total)]
	if titulo_insignias != null:
		titulo_insignias.text = "INSIGNIAS OBTENIDAS: %d · pendientes oscurecidas" % resumen.insignias.size()
	if contenedor_insignias != null and contenedor_insignias.has_method("actualizar_insignias"):
		contenedor_insignias.call("actualizar_insignias")
	sistema_puntos.call("registrar_resumen_en_ranking_general")
	if ranking_general != null:
		var entradas: Array = sistema_puntos.call("obtener_ranking_general")
		var lineas: Array[String] = ["RANKING GENERAL"]
		for i in range(mini(3, entradas.size())):
			var nombre: String = "Tú" if entradas[i].idJugador == sistema_puntos.call("obtener_id_jugador") else "Participante %d" % (i + 1)
			lineas.append("#%d · %s · %d puntos" % [i + 1, nombre, int(entradas[i].puntaje)])
		if entradas.is_empty():
			lineas.append("Pendiente: integrar los resultados completos de los tres niveles.")
		ranking_general.text = "\n".join(lineas)
	_ajustar_panel_general.call_deferred()


func _configurar_panel_general() -> void:
	contenido_resumen = get_node_or_null("ContenidoFinal") as VBoxContainer
	if contenido_resumen == null:
		return
	contenido_resumen.add_theme_constant_override("separation", 8)
	for hijo in contenido_resumen.get_children():
		if hijo is Label:
			hijo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			hijo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			hijo.add_theme_font_size_override("font_size", 18)
	if titulo_final != null:
		titulo_final.add_theme_font_size_override("font_size", 26)
	if icono_trofeo != null:
		icono_trofeo.custom_minimum_size = Vector2(48, 48)
		icono_trofeo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	resumen_ejercicios = _crear_etiqueta_resumen("ResumenEjercicios")
	contenido_resumen.move_child(resumen_ejercicios, puntos_totales.get_index() if puntos_totales != null else 0)
	ranking_general = _crear_etiqueta_resumen("RankingGeneral")
	contenido_resumen.move_child(ranking_general, maxi(0, contenido_resumen.get_child_count() - 2))
	for boton in [boton_jugar_nuevo, boton_volver_menu]:
		if boton != null:
			boton.add_theme_font_size_override("font_size", 18)
	var scroll := ScrollContainer.new()
	scroll.name = "ScrollResumenGeneral"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	add_child(scroll)
	contenido_resumen.reparent(scroll)
	contenido_resumen.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2.ZERO
	get_viewport().size_changed.connect(_ajustar_panel_general)
	_ajustar_panel_general()


func _crear_etiqueta_resumen(nombre: String) -> Label:
	var etiqueta := Label.new()
	etiqueta.name = nombre
	etiqueta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta.add_theme_font_size_override("font_size", 16)
	contenido_resumen.add_child(etiqueta)
	return etiqueta


func _ajustar_panel_general() -> void:
	if contenido_resumen == null:
		return
	var ventana := get_viewport_rect().size
	var ancho: float = minf(700.0, ventana.x * 0.52)
	var alto: float = minf(ventana.y - 88.0, maxf(440.0, contenido_resumen.get_combined_minimum_size().y + 32.0))
	set_anchors_preset(Control.PRESET_TOP_RIGHT)
	offset_left = -ancho - 24.0
	offset_right = -24.0
	offset_top = (ventana.y - alto) / 2.0
	offset_bottom = offset_top + alto


func jugar_de_nuevo() -> void:
	if sistema_puntos != null and sistema_puntos.has_method("reiniciar_puntajes"):
		sistema_puntos.call("reiniciar_puntajes")

	var ruta_destino: String = escena_inicio if escena_inicio != "" else "res://scenes/Nivel_3/1Entrada del Laboratorio.tscn"
	get_tree().change_scene_to_file(ruta_destino)


func volver_al_menu() -> void:
	var ruta_menu: String = escena_menu if escena_menu != "" else "res://scenes/common/ui/MainMenu.tscn"
	if not ResourceLoader.exists(ruta_menu):
		ruta_menu = "res://scenes/common/ui/MainMenu.tscn"
	get_tree().change_scene_to_file(ruta_menu)
