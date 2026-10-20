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
	"Mientras los intentos sean menores que 3 y la cápsula no esté abierta, solicita el código "
	+ "por teclado y, si es igual a \"PANKO\", cambia la bandera abierta a True."
)

const PLANTILLA_CODIGO: String = (
	"intentos = 0\n"
	+ "abierta = False\n\n"
	+ "[ Espacio 1 ]\n"
	+ "    [ Espacio 2 ]\n"
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
