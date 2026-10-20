extends Node

# ==========================================
# MGTS - NIVEL 2: EL BOSQUE PROFUNDO Y ANCESTRAL
# SISTEMA DE PUNTUACIÓN, RACHA E INSIGNIAS
# ==========================================

signal puntos_actualizados(total: int)
signal insignia_desbloqueada(nombre: String)

# Puntos acumulados en Nivel 2
var puntos_totales: int = 0

# Diccionario de ejercicios resueltos: {"E2.1": puntos, ...}
var ejercicios_completados: Dictionary = {}

# Racha de aciertos en el nivel
var racha_actual: int = 0

# Insignias desbloqueadas en Nivel 2
var insignias: Array[String] = []

# ID / Índice del examen activo para Nivel 2 (0: EX·A, 1: EX·B, 2: EX·C)
var examen_activo_idx: int = -1

const NOMBRE_INSIGNIA: String = "Cazador de Ciclos"
const PUNTOS_BASE_BLOQUE: int = 40
const BONUS_RACHA_NIVEL2: int = 10
const TOTAL_VARIANTES_EXAMEN: int = 3

func _ready() -> void:
	print("PuntajesNivel2: Sistema de puntuación del Bosque Profundo iniciado.")
	seleccionar_examen_aleatorio()

## Selecciona una variante aleatoria del examen (0, 1 o 2), opcionalmente excluyendo una variante previa
func seleccionar_examen_aleatorio(excluir_idx: int = -1) -> int:
	var candidatos: Array[int] = []
	for i in range(TOTAL_VARIANTES_EXAMEN):
		if i != excluir_idx:
			candidatos.append(i)
	candidatos.shuffle()
	examen_activo_idx = candidatos[0]
	print("PuntajesNivel2: Examen activo asignado dinámicamente -> Índice %d (excluido: %d)" % [examen_activo_idx, excluir_idx])
	return examen_activo_idx

## Registra la finalización de un ejercicio calculando puntos según fórmula oficial del PDF
func registrar_ejercicio(codigo: String, bloques_completados: int, errores: int) -> int:
	if ejercicios_completados.has(codigo):
		print("PuntajesNivel2: El ejercicio %s ya estaba completado." % codigo)
		return ejercicios_completados[codigo]
	
	# Fórmula oficial PDF (Pág. 10):
	# Base = bloques * 40
	var base: int = bloques_completados * PUNTOS_BASE_BLOQUE
	var puntos: int = base
	
	if errores == 2:
		puntos = int(base * 0.75) # -25%
	elif errores >= 3:
		puntos = int(base * 0.50) # -50%
	
	# Manejo de racha global (bonus a partir del 3er acierto consecutivo)
	if errores == 0:
		racha_actual += 1
		if racha_actual >= 3:
			puntos += BONUS_RACHA_NIVEL2
	else:
		racha_actual = 0
	
	ejercicios_completados[codigo] = puntos
	puntos_totales += puntos
	
	# Sincronizar con GameData global si existe
	if GameData:
		GameData.gatopuntos += puntos
		if "rachaGlobal" in GameData:
			if errores == 0:
				GameData.rachaGlobal += 1
			else:
				GameData.rachaGlobal = 0
	
	puntos_actualizados.emit(puntos_totales)
	
	# Comprobar insignia "Cazador de Ciclos" (>= 4 de 5 ejercicios resueltos)
	_verificar_insignia()
	
	print("========================================")
	print("NIVEL 2 - RETO COMPLETADO: ", codigo)
	print("Puntos obtenidos: ", puntos, " (Errores: ", errores, ", Racha: ", racha_actual, ")")
	print("Total Nivel 2: ", puntos_totales)
	print("========================================")
	
	return puntos

func _verificar_insignia() -> void:
	if not insignias.has(NOMBRE_INSIGNIA) and ejercicios_completados.size() >= 4:
		insignias.append(NOMBRE_INSIGNIA)
		insignia_desbloqueada.emit(NOMBRE_INSIGNIA)
		print("🏆 ¡INSIGNIA DESBLOQUEADA: %s!" % NOMBRE_INSIGNIA)

func obtener_puntos(codigo: String) -> int:
	return ejercicios_completados.get(codigo, 0)

func ejercicio_completado(codigo: String) -> bool:
	return ejercicios_completados.has(codigo)

func tiene_insignia(nombre: String) -> bool:
	return insignias.has(nombre)

func reiniciar_nivel() -> void:
	puntos_totales = 0
	racha_actual = 0
	ejercicios_completados.clear()
	insignias.clear()
	puntos_actualizados.emit(puntos_totales)
	print("PuntajesNivel2: Nivel 2 reiniciado.")
