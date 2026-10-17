
extends PanelContainer

# =====================================
# NIVEL 3 - EJERCICIO E3.1
# LA CONSOLA DE ACCESO
# PANTALLA DE COMPLETADO
# =====================================


# =====================================
# REFERENCIAS
# =====================================

@onready var nombre_nivel: Label = $ContenidoCompletado/Encabezado/NombreNivel

@onready var puntos_totales_label: Label = $ContenidoCompletado/Encabezado/PuntosTotales

@onready var titulo_completado: Label = $ContenidoCompletado/TituloCompletado

@onready var nombre_ejercicio: Label = $ContenidoCompletado/NombreEjercicio

@onready var mensaje_exito: Label = $ContenidoCompletado/MensajeExito

@onready var puntos_label: Label = $ContenidoCompletado/PuntosObtenidos

@onready var errores_label: Label = $ContenidoCompletado/ErroresCometidos

@onready var boton_continuar: Button = $ContenidoCompletado/BotonContinuar

@onready var consola = get_node_or_null("../../InteraccionConsola")

@onready var puerta = get_node_or_null("../../PuertaSeguridad")


# =====================================
# VARIABLES
# =====================================

var puntos_ganados: int = 0
var errores_cometidos: int = 0
var resultados_mostrados: bool = false


# =====================================
# INICIO
# =====================================

func _ready() -> void:

	hide()

	# Preparar textos
	nombre_nivel.text = "NIVEL 3"

	titulo_completado.text = "¡EJERCICIO COMPLETADO!"

	nombre_ejercicio.text = "E3.1 - LA CONSOLA DE ACCESO"

	mensaje_exito.text = (
		"¡Has superado el sistema de seguridad " +
		"del laboratorio!"
	)

	boton_continuar.text = "CONTINUAR"

	# Conectar botón una sola vez
	if not boton_continuar.pressed.is_connected(
		continuar_juego
	):
		boton_continuar.pressed.connect(
			continuar_juego
		)

	print("E3.1: pantalla de completado preparada.")


# =====================================
# MOSTRAR PANTALLA DE COMPLETADO
# =====================================

func mostrar_completado(errores: int) -> void:

	# Evitar registrar puntos dos veces
	if resultados_mostrados:
		show()
		return

	resultados_mostrados = true

	errores_cometidos = errores

	# Calcular puntos según errores
	if errores <= 1:

		puntos_ganados = 60

	elif errores == 2:

		puntos_ganados = 45

	else:

		puntos_ganados = 30

	# Registrar puntos del ejercicio E3.1
	PuntajesNivel3.registrar_ejercicio(
		"E3.1",
		puntos_ganados
	)

	# Mostrar puntos obtenidos
	puntos_label.text = (
		"★ PUNTOS GANADOS: +" +
		str(puntos_ganados)
	)

	# Mostrar errores cometidos
	errores_label.text = (
		"ERRORES COMETIDOS: " +
		str(errores_cometidos)
	)

	# Mostrar puntos totales del Nivel 3
	puntos_totales_label.text = (
		"★ PUNTOS TOTALES: " +
		str(PuntajesNivel3.puntos_totales)
	)

	# Mostrar pantalla
	show()

	print("¡Ejercicio E3.1 completado!")
	print("Puntos ganados: ", puntos_ganados)
	print("Errores cometidos: ", errores_cometidos)
	print(
		"Puntos totales Nivel 3: ",
		PuntajesNivel3.puntos_totales
	)


# =====================================
# COMPATIBILIDAD CON OTROS SCRIPTS
# =====================================

func mostrar_resultados(errores: int) -> void:

	mostrar_completado(errores)


# =====================================
# BOTÓN CONTINUAR
# =====================================

func continuar_juego() -> void:

	# Ocultar pantalla
	hide()

	# Asegurar que el ejercicio esté cerrado
	if consola != null:

		if consola.has_method("cerrar_ejercicio"):
			consola.cerrar_ejercicio()

	# Desbloquear puerta de seguridad
	if puerta != null:

		if puerta.has_method("desbloquear_puerta"):

			puerta.desbloquear_puerta()

			print(
				"E3.1: puerta de seguridad desbloqueada."
			)

		else:

			push_warning(
				"E3.1: PuertaSeguridad no tiene " +
				"desbloquear_puerta()."
			)

	else:

		push_warning(
			"E3.1: no se encontró PuertaSeguridad."
		)
