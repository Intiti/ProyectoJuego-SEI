
extends PanelContainer

# ==========================================
# MGTS - NIVEL 3 - E3.5
# CONDUCTOS DE VENTILACION
# GATO MECANICO
# ==========================================

signal ejercicio_resuelto(errores: int)

const CODIGO_EJERCICIO: String = "E3.5"
const PUNTOS_POR_BLOQUE: int = 60
const TOTAL_ESPACIOS: int = 4


# ==========================================
# BLOQUES DE PYTHON
# ==========================================

const CODIGO_BLOQUES: Array[String] = [
	"",
	"while indice < len(ventiladores):",
	"while indice > len(ventiladores):",
	"    if ventiladores[indice] == 0:",
	"    if ventiladores[indice] == 1:",
	"        print(\"Activar ventilador\")",
	"        print(\"Apagar ventilador\")",
	"    indice = indice + 1",
	"    indice = indice - 1"
]

const ORDEN_CORRECTO: Array[int] = [1, 3, 5, 7]


# ==========================================
# REFERENCIAS
# ==========================================

@onready var titulo: Label = get_node_or_null(
	"ContenidoEjercicio/FilaTitulo/TituloEjercicio"
) as Label

@onready var instrucciones: Label = get_node_or_null(
	"ContenidoEjercicio/FilaInstrucciones/InstruccionesEjercicio"
) as Label

@onready var panel_pista: PanelContainer = get_node_or_null(
	"ContenidoEjercicio/FilaInstrucciones/PanelPista"
) as PanelContainer

@onready var texto_pista: Label = get_node_or_null(
	"ContenidoEjercicio/FilaInstrucciones/PanelPista/ContenidoPista/TextoPista"
) as Label

@onready var lista_bloques: VBoxContainer = get_node_or_null(
	"ContenidoEjercicio/ColumnasEjercicio/PanelBloques/BloquesDisponibles/ListaBloques"
) as VBoxContainer

@onready var lista_algoritmo: VBoxContainer = get_node_or_null(
	"ContenidoEjercicio/ColumnasEjercicio/AreaAlgoritmo/PanelAlgoritmo/ListaAlgoritmo"
) as VBoxContainer

@onready var mensaje_vacio: Label = get_node_or_null(
	"ContenidoEjercicio/ColumnasEjercicio/AreaAlgoritmo/PanelAlgoritmo/ListaAlgoritmo/MensajeVacio"
) as Label

@onready var boton_limpiar: Button = get_node_or_null(
	"ContenidoEjercicio/BotonesEjercicio/BotonLimpiar"
) as Button

@onready var boton_comprobar: Button = get_node_or_null(
	"ContenidoEjercicio/BotonesEjercicio/BotonComprobar"
) as Button

@onready var boton_cerrar: Button = get_node_or_null(
	"ContenidoEjercicio/BotonesEjercicio/BotonCerrar"
) as Button

@onready var mensaje_resultado: Label = get_node_or_null(
	"ContenidoEjercicio/MensajeResultado"
) as Label

@onready var consola: Node = get_node_or_null(
	"../../InteraccionConsola"
)

@onready var ventana_completado: Node = get_node_or_null(
	"../../CompletadoUI/VentanaCompletado"
)


# ==========================================
# VARIABLES
# ==========================================

var bloques_seleccionados: Array[int] = []
var botones_bloques: Array[Button] = []

var errores: int = 0
var ejercicio_terminado: bool = false
var puntos_obtenidos: int = 0
var referencias_correctas: bool = false


# ==========================================
# INICIO
# ==========================================

func _ready() -> void:

	hide()

	referencias_correctas = comprobar_referencias()

	if not referencias_correctas:
		push_error(
			"E3.5: revisa los nodos de VentanaEjercicio."
		)
		return

	titulo.text = "E3.5 - Conductos de Ventilación"

	instrucciones.text = (
		"El Gato mecánico detectó movimiento que "
		+ "podría ser de Panko en los conductos.\n"
		+ "Pero varios ventiladores están apagados.\n"
		+ "Completa los 4 espacios del algoritmo "
		+ "para revisar los ventiladores y detectar "
		+ "cuáles necesitan activarse."
	)

	instrucciones.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	mensaje_resultado.text = ""
	mensaje_resultado.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	# Preparar panel de pistas.
	panel_pista.show()
	panel_pista.modulate.a = 0.0

	texto_pista.text = ""
	texto_pista.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	# Preparar los ocho botones.
	for numero in range(1, CODIGO_BLOQUES.size()):

		var boton: Button = lista_bloques.get_node_or_null(
			"Bloque" + str(numero)
		) as Button

		if boton == null:
			push_warning(
				"E3.5: falta Bloque" + str(numero)
			)
			continue

		botones_bloques.append(boton)

		boton.text = CODIGO_BLOQUES[numero]
		boton.disabled = false

		boton.add_theme_font_size_override(
			"font_size", 14
		)

		var accion: Callable = seleccionar_bloque.bind(numero)

		if not boton.pressed.is_connected(accion):
			boton.pressed.connect(accion)

	# Conectar botones principales.
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

	print("E3.5: ventana preparada correctamente.")


