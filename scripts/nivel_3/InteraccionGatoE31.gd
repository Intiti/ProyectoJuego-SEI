
extends Area2D

# ==========================================
# MGTS - NIVEL 3 - EJERCICIO E3.1
# INTERACCION CON EL GATO GUARDIAN
# HISTORIA DE PANKO
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

# Consola E3.1 que mostrara el signo !
@onready var consola_objetivo: Node = get_node_or_null(
	"../InteraccionConsola"
)


# ==========================================
# VARIABLES
# ==========================================

var jugador_cerca: bool = false
var dialogo_activo: bool = false
var dialogo_terminado: bool = false

var indice_dialogo: int = 0

var fisica_jugador_activa: bool = true
var referencias_correctas: bool = false

var estilo_dialogo: StyleBoxFlat


# ==========================================
# COLORES
# ==========================================

const COLOR_ILUMINADO: Color = Color.WHITE

const COLOR_OSCURO: Color = Color(
	0.3, 0.3, 0.3, 1.0
)

const COLOR_PROTAGONISTA: Color = Color(
	0.65, 0.42, 1.0, 1.0
)

const COLOR_GATO_GUARDIAN: Color = Color(
	0.0, 0.87, 1.0, 1.0
)

const COLOR_FONDO_CAJA: Color = Color(
	0.045, 0.065, 0.11, 0.97
)


# ==========================================
# CONVERSACION E3.1
# ==========================================

var dialogos: Array[String] = [
	"¡Alto! Esta entrada está restringida. ¿Qué haces aquí a estas horas?",
	"Estoy buscando a Panko, mi gato. Seguí sus huellas hasta este laboratorio.",
	"¿Panko? Hace poco detectamos una pequeña criatura entrando por los conductos de ventilación.",
	"¡Tiene que ser él! Por favor, necesito encontrarlo.",
	"Ten cuidado. Desde que falló el sistema central, algunas zonas se han vuelto peligrosas.",
	"No importa lo que encuentre ahí dentro. No pienso irme sin Panko.",
	"Entonces demuestra que puedo confiar en ti. Activa la consola de acceso y abriré el primer paso hacia el laboratorio."
]


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
			"E3.1: revisa los nodos del gato y DialogoUI."
		)
		return

	preparar_estilo_dialogo()

	if not body_entered.is_connected(_cuando_entra):
		body_entered.connect(_cuando_entra)

	if not body_exited.is_connected(_cuando_sale):
		body_exited.connect(_cuando_sale)

	print("E3.1: Gato Guardian preparado.")


# ==========================================
# COMPROBAR REFERENCIAS
# ==========================================

func comprobar_referencias() -> bool:

	var correcto: bool = true

	if jugador == null:
		push_error("E3.1: falta Player.")
		correcto = false

	if letra_e == null:
		push_error("E3.1: falta LetraE.")
		correcto = false

	if dialogo_ui == null:
		push_error("E3.1: falta DialogoUI.")
		correcto = false

	if fondo_dialogo == null:
		push_error("E3.1: falta FondoDialogo.")
		correcto = false

	if caja_dialogo == null:
		push_error("E3.1: falta CajaDialogo.")
		correcto = false

	if retrato_jugador == null:
		push_error("E3.1: falta RetratoJugador.")
		correcto = false

	if retrato_npc == null:
		push_error("E3.1: falta RetratoNPC.")
		correcto = false

	if nombre_gato == null:
		push_error("E3.1: falta NombreGato.")
		correcto = false

	if texto_dialogo == null:
		push_error("E3.1: falta TextoDialogo.")
		correcto = false

	if continuar_label == null:
		push_error("E3.1: falta ContinuarLabel.")
		correcto = false

	if consola_objetivo == null:
		push_warning(
			"E3.1: no se encontro InteraccionConsola."
		)

	return correcto


# ==========================================
# PREPARAR BORDE DEL DIALOGO
# ==========================================

func preparar_estilo_dialogo() -> void:

	estilo_dialogo = StyleBoxFlat.new()

	estilo_dialogo.bg_color = COLOR_FONDO_CAJA
	estilo_dialogo.border_color = COLOR_GATO_GUARDIAN

	estilo_dialogo.set_border_width_all(3)
	estilo_dialogo.set_corner_radius_all(16)
	estilo_dialogo.set_content_margin_all(16)

	if caja_dialogo is PanelContainer:
		caja_dialogo.add_theme_stylebox_override(
			"panel",
			estilo_dialogo
		)

	elif caja_dialogo is Panel:
		caja_dialogo.add_theme_stylebox_override(
			"panel",
			estilo_dialogo
		)

	else:
		push_warning(
			"E3.1: CajaDialogo debe ser Panel o PanelContainer."
		)


