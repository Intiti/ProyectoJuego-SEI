extends PanelContainer

# ==========================================
# MGTS - NIVEL 3
# CLASE BASE REUTILIZABLE PARA LOS 10 EJERCICIOS (E3.1 A E3.10)
# Sistema visual de bloques interactivos, indentación Python,
# acceso al Manual, pistas progresivas y validación de casos.
# ==========================================

signal ejercicio_resuelto(errores: int)

var nombre_nivel: Label = null
var puntos_nivel: Label = null
var titulo: Label = null
var boton_cerrar: Button = null
var instrucciones: Label = null
var boton_pista: Button = null
var panel_pista: PanelContainer = null
var texto_pista: Label = null
var titulo_construccion: Label = null
var lista_algoritmo: VBoxContainer = null
var codigo_ordenado: Label = null
var mensaje_resultado: Label = null
var boton_reiniciar: Button = null
var boton_ejecutar: Button = null
var panel_bloques: Control = null

@onready var ventana_completado: Control = get_node_or_null("../../CompletadoUI/VentanaCompletado") as Control
@onready var consola: Node = get_node_or_null("../../InteraccionConsola")
@onready var puerta_seguridad: Node = get_node_or_null("../../PuertaSeguridad")
@onready var sistema_puntos: Node = get_node_or_null("/root/PuntajesNivel3")
@onready var dj_manager: Node = get_node_or_null("/root/DJManager")

var botones_bloques: Array[Button] = []
var bloques_texto_original: Dictionary = {}
var bloques_colocados: Array[String] = []
var errores: int = 0
var id_intento_insignia: int = -1
var boton_repetir_insignia: Button = null
var estado_insignia: Label = null
var repeticion_sin_puntos: bool = false
var intentos_realizados: int = 0
var pistas_usadas: int = 0
var resuelto: bool = false
var validando_intento: bool = false
var ultimo_tipo_error: String = ""
var tiempo_inicio_intento_ms: int = 0


# Métodos virtuales que cada ejercicio E3.1..E3.10 proporciona o sobrescribe
func _obtener_id_ejercicio() -> String:
	return get("ID_EJERCICIO") if "ID_EJERCICIO" in self else "E3.1"

func _obtener_titulo_ejercicio() -> String:
	return get("TITULO_EJERCICIO") if "TITULO_EJERCICIO" in self else "Ejercicio Nivel 3"

func _obtener_instruccion_ejercicio() -> String:
	return get("DESCRIPCION_EJERCICIO") if "DESCRIPCION_EJERCICIO" in self else ""

func _obtener_total_espacios() -> int:
	return int(get("TOTAL_ESPACIOS")) if "TOTAL_ESPACIOS" in self else 4

func _obtener_puntos_por_bloque() -> int:
	return int(get("PUNTOS_POR_BLOQUE")) if "PUNTOS_POR_BLOQUE" in self else 60

func _obtener_plantilla_codigo() -> String:
	return get("PLANTILLA_CODIGO") if "PLANTILLA_CODIGO" in self else ""

func _obtener_respuesta_correcta() -> Array:
	return get("RESPUESTA_CORRECTA") if "RESPUESTA_CORRECTA" in self else []

func _obtener_bloques_disponibles() -> Array:
	return get("BLOQUES_DISPONIBLES") if "BLOQUES_DISPONIBLES" in self else []

func _obtener_tipos_error() -> Dictionary:
	return get("TIPOS_ERROR") if "TIPOS_ERROR" in self else {}

func _obtener_mensajes_error() -> Dictionary:
	return get("MENSAJES_ERROR") if "MENSAJES_ERROR" in self else {}

func _obtener_pistas() -> Dictionary:
	return get("PISTAS") if "PISTAS" in self else {}


func _ready() -> void:
	hide()
	if not comprobar_nodos():
		push_error(_obtener_id_ejercicio() + ": faltan nodos en VentanaEjercicio.")
		return
	configurar_interfaz()
	conectar_botones()
	preparar_bloques()
	_configurar_distribucion_adaptable()
	_preparar_repeticion_insignia()
	iniciar_ejercicio()
	print(_obtener_id_ejercicio() + ": ventana de ejercicio preparada.")


func comprobar_nodos() -> bool:
	_vincular_nodos_compatibles()
	return not (
		titulo == null or boton_cerrar == null or instrucciones == null
		or boton_pista == null or panel_pista == null or texto_pista == null
		or titulo_construccion == null or codigo_ordenado == null
		or mensaje_resultado == null or boton_reiniciar == null
		or boton_ejecutar == null or panel_bloques == null
	)


