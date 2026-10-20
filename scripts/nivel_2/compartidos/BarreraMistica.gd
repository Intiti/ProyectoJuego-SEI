extends StaticBody2D

# ==========================================
# MGTS - NIVEL 2: BARRERA MÍSTICA DE RAMAS
# ==========================================

@onready var colision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var luz: PointLight2D = get_node_or_null("PointLight2D")

var desbloqueada: bool = false

func _ready() -> void:
	desbloqueada = false
	if colision:
		colision.set_deferred("disabled", false)
	_iniciar_pulso_mistico()

func _iniciar_pulso_mistico() -> void:
	if sprite:
		var tween = create_tween().set_loops()
		tween.tween_property(sprite, "modulate:a", 0.7, 1.4)
		tween.tween_property(sprite, "modulate:a", 1.0, 1.4)

func desbloquear_barrera() -> void:
	if desbloqueada:
		return
	desbloqueada = true
	
	if colision:
		colision.set_deferred("disabled", true)
	
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color(1.5, 2.0, 1.8, 0.0), 1.2)
		tween.tween_callback(func(): sprite.visible = false)
	
	print("✨ ¡BARRERA MÍSTICA DISUELTA! El sendero ancestral está abierto.")

func esta_desbloqueada() -> bool:
	return desbloqueada
