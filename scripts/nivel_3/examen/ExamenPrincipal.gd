extends PanelContainer

# ==========================================
# MGTS - NIVEL 3 - EXAMEN PRINCIPAL (PORTADA Y GESTIÓN DE INTENTO)
# Selecciona 3 preguntas sin repetición del banco de 6 escenas
# (Pregunta1.tscn a Pregunta6.tscn) y gestiona el inicio del examen.
# ==========================================

const ESCENA_SALA_10: String = "res://scenes/Nivel_3/10Cámara de Rescat.tscn"

@onready var sistema_puntos: Node = get_node_or_null("/root/PuntajesNivel3")
@onready var dj_manager: Node = get_node_or_null("/root/DJManager")

var iniciando: bool = false


func _ready() -> void:
	show()
	if sistema_puntos != null and sistema_puntos.has_method("bloquear_manual_por_examen"):
		sistema_puntos.call("bloquear_manual_por_examen", true)

	_construir_interfaz_inicio()


func _construir_interfaz_inicio() -> void:
	for hijo in get_children():
		remove_child(hijo)
		hijo.queue_free()

	var contenedor := VBoxContainer.new()
	contenedor.name = "ContenidoExamenPrincipal"
	contenedor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contenedor.size_flags_vertical = Control.SIZE_EXPAND_FILL
	contenedor.alignment = BoxContainer.ALIGNMENT_CENTER
	contenedor.add_theme_constant_override("separation", 18)
	add_child(contenedor)

	var insignia_sup := Label.new()
	insignia_sup.text = "⚡ EVALUACIÓN FINAL DEL COMPLEJO SUBTERRÁNEO ⚡"
	insignia_sup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	insignia_sup.add_theme_color_override("font_color", Color("#38BDF8"))
	insignia_sup.add_theme_font_size_override("font_size", 16)
	contenedor.add_child(insignia_sup)

	var lbl_titulo := Label.new()
	lbl_titulo.text = "EXAMEN FINAL – PROTOCOLO DE RESCATE DE PANKO"
	lbl_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_titulo.add_theme_color_override("font_color", Color("#E9D5FF"))
	lbl_titulo.add_theme_font_size_override("font_size", 28)
	contenedor.add_child(lbl_titulo)

	var tarjeta := PanelContainer.new()
	tarjeta.custom_minimum_size = Vector2(780, 260)
	tarjeta.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var estilo_tarjeta := StyleBoxFlat.new()
	estilo_tarjeta.bg_color = Color(0.06, 0.10, 0.19, 0.96)
	estilo_tarjeta.border_color = Color("#60A5FA")
	estilo_tarjeta.set_border_width_all(2)
	estilo_tarjeta.set_corner_radius_all(12)
	estilo_tarjeta.content_margin_left = 28
	estilo_tarjeta.content_margin_right = 28
	estilo_tarjeta.content_margin_top = 22
	estilo_tarjeta.content_margin_bottom = 22
	tarjeta.add_theme_stylebox_override("panel", estilo_tarjeta)
	contenedor.add_child(tarjeta)

	var vbox_info := VBoxContainer.new()
	vbox_info.add_theme_constant_override("separation", 12)
	tarjeta.add_child(vbox_info)

	var lbl_intro := Label.new()
	lbl_intro.text = (
		"Estás frente a la compuerta blindada donde se encuentra Panko. "
		+ "Para desbloquearla deberás resolver 3 desafíos seleccionados al azar de un banco de 6 preguntas."
	)
	lbl_intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_intro.add_theme_color_override("font_color", Color("#F1F5F9"))
	lbl_intro.add_theme_font_size_override("font_size", 17)
	vbox_info.add_child(lbl_intro)

	var lbl_reglas := Label.new()
	lbl_reglas.text = (
		"• Cada pregunta evalúa ciclos while, condicionales if/elif/else, operadores lógicos (and, or, not), contadores, acumuladores y banderas.\n"
		+ "• Haz clic en los bloques disponibles para colocarlos en el algoritmo (o haz clic sobre un bloque colocado para quitarlo).\n"
		+ "• Durante el examen no hay pistas ni acceso al manual.\n"
		+ "• Cuentas con un máximo de 3 errores permitidos en todo el intento."
	)
	lbl_reglas.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_reglas.add_theme_color_override("font_color", Color("#CBD5E1"))
	lbl_reglas.add_theme_font_size_override("font_size", 15)
	vbox_info.add_child(lbl_reglas)

	var completados: int = 0
	var puntos_actuales: int = 0
	if sistema_puntos != null:
		if sistema_puntos.has_method("obtener_cantidad_ejercicios_completados"):
			completados = int(sistema_puntos.call("obtener_cantidad_ejercicios_completados"))
		if sistema_puntos.has_method("obtener_puntos_totales"):
			puntos_actuales = int(sistema_puntos.call("obtener_puntos_totales"))

	var lbl_estado := Label.new()
	lbl_estado.text = "Progreso actual: %d/10 ejercicios resueltos  |  ★ Puntaje acumulado: %d pts" % [completados, puntos_actuales]
	lbl_estado.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_estado.add_theme_color_override("font_color", Color("#FBBF24"))
	lbl_estado.add_theme_font_size_override("font_size", 16)
	vbox_info.add_child(lbl_estado)

	var fila_botones := HBoxContainer.new()
	fila_botones.alignment = BoxContainer.ALIGNMENT_CENTER
	fila_botones.add_theme_constant_override("separation", 20)
	contenedor.add_child(fila_botones)

	var btn_iniciar := Button.new()
	btn_iniciar.name = "BotonIniciarExamen"
	_estilizar_boton(btn_iniciar, "▶ Iniciar examen (3 preguntas)", Color("#065F46"), Color("#34D399"), Vector2(280, 52))
	btn_iniciar.pressed.connect(iniciar_examen)
	fila_botones.add_child(btn_iniciar)

	var btn_volver := Button.new()
	btn_volver.name = "BotonVolverNivel"
	_estilizar_boton(btn_volver, "⬅ Volver al nivel", Color("#334155"), Color("#94A3B8"), Vector2(220, 52))
	btn_volver.pressed.connect(volver_al_nivel)
	fila_botones.add_child(btn_volver)


