extends "res://scripts/nivel_3/compartidos/VentanaEjercicioBaseNivel3.gd"

# ==========================================
# MGTS - NIVEL 3 - EJERCICIO E3.7
# EL ESCUDO DE RADIACIÓN
# ==========================================

const ID_EJERCICIO: String = "E3.7"
const TITULO_EJERCICIO: String = "E3.7 – El escudo de radiación"
const OA_EJERCICIO: String = "OA2 / OA3: Ciclo while con caso límite (>= 50) y bandera booleana"
const DESCRIPCION_EJERCICIO: String = (
	"Analiza las lecturas de radiación de los sectores y activa el escudo (escudo_activo = True) "
	+ "si algún sector alcanza 50 o más unidades."
)
const TOTAL_ESPACIOS: int = 4
const PUNTOS_POR_BLOQUE: int = 60

const PLANTILLA_CODIGO: String = (
	"niveles = [20, 65, 30]\n"
	+ "indice = 0\n"
	+ "escudo_activo = False\n\n"
	+ "[ Espacio 1 ]\n"
	+ "    nivel = niveles[indice]\n"
	+ "    [ Espacio 2 ]\n"
	+ "        [ Espacio 3 ]\n"
	+ "    [ Espacio 4 ]"
)

const RESPUESTA_CORRECTA: Array[String] = [
	"while indice < len(niveles):",
	"if nivel >= 50:",
	"escudo_activo = True",
	"indice = indice + 1"
]

const BLOQUES_DISPONIBLES: Array[String] = [
	"while indice < len(niveles):",
	"while indice <= len(niveles):",
	"if nivel >= 50:",
	"if nivel < 50:",
	"escudo_activo = True",
	"escudo_activo = False",
	"indice = indice + 1",
	"indice = indice - 1"
]

const TIPOS_ERROR: Dictionary = {
	"while indice <= len(niveles):": "condicion_ciclo",
	"if nivel < 50:": "condicion_radiacion",
	"escudo_activo = False": "estado_escudo",
	"indice = indice - 1": "avance_indice"
}

const MENSAJES_ERROR: Dictionary = {
	"condicion_ciclo": "Usar '<=' intenta leer fuera de los límites de la lista niveles.",
	"condicion_radiacion": "El escudo debe activarse cuando la radiación es peligrosa (nivel >= 50).",
	"estado_escudo": "Debes cambiar la bandera escudo_activo a True al detectar peligro.",
	"avance_indice": "Decrementar indice impide avanzar por los sensores y causa un ciclo infinito.",
	"orden_incorrecto": "Revisa el orden del ciclo while, la condición de radiación y el cambio de bandera."
}

const PISTAS: Dictionary = {
	0: "Recorre los sensores mientras indice sea menor que len(niveles).",
	1: "Evalúa el umbral de radiación peligrosa con if nivel >= 50:.",
	2: "Activa la bandera de protección asignando escudo_activo = True.",
	3: "Avanza al siguiente sensor con indice = indice + 1."
}


func validar_algoritmo_y_casos() -> Dictionary:
	for i in range(TOTAL_ESPACIOS):
		if bloques_colocados[i] != RESPUESTA_CORRECTA[i]:
			return {"correcto": false}

	var casos: Array = [
		{"niveles": [20, 65, 30], "esp": true},
		{"niveles": [10, 49, 35], "esp": false},
		{"niveles": [50, 10, 15], "esp": true}
	]
	for c in casos:
		var niveles: Array = c["niveles"]
		var indice: int = 0
		var escudo_activo: bool = false
		while indice < niveles.size():
			var nivel: int = int(niveles[indice])
			if nivel >= 50:
				escudo_activo = true
			indice = indice + 1
		if escudo_activo != bool(c["esp"]):
			return {"correcto": false}

	return {
		"correcto": true,
		"resumen_casos": "✓ Activa escudo con radiación >= 50 | ✓ Mantiene apagado con valores menores"
	}
