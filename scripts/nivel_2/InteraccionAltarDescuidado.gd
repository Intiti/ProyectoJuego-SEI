extends Area2D

# ==========================================
# MGTS - NIVEL 2: ALTAR DESCUIDADO Y SECUENCIA DE TELETRANSPORTACIÓN AL NIVEL 3
# Nexo arcano olvidado que conecta el Bosque Profundo con el Laboratorio Subterráneo
# ==========================================

const RUTA_TEXTURA_ALTAR: String = "res://assets/nivel_2/personajes/Altar_Descuidado.png"
const ESCENA_NIVEL_3: String = "res://scenes/Nivel_3/1Entrada del Laboratorio.tscn"

var jugador: CharacterBody2D = null
var sprite_altar: Sprite2D = null
var letra_e: Label = null
var examen_ui: CanvasLayer = null

var jugador_cerca: bool = false
var teletransportando: bool = false
var examen_aprobado: bool = false

# Efectos visuales de teletransporte
var particulas_ambiente: CPUParticles2D = null
var particulas_vortice: CPUParticles2D = null
var haz_de_luz: ColorRect = null
var flash_pantalla: ColorRect = null
var canvas_fx: CanvasLayer = null

const RADIO_DETECCION: float = 140.0

func _ready() -> void:
	visible = true
	modulate.a = 1.0
	z_index = 2
	
	_crear_sombra_suelo()
	_asegurar_textura()
	_crear_efectos_visuales()
	_rotar_examen_activo()
	body_entered.connect(_on_body_entered)
	call_deferred("_resolver_referencias")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_rotar_examen_activo()

## Rota aleatoriamente el examen activo para el altar (Nivel 2.5) en cada entrada
func _rotar_examen_activo() -> void:
	var puntajes = get_node_or_null("/root/PuntajesNivel2")
	if puntajes and puntajes.has_method("seleccionar_examen_aleatorio"):
		var idx = puntajes.seleccionar_examen_aleatorio()
		if examen_ui and "ejercicio_idx" in examen_ui and not examen_ui.visible:
			examen_ui.ejercicio_idx = idx
			examen_ui._ultimo_ejercicio_idx = idx

func _crear_sombra_suelo() -> void:
	if get_node_or_null("SombraSuelo"):
		return
	var sombra = Sprite2D.new()
	sombra.name = "SombraSuelo"
	var img = Image.create(170, 58, false, Image.FORMAT_RGBA8)
	for y in range(58):
		for x in range(170):
			var nx = (x - 85.0) / 85.0
			var ny = (y - 29.0) / 29.0
			var d = nx * nx + ny * ny
			if d <= 1.0:
				var a = (1.0 - d) * 0.65
				img.set_pixel(x, y, Color(0.01, 0.02, 0.04, a))
			else:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
	sombra.texture = ImageTexture.create_from_image(img)
	sombra.position = Vector2(0, -6)
	sombra.z_index = -1
	add_child(sombra)

func _asegurar_textura() -> void:
	sprite_altar = get_node_or_null("SpriteAltar") as Sprite2D
	if sprite_altar == null:
		sprite_altar = Sprite2D.new()
		sprite_altar.name = "SpriteAltar"
		add_child(sprite_altar)
	
	sprite_altar.visible = true
	sprite_altar.z_index = 2
	sprite_altar.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite_altar.position = Vector2(0, -68)
	sprite_altar.scale = Vector2(0.145, 0.145)
	
	if ResourceLoader.exists(RUTA_TEXTURA_ALTAR):
		sprite_altar.texture = load(RUTA_TEXTURA_ALTAR)
	elif FileAccess.file_exists(ProjectSettings.globalize_path(RUTA_TEXTURA_ALTAR)):
		var img = Image.new()
		if img.load(ProjectSettings.globalize_path(RUTA_TEXTURA_ALTAR)) == OK:
			sprite_altar.texture = ImageTexture.create_from_image(img)

