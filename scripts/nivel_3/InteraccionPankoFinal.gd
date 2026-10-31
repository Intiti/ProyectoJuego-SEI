extends Area2D

# ==========================================
# MGTS - FINAL DEL JUEGO
# REENCUENTRO CON PANKO
# PANKO SOLO DICE ¡MIAU!
# ==========================================

signal panko_rescatado

# ==========================================
# COLORES
# ==========================================

const COLOR_JUGADOR: Color = Color("#A975EB")
const COLOR_PANKO: Color = Color("#FFBF69")

const COLOR_ILUMINADO: Color = Color.WHITE
const COLOR_OSCURO: Color = Color(0.3, 0.3, 0.3, 1.0)


# ==========================================
# REFERENCIAS
# ==========================================

@onready var jugador: CharacterBody2D = get_node_or_null(
	"../Player"
) as CharacterBody2D

@onready var panko: Node2D = get_node_or_null(
	"../PANKO"
) as Node2D

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

@onready var nombre_personaje: Label = get_node_or_null(
	"../DialogoUI/CajaDialogo/ContenidoDialogo/NombreGato"
) as Label

@onready var texto_dialogo: Label = get_node_or_null(
	"../DialogoUI/CajaDialogo/ContenidoDialogo/TextoDialogo"
) as Label

@onready var continuar_label: Label = get_node_or_null(
	"../DialogoUI/CajaDialogo/ContenidoDialogo/ContinuarLabel"
) as Label

@onready var retrato_jugador: CanvasItem = get_node_or_null(
	"../DialogoUI/RetratosDialogo/RetratoJugador"
) as CanvasItem

@onready var retrato_panko: CanvasItem = get_node_or_null(
	"../DialogoUI/RetratosDialogo/RetratoNPC"
) as CanvasItem

@onready var ventana_final: Control = get_node_or_null(
	"../FinalJuegoUI/VentanaFinal"
) as Control


# ==========================================
# DIALOGOS DEL REENCUENTRO
# ==========================================

const DIALOGOS: Array[Dictionary] = [
	{
		"nombre": "Jugador",
		"texto": "¡Panko! ¡Eres tú! ¡Por fin te encontré!"
	},
	{
		"nombre": "Panko",
		"texto": "¡Miau! ¡Miau!"
	},
	{
		"nombre": "Jugador",
		"texto": "¡No sabes cuánto te busqué! Recorrí todo el laboratorio para llegar hasta aquí."
	},
	{
		"nombre": "Panko",
		"texto": "¡Miaaau!"
	},
	{
		"nombre": "Jugador",
		"texto": "¡Y ahora estás aquí, sano y salvo! ¡Qué alegría verte!"
	},
	{
		"nombre": "Panko",
		"texto": "¡Miau! ¡Miau!"
	},
	{
		"nombre": "Jugador",
		"texto": "Ven, pequeño. ¡Te voy a dar el abrazo más grande del mundo!"
	},
	{
		"nombre": "Panko",
		"texto": "¡Miauuu!"
	},
	{
		"nombre": "Jugador",
		"texto": "Conocí a muchos amigos que me ayudaron a seguir tu rastro."
	},
	{
		"nombre": "Panko",
		"texto": "¡Miau!"
	},
	{
		"nombre": "Jugador",
		"texto": "También resolví todos los desafíos de Python. ¡Valió la pena cada esfuerzo!"
	},
	{
		"nombre": "Panko",
		"texto": "¡Miau! ¡Miau!"
	},
	{
		"nombre": "Jugador",
		"texto": "Lo importante es que estamos juntos otra vez. No voy a perderte de vista."
	},
	{
		"nombre": "Panko",
		"texto": "¡Miaaau!"
	},
	{
		"nombre": "Jugador",
		"texto": "Nuestra aventura terminó, Panko. ¡Es hora de volver a casa!"
	},
	{
		"nombre": "Panko",
		"texto": "¡MIAU! ¡MIAU! ¡MIAU!"
	}
]


# ==========================================
# VARIABLES
# ==========================================

var jugador_cerca: bool = false
var dialogo_activo: bool = false
var rescate_completado: bool = false
var indice_dialogo: int = 0

var jugador_congelado: bool = false

var fisica_jugador_activa: bool = true
var input_jugador_activo: bool = true
var unhandled_jugador_activo: bool = true
var unhandled_key_jugador_activo: bool = true

var estilo_original: StyleBox = null


# ==========================================
# INICIO
# ==========================================

func _ready() -> void:

	monitoring = true

	if letra_e != null:
		letra_e.hide()

	if dialogo_ui != null:
		dialogo_ui.hide()

	if ventana_final != null:
		ventana_final.hide()

	if jugador == null:
		push_error("FINAL: no se encontró Player.")

	if panko == null:
		push_warning("FINAL: no se encontró PANKO.")

	if caja_dialogo is Panel or caja_dialogo is PanelContainer:
		estilo_original = caja_dialogo.get_theme_stylebox(
			"panel"
		)

	if not body_entered.is_connected(_al_entrar):
		body_entered.connect(_al_entrar)

	if not body_exited.is_connected(_al_salir):
		body_exited.connect(_al_salir)

	print("MGTS: reencuentro final con Panko preparado.")


# ==========================================
# DETECTAR JUGADOR
# ==========================================

func _al_entrar(cuerpo: Node2D) -> void:

	if cuerpo == jugador:
		jugador_cerca = true
		actualizar_letra_e()


func _al_salir(cuerpo: Node2D) -> void:

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
		and not rescate_completado
	)


# ==========================================
# DETECTAR TECLA E
# ==========================================

