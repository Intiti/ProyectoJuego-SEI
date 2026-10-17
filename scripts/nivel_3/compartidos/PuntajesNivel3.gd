
extends Node

# ==========================================
# MGTS - NIVEL 3
# SISTEMA GLOBAL DE PUNTUACIÓN
# ==========================================

signal puntos_actualizados(total: int)

# Puntos acumulados del Nivel 3
var puntos_totales: int = 0

# Ejercicios que ya fueron completados
var ejercicios_completados: Dictionary = {}


# ==========================================
# REGISTRAR UN EJERCICIO
# ==========================================

func registrar_ejercicio(codigo: String, puntos: int) -> void:

	# Evitar sumar puntos dos veces
	if ejercicios_completados.has(codigo):

		print(
			"El ejercicio ",
			codigo,
			" ya fue registrado."
		)

		return

	# Guardar el ejercicio completado
	ejercicios_completados[codigo] = puntos

	# Sumar puntos
	puntos_totales += puntos

	# Avisar que cambió la puntuación
	puntos_actualizados.emit(puntos_totales)

	print("==============================")
	print("EJERCICIO COMPLETADO: ", codigo)
	print("PUNTOS GANADOS: ", puntos)
	print("TOTAL NIVEL 3: ", puntos_totales)
	print("==============================")


# ==========================================
# CONSULTAR PUNTOS DE UN EJERCICIO
# ==========================================

func obtener_puntos(codigo: String) -> int:

	return ejercicios_completados.get(codigo, 0)


# ==========================================
# SABER SI UN EJERCICIO ESTÁ COMPLETADO
# ==========================================

func ejercicio_completado(codigo: String) -> bool:

	return ejercicios_completados.has(codigo)


# ==========================================
# REINICIAR PUNTOS DEL NIVEL 3
# ==========================================

func reiniciar_nivel() -> void:

	puntos_totales = 0

	ejercicios_completados.clear()

	puntos_actualizados.emit(puntos_totales)

	print("Puntuación del Nivel 3 reiniciada.")