func _crear_efectos_visuales() -> void:
	# Partículas ambientales sutiles de polvo de maná dormido
	particulas_ambiente = CPUParticles2D.new()
	particulas_ambiente.name = "ParticulasAmbiente"
	particulas_ambiente.amount = 14
	particulas_ambiente.lifetime = 2.4
	particulas_ambiente.preprocess = 1.0
	particulas_ambiente.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particulas_ambiente.emission_rect_extents = Vector2(45, 15)
	particulas_ambiente.direction = Vector2(0, -1)
	particulas_ambiente.spread = 20.0
	particulas_ambiente.gravity = Vector2(0, -15)
	particulas_ambiente.initial_velocity_min = 15.0
	particulas_ambiente.initial_velocity_max = 35.0
	particulas_ambiente.scale_amount_min = 2.0
	particulas_ambiente.scale_amount_max = 3.5
	particulas_ambiente.color = Color(0.2, 0.9, 0.85, 0.45)
	particulas_ambiente.position = Vector2(0, -30)
	add_child(particulas_ambiente)
	
	# Vórtice intenso para teletransporte
	particulas_vortice = CPUParticles2D.new()
	particulas_vortice.name = "ParticulasVortice"
	particulas_vortice.emitting = false
	particulas_vortice.amount = 90
	particulas_vortice.lifetime = 1.2
	particulas_vortice.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particulas_vortice.emission_sphere_radius = 65.0
	particulas_vortice.gravity = Vector2(0, -120)
	particulas_vortice.initial_velocity_min = 40.0
	particulas_vortice.initial_velocity_max = 90.0
	particulas_vortice.scale_amount_min = 3.0
	particulas_vortice.scale_amount_max = 6.0
	particulas_vortice.color = Color(0.3, 1.0, 0.95, 0.9)
	particulas_vortice.position = Vector2(0, -30)
	add_child(particulas_vortice)
	
	# Columna o haz de luz vertical
	haz_de_luz = ColorRect.new()
	haz_de_luz.size = Vector2(100, 1200)
	haz_de_luz.position = Vector2(-50, -1200)
	haz_de_luz.color = Color(0.3, 0.95, 1.0, 0.0) # Transparente al inicio
	haz_de_luz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(haz_de_luz)
	
	# Canvas Layer para el flash de transición a pantalla completa
	canvas_fx = CanvasLayer.new()
	canvas_fx.layer = 25
	add_child(canvas_fx)
	
	flash_pantalla = ColorRect.new()
	flash_pantalla.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash_pantalla.color = Color(1, 1, 1, 0)
	flash_pantalla.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_fx.add_child(flash_pantalla)

func _resolver_referencias() -> void:
	jugador = get_tree().get_first_node_in_group("player") as CharacterBody2D
	letra_e = get_node_or_null("LetraE") as Label
	if letra_e:
		letra_e.visible = false
		letra_e.text = "[E] Sintonizar Altar Ancestral"
	
	if examen_ui == null:
		var root = get_tree().current_scene
		if root:
			examen_ui = root.get_node_or_null("ExamenUI") as CanvasLayer
			if examen_ui == null:
				for hijo in root.get_children():
					if hijo.name == "ExamenUI" or hijo.has_method("abrir_examen"):
						examen_ui = hijo
						break

func asignar_examen_ui(ui_node: CanvasLayer) -> void:
	examen_ui = ui_node

func _process(_delta: float) -> void:
	if teletransportando:
		return
	
	if jugador == null:
		jugador = get_tree().get_first_node_in_group("player") as CharacterBody2D
		return
	
	var dist = global_position.distance_to(jugador.global_position)
	var cerca_ahora = dist < RADIO_DETECCION
	
	if cerca_ahora != jugador_cerca:
		jugador_cerca = cerca_ahora
		if letra_e:
			letra_e.visible = cerca_ahora and (examen_ui == null or not examen_ui.visible)

func _unhandled_input(event: InputEvent) -> void:
	if teletransportando or not jugador_cerca:
		return
	
	if examen_ui and examen_ui.visible:
		return
	
	var es_interactuar = event.is_action_pressed("interact") or \
		(event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E)
	
	if es_interactuar:
		get_viewport().set_input_as_handled()
		_activar_altar()

func _activar_altar() -> void:
	if letra_e:
		letra_e.visible = false
	
	if examen_ui:
		var puntajes = get_node_or_null("/root/PuntajesNivel2")
		if puntajes and "examen_activo_idx" in puntajes and puntajes.examen_activo_idx >= 0:
			examen_ui.ejercicio_idx = puntajes.examen_activo_idx
		examen_ui.abrir_examen(self)
	else:
		iniciar_secuencia_teletransporte()

