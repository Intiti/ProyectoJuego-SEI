extends RefCounted

# ─────────────────────────────────────────────────────────────────────────────
#  EjercicioEstilo — presentación y feedback compartidos de los ejercicios.
#
#  El Nivel 1 (puzzleManager) define cómo se ve y cómo suena un ejercicio:
#  paleta, instrucción con palabras coloreadas, consola verde, "Correcto!" en
#  verde con su sonidito, sacudida al fallar y "RACHA xN" flotante.
#  Este módulo concentra esos mismos detalles para que las ventanas de los
#  niveles 2 y 3 (que arman el programa y luego pulsan Comprobar) se sientan
#  igual, sin cambiar su mecánica.
#
#  Todo son funciones estáticas:
#      const Estilo = preload("res://scripts/common/ui/ejercicioEstilo.gd")
#      panel.add_theme_stylebox_override("panel", Estilo.windowStyle())
#      Estilo.playOk(ventana)      # sonido + RACHA xN si corresponde
#      Estilo.playError(ventana)   # sonido de error + sacudida
# ─────────────────────────────────────────────────────────────────────────────

# Paleta (la misma del puzzle del Nivel 1 y del ScoreHud)
const BG            := Color(0.14, 0.11, 0.06, 0.97)
const BORDER        := Color(0.80, 0.75, 1.00, 1.0)
const TITLE         := Color(0.90, 0.85, 1.00)
const TEXT          := Color(0.92, 0.92, 0.92)
const CONSOLE_BG    := Color(0.07, 0.07, 0.10, 1.0)
const CONSOLE_BORDER := Color(0.40, 0.70, 0.40, 0.80)
const CONSOLE_TITLE := Color(0.50, 0.90, 0.50)
const HEADING       := Color(0.50, 0.90, 0.60)
const OK            := Color(0.40, 1.00, 0.50)
const ERR           := Color(1.00, 0.45, 0.35)

const STREAK_COLORS: Array[Color] = [
	Color(1.0, 0.3, 0.3),
	Color(1.0, 0.7, 0.1),
	Color(0.3, 1.0, 0.4),
	Color(0.2, 0.8, 1.0),
	Color(0.8, 0.3, 1.0),
]

const PROMPT_HEADING := "Instrucción del nivel"
const OK_HOLD := 1.0   # segundos que se ve el "¡Correcto!" antes de pasar al completado

# ── Estilos ───────────────────────────────────────────────────────────────────

static func windowStyle(radius: int = 16) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = BG
	sb.border_color = BORDER
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = 24
	sb.content_margin_right = 24
	sb.content_margin_top = 18
	sb.content_margin_bottom = 18
	return sb

# Panel de "Consola" del Nivel 1 (fondo oscuro, borde verde).
static func consoleStyle() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = CONSOLE_BG
	sb.border_color = CONSOLE_BORDER
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	return sb

# Estilo "arcoíris" que el Nivel 1 aplica a los bloques al completar un ejercicio.
static func rainbowStyle(index: int, total: int, hueBase: float = 0.0) -> StyleBoxFlat:
	var hue: float = fmod(hueBase + float(index) / maxf(1.0, float(total)) * 0.75, 1.0)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color.from_hsv(hue, 0.78, 0.92)
	sb.border_color = Color.from_hsv(fmod(hue + 0.12, 1.0), 0.45, 1.0)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	return sb

# ── Instrucción ───────────────────────────────────────────────────────────────

# Mismos colores de palabras que el Nivel 1: textos entre comillas, tipos de dato,
# palabras de orden, input(), print y los "Si".
static func colorizePrompt(text: String) -> String:
	# Los corchetes del texto no deben interpretarse como etiquetas BBCode.
	var result: String = text.replace("[", "[lb]")
	var quoteRegex := RegEx.new()
	quoteRegex.compile("\"([^\"]+)\"")
	result = quoteRegex.sub(result, "[color=#ffb86c]\"$1\"[/color]", true)
	var typeRegex := RegEx.new()
	typeRegex.compile("(enteros?|decimales)")
	result = typeRegex.sub(result, "[color=#7eb8f7]$1[/color]", true)
	var orderRegex := RegEx.new()
	orderRegex.compile("(?i)\\b(primero|luego|después)\\b")
	result = orderRegex.sub(result, "[color=#f9a8d4]$1[/color]", true)
	result = result.replace("input()", "[color=#7eb8f7]input()[/color]")
	result = result.replace("print", "[color=#7defa0]print[/color]")
	result = result.replace("Si no", "[color=#c084fc]Si no[/color]")
	result = result.replace("Si el", "[color=#f0d060]Si[/color] el")
	return result

