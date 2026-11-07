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
	"El reactor guarda su energía en una variable llamada energia, que parte en 0, y cuenta los ciclos de carga en otra llamada ciclos, que también parte en 0. Las compuertas se abren cuando la energía llega a 15 o más.\n"
	+ "El programa repite un ciclo mientras se cumplan DOS cosas a la vez: que la energía todavía sea menor que 15 y que los ciclos sean menores que 5.\n"
	+ "Dentro del ciclo, primero se pide por teclado una carga que sea un número entero y se muestra en pantalla. Luego se revisa la carga: solo si es mayor o igual a 5 se suma a la energía. Una carga menor que 5 se ignora.\n"
	+ "Al final de cada vuelta el contador de ciclos avanza de 1 en 1. Cuando el ciclo termina se muestra un mensaje distinto según si la energía alcanzó o no los 15."
)

const PLANTILLA_CODIGO: String = (
	"energia = 0\n"
	+ "ciclos = 0\n\n"
	+ "[ Espacio 1 ]\n"
	+ "    [ Espacio 2 ]\n"
	+ "    print(\"Carga recibida:\", carga)\n"
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