## Ejecuta la secuencia cinematográfica de teletransportación hacia el Nivel 3
func iniciar_secuencia_teletransporte() -> void:
	if teletransportando:
		return
	teletransportando = true
	
	if letra_e:
		letra_e.visible = false
	
	if jugador == null:
		jugador = get_tree().get_first_node_in_group("player") as CharacterBody2D
	
	if jugador:
		jugador.set_physics_process(false)
		jugador.set_process_unhandled_input(false)
		jugador.set_process_input(false)
		jugador.velocity = Vector2.ZERO
	
	print("AltarDescuidado: ¡Iniciando secuencia de teletransporte hacia el Complejo Subterráneo (Nivel 3)!")
	
	# Posición de destino del jugador: justo sobre el altar
	var pos_altar = global_position + Vector2(0, -10)
	
	var tween = create_tween().set_parallel(true)
	
	# 1. El jugador camina/desliza hacia el centro del altar
	if jugador:
		tween.tween_property(jugador, "global_position", pos_altar, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# 2. El altar brilla intensamente reactivando sus runas milenarias
	if sprite_altar:
		tween.tween_property(sprite_altar, "modulate", Color(0.3, 1.8, 1.9, 1.0), 1.2).set_trans(Tween.TRANS_SINE)
	
	await get_tree().create_timer(0.75).timeout
	
	# 3. Activación de vórtice y haz de luz
	particulas_vortice.emitting = true
	
	var tween_haz = create_tween().set_parallel(true)
	tween_haz.tween_property(haz_de_luz, "color:a", 0.85, 0.6).set_trans(Tween.TRANS_CUBIC)
	if jugador:
		# El jugador levita y absorbe energía cian/blanca
		tween_haz.tween_property(jugador, "global_position:y", pos_altar.y - 45.0, 1.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween_haz.tween_property(jugador, "modulate", Color(0.4, 2.0, 2.0, 1.0), 1.0)
	
	# Temblor de cámara / resonancia del suelo
	_sacudir_camara(1.4)
	
	await get_tree().create_timer(1.2).timeout
	
	# 4. Desmaterialización y flash dimensional
	if jugador:
		var tween_disolver = create_tween().set_parallel(true)
		tween_disolver.tween_property(jugador, "scale", Vector2(0.1, 2.5), 0.35).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
		tween_disolver.tween_property(jugador, "modulate:a", 0.0, 0.35)
	
	# Destello blanco expansivo
	var tween_flash = create_tween()
	tween_flash.tween_property(flash_pantalla, "color", Color(0.85, 1.0, 1.0, 1.0), 0.45).set_trans(Tween.TRANS_EXPO)
	tween_flash.tween_property(flash_pantalla, "color", Color(0.02, 0.04, 0.08, 1.0), 0.55).set_trans(Tween.TRANS_CUBIC)
	
	await tween_flash.finished
	
	var resumenNivel = GameData.showNivelResumen(2)
	if resumenNivel != null:
		await resumenNivel.closed
	
	if MenuPausa.mostrarAvisoExamen2():
		await MenuPausa.avisoCerrado
	
	# 5. Salto al Laboratorio Subterráneo (Nivel 3)
	print("AltarDescuidado: Teletransporte completado. Cargando Nivel 3...")
	if ResourceLoader.exists(ESCENA_NIVEL_3):
		get_tree().change_scene_to_file(ESCENA_NIVEL_3)
	else:
		push_error("AltarDescuidado: No se encontró la escena: " + ESCENA_NIVEL_3)

func _sacudir_camara(duracion: float) -> void:
	var camara: Camera2D = null
	if jugador:
		camara = jugador.get_node_or_null("Camera2D") as Camera2D
	if camara == null:
		camara = get_viewport().get_camera_2d()
	
	if camara == null:
		return
	
	var tiempo_inicio = Time.get_ticks_msec() / 1000.0
	var offset_original = camara.offset
	
	while (Time.get_ticks_msec() / 1000.0) - tiempo_inicio < duracion:
		var fuerza = 6.0 * (1.0 - ((Time.get_ticks_msec() / 1000.0) - tiempo_inicio) / duracion)
		camara.offset = offset_original + Vector2(randf_range(-fuerza, fuerza), randf_range(-fuerza, fuerza))
		await get_tree().process_frame
	
	camara.offset = offset_original
