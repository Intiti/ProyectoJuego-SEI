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
	rachaMaxNivel1 = 0
	rachaGlobal = 0
	gatopuntos = 0
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
