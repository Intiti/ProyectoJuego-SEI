
extends PanelContainer

# ==========================================
# MGTS - VENTANA FINAL DEL JUEGO
# RESCATE DE PANKO
# ==========================================

# Configurar estas escenas en el Inspector.
@export_file("*.tscn") var escena_menu: String = ""
@export_file("*.tscn") var escena_inicio: String = ""


# ==========================================
# FONDO Y PERSONAJES
# ==========================================

@onready var oscurecer_fondo: ColorRect = get_node_or_null(
	"../OscurecerFondo"
) as ColorRect

@onready var abrazo_final: Control = get_node_or_null(
	"../AbrazoFinal"
) as Control

@onready var jugador_original: Node2D = get_node_or_null(
	"../../Player"
) as Node2D

@onready var panko_original: Node2D = get_node_or_null(
	"../../PANKO"
) as Node2D


# ==========================================
# ELEMENTOS DE LA VENTANA
# ==========================================

@onready var titulo_final: Label = (
	$ContenidoFinal/TituloFinal
)

@onready var icono_trofeo: TextureRect = (
	$ContenidoFinal/IconoTrofeo
)

@onready var mensaje_final: Label = (
	$ContenidoFinal/MensajeFinal
)

@onready var puntos_nivel_1: Label = (
	$ContenidoFinal/PuntosNivel1
)

@onready var puntos_nivel_2: Label = (
	$ContenidoFinal/PuntosNivel2
)

@onready var puntos_nivel_3: Label = (
	$ContenidoFinal/PuntosNivel3
)

@onready var puntos_totales: Label = (
	$ContenidoFinal/PuntosTotales
)

@onready var titulo_insignias: Label = (
	$ContenidoFinal/TituloInsignias
)

@onready var insignias_ganadas: GridContainer = (
	$ContenidoFinal/InsigniasGanadas
)

@onready var boton_menu: Button = (
	$ContenidoFinal/BotonesFinal/BotonMenu
)

@onready var boton_reiniciar: Button = (
	$ContenidoFinal/BotonesFinal/BotonReiniciar
)


# ==========================================
# SISTEMAS DE PUNTOS
# ==========================================

@onready var sistema_nivel_1: Node = get_node_or_null(
	"/root/PuntajesNivel1"
)

@onready var sistema_nivel_2: Node = get_node_or_null(
	"/root/PuntajesNivel2"
)

@onready var sistema_nivel_3: Node = get_node_or_null(
	"/root/PuntajesNivel3"
)


# ==========================================
# INICIO
# ==========================================

func _ready() -> void:

	# Ocultar pantalla final al comenzar.
	hide()

	if abrazo_final != null:
		abrazo_final.hide()

	# Preparar fondo oscuro.
	if oscurecer_fondo != null:

		oscurecer_fondo.hide()

		oscurecer_fondo.set_anchors_and_offsets_preset(
			Control.PRESET_FULL_RECT
		)

		oscurecer_fondo.color = Color(
			0.063, 0.063, 0.125, 1.0
		)

		# No bloquear clics del ratón.
		oscurecer_fondo.mouse_filter = (
			Control.MOUSE_FILTER_IGNORE
		)

	else:

		push_warning(
			"MGTS: no se encontró OscurecerFondo."
		)

	# Evitar que la imagen del abrazo
	# bloquee los botones.
	if abrazo_final != null:
		abrazo_final.mouse_filter = (
			Control.MOUSE_FILTER_IGNORE
		)

	# Textos de victoria.
	titulo_final.text = "¡MISIÓN CUMPLIDA!"

	mensaje_final.text = (
		"¡HAS RESCATADO A PANKO!\n"
		+ "¡Has completado los 3 niveles de MGTS!"
	)

	mensaje_final.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	titulo_insignias.text = (
		"🏅 INSIGNIAS CONSEGUIDAS"
	)

	# Mantener proporción del trofeo.
	icono_trofeo.expand_mode = (
		TextureRect.EXPAND_IGNORE_SIZE
	)

	icono_trofeo.stretch_mode = (
		TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	)

	icono_trofeo.custom_minimum_size = Vector2(
		120, 120
	)

	icono_trofeo.size_flags_horizontal = (
		Control.SIZE_SHRINK_CENTER
	)

	# ======================================
	# PREPARAR BOTONES
	# ======================================

	boton_menu.text = "Volver al menú"
	boton_reiniciar.text = "Jugar de nuevo"

	boton_menu.disabled = false
	boton_reiniciar.disabled = false

	boton_menu.mouse_filter = (
		Control.MOUSE_FILTER_STOP
	)

	boton_reiniciar.mouse_filter = (
		Control.MOUSE_FILTER_STOP
	)

	# Conectar botón del menú.
	if not boton_menu.pressed.is_connected(
		volver_al_menu
	):

		boton_menu.pressed.connect(
			volver_al_menu
		)

	# Conectar botón de reinicio.
	if not boton_reiniciar.pressed.is_connected(
		jugar_de_nuevo
	):

		boton_reiniciar.pressed.connect(
			jugar_de_nuevo
		)

	print("MGTS: ventana final preparada.")
	print("MGTS: botones del final conectados.")


