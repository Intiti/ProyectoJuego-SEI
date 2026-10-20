extends StaticBody2D

# ==========================================
# MGTS - NIVEL 3
# PUERTA DE SEGURIDAD REUTILIZABLE
# Compatible con CollisionShape2D directo o BloqueoPuerta/CollisionShape2D
# ==========================================

@onready var puerta_cerrada: Node2D = get_node_or_null("PuertaCerrada") as Node2D
@onready var puerta_abierta: Node2D = get_node_or_null("PuertaAbierta") as Node2D
@onready var bloqueo: CollisionShape2D = _obtener_colision_bloqueo()
@onready var salida: Node = get_node_or_null("../SalidaLaboratorio")

var desbloqueada: bool = false
var indicador_visual: Node2D = null
var etiqueta_estado: Label = null


func _obtener_colision_bloqueo() -> CollisionShape2D:
	var col: CollisionShape2D = get_node_or_null("BloqueoPuerta/CollisionShape2D") as CollisionShape2D
	if col == null:
		col = get_node_or_null("CollisionShape2D") as CollisionShape2D
	return col


func _ready() -> void:
	_crear_indicador_visual_si_falta()
	bloquear_puerta()


func _crear_indicador_visual_si_falta() -> void:
	if puerta_cerrada != null or puerta_abierta != null:
		return
	if bloqueo == null:
		return

	indicador_visual = Node2D.new()
	indicador_visual.name = "IndicadorPuerta"
	indicador_visual.position = bloqueo.position
	add_child(indicador_visual)

	etiqueta_estado = Label.new()
	etiqueta_estado.name = "EstadoPuertaLabel"
	etiqueta_estado.position = Vector2(-75, -140)
	etiqueta_estado.custom_minimum_size = Vector2(150, 32)
	etiqueta_estado.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta_estado.add_theme_font_size_override("font_size", 15)
	etiqueta_estado.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	etiqueta_estado.add_theme_constant_override("outline_size", 4)
	indicador_visual.add_child(etiqueta_estado)


func bloquear_puerta() -> void:
	desbloqueada = false

	if puerta_cerrada != null:
		puerta_cerrada.show()
	if puerta_abierta != null:
		puerta_abierta.hide()

	if bloqueo != null:
		bloqueo.set_deferred("disabled", false)
	else:
		push_warning("PuertaSeguridad: no se encontró CollisionShape2D de bloqueo.")

	if etiqueta_estado != null:
		etiqueta_estado.text = "🔒 PUERTA BLOQUEADA"
		etiqueta_estado.add_theme_color_override("font_color", Color("#FF6B6B"))

	if salida != null and salida.has_method("desactivar_salida"):
		salida.call("desactivar_salida")

	print("Puerta de seguridad bloqueada.")


func desbloquear_puerta() -> void:
	if desbloqueada:
		return

	desbloqueada = true

	var dj: Node = get_node_or_null("/root/DJManager")
	if dj != null and dj.has_method("play_sfx"):
		dj.call("play_sfx", "puerta")

	if puerta_cerrada != null:
		puerta_cerrada.hide()

	if puerta_abierta != null:
		puerta_abierta.modulate = Color(1.4, 1.8, 1.4, 0.2)
		puerta_abierta.show()
		var tween := create_tween()
		tween.tween_property(puerta_abierta, "modulate", Color(1, 1, 1, 1), 0.45)

	if bloqueo != null:
		bloqueo.set_deferred("disabled", true)

	if etiqueta_estado != null:
		etiqueta_estado.text = "🔓 ACCESO HABILITADO →"
		etiqueta_estado.add_theme_color_override("font_color", Color("#55EFC4"))
		etiqueta_estado.scale = Vector2(1.25, 1.25)
		var tween_lbl := create_tween()
		tween_lbl.tween_property(etiqueta_estado, "scale", Vector2(1.0, 1.0), 0.4)

	if salida != null and salida.has_method("activar_salida"):
		salida.call("activar_salida")

	print("Puerta de seguridad abierta.")


func esta_desbloqueada() -> bool:
	return desbloqueada
