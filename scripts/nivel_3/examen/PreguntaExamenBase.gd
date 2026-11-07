extends PanelContainer

# ==========================================
# MGTS - NIVEL 3 - CLASE BASE DE PREGUNTA DE EXAMEN FINAL
# Interfaz visual unificada de bloques (sin pistas, sin etiquetas [Espacio X]
# ni textos OA técnicos visibles), transición inmediata entre escenas.
# ==========================================

@onready var titulo: Label = get_node_or_null("ContenidoEjercicio/FilaTitulo/TituloEjercicio") as Label
@onready var estado_examen: Label = get_node_or_null("ContenidoEjercicio/FilaTitulo/FilaEstadoExamen/EstadoExamen") as Label
@onready var progreso_examen: Label = get_node_or_null("ContenidoEjercicio/FilaTitulo/FilaEstadoExamen/ProgresoExamen") as Label
@onready var contador_examen: Label = get_node_or_null("ContenidoEjercicio/FilaTitulo/FilaEstadoExamen/ContadorExamen") as Label
@onready var instrucciones: Label = get_node_or_null("ContenidoEjercicio/FilaInstrucciones/InstruccionesEjercicio") as Label
@onready var panel_pista: PanelContainer = get_node_or_null("ContenidoEjercicio/FilaInstrucciones/PanelPista") as PanelContainer
@onready var lista_bloques: VBoxContainer = get_node_or_null("ContenidoEjercicio/ColumnasEjercicio/PanelBloques/BloquesDisponibles/ListaBloques") as VBoxContainer
@onready var titulo_algoritmo: Label = get_node_or_null("ContenidoEjercicio/ColumnasEjercicio/AreaAlgoritmo/TituloAlgoritmo") as Label
@onready var lista_algoritmo: VBoxContainer = get_node_or_null("ContenidoEjercicio/ColumnasEjercicio/AreaAlgoritmo/PanelAlgoritmo/ListaAlgoritmo") as VBoxContainer
@onready var mensaje_resultado: Label = get_node_or_null("ContenidoEjercicio/MensajeResultado") as Label
@onready var boton_limpiar: Button = get_node_or_null("ContenidoEjercicio/BotonesEjercicio/BotonLimpiar") as Button
@onready var boton_comprobar: Button = get_node_or_null("ContenidoEjercicio/BotonesEjercicio/BotonComprobar") as Button
@onready var boton_refuerzo: Button = get_node_or_null("ContenidoEjercicio/BotonesEjercicio/BotonRefuerzo") as Button
@onready var boton_cerrar: Button = get_node_or_null("ContenidoEjercicio/BotonesEjercicio/BotonCerrar") as Button

@onready var sistema_puntos: Node = get_node_or_null("/root/PuntajesNivel3")
@onready var dj_manager: Node = get_node_or_null("/root/DJManager")

const Estilo = preload("res://scripts/common/ui/ejercicioEstilo.gd")
const PawIconScript = preload("res://scripts/common/ui/pawIcon.gd")
const ESCENA_SALA_10: String = "res://scenes/Nivel_3/10Cámara de Rescat.tscn"
const TOTAL_ESPACIOS: int = 4

var botones_bloques: Array[Button] = []
var bloques_texto_original: Dictionary = {}
var bloques_colocados: Array[String] = []
var intentos_pregunta: int = 0
var validando: bool = false
var tiempo_inicio_ms: int = 0
var promptExamen: RichTextLabel = null
var etiquetaPaso: Label = null
var cajaVidas: HBoxContainer = null
var patitas: Array = []


# Propiedades definidas en cada script Pregunta1.gd .. Pregunta6.gd
func _obtener_numero_banco() -> int:
	return int(get("NUMERO_BANCO")) if "NUMERO_BANCO" in self else 1

func _obtener_id_pregunta() -> String:
	return get("ID_PREGUNTA") if "ID_PREGUNTA" in self else "EX3.1"

func _obtener_titulo_pregunta() -> String:
	return get("TITULO_PREGUNTA") if "TITULO_PREGUNTA" in self else "Pregunta de Examen"

func _obtener_instrucciones_pregunta() -> String:
	return get("INSTRUCCIONES_PREGUNTA") if "INSTRUCCIONES_PREGUNTA" in self else ""

func _obtener_plantilla_codigo() -> String:
	return get("PLANTILLA_CODIGO") if "PLANTILLA_CODIGO" in self else ""

