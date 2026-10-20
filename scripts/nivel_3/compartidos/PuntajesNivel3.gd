extends Node

# ==========================================
# MGTS - NIVEL 3
# SISTEMA GLOBAL DE PUNTAJES, GAMIFICACIÓN,
# IDENTIFICACIÓN DE ESTUDIANTE, MANUAL Y REGISTRO LOG (JSON)
# ==========================================

signal puntos_actualizados(total: int)

const RUTA_LOG_JSON: String = "user://log_interacciones_mgts.json"
const RUTA_LOG_JSONL: String = "user://log_interacciones_mgts.jsonl"
const RUTA_LOG_EXAMEN_JSONL: String = "user://log_examen_nivel3.jsonl"
const RUTA_PROGRESO_JSON: String = "user://progreso_nivel3_mgts.json"
const RUTA_PERFIL_JSON: String = "user://perfil_estudiante_mgts.json"
const RUTA_RANKING_JSON: String = "user://ranking_nivel3_mgts.json"

const PUNTOS_BASE_EJERCICIO: int = 240 # 4 bloques * 60 pts
const MAX_ERRORES_EXAMEN: int = 3
const TOTAL_PREGUNTAS_INTENTO_EXAMEN: int = 3

const ESCENAS_BANCO_EXAMEN: Dictionary = {
	1: "res://scenes/ExamenNivel3/Pregunta1.tscn",
	2: "res://scenes/ExamenNivel3/Pregunta2.tscn",
	3: "res://scenes/ExamenNivel3/Pregunta3.tscn",
	4: "res://scenes/ExamenNivel3/Pregunta4.tscn",
	5: "res://scenes/ExamenNivel3/Pregunta5.tscn",
	6: "res://scenes/ExamenNivel3/Pregunta6.tscn"
}

const RUTA_EXAMEN_PRINCIPAL: String = "res://scenes/ExamenNivel3/ExamenPrincipal.tscn"
const RUTA_RESULTADO_EXAMEN: String = "res://scenes/ExamenNivel3/ResultadoExamen.tscn"
const ManualNivel3Script = preload("res://scripts/nivel_3/compartidos/ManualNivel3.gd")

# Variables originales conservadas por compatibilidad
var puntos_por_ejercicio: Dictionary = {}
var ejercicios_completados: Dictionary = {}
var puntos_totales: int = 0

# Identificación del participante para prueba piloto
var id_jugador: String = ""
var identificacion_confirmada_sesion: bool = false

# Estado detallado de gamificación y progresión
var errores_por_ejercicio: Dictionary = {}
var pistas_por_ejercicio: Dictionary = {}
var intentos_por_ejercicio: Dictionary = {}
var resuelto_sin_ayuda: Dictionary = {}

var examen_completado: bool = false
var examen_aprobado: bool = false
var puntaje_examen: int = 0
var errores_examen: int = 0
var intentos_examen: int = 0
var panko_rescatado: bool = false

# Estado de la sesión activa del Examen Final (3 preguntas de 6)
var examen_preguntas_seleccionadas: Array[int] = []
var examen_indice_actual: int = 0
var examen_errores_actuales: int = 0
var examen_respuestas_correctas: int = 0
var examen_aprobado_actual: bool = false
var examen_finalizado_actual: bool = false
var examen_detalle_intento: Array = []

# Instancia del manual original recuperado para Nivel 3
var manual_nivel3: CanvasLayer = null

# Catálogo de 11 insignias del Nivel 3 (10 ejercicios E3.1..E3.10 + 1 Examen Final)
const INSIGNIAS_ORDEN: Array[String] = [
	"insignia_e3_1",
	"insignia_e3_2",
	"insignia_e3_3",
	"insignia_e3_4",
	"insignia_e3_5",
	"insignia_e3_6",
	"insignia_e3_7",
	"insignia_e3_8",
	"insignia_e3_9",
	"insignia_e3_10",
	"insignia_examen_final"
]

const INSIGNIAS_INFO: Dictionary = {
	"insignia_e3_1": {
		"codigo": "E3.1",
		"nombre": "E3.1 – La puerta del laboratorio",
		"descripcion": "Desbloquear la puerta de acceso al laboratorio validando la clave en hasta 3 intentos."
	},
	"insignia_e3_2": {
		"codigo": "E3.2",
		"nombre": "E3.2 – El núcleo de energía",
		"descripcion": "Cargar el núcleo de energía acumulando lecturas hasta alcanzar el umbral requerido."
	},
	"insignia_e3_3": {
		"codigo": "E3.3",
		"nombre": "E3.3 – Los pasos del dron",
		"descripcion": "Guiar al dron explorador por los conductos hasta encontrar la salida segura."
	},
	"insignia_e3_4": {
		"codigo": "E3.4",
		"nombre": "E3.4 – El sistema de enfriamiento",
		"descripcion": "Estabilizar la temperatura criogénica combinando condiciones en el ciclo while."
	},
	"insignia_e3_5": {
		"codigo": "E3.5",
		"nombre": "E3.5 – Conductos de ventilación",
		"descripcion": "Purificar los conductos de ventilación procesando lecturas con ciclos y condicionales."
	},
	"insignia_e3_6": {
		"codigo": "E3.6",
		"nombre": "E3.6 – Los registros genéticos",
		"descripcion": "Clasificar las muestras del laboratorio genético con múltiples criterios lógicos."
	},
	"insignia_e3_7": {
		"codigo": "E3.7",
		"nombre": "E3.7 – El escudo de radiación",
		"descripcion": "Mantener activo el escudo antirradiación mediante acumuladores y control de riesgo."
	},
	"insignia_e3_8": {
		"codigo": "E3.8",
		"nombre": "E3.8 – Los portales de contención",
		"descripcion": "Sincronizar los portales de contención usando operadores lógicos compuestos."
	},
	"insignia_e3_9": {
		"codigo": "E3.9",
		"nombre": "E3.9 – Las señales del servidor central",
		"descripcion": "Filtrar y validar las señales del servidor central con estructuras anidadas."
	},
	"insignia_e3_10": {
		"codigo": "E3.10",
		"nombre": "E3.10 – El protocolo de rescate",
		"descripcion": "Ejecutar el protocolo de rescate en la cámara de contención para localizar a Panko."
	},
	"insignia_examen_final": {
		"codigo": "EX3_FINAL",
		"nombre": "Examen Final del Nivel 3",
		"descripcion": "Aprobar la evaluación integradora final del complejo subterráneo."
	}
}

var insignias_otorgadas: Dictionary = {}
var intentos_insignias: Dictionary = {}
var ejercicios_perfectos: Dictionary = {}
var perfil_insignias_activo: String = ""
var examen_aprobado_para_insignia: bool = false
var modalidad_insignias: Dictionary = {} # "SIN_AYUDA" o "CON_AYUDA"
var ranking_local: Array = []