func _vincular_nodos_compatibles() -> void:
	nombre_nivel = get_node_or_null("Contenido/Encabezado/NombreNivel") as Label
	puntos_nivel = get_node_or_null("Contenido/Encabezado/PuntosNivel") as Label
	titulo = get_node_or_null("ContenidoEjercicio/FilaTitulo/TituloEjercicio") as Label
	if titulo == null:
		titulo = get_node_or_null("Contenido/FilaTitulo/Titulo") as Label

	var fila_titulo: HBoxContainer = get_node_or_null("ContenidoEjercicio/FilaTitulo") as HBoxContainer
	if fila_titulo != null and puntos_nivel == null and titulo != null:
		titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		puntos_nivel = fila_titulo.get_node_or_null("PuntosNivel") as Label
		if puntos_nivel == null:
			puntos_nivel = Label.new()
			puntos_nivel.name = "PuntosNivel"
			puntos_nivel.add_theme_color_override("font_color", Color("#FBBF24"))
			puntos_nivel.add_theme_font_size_override("font_size", 16)
			fila_titulo.add_child(puntos_nivel)

	instrucciones = get_node_or_null("ContenidoEjercicio/FilaInstrucciones/InstruccionesEjercicio") as Label
	if instrucciones == null:
		instrucciones = get_node_or_null("Contenido/FilaInstrucciones/Instrucciones") as Label

	panel_pista = get_node_or_null("ContenidoEjercicio/FilaInstrucciones/PanelPista") as PanelContainer
	if panel_pista == null:
		panel_pista = get_node_or_null("Contenido/PanelPista") as PanelContainer

	texto_pista = get_node_or_null("ContenidoEjercicio/FilaInstrucciones/PanelPista/ContenidoPista/TextoPista") as Label
	if texto_pista == null:
		texto_pista = get_node_or_null("Contenido/PanelPista/ContenidoPista/TextoPista") as Label

	titulo_construccion = get_node_or_null("ContenidoEjercicio/ColumnasEjercicio/AreaAlgoritmo/TituloAlgoritmo") as Label
	if titulo_construccion == null:
		titulo_construccion = get_node_or_null("Contenido/PanelConstruccion/ContenidoConstruccion/TituloConstruccion") as Label

	lista_algoritmo = get_node_or_null("ContenidoEjercicio/ColumnasEjercicio/AreaAlgoritmo/PanelAlgoritmo/ListaAlgoritmo") as VBoxContainer
	codigo_ordenado = get_node_or_null("ContenidoEjercicio/ColumnasEjercicio/AreaAlgoritmo/PanelAlgoritmo/ListaAlgoritmo/MensajeVacio") as Label
	if codigo_ordenado == null:
		codigo_ordenado = get_node_or_null("Contenido/PanelConstruccion/ContenidoConstruccion/CodigoOrdenado") as Label

	mensaje_resultado = get_node_or_null("ContenidoEjercicio/MensajeResultado") as Label
	if mensaje_resultado == null:
		mensaje_resultado = get_node_or_null("Contenido/MensajeResultado") as Label

	boton_reiniciar = get_node_or_null("ContenidoEjercicio/BotonesEjercicio/BotonLimpiar") as Button
	if boton_reiniciar == null:
		boton_reiniciar = get_node_or_null("Contenido/BotonesAccion/BotonReiniciar") as Button

	boton_ejecutar = get_node_or_null("ContenidoEjercicio/BotonesEjercicio/BotonComprobar") as Button
	if boton_ejecutar == null:
		boton_ejecutar = get_node_or_null("Contenido/BotonesAccion/BotonEjecutar") as Button

	boton_cerrar = get_node_or_null("ContenidoEjercicio/BotonesEjercicio/BotonCerrar") as Button
	if boton_cerrar == null:
		boton_cerrar = get_node_or_null("Contenido/FilaTitulo/BotonCerrar") as Button

	boton_pista = get_node_or_null("Contenido/FilaInstrucciones/BotonPista") as Button
	var botones_ej: HBoxContainer = get_node_or_null("ContenidoEjercicio/BotonesEjercicio") as HBoxContainer
	if boton_pista == null and botones_ej != null:
		boton_pista = botones_ej.get_node_or_null("BotonPista") as Button
		if boton_pista == null:
			boton_pista = Button.new()
			boton_pista.name = "BotonPista"
			botones_ej.add_child(boton_pista)
			botones_ej.move_child(boton_pista, 1)

	if botones_ej != null:
		botones_ej.alignment = BoxContainer.ALIGNMENT_CENTER
		botones_ej.add_theme_constant_override("separation", 12)
		for boton in [boton_reiniciar, boton_pista, boton_ejecutar, boton_cerrar]:
			if boton != null and boton.get_parent() == botones_ej:
				boton.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
				boton.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	panel_bloques = get_node_or_null("ContenidoEjercicio/ColumnasEjercicio/PanelBloques/BloquesDisponibles/ListaBloques") as Control
	if panel_bloques == null:
		panel_bloques = get_node_or_null("Contenido/PanelBloques") as Control


func configurar_interfaz() -> void:
	if nombre_nivel != null:
		nombre_nivel.text = "NIVEL 3 – COMPLEJO SUBTERRÁNEO"
	titulo.text = _obtener_titulo_ejercicio()
	instrucciones.text = _obtener_instruccion_ejercicio()
	instrucciones.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	titulo_construccion.text = "CONSTRUCCIÓN DEL ALGORITMO"
	titulo_construccion.tooltip_text = "Haz clic en un bloque colocado para quitarlo."
	mensaje_resultado.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto_pista.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	_estilizar_boton_accion(boton_reiniciar, "↺ Reiniciar", Color("#334155"), Color("#64748B"))
	_estilizar_boton_accion(boton_pista, "💡 Pista", Color("#78350F"), Color("#F59E0B"))
	_estilizar_boton_accion(boton_ejecutar, "▶ Comprobar", Color("#065F46"), Color("#34D399"))
	_estilizar_boton_accion(boton_cerrar, "✕ Cerrar", Color("#7F1D1D"), Color("#F87171"))

	panel_pista.hide()
	actualizar_puntos_encabezado()