func _obtener_respuesta_correcta() -> Array:
	return get("RESPUESTA_CORRECTA") if "RESPUESTA_CORRECTA" in self else []

func _obtener_bloques_disponibles() -> Array:
	return get("BLOQUES_DISPONIBLES") if "BLOQUES_DISPONIBLES" in self else []

func _obtener_tipos_error() -> Dictionary:
	return get("TIPOS_ERROR") if "TIPOS_ERROR" in self else {}


func _ready() -> void:
	show()
	if sistema_puntos != null:
		if sistema_puntos.has_method("bloquear_manual_por_examen"):
			sistema_puntos.call("bloquear_manual_por_examen", true)
		if sistema_puntos.has_method("asegurar_sesion_examen_activa"):
			sistema_puntos.call("asegurar_sesion_examen_activa")

	if panel_pista != null:
		panel_pista.hide()
	if boton_refuerzo != null:
		boton_refuerzo.hide()

	construirPantallaEstandar()
	_configurar_textos_y_botones()
	_preparar_botones_bloques()
	_iniciar_pregunta()


func construirPantallaEstandar() -> void:
	var viejo: Control = get_node_or_null("ContenidoEjercicio") as Control
	var ui: Dictionary = Estilo.buildScreen(self, "Bloques disponibles")

	titulo = ui["title_right"]
	promptExamen = ui["prompt"]
	titulo_algoritmo = ui["console_title"]
	mensaje_resultado = ui["feedback"]
	etiquetaPaso = ui["step_label"]
	panel_pista = ui["hint_panel"]
	panel_pista.hide()

	(ui["code_box"] as Node).queue_free()
	lista_algoritmo.reparent(ui["code_scroll"])
	lista_algoritmo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lista_algoritmo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	lista_algoritmo.add_theme_constant_override("separation", 4)

	(ui["bank_box"] as Node).queue_free()
	lista_bloques.reparent(ui["bank_scroll"])
	lista_bloques.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lista_bloques.add_theme_constant_override("separation", 10)

	var fila: HBoxContainer = ui["buttons"]
	for par in [[boton_cerrar, "Volver al nivel", "danger"], [boton_limpiar, "Reiniciar", "neutral"], [boton_comprobar, "Comprobar", "primary"]]:
		var boton: Button = par[0]
		if boton != null:
			boton.reparent(fila)
			Estilo.styleActionButton(boton, par[1], par[2])
	if boton_comprobar != null:
		boton_comprobar.custom_minimum_size = Vector2(190, 48)

	construirVidas(ui["head_row"])

	if viejo != null:
		viejo.hide()


func construirVidas(filaEncabezado: HBoxContainer) -> void:
	var maxErr: int = 3
	if sistema_puntos != null and sistema_puntos.has_method("obtener_max_errores_examen"):
		maxErr = int(sistema_puntos.call("obtener_max_errores_examen"))

	cajaVidas = HBoxContainer.new()
	cajaVidas.add_theme_constant_override("separation", 5)
	cajaVidas.alignment = BoxContainer.ALIGNMENT_CENTER
	cajaVidas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	filaEncabezado.add_child(cajaVidas)

	var etiquetaVidas := Label.new()
	etiquetaVidas.text = "Vidas:"
	etiquetaVidas.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	etiquetaVidas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	etiquetaVidas.add_theme_font_size_override("font_size", 20)
	etiquetaVidas.add_theme_color_override("font_color", Color(1.0, 0.6, 0.78))
	cajaVidas.add_child(etiquetaVidas)

	patitas = []
	for i in range(maxErr):
		var patita = PawIconScript.new()
		cajaVidas.add_child(patita)
		patitas.append(patita)


func _configurar_textos_y_botones() -> void:
	Estilo.setPromptText(promptExamen, _obtener_instrucciones_pregunta())
	titulo_algoritmo.text = "Consola – completa los " + str(TOTAL_ESPACIOS) + " huecos"


	_actualizar_encabezado_examen()

	if boton_limpiar != null and not boton_limpiar.pressed.is_connected(reiniciar_pregunta):
		boton_limpiar.pressed.connect(reiniciar_pregunta)
	if boton_comprobar != null and not boton_comprobar.pressed.is_connected(comprobar_respuesta):
		boton_comprobar.pressed.connect(comprobar_respuesta)
	if boton_cerrar != null and not boton_cerrar.pressed.is_connected(volver_al_nivel):
		boton_cerrar.pressed.connect(volver_al_nivel)


