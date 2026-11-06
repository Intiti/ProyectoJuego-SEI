extends Node

const RUTA_REPORTE := "user://reporte_jugador.json"
# Copia de seguridad: una por partida, nunca se sobreescribe con otra partida.
const DIR_REPORTES := "user://reportes"

var _ejercicios: Dictionary = {1: {}, 2: {}, 3: {}}
var _preguntasExamen: Dictionary = {1: [], 2: [], 3: []}
var _intentosExamen: Dictionary = {1: [], 2: [], 3: []}
var _niveles: Dictionary = {}
var _partidaInicio: String = Time.get_datetime_string_from_system(false, true)

func _ahora() -> String:
	return Time.get_datetime_string_from_system(false, true)

func _registro(level: int, code: String) -> Dictionary:
	var lvl: Dictionary = _ejercicios[level]
	if not lvl.has(code):
		lvl[code] = {
			"codigo": code,
			"resultado": "INCORRECTO",
			"intentosFallidos": 0,
			"erroresAlResolver": 0,
			"puntos": 0,
			"fallos": [],
		}
	return lvl[code]

func fallo(level: int, code: String, detalle: Dictionary = {}) -> void:
	if not _ejercicios.has(level) or code == "":
		return
	var r: Dictionary = _registro(level, code)
	if r["resultado"] == "CORRECTO":
		return
	r["intentosFallidos"] = int(r["intentosFallidos"]) + 1
	var f: Dictionary = detalle.duplicate(true)
	f["timestamp"] = _ahora()
	r["fallos"].append(f)

func acierto(level: int, code: String, detalle: Dictionary = {}) -> void:
	if not _ejercicios.has(level) or code == "":
		return
	var r: Dictionary = _registro(level, code)
	if r["resultado"] == "CORRECTO":
		return
	r["resultado"] = "CORRECTO"
	r["erroresAlResolver"] = int(detalle.get("errores", 0))
	r["puntos"] = int(detalle.get("puntos", 0))
	r["resueltoEn"] = _ahora()
	for k in detalle.keys():
		if not r.has(k):
			r[k] = detalle[k]

func examenPregunta(level: int, code: String, ok: bool, detalle: Dictionary = {}) -> void:
	if not _preguntasExamen.has(level):
		return
	var d: Dictionary = detalle.duplicate(true)
	d["pregunta"] = code
	d["correcta"] = ok
	d["timestamp"] = _ahora()
	_preguntasExamen[level].append(d)

func examenIntento(level: int, aprobado: bool, detalle: Dictionary = {}) -> void:
	if not _intentosExamen.has(level):
		return
	var d: Dictionary = detalle.duplicate(true)
	d["numero"] = _intentosExamen[level].size() + 1
	d["resultado"] = "APROBADO" if aprobado else "REPROBADO"
	d["timestamp"] = _ahora()
	d["preguntas"] = _preguntasExamen[level].duplicate(true)
	_preguntasExamen[level].clear()
	_intentosExamen[level].append(d)
	_guardar()

func _idJugador() -> String:
	var p3: Node = get_node_or_null("/root/PuntajesNivel3")
	if p3 != null and p3.has_method("obtener_id_jugador"):
		return str(p3.call("obtener_id_jugador"))
	return str(GameData.playerName)

func _rachaMax(level: int) -> int:
	match level:
		1:
			return GameData.rachaMaxNivel1
		2:
			return GameData.rachaMaxNivel2
	return GameData.rachaMaxNivel3

func _nombresInsignias(level: int) -> Array:
	var nombres: Array = []
	for b in GameData.levelSummary(level).get("insignias", []):
		nombres.append(str(b.get("nombre", "")))
	return nombres

