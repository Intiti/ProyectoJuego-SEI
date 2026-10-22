extends "res://scripts/nivel_3/compartidos/VentanaEjercicioBaseNivel3.gd"

# ==========================================
# MGTS - NIVEL 3 - EJERCICIO E3.9
# LAS SEÑALES DEL SERVIDOR CENTRAL
# ==========================================

const ID_EJERCICIO: String = "E3.9"
const TITULO_EJERCICIO: String = "E3.9 – Las señales del servidor central"
const OA_EJERCICIO: String = "OA2 / OA3: Ciclo while con operador or y clasificación if/else"
const DESCRIPCION_EJERCICIO: String = (
	"Analiza las señales del Servidor Central: cuenta como dañadas aquellas que sean "
	+ "\"perdida\" o \"latencia\", y cuenta el resto como señales estables."
)
const TOTAL_ESPACIOS: int = 4
const PUNTOS_POR_BLOQUE: int = 60

const PLANTILLA_CODIGO: String = (
	"senales = [\"ok\", \"perdida\", \"ok\", \"latencia\", \"ok\"]\n"
	+ "indice = 0\n"
	+ "danadas = 0\n"
	+ "estables = 0\n\n"
	+ "[ Espacio 1 ]\n"
	+ "    senal = senales[indice]\n"
	+ "    [ Espacio 2 ]\n"
	+ "        [ Espacio 3 ]\n"
	+ "    [ Espacio 4 ]\n"
	+ "        estables = estables + 1\n"
	+ "    indice = indice + 1"
)

const RESPUESTA_CORRECTA: Array[String] = [
	"while indice < len(senales):",
	"if senal == \"perdida\" or senal == \"latencia\":",
	"danadas = danadas + 1",
	"else:"
]

const BLOQUES_DISPONIBLES: Array[String] = [
	"while indice < len(senales):",
	"while indice <= len(senales):",
	"if senal == \"perdida\" or senal == \"latencia\":",
	"if senal == \"perdida\" and senal == \"latencia\":",
	"danadas = danadas + 1",
	"danadas = 0",
	"else:",
	"elif senal == \"error\":"
]

const TIPOS_ERROR: Dictionary = {
	"while indice <= len(senales):": "condicion_ciclo",
	"if senal == \"perdida\" and senal == \"latencia\":": "condicion_senal",
	"danadas = 0": "contador_danadas",
	"elif senal == \"error\":": "estructura_else"
}

const MENSAJES_ERROR: Dictionary = {
	"condicion_ciclo": "'indice <= len(senales)' excede el tamaño de la lista de señales.",
	"condicion_senal": "Una señal individual no puede ser \"perdida\" Y \"latencia\" a la vez; usa el operador 'or'.",
	"contador_danadas": "'danadas = 0' reinicia el conteo en lugar de sumar 1.",
	"estructura_else": "Usa 'else:' para que las señales \"ok\" se cuenten automáticamente como estables.",
	"orden_incorrecto": "Revisa la posición del ciclo, la condición con or, el contador y el bloque else:."
}

const PISTAS: Dictionary = {
	0: "El ciclo while debe ejecutarse mientras indice < len(senales).",
	1: "Detecta señales dañadas comprobando si senal es \"perdida\" O \"latencia\".",
	2: "Incrementa el contador de señales dañadas en 1 (danadas = danadas + 1).",
	3: "Cierra la bifurcación con 'else:' para contabilizar las señales estables."
}


func validar_algoritmo_y_casos() -> Dictionary:
	for i in range(TOTAL_ESPACIOS):
		if bloques_colocados[i] != RESPUESTA_CORRECTA[i]:
			return {"correcto": false}

	var senales: Array = ["ok", "perdida", "ok", "latencia", "ok"]
	var indice: int = 0
	var danadas: int = 0
	var estables: int = 0
	while indice < senales.size():
		var senal: String = str(senales[indice])
		if senal == "perdida" or senal == "latencia":
			danadas = danadas + 1
		else:
			estables = estables + 1
		indice = indice + 1

	if danadas != 2 or estables != 3:
		return {"correcto": false}

	return {
		"correcto": true,
		"resumen_casos": "✓ 2 señales dañadas ('perdida', 'latencia') | ✓ 2 señales estables ('ok')"
	}
