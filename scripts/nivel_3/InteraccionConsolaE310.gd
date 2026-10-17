
extends Area2D

# ==========================================
# MGTS - NIVEL 3 - EJERCICIO E3.10
# CAMARA DE RESCATE
# CONSOLA DEL PROTOCOLO DE RESCATE
# NPC: LINCE CIBERNETICO
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

@onready var lince_cibernetico: Area2D = get_node_or_null(
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

var jugador_congelado: bool = false


# ==========================================
# INICIO
# ==========================================

func _ready() -> void:

	monitoring = true

	# Ocultar letra E al iniciar.
	if letra_e != null:

		letra_e.hide()

	else:

		push_error(
			"E3.10: falta LetraE en InteraccionConsola."
		)

	# Preparar indicador de objetivo.
	if indicador_objetivo != null:

		indicador_objetivo.text = "!"

		# Color dorado del protocolo de rescate.
		indicador_objetivo.add_theme_color_override(
			"font_color",
			Color("#FFD700")
		)

		indicador_objetivo.hide()

	else:

		push_error(
			"E3.10: falta IndicadorObjetivo."
		)

	# Ocultar ventana del ejercicio.
	if ventana_ejercicio != null:

		ventana_ejercicio.hide()

	else:

		push_error(
			"E3.10: falta EjercicioUI/VentanaEjercicio."
		)

	if jugador == null:

		push_error(
			"E3.10: no se encontró Player."
		)

	# Conectar señal del Lince Cibernético.
	if lince_cibernetico == null:

		push_error(
			"E3.10: no se encontró InteraccionGatoa2D."
		)

	else:

		if lince_cibernetico.has_signal("iniciar_ejercicio"):

			var conexion: Callable = Callable(
				self,
				"habilitar_consola"
			)

			if not lince_cibernetico.is_connected(
				"iniciar_ejercicio",
				conexion
			):

				lince_cibernetico.connect(
					"iniciar_ejercicio",
					conexion
				)

		else:

			push_warning(
				"E3.10: el Lince Cibernético no tiene "
				+ "la señal iniciar_ejercicio."
			)

		# Recuperar estado si el diálogo
		# ya había terminado.
		if lince_cibernetico.get("dialogo_terminado") == true:

			consola_habilitada = true

	# Detectar entrada del protagonista.
	if not body_entered.is_connected(_cuando_entra):

		body_entered.connect(_cuando_entra)

	# Detectar salida del protagonista.
	if not body_exited.is_connected(_cuando_sale):

		body_exited.connect(_cuando_sale)

	actualizar_indicadores()

	print("E3.10: consola de rescate preparada.")


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

	print("E3.10: diálogo con el Lince Cibernético terminado.")
	print("E3.10: consola del protocolo de rescate habilitada.")


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

	# No abrir mientras el Lince Cibernético habla.
	if lince_cibernetico != null:

		if lince_cibernetico.get("dialogo_activo") == true:
			return

	abrir_ejercicio()

	get_viewport().set_input_as_handled()


# ==========================================
# ABRIR EJERCICIO
# ==========================================

func abrir_ejercicio() -> void:

	if ventana_ejercicio == null:

		push_error(
			"E3.10: no se encontró VentanaEjercicio."
		)
		return

	if ejercicio_completado:
		return

	if ejercicio_abierto:
		return

	if not consola_habilitada:
		return

	# Evitar abrir durante la conversación.
	if lince_cibernetico != null:

		if lince_cibernetico.get("dialogo_activo") == true:
			return

	ejercicio_abierto = true

	actualizar_indicadores()

	# Congelar al protagonista.
	congelar_jugador()

	# Mostrar ventana E3.10.
	ventana_ejercicio.show()

	# Preparar ejercicio del protocolo de rescate.
	if ventana_ejercicio.has_method("iniciar_ejercicio"):

		ventana_ejercicio.call(
			"iniciar_ejercicio"
		)

	print("E3.10: ventana del protocolo de rescate abierta.")


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

	print("E3.10: ventana del ejercicio cerrada.")


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

	print("E3.10: protocolo de rescate completado.")
	print("E3.10: sistema de rescate activado.")
	print("E3.10: consola desactivada.")


# ==========================================
# CONGELAR JUGADOR
# ==========================================

func congelar_jugador() -> void:

	if jugador == null:
		return

	if jugador_congelado:
		return

	jugador_congelado = true

	# Guardar estados originales.
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

	# Detener movimiento.
	jugador.velocity = Vector2.ZERO

	jugador.set_physics_process(false)
	jugador.set_process_input(false)
	jugador.set_process_unhandled_input(false)
	jugador.set_process_unhandled_key_input(false)

	print("E3.10: jugador detenido durante el ejercicio.")


# ==========================================
# DESCONGELAR JUGADOR
# ==========================================

func descongelar_jugador() -> void:

	if jugador == null:
		return

	if not jugador_congelado:
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

	jugador_congelado = false

	print("E3.10: movimiento del jugador restaurado.")