# Texto de instrucción con el mismo coloreado que el Nivel 1.
static func makePrompt(text: String, fontSize: int = 18) -> RichTextLabel:
	var rt := RichTextLabel.new()
	rt.bbcode_enabled = true
	rt.fit_content = true
	rt.scroll_active = false
	rt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rt.add_theme_font_size_override("normal_font_size", fontSize)
	rt.add_theme_color_override("default_color", TEXT)
	setPromptText(rt, text)
	return rt

static func setPromptText(rt: RichTextLabel, text: String) -> void:
	rt.text = colorizePrompt(text)

# Encabezado "Instrucción del nivel" del Nivel 1.
static func makeHeading(fontSize: int = 22) -> Label:
	var l := Label.new()
	l.text = PROMPT_HEADING
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_size_override("font_size", fontSize)
	l.add_theme_color_override("font_color", TITLE)
	return l

# ── Sonidos y efectos (los mismos del Nivel 1) ────────────────────────────────

# Acierto: sonido de racha si la racha global es >= 3 (con su "RACHA xN"), si no el
# "correcto" normal. Llamar DESPUÉS de acreditar el ejercicio para que la racha ya
# esté actualizada.
static func playOk(host: Control) -> void:
	var n: int = GameData.rachaGlobal
	if n >= GameData.STREAK_BONUS_MIN:
		DJManager.playStreak(n)
		streakPopup(host, n)
	else:
		DJManager.playCorrect()

# Fallo: sonido de error y sacudida de la ventana.
static func playError(host: Control) -> void:
	DJManager.playError()
	shake(host)

static func playFanfare() -> void:
	DJManager.playFanfare()

# "RACHA xN" flotante, con los colores cíclicos del Nivel 1.
static func streakPopup(host: Control, n: int) -> void:
	if host == null or not host.is_inside_tree():
		return
	var lbl := Label.new()
	lbl.text = "RACHA x%d" % n
	lbl.add_theme_font_size_override("font_size", 52)
	lbl.add_theme_color_override("font_color", STREAK_COLORS[n % STREAK_COLORS.size()])
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	lbl.add_theme_constant_override("shadow_offset_x", 3)
	lbl.add_theme_constant_override("shadow_offset_y", 3)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.top_level = true   # los contenedores no la acomodan: flota libre sobre la ventana
	lbl.z_index = 100
	host.add_child(lbl)
	var rect: Rect2 = host.get_global_rect()
	var start := Vector2(rect.position.x + rect.size.x * 0.5 - 150.0, rect.position.y + 80.0)
	lbl.global_position = start
	var tw := lbl.create_tween()
	tw.set_parallel(true)
	tw.tween_property(lbl, "position:y", start.y - 100.0, OK_HOLD).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(lbl, "modulate:a", 0.0, OK_HOLD).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(lbl.queue_free)

# Temblor corto de la ventana (misma fuerza y duración que el Nivel 1). Si la ventana se
# construyó con buildScreen() se sacude el contenido por offsets, exactamente como el puzzle
# del Nivel 1; si no, se mueve la posición de la ventana.
static func shake(host: Control, strength: float = 9.0, duration: float = 0.4) -> void:
	if host == null or not host.is_inside_tree():
		return
	var target = host.get_meta("shake_target") if host.has_meta("shake_target") else null
	if target is Control and is_instance_valid(target):
		_shakeOffsets(host, target, strength, duration)
		return
	var base: Vector2 = host.position
	if host.has_meta("_shake_base"):
		base = host.get_meta("_shake_base")
	host.set_meta("_shake_base", base)
	_killShake(host)
	var steps: int = 8
	var dt: float = duration / float(steps + 1)
	var tw := host.create_tween()
	host.set_meta("_shake_tween", tw)
	for i in steps:
		var decay: float = 1.0 - float(i) / float(steps)
		var dir: float = 1.0 if i % 2 == 0 else -1.0
		var off := Vector2(dir * randf_range(0.6, 1.0), randf_range(-0.5, 0.5)) * strength * decay
		tw.tween_property(host, "position", base + off, dt)
	tw.tween_property(host, "position", base, dt)
	tw.tween_callback(func() -> void:
		if is_instance_valid(host):
			host.remove_meta("_shake_base")
			host.remove_meta("_shake_tween")
	)