func _ready() -> void:
	randomize()
	_cargar_perfil_estudiante()
	_activar_perfil_insignias()
	# Iniciar siempre la sesión activa con puntaje en 0 para que los puntos
	# reflejen exclusivamente los ejercicios resueltos en la partida actual.
	puntos_por_ejercicio.clear()
	ejercicios_completados.clear()
	puntos_totales = 0
	_cargar_ranking_local()
	_asegurar_archivos_log()
	_inicializar_manual_nivel3()

	get_tree().node_added.connect(_al_cambiar_escena)
	call_deferred("_verificar_escena_inicial")


func _inicializar_manual_nivel3() -> void:
	if manual_nivel3 != null and is_instance_valid(manual_nivel3):
		return
	manual_nivel3 = ManualNivel3Script.new()
	manual_nivel3.name = "ManualNivel3"
	add_child(manual_nivel3)
	manual_nivel3.call("set_visibilidad_boton_flotante", false)


func abrir_manual_nivel3() -> void:
	_inicializar_manual_nivel3()
	if manual_nivel3 != null and manual_nivel3.has_method("abrir_manual"):
		manual_nivel3.call("abrir_manual")


func cerrar_manual_nivel3() -> void:
	if manual_nivel3 != null and manual_nivel3.has_method("cerrar_manual"):
		manual_nivel3.call("cerrar_manual")


func alternar_manual_nivel3() -> void:
	_inicializar_manual_nivel3()
	if manual_nivel3 != null and manual_nivel3.has_method("alternar_manual"):
		manual_nivel3.call("alternar_manual")


func bloquear_manual_por_examen(bloqueado: bool) -> void:
	_inicializar_manual_nivel3()
	if manual_nivel3 != null and manual_nivel3.has_method("set_bloqueado_examen"):
		manual_nivel3.call("set_bloqueado_examen", bloqueado)
	var manual_global: Node = get_node_or_null("/root/ManualUi")
	if manual_global != null and manual_global.has_method("set_bloqueado_examen"):
		manual_global.call("set_bloqueado_examen", bloqueado)


func _al_cambiar_escena(nodo: Node) -> void:
	if nodo == get_tree().current_scene:
		call_deferred("_verificar_escena_inicial")


func _verificar_escena_inicial() -> void:
	var escena: Node = get_tree().current_scene
	if escena == null:
		return
	var ruta: String = escena.scene_file_path
	var es_examen: bool = ruta.contains("scenes/ExamenNivel3/") or ruta.contains("scenes/Nivel_3/examen/")
	var es_final: bool = ruta.ends_with("Final.tscn")
	var es_laboratorio_n3: bool = ruta.contains("scenes/Nivel_3/") and not es_examen and not es_final

	_inicializar_manual_nivel3()
	if es_examen:
		bloquear_manual_por_examen(true)
		if manual_nivel3 != null and manual_nivel3.has_method("set_visibilidad_boton_flotante"):
			manual_nivel3.call("set_visibilidad_boton_flotante", false)
	elif es_laboratorio_n3:
		bloquear_manual_por_examen(false)
		if manual_nivel3 != null and manual_nivel3.has_method("set_visibilidad_boton_flotante"):
			manual_nivel3.call("set_visibilidad_boton_flotante", true)
	else:
		if manual_nivel3 != null and manual_nivel3.has_method("cerrar_manual"):
			manual_nivel3.call("cerrar_manual")
		if manual_nivel3 != null and manual_nivel3.has_method("set_visibilidad_boton_flotante"):
			manual_nivel3.call("set_visibilidad_boton_flotante", false)

	if ruta.contains("MainMenu") or ruta.contains("nivel_0/Intro"):
		reiniciar_puntajes()

	if es_laboratorio_n3:
		mostrar_hud_identificacion_y_audio(escena)


# ==========================================
# GESTIÓN DEL EXAMEN FINAL EN ESCENAS SEPARADAS
# ==========================================

func iniciar_nuevo_intento_examen() -> String:
	var banco_oa2_fuerte: Array[int] = [1, 3, 4]
	var banco_oa3_fuerte: Array[int] = [2, 5, 6]
	banco_oa2_fuerte.shuffle()
	banco_oa3_fuerte.shuffle()

	var seleccion: Array[int] = []
	# Garantizar cobertura de OA2 y OA3 sin repetir preguntas
	seleccion.append(banco_oa2_fuerte[0])
	seleccion.append(banco_oa3_fuerte[0])

	var restantes: Array[int] = [
		banco_oa2_fuerte[1],
		banco_oa2_fuerte[2],
		banco_oa3_fuerte[1],
		banco_oa3_fuerte[2]
	]
	restantes.shuffle()
	seleccion.append(restantes[0])
	seleccion.shuffle()

	examen_preguntas_seleccionadas = seleccion
	examen_indice_actual = 0
	examen_errores_actuales = 0
	examen_respuestas_correctas = 0
	examen_aprobado_actual = false
	examen_finalizado_actual = false
	examen_detalle_intento = []

	return obtener_escena_pregunta_examen_actual()


func asegurar_sesion_examen_activa() -> void:
	if examen_preguntas_seleccionadas.size() != TOTAL_PREGUNTAS_INTENTO_EXAMEN or examen_finalizado_actual:
		iniciar_nuevo_intento_examen()


func obtener_escena_pregunta_examen_actual() -> String:
	asegurar_sesion_examen_activa()
	var idx: int = clampi(examen_indice_actual, 0, examen_preguntas_seleccionadas.size() - 1)
	var id_preg: int = examen_preguntas_seleccionadas[idx]
	return str(ESCENAS_BANCO_EXAMEN.get(id_preg, "res://scenes/ExamenNivel3/Pregunta1.tscn"))


func obtener_id_pregunta_banco_actual() -> int:
	asegurar_sesion_examen_activa()
	var idx: int = clampi(examen_indice_actual, 0, examen_preguntas_seleccionadas.size() - 1)
	return examen_preguntas_seleccionadas[idx]


func obtener_numero_pregunta_examen_actual() -> int:
	return clampi(examen_indice_actual + 1, 1, TOTAL_PREGUNTAS_INTENTO_EXAMEN)


func obtener_total_preguntas_examen_intento() -> int:
	return TOTAL_PREGUNTAS_INTENTO_EXAMEN


func obtener_errores_examen_actuales() -> int:
	return examen_errores_actuales


func obtener_max_errores_examen() -> int:
	return MAX_ERRORES_EXAMEN


func registrar_error_en_examen() -> bool:
	examen_errores_actuales += 1
	return examen_errores_actuales >= MAX_ERRORES_EXAMEN


