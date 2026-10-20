extends "res://scripts/nivel_3/compartidos/VentanaEjercicioBaseNivel3.gd"

# ==========================================
# MGTS - NIVEL 3 - EJERCICIO E3.5
# CONDUCTOS DE VENTILACIÓN
# ==========================================

const ID_EJERCICIO: String = "E3.5"
const TITULO_EJERCICIO: String = "E3.5 – Conductos de ventilación"
const OA_EJERCICIO: String = "OA2 / OA3: Ciclo while con contador de activaciones y condicional if"
const DESCRIPCION_EJERCICIO: String = (
	"Recorre la lista de ventiladores del conducto, cuenta cuántos se encuentran en estado "
	+ "\"apagado\" para activarlos y avanza el índice en cada iteración."
)
const TOTAL_ESPACIOS: int = 4
const PUNTOS_POR_BLOQUE: int = 60

const PLANTILLA_CODIGO: String = (
	"ventiladores = [\"apagado\", \"activo\", \"apagado\"]\n"
	+ "indice = 0\n"
	+ "activados = 0\n\n"
	+ "[ Espacio 1 ]\n"
	+ "    estado = ventiladores[indice]\n"
	+ "    [ Espacio 2 ]\n"
	+ "        [ Espacio 3 ]\n"
	+ "    [ Espacio 4 ]"
)

const RESPUESTA_CORRECTA: Array[String] = [
	"while indice < len(ventiladores):",
	"if estado == \"apagado\":",
	"activados = activados + 1",
	"indice = indice + 1"
]

const BLOQUES_DISPONIBLES: Array[String] = [
	"while indice < len(ventiladores):",
	"while indice <= len(ventiladores):",
	"if estado == \"apagado\":",
	"if estado == \"activo\":",
	"activados = activados + 1",
	"activados = 0",
	"indice = indice + 1",
	"indice = indice - 1"
]

const TIPOS_ERROR: Dictionary = {
	"while indice <= len(ventiladores):": "condicion_ciclo",
	"if estado == \"activo\":": "condicion_interna",
	"activados = 0": "contador_activados",
	"indice = indice - 1": "avance_indice"
}

const MENSAJES_ERROR: Dictionary = {
	"condicion_ciclo": "Usar '<=' intenta acceder a un índice fuera de rango al final de la lista.",
	"condicion_interna": "Solo debes contar y activar los ventiladores cuyo estado sea \"apagado\".",
	"contador_activados": "Asignar activados = 0 reinicia la cuenta en lugar de sumar 1.",
	"avance_indice": "Restar 1 al índice impide avanzar por la lista y genera un ciclo infinito.",
	"orden_incorrecto": "Verifica la posición del ciclo while, el condicional if y el avance de indice."
}

const PISTAS: Dictionary = {
	0: "El ciclo while debe ejecutarse mientras el índice sea estrictamente menor que len(ventiladores).",
	1: "Comprueba si el ventilador actual requiere encenderse con if estado == \"apagado\":.",
	2: "Incrementa en 1 el contador de ventiladores encendidos (activados = activados + 1).",
	3: "Al final de cada iteración avanza al siguiente elemento con indice = indice + 1."
}


func validar_algoritmo_y_casos() -> Dictionary:
	for i in range(TOTAL_ESPACIOS):
		if bloques_colocados[i] != RESPUESTA_CORRECTA[i]:
			return {"correcto": false}

	var casos: Array = [
		{"lista": ["apagado", "activo", "apagado"], "esp": 2},
		{"lista": ["activo", "activo", "activo"], "esp": 0},
		{"lista": ["apagado", "apagado", "apagado"], "esp": 3}
	]
	for c in casos:
		var ventiladores: Array = c["lista"]
		var indice: int = 0
		var activados: int = 0
		while indice < ventiladores.size():
			var estado: String = str(ventiladores[indice])
			if estado == "apagado":
				activados = activados + 1
			indice = indice + 1
		if activados != int(c["esp"]) or indice != ventiladores.size():
			return {"correcto": false}

	return {
		"correcto": true,
		"resumen_casos": "✓ Detecta y activa 2 ventiladores apagados | ✓ Recorrido completo sin desborde"
	}