static func _killShake(host: Control) -> void:
	if host.has_meta("_shake_tween"):
		var old = host.get_meta("_shake_tween")
		if old is Tween and old.is_valid():
			old.kill()

static func _shakeOffsets(host: Control, target: Control, strength: float, duration: float) -> void:
	var base: Array = [target.offset_left, target.offset_top, target.offset_right, target.offset_bottom]
	if host.has_meta("_shake_offsets"):
		base = host.get_meta("_shake_offsets")
	host.set_meta("_shake_offsets", base)
	_killShake(host)
	var apply := func(v: Vector2) -> void:
		if is_instance_valid(target):
			target.offset_left = base[0] + v.x
			target.offset_top = base[1] + v.y
			target.offset_right = base[2] + v.x
			target.offset_bottom = base[3] + v.y
	var steps: int = 8
	var dt: float = duration / float(steps + 1)
	var tw := host.create_tween()
	host.set_meta("_shake_tween", tw)
	var prev := Vector2.ZERO
	for i in steps:
		var decay: float = 1.0 - float(i) / float(steps)
		var dir: float = 1.0 if i % 2 == 0 else -1.0
		var off := Vector2(dir * randf_range(0.6, 1.0), randf_range(-0.5, 0.5)) * strength * decay
		tw.tween_method(apply, prev, off, dt)
		prev = off
	tw.tween_method(apply, prev, Vector2.ZERO, dt)
	tw.tween_callback(func() -> void:
		if is_instance_valid(host):
			host.remove_meta("_shake_offsets")
			host.remove_meta("_shake_tween")
	)

# ═════════════════════════════════════════════════════════════════════════════
#  PANTALLA DE EJERCICIO (la misma del puzzle del Nivel 1)
# ═════════════════════════════════════════════════════════════════════════════

# Colores de bloque del Nivel 1 (CommandBlock)
const COLOR_INPUT  := Color(0.20, 0.45, 0.85, 1.0)
const COLOR_IF     := Color(0.65, 0.45, 0.08, 1.0)
const COLOR_ELSE   := Color(0.45, 0.15, 0.65, 1.0)
const COLOR_WHILE  := Color(0.78, 0.22, 0.52, 1.0)   # ciclos (while / for): ya no comparten el color de if
const COLOR_PRINT  := Color(0.12, 0.52, 0.30, 1.0)
const COLOR_ASSIGN := Color(0.50, 0.20, 0.20, 1.0)
const COLOR_EXPR   := Color(0.20, 0.55, 0.60, 1.0)
const BLOCK_FONT   := 17
const INDENT_PX    := 20.0   # sangría por nivel, igual que el Nivel 1

# Tipo de bloque según el texto de la línea (mismos colores que el Nivel 1).
static func blockColor(text: String) -> Color:
	var t: String = text.strip_edges()
	if t.begins_with("else"):
		return COLOR_ELSE
	if t.begins_with("while") or t.begins_with("for "):
		return COLOR_WHILE
	if t.begins_with("if") or t.begins_with("elif"):
		return COLOR_IF
	if t.contains("input("):
		return COLOR_INPUT
	if t.begins_with("print"):
		return COLOR_PRINT
	for op in ["+=", "-=", "*=", "/="]:
		if t.contains(op):
			return COLOR_EXPR
	var arith := RegEx.new()
	arith.compile("^[^=<>!\\s]+\\s*(\\+|-|\\*|/)?=\\s*.*[A-Za-z_0-9\\)\\]]\\s*(\\+|-|\\*|/)\\s*[A-Za-z_0-9\\(\\-]")
	if arith.search(t) != null:
		return COLOR_EXPR
	return COLOR_ASSIGN

# Sangría en niveles: 4 espacios = 1 nivel.
static func indentLevel(text: String) -> int:
	var n: int = 0
	for ch in text:
		if ch == " ":
			n += 1
		elif ch == "\t":
			n += 4
		else:
			break
	return n / 4

static func _blockBox(bg: Color, border: Color = Color(0, 0, 0, 0), borderW: int = 0) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(borderW)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	return sb

