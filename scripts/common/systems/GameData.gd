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

func markSolved(dialogFile: String) -> void:
	solvedDialogs[dialogFile] = true

func isSolved(dialogFile: String) -> bool:
	return solvedDialogs.get(dialogFile, false)

# Racha global entre puzzles
var rachaGlobal: int = 0
