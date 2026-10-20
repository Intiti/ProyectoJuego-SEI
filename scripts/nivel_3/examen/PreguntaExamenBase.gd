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

const ESCENA_SALA_10: String = "res://scenes/Nivel_3/10Cámara de Rescat.tscn"
const TOTAL_ESPACIOS: int = 4

var botones_bloques: Array[Button] = []
var bloques_texto_original: Dictionary = {}
var bloques_colocados: Array[String] = []
var intentos_pregunta: int = 0
var validando: bool = false
var tiempo_inicio_ms: int = 0


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

	_configurar_textos_y_botones()
	_preparar_botones_bloques()
	_iniciar_pregunta()


func _configurar_textos_y_botones() -> void:
	var num_actual: int = 1
	var total_preg: int = 3
	if sistema_puntos != null:
		if sistema_puntos.has_method("obtener_numero_pregunta_examen_actual"):
			num_actual = int(sistema_puntos.call("obtener_numero_pregunta_examen_actual"))
		if sistema_puntos.has_method("obtener_total_preguntas_examen_intento"):
			total_preg = int(sistema_puntos.call("obtener_total_preguntas_examen_intento"))

	if titulo != null:
		titulo.text = "Pregunta " + str(num_actual) + "/" + str(total_preg) + " – " + _obtener_titulo_pregunta()
	if instrucciones != null:
		instrucciones.text = _obtener_instrucciones_pregunta()
	if titulo_algoritmo != null:
		titulo_algoritmo.text = "CONSTRUCCIÓN DEL ALGORITMO (Haz clic en un bloque colocado para quitarlo)"

	_actualizar_encabezado_examen()

	_estilizar_boton_accion(boton_limpiar, "↺ Reiniciar", Color("#334155"), Color("#64748B"))
	_estilizar_boton_accion(boton_comprobar, "▶ Comprobar", Color("#4C1D95"), Color("#A78BFA"))
	_estilizar_boton_accion(boton_cerrar, "⬅ Volver al nivel", Color("#7F1D1D"), Color("#F87171"))

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

	if estado_examen != null:
		estado_examen.text = "Examen final"
		estado_examen.add_theme_color_override("font_color", Color("#55EFC4"))
	if progreso_examen != null:
		progreso_examen.text = "|  Pregunta " + str(num_actual) + "/" + str(total_preg)
		progreso_examen.add_theme_color_override("font_color", Color("#FBBF24"))
	if contador_examen != null:
		contador_examen.text = "|  Errores " + str(err_actuales) + "/" + str(max_err)
		contador_examen.add_theme_color_override("font_color", Color("#F87171") if err_actuales > 0 else Color("#93C5FD"))


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

		if esta_colocado:
			boton.text = txt
			boton.tooltip_text = "Bloque colocado. Haz clic para quitarlo del algoritmo."
			var estilo_colocado := StyleBoxFlat.new()
			estilo_colocado.bg_color = Color(0.09, 0.13, 0.22, 0.85)
			estilo_colocado.border_color = Color("#38BDF8")
			estilo_colocado.set_border_width_all(2)
			estilo_colocado.set_corner_radius_all(8)
			estilo_colocado.content_margin_left = 10
			estilo_colocado.content_margin_right = 10
			estilo_colocado.content_margin_top = 5
			estilo_colocado.content_margin_bottom = 5
			boton.add_theme_stylebox_override("normal", estilo_colocado)

			var hover_col := estilo_colocado.duplicate()
			hover_col.bg_color = Color(0.22, 0.12, 0.18, 0.95)
			hover_col.border_color = Color("#F87171")
			boton.add_theme_stylebox_override("hover", hover_col)
			boton.add_theme_stylebox_override("pressed", hover_col)
			boton.add_theme_color_override("font_color", Color("#93C5FD"))
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
			estilo_disp.content_margin_left = 10
			estilo_disp.content_margin_right = 10
			estilo_disp.content_margin_top = 5
			estilo_disp.content_margin_bottom = 5
			boton.add_theme_stylebox_override("normal", estilo_disp)

			var hover_disp := estilo_disp.duplicate()
			hover_disp.bg_color = bg.lightened(0.16)
			hover_disp.border_color = border.lightened(0.2)
			boton.add_theme_stylebox_override("hover", hover_disp)
			boton.add_theme_stylebox_override("pressed", hover_disp)
			boton.add_theme_color_override("font_color", paleta["text"])


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

	bloques_colocados.remove_at(posicion)
	bloques_colocados.append("")

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

	lista_algoritmo.add_theme_constant_override("separation", 5)
	var primer_libre: int = bloques_colocados.find("")
	var plantilla: String = _obtener_plantilla_codigo()
	var lineas: PackedStringArray = plantilla.split("\n")

	for linea_raw in lineas:
		var sin_espacios: String = linea_raw.strip_edges()
		if sin_espacios == "":
			var esp := Control.new()
			esp.custom_minimum_size = Vector2(0, 4)
			lista_algoritmo.add_child(esp)
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
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 0)
	if espacios_indent > 0:
		var margen := Control.new()
		margen.custom_minimum_size = Vector2(espacios_indent * 8.0, 0)
		fila.add_child(margen)

	var lbl := Label.new()
	lbl.text = texto_codigo
	lbl.add_theme_font_size_override("font_size", 15)
	if texto_codigo.begins_with("else:") or texto_codigo.begins_with("elif ") or texto_codigo.begins_with("while ") or texto_codigo.begins_with("if "):
		lbl.add_theme_color_override("font_color", Color("#FCD34D"))
	elif texto_codigo.contains("print("):
		lbl.add_theme_color_override("font_color", Color("#6EE7B7"))
	else:
		lbl.add_theme_color_override("font_color", Color("#E2E8F0"))

	fila.add_child(lbl)
	lista_algoritmo.add_child(fila)