# Solo presentación: conservar referencias y conexiones al envolver los contenedores.
func _configurar_distribucion_adaptable() -> void:
	var contenido := get_node_or_null("ContenidoEjercicio") as VBoxContainer
	if contenido == null or lista_algoritmo == null:
		return
	var columnas := contenido.get_node_or_null("ColumnasEjercicio") as HBoxContainer
	if columnas == null:
		return
	var panel_opciones := columnas.get_node_or_null("PanelBloques") as PanelContainer
	var area_algoritmo := columnas.get_node_or_null("AreaAlgoritmo") as VBoxContainer
	if panel_opciones == null or area_algoritmo == null:
		return
	var panel_algoritmo := area_algoritmo.get_node_or_null("PanelAlgoritmo") as PanelContainer
	if panel_opciones == null or panel_algoritmo == null:
		return

	# El panel exterior no debe heredar el alto mínimo de todo el código.
	custom_minimum_size = Vector2.ZERO
	var fondo := get_theme_stylebox("panel").duplicate() as StyleBox
	for lado in ["left", "right", "top", "bottom"]:
		fondo.set("content_margin_" + lado, 16.0)
	add_theme_stylebox_override("panel", fondo)
	contenido.add_theme_constant_override("separation", 8)
	contenido.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contenido.custom_minimum_size = Vector2.ZERO
	columnas.add_theme_constant_override("separation", 16)
	columnas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if "custom_maximum_size" in columnas:
		columnas.set("custom_maximum_size", Vector2(-1, -1))
	panel_opciones.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel_opciones.size_flags_stretch_ratio = 0.42
	area_algoritmo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	area_algoritmo.size_flags_stretch_ratio = 0.58
	area_algoritmo.custom_minimum_size = Vector2.ZERO
	area_algoritmo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel_opciones.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel_algoritmo.custom_minimum_size = Vector2.ZERO
	panel_algoritmo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var disponibles := panel_bloques.get_parent() as VBoxContainer
	disponibles.size_flags_vertical = Control.SIZE_EXPAND_FILL
	disponibles.add_theme_constant_override("separation", 6)
	for panel in [panel_opciones, panel_algoritmo]:
		var estilo := panel.get_theme_stylebox("panel").duplicate() as StyleBox
		for lado in ["left", "right", "top", "bottom"]:
			estilo.set("content_margin_" + lado, 8.0)
		panel.add_theme_stylebox_override("panel", estilo)
	for etiqueta in [titulo, instrucciones, texto_pista, titulo_construccion, mensaje_resultado]:
		etiqueta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		etiqueta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	instrucciones.add_theme_font_size_override("font_size", 16)
	texto_pista.add_theme_font_size_override("font_size", 15)
	mensaje_resultado.add_theme_font_size_override("font_size", 15)
	titulo_construccion.add_theme_font_size_override("font_size", 16)
	var titulo_bloques := disponibles.get_node_or_null("TituloBloques") as Label
	if titulo_bloques != null:
		titulo_bloques.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		titulo_bloques.add_theme_font_size_override("font_size", 16)

	for boton in botones_bloques:
		boton.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		boton.clip_text = false
		boton.alignment = HORIZONTAL_ALIGNMENT_LEFT
		boton.custom_minimum_size = Vector2(0, 28)
		boton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel_bloques.add_theme_constant_override("separation", 3)
	# Las dos cabeceras quedan dentro de paneles con la misma altura y márgenes.
	var interior_algoritmo := VBoxContainer.new()
	interior_algoritmo.name = "ContenidoAlgoritmoVisual"
	interior_algoritmo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	interior_algoritmo.add_theme_constant_override("separation", 6)
	panel_algoritmo.add_child(interior_algoritmo)
	titulo_construccion.reparent(interior_algoritmo)
	lista_algoritmo.reparent(interior_algoritmo)
	var fila_botones := contenido.get_node_or_null("BotonesEjercicio") as HBoxContainer
	if fila_botones != null:
		var margen_botones := MarginContainer.new()
		margen_botones.name = "MargenBotonesEjercicio"
		margen_botones.add_theme_constant_override("margin_top", 8)
		margen_botones.add_theme_constant_override("margin_bottom", 4)
		var posicion_botones: int = fila_botones.get_index()
		contenido.add_child(margen_botones)
		contenido.move_child(margen_botones, posicion_botones)
		fila_botones.reparent(margen_botones)
	_configurar_encabezado_visual(contenido)
	_envolver_lista_desplazable(panel_bloques, "ScrollBloques")
	_envolver_lista_desplazable(lista_algoritmo, "ScrollAlgoritmo")

	# También permite llegar a las acciones si las pistas ocupan más alto.
	_envolver_lista_desplazable(contenido, "ScrollEjercicio")
	_ajustar_alto_columnas(columnas)
	get_viewport().size_changed.connect(_ajustar_alto_columnas.bind(columnas))
	resized.connect(_ajustar_alto_columnas.bind(columnas))
	for etiqueta in [titulo, instrucciones, texto_pista, mensaje_resultado]:
		etiqueta.minimum_size_changed.connect(_programar_ajuste_columnas.bind(columnas))
	panel_pista.visibility_changed.connect(_programar_ajuste_columnas.bind(columnas))


func _programar_ajuste_columnas(columnas: HBoxContainer) -> void:
	_ajustar_alto_columnas.call_deferred(columnas)


func _ajustar_alto_columnas(columnas: HBoxContainer) -> void:
	if not is_instance_valid(columnas):
		return
	var contenido := columnas.get_parent() as VBoxContainer
	var otros_altos: float = 0.0
	var visibles: int = 0
	for hijo in contenido.get_children():
		if hijo is Control and hijo.visible:
			visibles += 1
			if hijo != columnas:
				otros_altos += hijo.get_combined_minimum_size().y
	var separaciones: float = max(0, visibles - 1) * contenido.get_theme_constant("separation")
	var alto_util: float = maxf(160.0, size.y - 32.0 - otros_altos - separaciones)
	columnas.custom_minimum_size = Vector2(0, floorf(alto_util))
	# Distribución compacta según la cantidad de opciones, sin reducir la fuente.
	var cantidad: int = maxi(1, _obtener_bloques_disponibles().size())
	var alto_bloque: float = clampf((alto_util - 52.0 - (cantidad - 1) * 3.0) / cantidad, 26.0, 28.0)
	for boton in botones_bloques:
		boton.custom_minimum_size = Vector2(0, floorf(alto_bloque))


func _envolver_lista_desplazable(lista: Control, nombre: String) -> void:
	var padre := lista.get_parent()
	var indice := lista.get_index()
	var scroll := ScrollContainer.new()
	scroll.name = nombre
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.follow_focus = true
	padre.add_child(scroll)
	padre.move_child(scroll, indice)
	lista.reparent(scroll)
	lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lista.size_flags_vertical = Control.SIZE_FILL


func _estilizar_boton_accion(boton: Button, texto_btn: String, color_fondo: Color, color_borde: Color) -> void:
	if boton == null:
		return
	boton.text = texto_btn
	boton.custom_minimum_size = Vector2(142, 44)
	boton.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	boton.add_theme_font_size_override("font_size", 15)
	boton.add_theme_color_override("font_color", Color("#F8FAFC"))

	var normal := StyleBoxFlat.new()
	normal.bg_color = color_fondo
	normal.border_color = color_borde
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(8)
	normal.content_margin_left = 12
	normal.content_margin_right = 12
	normal.content_margin_top = 6
	normal.content_margin_bottom = 6
	boton.add_theme_stylebox_override("normal", normal)

	var hover := normal.duplicate()
	hover.bg_color = color_fondo.lightened(0.15)
	hover.border_color = color_borde.lightened(0.2)
	boton.add_theme_stylebox_override("hover", hover)

	var pressed := normal.duplicate()
	pressed.bg_color = color_fondo.darkened(0.15)
	boton.add_theme_stylebox_override("pressed", pressed)

	var disabled := normal.duplicate()
	disabled.bg_color = Color(0.15, 0.18, 0.24, 0.7)
	disabled.border_color = Color(0.3, 0.35, 0.45, 0.5)
	boton.add_theme_stylebox_override("disabled", disabled)


