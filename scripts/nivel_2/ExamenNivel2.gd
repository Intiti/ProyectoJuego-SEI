extends CanvasLayer

# ==========================================
# MGTS - NIVEL 2 → 3: EXAMEN DEL ALTAR DESCUIDADO
# Examen secuencial (paso a paso) con 3 vidas, igual al Examen del Nivel 1.
# El jugador completa 6 pasos eligiendo bloques de código de while.
# Al aprobar invoca altar_descuidado.iniciar_secuencia_teletransporte().
# BUG FIX: layer = 25 para que tape el botón Manual (layer 20).
# ==========================================

signal examen_aprobado
signal examen_cerrado
# Señales internas para salir de los bucles de animación
signal _retry_pressed
signal _continue_pressed

const PawIconScript = preload("res://scripts/common/ui/pawIcon.gd")
const MAX_VIDAS: int = 3
const FONT_SIZE := 18

# ----------------------------------------------------------------
# BANCO DE EJERCICIOS DE EXAMEN
# Cada ejercicio tiene una plantilla de líneas (fijas o [?]) y
# un array de "steps" en paralelo, uno por cada [?].
# Cada step tiene "alternatives": array de {text, correct}.
# ----------------------------------------------------------------
const BANCO_EXAMEN: Array = [
	{
		"titulo": "EX·A · El contador de fogatas",
		"oa": "OA3: contador while + condicional",
		"npc": "Vigía del Bosque",
		"instrucciones": "El vigía enciende fogatas para guiar el camino. Necesitas construir el algoritmo que cuente 5 fogatas y calcule las llamas totales.\nElige la línea correcta en cada paso del algoritmo.",
		"plantilla": [
			"fogatas = 0",
			"[?]",
			"    print(\"Fogata encendida\")",
			"[?]",
			"llamas = fogatas * 2",
			"[?]",
			"[?]",
			"[?]",
			"[?]"
		],
		"steps": [
			{
				"hint": "¿Cuál es la condición del ciclo para contar 5 fogatas?",
				"alternatives": [
					{"text": "while fogatas < 5:", "correct": true},
					{"text": "while fogatas > 5:", "correct": false},
					{"text": "if fogatas < 5:", "correct": false},
					{"text": "while fogatas <= 0:", "correct": false}
				]
			},
			{
				"hint": "¿Cómo avanza el contador de fogatas?",
				"alternatives": [
					{"text": "    fogatas = fogatas + 1", "correct": true},
					{"text": "    fogatas = fogatas - 1", "correct": false},
					{"text": "    fogatas = 1", "correct": false},
					{"text": "    fogatas = fogatas + 2", "correct": false}
				]
			},
			{
				"hint": "¿Qué condición comprueba si las llamas superan 8?",
				"alternatives": [
					{"text": "if llamas > 8:", "correct": true},
					{"text": "if llamas < 8:", "correct": false},
					{"text": "while llamas > 8:", "correct": false},
					{"text": "if llamas >= 10:", "correct": false}
				]
			},
			{
				"hint": "¿Qué se imprime cuando el campamento está activo?",
				"alternatives": [
					{"text": "    print(\"Campamento activo\")", "correct": true},
					{"text": "    print(\"Apagar fogatas\")", "correct": false},
					{"text": "    print(fogatas)", "correct": false},
					{"text": "    print(\"Campamento inactivo\")", "correct": false}
				]
			},
			{
				"hint": "¿Cuál es el total de fogatas encendidas?",
				"alternatives": [
					{"text": "print(fogatas)", "correct": true},
					{"text": "print(llamas)", "correct": false},
					{"text": "print(\"fogatas\")", "correct": false},
					{"text": "print(fogatas + llamas)", "correct": false}
				]
			},
			{
				"hint": "¿Cuál es el total de llamas generadas?",
				"alternatives": [
					{"text": "print(llamas)", "correct": true},
					{"text": "print(fogatas)", "correct": false},
					{"text": "print(fogatas * 2)", "correct": false},
					{"text": "print(\"llamas\")", "correct": false}
				]
			}
		]
	},
	{
		"titulo": "EX·B · La cosechadora de cristales",
		"oa": "OA3: acumulador while + condición compuesta",
		"npc": "Druida del Cristal",
		"instrucciones": "La druida recoge cristales de energía mientras tenga menos de 5 cristales Y más de 0 de energía.\nConstruye el algoritmo que acumula los cristales y determina su valor.",
		"plantilla": [
			"cristales = 0",
			"energia = 10",
			"[?]",
			"[?]",
			"[?]",
			"valor = cristales * 4",
			"[?]",
			"[?]",
			"[?]"
		],
		"steps": [
			{
				"hint": "¿Cuál es la condición compuesta del ciclo?",
				"alternatives": [
					{"text": "while cristales < 5 and energia > 0:", "correct": true},
					{"text": "while cristales < 5 or energia > 0:", "correct": false},
					{"text": "while cristales > 5 and energia < 0:", "correct": false},
					{"text": "if cristales < 5 and energia > 0:", "correct": false}
				]
			},
			{
				"hint": "¿Cómo se acumula cada cristal recogido?",
				"alternatives": [
					{"text": "    cristales = cristales + 1", "correct": true},
					{"text": "    cristales = 1", "correct": false},
					{"text": "    cristales = cristales - 1", "correct": false},
					{"text": "    cristales = cristales + energia", "correct": false}
				]
			},
			{
				"hint": "¿Cómo consume energía cada cristal recogido?",
				"alternatives": [
					{"text": "    energia = energia - 2", "correct": true},
					{"text": "    energia = energia + 2", "correct": false},
					{"text": "    energia = 0", "correct": false},
					{"text": "    energia = energia - cristales", "correct": false}
				]
			},
			{
				"hint": "¿Qué condición comprueba si el valor supera 12?",
				"alternatives": [
					{"text": "if valor > 12:", "correct": true},
					{"text": "if valor < 12:", "correct": false},
					{"text": "while valor > 12:", "correct": false},
					{"text": "if valor >= 20:", "correct": false}
				]
			},
			{
				"hint": "¿Qué se imprime cuando el cofre está lleno?",
				"alternatives": [
					{"text": "    print(\"Cofre lleno\")", "correct": true},
					{"text": "    print(\"Cofre vacío\")", "correct": false},
					{"text": "    print(cristales)", "correct": false},
					{"text": "    print(valor)", "correct": false}
				]
			},
			{
				"hint": "¿Qué valor final se muestra al terminar?",
				"alternatives": [
					{"text": "print(valor)", "correct": true},
					{"text": "print(cristales)", "correct": false},
					{"text": "print(energia)", "correct": false},
					{"text": "print(\"valor\")", "correct": false}
				]
			}
		]
	},
	{
		"titulo": "EX·C · El vigía de la muralla",
		"oa": "OA3: acumulador con entrada + condición compuesta",
		"npc": "Constructor Fenris",
		"instrucciones": "El constructor apila bloques en la muralla: máximo 18 unidades de peso Y menos de 5 piedras.\nDebes leer el peso de cada piedra y construir el algoritmo que controla el muro.",
		"plantilla": [
			"peso_muro = 0",
			"piedras = 0",
			"[?]",
			"    bloque = int(input())",
			"[?]",
			"[?]",
			"resistencia = piedras * 3",
			"[?]",
			"[?]",
			"[?]"
		],
		"steps": [
			{
				"hint": "¿Cuál es la condición del ciclo para el muro?",
				"alternatives": [
					{"text": "while peso_muro < 18 and piedras < 5:", "correct": true},
					{"text": "while peso_muro < 18 or piedras < 5:", "correct": false},
					{"text": "while peso_muro > 18 and piedras > 5:", "correct": false},
					{"text": "if peso_muro < 18 and piedras < 5:", "correct": false}
				]
			},
			{
				"hint": "¿Cómo se acumula el peso del nuevo bloque?",
				"alternatives": [
					{"text": "    peso_muro = peso_muro + bloque", "correct": true},
					{"text": "    peso_muro = bloque", "correct": false},
					{"text": "    peso_muro = peso_muro - bloque", "correct": false},
					{"text": "    peso_muro = peso_muro + piedras", "correct": false}
				]
			},
			{
				"hint": "¿Cómo se cuenta cada piedra colocada?",
				"alternatives": [
					{"text": "    piedras = piedras + 1", "correct": true},
					{"text": "    piedras = piedras - 1", "correct": false},
					{"text": "    piedras = 1", "correct": false},
					{"text": "    piedras = bloque + 1", "correct": false}
				]
			},
			{
				"hint": "¿Qué condición comprueba si el muro es resistente?",
				"alternatives": [
					{"text": "if resistencia >= 9:", "correct": true},
					{"text": "if resistencia < 9:", "correct": false},
					{"text": "if resistencia == 0:", "correct": false},
					{"text": "while resistencia >= 9:", "correct": false}
				]
			},
			{
				"hint": "¿Qué se imprime si el muro es resistente?",
				"alternatives": [
					{"text": "    print(\"Muro resistente\")", "correct": true},
					{"text": "    print(\"Muro débil\")", "correct": false},
					{"text": "    print(resistencia)", "correct": false},
					{"text": "    print(\"Construcción fallida\")", "correct": false}
				]
			},
			{
				"hint": "¿Cuál es el peso total del muro construido?",
				"alternatives": [
					{"text": "print(peso_muro)", "correct": true},
					{"text": "print(piedras)", "correct": false},
					{"text": "print(resistencia)", "correct": false},
					{"text": "print(\"peso_muro\")", "correct": false}
				]
			}
		]
	}
]

