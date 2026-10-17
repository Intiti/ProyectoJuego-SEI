
extends Area2D

# ==========================================
# MGTS - NIVEL 3 - EJERCICIO E3.1
# INTERACCION CON LA CONSOLA
# ==========================================

signal solicitar_abrir_ejercicio


# ==========================================
# REFERENCIAS
# ==========================================

@onready var jugador: CharacterBody2D = (
	get_node_or_null("../Player") as CharacterBody2D
)

@onready var letra_e: Label = (
	get_node_or_null("LetraE") as Label
)

@onready var indicador_objetivo: Label = (
	get_node_or_null("IndicadorObjetivo") as Label
)

# Pantalla real del ejercicio E3.1.
@onready var pantalla_ejercicio: CanvasLayer = (
	get_node_or_null("../EjercicioUI") as CanvasLayer
)

# Ventana que contiene los bloques.
@onready var ventana_ejercicio: Control = (
	get_node_or_null(
		"../EjercicioUI/VentanaEjercicio"
	) as Control
)


# ==========================================
# VARIABLES
# ==========================================

var jugador_cerca: bool = false

var objetivo_activado: bool = false
var objetivo_completado: bool = false
var ejercicio_abierto: bool = false

var fisica_jugador_activa: bool = true


# ==========================================
# INICIO
# ==========================================

func _ready() -> void:

	monitoring = true

	objetivo_activado = false
	objetivo_completado = false
	ejercicio_abierto = false

	# Ocultar indicadores al iniciar.
	actualizar_indicadores()

	# Ocultar la pantalla del ejercicio.
	if pantalla_ejercicio != null:
		pantalla_ejercicio.hide()

	# Conectar deteccion del jugador.
	if not body_entered.is_connected(_cuando_entra):
		body_entered.connect(_cuando_entra)

	if not body_exited.is_connected(_cuando_sale):
		body_exited.connect(_cuando_sale)

	# Comprobar referencias.
	if jugador == null:
		push_error(
			"E3.1: no se encontro Player."
		)

	if letra_e == null:
		push_warning(
			"E3.1: no se encontro LetraE."
		)

	if indicador_objetivo == null:
		push_warning(
			"E3.1: no se encontro IndicadorObjetivo."
		)

	if pantalla_ejercicio == null:
		push_error(
			"E3.1: no se encontro EjercicioUI."
		)

	if ventana_ejercicio == null:
		push_warning(
			"E3.1: no se encontro VentanaEjercicio."
		)

	print("E3.1: consola preparada.")


# ==========================================
# ACTIVAR OBJETIVO DESPUES DEL DIALOGO
# ==========================================

func mostrar_objetivo() -> void:

	if objetivo_completado:
		return

	objetivo_activado = true

	actualizar_indicadores()

	print(
		"E3.1: objetivo activado despues del dialogo."
	)


# ==========================================
# ACTUALIZAR LOS INDICADORES ! Y E
# ==========================================

func actualizar_indicadores() -> void:

	var disponible: bool = (
		objetivo_activado
		and not objetivo_completado
		and not ejercicio_abierto
	)

	# Mostrar ! cuando el jugador esta lejos.
	if indicador_objetivo != null:

		indicador_objetivo.visible = (
			disponible
			and not jugador_cerca
		)

	# Mostrar E cuando el jugador esta cerca.
	if letra_e != null:

		letra_e.visible = (
			disponible
			and jugador_cerca
		)


# ==========================================
# JUGADOR ENTRA EN EL AREA
# ==========================================

func _cuando_entra(cuerpo: Node2D) -> void:

	if cuerpo != jugador:
		return

	jugador_cerca = true

	actualizar_indicadores()


# ==========================================
# JUGADOR SALE DEL AREA
# ==========================================

func _cuando_sale(cuerpo: Node2D) -> void:

	if cuerpo != jugador:
		return

	jugador_cerca = false

	actualizar_indicadores()


# ==========================================
# DETECTAR TECLA E
# ==========================================

func _unhandled_key_input(
	event: InputEvent
) -> void:

	if not event is InputEventKey:
		return

	if not event.pressed or event.echo:
		return

	if event.keycode != KEY_E:
		return

	if not jugador_cerca:
		return

	if not objetivo_activado:
		return

	if objetivo_completado:
		return

	if ejercicio_abierto:
		return

	abrir_ejercicio()

	get_viewport().set_input_as_handled()


# ==========================================
# ABRIR PANTALLA DEL EJERCICIO E3.1
# ==========================================

func abrir_ejercicio() -> void:

	if ejercicio_abierto:
		return

	if not objetivo_activado:
		return

	if objetivo_completado:
		return

	if pantalla_ejercicio == null:
		push_error(
			"E3.1: no existe EjercicioUI."
		)
		return

	ejercicio_abierto = true

	# Ocultar ! y E.
	actualizar_indicadores()

	# Congelar al protagonista.
	congelar_jugador()

	# Mostrar la interfaz.
	pantalla_ejercicio.show()

	# Mostrar la ventana de los bloques.
	if ventana_ejercicio != null:
		ventana_ejercicio.show()

	# Mantener compatibilidad con otras
	# conexiones del ejercicio.
	solicitar_abrir_ejercicio.emit()

	print(
		"E3.1: pantalla del ejercicio abierta."
	)


# ==========================================
# CONGELAR JUGADOR
# ==========================================

func congelar_jugador() -> void:

	if jugador == null:
		return

	fisica_jugador_activa = (
		jugador.is_physics_processing()
	)

	jugador.velocity = Vector2.ZERO

	jugador.set_physics_process(false)


# ==========================================
# DESCONGELAR JUGADOR
# ==========================================

func descongelar_jugador() -> void:

	if jugador == null:
		return

	jugador.set_physics_process(
		fisica_jugador_activa
	)


# ==========================================
# CERRAR EJERCICIO SIN COMPLETAR
# ==========================================

func cerrar_ejercicio() -> void:

	if not ejercicio_abierto:
		return

	ejercicio_abierto = false

	# Ocultar pantalla.
	if pantalla_ejercicio != null:
		pantalla_ejercicio.hide()

	# Permitir movimiento.
	descongelar_jugador()

	# Mostrar E o ! segun la distancia.
	actualizar_indicadores()

	print(
		"E3.1: ejercicio cerrado sin completar."
	)


# ==========================================
# EJERCICIO COMPLETADO
# ==========================================

func completar_ejercicio() -> void:

	objetivo_completado = true
	objetivo_activado = false
	ejercicio_abierto = false

	# Ocultar la pantalla.
	if pantalla_ejercicio != null:
		pantalla_ejercicio.hide()

	# Devolver movimiento.
	descongelar_jugador()

	# Ocultar definitivamente ! y E.
	actualizar_indicadores()

	print(
		"E3.1: ejercicio completado."
	)


# ==========================================
# OCULTAR OBJETIVO
# ==========================================

func ocultar_objetivo() -> void:

	completar_ejercicio()