func _estilizar_boton(boton: Button, texto: String, fondo: Color, borde: Color, tamano: Vector2) -> void:
	boton.text = texto
	boton.custom_minimum_size = tamano
	boton.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	boton.add_theme_font_size_override("font_size", 16)
	boton.add_theme_color_override("font_color", Color("#F8FAFC"))

	var normal := StyleBoxFlat.new()
	normal.bg_color = fondo
	normal.border_color = borde
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(10)
	normal.content_margin_left = 16
	normal.content_margin_right = 16
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8
	boton.add_theme_stylebox_override("normal", normal)

	var hover := normal.duplicate()
	hover.bg_color = fondo.lightened(0.16)
	hover.border_color = borde.lightened(0.2)
	boton.add_theme_stylebox_override("hover", hover)
	boton.add_theme_stylebox_override("pressed", normal)


func iniciar_examen() -> void:
	if iniciando:
		return
	iniciando = true
	if dj_manager != null and dj_manager.has_method("play_sfx"):
		dj_manager.call("play_sfx", "ui_abrir")

	var primera_escena: String = "res://scenes/ExamenNivel3/Pregunta1.tscn"
	if sistema_puntos != null and sistema_puntos.has_method("iniciar_nuevo_intento_examen"):
		primera_escena = str(sistema_puntos.call("iniciar_nuevo_intento_examen"))

	get_tree().change_scene_to_file(primera_escena)


func volver_al_nivel() -> void:
	if dj_manager != null and dj_manager.has_method("play_sfx"):
		dj_manager.call("play_sfx", "ui_cerrar")
	get_tree().change_scene_to_file(ESCENA_SALA_10)