# ==========================================
# COMPROBAR REFERENCIAS
# ==========================================

func comprobar_referencias() -> bool:

	var correcto: bool = true

	var referencias: Dictionary = {
		"TituloEjercicio": titulo,
		"InstruccionesEjercicio": instrucciones,
		"PanelPista": panel_pista,
		"TextoPista": texto_pista,
		"ListaBloques": lista_bloques,
		"ListaAlgoritmo": lista_algoritmo,
		"MensajeVacio": mensaje_vacio,
		"BotonLimpiar": boton_limpiar,
		"BotonComprobar": boton_comprobar,
		"BotonCerrar": boton_cerrar,
		"MensajeResultado": mensaje_resultado
	}

	for nombre in referencias:

		if referencias[nombre] == null:
			push_error(
				"E3.5: no se encontró el nodo " + nombre
			)
			correcto = false

	return correcto


# ==========================================
# INICIAR EJERCICIO
# ==========================================

func iniciar_ejercicio() -> void:

	if not referencias_correctas:
		return

	if ejercicio_terminado:
		return

	mensaje_resultado.text = ""

	if errores == 0:
		panel_pista.modulate.a = 0.0

	actualizar_algoritmo()

	print("E3.5: ejercicio iniciado.")


# ==========================================
# SELECCIONAR BLOQUE
# ==========================================

func seleccionar_bloque(numero: int) -> void:

	if not referencias_correctas or ejercicio_terminado:
		return

	if bloques_seleccionados.has(numero):
		return

	if bloques_seleccionados.size() >= TOTAL_ESPACIOS:

		mostrar_mensaje(
			"Ya completaste los 4 espacios. "
			+ "Comprueba o limpia para cambiar.",
			Color("#FFD477")
		)
		return

	bloques_seleccionados.append(numero)

	var boton: Button = lista_bloques.get_node_or_null(
		"Bloque" + str(numero)
	) as Button

	if boton != null:
		boton.disabled = true

	mensaje_resultado.text = ""

	actualizar_algoritmo()


# ==========================================
# MOSTRAR ALGORITMO
# ==========================================

func actualizar_algoritmo() -> void:

	if not referencias_correctas:
		return

	# Eliminar lineas anteriores.
	for hijo in lista_algoritmo.get_children():

		if hijo == mensaje_vacio:
			continue

		lista_algoritmo.remove_child(hijo)
		hijo.queue_free()

	mensaje_vacio.hide()

	# Lineas iniciales fijas.
	agregar_linea("ventiladores = [0, 1, 0]")
	agregar_linea("indice = 0")

	# Espacio 1: ciclo while.
	agregar_espacio(0, 0)

	# Espacio 2: decision interna.
	agregar_espacio(1, 4)

	# Espacio 3: activar ventilador.
	agregar_espacio(2, 8)

	# Espacio 4: avanzar al siguiente.
	agregar_espacio(3, 4)

	# Mensaje final.
	agregar_linea('print("Ventilación restaurada")')


# ==========================================
# AGREGAR LINEA FIJA
# ==========================================

func agregar_linea(contenido: String) -> void:

	var linea: Label = Label.new()

	linea.text = contenido
	linea.autowrap_mode = TextServer.AUTOWRAP_OFF

	linea.add_theme_color_override(
		"font_color",
		Color("#DCE9FA")
	)

	linea.add_theme_font_size_override(
		"font_size", 14
	)

	lista_algoritmo.add_child(linea)


# ==========================================
# AGREGAR ESPACIO VISUAL
# ==========================================

func agregar_espacio(indice: int, sangria: int) -> void:

	var panel: PanelContainer = PanelContainer.new()

	var estilo: StyleBoxFlat = StyleBoxFlat.new()

	estilo.bg_color = Color("#243453")
	estilo.border_color = Color("#9D83EA")

	estilo.set_border_width_all(1)
	estilo.set_corner_radius_all(6)
	estilo.set_content_margin_all(8)

	panel.add_theme_stylebox_override(
		"panel", estilo
	)

	var espacio: Label = Label.new()

	espacio.autowrap_mode = TextServer.AUTOWRAP_OFF

	if indice < bloques_seleccionados.size():

		var numero: int = bloques_seleccionados[indice]

		espacio.text = CODIGO_BLOQUES[numero]

	else:

		espacio.text = (
			" ".repeat(sangria)
			+ "[ Espacio "
			+ str(indice + 1)
			+ " ]"
		)

	espacio.add_theme_color_override(
		"font_color",
		Color("#DCC6FF")
	)

	espacio.add_theme_font_size_override(
		"font_size", 14
	)

	panel.custom_minimum_size.y = 36

	panel.add_child(espacio)
	lista_algoritmo.add_child(panel)


