
extends PanelContainer

# ==========================================
# MGTS - NIVEL 3 - E3.1
# LA CONSOLA DE ACCESO
# CONSTRUCCION PARCIAL
# ==========================================

signal ejercicio_resuelto(errores: int)

const CODIGO_EJERCICIO: String = "E3.1"
const PUNTOS_POR_BLOQUE: int = 60
const CANTIDAD_ESPACIOS: int = 4

# Cada respuesta correcta ocupa un espacio.
const RESPUESTA_CORRECTA: Array[int] = [1, 3, 5, 7]

# 8 opciones: cuatro correctas y cuatro distractores.
const OPCIONES: Array[String] = [
	"",
	"while intentos < 3 and not codigo_valido:",
	"while intentos < 3 or not codigo_valido:",
	"    if codigo == \"MGTS\":",
	"    if codigo = \"MGTS\":",
	"        intentos = intentos + 1",
	"        intentos = intentos - 1",
	"if codigo_valido:",
	"if not codigo_valido:"
]

# Tipos de error asociados a los distractores.
const TIPOS_ERROR: Dictionary = {
	2: "Condicion de parada",
	4: "Comparacion",
	6: "Actualizacion del contador",
	8: "Condicion de resultado"
}

const PISTAS: Dictionary = {
	2: "El ciclo debe terminar si se agotan los intentos o si el codigo es correcto.",
	4: "Para comparar dos valores se utiliza un operador diferente al de asignacion.",
	6: "Cada intento fallido debe acercar el contador a su limite.",
	8: "Revisa cuando corresponde conceder el acceso."
}


# ==========================================
# REFERENCIAS
# ==========================================


@onready var titulo: Label = $ContenidoEjercicio/FilaTitulo/TituloEjercicio

@onready var lista_bloques: VBoxContainer = $ContenidoEjercicio/ColumnasEjercicio/PanelBloques/BloquesDisponibles/ListaBloques


@onready var lista_algoritmo: VBoxContainer = (
	$ContenidoEjercicio/ColumnasEjercicio/AreaAlgoritmo/PanelAlgoritmo/ListaAlgoritmo
)

@onready var mensaje_vacio: Label = (
	$ContenidoEjercicio/ColumnasEjercicio/AreaAlgoritmo/PanelAlgoritmo/ListaAlgoritmo/MensajeVacio
)

@onready var boton_limpiar: Button = (
	$ContenidoEjercicio/BotonesEjercicio/BotonLimpiar
)

@onready var boton_comprobar: Button = (
	$ContenidoEjercicio/BotonesEjercicio/BotonComprobar
)

@onready var boton_cerrar: Button = (
	$ContenidoEjercicio/BotonesEjercicio/BotonCerrar
)

@onready var mensaje_resultado: Label = (
	$ContenidoEjercicio/MensajeResultado
)

@onready var consola: Node = (
	get_node_or_null("../../InteraccionConsola")
)

@onready var ventana_completado: Node = (
	get_node_or_null("../../CompletadoUI/VentanaCompletado")
)


@onready var instrucciones: Label = $ContenidoEjercicio/FilaInstrucciones/InstruccionesEjercicio

@onready var panel_pista: PanelContainer = $ContenidoEjercicio/FilaInstrucciones/PanelPista

@onready var texto_pista: Label = $ContenidoEjercicio/FilaInstrucciones/PanelPista/ContenidoPista/TextoPista

# ==========================================
# VARIABLES
# ==========================================

var bloques_seleccionados: Array[int] = []
var botones_bloques: Array[Button] = []

var errores: int = 0
var ejercicio_terminado: bool = false
var puntos_obtenidos: int = 0



# ==========================================
# INICIO
# ==========================================

func _ready() -> void:

	hide()
	panel_pista.hide()

	titulo.text = "E3.1 - La consola de acceso"

	instrucciones.text = (
		"El laboratorio está bloqueado. Ayuda al Gato Guardián "
		+ "a abrir el camino hacia Panko.\n"
		+ "Completa las 4 líneas del algoritmo para verificar "
		+ "el código MGTS en un máximo de 3 intentos."
	)

	mensaje_resultado.text = ""
	mensaje_resultado.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	# Preparar los ocho botones existentes.
	for numero in range(1, 9):

		var boton: Button = (
			lista_bloques.get_node_or_null(
				"Bloque" + str(numero)
			) as Button
		)

		if boton == null:
			push_warning(
				"E3.1: falta Bloque" + str(numero)
			)
			continue

		botones_bloques.append(boton)

		boton.text = OPCIONES[numero]

		boton.add_theme_font_size_override(
			"font_size", 14
		)

		boton.pressed.connect(
			seleccionar_bloque.bind(numero)
		)

	if not boton_limpiar.pressed.is_connected(
		limpiar_algoritmo
	):
		boton_limpiar.pressed.connect(
			limpiar_algoritmo
		)

	if not boton_comprobar.pressed.is_connected(
		comprobar_algoritmo
	):
		boton_comprobar.pressed.connect(
			comprobar_algoritmo
		)

	if not boton_cerrar.pressed.is_connected(
		cerrar_ventana
	):
		boton_cerrar.pressed.connect(
			cerrar_ventana
		)

	actualizar_algoritmo()

	print("E3.1: ejercicio preparado.")


