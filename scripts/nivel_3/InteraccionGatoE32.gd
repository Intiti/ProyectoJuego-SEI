extends Area2D

# MGTS - Nivel 3 - E3.2: Gato de datos
# El diálogo activa la consola al terminar.

signal iniciar_ejercicio

@onready var jugador: CharacterBody2D = get_node_or_null("../Player") as CharacterBody2D
@onready var letra_e: Label = get_node_or_null("LetraE") as Label
@onready var dialogo_ui: CanvasLayer = get_node_or_null("../DialogoUI") as CanvasLayer
@onready var fondo_dialogo: Control = get_node_or_null("../DialogoUI/FondoDialogo") as Control
@onready var caja_dialogo: Control = get_node_or_null("../DialogoUI/CajaDialogo") as Control
@onready var retrato_jugador: TextureRect = get_node_or_null("../DialogoUI/RetratosDialogo/RetratoJugador") as TextureRect
@onready var retrato_npc: TextureRect = get_node_or_null("../DialogoUI/RetratosDialogo/RetratoNPC") as TextureRect
@onready var nombre_gato: Label = get_node_or_null("../DialogoUI/CajaDialogo/ContenidoDialogo/NombreGato") as Label
@onready var texto_dialogo: Label = get_node_or_null("../DialogoUI/CajaDialogo/ContenidoDialogo/TextoDialogo") as Label
@onready var continuar_label: Label = get_node_or_null("../DialogoUI/CajaDialogo/ContenidoDialogo/ContinuarLabel") as Label

const COLOR_ILUMINADO: Color = Color(1, 1, 1, 1)
const COLOR_OSCURO: Color = Color(0.3, 0.3, 0.3, 1)
const COLOR_PROTAGONISTA: Color = Color("#A975EB")
const COLOR_GATO_DATOS: Color = Color("#36C8E8")

# true = Gato de datos; false = protagonista.
const CONVERSACION: Array[Dictionary] = [
	{"gato": true, "texto": "¡Al fin alguien llega! El núcleo de energía está casi apagado."},
	{"gato": false, "texto": "Estoy buscando a Panko. ¿Has visto pasar a un gatito por aquí?"},
	{"gato": true, "texto": "Mis sensores detectaron una pequeña señal felina cerca de los conductos, pero la energía se agotó antes de confirmar su ubicación."},
	{"gato": false, "texto": "Entonces debemos recuperar la energía. No quiero perder su rastro."},
	{"gato": true, "texto": "La consola admite hasta cuatro lecturas de energía. Solo las lecturas positivas ayudan a recargar el núcleo."},
	{"gato": false, "texto": "¿Cuánta energía necesitamos para que vuelva a funcionar?"},
	{"gato": true, "texto": "Diez unidades. Si las reunimos antes de las cuatro lecturas, el núcleo podrá encenderse de inmediato."},
	{"gato": false, "texto": "Entendido. Voy a activar la consola para seguir la pista de Panko."},
	{"gato": true, "texto": "¡Buena suerte!"}
]

var jugador_cerca: bool = false
var dialogo_activo: bool = false
var dialogo_terminado: bool = false
var indice_dialogo: int = 0
var fisica_jugador_activa: bool = true
var referencias_correctas: bool = false
var estilo_original: StyleBox = null

func _ready() -> void:
	monitoring = true
	referencias_correctas = comprobar_referencias()
	if letra_e != null:
		letra_e.hide()
	if dialogo_ui != null:
		dialogo_ui.hide()
	if not referencias_correctas:
		push_error("E3.2: revisa los nodos de InteraccionGatoa2D y DialogoUI.")
		return
	if caja_dialogo is PanelContainer or caja_dialogo is Panel:
		estilo_original = caja_dialogo.get_theme_stylebox("panel")
	body_entered.connect(_cuando_entra)
	body_exited.connect(_cuando_sale)
	print("E3.2: Gato de datos preparado.")

func comprobar_referencias() -> bool:
	var correcto: bool = true
	if jugador == null:
		push_error("E3.2: falta Player.")
		correcto = false
	if letra_e == null:
		push_error("E3.2: falta LetraE.")
		correcto = false
	if dialogo_ui == null:
		push_error("E3.2: falta DialogoUI.")
		correcto = false
	if fondo_dialogo == null:
		push_error("E3.2: falta FondoDialogo.")
		correcto = false
	if caja_dialogo == null:
		push_error("E3.2: falta CajaDialogo.")
		correcto = false
	if retrato_jugador == null:
		push_error("E3.2: falta RetratoJugador.")
		correcto = false
	if retrato_npc == null:
		push_error("E3.2: falta RetratoNPC.")
		correcto = false
	if nombre_gato == null:
		push_error("E3.2: falta NombreGato.")
		correcto = false
	if texto_dialogo == null:
		push_error("E3.2: falta TextoDialogo.")
		correcto = false
	if continuar_label == null:
		push_error("E3.2: falta ContinuarLabel.")
		correcto = false
	return correcto

