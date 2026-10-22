
extends Area2D

# ==========================================
# MGTS - NIVEL 3 - E3.4
# INTERACCION CON EL GATO INGENIERO
# SISTEMA DE ENFRIAMIENTO
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
const COLOR_GATO_INGENIERO: Color = Color("#36C8E8")


# ==========================================
# CONVERSACION E3.4
# true = Gato ingeniero
# false = Protagonista
# ==========================================

const CONVERSACION: Array[Dictionary] = [
	{
		"gato": true,
		"texto": "¡Cuidado! El sistema de enfriamiento está fallando y la temperatura es demasiado alta."
	},
	{
		"gato": false,
		"texto": "¡Hola! Vengo de los conductos de exploración. Estoy buscando a Panko. ¿Lo has visto?"
	},
	{
		"gato": true,
		"texto": "No lo he visto, pero mis sensores detectaron una pequeña señal cerca de aquí."
	},
	{
		"gato": false,
		"texto": "¡Podría ser Panko! ¿Podemos revisar esa señal?"
	},
	{
		"gato": true,
		"texto": "Sí, pero primero debemos enfriar el sistema. La temperatura está en 30 grados y necesitamos bajarla hasta 20 o menos."
	},
	{
		"gato": false,
		"texto": "¿Cómo podemos bajar la temperatura?"
	},
	{
		"gato": true,
		"texto": "El sistema puede reducir 3 grados por ciclo. Necesito que lo programes para que se detenga cuando la temperatura sea segura."
	},
	{
		"gato": false,
		"texto": "¡Entendido! Voy a ayudarte a estabilizar el sistema para seguir buscando a Panko."
	},
	{
		"gato": true,
		"texto": "¡Excelente! Activa la consola de enfriamiento y comencemos."
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
			"E3.4: revisa los nodos de InteraccionGatoa2D y DialogoUI."
		)
		return

	# Guardar el estilo original del diálogo.
	if caja_dialogo is PanelContainer or caja_dialogo is Panel:
		estilo_original = caja_dialogo.get_theme_stylebox(
			"panel"
		)

	# Conectar detección del jugador.
	if not body_entered.is_connected(_cuando_entra):
		body_entered.connect(_cuando_entra)

	if not body_exited.is_connected(_cuando_sale):
		body_exited.connect(_cuando_sale)

	print("E3.4: Gato ingeniero preparado.")


# ==========================================
# COMPROBAR REFERENCIAS
# ==========================================

func comprobar_referencias() -> bool:

	var correcto: bool = true

	if jugador == null:
		push_error("E3.4: falta Player.")
		correcto = false

	if letra_e == null:
		push_error("E3.4: falta LetraE.")
		correcto = false

	if dialogo_ui == null:
		push_error("E3.4: falta DialogoUI.")
		correcto = false

	if fondo_dialogo == null:
		push_error("E3.4: falta FondoDialogo.")
		correcto = false

	if caja_dialogo == null:
		push_error("E3.4: falta CajaDialogo.")
		correcto = false

	if retrato_jugador == null:
		push_error("E3.4: falta RetratoJugador.")
		correcto = false

	if retrato_npc == null:
		push_error("E3.4: falta RetratoNPC.")
		correcto = false

	if nombre_gato == null:
		push_error("E3.4: falta NombreGato.")
		correcto = false

	if texto_dialogo == null:
		push_error("E3.4: falta TextoDialogo.")
		correcto = false

	if continuar_label == null:
		push_error("E3.4: falta ContinuarLabel.")
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

func _unhandled_key_input(event: InputEvent) -> void:

	if not referencias_correctas:
		return

	if not event is InputEventKey:
		return

	if not event.pressed or event.echo:
		return

	if event.keycode != KEY_E:
		return

	if dialogo_activo:

		avanzar_dialogo()
		get_viewport().set_input_as_handled()
		return

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

	congelar_jugador()

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

	print("E3.4: diálogo iniciado.")


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

	var habla_gato: bool = intervencion["gato"]

	texto_dialogo.text = intervencion["texto"]

	texto_dialogo.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	continuar_label.text = "Presiona E para continuar"

	# Mantener ambos retratos visibles.
	retrato_jugador.show()
	retrato_npc.show()

	if habla_gato:

		nombre_gato.text = "GATO INGENIERO"

		retrato_npc.modulate = COLOR_ILUMINADO
		retrato_jugador.modulate = COLOR_OSCURO

		aplicar_color_dialogo(COLOR_GATO_INGENIERO)

	else:

		nombre_gato.text = GameData.playerName.to_upper()   # nombre real del jugador

		retrato_jugador.modulate = COLOR_ILUMINADO
		retrato_npc.modulate = COLOR_OSCURO

		aplicar_color_dialogo(COLOR_PROTAGONISTA)


# ==========================================
# CAMBIAR COLOR DEL DIALOGO
# ==========================================

func aplicar_color_dialogo(color_franja: Color) -> void:

	# Cambiar el color del nombre.
	nombre_gato.add_theme_color_override(
		"font_color",
		color_franja
	)

	# Cambiar el borde de la caja de diálogo.
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

	fisica_jugador_activa = jugador.is_physics_processing()

	jugador.velocity = Vector2.ZERO
	jugador.set_physics_process(false)


# ==========================================
# DESCONGELAR JUGADOR
# ==========================================

func descongelar_jugador() -> void:

	if jugador != null:
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

	if dialogo_ui != null:
		dialogo_ui.hide()

	actualizar_letra_e()

	# Restaurar iluminación.
	if retrato_jugador != null:
		retrato_jugador.modulate = COLOR_ILUMINADO

	if retrato_npc != null:
		retrato_npc.modulate = COLOR_ILUMINADO

	descongelar_jugador()

	# Habilitar consola E3.4.
	# La consola mostrará ! cuando esté lejos
	# y E cuando el jugador se acerque.
	iniciar_ejercicio.emit()

	print("E3.4: diálogo terminado.")
	print("E3.4: consola de enfriamiento habilitada.")
