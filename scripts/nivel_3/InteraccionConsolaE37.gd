
extends Area2D

# ==========================================
# MGTS - NIVEL 3 - EJERCICIO E3.7
# TUNELES DE RADIACION
# CONSOLA DEL ESCUDO DE RADIACION
# NPC: ROBOT DE SEGURIDAD
# ==========================================


# ==========================================
# REFERENCIAS
# ==========================================

@onready var jugador: CharacterBody2D = get_node_or_null(
	"../Player"
) as CharacterBody2D

@onready var letra_e: Label = get_node_or_null(
	"LetraE"
) as Label

@onready var indicador_objetivo: Label = get_node_or_null(
	"IndicadorObjetivo"
) as Label

@onready var robot_seguridad: Area2D = get_node_or_null(
	"../InteraccionGatoa2D"
) as Area2D

@onready var ventana_ejercicio: PanelContainer = get_node_or_null(
	"../EjercicioUI/VentanaEjercicio"
) as PanelContainer


# ==========================================
# VARIABLES
# ==========================================

var jugador_cerca: bool = false
var consola_habilitada: bool = false
var ejercicio_abierto: bool = false
var ejercicio_completado: bool = false

var fisica_jugador_activa: bool = true
var input_jugador_activo: bool = true
var unhandled_jugador_activo: bool = true
var unhandled_key_jugador_activo: bool = true


# ==========================================
# INICIO
# ==========================================

func _ready() -> void:

	monitoring = true

	# Ocultar letra E al iniciar.
	if letra_e != null:
		letra_e.hide()
	else:
		push_error("E3.7: falta LetraE.")

	# Ocultar indicador de objetivo.
	if indicador_objetivo != null:

		indicador_objetivo.text = "!"

		indicador_objetivo.add_theme_color_override(
			"font_color",
			Color("#ffd700")
		)

		indicador_objetivo.hide()

	else:
		push_error("E3.7: falta IndicadorObjetivo.")

	# Ocultar ventana del ejercicio.
	if ventana_ejercicio != null:

		ventana_ejercicio.hide()

	else:

		push_error(
			"E3.7: no se encontró EjercicioUI/VentanaEjercicio."
		)

	if jugador == null:
		push_error("E3.7: no se encontró Player.")

	# Conectar señal del Robot de Seguridad.
	if robot_seguridad == null:

		push_error(
			"E3.7: no se encontró InteraccionGatoa2D."
		)

	else:

		if robot_seguridad.has_signal("iniciar_ejercicio"):

			var conexion: Callable = Callable(
				self,
				"habilitar_consola"
			)

			if not robot_seguridad.is_connected(
				"iniciar_ejercicio",
				conexion
			):

				robot_seguridad.connect(
					"iniciar_ejercicio",
					conexion
				)

		else:

			push_warning(
				"E3.7: el Robot de Seguridad no tiene "
				+ "la señal iniciar_ejercicio."
			)

		# Recuperar estado si el diálogo
		# ya había terminado.
		if robot_seguridad.get("dialogo_terminado") == true:

			consola_habilitada = true

	# Detectar entrada del jugador.
	if not body_entered.is_connected(_cuando_entra):

		body_entered.connect(_cuando_entra)

	# Detectar salida del jugador.
	if not body_exited.is_connected(_cuando_sale):

		body_exited.connect(_cuando_sale)

	actualizar_indicadores()

	print("E3.7: consola de radiación preparada.")


# ==========================================
# DETECTAR JUGADOR
# ==========================================

func _cuando_entra(cuerpo: Node2D) -> void:

	if cuerpo == jugador:

		jugador_cerca = true

		actualizar_indicadores()


func _cuando_sale(cuerpo: Node2D) -> void:

	if cuerpo == jugador:

		jugador_cerca = false

		actualizar_indicadores()


# ==========================================
# ACTUALIZAR INDICADORES
# ==========================================

func actualizar_indicadores() -> void:

	var consola_pendiente: bool = (
		consola_habilitada
		and not ejercicio_abierto
		and not ejercicio_completado
	)

	# Mostrar ! cuando el jugador está lejos.
	if indicador_objetivo != null:

		indicador_objetivo.visible = (
			consola_pendiente
			and not jugador_cerca
		)

	# Mostrar E cuando el jugador está cerca.
	if letra_e != null:

		letra_e.visible = (
			consola_pendiente
			and jugador_cerca
		)


