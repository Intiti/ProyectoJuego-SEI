
extends Area2D

# ==========================================
# MGTS - NIVEL 3 - EJERCICIO E3.2
# INTERACCION CON LA CONSOLA DE ENERGIA
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

@onready var gato: Area2D = get_node_or_null(
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

	if letra_e != null:
		letra_e.hide()
	else:
		push_error("E3.2: falta LetraE.")

	if indicador_objetivo != null:
		indicador_objetivo.hide()
	else:
		push_error("E3.2: falta IndicadorObjetivo.")

	if ventana_ejercicio != null:
		ventana_ejercicio.hide()
	else:
		push_error(
			"E3.2: no se encontro EjercicioUI/VentanaEjercicio."
		)

	if jugador == null:
		push_error("E3.2: no se encontro Player.")

	if gato == null:
		push_error(
			"E3.2: no se encontro InteraccionGatoa2D."
		)
	else:

		# Conectar la señal que se emite
		# al terminar el dialogo con el gato.
		if gato.has_signal("iniciar_ejercicio"):

			var conexion: Callable = Callable(
				self,
				"habilitar_consola"
			)

			if not gato.is_connected(
				"iniciar_ejercicio",
				conexion
			):
				gato.connect(
					"iniciar_ejercicio",
					conexion
				)

		# Recuperar el estado si el dialogo
		# ya habia terminado.
		if gato.get("dialogo_terminado") == true:
			consola_habilitada = true

	body_entered.connect(_cuando_entra)
	body_exited.connect(_cuando_sale)

	actualizar_indicadores()

	print("E3.2: consola de energia preparada.")


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

	# Mostrar ! cuando el jugador esta lejos.
	if indicador_objetivo != null:

		indicador_objetivo.visible = (
			consola_pendiente
			and not jugador_cerca
		)

	# Mostrar E cuando el jugador esta cerca.
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

	print("E3.2: dialogo terminado.")
	print("E3.2: consola habilitada.")


# ==========================================
# PRESIONAR E
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

	# Evitar abrir la consola mientras
	# el dialogo del gato sigue activo.
	if gato != null:
		if gato.get("dialogo_activo") == true:
			return

	abrir_ejercicio()

	get_viewport().set_input_as_handled()


# ==========================================
# ABRIR EJERCICIO
# ==========================================

func abrir_ejercicio() -> void:

	if ventana_ejercicio == null:
		push_error(
			"E3.2: falta la ventana del ejercicio."
		)
		return

	if ejercicio_completado:
		return

	if ejercicio_abierto:
		return

	ejercicio_abierto = true

	actualizar_indicadores()

	congelar_jugador()

	ventana_ejercicio.show()

	# Preparar la ventana si tiene este metodo.
	if ventana_ejercicio.has_method("iniciar_ejercicio"):
		ventana_ejercicio.call("iniciar_ejercicio")

	print("E3.2: ventana de ejercicio abierta.")


# ==========================================
# CERRAR EJERCICIO
# ==========================================

func cerrar_ejercicio() -> void:

	if ejercicio_completado:
		return

	ejercicio_abierto = false

	if ventana_ejercicio != null:
		ventana_ejercicio.hide()

	descongelar_jugador()

	actualizar_indicadores()

	print("E3.2: ventana de ejercicio cerrada.")


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

	actualizar_indicadores()

	descongelar_jugador()

	print("E3.2: ejercicio completado.")
	print("E3.2: indicadores desactivados.")


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
