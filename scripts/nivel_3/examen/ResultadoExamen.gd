extends PanelContainer

# ==========================================
# MGTS - NIVEL 3 - RESULTADO DEL EXAMEN FINAL Y ACTIVIDADES DE REFUERZO
# Muestra el resultado de la evaluación (aprobado / reprobado),
# permite avanzar al rescate de Panko, reintentar el examen (con 3 nuevas
# preguntas del banco de 6), volver al nivel o practicar con refuerzo guiado.
# ==========================================

const ESCENA_FINAL_PANKO: String = "res://scenes/Nivel_3/Final.tscn"
const ESCENA_SALA_10: String = "res://scenes/Nivel_3/10Cámara de Rescat.tscn"

@onready var sistema_puntos: Node = get_node_or_null("/root/PuntajesNivel3")
@onready var dj_manager: Node = get_node_or_null("/root/DJManager")

var contenedor_principal: VBoxContainer = null
var panel_refuerzo: PanelContainer = null
var lbl_feedback_refuerzo: Label = null
var lista_algoritmo_refuerzo: VBoxContainer = null
var botones_refuerzo: Array[Button] = []
var bloques_refuerzo_colocados: Array[String] = ["", "", "", ""]

const PLANTILLA_REFUERZO: String = (
	"estable = False\n"
	+ "pruebas = 0\n\n"
	+ "[ Espacio 1 ]\n"
	+ "    [ Espacio 2 ]\n"
	+ "    [ Espacio 3 ]\n"
	+ "        [ Espacio 4 ]\n"
	+ "    pruebas = pruebas + 1"
)

const CORRECTA_REFUERZO: Array[String] = [
	"while not estable and pruebas < 3:",
	"dato = input(\"Señal: \")",
	"if dato == \"OK\" or dato == \"LISTO\":",
	"estable = True"
]

const OPCIONES_REFUERZO: Array[String] = [
	"while not estable and pruebas < 3:",
	"while estable or pruebas < 3:",
	"dato = input(\"Señal: \")",
	"if dato == \"OK\" or dato == \"LISTO\":",
	"if dato == \"OK\" and dato == \"LISTO\":",
	"estable = True"
]


func _ready() -> void:
	show()
	var aprobado: bool = false
	if sistema_puntos != null:
		aprobado = bool(sistema_puntos.get("examen_aprobado_actual")) or bool(sistema_puntos.get("examen_aprobado"))
		if sistema_puntos.has_method("bloquear_manual_por_examen"):
			sistema_puntos.call("bloquear_manual_por_examen", not aprobado)

	if dj_manager != null and dj_manager.has_method("play_sfx"):
		dj_manager.call("play_sfx", "examen_aprobado" if aprobado else "examen_reprobado")

	_construir_interfaz_resultado(aprobado)


