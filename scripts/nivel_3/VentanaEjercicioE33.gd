extends "res://scripts/nivel_3/compartidos/VentanaEjercicioBaseNivel3.gd"

# ==========================================
# MGTS - NIVEL 3 - EJERCICIO E3.3
# LOS CONDUCTOS DE EXPLORACIÓN (PASOS DEL DRON)
# ==========================================

const ID_EJERCICIO: String = "E3.3"
const TITULO_EJERCICIO: String = "E3.3 – Los pasos del dron"
const OA_EJERCICIO: String = "OA2 / OA3: Ciclo while con doble condición de parada y contadores"
const DESCRIPCION_EJERCICIO: String = (
	"Programa el dron explorador para avanzar hasta 5 pasos por el conducto y detenerse antes "
	+ "si detecta 2 obstáculos (\"roca\")."
)
const TOTAL_ESPACIOS: int = 4
const PUNTOS_POR_BLOQUE: int = 60

const PLANTILLA_CODIGO: String = (
	"pasos = 0\n"
	+ "obstaculos = 0\n\n"
	+ "[ Espacio 1 ]\n"
	+ "    [ Espacio 2 ]\n"
	+ "    [ Espacio 3 ]\n"
	+ "        [ Espacio 4 ]\n"
	+ "    pasos = pasos + 1"
)

const RESPUESTA_CORRECTA: Array[String] = [
	"while pasos < 5 and obstaculos < 2:",
	"camino = input(\"Camino: \")",
	"if camino == \"roca\":",
	"obstaculos = obstaculos + 1"
]

const BLOQUES_DISPONIBLES: Array[String] = [
	"while pasos < 5 and obstaculos < 2:",
	"while pasos <= 5 or obstaculos < 2:",
	"camino = input(\"Camino: \")",
	"camino = \"roca\"",
	"if camino == \"roca\":",
	"if camino != \"roca\":",
	"obstaculos = obstaculos + 1",
	"pasos = pasos - 1"
]

const TIPOS_ERROR: Dictionary = {
	"while pasos <= 5 or obstaculos < 2:": "condicion_ciclo",
	"camino = \"roca\"": "lectura_entrada",
	"if camino != \"roca\":": "condicion_interna",
	"pasos = pasos - 1": "actualizacion_contador"
}

const MENSAJES_ERROR: Dictionary = {
	"condicion_ciclo": "Usar '<=' u 'or' hace que el dron dé más de 5 pasos o no se detenga al encontrar 2 rocas.",
	"lectura_entrada": "Debes consultar el sensor en cada paso con camino = input(\"Camino: \").",
	"condicion_interna": "El contador de obstáculos solo debe aumentar cuando camino == \"roca\".",
	"actualizacion_contador": "Cuando se detecta una roca debes incrementar obstaculos = obstaculos + 1.",
	"orden_incorrecto": "Revisa el orden de las instrucciones dentro del ciclo while."
}

const PISTAS: Dictionary = {
	0: "El dron avanza mientras pasos < 5 Y obstaculos < 2.",
	1: "En cada paso, lee el estado del conducto con camino = input(\"Camino: \").",
	2: "Verifica si encontró un obstáculo comprobando if camino == \"roca\":.",
	3: "Si hay una roca, incrementa el contador con obstaculos = obstaculos + 1."
}


func validar_algoritmo_y_casos() -> Dictionary:
	for i in range(TOTAL_ESPACIOS):
		if bloques_colocados[i] != RESPUESTA_CORRECTA[i]:
			return {"correcto": false}

	var casos: Array = [
		{"caminos": ["libre", "roca", "libre", "roca", "libre"], "pasos_esp": 4, "obs_esp": 2},
		{"caminos": ["libre", "libre", "roca", "libre", "libre"], "pasos_esp": 5, "obs_esp": 1}
	]
	for c in casos:
		var caminos: Array = c["caminos"]
		var pasos: int = 0
		var obstaculos: int = 0
		while pasos < 5 and obstaculos < 2:
			var camino: String = str(caminos[pasos])
			if camino == "roca":
				obstaculos = obstaculos + 1
			pasos = pasos + 1
		if pasos != int(c["pasos_esp"]) or obstaculos != int(c["obs_esp"]):
			return {"correcto": false}

	return {
		"correcto": true,
		"resumen_casos": "✓ Parada preventiva al detectar 2 rocas | ✓ Recorrido completo de 5 pasos"
	}
