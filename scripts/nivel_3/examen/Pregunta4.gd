extends "res://scripts/nivel_3/examen/PreguntaExamenBase.gd"

# ==========================================
# MGTS - NIVEL 3 - BANCO EXAMEN PREGUNTA 4
# CLASIFICADOR TÉRMICO MULTIZONA
# ==========================================

const NUMERO_BANCO: int = 4
const ID_PREGUNTA: String = "EX3.P4"
const OA_PREGUNTA: String = "OA2 / OA3: Ciclo while con condicional encadenado if / elif / else y contador"
const TITULO_PREGUNTA: String = "Clasificador térmico multizona"
const INSTRUCCIONES_PREGUNTA: String = (
	"Recorre las 3 zonas térmicas con un ciclo while: si la temperatura supera 80 suma 1 a criticas, "
	+ "si no pero supera 40 usa elif para sumar 1 a alertas, y en otro caso usa else para normales."
)

const PLANTILLA_CODIGO: String = (
	"zona = 0\n"
	+ "criticas = 0\n"
	+ "alertas = 0\n"
	+ "normales = 0\n\n"
	+ "[ Espacio 1 ]\n"
	+ "    temp = int(input(\"Temp: \"))\n"
	+ "    [ Espacio 2 ]\n"
	+ "        criticas = criticas + 1\n"
	+ "    [ Espacio 3 ]\n"
	+ "        alertas = alertas + 1\n"
	+ "    [ Espacio 4 ]\n"
	+ "        normales = normales + 1\n"
	+ "    zona = zona + 1"
)

const RESPUESTA_CORRECTA: Array[String] = [
	"while zona < 3:",
	"if temp > 80:",
	"elif temp > 40:",
	"else:"
]

const BLOQUES_DISPONIBLES: Array[String] = [
	"while zona < 3:",
	"while zona > 3:",
	"if temp > 80:",
	"if temp < 40:",
	"elif temp > 40:",
	"elif temp > 80:",
	"else:",
	"zona = 0"
]

const TIPOS_ERROR: Dictionary = {
	"while zona > 3:": "condicion_ciclo",
	"if temp < 40:": "orden_rangos",
	"elif temp > 80:": "condicion_elif",
	"zona = 0": "estructura_else"
}