# Bloque ya "en el código": oscurecido con borde gris (CommandBlock.setLocked).
static func lockedStyle(text: String) -> StyleBoxFlat:
	return _blockBox(blockColor(text).darkened(0.35), Color(0.55, 0.55, 0.55, 1.0), 2)

# Bloque del banco que ya se usó (atenuado, con borde gris).
static func usedStyle(text: String) -> StyleBoxFlat:
	return _blockBox(blockColor(text).darkened(0.6), Color(0.35, 0.35, 0.35, 1.0), 2)

# Bloque marcado como incorrecto (CommandBlock.setWrongLocked).
static func wrongStyle() -> StyleBoxFlat:
	return _blockBox(Color(0.16, 0.11, 0.11, 1.0), Color(0.85, 0.25, 0.25, 1.0), 2)

# Hueco vacío del código (PuzzleManager._makeEmptySlot).
static func makeEmptySlot() -> PanelContainer:
	var pc := PanelContainer.new()
	pc.custom_minimum_size = Vector2(220, 44)
	pc.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	pc.add_theme_stylebox_override("panel", _blockBox(Color(0.10, 0.10, 0.14, 1.0), Color(0.55, 0.55, 0.65, 0.7), 2))
	var lbl := Label.new()
	lbl.text = "_ _ _"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.add_theme_color_override("font_color", Color(0.45, 0.45, 0.55))
	lbl.add_theme_font_size_override("font_size", BLOCK_FONT - 2)
	pc.add_child(lbl)
	return pc

# Bloque del código: mode = "locked" (línea fija o ya colocada) o "wrong" (marcado incorrecto).
static func makeCodeBlock(text: String, mode: String = "locked") -> PanelContainer:
	var pc := PanelContainer.new()
	pc.custom_minimum_size = Vector2(220, 44)
	pc.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	pc.add_theme_stylebox_override("panel", wrongStyle() if mode == "wrong" else lockedStyle(text))
	var lbl := Label.new()
	lbl.name = "Texto"
	lbl.text = text.strip_edges()
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.add_theme_font_size_override("font_size", BLOCK_FONT)
	lbl.add_theme_color_override("font_color", Color(0.6, 0.45, 0.45, 1.0) if mode == "wrong" else Color(1, 1, 1))
	pc.add_child(lbl)
	return pc

# Desplaza la consola hasta dejar visible la fila indicada (equivale al auto-scroll del Nivel 1).
static func ensureVisible(node: Control) -> void:
	if node == null or not node.is_inside_tree():
		return
	var tree: SceneTree = node.get_tree()
	await tree.process_frame
	await tree.process_frame
	if not is_instance_valid(node):
		return
	var p: Node = node.get_parent()
	while p != null and not (p is ScrollContainer):
		p = p.get_parent()
	if p != null:
		(p as ScrollContainer).ensure_control_visible(node)

# Fila de la consola: sangría + bloque (+ flecha amarilla si es el hueco activo).
static func makeRow(indent: int, content: Control, withArrow: bool = false) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	if indent > 0:
		var sp := Control.new()
		sp.custom_minimum_size = Vector2(float(indent) * INDENT_PX, 0)
		row.add_child(sp)
	row.add_child(content)
	if withArrow:
		row.add_child(makeArrow())
	return row

static func makeArrow() -> Label:
	var a := Label.new()
	a.name = "Flecha"
	a.text = "◀"
	a.add_theme_font_size_override("font_size", BLOCK_FONT + 2)
	a.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	a.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.8))
	a.add_theme_constant_override("outline_size", 3)
	a.custom_minimum_size = Vector2(28, 44)
	a.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	a.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	a.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return a

# Botón del banco con el aspecto de las alternativas del Nivel 1 (bloque de color).
static func styleBankButton(btn: Button, text: String) -> void:
	var col: Color = blockColor(text)
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.autowrap_mode = TextServer.AUTOWRAP_OFF
	btn.clip_text = false
	btn.custom_minimum_size = Vector2(220, 44)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	btn.focus_mode = Control.FOCUS_NONE
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.add_theme_font_size_override("font_size", BLOCK_FONT)
	var normal := _blockBox(col)
	var hover := _blockBox(col.lightened(0.12))
	var used := _blockBox(col.darkened(0.6), Color(0.35, 0.35, 0.35, 1.0), 2)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", hover)
	btn.add_theme_stylebox_override("focus", normal)
	btn.add_theme_stylebox_override("disabled", used)
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		btn.add_theme_color_override(c, Color(1, 1, 1))
	btn.add_theme_color_override("font_disabled_color", Color(0.55, 0.55, 0.55))

