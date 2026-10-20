extends Control
# Pantalla "INSIGNIAS" del menú principal: overlay con la lista de insignias
# (las conseguidas a todo color, las pendientes en gris con "?").
# Se abre con:  add_child(InsigniasScreenScript.new())   y se cierra con VOLVER o Esc.

const MedalScript := preload("res://scripts/common/ui/insigniaMedal.gd")
const FONT_PATH := "res://assets/fonts/MotionControl-Bold.otf"
const TIER_NAMES := ["Bronce", "Plata", "Oro"]
const TIER_COLORS := [Color("#E9A866"), Color("#DDE4EC"), Color("#FFD84D")]

var _font: Font = null

func _ready() -> void:
	if ResourceLoader.exists(FONT_PATH):
		_font = load(FONT_PATH)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.18)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		_close()

func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.06, 0.05, 0.88)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(760, 0)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.20, 0.16, 0.42, 1)
	sb.border_color = Color(0.80, 0.75, 1.00, 1)
	sb.set_border_width_all(4)
	sb.set_corner_radius_all(18)
	sb.content_margin_left = 28
	sb.content_margin_right = 28
	sb.content_margin_top = 20
	sb.content_margin_bottom = 22
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	vbox.add_child(_label("INSIGNIAS", 40, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER))
	vbox.add_child(_label("%d / %d conseguidas" % [Insignias.unlockedCount(), Insignias.totalCount()], 18, Color(0.82, 0.78, 1.0), HORIZONTAL_ALIGNMENT_CENTER))
	vbox.add_child(_label("NIVEL 1", 20, Color(1.0, 0.90, 0.55), HORIZONTAL_ALIGNMENT_LEFT))

	for info in Insignias.getCatalogo():
		if int(info["nivel"]) == 1:
			vbox.add_child(_makeRow(info))

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 6)
	vbox.add_child(spacer)

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 16)
	vbox.add_child(buttons)

	var back := Button.new()
	back.text = "VOLVER"
	back.custom_minimum_size = Vector2(200, 52)
	back.add_theme_font_size_override("font_size", 24)
	if _font != null:
		back.add_theme_font_override("font", _font)
	back.pressed.connect(_close)
	buttons.add_child(back)

	var reset := Button.new()
	reset.text = "REINICIAR INSIGNIAS"
	reset.custom_minimum_size = Vector2(320, 52)
	reset.add_theme_font_size_override("font_size", 24)
	if _font != null:
		reset.add_theme_font_override("font", _font)
	reset.pressed.connect(_askReset)
	buttons.add_child(reset)
	back.grab_focus()

func _askReset() -> void:
	var dlg := ConfirmationDialog.new()
	dlg.title = "Reiniciar insignias"
	dlg.dialog_text = "¿Seguro que quieres reiniciar todas las insignias?\nSe perderán las que llevas conseguidas."
	dlg.ok_button_text = "Reiniciar"
	dlg.cancel_button_text = "Cancelar"
	dlg.confirmed.connect(_onResetConfirmed)
	dlg.canceled.connect(dlg.queue_free)
	add_child(dlg)
	dlg.popup_centered()

func _onResetConfirmed() -> void:
	Insignias.reset()
	_rebuild.call_deferred()

func _rebuild() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_build()

func _makeRow(info: Dictionary) -> Control:
	var unlocked: bool = Insignias.isUnlocked(info["id"])
	var row := PanelContainer.new()
	var rsb := StyleBoxFlat.new()
	rsb.bg_color = Color(1, 1, 1, 0.08) if unlocked else Color(0, 0, 0, 0.22)
	rsb.set_corner_radius_all(12)
	rsb.content_margin_left = 12
	rsb.content_margin_right = 14
	rsb.content_margin_top = 8
	rsb.content_margin_bottom = 8
	row.add_theme_stylebox_override("panel", rsb)

	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 16)
	row.add_child(h)

	var medal := MedalScript.new()
	medal.tier = int(info["tier"])
	medal.face = int(info["face"])
	medal.locked = not unlocked
	medal.custom_minimum_size = Vector2(84, 84)
	h.add_child(medal)

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	col.add_theme_constant_override("separation", 2)
	h.add_child(col)

	var tier: int = clampi(int(info["tier"]), 0, 2)
	var title_text: String = str(info["nombre"]) if unlocked else "???"
	col.add_child(_label(title_text, 22, Color.WHITE if unlocked else Color(0.6, 0.6, 0.68), HORIZONTAL_ALIGNMENT_LEFT))
	var desc := _label(str(info["descripcion"]), 16, Color(0.82, 0.78, 1.0) if unlocked else Color(0.5, 0.5, 0.58), HORIZONTAL_ALIGNMENT_LEFT)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size = Vector2(440, 0)
	col.add_child(desc)

	var status := "%s · Conseguida" % TIER_NAMES[tier] if unlocked else "%s · Bloqueada" % TIER_NAMES[tier]
	col.add_child(_label(status, 14, TIER_COLORS[tier] if unlocked else Color(0.5, 0.5, 0.58), HORIZONTAL_ALIGNMENT_LEFT))
	return row

func _label(text: String, font_size: int, color: Color, align: int) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = align
	if _font != null:
		l.add_theme_font_override("font", _font)
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	return l

func _close() -> void:
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.15)
	await t.finished
	queue_free()