func conectar_botones() -> void:
	if not boton_cerrar.pressed.is_connected(cerrar_ventana):
		boton_cerrar.pressed.connect(cerrar_ventana)
	if not boton_pista.pressed.is_connected(mostrar_pista):
		boton_pista.pressed.connect(mostrar_pista)
	if not boton_reiniciar.pressed.is_connected(reiniciar_ejercicio):
		boton_reiniciar.pressed.connect(reiniciar_ejercicio)
	if not boton_ejecutar.pressed.is_connected(ejecutar_codigo):
		boton_ejecutar.pressed.connect(ejecutar_codigo)


func abrir_manual() -> void:
	_reproducir_sfx("boton")
	if sistema_puntos != null and sistema_puntos.has_method("abrir_manual_nivel3"):
		sistema_puntos.call("abrir_manual_nivel3")


func preparar_bloques() -> void:
	botones_bloques.clear()
	for hijo in panel_bloques.get_children():
		if hijo is Button:
			var boton: Button = hijo as Button
			botones_bloques.append(boton)
			boton.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			var conexion: Callable = Callable(self, "presionar_bloque").bind(boton)
			if not boton.pressed.is_connected(conexion):
				boton.pressed.connect(conexion)


func iniciar_ejercicio() -> void:
	var validaciones_previas: int = 0
	var pistas_previas: int = 0
	errores = 0
	repeticion_sin_puntos = sistema_puntos != null and sistema_puntos.has_method("ejercicio_esta_completado") and bool(sistema_puntos.call("ejercicio_esta_completado", _obtener_id_ejercicio()))
	if sistema_puntos != null and sistema_puntos.has_method("iniciar_intento_insignia"):
		var intento: Dictionary = sistema_puntos.call("iniciar_intento_insignia", _obtener_id_ejercicio(), _obtener_total_espacios() * _obtener_puntos_por_bloque())
		id_intento_insignia = int(intento.get("id", -1))
		errores = int(intento.get("errores", 0))
		validaciones_previas = int(intento.get("validaciones", 0))
		pistas_previas = int(intento.get("pistas", 0))
	intentos_realizados = validaciones_previas
	pistas_usadas = pistas_previas
	resuelto = false
	validando_intento = false
	ultimo_tipo_error = ""
	tiempo_inicio_intento_ms = Time.get_ticks_msec()
	panel_pista.hide()
	texto_pista.text = ""
	actualizar_puntos_encabezado()
	reiniciar_espacios()


func limpiar_algoritmo() -> void:
	reiniciar_ejercicio()


func comprobar_algoritmo() -> void:
	ejecutar_codigo()


func reiniciar_ejercicio() -> void:
	if resuelto or validando_intento:
		return
	_reproducir_sfx("bloque_quitar")
	reiniciar_espacios()


func reiniciar_espacios() -> void:
	var total_esp: int = _obtener_total_espacios()
	bloques_colocados.clear()
	for i in range(total_esp):
		bloques_colocados.append("")

	var disponibles: Array = _obtener_bloques_disponibles().duplicate()
	disponibles.shuffle()

	bloques_texto_original.clear()
	for i in range(botones_bloques.size()):
		var boton: Button = botones_bloques[i]
		if i < disponibles.size():
			var txt: String = str(disponibles[i])
			bloques_texto_original[boton] = txt
			boton.disabled = false
			boton.show()
		else:
			boton.hide()

	boton_ejecutar.disabled = false
	boton_reiniciar.disabled = false
	if boton_pista != null:
		boton_pista.disabled = false
	mensaje_resultado.text = ""
	_actualizar_estilos_botones_disponibles()
	actualizar_codigo_mostrado()


func _obtener_colores_bloque(texto_codigo: String) -> Dictionary:
	var limpio: String = texto_codigo.strip_edges()
	if limpio.begins_with("while "):
		return {"bg": Color("#4C1D95"), "border": Color("#A78BFA"), "text": Color("#F5F3FF")}
	elif limpio.begins_with("if ") or limpio.begins_with("elif ") or limpio.begins_with("else:"):
		return {"bg": Color("#78350F"), "border": Color("#FBBF24"), "text": Color("#FFFBEB")}
	elif limpio.contains("input("):
		return {"bg": Color("#1E3A8A"), "border": Color("#60A5FA"), "text": Color("#EFF6FF")}
	elif limpio.begins_with("print("):
		return {"bg": Color("#064E3B"), "border": Color("#34D399"), "text": Color("#ECFDF5")}
	else:
		return {"bg": Color("#164E63"), "border": Color("#38BDF8"), "text": Color("#ECFEFF")}


