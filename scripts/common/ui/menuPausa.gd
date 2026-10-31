extends CanvasLayer

# ==========================================
# MENÚ DE PAUSA (ESC) + POST TEST
# ------------------------------------------
# Autoload "MenuPausa". Ventanas:
#   1. ESC en cualquier escena de juego -> "¿Quieres volver al menú principal?"
#   2. SÍ -> ventana del post test (link + alias para copiar). Aún se puede volver al juego.
#   3. Fin del juego (tras Panko) -> misma ventana del post test, pero OBLIGATORIA (sin volver atrás).
#   4. Fin del examen del Nivel 1 -> aviso "Aún quedan muchos Miaugoritmos por resolver...".
# Mientras hay una ventana abierta el juego queda en pausa.
# ==========================================

enum Modo { NINGUNO, CONFIRMAR, POSTTEST, POSTTEST_OBLIGATORIO, AVISO }

const POST_TEST_URL := "https://docs.google.com/forms/d/e/1FAIpQLSfbvSdKIdZEcRZHRBezjqInytXtmCUnCUdTPqI3yacIFep63w/viewform?usp=sharing&ouid=101721836203715560181"
const MENU_SCENE := "res://scenes/common/ui/MainMenu.tscn"
const FONT_PATH := "res://assets/fonts/MotionControl-Bold.otf"

# Igual que el pretest: el botón de salir/continuar se habilita después de pulsar "IR AL POST TEST".
# Ponlo en false si quieres que el botón esté siempre disponible.
const EXIGIR_ABRIR_ENLACE := true

const PANEL_W := 760.0
const COLOR_SOFT := Color(0.82, 0.78, 1.0)
const COLOR_ALIAS := Color(1.0, 0.90, 0.55)
const COLOR_OK := Color(0.55, 0.95, 0.65)
const COLOR_ERR := Color(1.0, 0.55, 0.55)

var _modo: Modo = Modo.NINGUNO
var _font: Font = null
var _root: Control = null
var _center: CenterContainer = null
var _panel: PanelContainer = null
var _pausadoAntes: bool = false

# Estado de la partida actual (se reinicia al volver al menú principal)
var _postTestAbierto: bool = false
var _avisoMostrado: bool = false
var _obligatorioMostrado: bool = false

var _copyButton: Button = null
var _hintLabel: Label = null
var _salirButton: Button = null

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	if ResourceLoader.exists(FONT_PATH):
		_font = load(FONT_PATH)
	get_tree().scene_changed.connect(_alCambiarEscena)
	call_deferred("_mantenerAudioEnPausa")

# La música sigue sonando mientras el juego está en pausa.
func _mantenerAudioEnPausa() -> void:
	var dj: Node = get_node_or_null("/root/DJManager")
	if dj != null:
		dj.process_mode = Node.PROCESS_MODE_ALWAYS

func _alCambiarEscena() -> void:
	var escena: Node = get_tree().current_scene
	if escena != null and _esMenuPrincipal(escena):
		_postTestAbierto = false
		_avisoMostrado = false
		_obligatorioMostrado = false
		_cerrar()

func _esMenuPrincipal(escena: Node) -> bool:
	return escena.scene_file_path.ends_with("MainMenu.tscn")

# ==========================================
# API PÚBLICA
# ==========================================

func abrirPausa() -> void:
	if _modo != Modo.NINGUNO or not _puedeAbrirPausa():
		return
	_mostrar(Modo.CONFIRMAR)

# Fin del juego: el post test no se puede omitir.
func mostrarPostTestObligatorio() -> void:
	if _obligatorioMostrado:
		return
	_obligatorioMostrado = true
	_mostrar(Modo.POSTTEST_OBLIGATORIO)

# Fin del examen del Nivel 1.
func mostrarAvisoPrimerExamen() -> void:
	if _avisoMostrado or _modo != Modo.NINGUNO:
		return
	_avisoMostrado = true
	_mostrar(Modo.AVISO)

# ==========================================
# ENTRADA (ESC)
# ==========================================

func _puedeAbrirPausa() -> bool:
	var escena: Node = get_tree().current_scene
	return escena != null and not _esMenuPrincipal(escena)

func _esEsc(event: InputEvent) -> bool:
	return event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE

