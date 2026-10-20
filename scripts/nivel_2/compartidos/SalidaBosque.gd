extends Area2D

# ==========================================
# MGTS - NIVEL 2: SALIDA HACIA EL SIGUIENTE CLARO
# ==========================================

const FaderScript = preload("res://scripts/common/ui/sceneFader.gd")

@export_file("*.tscn") var siguiente_escena: String = ""

@onready var barrera = get_node_or_null("../BarreraMistica")

var cambiando_escena: bool = false

func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body_entered)

func _on_body_entered(cuerpo: Node2D) -> void:
	if not cuerpo.is_in_group("player"):
		return
	intentar_avanzar()

func intentar_avanzar() -> void:
	if cambiando_escena:
		return
	
	if barrera != null and not barrera.desbloqueada:
		print("SalidaBosque: El paso está custodiado por la barrera mística. Resuelve el reto primero.")
		return
	
	if siguiente_escena.is_empty():
		push_warning("SalidaBosque: Falta configurar la siguiente escena.")
		return
	
	cambiando_escena = true
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)
	
	# Transición suave de escena
	if ResourceLoader.exists(siguiente_escena):
		print("SalidaBosque: Avanzando hacia %s..." % siguiente_escena)
		FaderScript.fadeOutAndChange(get_tree().current_scene, siguiente_escena, 0.8)
	else:
		push_error("SalidaBosque: No existe la escena " + siguiente_escena)