func registrar_pregunta_examen_superada(id_banco: int, titulo: String) -> String:
	examen_respuestas_correctas += 1
	examen_detalle_intento.append({
		"id_banco": id_banco,
		"titulo": titulo,
		"correcta": true
	})
	examen_indice_actual += 1

	if examen_indice_actual >= TOTAL_PREGUNTAS_INTENTO_EXAMEN:
		examen_aprobado_actual = true
		examen_finalizado_actual = true
		registrar_resultado_examen(true, examen_errores_actuales, 300)
		return RUTA_RESULTADO_EXAMEN

	var id_sig: int = examen_preguntas_seleccionadas[examen_indice_actual]
	return str(ESCENAS_BANCO_EXAMEN.get(id_sig, RUTA_RESULTADO_EXAMEN))


func reprobar_intento_examen_actual(id_banco: int, titulo: String) -> String:
	examen_detalle_intento.append({
		"id_banco": id_banco,
		"titulo": titulo,
		"correcta": false
	})
	examen_aprobado_actual = false
	examen_finalizado_actual = true
	registrar_resultado_examen(false, examen_errores_actuales, 0)
	return RUTA_RESULTADO_EXAMEN


# ==========================================
# IDENTIFICACIÓN DE ESTUDIANTES (PRUEBA PILOTO)
# ==========================================

func _obtener_gamedata() -> Node:
	if not is_inside_tree():
		return null
	return get_node_or_null("/root/GameData")


func _cargar_perfil_estudiante() -> void:
	# 1. Revisar si GameData ya tiene un alias ingresado en el menú principal
	var game_data: Node = _obtener_gamedata()
	if game_data != null:
		var nombre_gd: String = str(game_data.get("playerName")).strip_edges()
		if nombre_gd != "" and nombre_gd != "Player" and nombre_gd != "SIN_ASIGNAR" and nombre_gd != "<null>":
			id_jugador = nombre_gd
			identificacion_confirmada_sesion = true
			_guardar_perfil_estudiante()
			return

	# 2. Revisar si existe un perfil guardado en user://
	if FileAccess.file_exists(RUTA_PERFIL_JSON):
		var archivo := FileAccess.open(RUTA_PERFIL_JSON, FileAccess.READ)
		if archivo != null:
			var texto: String = archivo.get_as_text()
			archivo.close()
			var json := JSON.new()
			if json.parse(texto) == OK and typeof(json.data) == TYPE_DICTIONARY:
				var guardado: String = str(json.data.get("idJugador", "")).strip_edges()
				if guardado != "" and guardado != "SIN_ASIGNAR":
					id_jugador = guardado
					_sincronizar_id_con_gamedata()
					return

	# 3. Generar código anónimo único por defecto para la prueba piloto
	var semilla: int = int(Time.get_unix_time_from_system()) % 10000
	id_jugador = "EST-%04d" % semilla
	_sincronizar_id_con_gamedata()
	_guardar_perfil_estudiante()


func _guardar_perfil_estudiante() -> void:
	var archivo := FileAccess.open(RUTA_PERFIL_JSON, FileAccess.WRITE)
	if archivo == null:
		return
	var datos: Dictionary = {
		"idJugador": id_jugador,
		"actualizado": Time.get_datetime_string_from_system(false, true)
	}
	archivo.store_string(JSON.stringify(datos, "\t"))
	archivo.close()


func _sincronizar_id_con_gamedata() -> void:
	var game_data: Node = _obtener_gamedata()
	if game_data != null and "playerName" in game_data:
		game_data.set("playerName", id_jugador)


func obtener_id_jugador() -> String:
	var game_data: Node = _obtener_gamedata()
	if game_data != null and "playerName" in game_data:
		var nombre_gd: String = str(game_data.get("playerName")).strip_edges()
		if nombre_gd != "" and nombre_gd != "Player" and nombre_gd != "SIN_ASIGNAR" and nombre_gd != "<null>":
			if nombre_gd != id_jugador:
				id_jugador = nombre_gd
				_guardar_perfil_estudiante()
			return id_jugador

	if id_jugador.strip_edges() == "" or id_jugador == "SIN_ASIGNAR":
		_cargar_perfil_estudiante()
	return id_jugador


func establecer_id_jugador(nuevo_id: String) -> void:
	var limpio: String = nuevo_id.strip_edges()
	if limpio == "":
		return
	id_jugador = limpio
	identificacion_confirmada_sesion = true
	_sincronizar_id_con_gamedata()
	_guardar_perfil_estudiante()
	_activar_perfil_insignias()
	_guardar_progreso_local()
	print("MGTS Nivel 3 - ID de estudiante establecido: ", id_jugador)


func mostrar_hud_identificacion_y_audio(escena_padre: Node) -> void:
	if escena_padre == null or escena_padre.get_node_or_null("HUDNivel3MGTS") != null:
		return

	# Asegurar que el ID interno esté listo para los registros JSON sin mostrar controles en la UI
	obtener_id_jugador()

	var capa := CanvasLayer.new()
	capa.name = "HUDNivel3MGTS"
	capa.layer = 18

	# Puntos y audio alineados a la izquierda del Manual superior, sin mostrar el ID.
	var barra := PanelContainer.new()
	barra.name = "BarraSuperiorMGTS"
	barra.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	barra.offset_left = -440.0
	barra.offset_top = 12.0
	barra.offset_right = -140.0
	barra.offset_bottom = 48.0

	var estilo_barra := StyleBoxFlat.new()
	estilo_barra.bg_color = Color(0.06, 0.09, 0.16, 0.90)
	estilo_barra.border_color = Color("#36C8E8")
	estilo_barra.set_border_width_all(2)
	estilo_barra.set_corner_radius_all(8)
	estilo_barra.content_margin_left = 8.0
	estilo_barra.content_margin_right = 8.0
	estilo_barra.content_margin_top = 4.0
	estilo_barra.content_margin_bottom = 4.0
	barra.add_theme_stylebox_override("panel", estilo_barra)

	var fila := HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_theme_constant_override("separation", 12)
	barra.add_child(fila)

	var etiqueta_puntos := Label.new()
	etiqueta_puntos.name = "PuntosNivel3"
	etiqueta_puntos.text = "Puntos: %d" % obtener_puntos_totales()
	etiqueta_puntos.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	etiqueta_puntos.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	etiqueta_puntos.add_theme_font_size_override("font_size", 14)
	etiqueta_puntos.add_theme_color_override("font_color", Color("#FBBF24"))
	fila.add_child(etiqueta_puntos)
	var actualizar_puntos := func(total: int) -> void:
		etiqueta_puntos.text = "Puntos: %d" % total
	puntos_actualizados.connect(actualizar_puntos)
	etiqueta_puntos.tree_exiting.connect(func() -> void:
		if puntos_actualizados.is_connected(actualizar_puntos):
			puntos_actualizados.disconnect(actualizar_puntos)
	)

	var btn_audio := Button.new()
	btn_audio.name = "BotonSilencio"
	var dj: Node = get_node_or_null("/root/DJManager")
	var silenciado: bool = dj != null and dj.has_method("is_muted") and dj.call("is_muted")
	btn_audio.text = "Audio: OFF" if silenciado else "Audio: ON"
	btn_audio.custom_minimum_size = Vector2(96, 26)
	btn_audio.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_audio.add_theme_font_size_override("font_size", 14)
	fila.add_child(btn_audio)

	capa.add_child(barra)
	escena_padre.add_child(capa)

	btn_audio.pressed.connect(func() -> void:
		var dj_node: Node = get_node_or_null("/root/DJManager")
		if dj_node != null and dj_node.has_method("toggle_mute"):
			var ahora_mudo: bool = dj_node.call("toggle_mute")
			btn_audio.text = "Audio: OFF" if ahora_mudo else "Audio: ON"
	)