# ----------------------------------------------------------------
# ESTADO
# ----------------------------------------------------------------
var jugador: CharacterBody2D = null
var altar_descuidado: Node2D = null

var ejercicio_idx: int = -1          # índice del ejercicio fijado para esta sesión
var _ultimo_ejercicio_idx: int = -1  # índice del último ejercicio fallado (para no repetirlo)
var ejercicio_actual: Dictionary = {}
var _steps: Array = []               # steps del ejercicio elegido
var _plantilla: Array = []           # plantilla de líneas del ejercicio

var _currentStep: int = 0            # índice del paso actual dentro de _steps
var _slots: Array = []               # {slot_node, step_idx, row} para cada [?]
var _arrowOverlay: Label = null

var resuelto: bool = false
var vidas_actuales: int = MAX_VIDAS
var mostrando_fallo: bool = false
var _reintentar_elegido: bool = true
var _musica_previa: String = ""
var _musica_examen_activa: bool = false

var _celebrating: bool = false

# ----------------------------------------------------------------
# NODOS UI
# ----------------------------------------------------------------
var panel: ColorRect
var _contentBox: VBoxContainer
var label_titulo: Label
var label_oa: Label
var label_instrucciones: Label
var cmdTitle: Label
var stepLabel: Label
var commandScroll: ScrollContainer
var commandWrapper: VBoxContainer
var feedbackLabel: Label
var dropZone: VBoxContainer
var consoleScroll: ScrollContainer
var _livesBox: HBoxContainer = null
var _paws: Array = []