func _actualizar_estilos_botones_disponibles() -> void:
	for boton in botones_bloques:
		if not boton.visible:
			continue
		var txt: String = str(bloques_texto_original.get(boton, boton.text))
		var esta_colocado: bool = bloques_colocados.has(txt)

		if esta_colocado:
			boton.text = txt
			boton.tooltip_text = "Bloque colocado en el algoritmo. Haz clic para quitarlo."
			var estilo_colocado := StyleBoxFlat.new()
			estilo_colocado.bg_color = Color(0.09, 0.13, 0.22, 0.85)
			estilo_colocado.border_color = Color("#38BDF8")
			estilo_colocado.set_border_width_all(2)
			estilo_colocado.set_corner_radius_all(8)
			estilo_colocado.content_margin_left = 8
			estilo_colocado.content_margin_right = 8
			estilo_colocado.content_margin_top = 2
			estilo_colocado.content_margin_bottom = 2
			boton.add_theme_stylebox_override("normal", estilo_colocado)

			var hover_col := estilo_colocado.duplicate()
			hover_col.bg_color = Color(0.22, 0.12, 0.18, 0.95)
			hover_col.border_color = Color("#F87171")
			boton.add_theme_stylebox_override("hover", hover_col)
			boton.add_theme_stylebox_override("pressed", hover_col)
			boton.add_theme_color_override("font_color", Color("#93C5FD"))
			boton.modulate = Color(0.85, 0.95, 1.0, 0.92)
		else:
			boton.text = txt
			boton.tooltip_text = "Haz clic para colocar este bloque en el algoritmo."
			var paleta: Dictionary = _obtener_colores_bloque(txt)
			var bg: Color = paleta["bg"]
			var border: Color = paleta["border"]

			var estilo_disp := StyleBoxFlat.new()
			estilo_disp.bg_color = bg
			estilo_disp.border_color = border
			estilo_disp.set_border_width_all(2)
			estilo_disp.set_corner_radius_all(8)
			estilo_disp.content_margin_left = 8
			estilo_disp.content_margin_right = 8
			estilo_disp.content_margin_top = 2
			estilo_disp.content_margin_bottom = 2
			boton.add_theme_stylebox_override("normal", estilo_disp)

			var hover_disp := estilo_disp.duplicate()
			hover_disp.bg_color = bg.lightened(0.16)
			hover_disp.border_color = border.lightened(0.2)
			boton.add_theme_stylebox_override("hover", hover_disp)
			boton.add_theme_stylebox_override("pressed", hover_disp)
			boton.add_theme_color_override("font_color", paleta["text"])
			boton.modulate = Color(1, 1, 1, 1)


func presionar_bloque(boton: Button) -> void:
	if resuelto or validando_intento or boton == null:
		return

	var texto_bloque: String = str(bloques_texto_original.get(boton, boton.text))

	# Si el bloque ya está colocado, al hacer clic de nuevo se elimina y reorganiza
	var pos_existente: int = bloques_colocados.find(texto_bloque)
	if pos_existente != -1:
		quitar_bloque_colocado(pos_existente)
		return

	var indice_libre: int = obtener_espacio_libre()
	if indice_libre == -1:
		mensaje_resultado.text = "Todos los espacios del algoritmo están ocupados. Haz clic sobre un bloque colocado para quitarlo o presiona Comprobar."
		mensaje_resultado.add_theme_color_override("font_color", Color("#FBBF24"))
		return

	bloques_colocados[indice_libre] = texto_bloque
	mensaje_resultado.text = ""
	_reproducir_sfx("bloque_colocar")
	_actualizar_estilos_botones_disponibles()
	actualizar_codigo_mostrado()


func quitar_bloque_colocado(posicion: int) -> void:
	if resuelto or validando_intento:
		return
	if posicion < 0 or posicion >= bloques_colocados.size():
		return
	if bloques_colocados[posicion] == "":
		return

	# Eliminar el bloque seleccionado y reorganizar los demás manteniendo su orden lógico
	bloques_colocados.remove_at(posicion)
	bloques_colocados.append("")

	mensaje_resultado.text = "Bloque devuelto a las opciones disponibles."
	mensaje_resultado.add_theme_color_override("font_color", Color("#94A3B8"))
	_reproducir_sfx("bloque_quitar")
	_actualizar_estilos_botones_disponibles()
	actualizar_codigo_mostrado()


func obtener_espacio_libre() -> int:
	for i in range(bloques_colocados.size()):
		if bloques_colocados[i] == "":
			return i
	return -1


func actualizar_codigo_mostrado() -> void:
	var plantilla: String = _obtener_plantilla_codigo()
	var total_esp: int = _obtener_total_espacios()

	# Si no existe contenedor VBoxContainer, usar fallback limpio sin etiquetas técnicas
	if lista_algoritmo == null:
		var texto_plano: String = plantilla
		for i in range(total_esp):
			var marcador: String = "[ Espacio " + str(i + 1) + " ]"
			var reemplazo: String = bloques_colocados[i] if bloques_colocados[i] != "" else "▸ [ Seleccionar bloque ]"
			texto_plano = texto_plano.replace(marcador, reemplazo)
		if codigo_ordenado != null:
			codigo_ordenado.text = texto_plano
		return

	if codigo_ordenado != null:
		codigo_ordenado.hide()

	for hijo in lista_algoritmo.get_children():
		if hijo == codigo_ordenado:
			continue
		lista_algoritmo.remove_child(hijo)
		hijo.queue_free()

	lista_algoritmo.add_theme_constant_override("separation", 3)
	var primer_libre: int = obtener_espacio_libre()
	var lineas: PackedStringArray = plantilla.split("\n")

	for linea_raw in lineas:
		var sin_espacios: String = linea_raw.strip_edges()
		if sin_espacios == "":
			var espaciador := Control.new()
			espaciador.custom_minimum_size = Vector2(0, 2)
			lista_algoritmo.add_child(espaciador)
			continue

		var espacios_indent: int = 0
		for c_idx in range(linea_raw.length()):
			if linea_raw[c_idx] == " ":
				espacios_indent += 1
			elif linea_raw[c_idx] == "\t":
				espacios_indent += 4
			else:
				break

		var indice_slot: int = _detectar_indice_espacio(sin_espacios, total_esp)
		if indice_slot != -1:
			_agregar_fila_espacio_visual(indice_slot, espacios_indent, indice_slot == primer_libre)
		else:
			_agregar_fila_codigo_fijo(sin_espacios, espacios_indent)


func _detectar_indice_espacio(texto_limpio: String, total_esp: int) -> int:
	for i in range(total_esp):
		var marcador: String = "[ Espacio " + str(i + 1) + " ]"
		if texto_limpio == marcador:
			return i
	return -1


func _agregar_fila_codigo_fijo(texto_codigo: String, espacios_indent: int) -> void:
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 0)

	if espacios_indent > 0:
		var margen := Control.new()
		margen.custom_minimum_size = Vector2(espacios_indent * 8.0, 0)
		fila.add_child(margen)

	var lbl := Label.new()
	lbl.text = texto_codigo
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.add_theme_font_size_override("font_size", 15)
	if texto_codigo.begins_with("else:") or texto_codigo.begins_with("elif ") or texto_codigo.begins_with("while ") or texto_codigo.begins_with("if "):
		lbl.add_theme_color_override("font_color", Color("#FCD34D"))
	elif texto_codigo.contains("print("):
		lbl.add_theme_color_override("font_color", Color("#6EE7B7"))
	else:
		lbl.add_theme_color_override("font_color", Color("#E2E8F0"))

	fila.add_child(lbl)
	lista_algoritmo.add_child(fila)