# ==========================================
# CAMBIAR COLOR SEGUN PERSONAJE
# ==========================================

func cambiar_color_dialogo(
	color_personaje: Color
) -> void:

	if estilo_dialogo != null:
		estilo_dialogo.border_color = color_personaje
		estilo_dialogo.emit_changed()

	if nombre_gato != null:
		nombre_gato.add_theme_color_override(
			"font_color",
			color_personaje
		)


# ==========================================
# DETECTAR AL JUGADOR
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
# MOSTRAR E SOBRE EL GATO
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
# TECLA E
# ==========================================

func _unhandled_key_input(
	event: InputEvent
) -> void:

	if not referencias_correctas:
		return

	if not event is InputEventKey:
		return

	if not event.pressed or event.echo:
		return

	if event.keycode != KEY_E:
		return

	# Si el dialogo esta activo,
	# avanzar a la siguiente frase.
	if dialogo_activo:

		avanzar_dialogo()

		get_viewport().set_input_as_handled()
		return

	# Si todavia no hemos hablado con el gato,
	# iniciar la conversacion.
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

	if letra_e != null:
		letra_e.hide()

	congelar_jugador()

	dialogo_ui.show()
	fondo_dialogo.show()
	caja_dialogo.show()

	retrato_jugador.show()
	retrato_npc.show()

	nombre_gato.show()
	texto_dialogo.show()
	continuar_label.show()

	mostrar_dialogo()

	print("E3.1: dialogo iniciado.")


# ==========================================
# MOSTRAR DIALOGO
# ==========================================

func mostrar_dialogo() -> void:

	if not referencias_correctas:
		return

	if indice_dialogo >= dialogos.size():
		finalizar_dialogo()
		return

	texto_dialogo.text = dialogos[indice_dialogo]

	texto_dialogo.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	continuar_label.text = (
		"Presiona E para continuar"
	)

	retrato_jugador.show()
	retrato_npc.show()

	if indice_dialogo % 2 == 0:

		# Habla el Gato Guardian.
		nombre_gato.text = "GATO GUARDIÁN"

		retrato_npc.modulate = COLOR_ILUMINADO
		retrato_jugador.modulate = COLOR_OSCURO

		cambiar_color_dialogo(
			COLOR_GATO_GUARDIAN
		)

	else:

		# Habla el protagonista.
		nombre_gato.text = GameData.characterName.to_upper()   # nombre elegido por el jugador (no el alias)

		retrato_jugador.modulate = COLOR_ILUMINADO
		retrato_npc.modulate = COLOR_OSCURO

		cambiar_color_dialogo(
			COLOR_PROTAGONISTA
		)


# ==========================================
# AVANZAR DIALOGO
# ==========================================

func avanzar_dialogo() -> void:

	if not dialogo_activo:
		return

	indice_dialogo += 1

	if indice_dialogo >= dialogos.size():
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
# FINALIZAR DIALOGO
# ==========================================

func finalizar_dialogo() -> void:

	if not dialogo_activo:
		return

	dialogo_activo = false
	dialogo_terminado = true

	# Ocultar el dialogo.
	if dialogo_ui != null:
		dialogo_ui.hide()

	# La E del gato no vuelve a aparecer.
	if letra_e != null:
		letra_e.hide()

	# Restaurar retratos.
	if retrato_jugador != null:
		retrato_jugador.modulate = COLOR_ILUMINADO

	if retrato_npc != null:
		retrato_npc.modulate = COLOR_ILUMINADO

	# El protagonista vuelve a moverse.
	descongelar_jugador()

	# Habilitar el ejercicio E3.1.
	iniciar_ejercicio.emit()

	# ======================================
	# ACTIVAR ! SOBRE LA CONSOLA
	# ======================================

	if consola_objetivo != null:

		if consola_objetivo.has_method("mostrar_objetivo"):

			consola_objetivo.call(
				"mostrar_objetivo"
			)

			print(
				"E3.1: indicador ! activado."
			)

		else:

			push_warning(
				"E3.1: la consola no tiene "
				+ "mostrar_objetivo()."
			)

	else:

		push_warning(
			"E3.1: no se encontro la consola. "
			+ "Revisa su nombre en el arbol."
		)

	print("E3.1: dialogo terminado.")