func mostrar_pista() -> void:
	if errores == 1:
		texto_pista.text = (
			"Piensa que condiciones deben cumplirse "
			+ "para que la consola siga solicitando codigos."
		)
	elif errores == 2:
		texto_pista.text = (
			"Revisa el uso de 'and' y 'or'. "
			+ "Cual permite detener el ciclo "
			+ "cuando una condicion deja de cumplirse?"
		)
	else:
		texto_pista.text = (
			"Comprueba las condiciones del ciclo, "
			+ "la comparacion del codigo y "
			+ "la actualizacion de intentos."
		)

	panel_pista.show()


# ==========================================
# INICIAR EJERCICIO
# ==========================================

func iniciar_ejercicio() -> void:

	if ejercicio_terminado:
		return

	mensaje_resultado.text = ""
	actualizar_algoritmo()


# ==========================================
# SELECCIONAR BLOQUE
# ==========================================

func seleccionar_bloque(numero: int) -> void:

	if ejercicio_terminado:
		return

	if bloques_seleccionados.size() >= CANTIDAD_ESPACIOS:
		mostrar_mensaje(
			"Ya completaste los 4 espacios. "
			+ "Comprueba o limpia para cambiar.",
			Color("#FFD477")
		)
		return

	if bloques_seleccionados.has(numero):
		return

	bloques_seleccionados.append(numero)

	var boton: Button = (
		lista_bloques.get_node_or_null(
			"Bloque" + str(numero)
		) as Button
	)

	if boton != null:
		boton.disabled = true

	mensaje_resultado.text = ""

	actualizar_algoritmo()


# ==========================================
# MOSTRAR CODIGO CON COMENTARIOS
# ==========================================

func actualizar_algoritmo() -> void:

	for hijo in lista_algoritmo.get_children():

		if hijo == mensaje_vacio:
			continue

		lista_algoritmo.remove_child(hijo)
		hijo.queue_free()

	mensaje_vacio.hide()

	agregar_linea("intentos = 0")
	agregar_linea("codigo_valido = False")

	agregar_espacio(0)

	agregar_linea("    codigo = input()")

	agregar_espacio(1)

	agregar_linea(
		"        codigo_valido = True"
	)

	agregar_linea("    else:")

	agregar_espacio(2)

	agregar_espacio(3)

	agregar_linea(
		"    print(\"Acceso concedido\")"
	)

	agregar_linea("else:")

	agregar_linea(
		"    print(\"Acceso bloqueado\")"
	)


# ==========================================
# AGREGAR LINEAS DE CODIGO
# ==========================================

func agregar_linea(
	contenido: String,
	color: Color = Color("#DCE9FA")
) -> void:

	var linea: Label = Label.new()

	linea.text = contenido

	linea.add_theme_color_override(
		"font_color", color
	)

	linea.add_theme_font_size_override(
		"font_size", 14
	)

	linea.autowrap_mode = (
		TextServer.AUTOWRAP_OFF
	)

	lista_algoritmo.add_child(linea)


# ==========================================
# AGREGAR ESPACIOS PARA COMPLETAR
# ==========================================

func agregar_espacio(indice: int) -> void:

	var contenido: String = (
		"[ Espacio " + str(indice + 1) + " ]"
	)

	if indice < bloques_seleccionados.size():

		var numero: int = (
			bloques_seleccionados[indice]
		)

		contenido = OPCIONES[numero]

	var espacio: Label = Label.new()

	espacio.text = contenido

	espacio.add_theme_font_size_override(
		"font_size", 14
	)

	espacio.add_theme_color_override(
		"font_color", Color("#DCC6FF")
	)

	var estilo: StyleBoxFlat = StyleBoxFlat.new()

	estilo.bg_color = Color("#243453")
	estilo.border_color = Color("#9D83EA")

	estilo.set_border_width_all(1)
	estilo.set_corner_radius_all(6)
	estilo.set_content_margin_all(8)

	espacio.add_theme_stylebox_override(
		"normal", estilo
	)

	lista_algoritmo.add_child(espacio)