func _agregar_fila_espacio_visual(indice: int, espacios_indent: int, es_siguiente_disponible: bool) -> void:
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 6)

	if espacios_indent > 0:
		var guia := Control.new()
		guia.custom_minimum_size = Vector2(espacios_indent * 8.0, 0)
		fila.add_child(guia)

	var btn_slot := Button.new()
	btn_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_slot.custom_minimum_size = Vector2(0, 24)
	btn_slot.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn_slot.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn_slot.clip_text = false
	btn_slot.add_theme_font_size_override("font_size", 14)

	var contenido_actual: String = bloques_colocados[indice] if indice < bloques_colocados.size() else ""

	if contenido_actual != "":
		btn_slot.text = contenido_actual
		btn_slot.tooltip_text = "Haz clic para quitar este bloque del algoritmo."
		btn_slot.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

		var paleta: Dictionary = _obtener_colores_bloque(contenido_actual)
		var bg: Color = paleta["bg"]
		var border: Color = paleta["border"]

		var estilo_lleno := StyleBoxFlat.new()
		estilo_lleno.bg_color = bg
		estilo_lleno.border_color = border
		estilo_lleno.set_border_width_all(2)
		estilo_lleno.set_corner_radius_all(6)
		estilo_lleno.content_margin_left = 8
		estilo_lleno.content_margin_right = 8
		estilo_lleno.content_margin_top = 2
		estilo_lleno.content_margin_bottom = 2
		btn_slot.add_theme_stylebox_override("normal", estilo_lleno)

		var hover_lleno := estilo_lleno.duplicate()
		hover_lleno.bg_color = Color("#7F1D1D")
		hover_lleno.border_color = Color("#F87171")
		btn_slot.add_theme_stylebox_override("hover", hover_lleno)
		btn_slot.add_theme_stylebox_override("pressed", hover_lleno)
		btn_slot.add_theme_color_override("font_color", paleta["text"])

		btn_slot.pressed.connect(quitar_bloque_colocado.bind(indice))
	else:
		btn_slot.disabled = true
		var estilo_vacio := StyleBoxFlat.new()
		estilo_vacio.set_corner_radius_all(6)
		estilo_vacio.content_margin_left = 8
		estilo_vacio.content_margin_right = 8
		estilo_vacio.content_margin_top = 2
		estilo_vacio.content_margin_bottom = 2

		if es_siguiente_disponible:
			btn_slot.text = "▸  Selecciona un bloque para colocar aquí..."
			estilo_vacio.bg_color = Color(0.08, 0.16, 0.28, 0.95)
			estilo_vacio.border_color = Color("#38BDF8")
			estilo_vacio.set_border_width_all(2)
			btn_slot.add_theme_color_override("font_disabled_color", Color("#7DD3FC"))
		else:
			btn_slot.text = "•  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─"
			estilo_vacio.bg_color = Color(0.06, 0.09, 0.16, 0.75)
			estilo_vacio.border_color = Color(0.28, 0.35, 0.48, 0.7)
			estilo_vacio.set_border_width_all(1)
			btn_slot.add_theme_color_override("font_disabled_color", Color("#64748B"))

		btn_slot.add_theme_stylebox_override("disabled", estilo_vacio)
		btn_slot.add_theme_stylebox_override("normal", estilo_vacio)

	fila.add_child(btn_slot)
	lista_algoritmo.add_child(fila)


func mostrar_pista() -> void:
	if resuelto:
		return
	pistas_usadas += 1
	_reproducir_sfx("boton")

	var mensajes_error: Dictionary = _obtener_mensajes_error()
	var pistas_dict: Dictionary = _obtener_pistas()
	var idx_err: int = _obtener_primer_espacio_incorrecto()

	var prefijo: String = "💡 Pista: "
	if errores >= 2 or pistas_usadas >= 3:
		prefijo = "💡 Ayuda detallada: "
	elif errores == 1 or pistas_usadas == 2:
		prefijo = "💡 Pista de estructura: "

	if ultimo_tipo_error != "" and mensajes_error.has(ultimo_tipo_error):
		texto_pista.text = prefijo + _limpiar_etiquetas_tecnicas(str(mensajes_error[ultimo_tipo_error]))
		if (errores >= 1 or pistas_usadas >= 2) and pistas_dict.has(idx_err):
			texto_pista.text += "\n👉 " + _limpiar_etiquetas_tecnicas(str(pistas_dict.get(idx_err, "")))
		panel_pista.show()
		return

	if pistas_dict.has(idx_err):
		texto_pista.text = prefijo + _limpiar_etiquetas_tecnicas(str(pistas_dict.get(idx_err, "")))
		panel_pista.show()
		return

	texto_pista.text = "¡Todos los bloques colocados son correctos! Presiona Comprobar para validar el algoritmo."
	panel_pista.show()


func _limpiar_etiquetas_tecnicas(texto: String) -> String:
	var limpio: String = texto
	limpio = limpio.replace(" (OA1)", "").replace(" (OA2)", "").replace(" (OA3)", "").replace(" (OA2 / OA3)", "")
	for i in range(1, 12):
		limpio = limpio.replace("Espacio " + str(i) + ": ", "")
		limpio = limpio.replace("Espacio " + str(i) + " ", "")
	return limpio


func _obtener_primer_espacio_incorrecto() -> int:
	var resp: Array = _obtener_respuesta_correcta()
	var total_esp: int = _obtener_total_espacios()
	for i in range(total_esp):
		if i >= bloques_colocados.size() or i >= resp.size():
			return i
		if bloques_colocados[i] != str(resp[i]):
			return i
	return 0


