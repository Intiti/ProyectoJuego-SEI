
extends StaticBody2D

# ==========================================
# NIVEL 3 - EJERCICIO E3.1
# PUERTA DE SEGURIDAD
# ==========================================

# ==========================================
# REFERENCIAS
# ==========================================

@onready var colision: CollisionShape2D = $CollisionShape2D


# ==========================================
# VARIABLES
# ==========================================

var desbloqueada: bool = false


# ==========================================
# INICIO
# ==========================================

func _ready() -> void:

	# La puerta comienza bloqueada.
	desbloqueada = false

	# Activar la colisión.
	colision.set_deferred("disabled", false)

	print("E3.1: puerta de seguridad bloqueada.")


# ==========================================
# DESBLOQUEAR PUERTA
# ==========================================

func desbloquear_puerta() -> void:

	if desbloqueada:
		return

	desbloqueada = true

	# Desactivar la colisión para permitir el paso.
	colision.set_deferred("disabled", true)

	print("================================")
	print("¡PUERTA DE SEGURIDAD DESBLOQUEADA!")
	print("Ya puedes avanzar hacia E3.2.")
	print("================================")


# ==========================================
# COMPROBAR ESTADO
# ==========================================

func esta_desbloqueada() -> bool:

	return desbloqueada


# ==========================================
# BLOQUEAR PUERTA
# ==========================================

func bloquear_puerta() -> void:

	desbloqueada = false

	colision.set_deferred("disabled", false)

	print("E3.1: puerta de seguridad bloqueada.")