# ==========================================
# LIMPIAR ALGORITMO
# ==========================================

func limpiar_algoritmo() -> void:

	if ejercicio_terminado:
		return

	bloques_seleccionados.clear()

	for boton in botones_bloques:
		boton.disabled = false

	mensaje_resultado.text = ""

	actualizar_algoritmo()


# ==========================================
# COMPROBAR RESPUESTA
# ==========================================

func comprobar_algoritmo() -> void:

	if ejercicio_terminado:
		return

	if bloques_seleccionados.size() != CANTIDAD_ESPACIOS:
		mostrar_mensaje(
			"Completa los 4 espacios antes de comprobar.",
			Color("#FFD477")
		)
		return

	if bloques_seleccionados == RESPUESTA_CORRECTA:

		completar_ejercicio()
		return

	# Detectar el primer error encontrado.
	for indice in range(CANTIDAD_ESPACIOS):

		var elegido: int = (
			bloques_seleccionados[indice]
		)

		var esperado: int = (
			RESPUESTA_CORRECTA[indice]
		)

		if elegido == esperado:
			continue

		if TIPOS_ERROR.has(elegido):

			registrar_error(
				TIPOS_ERROR[elegido],
				PISTAS[elegido]
			)

		else:

			registrar_error(
				"Orden de instrucciones",
				"Revisa que cada instruccion "
				+ "este ubicada en el bloque "
				+ "de control correspondiente."
			)

		return


# ==========================================
# REGISTRAR ERROR
# ==========================================

func registrar_error(
	tipo: String,
	pista: String
) -> void:

	errores += 1
	mostrar_pista()
	var texto: String = (
		"Error: " + tipo + ".\n"
		+ "Pista: " + pista
	)

	if errores == 1:
		texto += "\nPrimer error: sin penalizacion."

	elif errores == 2:
		texto += "\nPenalizacion actual: 25%."

	else:
		texto += "\nPenalizacion actual: 50%."

	print("E3.1: error ", errores, " - ", tipo)


# ==========================================
# MOSTRAR RETROALIMENTACION
# ==========================================

func mostrar_mensaje(
	texto: String,
	color: Color
) -> void:

	mensaje_resultado.text = texto

	mensaje_resultado.add_theme_color_override(
		"font_color", color
	)


# ==========================================
# CALCULAR PUNTOS
# ==========================================

func calcular_puntos() -> int:

	var base: int = (
		CANTIDAD_ESPACIOS * PUNTOS_POR_BLOQUE
	)

	if errores >= 3:
		return int(base * 0.50)

	if errores == 2:
		return int(base * 0.75)

	return base


# ==========================================
# COMPLETAR EJERCICIO
# ==========================================

func completar_ejercicio() -> void:
	if ejercicio_terminado:
		return

	ejercicio_terminado = true
	puntos_obtenidos = calcular_puntos()

	for boton in botones_bloques:
		boton.disabled = true

	boton_limpiar.disabled = true
	boton_comprobar.disabled = true

	mostrar_mensaje(
		"Acceso concedido. Ganaste "
		+ str(puntos_obtenidos)
		+ " puntos.",
		Color("#80E6B7")
	)

	# Conservar la señal original.
	ejercicio_resuelto.emit(errores)

	# Registrar los puntos una sola vez.
	var sistema_puntos: Node = get_node_or_null("/root/PuntajesNivel3")
	if sistema_puntos != null and sistema_puntos.has_method("registrar_ejercicio"):
		sistema_puntos.call(
			"registrar_ejercicio",
			CODIGO_EJERCICIO,
			puntos_obtenidos
		)
	else:
		push_warning("E3.1: no se encontro el Autoload PuntajesNivel3.")

	# Informar a la consola que el ejercicio se completo.
	if consola != null and consola.has_method("completar_ejercicio"):
		consola.call("completar_ejercicio")

	hide()

	# Mostrar la ventana de completado sin cambiar su interfaz.
	if ventana_completado != null and ventana_completado.has_method("mostrar_completado"):
		ventana_completado.call("mostrar_completado", errores)

	print("E3.1 completado. Puntos: ", puntos_obtenidos)


# ==========================================
# CERRAR VENTANA
# ==========================================

func cerrar_ventana() -> void:

	if ejercicio_terminado:
		return

	if consola != null:

		if consola.has_method(
			"cerrar_ejercicio"
		):

			consola.call(
				"cerrar_ejercicio"
			)

	hide()