# ==========================================
# GESTIÓN DE PUNTAJES Y GAMIFICACIÓN
# ==========================================

func _recalcular_puntos_totales() -> int:
	var suma: int = 0
	for clave in puntos_por_ejercicio.keys():
		suma += int(puntos_por_ejercicio[clave])
	puntos_totales = suma
	return puntos_totales


func calcular_puntos_ejercicio(errores: int) -> int:
	if errores <= 1:
		return PUNTOS_BASE_EJERCICIO # 240 pts (0% penalización en 1er error)
	elif errores == 2:
		return int(round(PUNTOS_BASE_EJERCICIO * 0.75)) # 180 pts (-25%)
	else:
		return int(round(PUNTOS_BASE_EJERCICIO * 0.50)) # 120 pts (-50%)


func registrar_ejercicio(id_ejercicio: String, puntos: int) -> void:
	# Evitar puntos infinitos si se repite el mismo ejercicio en la sesión
	if puntos_por_ejercicio.has(id_ejercicio):
		return

	# Normalizar si una ventana antigua pasa 60/45/30 en vez de 240/180/120
	var puntos_reales: int = puntos
	if puntos_reales == 60:
		puntos_reales = 240
	elif puntos_reales == 45:
		puntos_reales = 180
	elif puntos_reales == 30:
		puntos_reales = 120

	if puntos_reales <= 0:
		return

	puntos_por_ejercicio[id_ejercicio] = puntos_reales
	ejercicios_completados[id_ejercicio] = true
	_recalcular_puntos_totales()

	var game_data: Node = get_node_or_null("/root/GameData")
	if game_data != null:
		if "gatopuntos" in game_data:
			game_data.set("gatopuntos", int(game_data.get("gatopuntos")) + puntos_reales)
		if "playerScore" in game_data:
			game_data.set("playerScore", int(game_data.get("playerScore")) + puntos_reales)

	_evaluar_insignias()
	_guardar_progreso_local()
	puntos_actualizados.emit(puntos_totales)

	print("Ejercicio registrado: ", id_ejercicio)
	print("Puntos ganados: ", puntos_reales)
	print("Puntos totales Nivel 3: ", puntos_totales)


func registrar_resultado_detallado(id_ejercicio: String, puntos: int, errores: int, pistas: int, completo: bool = true, maximo: int = PUNTOS_BASE_EJERCICIO, id_intento: int = -1) -> void:
	_activar_perfil_insignias()
	var intento: Dictionary = intentos_insignias.get(id_ejercicio, {})
	if intento.is_empty() and id_intento == -1:
		intento = iniciar_intento_insignia(id_ejercicio, maximo)
	if not completo:
		return
	errores_por_ejercicio[id_ejercicio] = errores
	pistas_por_ejercicio[id_ejercicio] = pistas
	if errores == 0 and pistas == 0:
		resuelto_sin_ayuda[id_ejercicio] = true
	elif not resuelto_sin_ayuda.has(id_ejercicio):
		resuelto_sin_ayuda[id_ejercicio] = false
	var token_valido: bool = id_intento == -1 or int(intento.get("id", -2)) == id_intento
	if token_valido and not intento.get("cerrado", false):
		intento["errores"] = maxi(int(intento.get("errores", 0)), errores)
		intento["cerrado"] = true
		intento["completo"] = true
		intento["puntos"] = puntos
		if maximo > 0 and puntos == maximo and maximo == int(intento.get("maximo", 0)) and int(intento.errores) == 0:
			ejercicios_perfectos[id_ejercicio] = true
	intentos_insignias[id_ejercicio] = intento
	registrar_ejercicio(id_ejercicio, puntos)
	# Registrar un logro perfecto aunque los puntos de ese ejercicio ya se hayan entregado.
	_evaluar_insignias()
	_guardar_insignias_persistentes()
	_guardar_progreso_local()


func registrar_resultado_examen(aprobado: bool, errores: int, puntos_bono: int = 300) -> void:
	_activar_perfil_insignias()
	if aprobado:
		examen_aprobado_para_insignia = true
	intentos_examen += 1
	examen_completado = true
	errores_examen = errores

	if aprobado and not examen_aprobado:
		examen_aprobado = true
		puntaje_examen = puntos_bono
		if not puntos_por_ejercicio.has("EX3_FINAL"):
			puntos_por_ejercicio["EX3_FINAL"] = puntos_bono
			ejercicios_completados["EX3_FINAL"] = true
			_recalcular_puntos_totales()
			var game_data: Node = get_node_or_null("/root/GameData")
			if game_data != null and "gatopuntos" in game_data:
				game_data.set("gatopuntos", int(game_data.get("gatopuntos")) + puntos_bono)
			puntos_actualizados.emit(puntos_totales)

	_evaluar_insignias()
	_guardar_insignias_persistentes()
	_guardar_progreso_local()


func registrar_rescate_panko() -> void:
	panko_rescatado = true
	_evaluar_insignias()
	registrar_en_ranking()
	_guardar_progreso_local()


func obtener_puntos(id_ejercicio: String) -> int:
	if puntos_por_ejercicio.has(id_ejercicio):
		return int(puntos_por_ejercicio[id_ejercicio])
	return 0


func obtener_puntos_ejercicios() -> int:
	var subtotal: int = 0
	for i in range(1, 11):
		var clave: String = "E3." + str(i)
		if puntos_por_ejercicio.has(clave):
			subtotal += int(puntos_por_ejercicio[clave])
	return subtotal


func obtener_bono_examen() -> int:
	if puntos_por_ejercicio.has("EX3_FINAL"):
		return int(puntos_por_ejercicio["EX3_FINAL"])
	return 0


func obtener_puntos_totales() -> int:
	return _recalcular_puntos_totales()


func obtener_total_nivel() -> int:
	return _recalcular_puntos_totales()


func ejercicio_esta_completado(id_ejercicio: String) -> bool:
	return puntos_por_ejercicio.has(id_ejercicio)


func ejercicio_completado(codigo_ejercicio: String) -> bool:
	return puntos_por_ejercicio.has(codigo_ejercicio) or ejercicios_completados.get(codigo_ejercicio, false)


