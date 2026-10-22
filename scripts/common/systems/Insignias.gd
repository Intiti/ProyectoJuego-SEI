extends Node
# ─────────────────────────────────────────────────────────────────────────────
#  Insignias — sistema de logros estilo Steam (autoload "Insignias").
#
#  · Catálogo de insignias (bronce / plata / oro, con su gatito doodle).
#  · Se desbloquean solas escuchando a GameData (no hay que tocar los puzzles).
#  · Al desbloquear una sale un toast arriba a la derecha (en cola si caen varias).
#  · Se guardan en user://insignias.json, así que sobreviven entre partidas.
#
#  Para agregar una insignia nueva: añadir una entrada a CATALOGO y llamar
#  Insignias.unlock("mi_id") desde donde se cumpla la condición.
# ─────────────────────────────────────────────────────────────────────────────

signal insigniaDesbloqueada(id: String)

const SAVE_PATH := "user://insignias.json"
const ToastScript := preload("res://scripts/common/ui/insigniaToast.gd")

const BRONCE := 0
const PLATA := 1
const ORO := 2

const TOAST_MARGIN := 24.0
const TOAST_HOLD := 4.5

const ID_PRIMER_PUZZLE := "n1_primer_puzzle"
const ID_RACHA_5 := "n1_racha_5"
const ID_NIVEL_1 := "n1_nivel_completo"
const ID_N2_CAZADOR := "n2_cazador_ciclos"
const ID_N3_MAESTRO := "n3_maestro_nucleo"
const ID_DEPURADOR := "depurador_persistente"
const ID_N1_PANADERIA := "n1_panaderia"
const ID_N1_ESCUELA := "n1_escuela"
const ID_N1_EXAMEN_1ER := "n1_examen_primer_intento"
const ID_RACHA_12 := "n1_racha_12"
const ID_RACHA_25 := "n1_racha_25"
const ID_N2_COMPLETO := "n2_nivel_completo"
const ID_N2_IMPECABLE := "n2_examen_impecable"
const ID_N3_COMPLETO := "n3_nivel_completo"
const ID_N3_SIN_BUGS := "n3_sin_bugs"

const MISIONES_PANADERIA := ["npc_e12", "npc_e15", "npc_e17"]
const MISIONES_ESCUELA := ["npc_e16", "npc_e19", "npc_e20"]
const RUTA_DIALOGOS_N1 := "res://dialogs/nivel_1/%s.json"

