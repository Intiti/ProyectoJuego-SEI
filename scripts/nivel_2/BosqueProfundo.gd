extends Control

# ==========================================
# MGTS - NIVEL 2: EL BOSQUE PROFUNDO Y ANCESTRAL
# ENTRADA / HUB DEL NIVEL 2
# ==========================================

const FaderScript = preload("res://scripts/common/ui/sceneFader.gd")

func _ready() -> void:
	# Cargar directamente la primera escena de exploración del Nivel 2
	call_deferred("_iniciar_nivel")

func _iniciar_nivel() -> void:
	get_tree().change_scene_to_file("res://scenes/nivel_2/1SenderoDeLasHuellas.tscn")
