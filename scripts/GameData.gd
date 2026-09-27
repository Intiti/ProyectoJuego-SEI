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

func markSolved(dialogFile: String) -> void:
	solvedDialogs[dialogFile] = true

func isSolved(dialogFile: String) -> bool:
	return solvedDialogs.get(dialogFile, false)
