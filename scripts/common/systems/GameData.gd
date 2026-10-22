extends Node

var playerName: String = "Jugador"
var alcaldePuzzleSolved: bool = false

# Escena de origen para spawn correcto al cambiar de villa
# "left"  → el jugador venía del lado izquierdo → aparece a la izquierda
# "right" → el jugador venía del lado derecho  → aparece a la derecha
var spawnSide: String = "left"

# Flags de puzzles resueltos por NPC (indexados por dialogFile)
# Se usan para que los NPCs no reseteen su "!" al reentrar a la escena
var solvedDialogs: Dictionary = {}
# Se emite cada vez que cambian los puntos (lo usa el cuadro SCORE de la pantalla)
signal gatopuntosChanged(newValue: int)
var gatopuntos: int = 0:
	set(value):
		gatopuntos = value
		gatopuntosChanged.emit(value)

# Problemas de la villa: los 10 NPC (npc_e11 = alcalde ... npc_e20). El guardia/examen no cuenta.
const TOTAL_PROBLEMS := 10
const FIRST_PROBLEM := "res://dialogs/nivel_1/npc_e11.json"   # el del alcalde

signal problemsChanged

const LeaderboardScript = preload("res://scripts/common/systems/LeaderboardNivel1.gd")
const GUARDIA_FILE := "res://dialogs/nivel_1/npc_guardia_villa2.json"

signal nivel1Submitted

var rachaMaxNivel1: int = 0
var nivel1Terminado: bool = false
var nivel1Resumen: Dictionary = {}
var nivel1SubmitDone: bool = false
var nivel1SubmitOk: bool = false
var nivel1ResumenMostrado: bool = false
# Veces que se reinició el examen del Nivel 1 (0 = aprobado al primer intento)
var nivel1ExamReinicios: int = 0
# Ejercicios/exámenes de los niveles 2 y 3 resueltos sin ningún error: código -> true
var perfectExercises: Dictionary = {}

func markSolved(dialogFile: String) -> void:
	solvedDialogs[dialogFile] = true
	problemsChanged.emit()
	if dialogFile == GUARDIA_FILE and not nivel1Terminado:
		nivel1Terminado = true
		nivel1Resumen = {
			"score": gatopuntos,
			"racha": rachaMaxNivel1,
			"problemas": solvedProblemsCount(),
		}
		_submitNivel1()
	syncLevelSummaries()

func _submitNivel1() -> void:
	nivel1SubmitOk = await LeaderboardScript.submitFinalScore(nivel1Resumen["score"], nivel1Resumen["racha"], playerName)
	nivel1SubmitDone = true
	nivel1Submitted.emit()

func resetRun() -> void:
	solvedDialogs.clear()
	alcaldePuzzleSolved = false
	nivel1Terminado = false
	nivel1Resumen = {}
	nivel1SubmitDone = false
	nivel1SubmitOk = false
	nivel1ResumenMostrado = false
	nivel1ExamReinicios = 0
	perfectExercises.clear()
	rachaMaxNivel1 = 0
	rachaGlobal = 0
	gatopuntos = 0
	solvedExercises.clear()
	_errorSignatures.clear()
	_repeatedErrors.clear()
	lastBreakdown = {}
	puntosNivel = {1: 0, 2: 0, 3: 0}
	nivel2ExamenAprobado = false
	# Nueva partida: el Nivel 2 también vuelve a cero (antes conservaba sus ejercicios).
	var p2: Node = get_node_or_null("/root/PuntajesNivel2")
	if p2 != null and p2.has_method("reiniciar_nivel"):
		p2.call("reiniciar_nivel")
	problemsChanged.emit()

func solvedProblemsCount() -> int:
	var n := 0
	for k in solvedDialogs.keys():
		if String(k).get_file().begins_with("npc_e"):
			n += 1
	return n

func firstProblemSolved() -> bool:
	return isSolved(FIRST_PROBLEM)

func isSolved(dialogFile: String) -> bool:
	return solvedDialogs.get(dialogFile, false)

# Racha global entre puzzles (aciertos seguidos sin fallar).
# Emite rachaChanged cada vez que cambia (lo usa el sistema de insignias).
signal rachaChanged(newValue: int)
var rachaGlobal: int = 0:
	set(value):
		rachaGlobal = value
		if not nivel1Terminado and value > rachaMaxNivel1:
			rachaMaxNivel1 = value
		rachaChanged.emit(value)