# ==========================================
# HABILITAR CONSOLA
# ==========================================

func habilitar_consola() -> void:

	if ejercicio_completado:
		return

	consola_habilitada = true

	actualizar_indicadores()

	print("E3.7: diálogo con el Robot de Seguridad terminado.")
	print("E3.7: consola del escudo de radiación habilitada.")


# ==========================================
# DETECTAR TECLA E
# ==========================================

func _unhandled_key_input(event: InputEvent) -> void:

	if not event is InputEventKey:
		return

	if not event.pressed or event.echo:
		return

	if event.keycode != KEY_E:
		return

	if not jugador_cerca:
		return

	if not consola_habilitada:
		return

	if ejercicio_abierto or ejercicio_completado:
		return

	# No abrir mientras el robot habla.
	if robot_seguridad != null:

		if robot_seguridad.get("dialogo_activo") == true:
			return

	abrir_ejercicio()

	get_viewport().set_input_as_handled()


# ==========================================
# ABRIR EJERCICIO
# ==========================================

func abrir_ejercicio() -> void:

	if ventana_ejercicio == null:

		push_error(
			"E3.7: falta la ventana del ejercicio."
		)
		return

	if ejercicio_completado:
		return

	if ejercicio_abierto:
		return

	if not consola_habilitada:
		return

	ejercicio_abierto = true

	actualizar_indicadores()

	# Detener al protagonista.
	congelar_jugador()

	# Mostrar ventana E3.7.
	ventana_ejercicio.show()

	# Preparar el ejercicio de radiación.
	if ventana_ejercicio.has_method("iniciar_ejercicio"):

		ventana_ejercicio.call(
			"iniciar_ejercicio"
		)

	print("E3.7: ventana del escudo de radiación abierta.")


# ==========================================
# CERRAR EJERCICIO
# ==========================================

func cerrar_ejercicio() -> void:

	if ejercicio_completado:
		return

	if not ejercicio_abierto:
		return

	ejercicio_abierto = false

	if ventana_ejercicio != null:
		ventana_ejercicio.hide()

	# Devolver movimiento al protagonista.
	descongelar_jugador()

	# Restaurar ! o E según la distancia.
	actualizar_indicadores()

	print("E3.7: ventana del ejercicio cerrada.")


# ==========================================
# COMPLETAR EJERCICIO
# ==========================================

func completar_ejercicio() -> void:

	if ejercicio_completado:
		return

	ejercicio_completado = true
	ejercicio_abierto = false
	consola_habilitada = false

	if ventana_ejercicio != null:
		ventana_ejercicio.hide()

	# Ocultar definitivamente ! y E.
	actualizar_indicadores()

	# Devolver movimiento al protagonista.
	descongelar_jugador()

	print("E3.7: escudo de radiación activado.")
	print("E3.7: túneles protegidos.")
	print("E3.7: consola desactivada.")


# ==========================================
# CONGELAR JUGADOR
# ==========================================

func congelar_jugador() -> void:

	if jugador == null:
		return

	fisica_jugador_activa = (
		jugador.is_physics_processing()
	)

	input_jugador_activo = (
		jugador.is_processing_input()
	)

	unhandled_jugador_activo = (
		jugador.is_processing_unhandled_input()
	)

	unhandled_key_jugador_activo = (
		jugador.is_processing_unhandled_key_input()
	)

	jugador.velocity = Vector2.ZERO

	jugador.set_physics_process(false)
	jugador.set_process_input(false)
	jugador.set_process_unhandled_input(false)
	jugador.set_process_unhandled_key_input(false)


# ==========================================
# DESCONGELAR JUGADOR
# ==========================================

func descongelar_jugador() -> void:

	if jugador == null:
		return

	jugador.set_physics_process(
		fisica_jugador_activa
	)

	jugador.set_process_input(
		input_jugador_activo
	)

	jugador.set_process_unhandled_input(
		unhandled_jugador_activo
	)

	jugador.set_process_unhandled_key_input(
		unhandled_key_jugador_activo
	)