# Con una ventana abierta, ESC se atiende primero para que ningún otro nodo lo consuma.
func _input(event: InputEvent) -> void:
	if _modo == Modo.NINGUNO or not _esEsc(event):
		return
	get_viewport().set_input_as_handled()
	match _modo:
		Modo.CONFIRMAR, Modo.AVISO:
			_cerrar()
		Modo.POSTTEST:
			_cerrar()   # "volver al juego"
		Modo.POSTTEST_OBLIGATORIO:
			pass        # obligatorio: ESC no la cierra

# Sin ventana abierta, ESC solo llega aquí si ninguna otra pantalla lo usó (manual, diálogos, popups...).
func _unhandled_input(event: InputEvent) -> void:
	if _modo == Modo.NINGUNO and _esEsc(event):
		get_viewport().set_input_as_handled()
		abrirPausa()

# ==========================================
# CONSTRUCCIÓN DE VENTANAS
# ==========================================

func _mostrar(modo: Modo) -> void:
	if _modo == Modo.NINGUNO:
		_pausadoAntes = get_tree().paused
		get_tree().paused = true
		_crearOverlay()
	_modo = modo
	if _panel != null:
		_center.remove_child(_panel)
		_panel.queue_free()
		_panel = null
	match modo:
		Modo.CONFIRMAR:
			_construirConfirmacion()
		Modo.POSTTEST:
			_construirPostTest(false)
		Modo.POSTTEST_OBLIGATORIO:
			_construirPostTest(true)
		Modo.AVISO:
			_construirAviso()

func _cerrar() -> void:
	if _modo == Modo.NINGUNO:
		return
	_modo = Modo.NINGUNO
	if is_instance_valid(_root):
		_root.queue_free()
	_root = null
	_center = null
	_panel = null
	get_tree().paused = _pausadoAntes

func _crearOverlay() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)

	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.06, 0.05, 0.88)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(dim)

	_center = CenterContainer.new()
	_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(_center)

	_root.modulate.a = 0.0
	_root.create_tween().tween_property(_root, "modulate:a", 1.0, 0.15)

func _construirConfirmacion() -> void:
	var v := _nuevoPanel(620.0)
	v.add_child(_label("PAUSA", 38, Color.WHITE, 620.0))
	v.add_child(_label("¿Quieres volver al menú principal?", 28, COLOR_SOFT, 620.0))
	var row := _fila(v)
	var no := _button("NO", 200)
	no.pressed.connect(_cerrar)
	row.add_child(no)
	var si := _button("SÍ", 200)
	si.pressed.connect(func() -> void: _mostrar(Modo.POSTTEST))
	row.add_child(si)
	v.add_child(_label("Pulsa ESC otra vez para seguir jugando.", 16, COLOR_SOFT, 620.0))
	no.grab_focus()

func _construirPostTest(obligatorio: bool) -> void:
	var v := _nuevoPanel(PANEL_W)
	v.add_child(_label("ANTES DE CERRAR EL JUEGO", 36, Color.WHITE, PANEL_W))
	var intro: String = "¡Rescataste a Panko y terminaste el juego! Es obligatorio responder el post test. " if obligatorio else ""
	v.add_child(_label(intro + "Antes de cerrar el juego, haz el post test. Pulsa IR AL POST TEST para abrirlo:", 22, COLOR_SOFT, PANEL_W))

	v.add_child(_label("Tu alias de jugador es:", 22, COLOR_SOFT, PANEL_W))
	v.add_child(_label(GameData.playerName, 56, COLOR_ALIAS, PANEL_W))
	v.add_child(_label("Anótalo o cópialo: lo necesitarás en el formulario.", 18, COLOR_SOFT, PANEL_W))

	var row := _fila(v)
	_copyButton = _button("COPIAR ALIAS", 240)
	_copyButton.pressed.connect(_copiarAlias)
	row.add_child(_copyButton)
	var ir := _button("IR AL POST TEST", 300)
	ir.pressed.connect(_abrirPostTest.bind(obligatorio))
	row.add_child(ir)

	_hintLabel = _label("", 18, COLOR_OK, PANEL_W)
	v.add_child(_hintLabel)

	var row2 := _fila(v)
	if obligatorio:
		_salirButton = _button("CONTINUAR", 300)
		_salirButton.pressed.connect(_cerrar)
	else:
		var volver := _button("VOLVER AL JUEGO", 300)
		volver.pressed.connect(_cerrar)
		row2.add_child(volver)
		_salirButton = _button("IR AL MENÚ PRINCIPAL", 380)
		_salirButton.pressed.connect(_irAlMenu)
	row2.add_child(_salirButton)
	_salirButton.disabled = EXIGIR_ABRIR_ENLACE and not _postTestAbierto
	ir.grab_focus()