func _unhandled_key_input(event: InputEvent) -> void:

	if not event is InputEventKey:
		return

	if not event.pressed or event.echo:
		return

	if event.keycode != KEY_E:
		return

	if rescate_completado:
		return

	if dialogo_activo:
		siguiente_dialogo()
		get_viewport().set_input_as_handled()
		return

	if jugador_cerca:
		iniciar_dialogo()
		get_viewport().set_input_as_handled()


# ==========================================
# INICIAR DIALOGO
# ==========================================

func iniciar_dialogo() -> void:

	if dialogo_activo or rescate_completado:
		return

	if dialogo_ui == null:
		push_error("FINAL: falta DialogoUI.")
		return

	if nombre_personaje == null or texto_dialogo == null:
		push_error("FINAL: faltan los Labels del diálogo.")
		return

	dialogo_activo = true
	indice_dialogo = 0

	if letra_e != null:
		letra_e.hide()

	congelar_jugador()

	dialogo_ui.show()

	if fondo_dialogo != null:
		fondo_dialogo.show()

	if caja_dialogo != null:
		caja_dialogo.show()

	if retrato_jugador != null:
		retrato_jugador.show()

	if retrato_panko != null:
		retrato_panko.show()

	if continuar_label != null:
		continuar_label.show()

	mostrar_dialogo()


# ==========================================
# MOSTRAR DIALOGO
# ==========================================

func mostrar_dialogo() -> void:

	if indice_dialogo >= DIALOGOS.size():
		finalizar_dialogo()
		return

	var linea: Dictionary = DIALOGOS[indice_dialogo]

	var nombre: String = str(linea["nombre"])
	var mensaje: String = str(linea["texto"])

	nombre_personaje.text = GameData.characterName if nombre == "Jugador" else nombre   # nombre real del jugador
	texto_dialogo.text = mensaje

	texto_dialogo.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	if continuar_label != null:
		continuar_label.text = "Presiona E para continuar"

	var color_dialogo: Color = COLOR_JUGADOR

	if nombre == "Panko":
		color_dialogo = COLOR_PANKO

	# Cambiar color del nombre.
	nombre_personaje.add_theme_color_override(
		"font_color",
		color_dialogo
	)

	# Cambiar color del borde de la caja.
	aplicar_color_dialogo(color_dialogo)

	# Iluminar al personaje que habla.
	if retrato_jugador != null:

		if nombre == "Jugador":
			retrato_jugador.modulate = COLOR_ILUMINADO
		else:
			retrato_jugador.modulate = COLOR_OSCURO

	if retrato_panko != null:

		if nombre == "Panko":
			retrato_panko.modulate = COLOR_ILUMINADO
		else:
			retrato_panko.modulate = COLOR_OSCURO

	print(nombre, ": ", mensaje)


# ==========================================
# CAMBIAR COLOR DEL BORDE
# ==========================================

func aplicar_color_dialogo(color: Color) -> void:

	if caja_dialogo == null:
		return

	if not (
		caja_dialogo is Panel
		or caja_dialogo is PanelContainer
	):
		return

	var estilo: StyleBoxFlat

	if estilo_original is StyleBoxFlat:
		estilo = estilo_original.duplicate() as StyleBoxFlat
	else:
		estilo = StyleBoxFlat.new()
		estilo.bg_color = Color("#151A30")
		estilo.set_corner_radius_all(12)
		estilo.set_content_margin_all(12)

	estilo.border_color = color
	estilo.set_border_width_all(3)

	caja_dialogo.add_theme_stylebox_override(
		"panel",
		estilo
	)


# ==========================================
# SIGUIENTE DIALOGO
# ==========================================

func siguiente_dialogo() -> void:

	if not dialogo_activo:
		return

	indice_dialogo += 1

	if indice_dialogo >= DIALOGOS.size():
		finalizar_dialogo()
	else:
		mostrar_dialogo()


# ==========================================
# FINALIZAR DIALOGO
# ==========================================

func finalizar_dialogo() -> void:

	if not dialogo_activo:
		return

	dialogo_activo = false

	if dialogo_ui != null:
		dialogo_ui.hide()

	if retrato_jugador != null:
		retrato_jugador.modulate = COLOR_ILUMINADO

	if retrato_panko != null:
		retrato_panko.modulate = COLOR_ILUMINADO

	rescatar_panko()


# ==========================================
# COMPLETAR REENCUENTRO
# ==========================================

func rescatar_panko() -> void:

	if rescate_completado:
		return

	rescate_completado = true

	if letra_e != null:
		letra_e.hide()

	descongelar_jugador()

	var sistema_puntos: Node = get_node_or_null("/root/PuntajesNivel3")
	if sistema_puntos != null and sistema_puntos.has_method("registrar_rescate_panko"):
		sistema_puntos.call("registrar_rescate_panko")

	var dj: Node = get_node_or_null("/root/DJManager")
	if dj != null and dj.has_method("play_sfx"):
		dj.call("play_sfx", "rescate_panko")

	panko_rescatado.emit()

	print("================================")
	print("¡PANKO HA SIDO ENCONTRADO!")
	print("¡MISIÓN CUMPLIDA!")
	print("MGTS - FIN DEL JUEGO")
	print("================================")

	# Mostrar pantalla final.
	if ventana_final != null:

		if ventana_final.has_method("mostrar_final"):
			ventana_final.call("mostrar_final")
		else:
			ventana_final.show()

	else:
		push_warning(
			"FINAL: falta FinalJuegoUI/VentanaFinal."
		)


# ==========================================
# CONGELAR JUGADOR
# ==========================================

func congelar_jugador() -> void:

	if jugador == null:
		return

	if jugador_congelado:
		return

	jugador_congelado = true

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

	if not jugador_congelado:
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

	jugador_congelado = false