# Botón de acción con la paleta del juego. kind: "primary" | "neutral" | "warn" | "danger".
static func styleActionButton(btn: Button, text: String, kind: String = "neutral") -> void:
	var fill := Color(0.20, 0.16, 0.42, 1.0)
	var border := BORDER
	match kind:
		"primary":
			fill = COLOR_PRINT
			border = Color(0.45, 0.90, 0.60, 1.0)
		"warn":
			fill = COLOR_IF
			border = Color(0.95, 0.75, 0.30, 1.0)
		"danger":
			fill = COLOR_ASSIGN
			border = Color(0.95, 0.45, 0.45, 1.0)
	btn.text = text
	btn.custom_minimum_size = Vector2(140, 46)
	btn.focus_mode = Control.FOCUS_NONE
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.add_theme_font_size_override("font_size", 19)
	var normal := _blockBox(fill, border, 2)
	normal.set_corner_radius_all(8)
	var hover := _blockBox(fill.lightened(0.15), border, 2)
	hover.set_corner_radius_all(8)
	var dis := _blockBox(fill.darkened(0.55), Color(0.35, 0.35, 0.35, 1.0), 2)
	dis.set_corner_radius_all(8)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", hover)
	btn.add_theme_stylebox_override("focus", normal)
	btn.add_theme_stylebox_override("disabled", dis)
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		btn.add_theme_color_override(c, Color(1, 1, 1))
	btn.add_theme_color_override("font_disabled_color", Color(0.55, 0.55, 0.55))

