
extends GridContainer

# ==========================================
# MGTS - INSIGNIAS GANADAS
# PANTALLA FINAL
# ==========================================

# Imágenes de las insignias.
# Agrégalas desde el Inspector en el
# mismo orden en que se registran.

@export var imagenes_insignias: Array[Texture2D] = []

# Nombres que aparecerán al pasar el mouse.
@export var nombres_insignias: Array[String] = []

# Estado inicial de cada insignia.
# Es una configuración de prueba hasta
# conectarlo al sistema real de guardado.

@export var insignias_desbloqueadas: Array[bool] = []

@export var columnas: int = 5

@export var tamano_icono: Vector2 = Vector2(64, 64)

var estados_actuales: Array[bool] = []


# ==========================================
# INICIO
# ==========================================

func _ready() -> void:

	columns = maxi(columnas, 1)

	estados_actuales = (
		insignias_desbloqueadas.duplicate()
	)

	mostrar_insignias()


# ==========================================
# ACTUALIZAR INSIGNIAS
# ==========================================

func actualizar_insignias(
	estados: Array[bool]
) -> void:

	estados_actuales = estados.duplicate()

	mostrar_insignias()


# ==========================================
# MOSTRAR INSIGNIAS
# ==========================================

func mostrar_insignias() -> void:

	columns = maxi(columnas, 1)

	# Borrar iconos anteriores.
	for hijo in get_children():

		remove_child(hijo)
		hijo.queue_free()

	# Crear cada insignia.
	for i in range(imagenes_insignias.size()):

		var icono := TextureRect.new()

		icono.texture = imagenes_insignias[i]

		icono.custom_minimum_size = tamano_icono

		icono.expand_mode = (
			TextureRect.EXPAND_IGNORE_SIZE
		)

		icono.stretch_mode = (
			TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		)

		icono.mouse_filter = (
			Control.MOUSE_FILTER_STOP
		)

		var nombre: String = (
			"Insignia " + str(i + 1)
		)

		if i < nombres_insignias.size():

			if not nombres_insignias[i].is_empty():

				nombre = nombres_insignias[i]

		var ganada: bool = false

		if i < estados_actuales.size():

			ganada = estados_actuales[i]

		if ganada:

			icono.modulate = Color.WHITE

			icono.tooltip_text = (
				"🏅 " + nombre + " - Conseguida"
			)

		else:

			icono.modulate = Color(
				0.25, 0.25, 0.25, 0.6
			)

			icono.tooltip_text = (
				"🔒 " + nombre + " - Bloqueada"
			)

		add_child(icono)


# ==========================================
# CONSULTAR INSIGNIAS GANADAS
# ==========================================

func obtener_cantidad_ganadas() -> int:

	var cantidad: int = 0

	for estado in estados_actuales:

		if estado:
			cantidad += 1

	return cantidad