# ═════════════════════════════════════════════════════════════════════════════
#  REGLAS DE PUNTAJE COMPARTIDAS (Niveles 1, 2 y 3)
#
#  Una sola fuente de verdad para puntos base, penalización por errores, racha
#  y bono. Cada nivel conserva su valor por bloque (20 / 40 / 60); lo demás es
#  común:
#     · Penalización: 1 error = 0 %, 2 errores = -25 %, 3 o más = -50 %.
#     · Racha: cada acierto suma 1 y CUALQUIER error la reinicia a 0.
#     · Bono: desde racha 3, racha x 5 puntos.
#
#  Nivel 1 valida paso a paso (cada bloque correcto suma 1 a la racha).
#  Niveles 2 y 3 validan el programa completo al pulsar Comprobar, así que al
#  resolver el ejercicio la racha suma tantos aciertos como bloques tiene, y
#  cada comprobación fallida la reinicia (mismo criterio que el Nivel 1).
# ═════════════════════════════════════════════════════════════════════════════

const POINTS_PER_BLOCK := {1: 20, 2: 40, 3: 60}
const STREAK_BONUS_MIN := 3
const STREAK_BONUS_PER_HIT := 5
const LEVEL_TOTALS := {1: 10, 2: 10, 3: 10}
const LEVEL_NAMES := {1: "Villa Miaulemana", 2: "Bosque Profundo", 3: "Complejo Subterráneo"}

signal exerciseSolved(level: int, code: String)

# Ejercicios de los niveles 2 y 3 ya acreditados: código ("E2.1") -> puntos totales.
var solvedExercises: Dictionary = {}
# Puntos ganados en cada nivel (gatopuntos es la suma de los tres).
var puntosNivel: Dictionary = {1: 0, 2: 0, 3: 0}
# Desglose del último ejercicio acreditado (lo leen las ventanas de completado).
var lastBreakdown: Dictionary = {}
var nivel2ExamenAprobado: bool = false

func basePoints(level: int, blocks: int) -> int:
	return blocks * int(POINTS_PER_BLOCK.get(level, POINTS_PER_BLOCK[1]))

func errorPenalty(base: int, errors: int) -> int:
	if errors == 2:
		return int(base * 0.25)
	elif errors >= 3:
		return int(base * 0.50)
	return 0

func streakBonus() -> int:
	if rachaGlobal >= STREAK_BONUS_MIN:
		return rachaGlobal * STREAK_BONUS_PER_HIT
	return 0

# Desglose con la racha ACTUAL (llamar después de sumar los aciertos del ejercicio).
func scoreBreakdown(level: int, blocks: int, errors: int) -> Dictionary:
	var base: int = basePoints(level, blocks)
	var pen: int = errorPenalty(base, errors)
	var bonus: int = streakBonus()
	return {"base": base, "pen": pen, "bonus": bonus, "total": maxi(0, base - pen + bonus)}

func streakHit(count: int = 1) -> void:
	if count > 0:
		rachaGlobal += count

# Un error reinicia la racha. Si el ejercicio ya estaba resuelto (repetición sin
# recompensa) no se toca la racha, para que repetir no sirva ni para sumar ni para perder.
func streakFail(code: String = "") -> void:
	if code != "" and solvedExercises.has(code):
		return
	rachaGlobal = 0

func addPoints(level: int, amount: int) -> void:
	if amount == 0:
		return
	puntosNivel[level] = int(puntosNivel.get(level, 0)) + amount
	gatopuntos += amount

func isExerciseSolved(code: String) -> bool:
	return solvedExercises.has(code)

# ── Depuración (insignia transversal "Depurador Persistente") ─────────────────
# Se registra cada respuesta equivocada con una firma (lo que el jugador colocó).
# Si el mismo error se repite, ese ejercicio ya no cuenta como "corregido sin repetir".
signal exerciseDebugged(code: String)
var _errorSignatures: Dictionary = {}   # código -> {firma: veces}
var _repeatedErrors: Dictionary = {}    # código -> true

func noteError(code: String, signature: String) -> void:
	if code == "" or solvedExercises.has(code):
		return
	var seen: Dictionary = _errorSignatures.get(code, {})
	if seen.has(signature):
		_repeatedErrors[code] = true
	seen[signature] = int(seen.get(signature, 0)) + 1
	_errorSignatures[code] = seen

# Se llama al resolver un ejercicio con >= 1 error previo.
func reportDebugged(code: String) -> void:
	if not _repeatedErrors.get(code, false):
		exerciseDebugged.emit(code)

