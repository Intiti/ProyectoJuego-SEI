extends "res://scripts/nivel_3/examen/PreguntaExamenBase.gd"

# ==========================================
# MGTS - NIVEL 3 - BANCO EXAMEN PREGUNTA 3
# DESBLOQUEO DE LA CÁPSULA DE PANKO
# ==========================================

const NUMERO_BANCO: int = 3
const ID_PREGUNTA: String = "EX3.P3"
const OA_PREGUNTA: String = "OA2 / OA3: Ciclo while con límite de intentos, bandera booleana y comparación"
const TITULO_PREGUNTA: String = "Desbloqueo de la cápsula de Panko"
const INSTRUCCIONES_PREGUNTA: String = (
	"La cápsula de Panko se abre con una clave. El programa guarda el número de intentos realizados en una variable llamada intentos, que parte en 0, y una bandera llamada abierta, que parte en False (cápsula cerrada).\n"
	+ "El programa repite un ciclo mientras queden menos de 3 intentos y, al mismo tiempo, la cápsula todavía NO esté abierta.\n"
	+ "Dentro del ciclo se pide por teclado el código, que es un texto, y se informa que se recibió un intento. Luego se compara el código ingresado con la palabra PANKO: solo si es exactamente igual, la bandera de la cápsula debe pasar a abierta (True).\n"
	+ "Al final de cada vuelta el contador de intentos avanza de 1 en 1. Cuando el ciclo termina se muestra si la cápsula fue liberada o si quedó bloqueada."
)

const PLANTILLA_CODIGO: String = (
	"intentos = 0\n"
	+ "abierta = False\n\n"
	+ "[ Espacio 1 ]\n"
	+ "    [ Espacio 2 ]\n"
	+ "    print(\"Intento recibido\")\n"
	+ "    [ Espacio 3 ]\n"
	+ "        [ Espacio 4 ]\n"
	+ "    intentos = intentos + 1\n\n"
	+ "if abierta:\n"
	+ "    print(\"Cápsula liberada\")\n"
	+ "else:\n"
	+ "    print(\"Bloqueo de seguridad\")"
)

const RESPUESTA_CORRECTA: Array[String] = [
	"while intentos < 3 and not abierta:",
	"codigo = input(\"Código: \")",
	"if codigo == \"PANKO\":",
	"abierta = True"
]

const BLOQUES_DISPONIBLES: Array[String] = [
	"while intentos < 3 and not abierta:",
	"while intentos <= 3 or abierta:",
	"codigo = input(\"Código: \")",
	"codigo = \"PANKO\"",
	"if codigo == \"PANKO\":",
	"if codigo != \"PANKO\":",
	"abierta = True",
	"abierta = False"
]

const TIPOS_ERROR: Dictionary = {
	"while intentos <= 3 or abierta:": "condicion_ciclo",
	"codigo = \"PANKO\"": "lectura_entrada",
	"if codigo != \"PANKO\":": "condicion_interna",
	"abierta = False": "bandera_booleana"
}
