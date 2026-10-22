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

# Temblor corto de la ventana (misma fuerza y duración que el Nivel 1).
static func shake(host: Control, strength: float = 9.0, duration: float = 0.4) -> void:
	if host == null or not host.is_inside_tree():
		return
	var base: Vector2 = host.position
	if host.has_meta("_shake_base"):
		base = host.get_meta("_shake_base")
	host.set_meta("_shake_base", base)
	if host.has_meta("_shake_tween"):
		var old = host.get_meta("_shake_tween")
		if old is Tween and old.is_valid():
			old.kill()
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
