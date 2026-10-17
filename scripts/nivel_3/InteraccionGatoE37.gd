
extends Area2D

# ==========================================
# MGTS - NIVEL 3 - EJERCICIO E3.7
# TUNELES DE RADIACION
# INTERACCION CON ROBOT DE SEGURIDAD
# ==========================================

signal iniciar_ejercicio


# ==========================================
# REFERENCIAS
# ==========================================

@onready var jugador: CharacterBody2D = get_node_or_null(
	"../Player"
) as CharacterBody2D

@onready var letra_e: Label = get_node_or_null(
	"LetraE"
) as Label

@onready var dialogo_ui: CanvasLayer = get_node_or_null(
	"../DialogoUI"
) as CanvasLayer

@onready var fondo_dialogo: Control = get_node_or_null(
	"../DialogoUI/FondoDialogo"
) as Control

@onready var caja_dialogo: Control = get_node_or_null(
	"../DialogoUI/CajaDialogo"
) as Control

@onready var retrato_jugador: TextureRect = get_node_or_null(
	"../DialogoUI/RetratosDialogo/RetratoJugador"
) as TextureRect

@onready var retrato_npc: TextureRect = get_node_or_null(
	"../DialogoUI/RetratosDialogo/RetratoNPC"
) as TextureRect

@onready var nombre_gato: Label = get_node_or_null(
	"../DialogoUI/CajaDialogo/ContenidoDialogo/NombreGato"
) as Label

@onready var texto_dialogo: Label = get_node_or_null(
	"../DialogoUI/CajaDialogo/ContenidoDialogo/TextoDialogo"
) as Label

@onready var continuar_label: Label = get_node_or_null(
	"../DialogoUI/CajaDialogo/ContenidoDialogo/ContinuarLabel"
) as Label


# ==========================================
# COLORES
# ==========================================

const COLOR_ILUMINADO: Color = Color(1, 1, 1, 1)
const COLOR_OSCURO: Color = Color(0.3, 0.3, 0.3, 1)

const COLOR_PROTAGONISTA: Color = Color("#A975EB")
const COLOR_ROBOT: Color = Color("#A4FF36")


# ==========================================
# HISTORIA E3.7
# true = Robot de Seguridad
# false = Protagonista
# ==========================================

const CONVERSACION: Array[Dictionary] = [
	{
		"robot": true,
		"texto": "¡ALTO! Acceso restringido. Se han detectado niveles peligrosos de radiación en estos túneles."
	},
	{
		"robot": false,
		"texto": "¡Espera! Estoy buscando a Panko. ¿Has visto pasar a un gatito por aquí?"
	},
	{
		"robot": true,
		"texto": "Analizando registros... Detecté una pequeña figura cruzando este sector hace poco."
	},
	{
		"robot": false,
		"texto": "¡Podría ser Panko! Necesito seguir su rastro. ¿Puedes dejarme pasar?"
	},
	{
		"robot": true,
		"texto": "NEGATIVO. El escudo de radiación está desactivado. Atravesar el túnel ahora sería demasiado peligroso."
	},
	{
		"robot": false,
		"texto": "Entonces tendremos que repararlo. ¿Qué necesita el sistema?"
	},
	{
		"robot": true,
		"texto": "Debes programar un algoritmo en Python que revise los niveles de radiación y active la protección cuando sea necesario."
	},
	{
		"robot": false,
		"texto": "¡Entendido! Activaré el escudo. No puedo perder la pista de Panko."
	},
	{
		"robot": true,
		"texto": "PROTOCOLO AUTORIZADO. "
	}
]

# ==========================================
# VARIABLES
# ==========================================

var jugador_cerca: bool = false
var dialogo_activo: bool = false
var dialogo_terminado: bool = false

var indice_dialogo: int = 0

var fisica_jugador_activa: bool = true
var input_jugador_activo: bool = true
var unhandled_jugador_activo: bool = true
var unhandled_key_jugador_activo: bool = true

var referencias_correctas: bool = false

var estilo_original: StyleBox = null


# ==========================================
# INICIO
# ==========================================

func _ready() -> void:

	monitoring = true

	referencias_correctas = comprobar_referencias()

	if letra_e != null:
		letra_e.hide()

	if dialogo_ui != null:
		dialogo_ui.hide()

	if not referencias_correctas:
		push_error(
			"E3.7: revisa los nodos de InteraccionGatoa2D y DialogoUI."
		)
		return

	# Guardar estilo original de la caja.
	if caja_dialogo is PanelContainer or caja_dialogo is Panel:

		estilo_original = caja_dialogo.get_theme_stylebox(
			"panel"
		)

	# Detectar entrada del jugador.
	if not body_entered.is_connected(_cuando_entra):
		body_entered.connect(_cuando_entra)

	# Detectar salida del jugador.
	if not body_exited.is_connected(_cuando_sale):
		body_exited.connect(_cuando_sale)

	print("E3.7: Robot de Seguridad preparado.")


# ==========================================
# COMPROBAR REFERENCIAS
# ==========================================

func comprobar_referencias() -> bool:

	var correcto: bool = true

	if jugador == null:
		push_error("E3.7: falta Player.")
		correcto = false

	if letra_e == null:
		push_error("E3.7: falta LetraE.")
		correcto = false

	if dialogo_ui == null:
		push_error("E3.7: falta DialogoUI.")
		correcto = false

	if fondo_dialogo == null:
		push_error("E3.7: falta FondoDialogo.")
		correcto = false

	if caja_dialogo == null:
		push_error("E3.7: falta CajaDialogo.")
		correcto = false

	if retrato_jugador == null:
		push_error("E3.7: falta RetratoJugador.")
		correcto = false

	if retrato_npc == null:
		push_error("E3.7: falta RetratoNPC.")
		correcto = false

	if nombre_gato == null:
		push_error("E3.7: falta NombreGato.")
		correcto = false

	if texto_dialogo == null:
		push_error("E3.7: falta TextoDialogo.")
		correcto = false

	if continuar_label == null:
		push_error("E3.7: falta ContinuarLabel.")
		correcto = false

	return correcto