func ejecutar_codigo() -> void:
	if resuelto or validando_intento:
		return

	if obtener_espacio_libre() != -1:
		mensaje_resultado.text = "Completa todos los bloques del algoritmo antes de presionar Comprobar."
		mensaje_resultado.add_theme_color_override("font_color", Color("#FBBF24"))
		_reproducir_sfx("incorrecto")
		return

	validando_intento = true
	_reproducir_sfx("ejecutar")
	intentos_realizados += 1
	var duracion_seg: float = float(Time.get_ticks_msec() - tiempo_inicio_intento_ms) / 1000.0
	tiempo_inicio_intento_ms = Time.get_ticks_msec()

	var validacion: Dictionary = validar_algoritmo_y_casos()
	if bool(validacion.get("correcto", false)):
		resuelto = true
		validando_intento = false
		ultimo_tipo_error = ""
		panel_pista.hide()
		var puntos_obtenidos: int = calcular_puntos()

		_registrar_intento_log(true, duracion_seg, "NINGUNO", puntos_obtenidos)
		registrar_puntaje(puntos_obtenidos)
		actualizar_puntos_encabezado()

		mensaje_resultado.text = (
			"¡Algoritmo correcto! " + str(validacion.get("resumen_casos", ""))
			+ "\nPuntos obtenidos: +" + str(puntos_obtenidos)
		)
		mensaje_resultado.add_theme_color_override("font_color", Color("#4ADE80"))
		_animar_feedback(true)
		_reproducir_sfx("correcto")

		boton_ejecutar.disabled = true
		boton_reiniciar.disabled = true
		if boton_pista != null:
			boton_pista.disabled = true
		for b in botones_bloques:
			b.disabled = true

		ejercicio_resuelto.emit(errores)

		if consola != null and consola.has_method("completar_ejercicio"):
			consola.call("completar_ejercicio")
		if puerta_seguridad != null and puerta_seguridad.has_method("desbloquear_puerta"):
			puerta_seguridad.call("desbloquear_puerta")

		hide()
		if ventana_completado != null and ventana_completado.has_method("mostrar_completado"):
			ventana_completado.call("mostrar_completado", errores)
			_actualizar_feedback_insignia()
		return

	# Respuesta incorrecta
	validando_intento = false
	errores += 1
	if sistema_puntos != null and sistema_puntos.has_method("registrar_error_insignia"):
		errores = int(sistema_puntos.call("registrar_error_insignia", _obtener_id_ejercicio(), id_intento_insignia))
	ultimo_tipo_error = detectar_tipo_error()
	_registrar_intento_log(false, duracion_seg, ultimo_tipo_error, 0)

	var mensajes_error: Dictionary = _obtener_mensajes_error()
	var explicacion: String = _limpiar_etiquetas_tecnicas(
		str(mensajes_error.get(ultimo_tipo_error, "Revisa el orden y las condiciones de los bloques seleccionados."))
	)
	var penalizacion_txt: String = (
		"Sin penalización en 1° error" if errores == 1
		else ("Penalización actual: -25%" if errores == 2 else "Penalización actual: -50%")
	)
	mensaje_resultado.text = (
		"Solución incorrecta (Intento #" + str(intentos_realizados) + " | " + penalizacion_txt + ").\n"
		+ explicacion + " Haz clic en un bloque colocado para cambiarlo."
	)
	mensaje_resultado.add_theme_color_override("font_color", Color("#F87171"))
	_animar_feedback(false)
	_reproducir_sfx("incorrecto")


func validar_algoritmo_y_casos() -> Dictionary:
	var resp: Array = _obtener_respuesta_correcta()
	var total_esp: int = _obtener_total_espacios()
	for i in range(total_esp):
		if bloques_colocados[i] != str(resp[i]):
			return {"correcto": false}
	return {"correcto": true, "resumen_casos": "Casos de prueba superados."}


func detectar_tipo_error() -> String:
	var tipos_err: Dictionary = _obtener_tipos_error()
	var resp: Array = _obtener_respuesta_correcta()
	var total_esp: int = _obtener_total_espacios()
	for i in range(bloques_colocados.size()):
		var bloque: String = bloques_colocados[i]
		if tipos_err.has(bloque):
			return str(tipos_err[bloque])
	for i in range(total_esp):
		if bloques_colocados[i] != str(resp[i]):
			return "orden_incorrecto"
	return "orden_incorrecto"


func calcular_puntos() -> int:
	var base: int = _obtener_total_espacios() * _obtener_puntos_por_bloque()
	if errores <= 1:
		return base
	elif errores == 2:
		return int(round(base * 0.75))
	return int(round(base * 0.50))


func registrar_puntaje(puntos: int) -> void:
	var id_ej: String = _obtener_id_ejercicio()
	if sistema_puntos != null:
		if sistema_puntos.has_method("registrar_resultado_detallado"):
			sistema_puntos.call("registrar_resultado_detallado", id_ej, puntos, errores, pistas_usadas, resuelto and obtener_espacio_libre() == -1, _obtener_total_espacios() * _obtener_puntos_por_bloque(), id_intento_insignia)
		elif sistema_puntos.has_method("registrar_ejercicio"):
			sistema_puntos.call("registrar_ejercicio", id_ej, puntos)


func _registrar_intento_log(fue_correcta: bool, tiempo_seg: float, tipo_err: String, puntos: int) -> void:
	if sistema_puntos != null and sistema_puntos.has_method("registrar_intento_log"):
		sistema_puntos.call("registrar_intento_log", {
			"nivel": "Nivel 3",
			"ejercicio": _obtener_id_ejercicio(),
			"pregunta": _obtener_titulo_ejercicio(),
			"alternativas": _obtener_bloques_disponibles(),
			"respuestaJugador": bloques_colocados.duplicate(),
			"siFueCorrectaONo": fue_correcta,
			"tiempoDeRespuesta": tiempo_seg,
			"numeroIntento": intentos_realizados,
			"intentoInsignia": id_intento_insignia,
			"pistasUtilizadas": pistas_usadas,
			"erroresAcumulados": errores,
			"tipoError": tipo_err,
			"puntajeObtenido": puntos
		})


func actualizar_puntos_encabezado() -> void:
	if puntos_nivel == null:
		return
	if sistema_puntos != null and sistema_puntos.has_method("obtener_puntos_totales"):
		puntos_nivel.text = "★ Puntos: " + str(int(sistema_puntos.call("obtener_puntos_totales")))
	else:
		puntos_nivel.text = "★ Puntos: 0"


