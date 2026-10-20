extends "res://scripts/nivel_3/compartidos/VentanaEjercicioBaseNivel3.gd"

# ==========================================
# MGTS - NIVEL 3 - EJERCICIO E3.2
# EL NÚCLEO DE ENERGÍA
# ==========================================

const ID_EJERCICIO: String = "E3.2"
const TITULO_EJERCICIO: String = "E3.2 – El núcleo de energía"
const OA_EJERCICIO: String = "OA2 / OA3: Ciclo while con acumulador, contador y filtro condicional"
const DESCRIPCION_EJERCICIO: String = (
	"Recarga el núcleo energético hasta reunir al menos 10 unidades en un máximo de 4 lecturas. "
	+ "Solo debes sumar al acumulador las lecturas mayores que cero."
)
const TOTAL_ESPACIOS: int = 4
const PUNTOS_POR_BLOQUE: int = 60

const PLANTILLA_CODIGO: String = (
	"energia = 0\n"
	+ "lecturas = 0\n\n"
	+ "[ Espacio 1 ]\n"
	+ "    [ Espacio 2 ]\n"
	+ "    [ Espacio 3 ]\n"
	+ "        [ Espacio 4 ]\n"
	+ "    lecturas = lecturas + 1"
)

const RESPUESTA_CORRECTA: Array[String] = [
	"while energia < 10 and lecturas < 4:",
	"dato = int(input(\"Energía: \"))",
	"if dato > 0:",
	"energia = energia + dato"
]

const BLOQUES_DISPONIBLES: Array[String] = [
	"while energia < 10 and lecturas < 4:",
	"while energia >= 10 or lecturas < 4:",
	"dato = int(input(\"Energía: \"))",
	"dato = 10",
	"if dato > 0:",
	"if dato < 0:",
	"energia = energia + dato",
	"energia = dato"
]

const TIPOS_ERROR: Dictionary = {
	"while energia >= 10 or lecturas < 4:": "condicion_ciclo",
	"dato = 10": "lectura_entrada",
	"if dato < 0:": "condicion_interna",
	"energia = dato": "acumulador"
}

const MENSAJES_ERROR: Dictionary = {
	"condicion_ciclo": "El núcleo debe seguir cargando mientras energia < 10 Y lecturas < 4.",
	"lectura_entrada": "Debes leer cada valor con int(input(\"Energía: \")), no asignar un número fijo.",
	"condicion_interna": "Solo las lecturas positivas (dato > 0) deben sumarse al núcleo.",
	"acumulador": "'energia = dato' reemplaza el valor anterior; usa 'energia = energia + dato' para acumular.",
	"orden_incorrecto": "Revisa el orden del ciclo while, la lectura input(), el condicional if y el acumulador."
}

const PISTAS: Dictionary = {
	0: "El ciclo while continúa mientras la energía sea menor que 10 y las lecturas sean menores que 4.",
	1: "Solicita el valor numérico de energía usando dato = int(input(\"Energía: \")).",
	2: "Filtra únicamente las lecturas positivas comprobando if dato > 0:.",
	3: "Acumula el valor positivo sumándolo a la reserva actual: energia = energia + dato."
}


func validar_algoritmo_y_casos() -> Dictionary:
	for i in range(TOTAL_ESPACIOS):
		if bloques_colocados[i] != RESPUESTA_CORRECTA[i]:
			return {"correcto": false}

	var casos: Array = [
		{"datos": [4, -3, 6, 5], "energia_esp": 10, "lecturas_esp": 3},
		{"datos": [2, 3, -1, 2], "energia_esp": 7, "lecturas_esp": 4}
	]
	for c in casos:
		var datos: Array = c["datos"]
		var energia: int = 0
		var lecturas: int = 0
		while energia < 10 and lecturas < 4:
			var dato: int = int(datos[lecturas])
			if dato > 0:
				energia = energia + dato
			lecturas = lecturas + 1
		if energia != int(c["energia_esp"]) or lecturas != int(c["lecturas_esp"]):
			return {"correcto": false}

	return {
		"correcto": true,
		"resumen_casos": "✓ Acumula lecturas positivas e ignora negativas | ✓ Respeta el límite de 4 lecturas"
	}
