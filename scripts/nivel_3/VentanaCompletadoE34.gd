
extends PanelContainer

# ==========================================
# MGTS - NIVEL 3 - EJERCICIO E3.4
# SISTEMA DE ENFRIAMIENTO
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
			"E3.4 - Sistema de Enfriamiento"
		)

	if mensaje_exito != null:
		mensaje_exito.text = (
			"¡Excelente trabajo!\n"
			+ "Has estabilizado la temperatura del laboratorio."
		)

	if puntos_obtenidos != null:
		puntos_obtenidos.text = "Puntos obtenidos: 0"

	if errores_cometidos != null:
		errores_cometidos.text = "Errores cometidos: 0"

	if boton_continuar != null:
		boton_continuar.text = "Continuar"

		if not boton_continuar.pressed.is_connected(continuar_juego):
			boton_continuar.pressed.connect(continuar_juego)
	else:
		push_error("E3.4: falta BotonContinuar.")

	actualizar_puntos_totales()

	print("E3.4: ventana de completado preparada.")


# ==========================================
# MOSTRAR RESULTADOS
# ==========================================

func mostrar_completado(errores: int) -> void:

	cantidad_errores = errores
	puntos_ganados = calcular_puntos(errores)

	# Registrar el ejercicio una sola vez
	if not ejercicio_completado:

		ejercicio_completado = true

		if sistema_puntos != null:

			if sistema_puntos.has_method("registrar_ejercicio"):

				sistema_puntos.call(
					"registrar_ejercicio",
					"E3.4",
					puntos_ganados
				)

				print(
					"E3.4: puntos registrados: ",
					puntos_ganados
				)

			else:
				push_warning(
					"E3.4: PuntajesNivel3 no tiene registrar_ejercicio()."
				)

		else:
			push_warning(
				"E3.4: no se encontró el Autoload PuntajesNivel3."
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
			"¡Sistema de enfriamiento estabilizado!\n"
			+ "La temperatura del laboratorio "
			+ "ha descendido a un nivel seguro (18 °C)."
		)

	actualizar_puntos_totales()

	show()

	print("E3.4: ejercicio completado.")
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
	return GameData.creditedPoints("E3.4", base)


# ==========================================
# ACTUALIZAR PUNTOS TOTALES
# ==========================================

func actualizar_puntos_totales() -> void:

	if puntos_totales == null:
		return

	if sistema_puntos == null:
		puntos_totales.text = "Puntos totales: --"
		return

	# No llamamos obtener_puntos() sin argumentos,
	# porque en tu sistema esa función requiere uno.
	var total: int = 0
	var total_encontrado: bool = false

	if sistema_puntos.has_method("obtener_total_nivel"):

		total = int(
			sistema_puntos.call("obtener_total_nivel")
		)

		total_encontrado = true

	elif sistema_puntos.has_method("obtener_puntos_totales"):

		total = int(
			sistema_puntos.call("obtener_puntos_totales")
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
			"Puntos totales: "
			+ str(total)
		)

	else:

		# Evita mostrar un total inventado.
		puntos_totales.text = "Puntos totales: --"


# ==========================================
# BOTON CONTINUAR
# ==========================================

func continuar_juego() -> void:

	if not ejercicio_completado:
		return

	hide()

	# Asegurar que la ventana del ejercicio esté cerrada
	if consola != null:

		if consola.has_method("cerrar_ejercicio"):
			consola.call("cerrar_ejercicio")

	# Desbloquear la puerta
	if puerta_seguridad != null:

		if puerta_seguridad.has_method("desbloquear_puerta"):

			puerta_seguridad.call(
				"desbloquear_puerta"
			)

			print(
				"E3.4: puerta desbloqueada."
			)

		else:

			push_warning(
				"E3.4: PuertaSeguridad no tiene desbloquear_puerta()."
			)

	else:

		push_warning(
			"E3.4: no se encontró PuertaSeguridad."
		)

	print("E3.4: jugador puede continuar hacia E3.5.")