func obtener_cantidad_ejercicios_completados() -> int:
	var cuenta: int = 0
	for i in range(1, 11):
		if puntos_por_ejercicio.has("E3." + str(i)):
			cuenta += 1
	return cuenta


# ==========================================
# INSIGNIAS (10 EJERCICIOS + 1 EXAMEN FINAL)
# ==========================================

func _evaluar_insignias() -> void:
	_activar_perfil_insignias()
	for i in range(1, 11):
		var codigo: String = "E3.%d" % i
		if ejercicios_perfectos.get(codigo, false):
			_desbloquear_insignia("insignia_e3_%d" % i, bool(resuelto_sin_ayuda.get(codigo, false)))
	if examen_aprobado_para_insignia:
		_desbloquear_insignia("insignia_examen_final", errores_examen == 0)


func _desbloquear_insignia(id_insignia: String, lograda_sin_ayuda: bool) -> void:
	var modalidad: String = "SIN_AYUDA" if lograda_sin_ayuda else "CON_AYUDA"

	if insignias_otorgadas.get(id_insignia, false) == true:
		if lograda_sin_ayuda and modalidad_insignias.get(id_insignia, "") != "SIN_AYUDA":
			modalidad_insignias[id_insignia] = "SIN_AYUDA"
		return

	insignias_otorgadas[id_insignia] = true
	modalidad_insignias[id_insignia] = modalidad

	var dj: Node = get_node_or_null("/root/DJManager")
	if dj != null and dj.has_method("play_sfx"):
		dj.call("play_sfx", "insignia")

	_guardar_insignias_persistentes()
	print("¡Insignia desbloqueada!: ", id_insignia, " (", modalidad, ")")


func obtener_estado_insignias() -> Array[bool]:
	_evaluar_insignias()
	var resultado: Array[bool] = []
	for id_ins in INSIGNIAS_ORDEN:
		resultado.append(insignias_otorgadas.get(id_ins, false) == true)
	return resultado


func obtener_nombres_insignias() -> Array[String]:
	var nombres: Array[String] = []
	for id_ins in INSIGNIAS_ORDEN:
		var info: Dictionary = INSIGNIAS_INFO.get(id_ins, {})
		var base: String = str(info.get("nombre", id_ins))
		if insignias_otorgadas.get(id_ins, false) == true:
			var mod: String = str(modalidad_insignias.get(id_ins, "CON_AYUDA"))
			if mod == "SIN_AYUDA":
				base += " ★ (Sin ayuda)"
			else:
				base += " (Completada)"
		nombres.append(base)
	return nombres


func obtener_descripciones_insignias() -> Array[String]:
	var descripciones: Array[String] = []
	for id_ins in INSIGNIAS_ORDEN:
		var info: Dictionary = INSIGNIAS_INFO.get(id_ins, {})
		descripciones.append(str(info.get("descripcion", "")))
	return descripciones


func obtener_lista_insignias_desbloqueadas() -> Array[String]:
	_evaluar_insignias()
	var lista: Array[String] = []
	for id_ins in INSIGNIAS_ORDEN:
		if insignias_otorgadas.get(id_ins, false) == true:
			var info: Dictionary = INSIGNIAS_INFO.get(id_ins, {})
			var mod: String = str(modalidad_insignias.get(id_ins, "CON_AYUDA"))
			lista.append(str(info.get("nombre", id_ins)) + " [" + mod + "]")
	return lista


# ==========================================
# RANKING LOCAL (SIN PRESIÓN DE TIEMPO)
# ==========================================

func _cargar_ranking_local() -> void:
	if not FileAccess.file_exists(RUTA_RANKING_JSON):
		ranking_local = []
		return
	var archivo := FileAccess.open(RUTA_RANKING_JSON, FileAccess.READ)
	if archivo == null:
		return
	var texto: String = archivo.get_as_text()
	archivo.close()
	var json := JSON.new()
	if json.parse(texto) == OK and typeof(json.data) == TYPE_ARRAY:
		ranking_local = json.data


func registrar_en_ranking() -> void:
	var id_actual: String = obtener_id_jugador()
	var insignias_count: int = obtener_lista_insignias_desbloqueadas().size()
	var entrada: Dictionary = {
		"idJugador": id_actual,
		"puntaje": puntos_totales,
		"insignias": insignias_count,
		"fecha": Time.get_datetime_string_from_system(false, true)
	}

	var actualizado: bool = false
	for i in range(ranking_local.size()):
		var item: Dictionary = ranking_local[i]
		if str(item.get("idJugador", "")) == id_actual:
			if puntos_totales >= int(item.get("puntaje", 0)):
				if item.has("resumenGeneral"):
					entrada["resumenGeneral"] = item["resumenGeneral"]
				ranking_local[i] = entrada
			actualizado = true
			break

	if not actualizado:
		ranking_local.append(entrada)

	ranking_local.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("puntaje", 0)) > int(b.get("puntaje", 0))
	)

	if ranking_local.size() > 10:
		var generales: Array = []
		for item in ranking_local.slice(10):
			if item.has("resumenGeneral"):
				generales.append(item)
		ranking_local.resize(10)
		ranking_local.append_array(generales)

	var archivo := FileAccess.open(RUTA_RANKING_JSON, FileAccess.WRITE)
	if archivo != null:
		archivo.store_string(JSON.stringify(ranking_local, "\t"))
		archivo.close()


func obtener_resumen_ranking(max_filas: int = 3) -> String:
	if ranking_local.is_empty():
		registrar_en_ranking()
	var lineas: Array[String] = []
	var limite: int = min(max_filas, ranking_local.size())
	for i in range(limite):
		var item: Dictionary = ranking_local[i]
		lineas.append(
			"#%d %s - %d pts (%d insignias)" % [
				i + 1,
				str(item.get("idJugador", "EST")),
				int(item.get("puntaje", 0)),
				int(item.get("insignias", 0))
			]
		)
	return "\n".join(lineas)


# ==========================================
# REGISTRO CENTRALIZADO DE INTERACCIÓN (LOG JSON)
# ==========================================

func _asegurar_archivos_log() -> void:
	if not FileAccess.file_exists(RUTA_LOG_JSON):
		var archivo := FileAccess.open(RUTA_LOG_JSON, FileAccess.WRITE)
		if archivo != null:
			archivo.store_string("[]\n")
			archivo.close()