# Construye dentro de `window` la misma pantalla que el puzzle del Nivel 1:
#   · fondo a pantalla completa (marcos de 32 px)
#   · "Instrucción del nivel" + texto de la instrucción
#   · consola con borde verde a la izquierda y columna de bloques a la derecha
#   · fila inferior para los botones de acción
# Devuelve las referencias a los nodos para que cada nivel enchufe su lógica.
static func buildScreen(window: PanelContainer, rightTitle: String = "Bloques disponibles") -> Dictionary:
	window.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	window.custom_minimum_size = Vector2.ZERO
	window.mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := StyleBoxFlat.new()
	bg.bg_color = BG
	window.add_theme_stylebox_override("panel", bg)

	var shakeRoot := Control.new()
	shakeRoot.name = "ShakeRoot"
	shakeRoot.mouse_filter = Control.MOUSE_FILTER_PASS
	shakeRoot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shakeRoot.size_flags_vertical = Control.SIZE_EXPAND_FILL
	window.add_child(shakeRoot)

	var vbox := VBoxContainer.new()
	vbox.name = "Contenido"
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 32.0
	vbox.offset_top = 32.0
	vbox.offset_right = -32.0
	vbox.offset_bottom = -32.0
	vbox.add_theme_constant_override("separation", 12)
	vbox.mouse_filter = Control.MOUSE_FILTER_PASS
	shakeRoot.add_child(vbox)
	window.set_meta("shake_target", vbox)

	# Encabezado: "Instrucción del nivel" + nombre del ejercicio a la derecha
	var headRow := HBoxContainer.new()
	headRow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(headRow)
	var titleRight := Label.new()
	titleRight.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titleRight.add_theme_font_size_override("font_size", 20)
	titleRight.add_theme_color_override("font_color", Color(0.82, 0.78, 1.0))
	titleRight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	headRow.add_child(titleRight)

	var prompt: RichTextLabel = makePrompt("", 20)
	prompt.custom_minimum_size = Vector2(0, 60)
	vbox.add_child(prompt)

	var hbox := HBoxContainer.new()
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 16)
	hbox.mouse_filter = Control.MOUSE_FILTER_PASS
	vbox.add_child(hbox)

	# Consola (izquierda)
	var consoleWrap := PanelContainer.new()
	consoleWrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	consoleWrap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	consoleWrap.add_theme_stylebox_override("panel", consoleStyle())
	hbox.add_child(consoleWrap)
	var consoleInner := VBoxContainer.new()
	consoleInner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	consoleInner.size_flags_vertical = Control.SIZE_EXPAND_FILL
	consoleWrap.add_child(consoleInner)
	var consoleTitle := Label.new()
	consoleTitle.text = "Consola"
	consoleTitle.add_theme_font_size_override("font_size", 16)
	consoleTitle.add_theme_color_override("font_color", CONSOLE_TITLE)
	consoleInner.add_child(consoleTitle)
	var codeScroll := ScrollContainer.new()
	codeScroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	codeScroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	consoleInner.add_child(codeScroll)
	var codeBox := VBoxContainer.new()
	codeBox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	codeBox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	codeBox.add_theme_constant_override("separation", 4)
	codeScroll.add_child(codeBox)

	hbox.add_child(VSeparator.new())

	# Columna de bloques (derecha)
	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(400, 0)
	right.add_theme_constant_override("separation", 8)
	hbox.add_child(right)
	var rightLbl := Label.new()
	rightLbl.text = rightTitle
	rightLbl.add_theme_font_size_override("font_size", 22)
	rightLbl.add_theme_color_override("font_color", HEADING)
	right.add_child(rightLbl)
	var stepLabel := Label.new()
	stepLabel.add_theme_font_size_override("font_size", 20)
	stepLabel.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	right.add_child(stepLabel)
	var bankScroll := ScrollContainer.new()
	bankScroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bankScroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	right.add_child(bankScroll)
	var bankBox := VBoxContainer.new()
	bankBox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bankBox.add_theme_constant_override("separation", 10)
	bankScroll.add_child(bankBox)
	# Fila inferior: mensajes de acierto/error y pista a la izquierda, botones de acción a la derecha
	var bottom := HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 16)
	vbox.add_child(bottom)
	var msgBox := VBoxContainer.new()
	msgBox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	msgBox.size_flags_vertical = Control.SIZE_SHRINK_END
	msgBox.add_theme_constant_override("separation", 2)
	bottom.add_child(msgBox)
	var feedback := Label.new()
	feedback.custom_minimum_size = Vector2(0, 26)
	feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback.add_theme_font_size_override("font_size", 17)
	msgBox.add_child(feedback)
	var hintPanel := PanelContainer.new()
	hintPanel.visible = false
	hintPanel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	msgBox.add_child(hintPanel)
	var hintLabel := Label.new()
	hintLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hintLabel.add_theme_font_size_override("font_size", 15)
	hintLabel.add_theme_color_override("font_color", Color(0.94, 0.82, 0.38))
	hintPanel.add_child(hintLabel)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_END
	buttons.size_flags_vertical = Control.SIZE_SHRINK_END
	buttons.add_theme_constant_override("separation", 12)
	bottom.add_child(buttons)

	return {
		"shake_root": shakeRoot, "content": vbox, "title_right": titleRight, "prompt": prompt,
		"console_title": consoleTitle, "code_scroll": codeScroll, "code_box": codeBox,
		"right_title": rightLbl, "step_label": stepLabel, "bank_scroll": bankScroll, "bank_box": bankBox,
		"feedback": feedback, "hint_panel": hintPanel, "hint_label": hintLabel, "buttons": buttons, "head_row": headRow,
	}


# ═════════════════════════════════════════════════════════════════════════════
#  TABLÓN DE COMPLETADO (el mismo del Nivel 1)
# ═════════════════════════════════════════════════════════════════════════════

# Bloques (PanelContainer) de una lista de filas, para pintarlos en arcoíris.
static func collectBlocks(box: Node) -> Array:
	var out: Array = []
	if box == null:
		return out
	for fila in box.get_children():
		for hijo in fila.get_children():
			if hijo is PanelContainer:
				out.append(hijo)
	return out

# Arma las líneas de puntaje con el mismo formato del Nivel 1 a partir del desglose de GameData.
static func scoreLines(level: int, blocks: int, errors: int, d: Dictionary, repeat: bool = false) -> Dictionary:
	if repeat or d.is_empty():
		return {"base": "Ejercicio ya completado: no suma puntos adicionales", "pen": "", "bonus": "",
			"total": "Total:  0 pts   (Gatopuntos acumulados: %d)" % GameData.gatopuntos}
	var base: String = "Puntaje base  (%d bloques × %d):  %d pts" % [blocks, int(GameData.POINTS_PER_BLOCK.get(level, 20)), int(d["base"])]
	var pen: String = ""
	if int(d["pen"]) > 0:
		pen = "Penalización  (%d errores, -%s):  -%d pts" % [errors, "25%" if errors == 2 else "50%", int(d["pen"])]
	var bonus: String = ""
	if int(d["bonus"]) > 0:
		bonus = "Bonus racha  (racha de %d):  +%d pts" % [GameData.rachaGlobal, int(d["bonus"])]
	return {"base": base, "pen": pen, "bonus": bonus,
		"total": "Total:  %d pts   (Gatopuntos acumulados: %d)" % [int(d["total"]), GameData.gatopuntos]}

