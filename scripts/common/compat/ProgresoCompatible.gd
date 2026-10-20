extends "res://scripts/nivel_3/compartidos/PuntajesNivel3.gd"
# Protección de guardados al restaurar los menús. El archivo del Nivel 3 no se modifica.
func _ready() -> void:
	super._ready()
	get_tree().scene_changed.connect(_verificar_escena_inicial)
	var datos := _leer_json_diccionario(RUTA_PROGRESO_JSON)
	if str(datos.get("idJugador", "")) == obtener_id_jugador():
		_cargar_progreso_local()

func _cargar_perfil_estudiante() -> void:
	var game_data := _obtener_gamedata()
	var alias_actual: String = str(game_data.get("playerName")) if game_data != null else ""
	if alias_actual in ["", "Jugador", "Player", "SIN_ASIGNAR", "<null>"]:
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
