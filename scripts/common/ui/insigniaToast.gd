extends PanelContainer
# Aviso tipo Steam: medalla + "¡Insignia desbloqueada!" + título + descripción.
# Lo crea y lo anima el autoload Insignias; acá solo se construye el contenido.

const MedalScript := preload("res://scripts/common/ui/insigniaMedal.gd")
const FONT_PATH := "res://assets/fonts/MotionControl-Bold.otf"

const TIER_NAMES := ["BRONCE", "PLATA", "ORO"]
const TIER_TEXT_COLORS := [Color("#E9A866"), Color("#DDE4EC"), Color("#FFD84D")]

func setup(info: Dictionary) -> void:
	var tier: int = int(info.get("tier", 0))
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(500, 0)

	var font: Font = null
	if ResourceLoader.exists(FONT_PATH):
		font = load(FONT_PATH)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.20, 0.16, 0.42, 0.97)
	style.border_color = TIER_TEXT_COLORS[clampi(tier, 0, 2)]
	style.set_border_width_all(4)
	style.set_corner_radius_all(16)
	style.content_margin_left = 16
	style.content_margin_right = 20
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 4)
	add_theme_stylebox_override("panel", style)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)

	var medal := MedalScript.new()
	medal.tier = tier
	medal.face = int(info.get("face", 0))
	medal.custom_minimum_size = Vector2(92, 92)
	medal.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(medal)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(col)

	col.add_child(_label("¡INSIGNIA DESBLOQUEADA!  ·  %s" % TIER_NAMES[clampi(tier, 0, 2)], 15, TIER_TEXT_COLORS[clampi(tier, 0, 2)], font))
	col.add_child(_label(str(info.get("nombre", "")), 24, Color.WHITE, font))
	var desc := _label(str(info.get("descripcion", "")), 17, Color(0.82, 0.78, 1.0), font)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size = Vector2(340, 0)
	col.add_child(desc)

func _label(text: String, font_size: int, color: Color, font: Font) -> Label:
	var l := Label.new()
	l.text = text
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if font != null:
		l.add_theme_font_override("font", font)
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	return l