# ----------------------------------------------------------------
# READY — layer 25 para tapar el botón Manual (layer 20)
# Preseleccionar ejercicio aleatorio al cargar la escena (Req. 2 — Nivel 2.5)
# ----------------------------------------------------------------
func _ready() -> void:
	layer = 25
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_construir_interfaz()
	# Selección dinámica: sincronizar con PuntajesNivel2 o seleccionar aleatorio
	var puntajes = get_node_or_null("/root/PuntajesNivel2")
	if puntajes and "examen_activo_idx" in puntajes and puntajes.examen_activo_idx >= 0:
		ejercicio_idx = puntajes.examen_activo_idx
	elif puntajes and puntajes.has_method("seleccionar_examen_aleatorio"):
		ejercicio_idx = puntajes.seleccionar_examen_aleatorio()
	else:
		ejercicio_idx = randi() % BANCO_EXAMEN.size()
	_ultimo_ejercicio_idx = ejercicio_idx

# ----------------------------------------------------------------
# APERTURA
# ----------------------------------------------------------------
func abrir_examen(altar_ref: Node2D = null) -> void:
	altar_descuidado = altar_ref
	jugador = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if jugador:
		jugador.set_physics_process(false)
		jugador.set_process_unhandled_input(false)
		jugador.set_process_input(false)
		jugador.velocity = Vector2.ZERO

	# El índice ya fue asignado aleatoriamente en _ready() (Nivel 2.5) o por
	# _reiniciar_ejercicio() al reintentar; solo lo generamos aquí como
	# respaldo por si esta instancia se usa fuera del flujo normal.
	if ejercicio_idx < 0:
		ejercicio_idx = randi() % BANCO_EXAMEN.size()
		_ultimo_ejercicio_idx = ejercicio_idx

	ejercicio_actual  = BANCO_EXAMEN[ejercicio_idx]
	_steps            = ejercicio_actual["steps"]
	_plantilla        = ejercicio_actual["plantilla"]

	resuelto       = false
	vidas_actuales = MAX_VIDAS
	mostrando_fallo = false
	_currentStep   = 0
	_celebrating   = false

	_actualizar_vidas()

	label_titulo.text       = "🏛️ EXAMEN ALTAR ANCESTRAL  ·  " + ejercicio_actual["titulo"]
	label_oa.text           = "🎯 " + ejercicio_actual["oa"] + "   |   👤 NPC: " + ejercicio_actual["npc"]
	label_instrucciones.text = ejercicio_actual["instrucciones"]
	feedbackLabel.text      = ""
	feedbackLabel.visible   = false

	_construir_slots()
	_cargar_paso_actual()

	panel.visible = true
	visible = true
	_iniciar_musica_examen()

# ----------------------------------------------------------------
# CIERRE
# ----------------------------------------------------------------
func cerrar_examen() -> void:
	visible = false
	panel.visible = false
	_limpiar_flecha()
	if jugador and not resuelto:
		jugador.set_physics_process(true)
		jugador.set_process_unhandled_input(true)
		jugador.set_process_input(true)
	_detener_musica_examen()
	examen_cerrado.emit()

func _iniciar_musica_examen() -> void:
	if _musica_examen_activa:
		return
	var dj = get_node_or_null("/root/DJManager")
	if dj == null:
		return
	_musica_examen_activa = true
	_musica_previa = str(dj.currentTrack())
	dj.playMusic("examen")

func _detener_musica_examen() -> void:
	if not _musica_examen_activa:
		return
	_musica_examen_activa = false
	var dj = get_node_or_null("/root/DJManager")
	if dj == null:
		return
	if _musica_previa != "":
		dj.playMusic(_musica_previa)
	else:
		dj.stopMusic()

# ----------------------------------------------------------------
# VIDAS
# ----------------------------------------------------------------
func _actualizar_vidas() -> void:
	for i in _paws.size():
		_paws[i].alive = i < vidas_actuales