const CATALOGO := [
	{
		"id": ID_PRIMER_PUZZLE, "nivel": 1, "tier": BRONCE, "face": 0,
		"nombre": "Insignia del Gatito Principiante",
		"descripcion": "Completaste tu primer puzzle. ¡Todo gran gato empieza con un primer maullido!",
	},
	{
		"id": ID_RACHA_5, "nivel": 0, "tier": PLATA, "face": 1,
		"nombre": "Insignia del Bigote Imparable",
		"descripcion": "Lograste una racha de 5 aciertos seguidos sin equivocarte.",
	},
	{
		"id": ID_NIVEL_1, "nivel": 1, "tier": ORO, "face": 2,
		"nombre": "Insignia del Gato Héroe de la Villa",
		"descripcion": "Completaste los 10 ejercicios del Nivel 1.",
	},
	{
		"id": ID_N2_CAZADOR, "nivel": 2, "tier": PLATA, "face": 1,
		"nombre": "Insignia del Cazador de Ciclos",
		"descripcion": "Resolviste al menos 8 de los 10 ejercicios del Bosque Profundo, con ciclos que terminan correctamente.",
	},
	{
		"id": ID_N3_MAESTRO, "nivel": 3, "tier": ORO, "face": 2,
		"nombre": "Insignia del Maestro del Núcleo Cibernético",
		"descripcion": "Superaste el examen integrador del complejo subterráneo sin quedarte sin vidas.",
	},
	{
		"id": ID_DEPURADOR, "nivel": 0, "tier": BRONCE, "face": 0,
		"nombre": "Insignia del Depurador Persistente",
		"descripcion": "Corregiste una solución tras recibir feedback y resolviste el ejercicio sin repetir el mismo error.",
	},
	{
		"id": ID_N1_PANADERIA, "nivel": 1, "tier": PLATA, "face": 0,
		"nombre": "Insignia del Maestro Panadero",
		"descripcion": "Completaste todos lss problemas de la Panadería.",
	},
	{
		"id": ID_N1_ESCUELA, "nivel": 1, "tier": PLATA, "face": 1,
		"nombre": "Insignia del Gato Matrícula de Honor",
		"descripcion": "Completaste todos lss problemas de la Escuela.",
	},
	{
		"id": ID_N1_EXAMEN_1ER, "nivel": 1, "tier": PLATA, "face": 2,
		"nombre": "Insignia del Examen Sin Rasguños",
		"descripcion": "Superaste el examen del Nivel 1 en el primer intento, sin reiniciarlo.",
	},
	{
		"id": ID_RACHA_12, "nivel": 0, "tier": PLATA, "face": 1,
		"nombre": "Insignia de la Cola Veloz",
		"descripcion": "Lograste una racha de 12 aciertos seguidos.",
	},
	{
		"id": ID_RACHA_25, "nivel": 0, "tier": ORO, "face": 2,
		"nombre": "Insignia del Gato Leyenda",
		"descripcion": "Lograste una racha de 25 aciertos seguidos.",
	},
	{
		"id": ID_N2_COMPLETO, "nivel": 2, "tier": ORO, "face": 2,
		"nombre": "Insignia del Guardián del Bosque",
		"descripcion": "Completaste los 10 ejercicios del Bosque Profundo y aprobaste su examen.",
	},
	{
		"id": ID_N2_IMPECABLE, "nivel": 2, "tier": PLATA, "face": 0,
		"nombre": "Insignia del Rastreador Impecable",
		"descripcion": "Aprobaste el examen del Bosque Profundo sin cometer ningún error.",
	},
	{
		"id": ID_N3_COMPLETO, "nivel": 3, "tier": ORO, "face": 1,
		"nombre": "Insignia del Gato Ingeniero Jefe",
		"descripcion": "Completaste los 10 ejercicios del Complejo Subterráneo y aprobaste el examen final.",
	},
	{
		"id": ID_N3_SIN_BUGS, "nivel": 3, "tier": PLATA, "face": 0,
		"nombre": "Insignia del Código Sin Bugs",
		"descripcion": "Resolviste al menos 5 ejercicios del Complejo Subterráneo sin cometer ningún error.",
	},
]

var _desbloqueadas: Dictionary = {}   # id -> timestamp unix
var _layer: CanvasLayer = null
var _queue: Array = []
var _showing: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_layer = CanvasLayer.new()
	_layer.layer = 100
	add_child(_layer)
	_load()
	GameData.problemsChanged.connect(_onProblemsChanged)
	GameData.rachaChanged.connect(_onRachaChanged)
	GameData.exerciseSolved.connect(_onExerciseSolved)
	GameData.exerciseDebugged.connect(_onExerciseDebugged)
	insigniaDesbloqueada.connect(_onInsigniaDesbloqueada)

# ── API pública ───────────────────────────────────────────────────────────────

func getCatalogo() -> Array:
	return CATALOGO

func getInfo(id: String) -> Dictionary:
	for info in CATALOGO:
		if info["id"] == id:
			return info
	return {}

func isUnlocked(id: String) -> bool:
	return _desbloqueadas.has(id)

func unlockedCount() -> int:
	return _desbloqueadas.size()

func totalCount() -> int:
	return CATALOGO.size()

func unlock(id: String) -> void:
	if _desbloqueadas.has(id):
		return
	var info := getInfo(id)
	if info.is_empty():
		push_warning("Insignias: id desconocido '%s'" % id)
		return
	_desbloqueadas[id] = int(Time.get_unix_time_from_system())
	_save()
	insigniaDesbloqueada.emit(id)
	_queue.append(info)
	if not _showing:
		_processQueue()

func reset() -> void:
	_desbloqueadas.clear()
	_queue.clear()
	_save()