func cerrarNivel(level: int) -> void:
	if not _ejercicios.has(level):
		return
	var resueltos: Array = []
	var resueltosConErrores: Array = []
	var noResueltos: Array = []
	var sinIntentar: Array = []
	for i in range(1, GameData.levelTotal(level) + 1):
		var code: String = "E%d.%d" % [level, i]
		var r = _ejercicios[level].get(code)
		if r == null:
			sinIntentar.append(code)
		elif r["resultado"] == "CORRECTO":
			resueltos.append(code)
			if int(r["intentosFallidos"]) > 0 or int(r["erroresAlResolver"]) > 0:
				resueltosConErrores.append(code)
		else:
			noResueltos.append(code)
	var intentos: Array = _intentosExamen[level]
	var aprobado: bool = false
	for it in intentos:
		if it["resultado"] == "APROBADO":
			aprobado = true
	_niveles[str(level)] = {
		"nivel": level,
		"nombre": GameData.levelName(level),
		"completadoEn": _ahora(),
		"puntaje": int(GameData.puntosNivel.get(level, 0)),
		"rachaMax": _rachaMax(level),
		"insignias": _nombresInsignias(level),
		"resumen": {
			"resueltos": resueltos,
			"resueltosConErrores": resueltosConErrores,
			"noResueltos": noResueltos,
			"sinIntentar": sinIntentar,
		},
		"ejercicios": _ejercicios[level].values(),
		"examen": {
			"aprobado": aprobado,
			"intentos": intentos.duplicate(true),
			"preguntasSinCerrar": _preguntasExamen[level].duplicate(true),
		},
	}
	_guardar()

# Intentos de examen de niveles que aún no se cierran (para no perderlos si el
# jugador sale antes de terminar el nivel).
func _pendientes() -> Dictionary:
	var out: Dictionary = {}
	for level in [1, 2, 3]:
		if _niveles.has(str(level)):
			continue
		if _intentosExamen[level].is_empty() and _preguntasExamen[level].is_empty():
			continue
		out[str(level)] = {
			"intentos": _intentosExamen[level].duplicate(true),
			"preguntasSinCerrar": _preguntasExamen[level].duplicate(true),
		}
	return out

func _rutaRun() -> String:
	var nombre: String = _partidaInicio.replace(":", "-").replace(" ", "_")
	return "%s/reporte_%s.json" % [DIR_REPORTES, nombre]

func _escribir(ruta: String, texto: String) -> bool:
	var archivo := FileAccess.open(ruta, FileAccess.WRITE)
	if archivo == null:
		push_error("ReporteNivel: no se pudo escribir %s (error %d)" % [ruta, FileAccess.get_open_error()])
		return false
	archivo.store_string(texto)
	archivo.close()
	return true

# Escribe a un .tmp y lo renombra, así un fallo a medias no deja el JSON roto.
func _escribirAtomico(ruta: String, texto: String) -> bool:
	var tmp: String = ruta + ".tmp"
	if not _escribir(tmp, texto):
		return _escribir(ruta, texto)
	var err: int = DirAccess.rename_absolute(ProjectSettings.globalize_path(tmp), ProjectSettings.globalize_path(ruta))
	if err == OK:
		return true
	DirAccess.remove_absolute(ProjectSettings.globalize_path(tmp))
	return _escribir(ruta, texto)

func _guardar() -> void:
	var datos: Dictionary = {
		"idJugador": _idJugador(),
		"inicioPartida": _partidaInicio,
		"actualizadoEn": _ahora(),
		"examenesPendientes": _pendientes(),
		"niveles": _niveles,
	}
	var texto: String = JSON.stringify(datos, "\t")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DIR_REPORTES))
	var rutaRun: String = _rutaRun()
	var okRun: bool = _escribir(rutaRun, texto)
	var okMain: bool = _escribirAtomico(RUTA_REPORTE, texto)
	if okMain:
		print("ReporteNivel: reporte guardado en ", ProjectSettings.globalize_path(RUTA_REPORTE))
	else:
		push_warning("ReporteNivel: no se pudo actualizar reporte_jugador.json (¿está abierto en otro programa?)")
	if okRun:
		print("ReporteNivel: copia de la partida en ", ProjectSettings.globalize_path(rutaRun))

func reiniciar() -> void:
	_ejercicios = {1: {}, 2: {}, 3: {}}
	_preguntasExamen = {1: [], 2: [], 3: []}
	_intentosExamen = {1: [], 2: [], 3: []}
	_niveles = {}
	_partidaInicio = _ahora()