# ==========================================
# MOSTRAR PANTALLA FINAL
# ==========================================

func mostrar_final() -> void:

	print("MGTS: mostrando pantalla final.")

	# 1. Mostrar fondo oscuro.
	if oscurecer_fondo != null:
		oscurecer_fondo.show()

	# 2. Ocultar personajes originales.
	if jugador_original != null:
		jugador_original.hide()

	if panko_original != null:
		panko_original.hide()

	# 3. Mostrar imagen del abrazo.
	if abrazo_final != null:
		abrazo_final.show()

	# 4. Consultar puntos.
	var total_1: int = obtener_puntos_nivel(
		sistema_nivel_1
	)

	var total_2: int = obtener_puntos_nivel(
		sistema_nivel_2
	)

	var total_3: int = obtener_puntos_nivel(
		sistema_nivel_3
	)

	var total_general: int = (
		total_1 + total_2 + total_3
	)

	# 5. Actualizar puntuaciones.
	puntos_nivel_1.text = (
		"Nivel 1: "
		+ str(total_1)
		+ " puntos"
	)

	puntos_nivel_2.text = (
		"Nivel 2: "
		+ str(total_2)
		+ " puntos"
	)

	puntos_nivel_3.text = (
		"Nivel 3: "
		+ str(total_3)
		+ " puntos"
	)

	puntos_totales.text = (
		"TOTAL: "
		+ str(total_general)
		+ " puntos"
	)

	# 6. Actualizar insignias.
	if insignias_ganadas != null:

		if insignias_ganadas.has_method(
			"mostrar_insignias"
		):

			insignias_ganadas.call(
				"mostrar_insignias"
			)

	# 7. Mostrar ventana de victoria.
	show()

	# Asegurar que los botones puedan
	# recibir clics.
	boton_menu.disabled = false
	boton_reiniciar.disabled = false

	print("================================")
	print("¡MISIÓN CUMPLIDA!")
	print("¡PANKO HA SIDO RESCATADO!")
	print("Nivel 1: ", total_1)
	print("Nivel 2: ", total_2)
	print("Nivel 3: ", total_3)
	print("TOTAL: ", total_general)
	print("================================")


# ==========================================
# OBTENER PUNTOS DE CADA NIVEL
# ==========================================

func obtener_puntos_nivel(
	sistema: Node
) -> int:

	if sistema == null:

		push_warning(
			"MGTS: sistema de puntos no encontrado."
		)

		return 0

	if sistema.has_method(
		"obtener_total_nivel"
	):

		return int(
			sistema.call(
				"obtener_total_nivel"
			)
		)

	if sistema.has_method(
		"obtener_puntos_totales"
	):

		return int(
			sistema.call(
				"obtener_puntos_totales"
			)
		)

	var puntos: Variant = sistema.get(
		"puntos_totales"
	)

	if puntos != null:

		return int(puntos)

	push_warning(
		"MGTS: no se encontró una función "
		+ "compatible para consultar puntos."
	)

	return 0


# ==========================================
# VOLVER AL MENÚ
# ==========================================

func volver_al_menu() -> void:

	print("MGTS: botón Volver al menú presionado.")

	if escena_menu.is_empty():

		push_warning(
			"MGTS: configura escena_menu "
			+ "en el Inspector."
		)

		return

	if not ResourceLoader.exists(escena_menu):

		push_error(
			"MGTS: no existe la escena del menú: "
			+ escena_menu
		)

		return

	var error: Error = get_tree().change_scene_to_file(
		escena_menu
	)

	if error != OK:

		push_error(
			"MGTS: error al abrir el menú: "
			+ str(error)
		)


# ==========================================
# JUGAR DE NUEVO
# ==========================================

func jugar_de_nuevo() -> void:

	print("MGTS: botón Jugar de nuevo presionado.")

	if escena_inicio.is_empty():

		push_warning(
			"MGTS: configura escena_inicio "
			+ "en el Inspector."
		)

		return

	if not ResourceLoader.exists(escena_inicio):

		push_error(
			"MGTS: no existe la escena inicial: "
			+ escena_inicio
		)

		return

	var error: Error = get_tree().change_scene_to_file(
		escena_inicio
	)

	if error != OK:

		push_error(
			"MGTS: error al iniciar una nueva partida: "
			+ str(error)
		)