func _construir_interfaz_resultado(aprobado: bool) -> void:
	for hijo in get_children():
		remove_child(hijo)
		hijo.queue_free()

	contenedor_principal = VBoxContainer.new()
	contenedor_principal.name = "ContenidoResultadoExamen"
	contenedor_principal.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contenedor_principal.size_flags_vertical = Control.SIZE_EXPAND_FILL
	contenedor_principal.alignment = BoxContainer.ALIGNMENT_CENTER
	contenedor_principal.add_theme_constant_override("separation", 14)
	add_child(contenedor_principal)

	var correctas: int = 0
	var errores_tot: int = 0
	var puntos_tot: int = 0
	if sistema_puntos != null:
		correctas = int(sistema_puntos.get("examen_respuestas_correctas"))
		errores_tot = int(sistema_puntos.call("obtener_errores_examen_actuales"))
		puntos_tot = int(sistema_puntos.call("obtener_puntos_totales"))
		if aprobado and correctas < 3:
			correctas = 3

	var lbl_estado := Label.new()
	lbl_estado.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_estado.add_theme_font_size_override("font_size", 28)
	if aprobado:
		lbl_estado.text = "🏆 ¡EXAMEN FINAL APROBADO!"
		lbl_estado.add_theme_color_override("font_color", Color("#4ADE80"))
	else:
		lbl_estado.text = "⚠ EXAMEN FINAL NO SUPERADO"
		lbl_estado.add_theme_color_override("font_color", Color("#F87171"))
	contenedor_principal.add_child(lbl_estado)

	var tarjeta := PanelContainer.new()
	tarjeta.custom_minimum_size = Vector2(780, 170)
	tarjeta.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var estilo_t := StyleBoxFlat.new()
	estilo_t.bg_color = Color(0.06, 0.10, 0.19, 0.96)
	estilo_t.border_color = Color("#4ADE80") if aprobado else Color("#F87171")
	estilo_t.set_border_width_all(2)
	estilo_t.set_corner_radius_all(12)
	estilo_t.content_margin_left = 24
	estilo_t.content_margin_right = 24
	estilo_t.content_margin_top = 16
	estilo_t.content_margin_bottom = 16
	tarjeta.add_theme_stylebox_override("panel", estilo_t)
	contenedor_principal.add_child(tarjeta)

	var vbox_resumen := VBoxContainer.new()
	vbox_resumen.add_theme_constant_override("separation", 8)
	tarjeta.add_child(vbox_resumen)

	var lbl_msg := Label.new()
	lbl_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_msg.add_theme_font_size_override("font_size", 16)
	lbl_msg.add_theme_color_override("font_color", Color("#F1F5F9"))
	if aprobado:
		lbl_msg.text = (
			"¡Excelente trabajo! Superaste las 3 preguntas del Examen Final integrador.\n"
			+ "La cápsula de contención se ha abierto y Panko está listo para ser rescatado."
		)
	else:
		lbl_msg.text = (
			"Alcanzaste el límite de 3 errores permitidos durante el examen.\n"
			+ "Puedes realizar la actividad de refuerzo guiado aquí mismo o reintentar el examen con 3 preguntas."
		)
	vbox_resumen.add_child(lbl_msg)

	var lbl_metricas := Label.new()
	lbl_metricas.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_metricas.add_theme_font_size_override("font_size", 16)
	lbl_metricas.add_theme_color_override("font_color", Color("#FBBF24"))
	lbl_metricas.text = (
		"Preguntas resueltas: %d / 3   |   Errores: %d / 3   |   ★ Puntaje Total Nivel 3: %d pts"
		% [correctas, errores_tot, puntos_tot]
	)
	vbox_resumen.add_child(lbl_metricas)

	# Panel de Actividad de Refuerzo Guiado (oculto inicialmente, activable con el botón)
	_construir_panel_refuerzo()

	# Fila de botones de acción
	var fila_btn := HBoxContainer.new()
	fila_btn.alignment = BoxContainer.ALIGNMENT_CENTER
	fila_btn.add_theme_constant_override("separation", 14)
	contenedor_principal.add_child(fila_btn)

	if aprobado:
		var btn_final := Button.new()
		btn_final.name = "BotonContinuarFinal"
		_estilizar_boton(btn_final, "🐾 Continuar al final del juego →", Color("#065F46"), Color("#34D399"), Vector2(280, 48))
		btn_final.pressed.connect(continuar_al_final)
		fila_btn.add_child(btn_final)

	var btn_reintentar := Button.new()
	btn_reintentar.name = "BotonReintentarExamen"
	_estilizar_boton(btn_reintentar, "↻ Reintentar examen", Color("#4C1D95"), Color("#A78BFA"), Vector2(210, 48))
	btn_reintentar.pressed.connect(reintentar_examen)
	fila_btn.add_child(btn_reintentar)

	if not aprobado:
		var btn_refuerzo := Button.new()
		btn_refuerzo.name = "BotonActividadesRefuerzo"
		_estilizar_boton(btn_refuerzo, "📘 Actividades de refuerzo", Color("#0E7490"), Color("#38BDF8"), Vector2(230, 48))
		btn_refuerzo.pressed.connect(mostrar_actividades_refuerzo)
		fila_btn.add_child(btn_refuerzo)

	var btn_volver := Button.new()
	btn_volver.name = "BotonVolverNivel"
	_estilizar_boton(btn_volver, "⬅ Volver al nivel", Color("#334155"), Color("#94A3B8"), Vector2(180, 48))
	btn_volver.pressed.connect(volver_al_nivel)
	fila_btn.add_child(btn_volver)


