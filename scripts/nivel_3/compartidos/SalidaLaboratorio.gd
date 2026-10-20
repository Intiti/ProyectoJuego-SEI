extends Area2D

# ==========================================
# MGTS - NIVEL 3
# SALIDA DEL ESCENARIO
# ==========================================

@export_file("*.tscn") var siguiente_escena: String = ""

@onready var jugador: CharacterBody2D = get_node_or_null("../Player") as CharacterBody2D
@onready var puerta: Node = get_node_or_null("../PuertaSeguridad")

var salida_activa: bool = false
var cambiando_escena: bool = false


func _ready() -> void:
	monitoring = true
	if not body_entered.is_connected(_cuando_entra):
		body_entered.connect(_cuando_entra)
	print("Salida preparada.")


func _physics_process(_delta: float) -> void:
	if cambiando_escena:
		return
	if not _esta_habilitada():
		return

	for cuerpo in get_overlapping_bodies():
		if _es_jugador(cuerpo):
			_iniciar_transicion()
			return


func _esta_habilitada() -> bool:
	if salida_activa:
		return true
	if puerta != null:
		if puerta.has_method("esta_desbloqueada") and bool(puerta.call("esta_desbloqueada")):
			return true
		if "desbloqueada" in puerta and bool(puerta.get("desbloqueada")):
			return true
	return false


func _es_jugador(cuerpo: Node2D) -> bool:
	if cuerpo == null:
		return false
	if cuerpo == jugador or cuerpo.name == "Player" or cuerpo.is_in_group("player"):
		return true
	return false


func activar_salida() -> void:
	salida_activa = true
	print("Salida del escenario habilitada.")
	for cuerpo in get_overlapping_bodies():
		if _es_jugador(cuerpo):
			_iniciar_transicion()
			return


func desactivar_salida() -> void:
	salida_activa = false


func _cuando_entra(cuerpo: Node2D) -> void:
	if not _es_jugador(cuerpo):
		return
	if not _esta_habilitada() or cambiando_escena:
		return
	_iniciar_transicion()


func _iniciar_transicion() -> void:
	if cambiando_escena:
		return
	if siguiente_escena == "":
		push_warning("SalidaLaboratorio: falta asignar siguiente_escena en el Inspector.")
		return

	cambiando_escena = true
	var dj: Node = get_node_or_null("/root/DJManager")
	if dj != null and dj.has_method("play_sfx"):
		dj.call("play_sfx", "ui_abrir")

	print("Cambiando a escena: ", siguiente_escena)
	get_tree().call_deferred("change_scene_to_file", siguiente_escena)