func _cuando_entra(cuerpo: Node2D) -> void:
	if cuerpo == jugador:
		jugador_cerca = true
		actualizar_letra_e()

func _cuando_sale(cuerpo: Node2D) -> void:
	if cuerpo == jugador:
		jugador_cerca = false
		actualizar_letra_e()

func actualizar_letra_e() -> void:
	if letra_e != null:
		letra_e.visible = jugador_cerca and not dialogo_activo and not dialogo_terminado

func _unhandled_key_input(event: InputEvent) -> void:
	if not referencias_correctas:
		return
	if not event is InputEventKey:
		return
	if not event.pressed or event.echo or event.keycode != KEY_E:
		return
	if dialogo_activo:
		avanzar_dialogo()
		get_viewport().set_input_as_handled()
	elif jugador_cerca and not dialogo_terminado:
		iniciar_dialogo()
		get_viewport().set_input_as_handled()

func iniciar_dialogo() -> void:
	if not referencias_correctas or dialogo_activo or dialogo_terminado:
		return
	dialogo_activo = true
	indice_dialogo = 0
	actualizar_letra_e()
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
	print("E3.2: diálogo iniciado.")

func mostrar_dialogo() -> void:
	if not referencias_correctas:
		return
	if indice_dialogo >= CONVERSACION.size():
		finalizar_dialogo()
		return
	var intervencion: Dictionary = CONVERSACION[indice_dialogo]
	var habla_gato: bool = intervencion["gato"]
	texto_dialogo.text = intervencion["texto"]
	texto_dialogo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	continuar_label.text = "Presiona E para continuar"
	retrato_jugador.show()
	retrato_npc.show()
	if habla_gato:
		nombre_gato.text = "GATO DE DATOS"
		retrato_npc.modulate = COLOR_ILUMINADO
		retrato_jugador.modulate = COLOR_OSCURO
		aplicar_color_dialogo(COLOR_GATO_DATOS)
	else:
		nombre_gato.text = "PROTAGONISTA"
		retrato_jugador.modulate = COLOR_ILUMINADO
		retrato_npc.modulate = COLOR_OSCURO
		aplicar_color_dialogo(COLOR_PROTAGONISTA)

func aplicar_color_dialogo(color_franja: Color) -> void:
	# Cambia el borde de la caja si es Panel o PanelContainer.
	# Mantiene el fondo, las esquinas y márgenes originales.
	nombre_gato.add_theme_color_override("font_color", color_franja)
	if not (caja_dialogo is Panel or caja_dialogo is PanelContainer):
		return
	var estilo: StyleBoxFlat
	if estilo_original is StyleBoxFlat:
		estilo = (estilo_original as StyleBoxFlat).duplicate() as StyleBoxFlat
	else:
		estilo = StyleBoxFlat.new()
		estilo.bg_color = Color("#101827")
		estilo.set_corner_radius_all(10)
	estilo.border_color = color_franja
	estilo.set_border_width_all(3)
	caja_dialogo.add_theme_stylebox_override("panel", estilo)

func avanzar_dialogo() -> void:
	if not dialogo_activo:
		return
	indice_dialogo += 1
	if indice_dialogo >= CONVERSACION.size():
		finalizar_dialogo()
	else:
		mostrar_dialogo()

func congelar_jugador() -> void:
	if jugador == null:
		return
	fisica_jugador_activa = jugador.is_physics_processing()
	jugador.velocity = Vector2.ZERO
	jugador.set_physics_process(false)

func descongelar_jugador() -> void:
	if jugador != null:
		jugador.set_physics_process(fisica_jugador_activa)

func finalizar_dialogo() -> void:
	if not dialogo_activo:
		return
	dialogo_activo = false
	dialogo_terminado = true
	if dialogo_ui != null:
		dialogo_ui.hide()
	actualizar_letra_e()
	if retrato_jugador != null:
		retrato_jugador.modulate = COLOR_ILUMINADO
	if retrato_npc != null:
		retrato_npc.modulate = COLOR_ILUMINADO
	descongelar_jugador()
	# La consola debe escuchar esta señal para mostrar ! y luego E.
	iniciar_ejercicio.emit()
	print("E3.2: diálogo terminado. Consola habilitada.")
