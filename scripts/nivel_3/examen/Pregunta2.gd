extends "res://scripts/nivel_3/examen/PreguntaExamenBase.gd"

# ==========================================
# MGTS - NIVEL 3 - BANCO EXAMEN PREGUNTA 2
# EL FILTRO DE BIOSEGURIDAD
# ==========================================

const NUMERO_BANCO: int = 2
const ID_PREGUNTA: String = "EX3.P2"
const OA_PREGUNTA: String = "OA2 / OA3: Ciclo while con bandera negada (not), operador or y contador"
const TITULO_PREGUNTA: String = "El filtro de bioseguridad"
const INSTRUCCIONES_PREGUNTA: String = (
	"El filtro de bioseguridad usa una bandera llamada alerta, que parte en False (sin alerta), y un contador llamado muestras, que parte en 0.\n"
	+ "El programa repite un ciclo mientras la alerta NO esté activada y, al mismo tiempo, las muestras sean menores que 4.\n"
	+ "Dentro del ciclo se pide por teclado el nivel de la muestra, como número entero, y se muestra en pantalla. Luego se revisa el nivel: si es menor que 0 o mayor que 100, el valor es peligroso y la bandera de alerta debe quedar activada (en True). Si el nivel está entre 0 y 100, no se toca nada.\n"
	+ "Al final de cada vuelta el contador de muestras avanza de 1 en 1. Cuando el ciclo termina, se muestra si la bioseguridad quedó estable o si la alerta se activó."
)

const PLANTILLA_CODIGO: String = (
	"alerta = False\n"
	+ "muestras = 0\n\n"
	+ "[ Espacio 1 ]\n"
	+ "    [ Espacio 2 ]\n"
	+ "    print(\"Nivel leído:\", nivel)\n"
	+ "    [ Espacio 3 ]\n"
	+ "        [ Espacio 4 ]\n"
	+ "    muestras = muestras + 1\n\n"
	+ "if not alerta:\n"
	+ "    print(\"Bioseguridad estable\")\n"
	+ "else:\n"
	+ "    print(\"Alerta activada\")"
)

const RESPUESTA_CORRECTA: Array[String] = [
	"while not alerta and muestras < 4:",
	"nivel = int(input(\"Nivel: \"))",
	"if nivel < 0 or nivel > 100:",
	"alerta = True"
]

const BLOQUES_DISPONIBLES: Array[String] = [
	"while not alerta and muestras < 4:",
	"while alerta or muestras < 4:",
	"nivel = int(input(\"Nivel: \"))",
	"nivel = 100",
	"if nivel < 0 or nivel > 100:",
	"if nivel < 0 and nivel > 100:",
	"alerta = True",
	"alerta = False"
]

const TIPOS_ERROR: Dictionary = {
	"while alerta or muestras < 4:": "condicion_ciclo",
	"nivel = 100": "lectura_entrada",
	"if nivel < 0 and nivel > 100:": "operador_logico",
	"alerta = False": "bandera_booleana"
}