func _construirAviso() -> void:
	var w := 700.0
	var v := _nuevoPanel(w)
	v.add_child(_label("¡BUEN TRABAJO!", 36, Color.WHITE, w))
	v.add_child(_label("¡Aún quedan muchos Miaugoritmos por resolver!", 24, COLOR_ALIAS, w))
	v.add_child(_label("Pero para cuando desees terminar tu sesión de juego, pulsa ESC.", 22, COLOR_SOFT, w))
	v.add_child(_label("RECUERDA responder el Post-Test cuando termines.", 22, COLOR_SOFT, w))
	v.add_child(_label("¡Que sigas disfrutando!! :3", 24, COLOR_OK, w))
	var row := _fila(v)
	var ok := _button("¡ENTENDIDO!", 300)
	ok.pressed.connect(_cerrar)
	row.add_child(ok)
	ok.grab_focus()

# ==========================================
# ACCIONES
# ==========================================

func _copiarAlias() -> void:
	DisplayServer.clipboard_set(GameData.playerName)
	if is_instance_valid(_copyButton):
		_copyButton.text = "¡COPIADO!"

func _abrirPostTest(obligatorio: bool) -> void:
	var err: int = OS.shell_open(POST_TEST_URL)
	if err != OK:
		push_error("MenuPausa: no se pudo abrir %s (error %d)" % [POST_TEST_URL, err])
		DisplayServer.clipboard_set(POST_TEST_URL)
		_hintLabel.text = "No se pudo abrir el navegador. El link del post test se copió al portapapeles: pégalo en tu navegador."
		_hintLabel.add_theme_color_override("font_color", COLOR_ERR)
	else:
		_hintLabel.text = "Cuando termines el post test, presiona CONTINUAR." if obligatorio \
			else "Cuando termines el post test, presiona IR AL MENÚ PRINCIPAL."
		_hintLabel.add_theme_color_override("font_color", COLOR_OK)
	_postTestAbierto = true
	if is_instance_valid(_salirButton):
		_salirButton.disabled = false

func _irAlMenu() -> void:
	_cerrar()   # quita la pausa antes de cambiar de escena
	get_tree().change_scene_to_file(MENU_SCENE)

# ==========================================
# HELPERS DE UI (mismo estilo que el formulario del pretest)
# ==========================================

func _nuevoPanel(ancho: float) -> VBoxContainer:
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(ancho, 0)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.20, 0.16, 0.42, 1)
	sb.border_color = Color(0.80, 0.75, 1.00, 1)
	sb.set_border_width_all(4)
	sb.set_corner_radius_all(18)
	sb.content_margin_left = 32
	sb.content_margin_right = 32
	sb.content_margin_top = 24
	sb.content_margin_bottom = 26
	_panel.add_theme_stylebox_override("panel", sb)
	_center.add_child(_panel)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	_panel.add_child(vbox)
	return vbox

func _fila(padre: VBoxContainer) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 14)
	padre.add_child(row)
	return row

# El ancho mínimo evita que las etiquetas con autowrap se midan con ancho ~0 (ventana altísima).
func _label(texto: String, tam: int, color: Color, anchoPanel: float) -> Label:
	var l := Label.new()
	l.text = texto
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size.x = anchoPanel - 72.0   # márgenes (32+32) + borde (4+4)
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", color)
	if _font != null:
		l.add_theme_font_override("font", _font)
	return l

func _button(texto: String, ancho: float) -> Button:
	var b := Button.new()
	b.text = texto
	b.custom_minimum_size = Vector2(ancho, 52)
	b.add_theme_font_size_override("font_size", 24)
	if _font != null:
		b.add_theme_font_override("font", _font)
	return b