func _animar_feedback(exito: bool) -> void:
	modulate = Color(0.75, 1.0, 0.8, 1.0) if exito else Color(1.0, 0.75, 0.75, 1.0)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.35)


func _reproducir_sfx(nombre: String) -> void:
	if dj_manager != null and dj_manager.has_method("play_sfx"):
		dj_manager.call("play_sfx", nombre)


func cerrar_ventana() -> void:
	_reproducir_sfx("ui_cerrar")
	hide()
	if consola != null and consola.has_method("cerrar_ejercicio"):
		consola.call("cerrar_ejercicio")


# Repetir un ejercicio ya terminado no cambia su estado de avance ni duplica puntos.
func _preparar_repeticion_insignia() -> void:
	if ventana_completado == null:
		return
	var contenido := ventana_completado.get_node_or_null("ContenidoCompletado") as VBoxContainer
	if contenido == null:
		return
	contenido.add_theme_constant_override("separation", 8)
	estado_insignia = contenido.get_node_or_null("EstadoInsignia") as Label
	if estado_insignia == null:
		estado_insignia = Label.new()
		estado_insignia.name = "EstadoInsignia"
		estado_insignia.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		estado_insignia.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		estado_insignia.add_theme_font_size_override("font_size", 15)
		contenido.add_child(estado_insignia)
	boton_repetir_insignia = contenido.get_node_or_null("RepetirParaInsignia") as Button
	if boton_repetir_insignia == null:
		boton_repetir_insignia = Button.new()
		boton_repetir_insignia.name = "RepetirParaInsignia"
		contenido.add_child(boton_repetir_insignia)
	boton_repetir_insignia.text = "Repetir para mejorar · sin puntos extra"
	boton_repetir_insignia.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	boton_repetir_insignia.add_theme_font_size_override("font_size", 16)
	boton_repetir_insignia.custom_minimum_size = Vector2(0, 36)
	if not boton_repetir_insignia.pressed.is_connected(_repetir_para_insignia):
		boton_repetir_insignia.pressed.connect(_repetir_para_insignia)


func _repetir_para_insignia() -> void:
	if not resuelto or validando_intento:
		return
	ventana_completado.hide()
	iniciar_ejercicio()
	var capa := get_parent() as CanvasLayer
	if capa != null:
		capa.show()
	if consola != null:
		consola.set("ejercicio_abierto", true)
		if consola.has_method("congelar_jugador"):
			consola.call("congelar_jugador")
	show()


func _actualizar_feedback_insignia() -> void:
	if estado_insignia != null and sistema_puntos != null:
		var obtenida: bool = bool(sistema_puntos.call("tiene_insignia_ejercicio", _obtener_id_ejercicio()))
		estado_insignia.text = "Insignia obtenida." if obtenida else "Insignia pendiente: completa un intento con puntaje máximo y cero errores."
	if ventana_completado == null:
		return
	var errores_label := ventana_completado.get_node_or_null("ContenidoCompletado/ErroresCometidos") as Label
	if errores_label != null:
		errores_label.text = "ERRORES EN ESTE INTENTO: %d" % errores
	if repeticion_sin_puntos:
		var puntos_label := ventana_completado.get_node_or_null("ContenidoCompletado/PuntosObtenidos") as Label
		if puntos_label != null:
			puntos_label.text = "Puntos ya registrados · sin recompensa adicional"


# Controles visuales del encabezado: reutilizan las acciones de los botones originales.
var controles_superiores_ocultos: Array[Dictionary] = []
var audio_encabezado: Button = null

func _configurar_encabezado_visual(contenido: VBoxContainer) -> void:
	var fila := contenido.get_node_or_null("FilaTitulo") as HBoxContainer
	if fila == null:
		return
	fila.add_theme_constant_override("separation", 12)
	for hijo in fila.get_children():
		if hijo is Control:
			hijo.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		if hijo is TextureRect:
			hijo.custom_minimum_size = Vector2(48, 48)
	titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if puntos_nivel != null:
		puntos_nivel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	audio_encabezado = Button.new()
	audio_encabezado.name = "AudioEncabezado"
	# El Manual conserva su botón original superior; no crear una copia local.
	for boton in [audio_encabezado]:
		boton.custom_minimum_size = Vector2(112, 36)
		boton.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		boton.add_theme_font_size_override("font_size", 15)
		boton.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		fila.add_child(boton)
	audio_encabezado.hide()
	visibility_changed.connect(_sincronizar_encabezado_visual)
	tree_exiting.connect(_restaurar_controles_superiores)


func _restaurar_controles_superiores() -> void:
	for guardado in controles_superiores_ocultos:
		var control = guardado.control
		if is_instance_valid(control):
			control.visible = bool(guardado.visible)
	controles_superiores_ocultos.clear()


func _sincronizar_encabezado_visual() -> void:
	_restaurar_controles_superiores()
	if not is_visible_in_tree():
		return
	var escena: Node = get_tree().current_scene
	if escena == null:
		return
	var barra: Control = escena.get_node_or_null("HUDNivel3MGTS/BarraSuperiorMGTS") as Control
	var original_audio: Button = null
	if barra != null:
		original_audio = barra.find_child("BotonSilencio", true, false) as Button
	for par in [[audio_encabezado, original_audio]]:
		var boton: Button = par[0]
		var original: Button = par[1]
		for conexion in boton.pressed.get_connections():
			boton.pressed.disconnect(conexion.callable)
		boton.visible = original != null
		if original == null:
			continue
		boton.text = original.text
		boton.disabled = original.disabled
		for estado in ["normal", "hover", "pressed", "disabled", "focus"]:
			boton.add_theme_stylebox_override(estado, original.get_theme_stylebox(estado).duplicate())
		boton.pressed.connect(func() -> void:
			if is_instance_valid(original):
				original.pressed.emit()
				boton.text = original.text
		)
	for control in [barra]:
		if control != null:
			controles_superiores_ocultos.append({"control": control, "visible": control.visible})
			control.hide()
