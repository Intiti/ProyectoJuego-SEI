extends "res://scripts/nivel_3/compartidos/VentanaEjercicioBaseNivel3.gd"

# ==========================================
# MGTS - NIVEL 3 - EJERCICIO E3.4
# EL SISTEMA DE ENFRIAMIENTO
# ==========================================

const ID_EJERCICIO: String = "E3.4"
const TITULO_EJERCICIO: String = "E3.4 – El sistema de enfriamiento"
const OA_EJERCICIO: String = "OA2 / OA3: Ciclo while con decremento y condición de caso límite"
const DESCRIPCION_EJERCICIO: String = (
	"La temperatura inicial del reactor es 30 °C. Redúcela en 3 °C por ciclo mientras sea "
	+ "mayor que 20 °C y finalmente comprueba que haya quedado en 20 °C o menos."
)
const TOTAL_ESPACIOS: int = 4
const PUNTOS_POR_BLOQUE: int = 60

const PLANTILLA_CODIGO: String = (
	"temp = 30\n\n"
	+ "[ Espacio 1 ]\n"
	+ "    [ Espacio 2 ]\n\n"
	+ "[ Espacio 3 ]\n"
	+ "    [ Espacio 4 ]"
)

const RESPUESTA_CORRECTA: Array[String] = [
	"while temp > 20:",
	"temp = temp - 3",
	"if temp <= 20:",
	"print(\"Sistema estable\")"
]

const BLOQUES_DISPONIBLES: Array[String] = [
	"while temp > 20:",
	"while temp < 20:",
	"temp = temp - 3",
	"temp = temp + 3",
	"if temp <= 20:",
	"if temp > 30:",
	"print(\"Sistema estable\")",
	"temp = 30"
]

const TIPOS_ERROR: Dictionary = {
	"while temp < 20:": "condicion_ciclo",
	"temp = temp + 3": "actualizacion_variable",
	"if temp > 30:": "condicion_final",
	"temp = 30": "accion_final"
}

const MENSAJES_ERROR: Dictionary = {
	"condicion_ciclo": "La temperatura inicia en 30, por lo que 'temp < 20' es falso desde el inicio y nunca enfriaría.",
	"actualizacion_variable": "Sumar 3 grados aumenta el calor del reactor y provoca un ciclo infinito.",
	"condicion_final": "El sistema es seguro cuando temp <= 20, no cuando supera 30.",
	"accion_final": "Al estabilizar la temperatura debes mostrar print(\"Sistema estable\").",
	"orden_incorrecto": "Revisa qué bloque corresponde al ciclo while y cuál al condicional if final."
}

const PISTAS: Dictionary = {
	0: "El ciclo while debe ejecutarse mientras la temperatura supere los 20 grados (while temp > 20:).",
	1: "En cada ciclo de enfriamiento disminuye la temperatura en 3 grados (temp = temp - 3).",
	2: "Al terminar el ciclo, verifica el umbral seguro con if temp <= 20:.",
	3: "Confirma la estabilización en pantalla con print(\"Sistema estable\")."
}


func validar_algoritmo_y_casos() -> Dictionary:
	for i in range(TOTAL_ESPACIOS):
		if bloques_colocados[i] != RESPUESTA_CORRECTA[i]:
			return {"correcto": false}

	var casos: Array = [
		{"temp_ini": 30, "temp_fin": 18, "ciclos": 4},
		{"temp_ini": 20, "temp_fin": 20, "ciclos": 0}
	]
	for c in casos:
		var temp: int = int(c["temp_ini"])
		var iteraciones: int = 0
		while temp > 20 and iteraciones < 20:
			temp = temp - 3
			iteraciones += 1
		if temp != int(c["temp_fin"]) or iteraciones != int(c["ciclos"]) or not (temp <= 20):
			return {"correcto": false}

	return {
		"correcto": true,
		"resumen_casos": "✓ Enfriamiento de 30 °C a 18 °C en 4 ciclos | ✓ Umbral seguro <= 20 °C verificado"
	}
