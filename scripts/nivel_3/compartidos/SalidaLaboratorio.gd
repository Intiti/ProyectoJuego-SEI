
extends Area2D

# ==========================================
# NIVEL 3 - EJERCICIO E3.1
# SALIDA DEL LABORATORIO
# TRANSICIÓN HACIA E3.2
# ==========================================

# ==========================================
# CONFIGURACIÓN
# ==========================================

# La escena siguiente se selecciona
# desde el Inspector de Godot.
@export_file("*.tscn") var siguiente_escena: String = ""


# ==========================================
# REFERENCIAS
# ==========================================

@onready var jugador: CharacterBody2D = $"../Player"

@onready var puerta = get_node_or_null("../PuertaSeguridad")


# ==========================================
# VARIABLES
# ==========================================

var cambiando_escena: bool = false


# ==========================================
# INICIO
# ==========================================

func _ready() -> void:

	monitoring = true

	# Detectar cuando el jugador entra.
	body_entered.connect(_cuando_entra)

	print("E3.1: salida del laboratorio preparada.")


# ==========================================
# DETECTAR ENTRADA DEL JUGADOR
# ==========================================

func _cuando_entra(cuerpo: Node2D) -> void:

	if cuerpo != jugador:
		return

	intentar_salir()


# ==========================================
# COMPROBAR SI PUEDE AVANZAR
# ==========================================

func intentar_salir() -> void:

	# Evitar cambiar de escena varias veces.
	if cambiando_escena:
		return

	# Comprobar que existe la puerta.
	if puerta == null:

		push_warning(
			"E3.1: no se encontró PuertaSeguridad."
		)
		return

	# La puerta debe estar desbloqueada.
	if not puerta.desbloqueada:

		print(
			"E3.1: la puerta está bloqueada. " +
			"Completa primero el ejercicio."
		)
		return

	# Comprobar que se configuró el destino.
	if siguiente_escena.is_empty():

		push_warning(
			"E3.1: falta configurar Siguiente Escena."
		)
		return

	# Comprobar que existe la escena.
	if not ResourceLoader.exists(siguiente_escena):

		push_warning(
			"E3.1: no existe la escena: " +
			siguiente_escena
		)
		return

	# Comenzar transición.
	cambiando_escena = true

	print("E3.1: entrando a E3.2...")
	print("Destino: ", siguiente_escena)

	get_tree().call_deferred(
		"change_scene_to_file",
		siguiente_escena
	)


# ==========================================
# COMPROBAR SI EL JUGADOR YA ESTÁ EN EL ÁREA
# ==========================================

func _physics_process(_delta: float) -> void:

	if cambiando_escena:
		return

	if puerta == null:
		return

	if not puerta.desbloqueada:
		return

	# Si la puerta se desbloqueó mientras
	# el jugador estaba dentro de la salida,
	# permitir el cambio de escena.
	for cuerpo in get_overlapping_bodies():

		if cuerpo == jugador:

			intentar_salir()
			return