func registrar_intento_log(datos: Dictionary) -> void:
	var id_ej: String = str(datos.get("ejercicio", "E3.X"))
	var num_intento: int = int(datos.get("numeroIntento", 0))
	if num_intento <= 0:
		num_intento = int(intentos_por_ejercicio.get(id_ej, 0)) + 1
	intentos_por_ejercicio[id_ej] = num_intento

	var fue_correcta: bool = bool(datos.get("siFueCorrectaONo", false))
	var pistas_usadas: int = int(datos.get("pistasUtilizadas", pistas_por_ejercicio.get(id_ej, 0)))
	pistas_por_ejercicio[id_ej] = pistas_usadas

	var errores_acum: int = int(datos.get("erroresAcumulados", errores_por_ejercicio.get(id_ej, 0)))
	errores_por_ejercicio[id_ej] = errores_acum

	if fue_correcta:
		if errores_acum == 0 and pistas_usadas == 0:
			resuelto_sin_ayuda[id_ej] = true
		elif not resuelto_sin_ayuda.has(id_ej):
			resuelto_sin_ayuda[id_ej] = false
		_evaluar_insignias()

	if datos.get("intentoInsignia") != null:
		_activar_perfil_insignias()
		var activo: Dictionary = intentos_insignias.get(id_ej, {})
		if int(activo.get("id", -1)) == int(datos.intentoInsignia):
			activo["validaciones"] = maxi(int(activo.get("validaciones", 0)), num_intento)
			activo["errores"] = maxi(int(activo.get("errores", 0)), errores_acum)
			activo["pistas"] = maxi(int(activo.get("pistas", 0)), pistas_usadas)
			_guardar_insignias_persistentes()

	var tiempo_resp: float = snappedf(float(datos.get("tiempoDeRespuesta", 0.0)), 0.01)

	var registro: Dictionary = {
		"timestamp": Time.get_datetime_string_from_system(false, true),
		"idJugador": obtener_id_jugador(),
		"nivel": str(datos.get("nivel", "Nivel 3")),
		"ejercicio": id_ej,
		"pregunta": str(datos.get("pregunta", id_ej)),
		"alternativas": datos.get("alternativas", []),
		"respuestaJugador": datos.get("respuestaJugador", []),
		"siFueCorrectaONo": fue_correcta,
		"tiempoDeRespuesta": tiempo_resp,
		"numeroIntento": num_intento,
		"intentoInsignia": datos.get("intentoInsignia", null),
		"erroresAcumulados": errores_acum,
		"pistasUtilizadas": pistas_usadas,
		"tipoError": str(datos.get("tipoError", "NINGUNO" if fue_correcta else "ERROR_LOGICO")),
		"puntajeObtenido": int(datos.get("puntajeObtenido", 0)),
		"puntajeTotalNivel3": puntos_totales,
		"resultadoExamen": str(datos.get("resultadoExamen", "APROBADO" if examen_aprobado else "NO_APLICA")),
		"insigniasObtenidas": obtener_lista_insignias_desbloqueadas()
	}

	var lista_registros: Array = []
	if FileAccess.file_exists(RUTA_LOG_JSON):
		var lec := FileAccess.open(RUTA_LOG_JSON, FileAccess.READ)
		if lec != null:
			var contenido: String = lec.get_as_text()
			lec.close()
			var json := JSON.new()
			if json.parse(contenido) == OK and typeof(json.data) == TYPE_ARRAY:
				lista_registros = json.data

	lista_registros.append(registro)
	var esc_json := FileAccess.open(RUTA_LOG_JSON, FileAccess.WRITE)
	if esc_json != null:
		esc_json.store_string(JSON.stringify(lista_registros, "\t"))
		esc_json.close()

	_agregar_linea_jsonl(RUTA_LOG_JSONL, registro)

	if id_ej.begins_with("EX3"):
		_agregar_linea_jsonl(RUTA_LOG_EXAMEN_JSONL, registro)

	_guardar_progreso_local()


func _agregar_linea_jsonl(ruta: String, registro: Dictionary) -> void:
	var modo: int = FileAccess.READ_WRITE
	if not FileAccess.file_exists(ruta):
		modo = FileAccess.WRITE
	var archivo := FileAccess.open(ruta, modo)
	if archivo == null:
		return
	archivo.seek_end()
	archivo.store_line(JSON.stringify(registro))
	archivo.close()


# ==========================================
# PERSISTENCIA LOCAL DE PROGRESO
# ==========================================

func _guardar_progreso_local() -> void:
	var datos_existentes: Dictionary = _leer_json_diccionario(RUTA_PROGRESO_JSON)
	var resumenes_guardados: Dictionary = datos_existentes.get("resumen_niveles_por_jugador", {})
	var archivo := FileAccess.open(RUTA_PROGRESO_JSON, FileAccess.WRITE)
	if archivo == null:
		return
	var datos: Dictionary = {
		"idJugador": id_jugador,
		"resumen_niveles_por_jugador": resumenes_guardados,
		"insignias_por_jugador": datos_existentes.get("insignias_por_jugador", {}),
		"puntos_por_ejercicio": puntos_por_ejercicio,
		"puntos_totales": puntos_totales,
		"errores_por_ejercicio": errores_por_ejercicio,
		"pistas_por_ejercicio": pistas_por_ejercicio,
		"intentos_por_ejercicio": intentos_por_ejercicio,
		"resuelto_sin_ayuda": resuelto_sin_ayuda,
		"insignias_otorgadas": insignias_otorgadas,
		"modalidad_insignias": modalidad_insignias,
		"examen_completado": examen_completado,
		"examen_aprobado": examen_aprobado,
		"puntaje_examen": puntaje_examen,
		"errores_examen": errores_examen,
		"panko_rescatado": panko_rescatado,
		"actualizado": Time.get_datetime_string_from_system(false, true)
	}
	datos_existentes.merge(datos, true)
	archivo.store_string(JSON.stringify(datos_existentes, "\t"))
	archivo.close()


func _cargar_progreso_local() -> void:
	if not FileAccess.file_exists(RUTA_PROGRESO_JSON):
		return
	var archivo := FileAccess.open(RUTA_PROGRESO_JSON, FileAccess.READ)
	if archivo == null:
		return
	var texto: String = archivo.get_as_text()
	archivo.close()
	var json := JSON.new()
	if json.parse(texto) != OK or typeof(json.data) != TYPE_DICTIONARY:
		return
	var d: Dictionary = json.data
	puntos_por_ejercicio = d.get("puntos_por_ejercicio", {})
	ejercicios_completados.clear()
	for k in puntos_por_ejercicio.keys():
		ejercicios_completados[k] = true
	puntos_totales = int(d.get("puntos_totales", 0))
	errores_por_ejercicio = d.get("errores_por_ejercicio", {})
	pistas_por_ejercicio = d.get("pistas_por_ejercicio", {})
	intentos_por_ejercicio = d.get("intentos_por_ejercicio", {})
	resuelto_sin_ayuda = d.get("resuelto_sin_ayuda", {})
	insignias_otorgadas = d.get("insignias_otorgadas", {})
	modalidad_insignias = d.get("modalidad_insignias", {})
	examen_completado = bool(d.get("examen_completado", false))
	examen_aprobado = bool(d.get("examen_aprobado", false))
	puntaje_examen = int(d.get("puntaje_examen", 0))
	errores_examen = int(d.get("errores_examen", 0))
	panko_rescatado = bool(d.get("panko_rescatado", false))