# ── Condiciones (Nivel 1) ─────────────────────────────────────────────────────

func _onProblemsChanged() -> void:
	var solved: int = GameData.solvedProblemsCount()
	if solved >= 1:
		unlock(ID_PRIMER_PUZZLE)
	if solved >= GameData.TOTAL_PROBLEMS:
		unlock(ID_NIVEL_1)
	if _todasResueltas(MISIONES_PANADERIA):
		unlock(ID_N1_PANADERIA)
	if _todasResueltas(MISIONES_ESCUELA):
		unlock(ID_N1_ESCUELA)
	# El examen se aprueba al marcar resuelto al guardia (nivel1Terminado)
	if GameData.nivel1Terminado and GameData.nivel1ExamReinicios == 0:
		unlock(ID_N1_EXAMEN_1ER)

func _todasResueltas(ids: Array) -> bool:
	for id in ids:
		if not GameData.isSolved(RUTA_DIALOGOS_N1 % id):
			return false
	return true

func _onRachaChanged(value: int) -> void:
	if value >= 5:
		unlock(ID_RACHA_5)
	if value >= 12:
		unlock(ID_RACHA_12)
	if value >= 25:
		unlock(ID_RACHA_25)

# Niveles 2 y 3: GameData avisa cada vez que se acredita un ejercicio.
func _onExerciseSolved(level: int, _code: String) -> void:
	if level == 2 and GameData.solvedCount(2) >= 8:
		unlock(ID_N2_CAZADOR)
	if GameData.levelRequirementsDone(2):
		unlock(ID_N2_COMPLETO)
	if GameData.perfectExercises.has("EX2"):
		unlock(ID_N2_IMPECABLE)
	if GameData.perfectCount(3) >= 5:
		unlock(ID_N3_SIN_BUGS)
	_checkNivel3()

func _onInsigniaDesbloqueada(id: String) -> void:
	if id == ID_N3_MAESTRO:
		_checkNivel3()

# Nivel 3 completo = 10 ejercicios + examen final (que otorga el Maestro del Núcleo).
func _checkNivel3() -> void:
	if isUnlocked(ID_N3_MAESTRO) and GameData.solvedCount(3) >= GameData.levelTotal(3):
		unlock(ID_N3_COMPLETO)

func _onExerciseDebugged(_code: String) -> void:
	unlock(ID_DEPURADOR)

# ── Toast ─────────────────────────────────────────────────────────────────────

func _processQueue() -> void:
	_showing = true
	while not _queue.is_empty():
		var info: Dictionary = _queue.pop_front()
		await _showToast(info)
	_showing = false

func _showToast(info: Dictionary) -> void:
	var toast := ToastScript.new()
	toast.setup(info)
	toast.modulate.a = 0.0
	_layer.add_child(toast)
	# Esperar a que el contenedor calcule su tamaño real
	await get_tree().process_frame
	await get_tree().process_frame
	var viewW: float = get_viewport().get_visible_rect().size.x
	var targetX: float = viewW - toast.size.x - TOAST_MARGIN
	toast.position = Vector2(viewW + 20.0, TOAST_MARGIN)
	toast.modulate.a = 1.0
	if DJManager.has_method("playInsignia"):
		DJManager.playInsignia()

	var tin := create_tween()
	tin.tween_property(toast, "position:x", targetX, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tin.finished
	await get_tree().create_timer(TOAST_HOLD).timeout
	var tout := create_tween().set_parallel(true)
	tout.tween_property(toast, "position:x", viewW + 20.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tout.tween_property(toast, "modulate:a", 0.0, 0.35)
	await tout.finished
	toast.queue_free()

# ── Guardado ──────────────────────────────────────────────────────────────────

func _save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Insignias: no se pudo guardar en %s" % SAVE_PATH)
		return
	file.store_string(JSON.stringify({"desbloqueadas": _desbloqueadas}))

func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		return
	var saved = data.get("desbloqueadas", {})
	if typeof(saved) != TYPE_DICTIONARY:
		return
	for id in saved.keys():
		if not getInfo(str(id)).is_empty():
			_desbloqueadas[str(id)] = int(saved[id])