# Muestra el tablón de "MIAUGORITMO COMPLETADO" sobre `host`, con los bloques en arcoíris y el
# título ondulando hasta que el jugador pulsa un botón. Es idéntico al del Nivel 1.
# opts: title, base, pen, bonus, total, notes (Array[String]), continue_text, extra_button.
# Devuelve "continuar" o "extra".
static func playTablon(host: Control, blocks: Array, opts: Dictionary) -> String:
	if host == null or not host.is_inside_tree():
		return "continuar"
	var tree: SceneTree = host.get_tree()
	var fontSize: int = 18

	var celebration := Control.new()
	celebration.name = "CompletionCelebration"
	celebration.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	celebration.mouse_filter = Control.MOUSE_FILTER_PASS
	host.add_child(celebration)

	var W: float = host.size.x
	var H: float = host.size.y
	var tablonW: float = minf(W * 0.58, 760.0)
	var tablonH: float = H * 0.50
	var tablonX: float = (W - tablonW) * 0.5

	var tablon := PanelContainer.new()
	var tablonStyle := StyleBoxFlat.new()
	tablonStyle.bg_color = Color(0.04, 0.04, 0.07, 0.97)
	tablonStyle.border_color = Color(0.55, 0.30, 0.85, 1.0)
	tablonStyle.set_border_width_all(3)
	tablonStyle.set_corner_radius_all(12)
	tablonStyle.content_margin_left = 24
	tablonStyle.content_margin_right = 24
	tablonStyle.content_margin_top = 20
	tablonStyle.content_margin_bottom = 20
	tablon.add_theme_stylebox_override("panel", tablonStyle)
	tablon.custom_minimum_size = Vector2(tablonW, tablonH)
	tablon.position = Vector2(tablonX, H)
	tablon.size = Vector2(tablonW, tablonH)
	tablon.mouse_filter = Control.MOUSE_FILTER_STOP
	celebration.add_child(tablon)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 14)
	tablon.add_child(vb)

	# Título con letras que ondulan y cambian de color
	var textContainer := HBoxContainer.new()
	textContainer.alignment = BoxContainer.ALIGNMENT_CENTER
	textContainer.add_theme_constant_override("separation", 0)
	textContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textContainer.custom_minimum_size = Vector2(0, 60)
	vb.add_child(textContainer)
	var message: String = String(opts.get("title", "MIAUGORITMO COMPLETADO"))
	var letters: Array = []
	for i in message.length():
		var slot := Control.new()
		slot.custom_minimum_size = Vector2(22, 60)
		textContainer.add_child(slot)
		var letter := Label.new()
		letter.text = message.substr(i, 1)
		letter.position = Vector2(0, 0)
		letter.size = Vector2(22, 60)
		letter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		letter.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		letter.add_theme_font_size_override("font_size", fontSize + 18)
		letter.add_theme_color_override("font_color", Color.WHITE)
		letter.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.08, 1.0))
		letter.add_theme_constant_override("outline_size", 4)
		letter.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(letter)
		letters.append(letter)

	vb.add_child(HSeparator.new())

	var lblBase := Label.new()
	lblBase.text = String(opts.get("base", ""))
	lblBase.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lblBase.add_theme_font_size_override("font_size", fontSize + 2)
	lblBase.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	vb.add_child(lblBase)
	if String(opts.get("pen", "")) != "":
		var lblPen := Label.new()
		lblPen.text = String(opts["pen"])
		lblPen.add_theme_font_size_override("font_size", fontSize + 2)
		lblPen.add_theme_color_override("font_color", Color(1.0, 0.45, 0.35))
		vb.add_child(lblPen)
	if String(opts.get("bonus", "")) != "":
		var lblBonus := Label.new()
		lblBonus.text = String(opts["bonus"])
		lblBonus.add_theme_font_size_override("font_size", fontSize + 2)
		lblBonus.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		vb.add_child(lblBonus)

	vb.add_child(HSeparator.new())

	var lblTotal := Label.new()
	lblTotal.text = String(opts.get("total", ""))
	lblTotal.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lblTotal.add_theme_font_size_override("font_size", fontSize + 4)
	lblTotal.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))
	vb.add_child(lblTotal)

	# Mensajes adicionales (historia del ejercicio, estado de la insignia...)
	for nota in opts.get("notes", []):
		if String(nota).strip_edges() == "":
			continue
		var lblNota := Label.new()
		lblNota.text = String(nota)
		lblNota.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lblNota.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lblNota.add_theme_font_size_override("font_size", fontSize)
		lblNota.add_theme_color_override("font_color", Color(0.82, 0.78, 1.0))
		vb.add_child(lblNota)

	var state := {"choice": ""}
	var botones := HBoxContainer.new()
	botones.alignment = BoxContainer.ALIGNMENT_CENTER
	botones.add_theme_constant_override("separation", 16)
	vb.add_child(botones)
	var btn := Button.new()
	btn.text = String(opts.get("continue_text", "Continuar"))
	btn.add_theme_font_size_override("font_size", fontSize + 6)
	btn.custom_minimum_size = Vector2(220, 52)
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	btn.pressed.connect(func() -> void: state["choice"] = "continuar")
	botones.add_child(btn)
	if String(opts.get("extra_button", "")) != "":
		var btnExtra := Button.new()
		btnExtra.text = String(opts["extra_button"])
		btnExtra.add_theme_font_size_override("font_size", fontSize + 2)
		btnExtra.custom_minimum_size = Vector2(220, 52)
		btnExtra.mouse_filter = Control.MOUSE_FILTER_STOP
		btnExtra.pressed.connect(func() -> void: state["choice"] = "extra")
		botones.add_child(btnExtra)

	# El tablón sube desde abajo hasta quedar centrado (se espera un frame para conocer su alto real)
	await tree.process_frame
	var altoFinal: float = maxf(tablon.size.y, tablon.get_combined_minimum_size().y)
	tablon.size.y = altoFinal
	var targetY: float = maxf(8.0, (H - altoFinal) * 0.5)
	var tween := tablon.create_tween()
	tween.tween_property(tablon, "position:y", targetY, 0.65).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Animación hasta que el jugador pulse un botón: arcoíris en los bloques + onda en el título
	var startTime: int = Time.get_ticks_msec()
	while state["choice"] == "":
		if not is_instance_valid(host) or not host.is_inside_tree():
			return "continuar"
		var elapsed: float = float(Time.get_ticks_msec() - startTime) / 1000.0
		var hueBase: float = fmod(elapsed * 0.22, 1.0)
		for i in blocks.size():
			var b = blocks[i]
			if is_instance_valid(b):
				var hue: float = fmod(hueBase + float(i) / maxf(1.0, float(blocks.size())) * 0.75, 1.0)
				var sb := StyleBoxFlat.new()
				sb.bg_color = Color.from_hsv(hue, 0.78, 0.92)
				sb.border_color = Color.from_hsv(fmod(hue + 0.12, 1.0), 0.45, 1.0)
				sb.set_border_width_all(2)
				sb.set_corner_radius_all(6)
				sb.content_margin_left = 10
				sb.content_margin_right = 10
				sb.content_margin_top = 6
				sb.content_margin_bottom = 6
				b.add_theme_stylebox_override("panel", sb)
				var lbl = b.get_node_or_null("Texto")
				if lbl != null:
					lbl.add_theme_color_override("font_color", Color(1, 1, 1))
		for i in letters.size():
			var letter: Label = letters[i]
			letter.position.y = sin(elapsed * 7.0 - float(i) * 0.55) * 6.0
			var letterHue: float = fmod(hueBase + float(i) / maxf(1.0, float(letters.size())) * 0.85, 1.0)
			letter.add_theme_color_override("font_color", Color.from_hsv(letterHue, 0.72, 1.0))
		tablonStyle.border_color = Color.from_hsv(fmod(hueBase * 1.5, 1.0), 0.65, 1.0)
		tablon.add_theme_stylebox_override("panel", tablonStyle)
		await tree.process_frame

	var choice: String = state["choice"]
	celebration.queue_free()
	return choice
