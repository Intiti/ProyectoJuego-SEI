extends "res://scripts/nivel_3/examen/PreguntaExamenBase.gd"

# ==========================================
# MGTS - NIVEL 3 - BANCO EXAMEN PREGUNTA 1
# LAS COMPUERTAS DEL REACTOR
# ==========================================

const NUMERO_BANCO: int = 1
const ID_PREGUNTA: String = "EX3.P1"
const OA_PREGUNTA: String = "OA2 / OA3: Ciclo while con operador and, acumulador y filtro condicional"
const TITULO_PREGUNTA: String = "Las compuertas del reactor"
const INSTRUCCIONES_PREGUNTA: String = (
	"Mientras la energía sea menor que 15 y los ciclos sean menores que 5, solicita una carga "
	+ "entera por teclado y súmala al acumulador únicamente si es mayor o igual a 5."
)

const PLANTILLA_CODIGO: String = (
	"energia = 0\n"
	+ "ciclos = 0\n\n"
	+ "[ Espacio 1 ]\n"
	+ "    [ Espacio 2 ]\n"
	+ "    [ Espacio 3 ]\n"
	+ "        [ Espacio 4 ]\n"
	+ "    ciclos = ciclos + 1\n\n"
	+ "if energia >= 15:\n"
	+ "    print(\"Compuertas abiertas\")\n"
	+ "else:\n"
	+ "    print(\"Energía insuficiente\")"
)

const RESPUESTA_CORRECTA: Array[String] = [
	"while energia < 15 and ciclos < 5:",
	"carga = int(input(\"Carga: \"))",
	"if carga >= 5:",
	"energia = energia + carga"
]

const BLOQUES_DISPONIBLES: Array[String] = [
	"while energia < 15 and ciclos < 5:",
	"while energia >= 15 or ciclos < 5:",
	"carga = int(input(\"Carga: \"))",
	"carga = 15",
	"if carga >= 5:",
	"if carga < 5:",
	"energia = energia + carga",
	"energia = carga"
]

const TIPOS_ERROR: Dictionary = {
	"while energia >= 15 or ciclos < 5:": "condicion_ciclo",
	"carga = 15": "lectura_entrada",
	"if carga < 5:": "condicion_interna",
	"energia = carga": "acumulador"
}