# ----------------------------------------------------------------
# CONSTRUCCIÓN DE INTERFAZ
# ----------------------------------------------------------------
func _construir_interfaz() -> void:
	# Fondo a pantalla completa
	panel = ColorRect.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.color = Color(0.14, 0.11, 0.06, 0.97)
	panel.visible = false
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel)

	# Contenido principal
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left   = 32.0
	vbox.offset_top    = 28.0
	vbox.offset_right  = -32.0
	vbox.offset_bottom = -28.0
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)
	_contentBox = vbox

	# --- Título ---
	label_titulo = Label.new()
	label_titulo.text = "🏛️ EXAMEN ALTAR ANCESTRAL"
	label_titulo.add_theme_font_size_override("font_size", FONT_SIZE + 6)
	label_titulo.add_theme_color_override("font_color", Color(0.3, 0.95, 0.85))
	label_titulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(label_titulo)

	# --- Fila: OA | Vidas | Cerrar ---
	var fila_meta = HBoxContainer.new()
	fila_meta.add_theme_constant_override("separation", 16)
	vbox.add_child(fila_meta)

	label_oa = Label.new()
	label_oa.text = "🎯 OA3  |  👤 NPC: —"
	label_oa.add_theme_font_size_override("font_size", FONT_SIZE - 2)
	label_oa.add_theme_color_override("font_color", Color(0.7, 0.85, 0.95))
	label_oa.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila_meta.add_child(label_oa)

	# Vidas (patitas)
	_livesBox = HBoxContainer.new()
	_livesBox.add_theme_constant_override("separation", 5)
	_livesBox.alignment = BoxContainer.ALIGNMENT_CENTER
	fila_meta.add_child(_livesBox)

	var lbl_vidas = Label.new()
	lbl_vidas.text = "Vidas:"
	lbl_vidas.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_vidas.add_theme_font_size_override("font_size", FONT_SIZE)
	lbl_vidas.add_theme_color_override("font_color", Color(1.0, 0.6, 0.78))
	_livesBox.add_child(lbl_vidas)

	_paws = []
	for i in MAX_VIDAS:
		var paw = PawIconScript.new()
		_livesBox.add_child(paw)
		_paws.append(paw)

	var btn_cerrar = Button.new()
	btn_cerrar.text = "✕ Cerrar"
	btn_cerrar.custom_minimum_size = Vector2(90, 34)
	btn_cerrar.mouse_filter = Control.MOUSE_FILTER_STOP
	btn_cerrar.pressed.connect(cerrar_examen)
	fila_meta.add_child(btn_cerrar)

	# --- Instrucciones ---
	label_instrucciones = Label.new()
	label_instrucciones.text = ""
	label_instrucciones.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label_instrucciones.add_theme_font_size_override("font_size", FONT_SIZE - 1)
	label_instrucciones.add_theme_color_override("font_color", Color(0.88, 0.91, 0.96))
	label_instrucciones.custom_minimum_size = Vector2(0, 50)
	vbox.add_child(label_instrucciones)

	# --- Columnas: consola (izq) + alternativas (der) ---
	var hbox = HBoxContainer.new()
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 18)
	vbox.add_child(hbox)

	# Panel consola
	var consoleWrapper = PanelContainer.new()
	consoleWrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	consoleWrapper.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	var consoleStyle = StyleBoxFlat.new()
	consoleStyle.bg_color        = Color(0.07, 0.07, 0.10, 1.0)
	consoleStyle.border_color    = Color(0.4, 0.7, 0.4, 0.8)
	consoleStyle.set_border_width_all(2)
	consoleStyle.set_corner_radius_all(6)
	consoleStyle.content_margin_left   = 12
	consoleStyle.content_margin_right  = 12
	consoleStyle.content_margin_top    = 12
	consoleStyle.content_margin_bottom = 12
	consoleWrapper.add_theme_stylebox_override("panel", consoleStyle)
	hbox.add_child(consoleWrapper)

	var consoleInner = VBoxContainer.new()
	consoleInner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	consoleInner.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	consoleWrapper.add_child(consoleInner)

	var consoleTitle = Label.new()
	consoleTitle.text = "Consola  —  Miaugoritmo en construcción"
	consoleTitle.add_theme_font_size_override("font_size", FONT_SIZE - 2)
	consoleTitle.add_theme_color_override("font_color", Color(0.5, 0.9, 0.5))
	consoleInner.add_child(consoleTitle)

	consoleScroll = ScrollContainer.new()
	consoleScroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	consoleScroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	consoleInner.add_child(consoleScroll)

	dropZone = VBoxContainer.new()
	dropZone.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dropZone.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	dropZone.add_theme_constant_override("separation", 4)
	consoleScroll.add_child(dropZone)

	# Separador
	var sep = VSeparator.new()
	hbox.add_child(sep)

	# Panel alternativas (columna derecha con Scroll)
	var rightColumn = VBoxContainer.new()
	rightColumn.custom_minimum_size = Vector2(360, 0)
	rightColumn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rightColumn.add_theme_constant_override("separation", 8)
	hbox.add_child(rightColumn)

	cmdTitle = Label.new()
	cmdTitle.text = "¿Cuál línea sigue?"
	cmdTitle.add_theme_font_size_override("font_size", FONT_SIZE + 3)
	cmdTitle.add_theme_color_override("font_color", Color(0.5, 0.9, 0.6))
	rightColumn.add_child(cmdTitle)

	stepLabel = Label.new()
	stepLabel.add_theme_font_size_override("font_size", FONT_SIZE + 1)
	stepLabel.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	rightColumn.add_child(stepLabel)

	# Feedback
	feedbackLabel = Label.new()
	feedbackLabel.custom_minimum_size = Vector2(0, 36)
	feedbackLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedbackLabel.add_theme_font_size_override("font_size", FONT_SIZE + 2)
	feedbackLabel.visible = false
	rightColumn.add_child(feedbackLabel)

	# ScrollContainer para permitir deslizar hacia abajo la pregunta y opciones
	commandScroll = ScrollContainer.new()
	commandScroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	commandScroll.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	commandScroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	commandScroll.vertical_scroll_mode   = ScrollContainer.SCROLL_MODE_AUTO
	rightColumn.add_child(commandScroll)

	commandWrapper = VBoxContainer.new()
	commandWrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	commandWrapper.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	commandWrapper.add_theme_constant_override("separation", 10)
	commandScroll.add_child(commandWrapper)

# ----------------------------------------------------------------
# CONSTRUIR SLOTS (plantilla de código)
# ----------------------------------------------------------------
func _construir_slots() -> void:
	# Limpiar dropZone
	for c in dropZone.get_children():
		c.queue_free()
	_slots = []
	_limpiar_flecha()

	var step_idx: int = 0
	for i in _plantilla.size():
		var linea: String = _plantilla[i]
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		dropZone.add_child(row)

		if linea.begins_with("[?]"):
			var emptySlot = _crear_slot_vacio()
			row.add_child(emptySlot)
			_slots.append({"row": row, "slot_node": emptySlot, "step_idx": step_idx, "kind": "empty"})
			step_idx += 1
		else:
			var bloque = _crear_bloque_fijo(linea)
			row.add_child(bloque)

func _crear_bloque_fijo(texto: String) -> PanelContainer:
	var pc = PanelContainer.new()
	pc.custom_minimum_size = Vector2(240, 42)
	pc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style = StyleBoxFlat.new()
	style.bg_color     = Color(0.10, 0.12, 0.16, 1.0)
	style.border_color = Color(0.3, 0.45, 0.55, 0.9)
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	style.content_margin_left   = 14
	style.content_margin_right  = 14
	style.content_margin_top    = 7
	style.content_margin_bottom = 7
	pc.add_theme_stylebox_override("panel", style)
	var lbl = Label.new()
	lbl.text = texto
	lbl.add_theme_font_size_override("font_size", FONT_SIZE)
	lbl.add_theme_color_override("font_color", Color(0.75, 0.88, 1.0))
	pc.add_child(lbl)
	return pc

