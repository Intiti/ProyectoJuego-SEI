extends Area2D

# ==========================================
# MGTS - NIVEL 2: INTERACCIÓN CON ALTAR RÚNICO
# Detección por distancia (_process) — más confiable que body_entered
# ==========================================

var jugador: CharacterBody2D = null
var letra_e: Label = null
var ventana_ejercicio: Control = null
var sprite_altar: Sprite2D = null

var altar_activo: bool = false
var jugador_cerca: bool = false

const RADIO_DETECCION: float = 140.0
const RUTA_TEXTURA_ALTAR: String = "res://assets/nivel_2/personajes/Altar_Runico.png"

func _ready() -> void:
	visible = true
	modulate.a = 1.0
	z_index = 2
	
	_crear_sombra_suelo()
	_asegurar_textura_altar()
	call_deferred("_resolver_referencias")

func _crear_sombra_suelo() -> void:
	if get_node_or_null("SombraSuelo"):
		return
	var sombra = Sprite2D.new()
	sombra.name = "SombraSuelo"
	var img = Image.create(160, 56, false, Image.FORMAT_RGBA8)
	for y in range(56):
		for x in range(160):
			var nx = (x - 80.0) / 80.0
			var ny = (y - 28.0) / 28.0
			var d = nx * nx + ny * ny
			if d <= 1.0:
				var a = (1.0 - d) * 0.6
				img.set_pixel(x, y, Color(0.01, 0.03, 0.05, a))
			else:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
	sombra.texture = ImageTexture.create_from_image(img)
	sombra.position = Vector2(0, -6)
	sombra.z_index = -1
	add_child(sombra)

## Asegura que el Altar Rúnico siempre tenga su textura asignada y sea completamente visible
func _asegurar_textura_altar() -> void:
	sprite_altar = get_node_or_null("SpriteAltar") as Sprite2D
	if sprite_altar:
		sprite_altar.visible = true
		sprite_altar.modulate = Color.WHITE
		sprite_altar.z_index = 2
		sprite_altar.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		
		if sprite_altar.texture == null:
			if ResourceLoader.exists(RUTA_TEXTURA_ALTAR):
				sprite_altar.texture = load(RUTA_TEXTURA_ALTAR)
				print("AltarRunico: Textura cargada exitosamente mediante ResourceLoader.")
			else:
				var global_path = ProjectSettings.globalize_path(RUTA_TEXTURA_ALTAR)
				if FileAccess.file_exists(global_path):
					var img = Image.new()
					if img.load(global_path) == OK:
						sprite_altar.texture = ImageTexture.create_from_image(img)
						print("AltarRunico: Textura cargada exitosamente mediante Image fallback.")

func _resolver_referencias() -> void:
	jugador = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if jugador == null:
		var root = get_parent()
		if root:
			jugador = root.get_node_or_null("Player") as CharacterBody2D
	
	letra_e = get_node_or_null("LetraE") as Label
	if sprite_altar == null:
		sprite_altar = get_node_or_null("SpriteAltar") as Sprite2D
	
	# VentanaEjercicio está en: EjercicioUI (CanvasLayer) > VentanaEjercicio
	var root = get_parent()
	if root:
		var ejercicio_ui = root.get_node_or_null("EjercicioUI")
		if ejercicio_ui:
			ventana_ejercicio = ejercicio_ui.get_node_or_null("VentanaEjercicio") as Control
	
	if letra_e:
		letra_e.visible = false
		letra_e.z_index = 10
	
	# Animación de pulso suave en el altar para indicar magia ancestral
	if sprite_altar:
		var tween = create_tween().set_loops()
		tween.tween_property(sprite_altar, "modulate", Color(0.85, 1.1, 1.3, 1.0), 1.5)
		tween.tween_property(sprite_altar, "modulate", Color(1.0, 1.0, 1.0, 1.0), 1.5)
	
	print("AltarRunico: Ventana=%s, Jugador=%s" % [str(ventana_ejercicio), str(jugador)])

func _ejercicio_completado() -> bool:
	var pj = get_node_or_null("/root/PuntajesNivel2")
	if pj == null or ventana_ejercicio == null:
		return false
	return pj.ejercicio_completado(String(ventana_ejercicio.get("codigo_ejercicio")))

func activar_altar() -> void:
	altar_activo = true
	if jugador_cerca and letra_e:
		letra_e.visible = true
	print("AltarRunico: ¡El altar rúnico ha despertado con poder ancestral!")

func _process(_delta: float) -> void:
	if jugador == null:
		jugador = get_tree().get_first_node_in_group("player") as CharacterBody2D
		return
	
	if not altar_activo:
		return
	if _ejercicio_completado():
		if letra_e:
			letra_e.visible = false
		return
	
	var dist = global_position.distance_to(jugador.global_position)
	var cerca_ahora = dist < RADIO_DETECCION
	
	if cerca_ahora != jugador_cerca:
		jugador_cerca = cerca_ahora
		if letra_e:
			letra_e.visible = cerca_ahora

func _unhandled_input(event: InputEvent) -> void:
	if not jugador_cerca or not altar_activo or _ejercicio_completado():
		return
	
	var es_interaccion = event.is_action_pressed("interact") or \
		(event is InputEventKey and event.pressed and event.keycode == KEY_E and not event.echo)
	
	if es_interaccion:
		get_viewport().set_input_as_handled()
		abrir_ejercicio()

func abrir_ejercicio() -> void:
	if _ejercicio_completado():
		return
	if ventana_ejercicio == null:
		var root = get_parent()
		if root:
			var ejercicio_ui = root.get_node_or_null("EjercicioUI")
			if ejercicio_ui:
				ventana_ejercicio = ejercicio_ui.get_node_or_null("VentanaEjercicio") as Control
	
	if ventana_ejercicio == null:
		push_error("AltarRunico: No se encontró VentanaEjercicio en EjercicioUI.")
		return
	
	if letra_e:
		letra_e.visible = false
	
	if jugador:
		jugador.set_physics_process(false)
	
	if ventana_ejercicio.has_method("abrir_reto"):
		ventana_ejercicio.abrir_reto()
	else:
		ventana_ejercicio.visible = true
