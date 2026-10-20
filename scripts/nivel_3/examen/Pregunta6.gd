extends "res://scripts/nivel_3/examen/PreguntaExamenBase.gd"

# ==========================================
# MGTS - NIVEL 3 - BANCO EXAMEN PREGUNTA 6
# SINCRONIZACIÓN DEL PUENTE DE RESCATE
# ==========================================

const NUMERO_BANCO: int = 6
const ID_PREGUNTA: String = "EX3.P6"
const OA_PREGUNTA: String = "OA2 / OA3: Ciclo while con bandera booleana, operador or y rama else"
const TITULO_PREGUNTA: String = "Sincronización del puente de rescate"
const INSTRUCCIONES_PREGUNTA: String = (
	"Mientras el puente no esté listo y los fallos sean menores que 3, lee la frecuencia. "
	+ "Si es \"ALFA\" o \"MIAU\", activa puente_listo = True; de lo contrario incrementa los fallos."
)

const PLANTILLA_CODIGO: String = (
	"puente_listo = False\n"
	+ "fallos = 0\n\n"
	+ "[ Espacio 1 ]\n"
	+ "    frecuencia = input(\"Frecuencia: \")\n"
	+ "    [ Espacio 2 ]\n"
	+ "        [ Espacio 3 ]\n"
	+ "    else:\n"
	+ "        [ Espacio 4 ]"
)

const RESPUESTA_CORRECTA: Array[String] = [
	"while not puente_listo and fallos < 3:",
	"if frecuencia == \"ALFA\" or frecuencia == \"MIAU\":",
	"puente_listo = True",
	"fallos = fallos + 1"
]

const BLOQUES_DISPONIBLES: Array[String] = [
	"while not puente_listo and fallos < 3:",
	"while puente_listo or fallos < 3:",
	"if frecuencia == \"ALFA\" or frecuencia == \"MIAU\":",
	"if frecuencia == \"ALFA\" and frecuencia == \"MIAU\":",
	"puente_listo = True",
	"puente_listo = False",
	"fallos = fallos + 1",
	"fallos = 0"
]

const TIPOS_ERROR: Dictionary = {
	"while puente_listo or fallos < 3:": "condicion_ciclo",
	"if frecuencia == \"ALFA\" and frecuencia == \"MIAU\":": "operador_logico",
	"puente_listo = False": "bandera_booleana",
	"fallos = 0": "contador_fallos"
}