# Puntos que realmente se acreditaron a un ejercicio (o `fallback` si aún no hay registro).
func creditedPoints(code: String, fallback: int = 0) -> int:
	return int(solvedExercises.get(code, fallback))

# Acredita un ejercicio de los niveles 2 o 3 (validación del programa completo).
# Devuelve {base, pen, bonus, total, repeat}. Si ya estaba resuelto no suma nada.
func completeExercise(level: int, code: String, blocks: int, errors: int) -> Dictionary:
	if solvedExercises.has(code):
		return {"base": 0, "pen": 0, "bonus": 0, "total": 0, "repeat": true}
	streakHit(blocks)
	var r: Dictionary = scoreBreakdown(level, blocks, errors)
	r["repeat"] = false
	solvedExercises[code] = int(r["total"])
	if errors == 0:
		perfectExercises[code] = true
	lastBreakdown = r.duplicate()
	lastBreakdown["code"] = code
	lastBreakdown["level"] = level
	addPoints(level, int(r["total"]))
	exerciseSolved.emit(level, code)
	if errors >= 1:
		reportDebugged(code)
	syncLevelSummaries()
	return r

func perfectCount(level: int) -> int:
	var n: int = 0
	var prefix: String = "E%d." % level
	for k in perfectExercises.keys():
		if String(k).begins_with(prefix):
			n += 1
	return n

func solvedCount(level: int) -> int:
	if level == 1:
		return solvedProblemsCount()
	var n: int = 0
	var prefix: String = "E%d." % level
	for k in solvedExercises.keys():
		if String(k).begins_with(prefix):
			n += 1
	return n

func levelTotal(level: int) -> int:
	return int(LEVEL_TOTALS.get(level, 0))

func levelName(level: int) -> String:
	return String(LEVEL_NAMES.get(level, ""))

# Acredita un examen (vidas, paso a paso). La racha ya se fue sumando en vivo con
# cada acierto, igual que en el Nivel 1, así que aquí solo se calcula el desglose.
# Los exámenes no cuentan como "problemas resueltos"; el del Nivel 2 sí es requisito
# para dar el nivel por completo.
func completeExam(level: int, code: String, blocks: int, errors: int) -> Dictionary:
	if solvedExercises.has(code):
		return {"base": 0, "pen": 0, "bonus": 0, "total": 0, "repeat": true}
	var r: Dictionary = scoreBreakdown(level, blocks, errors)
	r["repeat"] = false
	solvedExercises[code] = int(r["total"])
	if errors == 0:
		perfectExercises[code] = true
	lastBreakdown = r.duplicate()
	lastBreakdown["code"] = code
	lastBreakdown["level"] = level
	if level == 2:
		nivel2ExamenAprobado = true
	addPoints(level, int(r["total"]))
	exerciseSolved.emit(level, code)
	syncLevelSummaries()
	return r

func levelRequirementsDone(level: int) -> bool:
	match level:
		1:
			return nivel1Terminado
		2:
			return solvedCount(2) >= levelTotal(2) and nivel2ExamenAprobado
	return false

# Resumen de un nivel con el formato que espera PuntajesNivel3.integrar_resumen_nivel().
func levelSummary(level: int) -> Dictionary:
	var badges: Array = []
	var ins: Node = get_node_or_null("/root/Insignias")
	if ins != null:
		for info in ins.getCatalogo():
			if int(info["nivel"]) == level and ins.isUnlocked(String(info["id"])):
				badges.append({
					"id": String(info["id"]),
					"nombre": String(info["nombre"]),
					"descripcion": String(info["descripcion"]),
					"icono": String(info["id"]),
				})
	return {
		"puntos": int(puntosNivel.get(level, 0)),
		"completados": mini(solvedCount(level), levelTotal(level)),
		"total": levelTotal(level),
		"requisitos_completados": levelRequirementsDone(level),
		"insignias": badges,
	}

# Entrega los resultados de los niveles 1 y 2 a la pantalla final y al ranking general
# (que vive en PuntajesNivel3). No otorga recompensas, solo informa.
func syncLevelSummaries() -> void:
	var p3: Node = get_node_or_null("/root/PuntajesNivel3")
	if p3 == null or not p3.has_method("integrar_resumen_nivel"):
		return
	for level in [1, 2]:
		p3.call("integrar_resumen_nivel", level, levelSummary(level))
