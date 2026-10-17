
extends PanelContainer

# ==========================================
# MGTS - NIVEL 3 - EJERCICIO E3.9
# SALA DEL SERVIDOR CENTRAL
# VENTANA DE COMPLETADO
# NPC: GATO HOLOGRAFICO
# ==========================================

# ==========================================
# REFERENCIAS
# ==========================================

@onready var nombre_nivel: Label = get_node_or_null(
	"ContenidoCompletado/Encabezado/NombreNivel"
) as Label

@onready var puntos_totales: Label = get_node_or_null(
	"ContenidoCompletado/Encabezado/PuntosTotales"
) as Label

@onready var icono_trofeo: TextureRect = get_node_or_null(
	"ContenidoCompletado/IconoTrofeo"
) as TextureRect

@onready var titulo_completado: Label = get_node_or_null(
	"ContenidoCompletado/TituloCompletado"
) as Label

@onready var nombre_ejercicio: Label = get_node_or_null(
	"ContenidoCompletado/NombreEjercicio"
) as Label

@onready var mensaje_exito: Label = get_node_or_null(
	"ContenidoCompletado/MensajeExito"
) as Label

@onready var puntos_obtenidos: Label = get_node_or_null(
	"ContenidoCompletado/PuntosObtenidos"
) as Label

@onready var errores_cometidos: Label = get_node_or_null(
	"ContenidoCompletado/ErroresCometidos"
) as Label

@onready var boton_continuar: Button = get_node_or_null(
	"ContenidoCompletado/BotonContinuar"
) as Button

@onready var puerta_seguridad: Node = get_node_or_null(
	"../../PuertaSeguridad"
)

@onready var consola: Node = get_node_or_null(
	"../../InteraccionConsola"
)

@onready var sistema_puntos: Node = get_node_or_null(
	"/root/PuntajesNivel3"
)

# ==========================================
# VARIABLES
# ==========================================

var ejercicio_completado: bool = false
var puntos_ganados: int = 0
var cantidad_errores: int = 0

# ==========================================
# INICIO
# ==========================================

func _ready() -> void:

	hide()

	if nombre_nivel != null:
		nombre_nivel.text = "NIVEL 3"

	if titulo_completado != null:
		titulo_completado.text = "¡EJERCICIO COMPLETADO!"

	if nombre_ejercicio != null:
		nombre_ejercicio.text = (
			"E3.9 - Las señales del servidor central"
		)

	if mensaje_exito != null:
		mensaje_exito.text = (
			"¡Excelente trabajo!\n"
			+ "Has identificado las señales dañadas."
		)

	if puntos_obtenidos != null:
		puntos_obtenidos.text = "Puntos obtenidos: 0"

	if errores_cometidos != null:
		errores_cometidos.text = "Errores cometidos: 0"

	if boton_continuar != null:

		boton_continuar.text = "Continuar"

		if not boton_continuar.pressed.is_connected(
			continuar_juego
		):
			boton_continuar.pressed.connect(
				continuar_juego
			)

	else:
		push_error("E3.9: falta BotonContinuar.")

	actualizar_puntos_totales()

	print("E3.9: ventana de completado preparada.")

# ==========================================
# MOSTRAR RESULTADOS
# ==========================================

func mostrar_completado(errores: int) -> void:

	cantidad_errores = errores

	# Registrar puntos solo la primera vez
	if not ejercicio_completado:

		ejercicio_completado = true
		puntos_ganados = calcular_puntos(errores)

		if sistema_puntos != null:

			if sistema_puntos.has_method(
				"registrar_ejercicio"
			):

				sistema_puntos.call(
					"registrar_ejercicio",
					"E3.9",
					puntos_ganados
				)

				print(
					"E3.9: puntos registrados: ",
					puntos_ganados
				)

			else:
				push_warning(
					"E3.9: falta registrar_ejercicio() "
					+ "en PuntajesNivel3."
				)

		else:
			push_warning(
				"E3.9: no se encontró PuntajesNivel3."
			)

	# Mostrar puntos obtenidos
	if puntos_obtenidos != null:
		puntos_obtenidos.text = (
			"Puntos obtenidos: "
			+ str(puntos_ganados)
		)

	# Mostrar errores
	if errores_cometidos != null:
		errores_cometidos.text = (
			"Errores cometidos: "
			+ str(cantidad_errores)
		)

	# Mensaje de éxito
	if mensaje_exito != null:
		mensaje_exito.text = (
			"¡Servidor central estabilizado!\n"
			+ "El Gato Holográfico confirma que "
			+ "las señales dañadas fueron detectadas."
		)

	actualizar_puntos_totales()

	show()

	print("E3.9: ejercicio completado.")
	print("Puntos obtenidos: ", puntos_ganados)
	print("Errores cometidos: ", cantidad_errores)

# ==========================================
# CALCULAR PUNTOS
# ==========================================

func calcular_puntos(errores: int) -> int:

	if errores <= 1:
		return 60
	elif errores == 2:
		return 45
	else:
		return 30

# ==========================================
# ACTUALIZAR PUNTOS TOTALES
# ==========================================

func actualizar_puntos_totales() -> void:

	if puntos_totales == null:
		return

	if sistema_puntos == null:
		puntos_totales.text = "Puntos totales: --"
		return

	var total: int = 0
	var total_encontrado: bool = false

	if sistema_puntos.has_method(
		"obtener_total_nivel"
	):

		total = int(
			sistema_puntos.call(
				"obtener_total_nivel"
			)
		)

		total_encontrado = true

	elif sistema_puntos.has_method(
		"obtener_puntos_totales"
	):

		total = int(
			sistema_puntos.call(
				"obtener_puntos_totales"
			)
		)

		total_encontrado = true

	else:

		var valor: Variant = sistema_puntos.get(
			"puntos_totales"
		)

		if valor != null:
			total = int(valor)
			total_encontrado = true

	if total_encontrado:
		puntos_totales.text = (
			"Puntos totales: " + str(total)
		)
	else:
		puntos_totales.text = "Puntos totales: --"

# ==========================================
# BOTON CONTINUAR
# ==========================================

func continuar_juego() -> void:

	if not ejercicio_completado:
		return

	hide()

	# Cerrar la ventana del ejercicio
	if consola != null:

		if consola.has_method(
			"cerrar_ejercicio"
		):
			consola.call(
				"cerrar_ejercicio"
			)

	# Desbloquear puerta de seguridad
	if puerta_seguridad != null:

		if puerta_seguridad.has_method(
			"desbloquear_puerta"
		):

			puerta_seguridad.call(
				"desbloquear_puerta"
			)

			print(
				"E3.9: puerta de seguridad desbloqueada."
			)

		else:
			push_warning(
				"E3.9: PuertaSeguridad no tiene "
				+ "desbloquear_puerta()."
			)

	else:
		push_warning(
			"E3.9: no se encontró PuertaSeguridad."
		)

	print("E3.9: acceso hacia E3.10 habilitado.")