func _agregar_fila_slot_examen(indice: int, espacios_indent: int, es_siguiente_disponible: bool) -> void:
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 6)
	if espacios_indent > 0:
		var guia := Control.new()
		guia.custom_minimum_size = Vector2(espacios_indent * 8.0, 0)
		fila.add_child(guia)

	var btn_slot := Button.new()
	btn_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_slot.custom_minimum_size = Vector2(0, 32)
	btn_slot.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn_slot.add_theme_font_size_override("font_size", 14)

	var contenido_actual: String = bloques_colocados[indice] if indice < bloques_colocados.size() else ""
	if contenido_actual != "":
		btn_slot.text = contenido_actual
		btn_slot.tooltip_text = "Haz clic para quitar este bloque del algoritmo."
		btn_slot.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

		var paleta: Dictionary = _obtener_colores_bloque(contenido_actual)
		var estilo_lleno := StyleBoxFlat.new()
		estilo_lleno.bg_color = paleta["bg"]
		estilo_lleno.border_color = paleta["border"]
		estilo_lleno.set_border_width_all(2)
		estilo_lleno.set_corner_radius_all(6)
		estilo_lleno.content_margin_left = 12
		estilo_lleno.content_margin_right = 12
		estilo_lleno.content_margin_top = 4
		estilo_lleno.content_margin_bottom = 4
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
		estilo_vacio.content_margin_left = 12
		estilo_vacio.content_margin_right = 12
		estilo_vacio.content_margin_top = 4
		estilo_vacio.content_margin_bottom = 4

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
	if mensaje_resultado != null:
		mensaje_resultado.text = (
			"Solución incorrecta (Errores acumulados: " + str(err_act) + "/" + str(max_err) + "). "
			+ "Durante el examen no se muestran pistas. Revisa el orden y las condiciones de tus bloques."
		)
		mensaje_resultado.add_theme_color_override("font_color", Color("#F87171"))


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