# ==========================================
# DETECTAR JUGADOR
# ==========================================

func _cuando_entra(cuerpo: Node2D) -> void:

	if cuerpo == jugador:

		jugador_cerca = true

		actualizar_letra_e()


func _cuando_sale(cuerpo: Node2D) -> void:

	if cuerpo == jugador:

		jugador_cerca = false

		actualizar_letra_e()


# ==========================================
# MOSTRAR LETRA E
# ==========================================

func actualizar_letra_e() -> void:

	if letra_e == null:
		return

	letra_e.visible = (
		jugador_cerca
		and not dialogo_activo
		and not dialogo_terminado
	)


# ==========================================
# DETECTAR TECLA E
# ==========================================

func _unhandled_key_input(event: InputEvent) -> void:

	if not referencias_correctas:
		return

	if not event is InputEventKey:
		return

	if not event.pressed or event.echo:
		return

	if event.keycode != KEY_E:
		return

	# Continuar conversación.
	if dialogo_activo:

		avanzar_dialogo()

		get_viewport().set_input_as_handled()

		return

	# Comenzar conversación.
	if jugador_cerca and not dialogo_terminado:

		iniciar_dialogo()

		get_viewport().set_input_as_handled()


# ==========================================
# INICIAR DIALOGO
# ==========================================

func iniciar_dialogo() -> void:

	if not referencias_correctas:
		return

	if dialogo_activo or dialogo_terminado:
		return

	dialogo_activo = true

	indice_dialogo = 0

	actualizar_letra_e()

	# Detener al protagonista.
	congelar_jugador()

	# Mostrar interfaz.
	dialogo_ui.show()
	fondo_dialogo.show()
	caja_dialogo.show()

	# Ambos retratos visibles.
	retrato_jugador.show()
	retrato_npc.show()

	nombre_gato.show()
	texto_dialogo.show()
	continuar_label.show()

	mostrar_dialogo()

	print("E3.7: diálogo iniciado.")


# ==========================================
# MOSTRAR DIALOGO
# ==========================================

func mostrar_dialogo() -> void:

	if not referencias_correctas:
		return

	if indice_dialogo >= CONVERSACION.size():
		finalizar_dialogo()
		return

	var intervencion: Dictionary = CONVERSACION[indice_dialogo]

	var habla_robot: bool = intervencion["robot"]

	texto_dialogo.text = intervencion["texto"]

	texto_dialogo.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	continuar_label.text = "Presiona E para continuar"

	# Mantener visibles ambos retratos.
	retrato_jugador.show()
	retrato_npc.show()

	if habla_robot:

		# Habla el Robot de Seguridad.
		nombre_gato.text = "ROBOT DE SEGURIDAD"

		retrato_npc.modulate = COLOR_ILUMINADO
		retrato_jugador.modulate = COLOR_OSCURO

		aplicar_color_dialogo(COLOR_ROBOT)

	else:

		# Habla el protagonista.
		nombre_gato.text = "PROTAGONISTA"

		retrato_jugador.modulate = COLOR_ILUMINADO
		retrato_npc.modulate = COLOR_OSCURO

		aplicar_color_dialogo(COLOR_PROTAGONISTA)


# ==========================================
# CAMBIAR COLOR DEL DIALOGO
# ==========================================

func aplicar_color_dialogo(color_franja: Color) -> void:

	if nombre_gato != null:

		nombre_gato.add_theme_color_override(
			"font_color",
			color_franja
		)

	if not (
		caja_dialogo is Panel
		or caja_dialogo is PanelContainer
	):
		return

	var estilo: StyleBoxFlat

	if estilo_original is StyleBoxFlat:

		estilo = (
			estilo_original as StyleBoxFlat
		).duplicate() as StyleBoxFlat

	else:

		estilo = StyleBoxFlat.new()

		estilo.bg_color = Color("#101827")

		estilo.set_corner_radius_all(10)

	# Cambiar borde según quién habla.
	estilo.border_color = color_franja

	estilo.set_border_width_all(3)

	caja_dialogo.add_theme_stylebox_override(
		"panel",
		estilo
	)


# ==========================================
# AVANZAR DIALOGO
# ==========================================

func avanzar_dialogo() -> void:

	if not dialogo_activo:
		return

	indice_dialogo += 1

	if indice_dialogo >= CONVERSACION.size():

		finalizar_dialogo()

	else:

		mostrar_dialogo()


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


# ==========================================
# FINALIZAR DIALOGO
# ==========================================

func finalizar_dialogo() -> void:

	if not dialogo_activo:
		return

	dialogo_activo = false
	dialogo_terminado = true

	# Ocultar interfaz.
	if dialogo_ui != null:
		dialogo_ui.hide()

	actualizar_letra_e()

	# Restaurar iluminación.
	if retrato_jugador != null:
		retrato_jugador.modulate = COLOR_ILUMINADO

	if retrato_npc != null:
		retrato_npc.modulate = COLOR_ILUMINADO

	# Restaurar movimiento.
	descongelar_jugador()

	# Habilitar consola E3.7.
	# La consola mostrará ! a distancia
	# y E cuando el jugador se acerque.
	iniciar_ejercicio.emit()

	print("E3.7: diálogo terminado.")
	print("E3.7: consola de radiación habilitada.")
