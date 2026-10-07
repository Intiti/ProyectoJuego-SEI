extends CanvasLayer

# ─────────────────────────────────────────────────────────────────────────────
#  TutorialHint — barra de ayuda en la parte inferior de la pantalla.
#  Fondo oscuro semitransparente (legible sobre cualquier fondo) y teclas
#  dibujadas como "keycaps" con TutorialHint.key("E").
#
#      const TutorialHintScript = preload("res://scripts/common/ui/tutorialHint.gd")
#      var hint = TutorialHintScript.new()
#      hint.setup("Pulsa " + TutorialHintScript.key("E") + " para hablar")
#      add_child(hint)
#      hint.setText("...")        # cambiar el mensaje
#      hint.dismiss()             # desvanece y elimina
# ─────────────────────────────────────────────────────────────────────────────

const FONT_PATH := "res://assets/fonts/MotionControl-Bold.otf"
const FONT_SIZE := 30
const MIN_WIDTH := 820.0   # ancho mínimo de la barra (px); crece si el texto es más largo

var _initialText: String = ""
var _panel: PanelContainer
var _label: RichTextLabel
var _dismissed := false
var _flashTween: Tween = null

# Devuelve una "tecla" en BBCode (texto amarillo, sin recuadro), p. ej. key("E"), key("ESPACIO"), key("←")
static func key(k: String) -> String:
	return "[color=#ffd84a][b]%s[/b][/color]" % k

# Símbolo "!" rojo en BBCode (el mismo que se ve sobre los NPC)
static func bang() -> String:
	return "[color=#ff3b3b][b]![/b][/color]"

# Llamar antes de add_child()
func setup(bbcode: String) -> void:
	_initialText = bbcode

func _ready() -> void:
	layer = 5

	_panel = PanelContainer.new()
	_panel.anchor_left = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_top = 1.0
	_panel.anchor_bottom = 1.0
	_panel.offset_bottom = -14.0
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)   # sin sombreado de fondo
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 24
	sb.content_margin_right = 24
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	_panel.add_theme_stylebox_override("panel", sb)
	add_child(_panel)

	_label = RichTextLabel.new()
	_label.bbcode_enabled = true
	_label.fit_content = true
	_label.scroll_active = false
	_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_label.custom_minimum_size = Vector2(MIN_WIDTH, 0)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var font = load(FONT_PATH)
	if font:
		_label.add_theme_font_override("normal_font", font)
		_label.add_theme_font_override("bold_font", font)
	_label.add_theme_font_size_override("normal_font_size", FONT_SIZE)
	_label.add_theme_font_size_override("bold_font_size", FONT_SIZE)
	_label.add_theme_color_override("default_color", Color(1, 1, 1, 1))
	# Sin caja de fondo: el contorno negro mantiene el texto legible sobre cualquier escenario
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	_label.add_theme_constant_override("outline_size", 10)
	_panel.add_child(_label)

	setText(_initialText)

	# Entrada suave (sin parpadeo ni pulso: no distrae)
	_panel.modulate.a = 0.0
	create_tween().tween_property(_panel, "modulate:a", 1.0, 0.25)

func setText(bbcode: String) -> void:
	if is_instance_valid(_label):
		_label.text = "[center]%s[/center]" % bbcode

# Destello breve (el texto brilla y "late" una vez). Sirve para indicar que
# el jugador completó la acción que pedía el mensaje.
func flash() -> void:
	if _dismissed or not is_instance_valid(_panel):
		return
	if _flashTween and _flashTween.is_valid():
		_flashTween.kill()
	_panel.pivot_offset = _panel.size / 2.0
	_flashTween = create_tween()
	_flashTween.set_parallel(true)
	_flashTween.tween_property(_panel, "modulate", Color(1.7, 1.7, 1.3, 1.0), 0.12)
	_flashTween.tween_property(_panel, "scale", Vector2(1.06, 1.06), 0.12)
	_flashTween.chain().set_parallel(true)
	_flashTween.tween_property(_panel, "modulate", Color(1, 1, 1, 1), 0.5)
	_flashTween.tween_property(_panel, "scale", Vector2.ONE, 0.5)

func dismiss(delay: float = 0.0) -> void:
	if _dismissed:
		return
	_dismissed = true
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	if not is_instance_valid(self):
		return
	var t := create_tween()
	t.tween_property(_panel, "modulate:a", 0.0, 0.3)
	t.tween_callback(queue_free)
