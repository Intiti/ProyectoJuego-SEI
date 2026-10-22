extends PanelContainer

# ==========================================
# MGTS - NIVEL 2: VENTANA POPUP DE TAREA COMPLETADA Y CELEBRACIÓN
# ==========================================

signal completado_cerrado

@export var es_ultimo_ejercicio: bool = false
@export_file("*.tscn") var siguiente_escena_directa: String = ""

var jugador: CharacterBody2D = null

var label_titulo: Label
var label_subtitulo: Label
var label_puntos: Label
var label_desglose: Label
var panel_insignia: PanelContainer
var label_insignia: Label
var btn_continuar: Button
var btn_cerrar_popup: Button

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS # Asegura interacción incluso si el árbol está pausado
	_construir_interfaz()
	call_deferred("_resolver_referencias")

func _resolver_referencias() -> void:
	jugador = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if jugador == null:
		var root = get_tree().current_scene
		if root:
			jugador = root.get_node_or_null("Player") as CharacterBody2D

func _construir_interfaz() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	custom_minimum_size = Vector2(740, 440)
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.07, 0.12, 0.98)
	style.border_color = Color(0.3, 0.95, 0.8, 1.0)
	style.set_border_width_all(3)
	style.set_corner_radius_all(16)
	style.content_margin_left = 32
	style.content_margin_top = 22
	style.content_margin_right = 32
	style.content_margin_bottom = 24
	add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(vbox)
	
	# Barra superior con título y botón de cierre directo
	var top_bar = HBoxContainer.new()
	top_bar.mouse_filter = Control.MOUSE_FILTER_PASS
	vbox.add_child(top_bar)
	
	var spacer_left = Control.new()
	spacer_left.custom_minimum_size = Vector2(36, 0)
	top_bar.add_child(spacer_left)
	
	label_titulo = Label.new()
	label_titulo.text = "✨ ¡TAREA COMPLETADA CON ÉXITO! ✨"
	label_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label_titulo.add_theme_font_size_override("font_size", 24)
	label_titulo.add_theme_color_override("font_color", Color(0.4, 1.0, 0.85))
	top_bar.add_child(label_titulo)
	
	btn_cerrar_popup = Button.new()
	btn_cerrar_popup.text = "✕"
	btn_cerrar_popup.custom_minimum_size = Vector2(36, 36)
	btn_cerrar_popup.tooltip_text = "Cerrar ventana emergente"
	btn_cerrar_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	btn_cerrar_popup.focus_mode = Control.FOCUS_ALL
	var style_btn_close = StyleBoxFlat.new()
	style_btn_close.bg_color = Color(0.3, 0.15, 0.18, 0.9)
	style_btn_close.border_color = Color(0.9, 0.4, 0.4, 1.0)
	style_btn_close.set_border_width_all(1)
	style_btn_close.set_corner_radius_all(8)
	btn_cerrar_popup.add_theme_stylebox_override("normal", style_btn_close)
	btn_cerrar_popup.pressed.connect(_on_cerrar_pressed)
	top_bar.add_child(btn_cerrar_popup)
	
	label_subtitulo = Label.new()
	label_subtitulo.text = "El bosque ancestral reconoce tu dominio del código."
	label_subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_subtitulo.add_theme_font_size_override("font_size", 18)
	label_subtitulo.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95))
	vbox.add_child(label_subtitulo)
	
	label_puntos = Label.new()
	label_puntos.text = "+80 PUNTOS"
	label_puntos.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_puntos.add_theme_font_size_override("font_size", 38)
	label_puntos.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35))
	vbox.add_child(label_puntos)
	
	label_desglose = Label.new()
	label_desglose.text = "Solución sin errores (Puntos completos)"
	label_desglose.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_desglose.add_theme_font_size_override("font_size", 16)
	label_desglose.add_theme_color_override("font_color", Color(0.7, 0.8, 0.85))
	vbox.add_child(label_desglose)
	
	# Panel de Insignia desbloqueada
	panel_insignia = PanelContainer.new()
	panel_insignia.visible = false
	panel_insignia.mouse_filter = Control.MOUSE_FILTER_PASS
	var style_ins = StyleBoxFlat.new()
	style_ins.bg_color = Color(0.18, 0.14, 0.04, 0.95)
	style_ins.border_color = Color(1.0, 0.85, 0.2, 1.0)
	style_ins.set_border_width_all(2)
	style_ins.set_corner_radius_all(10)
	style_ins.content_margin_left = 16
	style_ins.content_margin_top = 8
	style_ins.content_margin_right = 16
	style_ins.content_margin_bottom = 8
	panel_insignia.add_theme_stylebox_override("panel", style_ins)
	vbox.add_child(panel_insignia)
	
	label_insignia = Label.new()
	label_insignia.text = "🏆 ¡Nueva Insignia Obtenida: Cazador de Ciclos!"
	label_insignia.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_insignia.add_theme_font_size_override("font_size", 17)
	label_insignia.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
	panel_insignia.add_child(label_insignia)
	
	# Botón de acción principal
	btn_continuar = Button.new()
	btn_continuar.text = "Avanzar por el Sendero →"
	btn_continuar.custom_minimum_size = Vector2(300, 50)
	btn_continuar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn_continuar.mouse_filter = Control.MOUSE_FILTER_STOP
	btn_continuar.focus_mode = Control.FOCUS_ALL
	btn_continuar.add_theme_font_size_override("font_size", 20)
	
	var style_btn = StyleBoxFlat.new()
	style_btn.bg_color = Color(0.15, 0.55, 0.45, 1.0)
	style_btn.border_color = Color(0.3, 0.95, 0.8, 1.0)
	style_btn.set_border_width_all(1)
	style_btn.set_corner_radius_all(10)
	btn_continuar.add_theme_stylebox_override("normal", style_btn)
	btn_continuar.pressed.connect(_on_continuar_pressed)
	vbox.add_child(btn_continuar)

