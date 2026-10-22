extends "res://scripts/nivel_3/compartidos/VentanaEjercicioBaseNivel3.gd"

# ==========================================
# MGTS - NIVEL 3 - EJERCICIO E3.8
# LOS PORTALES DE CONTENCIÓN
# ==========================================

const ID_EJERCICIO: String = "E3.8"
const TITULO_EJERCICIO: String = "E3.8 – Los portales de contención"
const OA_EJERCICIO: String = "OA2 / OA3: Ciclo while con operadores and, not y bifurcación if/else"
const DESCRIPCION_EJERCICIO: String = (
	"Clasifica cada portal como seguro únicamente cuando esté autorizado y NO presente anomalía; "
	+ "en cualquier otro caso clasifícalo como bloqueado."
)
const TOTAL_ESPACIOS: int = 4
const PUNTOS_POR_BLOQUE: int = 60

const PLANTILLA_CODIGO: String = (
	"portales = [\n"
	+ "    {\"autorizado\": True, \"anomalia\": False},\n"
	+ "    {\"autorizado\": True, \"anomalia\": False},\n"
	+ "    {\"autorizado\": True, \"anomalia\": True},\n"
	+ "    {\"autorizado\": False, \"anomalia\": False},\n"
	+ "    {\"autorizado\": False, \"anomalia\": True}\n"
	+ "]\n"
	+ "indice = 0\n"
	+ "seguros = 0\n"
	+ "bloqueados = 0\n\n"
	+ "[ Espacio 1 ]\n"
	+ "    portal = portales[indice]\n"
	+ "    [ Espacio 2 ]\n"
	+ "        [ Espacio 3 ]\n"
	+ "    [ Espacio 4 ]\n"
	+ "        bloqueados = bloqueados + 1\n"
	+ "    indice = indice + 1"
)

const RESPUESTA_CORRECTA: Array[String] = [
	"while indice < len(portales):",
	"if portal[\"autorizado\"] and not portal[\"anomalia\"]:",
	"seguros = seguros + 1",
	"else:"
]

const BLOQUES_DISPONIBLES: Array[String] = [
	"while indice < len(portales):",
	"while indice <= len(portales):",
	"if portal[\"autorizado\"] and not portal[\"anomalia\"]:",
	"if portal[\"autorizado\"] or portal[\"anomalia\"]:",
	"seguros = seguros + 1",
	"seguros = 0",
	"else:",
	"elif portal[\"anomalia\"]:"
]

const TIPOS_ERROR: Dictionary = {
	"while indice <= len(portales):": "condicion_ciclo",
	"if portal[\"autorizado\"] or portal[\"anomalia\"]:": "condicion_portal",
	"seguros = 0": "contador_seguros",
	"elif portal[\"anomalia\"]:": "estructura_else"
}

const MENSAJES_ERROR: Dictionary = {
	"condicion_ciclo": "'indice <= len(portales)' intenta acceder fuera de la lista.",
	"condicion_portal": "Un portal es seguro solo si está autorizado Y NO presenta anomalía (and not).",
	"contador_seguros": "'seguros = 0' reinicia el conteo en lugar de incrementarlo en 1.",
	"estructura_else": "Cualquier portal que no cumpla la condición segura debe ir por defecto a 'else:'.",
	"orden_incorrecto": "Verifica la posición del ciclo, la condición compuesta, el contador y el bloque else:."
}

const PISTAS: Dictionary = {
	0: "Controla el recorrido con while indice < len(portales):.",
	1: "Combina autorización y ausencia de anomalías usando 'and not'.",
	2: "Si el portal es seguro, incrementa seguros = seguros + 1.",
	3: "Usa 'else:' para cubrir todos los portales que deben bloquearse."
}


func validar_algoritmo_y_casos() -> Dictionary:
	for i in range(TOTAL_ESPACIOS):
		if bloques_colocados[i] != RESPUESTA_CORRECTA[i]:
			return {"correcto": false}

	var portales: Array = [
		{"autorizado": true, "anomalia": false},
		{"autorizado": true, "anomalia": false},
		{"autorizado": true, "anomalia": true},
		{"autorizado": false, "anomalia": false},
		{"autorizado": false, "anomalia": true}
	]
	var indice: int = 0
	var seguros: int = 0
	var bloqueados: int = 0
	while indice < portales.size():
		var portal: Dictionary = portales[indice]
		if bool(portal["autorizado"]) and not bool(portal["anomalia"]):
			seguros = seguros + 1
		else:
			bloqueados = bloqueados + 1
		indice = indice + 1

	if seguros != 2 or bloqueados != 3:
		return {"correcto": false}

	return {
		"correcto": true,
		"resumen_casos": "✓ 1 portal autorizado sin anomalía -> Seguro | ✓ 2 portales -> Bloqueados"
	}