func _construir_panel_refuerzo() -> void:
	panel_refuerzo = PanelContainer.new()
	panel_refuerzo.name = "PanelRefuerzoInteractivo"
	panel_refuerzo.visible = false
	panel_refuerzo.custom_minimum_size = Vector2(920, 290)
	panel_refuerzo.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	var estilo_ref := StyleBoxFlat.new()
	estilo_ref.bg_color = Color(0.05, 0.11, 0.18, 0.98)
	estilo_ref.border_color = Color("#38BDF8")
	estilo_ref.set_border_width_all(2)
	estilo_ref.set_corner_radius_all(10)
	estilo_ref.content_margin_left = 18
	estilo_ref.content_margin_right = 18
	estilo_ref.content_margin_top = 12
	estilo_ref.content_margin_bottom = 12
	panel_refuerzo.add_theme_stylebox_override("panel", estilo_ref)
	contenedor_principal.add_child(panel_refuerzo)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel_refuerzo.add_child(vbox)

	var lbl_tit := Label.new()
	lbl_tit.text = "📘 ACTIVIDAD DE REFUERZO GUIADO – Estabilización de respaldo (Sin límite de errores)"
	lbl_tit.add_theme_color_override("font_color", Color("#38BDF8"))
	lbl_tit.add_theme_font_size_override("font_size", 15)
	vbox.add_child(lbl_tit)

	var lbl_guia := Label.new()
	lbl_guia.text = "Guía paso a paso: 1) Repite mientras 'not estable and pruebas < 3:'  2) Lee la señal con input()  3) Comprueba con 'or' si es \"OK\" o \"LISTO\"  4) Cambia 'estable = True'."
	lbl_guia.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_guia.add_theme_color_override("font_color", Color("#FDE68A"))
	lbl_guia.add_theme_font_size_override("font_size", 13)
	vbox.add_child(lbl_guia)

	var columnas := HBoxContainer.new()
	columnas.add_theme_constant_override("separation", 16)
	columnas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(columnas)

	var col_izq := VBoxContainer.new()
	col_izq.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col_izq.add_theme_constant_override("separation", 5)
	columnas.add_child(col_izq)

	botones_refuerzo.clear()
	for txt_op in OPCIONES_REFUERZO:
		var b := Button.new()
		b.text = txt_op
		b.custom_minimum_size = Vector2(0, 30)
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		b.add_theme_font_size_override("font_size", 13)
		var op_str: String = txt_op
		b.pressed.connect(func() -> void: _presionar_bloque_refuerzo(op_str))
		col_izq.add_child(b)
		botones_refuerzo.append(b)

	lista_algoritmo_refuerzo = VBoxContainer.new()
	lista_algoritmo_refuerzo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lista_algoritmo_refuerzo.add_theme_constant_override("separation", 4)
	columnas.add_child(lista_algoritmo_refuerzo)

	var fila_acc := HBoxContainer.new()
	fila_acc.alignment = BoxContainer.ALIGNMENT_CENTER
	fila_acc.add_theme_constant_override("separation", 12)
	vbox.add_child(fila_acc)

	var btn_limp := Button.new()
	_estilizar_boton(btn_limp, "↺ Reiniciar práctica", Color("#334155"), Color("#64748B"), Vector2(165, 36))
	btn_limp.pressed.connect(_reiniciar_refuerzo)
	fila_acc.add_child(btn_limp)

	var btn_val := Button.new()
	_estilizar_boton(btn_val, "▶ Comprobar práctica", Color("#065F46"), Color("#34D399"), Vector2(185, 36))
	btn_val.pressed.connect(_validar_refuerzo)
	fila_acc.add_child(btn_val)

	var btn_man := Button.new()
	_estilizar_boton(btn_man, "📖 Abrir Manual", Color("#1E3A8A"), Color("#60A5FA"), Vector2(160, 36))
	btn_man.pressed.connect(func() -> void:
		if sistema_puntos != null:
			sistema_puntos.call("bloquear_manual_por_examen", false)
			sistema_puntos.call("abrir_manual_nivel3")
	)
	fila_acc.add_child(btn_man)

	lbl_feedback_refuerzo = Label.new()
	lbl_feedback_refuerzo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_feedback_refuerzo.add_theme_font_size_override("font_size", 14)
	vbox.add_child(lbl_feedback_refuerzo)

	_reiniciar_refuerzo()


func _reiniciar_refuerzo() -> void:
	bloques_refuerzo_colocados = ["", "", "", ""]
	if lbl_feedback_refuerzo != null:
		lbl_feedback_refuerzo.text = ""
	_renderizar_refuerzo()


func _presionar_bloque_refuerzo(texto_op: String) -> void:
	var pos: int = bloques_refuerzo_colocados.find(texto_op)
	if pos != -1:
		bloques_refuerzo_colocados.remove_at(pos)
		bloques_refuerzo_colocados.append("")
		_renderizar_refuerzo()
		return
	var libre: int = bloques_refuerzo_colocados.find("")
	if libre == -1:
		return
	bloques_refuerzo_colocados[libre] = texto_op
	_renderizar_refuerzo()


func _quitar_slot_refuerzo(idx: int) -> void:
	if idx < 0 or idx >= bloques_refuerzo_colocados.size():
		return
	if bloques_refuerzo_colocados[idx] == "":
		return
	bloques_refuerzo_colocados.remove_at(idx)
	bloques_refuerzo_colocados.append("")
	_renderizar_refuerzo()