# ==========================================
# REINICIAR PUNTAJES (NUEVA PARTIDA)
# ==========================================

func reiniciar_puntajes() -> void:
	_activar_perfil_insignias()
	for intento in intentos_insignias.values():
		intento["cerrado"] = true # Una nueva partida permite otro intento, sin borrar logros.
	_guardar_insignias_persistentes()
	puntos_por_ejercicio.clear()
	ejercicios_completados.clear()
	puntos_totales = 0
	errores_por_ejercicio.clear()
	pistas_por_ejercicio.clear()
	intentos_por_ejercicio.clear()
	resuelto_sin_ayuda.clear()
	# Las insignias permanentes no se borran al iniciar otra partida.
	examen_completado = false
	examen_aprobado = false
	puntaje_examen = 0
	errores_examen = 0
	panko_rescatado = false
	examen_preguntas_seleccionadas.clear()
	examen_indice_actual = 0
	examen_errores_actuales = 0
	examen_respuestas_correctas = 0
	examen_aprobado_actual = false
	examen_finalizado_actual = false
	_guardar_progreso_local()
	puntos_actualizados.emit(0)
	print("Puntajes del Nivel 3 reiniciados (registros LOG históricos conservados en user://).")


func reiniciar_nivel() -> void:
	reiniciar_puntajes()


# Resúmenes opcionales: puntos incluye la bonificación del examen, nunca se suma dos veces.
# integrar_resumen_nivel(1/2, {puntos: int|null, completados: int|null, total: int|null,
# requisitos_completados: bool|null, insignias: [{id, nombre, descripcion, icono, textura}]})
# Cada llamada reemplaza una instantánea del mismo nivel y jugador; no otorga recompensas.
func integrar_resumen_nivel(nivel: int, datos: Dictionary) -> bool:
	if nivel < 1 or nivel > 2:
		return false
	for campo in ["puntos", "completados", "total"]:
		var valor = datos.get(campo)
		if valor != null and (typeof(valor) not in [TYPE_INT, TYPE_FLOAT] or valor < 0 or float(valor) != floorf(float(valor))):
			return false
	if datos.get("completados") != null and datos.get("total") != null and datos.completados > datos.total:
		return false
	if datos.get("requisitos_completados") != null and typeof(datos.requisitos_completados) != TYPE_BOOL:
		return false
	if typeof(datos.get("insignias", [])) != TYPE_ARRAY:
		return false
	var copia := datos.duplicate(true)
	var unicas: Array = []
	var ids: Dictionary = {}
	for insignia in copia.get("insignias", []):
		if typeof(insignia) != TYPE_DICTIONARY or str(insignia.get("id", "")).is_empty() or str(insignia.get("nombre", "")).is_empty():
			return false
		if not ids.has(str(insignia.id)):
			ids[str(insignia.id)] = true
			unicas.append(insignia)
	copia["insignias"] = unicas
	var id_actual := obtener_id_jugador()
	var todos := _leer_json_diccionario(RUTA_PROGRESO_JSON)
	if FileAccess.file_exists(RUTA_PROGRESO_JSON) and todos.is_empty():
		return false # No sobrescribir un archivo anterior ilegible.
	var por_jugador: Dictionary = todos.get("resumen_niveles_por_jugador", {})
	var niveles: Dictionary = por_jugador.get(id_actual, {})
	niveles[str(nivel)] = copia
	por_jugador[id_actual] = niveles
	todos["resumen_niveles_por_jugador"] = por_jugador
	var archivo := FileAccess.open(RUTA_PROGRESO_JSON, FileAccess.WRITE)
	if archivo == null:
		return false
	archivo.store_string(JSON.stringify(todos, "\t"))
	archivo.close()
	return true


func _leer_json_diccionario(ruta: String) -> Dictionary:
	if not FileAccess.file_exists(ruta):
		return {}
	var datos = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	return datos if typeof(datos) == TYPE_DICTIONARY else {}


func obtener_resumen_general() -> Dictionary:
	var guardado := _leer_json_diccionario(RUTA_PROGRESO_JSON)
	var por_jugador: Dictionary = guardado.get("resumen_niveles_por_jugador", {})
	var anteriores: Dictionary = por_jugador.get(obtener_id_jugador(), {})
	var niveles: Array[Dictionary] = []
	var todas_insignias: Array[Dictionary] = []
	var puntos_conocidos: int = 0
	var ejercicios_conocidos: int = 0
	var total_conocido: int = 0
	var puntos_completos: bool = true
	var progreso_completo: bool = true
	var juego_completo: bool = true
	for nivel in range(1, 4):
		var datos: Dictionary = anteriores.get(str(nivel), {}).duplicate(true) if nivel < 3 else {}
		if nivel == 3:
			datos = _obtener_nivel3_para_resumen(guardado)
		datos["nivel"] = nivel
		if datos.get("puntos") == null:
			puntos_completos = false
		else:
			puntos_conocidos += int(datos.puntos)
		if datos.get("completados") == null or datos.get("total") == null:
			progreso_completo = false
		else:
			ejercicios_conocidos += int(datos.completados)
			total_conocido += int(datos.total)
		juego_completo = juego_completo and datos.get("requisitos_completados") == true
		for insignia in datos.get("insignias", []):
			var item: Dictionary = insignia.duplicate(true)
			item["id"] = "N%d:%s" % [nivel, item.id]
			item["nivel"] = nivel
			todas_insignias.append(item)
		niveles.append(datos)
	return {"niveles": niveles, "puntos": puntos_conocidos if puntos_completos else null,
		"subtotal_conocido": puntos_conocidos, "completados": ejercicios_conocidos,
		"total": total_conocido, "progreso_completo": progreso_completo,
		"juego_completo": juego_completo, "insignias": todas_insignias}


# Leer el progreso persistido cuando todavía no existe una partida activa en memoria.
# Solo es una consulta del resumen: no cambia los puntos ni carga otro jugador.
func _obtener_nivel3_para_resumen(guardado: Dictionary) -> Dictionary:
	var usar_guardado: bool = puntos_por_ejercicio.is_empty() and not panko_rescatado and not examen_aprobado and str(guardado.get("idJugador", "")) == obtener_id_jugador()
	var premios: Dictionary = guardado.get("puntos_por_ejercicio", {}) if usar_guardado else puntos_por_ejercicio
	var estados: Dictionary = guardado.get("insignias_otorgadas", {}) if usar_guardado else insignias_otorgadas
	var examen: bool = bool(guardado.get("examen_aprobado", false)) if usar_guardado else examen_aprobado
	var rescate: bool = bool(guardado.get("panko_rescatado", false)) if usar_guardado else panko_rescatado
	var suma: int = 0
	var completados: int = 0
	for codigo in premios:
		suma += int(premios[codigo])
	for i in range(1, 11):
		if premios.has("E3.%d" % i):
			completados += 1
	if not usar_guardado:
		_evaluar_insignias()
	var insignias: Array[Dictionary] = []
	for id_ins in INSIGNIAS_ORDEN:
		if estados.get(id_ins, false):
			var info: Dictionary = INSIGNIAS_INFO[id_ins]
			insignias.append({"id": id_ins, "nombre": info.nombre, "descripcion": info.descripcion, "icono": id_ins})
	return {"puntos": suma, "completados": completados, "total": 10,
		"requisitos_completados": completados == 10 and examen and rescate,
		"rescate_confirmado": rescate, "insignias": insignias}


