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
	"El puente de rescate necesita sincronizarse con una frecuencia secreta. El programa usa una bandera llamada puente_listo, que parte en False, y un contador de fallos llamado fallos, que parte en 0.\n"
	+ "El programa repite un ciclo mientras el puente NO esté listo y, al mismo tiempo, los fallos sean menores que 3.\n"
	+ "En cada vuelta se lee por teclado la frecuencia, que es un texto. Luego se revisa: si la frecuencia es ALFA o es MIAU (basta con que sea una de las dos), el puente queda listo y su bandera pasa a True.\n"
	+ "Si la frecuencia no es ninguna de esas dos, se usa la rama else: allí se suma 1 al contador de fallos. Cuando el ciclo termina se muestra si el puente quedó sincronizado o bloqueado."
)

const PLANTILLA_CODIGO: String = (
	"puente_listo = False\n"
	+ "fallos = 0\n\n"
	+ "[ Espacio 1 ]\n"
	+ "    frecuencia = input(\"Frecuencia: \")\n"
	+ "    [ Espacio 2 ]\n"
	+ "        [ Espacio 3 ]\n"
	+ "    else:\n"
	+ "        [ Espacio 4 ]\n\n"
	+ "if puente_listo:\n"
	+ "    print(\"Puente sincronizado\")\n"
	+ "else:\n"
	+ "    print(\"Puente bloqueado\")"
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
