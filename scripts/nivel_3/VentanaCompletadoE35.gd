
extends PanelContainer

# ==========================================
# MGTS - NIVEL 3 - EJERCICIO E3.5
# CONDUCTOS DE VENTILACION
# VENTANA DE COMPLETADO
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
			"E3.5 - Conductos de Ventilación"
		)

	if mensaje_exito != null:
		mensaje_exito.text = (
			"¡Excelente trabajo!\n"
			+ "Has restaurado el sistema de ventilación."
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
		push_error("E3.5: falta BotonContinuar.")

	actualizar_puntos_totales()

	print("E3.5: ventana de completado preparada.")


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
					"E3.5",
					puntos_ganados
				)

				print(
					"E3.5: puntos registrados: ",
					puntos_ganados
				)

			else:
				push_warning(
					"E3.5: falta registrar_ejercicio() "
					+ "en PuntajesNivel3."
				)

		else:
			push_warning(
				"E3.5: no se encontró PuntajesNivel3."
			)

	# Mostrar los resultados
	if puntos_obtenidos != null:

		puntos_obtenidos.text = (
			"Puntos obtenidos: "
			+ str(puntos_ganados)
		)

	if errores_cometidos != null:

		errores_cometidos.text = (
			"Errores cometidos: "
			+ str(cantidad_errores)
		)

	if mensaje_exito != null:

		mensaje_exito.text = (
			"¡Ventilación restaurada!\n"
			+ "Los conductos del laboratorio "
			+ "vuelven a funcionar correctamente."
		)

	actualizar_puntos_totales()

	show()

	print("E3.5: ejercicio completado.")
	print("Puntos obtenidos: ", puntos_ganados)
	print("Errores cometidos: ", cantidad_errores)


# ==========================================
# CALCULAR PUNTOS
# ==========================================

# Muestra los puntos que de verdad se acreditaron (base - penalización + bono de racha),
# calculados con las reglas compartidas de GameData. Si el ejercicio no se acreditó en esta
# sesión (repetición), se usa el valor de referencia sin bono.
func calcular_puntos(errores: int) -> int:
	var base: int = 240 - GameData.errorPenalty(240, errores)
	return GameData.creditedPoints("E3.5", base)


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

	# Buscar una función para el total acumulado
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

		# Alternativa si el Autoload tiene
		# una variable llamada puntos_totales
		var valor: Variant = sistema_puntos.get(
			"puntos_totales"
		)

		if valor != null:

			total = int(valor)
			total_encontrado = true

	if total_encontrado:

		puntos_totales.text = (
			"Puntos totales: "
			+ str(total)
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

	# Desbloquear la puerta de seguridad
	if puerta_seguridad != null:

		if puerta_seguridad.has_method(
			"desbloquear_puerta"
		):

			puerta_seguridad.call(
				"desbloquear_puerta"
			)

			print(
				"E3.5: puerta de seguridad desbloqueada."
			)

		else:

			push_warning(
				"E3.5: PuertaSeguridad no tiene "
				+ "desbloquear_puerta()."
			)

	else:

		push_warning(
			"E3.5: no se encontró PuertaSeguridad."
		)

	print(
		"E3.5: jugador puede continuar hacia E3.6."
	)