# ==========================================
# LIMPIAR ALGORITMO
# ==========================================

func limpiar_algoritmo() -> void:

	if not referencias_correctas or ejercicio_terminado:
		return

	bloques_seleccionados.clear()

	for boton in botones_bloques:
		boton.disabled = false

	mensaje_resultado.text = ""

	actualizar_algoritmo()

	print("E3.5: algoritmo limpiado.")


# ==========================================
# COMPROBAR RESPUESTA
# ==========================================

func comprobar_algoritmo() -> void:

	if not referencias_correctas or ejercicio_terminado:
		return

	if bloques_seleccionados.size() != TOTAL_ESPACIOS:

		mostrar_mensaje(
			"Completa los 4 espacios antes de comprobar.",
			Color("#FFD477")
		)

		# No sumar errores por respuesta incompleta.
		return

	if bloques_seleccionados == ORDEN_CORRECTO:
		completar_ejercicio()
		return

	errores += 1

	mostrar_pista()

	mensaje_resultado.text = ""

	print("E3.5: error número ", errores)


# ==========================================
# MOSTRAR PISTA
# ==========================================

func mostrar_pista() -> void:

	if not referencias_correctas:
		return

	var indice_error: int = -1

	for i in range(TOTAL_ESPACIOS):

		if bloques_seleccionados[i] != ORDEN_CORRECTO[i]:
			indice_error = i
			break

	match indice_error:

		0:
			texto_pista.text = (
				"Necesitas recorrer todos los "
				+ "ventiladores de la lista. "
				+ "El ciclo continúa mientras "
				+ "el índice sea menor que "
				+ "la cantidad de ventiladores."
			)

		1:
			texto_pista.text = (
				"El valor 0 significa que "
				+ "el ventilador está apagado. "
				+ "Debes comprobar ese valor."
			)

		2:
			texto_pista.text = (
				"Si el ventilador está apagado, "
				+ "debes mostrar el mensaje "
				+ "'Activar ventilador'."
			)

		3:
			texto_pista.text = (
				"Después de revisar cada ventilador, "
				+ "el índice debe aumentar en 1 "
				+ "para continuar con el siguiente."
			)

		_:
			texto_pista.text = (
				"Revisa el ciclo, la condición "
				+ "y las instrucciones del algoritmo."
			)

	panel_pista.modulate.a = 1.0


# ==========================================
# MOSTRAR MENSAJES
# ==========================================

func mostrar_mensaje(texto: String, color: Color) -> void:

	mensaje_resultado.text = texto

	mensaje_resultado.add_theme_color_override(
		"font_color",
		color
	)


# ==========================================
# CALCULAR PUNTOS
# ==========================================

func calcular_puntos() -> int:

	var base: int = (
		TOTAL_ESPACIOS * PUNTOS_POR_BLOQUE
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
		"¡Ventilación restaurada! Ganaste "
		+ str(puntos_obtenidos)
		+ " puntos.",
		Color("#80E6B7")
	)

	# Registrar puntos del E3.5.
	var sistema_puntos: Node = get_node_or_null(
		"/root/PuntajesNivel3"
	)

	if sistema_puntos != null:

		if sistema_puntos.has_method(
			"registrar_ejercicio"
		):

			sistema_puntos.call(
				"registrar_ejercicio",
				CODIGO_EJERCICIO,
				puntos_obtenidos
			)

	else:
		push_warning(
			"E3.5: no se encontró PuntajesNivel3."
		)

	ejercicio_resuelto.emit(errores)

	# Avisar a la consola.
	if consola != null:

		if consola.has_method("completar_ejercicio"):
			consola.call("completar_ejercicio")

	hide()

	# Mostrar ventana de completado.
	if ventana_completado != null:

		if ventana_completado.has_method(
			"mostrar_completado"
		):

			ventana_completado.call(
				"mostrar_completado",
				errores
			)

		else:
			push_warning(
				"E3.5: falta mostrar_completado()."
			)

	else:
		push_warning(
			"E3.5: falta VentanaCompletado."
		)

	print(
		"E3.5 completado. Puntos: ",
		puntos_obtenidos,
		" | Errores: ",
		errores
	)


# ==========================================
# CERRAR VENTANA
# ==========================================

func cerrar_ventana() -> void:

	if ejercicio_terminado:
		return

	if consola != null:

		if consola.has_method("cerrar_ejercicio"):
			consola.call("cerrar_ejercicio")
			return

	hide()

	print("E3.5: ventana cerrada.")