func _crear_slot_vacio() -> PanelContainer:
	var pc = PanelContainer.new()
	pc.custom_minimum_size = Vector2(240, 42)
	pc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style = StyleBoxFlat.new()
	style.bg_color     = Color(0.10, 0.10, 0.14, 1.0)
	style.border_color = Color(0.55, 0.55, 0.65, 0.7)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.content_margin_left   = 10
	style.content_margin_right  = 10
	style.content_margin_top    = 6
	style.content_margin_bottom = 6
	pc.add_theme_stylebox_override("panel", style)
	var lbl = Label.new()
	lbl.text = "_ _ _"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_color_override("font_color", Color(0.45, 0.45, 0.55))
	lbl.add_theme_font_size_override("font_size", FONT_SIZE - 2)
	pc.add_child(lbl)
	return pc

func _crear_bloque_lleno(texto: String) -> PanelContainer:
	var pc = PanelContainer.new()
	pc.custom_minimum_size = Vector2(240, 42)
	pc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style = StyleBoxFlat.new()
	style.bg_color     = Color(0.08, 0.25, 0.22, 1.0)
	style.border_color = Color(0.3, 0.9, 0.75, 1.0)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.content_margin_left   = 14
	style.content_margin_right  = 14
	style.content_margin_top    = 7
	style.content_margin_bottom = 7
	pc.add_theme_stylebox_override("panel", style)
	var lbl = Label.new()
	lbl.text = texto
	lbl.add_theme_font_size_override("font_size", FONT_SIZE)
	lbl.add_theme_color_override("font_color", Color(0.4, 1.0, 0.85))
	pc.add_child(lbl)
	return pc

# ----------------------------------------------------------------
# CARGAR PASO ACTUAL — flecha + alternativas
# ----------------------------------------------------------------
func _cargar_paso_actual(animate_arrow: bool = true) -> void:
	_limpiar_flecha()
	_limpiar_alternativas()

	if _currentStep >= _steps.size():
		_on_examen_superado()
		return

	var total_choices = _steps.size()
	stepLabel.text = "Elección %d de %d" % [_currentStep + 1, total_choices]

	# Poner flecha en la fila del slot activo
	var target_row: HBoxContainer = null
	for slot in _slots:
		if slot["step_idx"] == _currentStep:
			target_row = slot["row"]
			break

	if target_row:
		_arrowOverlay = Label.new()
		_arrowOverlay.text = "◀"
		_arrowOverlay.add_theme_font_size_override("font_size", FONT_SIZE + 2)
		_arrowOverlay.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		_arrowOverlay.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.8))
		_arrowOverlay.add_theme_constant_override("outline_size", 3)
		_arrowOverlay.custom_minimum_size = Vector2(28, 42)
		_arrowOverlay.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_arrowOverlay.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		_arrowOverlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_arrowOverlay.modulate.a = 0.0
		target_row.add_child(_arrowOverlay)

		var tween = _arrowOverlay.create_tween().set_parallel(true)
		if animate_arrow:
			_arrowOverlay.scale = Vector2(0.5, 0.5)
			tween.tween_property(_arrowOverlay, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(_arrowOverlay, "modulate:a", 1.0, 0.20)

	# Mostrar alternativas mezcladas
	var step = _steps[_currentStep]
	var alts: Array = step["alternatives"].duplicate()
	alts.shuffle()
	_mostrar_alternativas(alts, step.get("hint", ""))

	_scroll_a_fila_activa()

func _limpiar_flecha() -> void:
	if is_instance_valid(_arrowOverlay):
		_arrowOverlay.queue_free()
	_arrowOverlay = null

func _limpiar_alternativas() -> void:
	# Vaciar por completo commandWrapper (solo contiene la pregunta del paso actual y sus opciones)
	for c in commandWrapper.get_children():
		c.queue_free()
	if commandScroll:
		commandScroll.scroll_vertical = 0

func _mostrar_alternativas(alts: Array, hint: String) -> void:
	# Subhint de contexto
	if hint != "":
		var hintLbl = Label.new()
		hintLbl.text = hint
		hintLbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hintLbl.add_theme_font_size_override("font_size", FONT_SIZE - 1)
		hintLbl.add_theme_color_override("font_color", Color(0.68, 0.8, 0.98))
		commandWrapper.add_child(hintLbl)

	for alt in alts:
		var texto: String = alt["text"]
		var correcto: bool = alt["correct"]

		var pc = PanelContainer.new()
		pc.mouse_filter = Control.MOUSE_FILTER_STOP
		var style = StyleBoxFlat.new()
		style.bg_color     = Color(0.10, 0.18, 0.28, 0.95)
		style.border_color = Color(0.3, 0.6, 0.8, 1.0)
		style.set_border_width_all(2)
		style.set_corner_radius_all(8)
		style.content_margin_left   = 14
		style.content_margin_right  = 14
		style.content_margin_top    = 10
		style.content_margin_bottom = 10
		pc.add_theme_stylebox_override("panel", style)
		pc.custom_minimum_size = Vector2(280, 48)
		pc.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var lbl = Label.new()
		lbl.text = texto
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.add_theme_font_size_override("font_size", FONT_SIZE)
		lbl.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pc.add_child(lbl)

		# Hover effect
		pc.mouse_entered.connect(func():
			if pc.mouse_filter == Control.MOUSE_FILTER_STOP:
				var hs = style.duplicate()
				hs.bg_color = Color(0.15, 0.28, 0.42, 1.0)
				pc.add_theme_stylebox_override("panel", hs)
		)
		pc.mouse_exited.connect(func():
			pc.add_theme_stylebox_override("panel", style)
		)

		# Usar InputEvent para detectar clic en el PanelContainer
		pc.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if pc.mouse_filter == Control.MOUSE_FILTER_STOP:
					_on_alternativa_elegida(texto, correcto, pc)
		)

		commandWrapper.add_child(pc)