func _renderizar_refuerzo() -> void:
	for i in range(botones_refuerzo.size()):
		var b: Button = botones_refuerzo[i]
		var txt: String = OPCIONES_REFUERZO[i]
		if bloques_refuerzo_colocados.has(txt):
			b.text = txt
			b.modulate = Color(0.75, 0.92, 1.0, 0.85)
		else:
			b.text = txt
			b.modulate = Color(1, 1, 1, 1)

	if lista_algoritmo_refuerzo == null:
		return
	for h in lista_algoritmo_refuerzo.get_children():
		lista_algoritmo_refuerzo.remove_child(h)
		h.queue_free()

	var lineas: PackedStringArray = PLANTILLA_REFUERZO.split("\n")
	for l in lineas:
		var limpio: String = l.strip_edges()
		if limpio == "":
			continue
		var slot_idx: int = -1
		for s in range(4):
			if limpio == "[ Espacio " + str(s + 1) + " ]":
				slot_idx = s
				break
		if slot_idx != -1:
			var btn_s := Button.new()
			btn_s.alignment = HORIZONTAL_ALIGNMENT_LEFT
			btn_s.add_theme_font_size_override("font_size", 13)
			var val: String = bloques_refuerzo_colocados[slot_idx]
			if val != "":
				btn_s.text = val
				btn_s.pressed.connect(_quitar_slot_refuerzo.bind(slot_idx))
			else:
				btn_s.text = "▸  Selecciona un bloque aquí..."
				btn_s.disabled = true
			lista_algoritmo_refuerzo.add_child(btn_s)
		else:
			var lbl := Label.new()
			lbl.text = l
			lbl.add_theme_font_size_override("font_size", 13)
			lbl.add_theme_color_override("font_color", Color("#E2E8F0"))
			lista_algoritmo_refuerzo.add_child(lbl)


func _validar_refuerzo() -> void:
	if bloques_refuerzo_colocados.find("") != -1:
		lbl_feedback_refuerzo.text = "Completa los 4 bloques de práctica antes de comprobar."
		lbl_feedback_refuerzo.add_theme_color_override("font_color", Color("#FBBF24"))
		return
	for i in range(4):
		if bloques_refuerzo_colocados[i] != CORRECTA_REFUERZO[i]:
			lbl_feedback_refuerzo.text = "Revisa la guía amarilla: primero el ciclo while, luego input(), después el if con or y finalmente estable = True."
			lbl_feedback_refuerzo.add_theme_color_override("font_color", Color("#F87171"))
			return
	lbl_feedback_refuerzo.text = "✓ ¡Actividad de refuerzo completada! Ya estás listo para presionar 'Reintentar examen'."
	lbl_feedback_refuerzo.add_theme_color_override("font_color", Color("#4ADE80"))


func _estilizar_boton(boton: Button, texto: String, fondo: Color, borde: Color, tamano: Vector2) -> void:
	boton.text = texto
	boton.custom_minimum_size = tamano
	boton.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	boton.add_theme_font_size_override("font_size", 15)
	boton.add_theme_color_override("font_color", Color("#F8FAFC"))

	var normal := StyleBoxFlat.new()
	normal.bg_color = fondo
	normal.border_color = borde
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(8)
	normal.content_margin_left = 14
	normal.content_margin_right = 14
	normal.content_margin_top = 6
	normal.content_margin_bottom = 6
	boton.add_theme_stylebox_override("normal", normal)

	var hover := normal.duplicate()
	hover.bg_color = fondo.lightened(0.15)
	hover.border_color = borde.lightened(0.2)
	boton.add_theme_stylebox_override("hover", hover)
	boton.add_theme_stylebox_override("pressed", normal)


func mostrar_actividades_refuerzo() -> void:
	if dj_manager != null and dj_manager.has_method("play_sfx"):
		dj_manager.call("play_sfx", "boton")
	if panel_refuerzo != null:
		panel_refuerzo.visible = not panel_refuerzo.visible


func continuar_al_final() -> void:
	if dj_manager != null and dj_manager.has_method("play_sfx"):
		dj_manager.call("play_sfx", "ui_abrir")
	get_tree().change_scene_to_file(ESCENA_FINAL_PANKO)


func reintentar_examen() -> void:
	if dj_manager != null and dj_manager.has_method("play_sfx"):
		dj_manager.call("play_sfx", "ui_abrir")
	if sistema_puntos != null and sistema_puntos.has_method("bloquear_manual_por_examen"):
		sistema_puntos.call("bloquear_manual_por_examen", true)

	var primera_pregunta: String = "res://scenes/ExamenNivel3/Pregunta1.tscn"
	if sistema_puntos != null and sistema_puntos.has_method("iniciar_nuevo_intento_examen"):
		primera_pregunta = str(sistema_puntos.call("iniciar_nuevo_intento_examen"))
	get_tree().change_scene_to_file(primera_pregunta)


func volver_al_nivel() -> void:
	if dj_manager != null and dj_manager.has_method("play_sfx"):
		dj_manager.call("play_sfx", "ui_cerrar")
	get_tree().change_scene_to_file(ESCENA_SALA_10)