func mostrar_celebracion(codigo: String, titulo: String, puntos: int, errores: int) -> void:
	_resolver_referencias()
	visible = true
	move_to_front()
	
	label_subtitulo.text = titulo
	label_puntos.text = "+%d PUNTOS" % puntos
	
	var texto_desglose = ""
	if errores == 0:
		texto_desglose = "¡Solución impecable al primer intento! Puntuación máxima."
	elif errores == 1:
		texto_desglose = "1 error detectado: ¡Sin penalización!"
	elif errores == 2:
		texto_desglose = "2 errores cometidos: Descuento del 25%."
	else:
		texto_desglose = "%d errores cometidos: Descuento del 50%%." % errores

	var puntajes = get_node_or_null("/root/PuntajesNivel2")

	# Desglose real con las reglas compartidas (base, penalización y bono de racha).
	var d: Dictionary = GameData.lastBreakdown
	if String(d.get("code", "")) == codigo:
		texto_desglose += "\nPuntaje base:  %d pts" % int(d["base"])
		if int(d["pen"]) > 0:
			texto_desglose += "   ·   Penalización:  -%d pts" % int(d["pen"])
		if int(d["bonus"]) > 0:
			texto_desglose += "   ·   Bonus racha (x%d):  +%d pts" % [GameData.rachaGlobal, int(d["bonus"])]

	label_desglose.text = texto_desglose
	
	# Comprobar si se obtuvo la insignia oficial
	if puntajes and puntajes.tiene_insignia("Cazador de Ciclos"):
		panel_insignia.visible = true
	else:
		panel_insignia.visible = false
	
	if es_ultimo_ejercicio:
		btn_continuar.text = "Cruzar el Puente Hacia el Altar →"
	else:
		btn_continuar.text = "Aceptar y Avanzar →"
	
	# Asignar foco para permitir navegación por teclado
	btn_continuar.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE and not event.echo):
		get_viewport().set_input_as_handled()
		_cerrar_popup()
	elif event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_ENTER and not event.echo):
		get_viewport().set_input_as_handled()
		_on_continuar_pressed()

func _on_cerrar_pressed() -> void:
	_cerrar_popup()

func _on_continuar_pressed() -> void:
	_cerrar_popup()

func _cerrar_popup() -> void:
	visible = false
	completado_cerrado.emit()
	
	# Reanudar estado de juego si estaba pausado
	if get_tree().paused:
		get_tree().paused = false
	
	if jugador:
		jugador.set_physics_process(true)
		jugador.set_process_unhandled_input(true)
		jugador.set_process_input(true)
	
	print("VentanaCompletadoN2: Popup de tarea completada cerrado exitosamente.")