func registrar_resumen_en_ranking_general() -> void:
	var resumen := obtener_resumen_general()
	if resumen.puntos == null or not resumen.juego_completo:
		return # No comparar un subtotal con partidas completas.
	_cargar_ranking_local()
	var id_actual := obtener_id_jugador()
	var entrada: Dictionary = {}
	for item in ranking_local:
		if str(item.get("idJugador", "")) == id_actual:
			entrada = item
			break
	if entrada.is_empty():
		entrada = {"idJugador": id_actual}
		ranking_local.append(entrada)
	var previo: Dictionary = entrada.get("resumenGeneral", {})
	if int(previo.get("puntaje", -1)) <= int(resumen.puntos):
		entrada["resumenGeneral"] = {"puntaje": resumen.puntos, "insignias": resumen.insignias.size(), "actualizado": Time.get_datetime_string_from_system(false, true)}
	var archivo := FileAccess.open(RUTA_RANKING_JSON, FileAccess.WRITE)
	if archivo != null:
		archivo.store_string(JSON.stringify(ranking_local, "\t"))
		archivo.close()


func obtener_ranking_general() -> Array:
	_cargar_ranking_local()
	var unicos: Dictionary = {}
	for entrada in ranking_local:
		if not entrada.has("resumenGeneral"):
			continue # Las entradas históricas del Nivel 3 siguen intactas.
		var id_actual: String = str(entrada.get("idJugador", ""))
		var puntos: int = int(entrada.resumenGeneral.get("puntaje", 0))
		if not unicos.has(id_actual) or int(unicos[id_actual].puntaje) < puntos:
			unicos[id_actual] = {"idJugador": id_actual, "puntaje": puntos}
	var resultado: Array = unicos.values()
	resultado.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.puntaje > b.puntaje)
	return resultado


func _activar_perfil_insignias() -> void:
	var id_actual := obtener_id_jugador()
	if perfil_insignias_activo == id_actual:
		return
	var guardado := _leer_json_diccionario(RUTA_PROGRESO_JSON)
	var perfiles: Dictionary = guardado.get("insignias_por_jugador", {})
	var perfil: Dictionary = perfiles.get(id_actual, {})
	insignias_otorgadas = perfil.get("otorgadas", {}).duplicate(true)
	modalidad_insignias = perfil.get("modalidades", {}).duplicate(true)
	intentos_insignias = perfil.get("intentos", {}).duplicate(true)
	ejercicios_perfectos = perfil.get("perfectos", {}).duplicate(true)
	examen_aprobado_para_insignia = bool(perfil.get("examen_aprobado", false))
	# Migrar los logros anteriores del mismo estudiante, sin revocarlos.
	if str(guardado.get("idJugador", "")) == id_actual:
		if bool(guardado.get("examen_aprobado", false)):
			examen_aprobado_para_insignia = true
		for clave in guardado.get("insignias_otorgadas", {}):
			if guardado.insignias_otorgadas[clave]:
				insignias_otorgadas[clave] = true
		for clave in guardado.get("modalidad_insignias", {}):
			if not modalidad_insignias.has(clave):
				modalidad_insignias[clave] = guardado.modalidad_insignias[clave]
	perfil_insignias_activo = id_actual


func _guardar_insignias_persistentes() -> void:
	if perfil_insignias_activo.is_empty():
		return
	var datos := _leer_json_diccionario(RUTA_PROGRESO_JSON)
	var perfiles: Dictionary = datos.get("insignias_por_jugador", {})
	perfiles[perfil_insignias_activo] = {"otorgadas": insignias_otorgadas, "modalidades": modalidad_insignias,
		"intentos": intentos_insignias, "perfectos": ejercicios_perfectos, "examen_aprobado": examen_aprobado_para_insignia}
	datos["insignias_por_jugador"] = perfiles
	var archivo := FileAccess.open(RUTA_PROGRESO_JSON, FileAccess.WRITE)
	if archivo != null:
		archivo.store_string(JSON.stringify(datos, "\t"))
		archivo.close()


func iniciar_intento_insignia(codigo: String, maximo: int) -> Dictionary:
	_activar_perfil_insignias()
	var anterior: Dictionary = intentos_insignias.get(codigo, {})
	if not anterior.is_empty() and not anterior.get("cerrado", false):
		return anterior.duplicate(true) # Cerrar/reabrir no borra los errores.
	var intento: Dictionary = {"id": int(anterior.get("id", 0)) + 1, "errores": 0, "cerrado": false,
		"completo": false, "maximo": maximo, "validaciones": 0, "pistas": 0}
	intentos_insignias[codigo] = intento
	_guardar_insignias_persistentes()
	return intento.duplicate(true)


func registrar_error_insignia(codigo: String, id_intento: int) -> int:
	_activar_perfil_insignias()
	var intento: Dictionary = intentos_insignias.get(codigo, {})
	if int(intento.get("id", -1)) != id_intento or intento.get("cerrado", false):
		return int(intento.get("errores", 0))
	intento["errores"] = int(intento.get("errores", 0)) + 1
	_guardar_insignias_persistentes()
	return int(intento.errores)


func tiene_insignia_ejercicio(codigo: String) -> bool:
	_activar_perfil_insignias()
	return bool(insignias_otorgadas.get("insignia_e3_" + codigo.get_slice(".", 1), false))


func obtener_catalogo_insignias_nivel3() -> Array[Dictionary]:
	_evaluar_insignias()
	var catalogo: Array[Dictionary] = []
	for clave in INSIGNIAS_ORDEN:
		var info: Dictionary = INSIGNIAS_INFO[clave]
		var condicion: String = "Aprobar el examen final dentro del límite de errores permitido." if clave == "insignia_examen_final" else "Resolver el ejercicio completo con el puntaje máximo y cero errores en un mismo intento."
		catalogo.append({"id": "N3:" + clave, "nombre": info.nombre, "descripcion": info.descripcion,
			"condicion": condicion, "icono": clave, "nivel": 3, "desbloqueada": bool(insignias_otorgadas.get(clave, false))})
	return catalogo