func _actualizar_encabezado_examen() -> void:
	var num_actual: int = 1
	var total_preg: int = 3
	var err_actuales: int = 0
	var max_err: int = 3

	if sistema_puntos != null:
		if sistema_puntos.has_method("obtener_numero_pregunta_examen_actual"):
			num_actual = int(sistema_puntos.call("obtener_numero_pregunta_examen_actual"))
		if sistema_puntos.has_method("obtener_total_preguntas_examen_intento"):
			total_preg = int(sistema_puntos.call("obtener_total_preguntas_examen_intento"))
		if sistema_puntos.has_method("obtener_errores_examen_actuales"):
			err_actuales = int(sistema_puntos.call("obtener_errores_examen_actuales"))
		if sistema_puntos.has_method("obtener_max_errores_examen"):
			max_err = int(sistema_puntos.call("obtener_max_errores_examen"))

	if titulo != null:
		titulo.text = "Examen final · Pregunta " + str(num_actual) + "/" + str(total_preg) + " – " + _obtener_titulo_pregunta()

	for i in range(patitas.size()):
		patitas[i].alive = i < (max_err - err_actuales)


func _estilizar_boton_accion(boton: Button, texto_btn: String, color_fondo: Color, color_borde: Color) -> void:
	if boton == null:
		return
	boton.text = texto_btn
	boton.custom_minimum_size = Vector2(180, 44)
	boton.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	boton.add_theme_font_size_override("font_size", 15)
	boton.add_theme_color_override("font_color", Color("#F8FAFC"))

	var normal := StyleBoxFlat.new()
	normal.bg_color = color_fondo
	normal.border_color = color_borde
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(8)
	normal.content_margin_left = 14
	normal.content_margin_right = 14
	normal.content_margin_top = 6
	normal.content_margin_bottom = 6
	boton.add_theme_stylebox_override("normal", normal)

	var hover := normal.duplicate()
	hover.bg_color = color_fondo.lightened(0.15)
	hover.border_color = color_borde.lightened(0.2)
	boton.add_theme_stylebox_override("hover", hover)
	boton.add_theme_stylebox_override("pressed", normal)


func _preparar_botones_bloques() -> void:
	botones_bloques.clear()
	if lista_bloques == null:
		return
	for hijo in lista_bloques.get_children():
		if hijo is Button:
			var boton: Button = hijo as Button
			botones_bloques.append(boton)
			boton.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			var conexion: Callable = Callable(self, "presionar_bloque").bind(boton)
			if not boton.pressed.is_connected(conexion):
				boton.pressed.connect(conexion)


func _iniciar_pregunta() -> void:
	intentos_pregunta = 0
	validando = false
	tiempo_inicio_ms = Time.get_ticks_msec()
	_reiniciar_espacios()


func reiniciar_pregunta() -> void:
	if validando:
		return
	_reproducir_sfx("bloque_quitar")
	_reiniciar_espacios()


func _reiniciar_espacios() -> void:
	bloques_colocados.clear()
	for i in range(TOTAL_ESPACIOS):
		bloques_colocados.append("")

	var opciones: Array = _obtener_bloques_disponibles().duplicate()
	opciones.shuffle()

	bloques_texto_original.clear()
	for i in range(botones_bloques.size()):
		var boton: Button = botones_bloques[i]
		if i < opciones.size():
			var txt: String = str(opciones[i])
			bloques_texto_original[boton] = txt
			boton.disabled = false
			boton.show()
		else:
			boton.hide()

	if boton_comprobar != null:
		boton_comprobar.disabled = false
	if mensaje_resultado != null:
		mensaje_resultado.text = ""

	_actualizar_estilos_botones_disponibles()
	_actualizar_algoritmo_visual()


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
		boton.text = txt.strip_edges()
		Estilo.styleBankButton(boton, txt)
		if esta_colocado:
			boton.tooltip_text = "Bloque colocado en el algoritmo. Haz clic para quitarlo."
			var usado: StyleBoxFlat = Estilo.usedStyle(txt)
			for estado in ["normal", "hover", "pressed", "focus"]:
				boton.add_theme_stylebox_override(estado, usado)
			for nombre_color in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
				boton.add_theme_color_override(nombre_color, Color(0.55, 0.55, 0.55))
		else:
			boton.tooltip_text = "Haz clic para colocar este bloque en el algoritmo."


