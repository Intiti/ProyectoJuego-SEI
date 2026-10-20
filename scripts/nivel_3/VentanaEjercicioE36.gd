extends "res://scripts/nivel_3/compartidos/VentanaEjercicioBaseNivel3.gd"

# ==========================================
# MGTS - NIVEL 3 - EJERCICIO E3.6
# LOS REGISTROS GENÉTICOS
# ==========================================

const ID_EJERCICIO: String = "E3.6"
const TITULO_EJERCICIO: String = "E3.6 – Los registros genéticos"
const OA_EJERCICIO: String = "OA2 / OA3: Ciclo while con operador lógico or y contador"
const DESCRIPCION_EJERCICIO: String = (
	"Filtra la lista de muestras del laboratorio contando como válidos los registros "
	+ "cuyo valor sea \"felino\" o \"panko\"."
)
const TOTAL_ESPACIOS: int = 4
const PUNTOS_POR_BLOQUE: int = 60

const PLANTILLA_CODIGO: String = (
	"muestras = [\"felino\", \"error\", \"panko\"]\n"
	+ "indice = 0\n"
	+ "validos = 0\n\n"
	+ "[ Espacio 1 ]\n"
	+ "    muestra = muestras[indice]\n"
	+ "    [ Espacio 2 ]\n"
	+ "        [ Espacio 3 ]\n"
	+ "    [ Espacio 4 ]"
)

const RESPUESTA_CORRECTA: Array[String] = [
	"while indice < len(muestras):",
	"if muestra == \"felino\" or muestra == \"panko\":",
	"validos = validos + 1",
	"indice = indice + 1"
]

const BLOQUES_DISPONIBLES: Array[String] = [
	"while indice < len(muestras):",
	"while indice <= len(muestras):",
	"if muestra == \"felino\" or muestra == \"panko\":",
	"if muestra == \"felino\" and muestra == \"panko\":",
	"validos = validos + 1",
	"validos = 0",
	"indice = indice + 1",
	"indice = indice - 1"
]

const TIPOS_ERROR: Dictionary = {
	"while indice <= len(muestras):": "condicion_ciclo",
	"if muestra == \"felino\" and muestra == \"panko\":": "operador_logico",
	"validos = 0": "contador_validos",
	"indice = indice - 1": "avance_indice"
}

const MENSAJES_ERROR: Dictionary = {
	"condicion_ciclo": "Usar 'indice <= len(muestras)' intenta leer una posición inexistente al final de la lista.",
	"operador_logico": "Una misma muestra no puede valer \"felino\" Y \"panko\" al mismo tiempo; debes usar el operador 'or'.",
	"contador_validos": "'validos = 0' reinicia el conteo en vez de sumar 1.",
	"avance_indice": "Restar 1 al índice provoca un ciclo infinito.",
	"orden_incorrecto": "Revisa el orden de los bloques dentro del ciclo while."
}

const PISTAS: Dictionary = {
	0: "El ciclo while debe recorrer la lista mientras indice < len(muestras).",
	1: "Acepta muestras que sean \"felino\" O \"panko\" mediante el operador lógico or.",
	2: "Incrementa en 1 el contador de registros válidos (validos = validos + 1).",
	3: "Incrementa indice en 1 para avanzar al siguiente registro."
}


func validar_algoritmo_y_casos() -> Dictionary:
	for i in range(TOTAL_ESPACIOS):
		if bloques_colocados[i] != RESPUESTA_CORRECTA[i]:
			return {"correcto": false}

	var casos: Array = [
		{"muestras": ["felino", "error", "panko"], "esp": 2},
		{"muestras": ["ruido", "error", "desconocido"], "esp": 0}
	]
	for c in casos:
		var muestras: Array = c["muestras"]
		var indice: int = 0
		var validos: int = 0
		while indice < muestras.size():
			var muestra: String = str(muestras[indice])
			if muestra == "felino" or muestra == "panko":
				validos = validos + 1
			indice = indice + 1
		if validos != int(c["esp"]):
			return {"correcto": false}

	return {
		"correcto": true,
		"resumen_casos": "✓ Identifica 'felino' y 'panko' (2 válidos) | ✓ Descarta muestras con error"
	}
