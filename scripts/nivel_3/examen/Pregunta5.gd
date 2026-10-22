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
	"Mientras el oxígeno sea menor que 20 y los tanques revisados sean menores que 4, "
	+ "suma la reserva al acumulador cuando sea positiva y no exista fuga (por teclado, \"si\" indica fuga), y avanza el contador de tanques."
)

const PLANTILLA_CODIGO: String = (
	"oxigeno = 0\n"
	+ "tanques = 0\n\n"
	+ "[ Espacio 1 ]\n"
	+ "    reserva = int(input(\"Reserva: \"))\n"
	+ "    fuga = input(\"¿Fuga? (si/no): \") == \"si\"\n"
	+ "    [ Espacio 2 ]\n"
	+ "        [ Espacio 3 ]\n"
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
