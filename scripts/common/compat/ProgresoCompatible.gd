extends "res://scripts/nivel_3/compartidos/PuntajesNivel3.gd"
# Protección de guardados al restaurar los menús. El archivo del Nivel 3 no se modifica.
func _ready() -> void:
	super._ready()
	get_tree().scene_changed.connect(_verificar_escena_inicial)
	_olvidar_progreso_de_sesiones_anteriores()

# Borra del archivo guardado el avance de partidas anteriores (ejercicios resueltos, examen, rescate
# y resúmenes de nivel). Se conservan el ID del jugador, las insignias y el ranking.
func _olvidar_progreso_de_sesiones_anteriores() -> void:
	var datos := _leer_json_diccionario(RUTA_PROGRESO_JSON)
	if datos.is_empty():
		return
	var cambiado: bool = false
	for clave in ["resumen_niveles_por_jugador", "puntos_por_ejercicio", "puntos_totales", "errores_por_ejercicio",
			"pistas_por_ejercicio", "intentos_por_ejercicio", "resuelto_sin_ayuda", "examen_completado",
			"examen_aprobado", "puntaje_examen", "errores_examen", "panko_rescatado"]:
		if datos.has(clave):
			datos.erase(clave)
			cambiado = true
	if cambiado:
		var archivo := FileAccess.open(RUTA_PROGRESO_JSON, FileAccess.WRITE)
		if archivo != null:
			archivo.store_string(JSON.stringify(datos, "\t"))
			archivo.close()

func registrar_rescate_panko() -> void:
	super.registrar_rescate_panko()
	GameData.finishNivel(3)
	GameData.showNivelResumen(3)

func _cargar_perfil_estudiante() -> void:
	var game_data := _obtener_gamedata()
	var alias_actual: String = str(game_data.get("playerName")) if game_data != null else ""
	if alias_actual in ["", "SIN_ASIGNAR", "<null>"]:
		var perfil := _leer_json_diccionario(RUTA_PERFIL_JSON)
		var id_guardado: String = str(perfil.get("idJugador", "")).strip_edges()
		if not id_guardado.is_empty() and id_guardado != "SIN_ASIGNAR":
			id_jugador = id_guardado
			_sincronizar_id_con_gamedata()
			return
	super._cargar_perfil_estudiante()

func _verificar_escena_inicial() -> void:
	var escena := get_tree().current_scene
	if escena == null:
		return
	var ruta: String = escena.scene_file_path
	if ruta.contains("/Nivel_3/") or ruta.contains("/ExamenNivel3/"):
		super._verificar_escena_inicial()
	else:
		# Navegar al menú no equivale a pulsar "Jugar de nuevo".
		if manual_nivel3 != null:
			manual_nivel3.call("cerrar_manual")
			manual_nivel3.call("set_visibilidad_boton_flotante", false)