# ----------------------------------------------------------------
# CUANDO EL JUGADOR ELIGE UNA ALTERNATIVA
# ----------------------------------------------------------------
func _on_alternativa_elegida(texto: String, correcto: bool, boton: PanelContainer) -> void:
	if mostrando_fallo:
		return

	if correcto:
		# Reemplazar el slot vacío por bloque lleno
		for slot in _slots:
			if slot["step_idx"] == _currentStep and slot["kind"] == "empty":
				var row = slot["row"]
				slot["slot_node"].queue_free()
				var bloque_lleno = _crear_bloque_lleno(texto)
				row.add_child(bloque_lleno)
				slot["kind"] = "filled"
				slot["block"] = bloque_lleno
				slot.erase("slot_node")
				break

		_mostrar_feedback("¡Correcto!", Color(0.4, 1.0, 0.5))
		_currentStep += 1

		await get_tree().create_timer(0.5).timeout
		if not mostrando_fallo:
			feedbackLabel.visible = false
			_cargar_paso_actual()
	else:
		# Bloquear este botón
		boton.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var style_err = StyleBoxFlat.new()
		style_err.bg_color     = Color(0.25, 0.06, 0.06, 0.9)
		style_err.border_color = Color(0.85, 0.2, 0.2, 1.0)
		style_err.set_border_width_all(2)
		style_err.set_corner_radius_all(8)
		style_err.content_margin_left   = 14
		style_err.content_margin_right  = 14
		style_err.content_margin_top    = 10
		style_err.content_margin_bottom = 10
		boton.add_theme_stylebox_override("panel", style_err)
		boton.modulate.a = 0.5

		vidas_actuales -= 1
		_actualizar_vidas()

		if vidas_actuales <= 0:
			_mostrar_feedback("Sin vidas. ¡Inténtalo de nuevo!", Color(1.0, 0.35, 0.35))
			await get_tree().create_timer(0.8).timeout
			await _mostrar_examen_fallido()
		else:
			_mostrar_feedback("Incorrecto — Vidas restantes: %d" % vidas_actuales, Color(1.0, 0.5, 0.4))

func _mostrar_feedback(texto: String, color: Color) -> void:
	feedbackLabel.text = texto
	feedbackLabel.add_theme_color_override("font_color", color)
	feedbackLabel.modulate.a = 1.0
	feedbackLabel.visible = true

# ----------------------------------------------------------------
# SCROLL A FILA ACTIVA
# ----------------------------------------------------------------
func _scroll_a_fila_activa() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if not visible or consoleScroll == null:
		return
	var target_row: Control = null
	for slot in _slots:
		if slot["step_idx"] == _currentStep:
			target_row = slot["row"]
			break
	if not is_instance_valid(target_row):
		return
	var bar = consoleScroll.get_v_scroll_bar()
	var maxScroll: float = maxf(0.0, bar.max_value - bar.page)
	if maxScroll <= 0.0:
		return
	var rowTop: float = target_row.global_position.y - dropZone.global_position.y
	var viewH: float = consoleScroll.size.y
	var target: float = clampf(rowTop - (viewH - target_row.size.y) / 2.0, 0.0, maxScroll)
	var tw = create_tween()
	tw.tween_property(consoleScroll, "scroll_vertical", int(target), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# ----------------------------------------------------------------
# EXAMEN SUPERADO
# ----------------------------------------------------------------
func _on_examen_superado() -> void:
	if _celebrating:
		return
	_celebrating = true
	resuelto = true
	ejercicio_idx = -1   # liberar para que el próximo examen elija otro

	_limpiar_flecha()
	_limpiar_alternativas()
	stepLabel.text = "¡Completado!"
	feedbackLabel.visible = false

	await _mostrar_completado()

	_celebrating = false
	visible = false
	panel.visible = false
	_detener_musica_examen()
	examen_aprobado.emit()
	if altar_descuidado and altar_descuidado.has_method("iniciar_secuencia_teletransporte"):
		altar_descuidado.iniciar_secuencia_teletransporte()

func _mostrar_completado() -> void:
	panel.move_to_front()

	var celebration = Control.new()
	celebration.name = "CompletionCelebration"
	celebration.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	celebration.mouse_filter = Control.MOUSE_FILTER_PASS
	panel.add_child(celebration)

	var tablonW = panel.size.x * 0.58 if panel.size.x > 0 else 640.0
	var tablonH = panel.size.y * 0.50 if panel.size.y > 0 else 340.0
	var tablonX = (panel.size.x - tablonW) * 0.5 if panel.size.x > 0 else 200.0
	var tablonTargetY = (panel.size.y - tablonH) * 0.5 if panel.size.y > 0 else 180.0

	var tablon = PanelContainer.new()
	var tablonStyle = StyleBoxFlat.new()
	tablonStyle.bg_color     = Color(0.04, 0.04, 0.07, 0.97)
	tablonStyle.border_color = Color(0.55, 0.30, 0.85, 1.0)
	tablonStyle.set_border_width_all(3)
	tablonStyle.set_corner_radius_all(12)
	tablonStyle.content_margin_left   = 24
	tablonStyle.content_margin_right  = 24
	tablonStyle.content_margin_top    = 20
	tablonStyle.content_margin_bottom = 20
	tablon.add_theme_stylebox_override("panel", tablonStyle)
	tablon.position = Vector2(tablonX, panel.size.y if panel.size.y > 0 else 900.0)
	tablon.size     = Vector2(tablonW, tablonH)
	tablon.mouse_filter = Control.MOUSE_FILTER_STOP
	celebration.add_child(tablon)

	var tw = tablon.create_tween()
	tw.tween_property(tablon, "position:y", tablonTargetY, 0.65).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	var tablonVbox = VBoxContainer.new()
	tablonVbox.add_theme_constant_override("separation", 14)
	tablon.add_child(tablonVbox)

	var textContainer = HBoxContainer.new()
	textContainer.alignment = BoxContainer.ALIGNMENT_CENTER
	textContainer.add_theme_constant_override("separation", 0)
	textContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textContainer.custom_minimum_size = Vector2(0, 60)
	tablonVbox.add_child(textContainer)

	var message = "MIAUGORITMO COMPLETADO"
	var letters: Array = []
	for i in message.length():
		var slot = Control.new()
		slot.custom_minimum_size = Vector2(22, 60)
		textContainer.add_child(slot)
		var letter = Label.new()
		letter.text = message.substr(i, 1)
		letter.position = Vector2(0, 0)
		letter.size = Vector2(22, 60)
		letter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		letter.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		letter.add_theme_font_size_override("font_size", FONT_SIZE + 16)
		letter.add_theme_color_override("font_color", Color.WHITE)
		letter.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.08, 1.0))
		letter.add_theme_constant_override("outline_size", 4)
		letter.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(letter)
		letters.append(letter)

	tablonVbox.add_child(HSeparator.new())

	var lblMsg = Label.new()
	lblMsg.text = "¡Examen aprobado!\nEstás listo para avanzar al Laboratorio Subterráneo."
	lblMsg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lblMsg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lblMsg.add_theme_font_size_override("font_size", FONT_SIZE + 2)
	lblMsg.add_theme_color_override("font_color", Color(0.8, 1.0, 0.85))
	tablonVbox.add_child(lblMsg)

	tablonVbox.add_child(HSeparator.new())

	var btn = Button.new()
	btn.text = "Continuar →"
	btn.add_theme_font_size_override("font_size", FONT_SIZE + 5)
	btn.custom_minimum_size = Vector2(220, 50)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	btn.pressed.connect(func(): _continue_pressed.emit())
	tablonVbox.add_child(btn)

	# Lanzar animación como corutina independiente (fire-and-forget)
	_animar_completado(letters, tablonStyle, tablon)

	# Esperar DIRECTAMENTE la señal — patrón 100% fiable en Godot 4
	await _continue_pressed

	celebration.queue_free()

