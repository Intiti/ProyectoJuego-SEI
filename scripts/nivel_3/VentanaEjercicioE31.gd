extends "res://scripts/nivel_3/compartidos/VentanaEjercicioBaseNivel3.gd"

# ==========================================
# MGTS - NIVEL 3 - EJERCICIO E3.1
# LA PUERTA DEL LABORATORIO
# ==========================================

const ID_EJERCICIO: String = "E3.1"
const TITULO_EJERCICIO: String = "E3.1 – La puerta del laboratorio"
const OA_EJERCICIO: String = "OA2 / OA3: Ciclo while con operador and, contador y condicional if"
const DESCRIPCION_EJERCICIO: String = (
	"La entrada al complejo está bloqueada. Completa el algoritmo para pedir la clave mientras "
	+ "sea distinta de \"miau\" y los intentos sean menores que 3. Si aciertas la clave, abre la puerta."
)
const TOTAL_ESPACIOS: int = 4
const PUNTOS_POR_BLOQUE: int = 60

const PLANTILLA_CODIGO: String = (
	"clave = \"\"\n"
	+ "intentos = 0\n\n"
	+ "[ Espacio 1 ]\n"
	+ "    [ Espacio 2 ]\n"
	+ "    intentos = intentos + 1\n\n"
	+ "[ Espacio 3 ]\n"
	+ "    [ Espacio 4 ]\n"
	+ "else:\n"
	+ "    print(\"Acceso bloqueado\")"
)

const RESPUESTA_CORRECTA: Array[String] = [
	"while clave != \"miau\" and intentos < 3:",
	"clave = input(\"Clave: \")",
	"if clave == \"miau\":",
	"print(\"Puerta abierta\")"
]

const BLOQUES_DISPONIBLES: Array[String] = [
	"while clave != \"miau\" and intentos < 3:",
	"while clave == \"miau\" or intentos < 3:",
	"clave = input(\"Clave: \")",
	"clave = \"miau\"",
	"if clave == \"miau\":",
	"if intentos == 3:",
	"print(\"Puerta abierta\")",
	"intentos = intentos - 1"
]

const TIPOS_ERROR: Dictionary = {
	"while clave == \"miau\" or intentos < 3:": "condicion_ciclo",
	"clave = \"miau\"": "lectura_entrada",
	"if intentos == 3:": "condicion_final",
	"intentos = intentos - 1": "accion_correcta"
}

const MENSAJES_ERROR: Dictionary = {
	"condicion_ciclo": "Revisa la condición del ciclo: si usas '==' u 'or', el ciclo no se detendrá al acertar la clave o cuando se agoten los 3 intentos.",
	"lectura_entrada": "Asignar clave = \"miau\" fijo impide pedir la clave al usuario en cada intento mediante input().",
	"condicion_final": "En la verificación final debes comprobar si clave == \"miau\", no si intentos == 3.",
	"accion_correcta": "Cuando la clave es \"miau\", el sistema debe mostrar print(\"Puerta abierta\").",
	"orden_incorrecto": "Los bloques seleccionados son válidos, pero no están en el orden lógico del algoritmo."
}

const PISTAS: Dictionary = {
	0: "El ciclo while debe repetirse mientras la clave sea distinta de \"miau\" Y los intentos sean menores que 3.",
	1: "Dentro del ciclo debes pedir la contraseña al usuario usando clave = input(\"Clave: \").",
	2: "Al salir del ciclo, verifica si la clave ingresada fue \"miau\" con if clave == \"miau\":.",
	3: "Si la condición del if se cumple, imprime el mensaje print(\"Puerta abierta\")."
}


func validar_algoritmo_y_casos() -> Dictionary:
	for i in range(TOTAL_ESPACIOS):
		if bloques_colocados[i] != RESPUESTA_CORRECTA[i]:
			return {"correcto": false}

	var casos: Array = [
		{"entradas": ["error", "miau"], "esperado": "Puerta abierta", "intentos_esp": 2},
		{"entradas": ["111", "222", "333"], "esperado": "Acceso bloqueado", "intentos_esp": 3},
		{"entradas": ["miau"], "esperado": "Puerta abierta", "intentos_esp": 1}
	]

	for c in casos:
		var entradas: Array = c["entradas"]
		var clave: String = ""
		var intentos: int = 0
		var idx_in: int = 0
		while clave != "miau" and intentos < 3:
			clave = str(entradas[idx_in]) if idx_in < entradas.size() else ""
			idx_in += 1
			intentos = intentos + 1
		var salida: String = "Puerta abierta" if clave == "miau" else "Acceso bloqueado"
		if salida != c["esperado"] or intentos != int(c["intentos_esp"]):
			return {"correcto": false}

	return {
		"correcto": true,
		"resumen_casos": "✓ Clave 'miau' abre la puerta | ✓ 3 intentos fallidos bloquean el acceso"
	}
