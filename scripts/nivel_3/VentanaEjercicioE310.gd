extends "res://scripts/nivel_3/compartidos/VentanaEjercicioBaseNivel3.gd"

# ==========================================
# MGTS - NIVEL 3 - EJERCICIO E3.10
# EL PROTOCOLO DE RESCATE (CÁMARA DE RESCATE)
# ==========================================

const ID_EJERCICIO: String = "E3.10"
const TITULO_EJERCICIO: String = "E3.10 – El protocolo de rescate"
const OA_EJERCICIO: String = "OA2 / OA3: Ciclo while con bandera (not), contador (< 3) y condición or"
const DESCRIPCION_EJERCICIO: String = (
	"Rastrea la señal de Panko mientras aún no haya sido rescatado y los intentos fallidos sean "
	+ "menores que 3. Si la señal es \"gatito\" o \"maullido\", cambia rescatado a True."
)
const TOTAL_ESPACIOS: int = 4
const PUNTOS_POR_BLOQUE: int = 60

const PLANTILLA_CODIGO: String = (
	"rescatado = False\n"
	+ "intentos = 0\n\n"
	+ "[ Espacio 1 ]\n"
	+ "    [ Espacio 2 ]\n"
	+ "    [ Espacio 3 ]\n"
	+ "        [ Espacio 4 ]\n"
	+ "    else:\n"
	+ "        intentos = intentos + 1"
)

const RESPUESTA_CORRECTA: Array[String] = [
	"while not rescatado and intentos < 3:",
	"senal = input(\"Señal: \")",
	"if senal == \"gatito\" or senal == \"maullido\":",
	"rescatado = True"
]

const BLOQUES_DISPONIBLES: Array[String] = [
	"while not rescatado and intentos < 3:",
	"while rescatado or intentos < 3:",
	"senal = input(\"Señal: \")",
	"senal = \"gatito\"",
	"if senal == \"gatito\" or senal == \"maullido\":",
	"if senal == \"gatito\" and senal == \"maullido\":",
	"rescatado = True",
	"rescatado = False"
]

const TIPOS_ERROR: Dictionary = {
	"while rescatado or intentos < 3:": "condicion_ciclo",
	"senal = \"gatito\"": "lectura_entrada",
	"if senal == \"gatito\" and senal == \"maullido\":": "operador_logico",
	"rescatado = False": "bandera_rescate"
}

const MENSAJES_ERROR: Dictionary = {
	"condicion_ciclo": "Debes repetir la búsqueda mientras NO se haya rescatado (not rescatado) Y queden intentos (< 3).",
	"lectura_entrada": "Debes leer la señal del escáner con senal = input(\"Señal: \"), no fijar un texto constante.",
	"operador_logico": "Una señal no puede ser \"gatito\" Y \"maullido\" al mismo tiempo; usa el operador 'or'.",
	"bandera_rescate": "Al detectar una señal válida, debes cambiar rescatado = True para finalizar la búsqueda.",
	"orden_incorrecto": "Verifica la posición del ciclo while, la lectura input(), el condicional if y la bandera rescatado = True."
}

const PISTAS: Dictionary = {
	0: "El ciclo while continúa mientras 'not rescatado' y 'intentos < 3'.",
	1: "Lee la señal recibida en la Cámara de Rescate con senal = input(\"Señal: \").",
	2: "Acepta las señales \"gatito\" O \"maullido\" usando el operador or.",
	3: "Activa la bandera rescatado = True al encontrar una señal válida."
}


func validar_algoritmo_y_casos() -> Dictionary:
	for i in range(TOTAL_ESPACIOS):
		if bloques_colocados[i] != RESPUESTA_CORRECTA[i]:
			return {"correcto": false}

	var casos: Array = [
		{"senales": ["ruido", "maullido"], "res_esp": true, "int_esp": 1},
		{"senales": ["gatito"], "res_esp": true, "int_esp": 0},
		{"senales": ["eco", "viento", "estatica"], "res_esp": false, "int_esp": 3}
	]
	for c in casos:
		var senales: Array = c["senales"]
		var rescatado: bool = false
		var intentos: int = 0
		var idx: int = 0
		while not rescatado and intentos < 3:
			var senal: String = str(senales[idx]) if idx < senales.size() else ""
			idx += 1
			if senal == "gatito" or senal == "maullido":
				rescatado = true
			else:
				intentos = intentos + 1
		if rescatado != bool(c["res_esp"]) or intentos != int(c["int_esp"]):
			return {"correcto": false}

	return {
		"correcto": true,
		"resumen_casos": "✓ Señal 'maullido' o 'gatito' activa rescatado = True | ✓ Límite de 3 intentos"
	}