# Corutina de animación arcoíris para la pantalla de completado.
# Se ejecuta en paralelo; termina sola cuando _celebrating pasa a false.
func _animar_completado(letters: Array, tablonStyle: StyleBoxFlat, tablon: PanelContainer) -> void:
	var startTime = Time.get_ticks_msec()
	while _celebrating and is_instance_valid(tablon):
		var elapsed = float(Time.get_ticks_msec() - startTime) / 1000.0
		var hueBase = fmod(elapsed * 0.22, 1.0)
		for i in letters.size():
			var letter: Label = letters[i]
			if not is_instance_valid(letter):
				return
			letter.position.y = sin(elapsed * 7.0 - float(i) * 0.55) * 6.0
			var letterHue = fmod(hueBase + float(i) / max(1.0, float(letters.size())) * 0.85, 1.0)
			letter.add_theme_color_override("font_color", Color.from_hsv(letterHue, 0.72, 1.0))
		tablonStyle.border_color = Color.from_hsv(fmod(hueBase * 1.5, 1.0), 0.65, 1.0)
		tablon.add_theme_stylebox_override("panel", tablonStyle)
		await get_tree().process_frame

# ----------------------------------------------------------------
# EXAMEN FALLIDO
# ----------------------------------------------------------------
func _mostrar_examen_fallido() -> void:
	mostrando_fallo = true
	_reintentar_elegido = true

	var overlay = ColorRect.new()
	overlay.name = "ExamFailedOverlay"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.0, 0.0, 0.0, 0.82)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_child(overlay)

	var tablonW = 560.0
	var tablonH = 280.0
	var pW = panel.size.x if panel.size.x > 0 else 1024.0
	var pH = panel.size.y if panel.size.y > 0 else 768.0
	var tablonX = (pW - tablonW) * 0.5
	var tablonTargetY = (pH - tablonH) * 0.5

	var tablon = PanelContainer.new()
	var tablonStyle = StyleBoxFlat.new()
	tablonStyle.bg_color     = Color(0.08, 0.02, 0.02, 0.97)
	tablonStyle.border_color = Color(0.85, 0.10, 0.10, 1.0)
	tablonStyle.set_border_width_all(3)
	tablonStyle.set_corner_radius_all(12)
	tablonStyle.content_margin_left   = 24
	tablonStyle.content_margin_right  = 24
	tablonStyle.content_margin_top    = 20
	tablonStyle.content_margin_bottom = 20
	tablon.add_theme_stylebox_override("panel", tablonStyle)
	tablon.position = Vector2(tablonX, pH)
	tablon.size     = Vector2(tablonW, tablonH)
	tablon.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(tablon)

	var tw = tablon.create_tween()
	tw.tween_property(tablon, "position:y", tablonTargetY, 0.65).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	var tablonVbox = VBoxContainer.new()
	tablonVbox.add_theme_constant_override("separation", 14)
	tablon.add_child(tablonVbox)

	var textContainer = HBoxContainer.new()
	textContainer.alignment = BoxContainer.ALIGNMENT_CENTER
	textContainer.add_theme_constant_override("separation", 0)
	textContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textContainer.custom_minimum_size = Vector2(0, 60)
	tablonVbox.add_child(textContainer)

	var message = "EXAMEN FALLIDO"
	var letters: Array = []
	for i in message.length():
		var slot = Control.new()
		slot.custom_minimum_size = Vector2(30, 60)
		textContainer.add_child(slot)
		var letter = Label.new()
		letter.text = message.substr(i, 1)
		letter.position = Vector2(0, 0)
		letter.size = Vector2(30, 60)
		letter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		letter.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		letter.add_theme_font_size_override("font_size", FONT_SIZE + 16)
		letter.add_theme_color_override("font_color", Color(1.0, 0.15, 0.15))
		letter.add_theme_color_override("font_outline_color", Color(0.05, 0.00, 0.00, 1.0))
		letter.add_theme_constant_override("outline_size", 4)
		letter.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(letter)
		letters.append(letter)

	tablonVbox.add_child(HSeparator.new())

	var lblMsg = Label.new()
	lblMsg.text = "Cometiste 3 errores. Debes intentarlo de nuevo."
	lblMsg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lblMsg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lblMsg.add_theme_font_size_override("font_size", FONT_SIZE + 2)
	lblMsg.add_theme_color_override("font_color", Color(0.95, 0.75, 0.75))
	tablonVbox.add_child(lblMsg)

	tablonVbox.add_child(HSeparator.new())

	var btnRow = HBoxContainer.new()
	btnRow.alignment = BoxContainer.ALIGNMENT_CENTER
	btnRow.add_theme_constant_override("separation", 16)
	tablonVbox.add_child(btnRow)

	var btnRetry = Button.new()
	btnRetry.text = "Intentar de nuevo"
	btnRetry.add_theme_font_size_override("font_size", FONT_SIZE + 5)
	btnRetry.custom_minimum_size = Vector2(240, 50)
	btnRetry.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btnRetry.mouse_filter = Control.MOUSE_FILTER_STOP
	btnRetry.pressed.connect(func():
		_reintentar_elegido = true
		_retry_pressed.emit())
	btnRow.add_child(btnRetry)

	var btnNoRetry = Button.new()
	btnNoRetry.text = "No reintentar"
	btnNoRetry.add_theme_font_size_override("font_size", FONT_SIZE + 5)
	btnNoRetry.custom_minimum_size = Vector2(220, 50)
	btnNoRetry.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btnNoRetry.mouse_filter = Control.MOUSE_FILTER_STOP
	btnNoRetry.pressed.connect(func():
		_reintentar_elegido = false
		_retry_pressed.emit())
	btnRow.add_child(btnNoRetry)
	btnRetry.grab_focus()

	# Lanzar la animación en una corutina independiente en paralelo
	_animar_fallido(letters, tablonStyle, tablon)

	# Esperar DIRECTAMENTE la señal — patrón 100% fiable en Godot 4
	await _retry_pressed

	overlay.queue_free()
	if _reintentar_elegido:
		_reiniciar_ejercicio()
	else:
		mostrando_fallo = false
		cerrar_examen()