func presionar_bloque(boton: Button) -> void:
	if validando or boton == null:
		return

	var texto_bloque: String = str(bloques_texto_original.get(boton, boton.text))
	var pos_existente: int = bloques_colocados.find(texto_bloque)
	if pos_existente != -1:
		quitar_bloque_colocado(pos_existente)
		return

	var indice_libre: int = bloques_colocados.find("")
	if indice_libre == -1:
		if mensaje_resultado != null:
			mensaje_resultado.text = "Todos los espacios están ocupados. Haz clic sobre un bloque colocado para quitarlo o presiona Comprobar."
			mensaje_resultado.add_theme_color_override("font_color", Color("#FBBF24"))
		return

	bloques_colocados[indice_libre] = texto_bloque
	if mensaje_resultado != null:
		mensaje_resultado.text = ""
	_reproducir_sfx("bloque_colocar")
	_actualizar_estilos_botones_disponibles()
	_actualizar_algoritmo_visual()


func quitar_bloque_colocado(posicion: int) -> void:
	if validando:
		return
	if posicion < 0 or posicion >= bloques_colocados.size():
		return
	if bloques_colocados[posicion] == "":
		return

	bloques_colocados[posicion] = ""

	if mensaje_resultado != null:
		mensaje_resultado.text = "Bloque devuelto a las opciones disponibles."
		mensaje_resultado.add_theme_color_override("font_color", Color("#94A3B8"))
	_reproducir_sfx("bloque_quitar")
	_actualizar_estilos_botones_disponibles()
	_actualizar_algoritmo_visual()


func _actualizar_algoritmo_visual() -> void:
	if lista_algoritmo == null:
		return

	for hijo in lista_algoritmo.get_children():
		lista_algoritmo.remove_child(hijo)
		hijo.queue_free()

	lista_algoritmo.add_theme_constant_override("separation", 3)
	var primer_libre: int = bloques_colocados.find("")

	if etiquetaPaso != null:
		var colocados: int = 0
		for b in bloques_colocados:
			if b != "":
				colocados += 1
		etiquetaPaso.text = "Colocados %d de %d" % [colocados, TOTAL_ESPACIOS]

	var plantilla: String = _obtener_plantilla_codigo()
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

		var idx_slot: int = -1
		for i in range(TOTAL_ESPACIOS):
			if sin_espacios == "[ Espacio " + str(i + 1) + " ]":
				idx_slot = i
				break

		if idx_slot != -1:
			_agregar_fila_slot_examen(idx_slot, espacios_indent, idx_slot == primer_libre)
		else:
			_agregar_fila_codigo_examen(sin_espacios, espacios_indent)


func _agregar_fila_codigo_examen(texto_codigo: String, espacios_indent: int) -> void:
	lista_algoritmo.add_child(Estilo.makeRow(int(espacios_indent / 4.0), Estilo.makeCodeBlock(texto_codigo, "locked")))


func _agregar_fila_slot_examen(indice: int, espacios_indent: int, es_siguiente_disponible: bool) -> void:
	var contenido_actual: String = bloques_colocados[indice] if indice < bloques_colocados.size() else ""
	var bloque: Control
	var con_flecha: bool = false
	if contenido_actual != "":
		bloque = Estilo.makeCodeBlock(contenido_actual, "locked")
		bloque.tooltip_text = "Haz clic para quitar este bloque del algoritmo."
		bloque.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		bloque.gui_input.connect(alPresionarBloqueColocado.bind(indice))
	else:
		bloque = Estilo.makeEmptySlot()
		con_flecha = es_siguiente_disponible
	var fila: HBoxContainer = Estilo.makeRow(int(espacios_indent / 4.0), bloque, con_flecha)
	lista_algoritmo.add_child(fila)
	if con_flecha:
		Estilo.ensureVisible(fila)


func alPresionarBloqueColocado(evento: InputEvent, indice: int) -> void:
	if evento is InputEventMouseButton and evento.pressed and evento.button_index == MOUSE_BUTTON_LEFT:
		quitar_bloque_colocado(indice)


