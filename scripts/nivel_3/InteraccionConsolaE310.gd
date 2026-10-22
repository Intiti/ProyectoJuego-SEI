extends Area2D

# ==========================================
# MGTS - NIVEL 3 - EJERCICIO E3.10
# CAMARA DE RESCATE
# INTERACCION CON EL LINCE CIBERNETICO
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
const COLOR_LINCE: Color = Color("#36E5FF")


# ==========================================
# HISTORIA E3.10
# true = Lince Cibernetico
# false = Protagonista
# ==========================================

const CONVERSACION: Array[Dictionary] = [
	{
		"lince": true,
		"texto": "¡Alto! Soy el Lince Cibernético, responsable de la Cámara de Rescate. Este sector permanece bajo protocolo de seguridad."
	},
	{
		"lince": false,
		"texto": "¡Hola! Vengo del Servidor Central. Recuperamos unos registros que indican que Panko, un gatito perdido, podría estar aquí."
	},
	{
		"lince": true,
		"texto": "Analizando registros recuperados... Confirmado. Una pequeña criatura ingresó a esta cámara hace poco."
	},
	{
		"lince": false,
		"texto": "¡Panko! ¡Sabía que estaba cerca! ¿Dónde está? ¡Necesito encontrarlo!"
	},
	{
		"lince": true,
		"texto": "La criatura se encuentra en una zona de rescate protegida, pero el sistema de apertura está bloqueado."
	},
	{
		"lince": false,
		"texto": "¡Entonces está aquí! ¿Por qué no podemos abrir la zona de rescate?"
	},
	{
		"lince": true,
		"texto": "El protocolo automático dejó de funcionar. Debemos verificar una señal de rescate válida antes de desbloquear el acceso."
	},
	{
		"lince": false,
		"texto": "¿Una señal de rescate? ¿Cómo podemos reconocerla?"
	},
	{
		"lince": true,
		"texto": "El sistema acepta las señales 'gatito' o 'maullido'. Disponemos de un máximo de tres intentos para detectar una señal válida."
	},
	{
		"lince": false,
		"texto": "¡Entiendo! Necesitamos comprobar las señales y detener la búsqueda en cuanto encontremos una correcta."
	},
	{
		"lince": true,
		"texto": "Exactamente. Debes construir un algoritmo en Python que repita la búsqueda mientras no se haya detectado una señal válida y queden intentos disponibles."
	},
	{
		"lince": false,
		"texto": "¡Lo haré! He recorrido todo el laboratorio para encontrar a Panko. No voy a detenerme ahora."
	},
	{
		"lince": true,
		"texto": "Esta es nuestra última misión. Si restauramos el protocolo de rescate, podremos abrir la zona protegida y comprobar si Panko está a salvo."
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
			"E3.10: revisa los nodos de InteraccionGatoa2D y DialogoUI."
		)
		return

	# Guardar estilo original de la caja.
	if caja_dialogo is PanelContainer or caja_dialogo is Panel:

		estilo_original = caja_dialogo.get_theme_stylebox(
			"panel"
		)

	# Detectar entrada del protagonista.
	if not body_entered.is_connected(_cuando_entra):

		body_entered.connect(_cuando_entra)

	# Detectar salida del protagonista.
	if not body_exited.is_connected(_cuando_sale):

		body_exited.connect(_cuando_sale)

	print("E3.10: Lince Cibernético preparado.")


# ==========================================
# COMPROBAR REFERENCIAS
# ==========================================

func comprobar_referencias() -> bool:

	var correcto: bool = true

	if jugador == null:
		push_error("E3.10: falta Player.")
		correcto = false

	if letra_e == null:
		push_error("E3.10: falta LetraE.")
		correcto = false

	if dialogo_ui == null:
		push_error("E3.10: falta DialogoUI.")
		correcto = false

	if fondo_dialogo == null:
		push_error("E3.10: falta FondoDialogo.")
		correcto = false

	if caja_dialogo == null:
		push_error("E3.10: falta CajaDialogo.")
		correcto = false

	if retrato_jugador == null:
		push_error("E3.10: falta RetratoJugador.")
		correcto = false

	if retrato_npc == null:
		push_error("E3.10: falta RetratoNPC.")
		correcto = false

	if nombre_gato == null:
		push_error("E3.10: falta NombreGato.")
		correcto = false

	if texto_dialogo == null:
		push_error("E3.10: falta TextoDialogo.")
		correcto = false

	if continuar_label == null:
		push_error("E3.10: falta ContinuarLabel.")
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

	# Mostrar ambos retratos.
	retrato_jugador.show()
	retrato_npc.show()

	nombre_gato.show()
	texto_dialogo.show()
	continuar_label.show()

	mostrar_dialogo()

	print("E3.10: diálogo iniciado.")


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

	var habla_lince: bool = intervencion["lince"]

	texto_dialogo.text = intervencion["texto"]

	texto_dialogo.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	continuar_label.text = "Presiona E para continuar"

	# Mantener ambos retratos visibles.
	retrato_jugador.show()
	retrato_npc.show()

	if habla_lince:

		# Habla el Lince Cibernético.
		nombre_gato.text = "LINCE CIBERNÉTICO"

		retrato_npc.modulate = COLOR_ILUMINADO
		retrato_jugador.modulate = COLOR_OSCURO

		aplicar_color_dialogo(COLOR_LINCE)

	else:

		# Habla el protagonista.
		nombre_gato.text = GameData.playerName.to_upper()   # nombre real del jugador

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

	# Habilitar consola E3.10.
	iniciar_ejercicio.emit()

	print("E3.10: diálogo terminado.")
	print("E3.10: consola de rescate habilitada.")