func _animar_fallido(letters: Array, tablonStyle: StyleBoxFlat, tablon: PanelContainer) -> void:
	var startTime = Time.get_ticks_msec()
	while mostrando_fallo and is_instance_valid(tablon):
		var elapsed = float(Time.get_ticks_msec() - startTime) / 1000.0
		for i in letters.size():
			var letter: Label = letters[i]
			if not is_instance_valid(letter):
				return
			letter.position.y = sin(elapsed * 5.0 - float(i) * 0.4) * 5.0
			var brightness = 0.7 + 0.3 * abs(sin(elapsed * 2.5 + float(i) * 0.3))
			letter.add_theme_color_override("font_color", Color(brightness, 0.05, 0.05))
		var borderHue = 0.02 + 0.04 * abs(sin(elapsed * 1.2))
		tablonStyle.border_color = Color.from_hsv(borderHue, 0.95, 0.9)
		tablon.add_theme_stylebox_override("panel", tablonStyle)
		await get_tree().process_frame

func _reiniciar_ejercicio() -> void:
	mostrando_fallo  = false
	vidas_actuales   = MAX_VIDAS
	resuelto         = false
	_currentStep     = 0
	_celebrating     = false
	feedbackLabel.visible = false
	feedbackLabel.text    = ""

	# ── Req. 1: elegir una variante DISTINTA a la que acaba de fallar ──
	# Construir la lista de índices posibles excluyendo el fallado (2 restantes de 3).
	var puntajes = get_node_or_null("/root/PuntajesNivel2")
	if puntajes and puntajes.has_method("seleccionar_examen_aleatorio"):
		ejercicio_idx = puntajes.seleccionar_examen_aleatorio(_ultimo_ejercicio_idx)
	else:
		var total = BANCO_EXAMEN.size()
		if total > 1:
			var candidatos: Array = []
			for i in total:
				if i != _ultimo_ejercicio_idx:
					candidatos.append(i)
			candidatos.shuffle()
			ejercicio_idx = candidatos[0]
	_ultimo_ejercicio_idx = ejercicio_idx

	# Recargar datos del nuevo ejercicio
	ejercicio_actual = BANCO_EXAMEN[ejercicio_idx]
	_steps           = ejercicio_actual["steps"]
	_plantilla       = ejercicio_actual["plantilla"]

	label_titulo.text        = "🏛️ EXAMEN ALTAR ANCESTRAL  ·  " + ejercicio_actual["titulo"]
	label_oa.text            = "🎯 " + ejercicio_actual["oa"] + "   |   👤 NPC: " + ejercicio_actual["npc"]
	label_instrucciones.text = ejercicio_actual["instrucciones"]

	_actualizar_vidas()
	_construir_slots()
	_cargar_paso_actual()

# ----------------------------------------------------------------
# INPUT — ESC cierra, ENTER reintenta si está en pantalla de fallo
# ----------------------------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if mostrando_fallo:
		if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_ENTER and not event.echo):
			get_viewport().set_input_as_handled()
			_reintentar_elegido = true
			_retry_pressed.emit()
			return
		if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE and not event.echo):
			get_viewport().set_input_as_handled()
			_reintentar_elegido = false
			_retry_pressed.emit()
			return
	if event.is_action_pressed("ui_cancel") or \
		(event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE and not event.echo):
		get_viewport().set_input_as_handled()
		cerrar_examen()
