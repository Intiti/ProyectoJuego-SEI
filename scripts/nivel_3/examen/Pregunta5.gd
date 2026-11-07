extends "res://scripts/nivel_3/examen/PreguntaExamenBase.gd"

# ==========================================
# MGTS - NIVEL 3 - BANCO EXAMEN PREGUNTA 5
# RESERVA DE OXÍGENO SUBTERRÁNEO
# ==========================================

const NUMERO_BANCO: int = 5
const ID_PREGUNTA: String = "EX3.P5"
const OA_PREGUNTA: String = "OA2 / OA3: Ciclo while con acumulador, contador y condición con and not"
const TITULO_PREGUNTA: String = "Reserva de oxígeno subterráneo"
const INSTRUCCIONES_PREGUNTA: String = (
	"La reserva de oxígeno se mide en una variable llamada oxigeno, que parte en 0, y los tanques revisados se cuentan en otra llamada tanques, que también parte en 0.\n"
	+ "El programa repite un ciclo mientras el oxígeno sea menor que 20 y, al mismo tiempo, los tanques revisados sean menores que 4.\n"
	+ "En cada vuelta se lee por teclado la reserva del tanque, como número entero, y se pregunta si hay fuga: escribir si significa que hay fuga. Luego se decide si el tanque sirve: la reserva se suma al oxígeno solo cuando la reserva es positiva y, además, NO hay fuga.\n"
	+ "Pase lo que pase con la reserva, el tanque ya fue revisado, así que el contador de tanques avanza de 1 en 1 en cada vuelta. Al terminar se muestra el oxígeno total."
)

const PLANTILLA_CODIGO: String = (
	"oxigeno = 0\n"
	+ "tanques = 0\n\n"
	+ "[ Espacio 1 ]\n"
	+ "    reserva = int(input(\"Reserva: \"))\n"
	+ "    fuga = input(\"¿Fuga? (si/no): \") == \"si\"\n"
	+ "    [ Espacio 2 ]\n"
	+ "        [ Espacio 3 ]\n"
	+ "    print(\"Tanque revisado\")\n"
	+ "    [ Espacio 4 ]\n\n"
	+ "print(\"Oxígeno total:\", oxigeno)"
)

const RESPUESTA_CORRECTA: Array[String] = [
	"while oxigeno < 20 and tanques < 4:",
	"if reserva > 0 and not fuga:",
	"oxigeno = oxigeno + reserva",
	"tanques = tanques + 1"
]

const BLOQUES_DISPONIBLES: Array[String] = [
	"while oxigeno < 20 and tanques < 4:",
	"while oxigeno >= 20 or tanques < 4:",
	"if reserva > 0 and not fuga:",
	"if reserva > 0 or fuga:",
	"oxigeno = oxigeno + reserva",
	"oxigeno = reserva",
	"tanques = tanques + 1",
	"tanques = tanques - 1"
]

const TIPOS_ERROR: Dictionary = {
	"while oxigeno >= 20 or tanques < 4:": "condicion_ciclo",
	"if reserva > 0 or fuga:": "operador_logico",
	"oxigeno = reserva": "acumulador",
	"tanques = tanques - 1": "contador"
}