func comprobar_respuesta() -> void:
	if validando:
		return

	if bloques_colocados.find("") != -1:
		if mensaje_resultado != null:
			mensaje_resultado.text = "Completa todos los espacios del algoritmo antes de presionar Comprobar."
			mensaje_resultado.add_theme_color_override("font_color", Color("#FBBF24"))
		_reproducir_sfx("incorrecto")
		return

	validando = true
	_reproducir_sfx("ejecutar")
	intentos_pregunta += 1
	var duracion_seg: float = float(Time.get_ticks_msec() - tiempo_inicio_ms) / 1000.0
	tiempo_inicio_ms = Time.get_ticks_msec()

	if validar_solucion_pregunta():
		_reproducir_sfx("correcto")
		_registrar_log_pregunta(true, duracion_seg, "NINGUNO", "EN_PROGRESO")

		var ruta_siguiente: String = "res://scenes/ExamenNivel3/ResultadoExamen.tscn"
		if sistema_puntos != null and sistema_puntos.has_method("registrar_pregunta_examen_superada"):
			ruta_siguiente = str(sistema_puntos.call(
				"registrar_pregunta_examen_superada",
				_obtener_numero_banco(),
				_obtener_titulo_pregunta()
			))

		get_tree().change_scene_to_file(ruta_siguiente)
		return

	# Solución incorrecta (sin pistas que revelen la respuesta)
	validando = false
	_reproducir_sfx("incorrecto")
	var tipo_err: String = _detectar_tipo_error()
	var alcanzo_limite: bool = false
	if sistema_puntos != null and sistema_puntos.has_method("registrar_error_en_examen"):
		alcanzo_limite = bool(sistema_puntos.call("registrar_error_en_examen"))

	_actualizar_encabezado_examen()

	if alcanzo_limite:
		_registrar_log_pregunta(false, duracion_seg, tipo_err, "REPROBADO")
		_reproducir_sfx("examen_reprobado")
		var ruta_res: String = "res://scenes/ExamenNivel3/ResultadoExamen.tscn"
		if sistema_puntos != null and sistema_puntos.has_method("reprobar_intento_examen_actual"):
			ruta_res = str(sistema_puntos.call(
				"reprobar_intento_examen_actual",
				_obtener_numero_banco(),
				_obtener_titulo_pregunta()
			))
		get_tree().change_scene_to_file(ruta_res)
		return

	_registrar_log_pregunta(false, duracion_seg, tipo_err, "EN_PROGRESO")
	var err_act: int = int(sistema_puntos.call("obtener_errores_examen_actuales")) if sistema_puntos != null else 1
	var max_err: int = int(sistema_puntos.call("obtener_max_errores_examen")) if sistema_puntos != null else 3
	Estilo.shake(self)
	if mensaje_resultado != null:
		var vidas_restantes: int = max_err - err_act
		mensaje_resultado.text = (
			"Incorrecto. Te quedan " + str(vidas_restantes) + " de " + str(max_err) + " vidas. "
			+ "En el examen no hay pistas: revisa el orden y las condiciones de tus bloques."
		)
		mensaje_resultado.add_theme_color_override("font_color", Estilo.ERR)


func validar_solucion_pregunta() -> bool:
	var resp: Array = _obtener_respuesta_correcta()
	for i in range(TOTAL_ESPACIOS):
		if bloques_colocados[i] != str(resp[i]):
			return false
	return true


func _detectar_tipo_error() -> String:
	var mapa: Dictionary = _obtener_tipos_error()
	for b in bloques_colocados:
		if mapa.has(b):
			return str(mapa[b])
	return "orden_incorrecto"


func _registrar_log_pregunta(fue_correcta: bool, tiempo_seg: float, tipo_err: String, estado_ex: String) -> void:
	if sistema_puntos != null and sistema_puntos.has_method("registrar_intento_log"):
		var err_act: int = int(sistema_puntos.call("obtener_errores_examen_actuales"))
		sistema_puntos.call("registrar_intento_log", {
			"nivel": "Nivel 3",
			"ejercicio": _obtener_id_pregunta(),
			"pregunta": _obtener_titulo_pregunta(),
			"alternativas": _obtener_bloques_disponibles(),
			"respuestaJugador": bloques_colocados.duplicate(),
			"siFueCorrectaONo": fue_correcta,
			"tiempoDeRespuesta": tiempo_seg,
			"numeroIntento": intentos_pregunta,
			"pistasUtilizadas": 0,
			"erroresAcumulados": err_act,
			"tipoError": tipo_err,
			"puntajeObtenido": 0,
			"resultadoExamen": estado_ex
		})


func volver_al_nivel() -> void:
	_reproducir_sfx("ui_cerrar")
	get_tree().change_scene_to_file(ESCENA_SALA_10)


func _reproducir_sfx(nombre: String) -> void:
	if dj_manager != null and dj_manager.has_method("play_sfx"):
		dj_manager.call("play_sfx", nombre)
