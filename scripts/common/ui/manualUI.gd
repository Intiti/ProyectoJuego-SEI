extends "res://scripts/common/compat/ManualNivel3Actual.gd"
# El manual del Nivel 3 conserva su código y sus rutas públicas originales.
const ManualOriginal = preload("res://scripts/common/compat/ManualOriginal.gd")
var manual_original: CanvasLayer = null

func _ready() -> void:
	super._ready()
	manual_original = ManualOriginal.new()
	manual_original.name = "ManualOriginal"
	add_child(manual_original)
	_construir_boton_audio()
	_actualizar_visibilidad_segun_escena()

# Botón "Audio: ON/OFF" para todo el juego (menús, niveles 1, 2 y 3, exámenes). Va a la izquierda
# del botón Manual y silencia el bus Master, así que apaga música y efectos de cualquier nivel.
var _audio_btn: Button = null

func _construir_boton_audio() -> void:
	_audio_btn = Button.new()
	_audio_btn.name = "BotonAudioGlobal"
	_audio_btn.anchor_left = 1.0
	_audio_btn.anchor_right = 1.0
	_audio_btn.anchor_top = 0.0
	_audio_btn.anchor_bottom = 0.0
	_audio_btn.offset_left = -266.0
	_audio_btn.offset_right = -132.0
	_audio_btn.offset_top = 12.0
	_audio_btn.offset_bottom = 48.0
	_audio_btn.focus_mode = Control.FOCUS_NONE
	_audio_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_audio_btn.add_theme_font_size_override("font_size", 18)
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.15, 0.15, 0.22, 0.95)
	estilo.border_color = Color(0.55, 0.55, 0.75, 0.9)
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(6)
	estilo.content_margin_left = 10
	estilo.content_margin_right = 10
	_audio_btn.add_theme_stylebox_override("normal", estilo)
	var estilo_hover: StyleBoxFlat = estilo.duplicate()
	estilo_hover.bg_color = Color(0.22, 0.22, 0.35, 0.97)
	_audio_btn.add_theme_stylebox_override("hover", estilo_hover)
	_audio_btn.add_theme_stylebox_override("pressed", estilo_hover)
	_audio_btn.pressed.connect(func() -> void:
		if DJManager.has_method("toggle_mute"):
			DJManager.toggle_mute()
		_refrescar_texto_audio()
	)
	add_child(_audio_btn)
	_refrescar_texto_audio()

func _refrescar_texto_audio() -> void:
	if _audio_btn == null:
		return
	var silenciado: bool = DJManager.has_method("is_muted") and DJManager.is_muted()
	_audio_btn.text = "Audio: OFF" if silenciado else "Audio: ON"

# Un solo manual para los tres niveles (el original, ampliado con lo útil del manual del Nivel 3).
# El manual propio del Nivel 3 queda apagado; en los exámenes del Nivel 3 el manual se oculta.
func _es_examen() -> bool:
	var escena := get_tree().current_scene
	if escena == null:
		return false
	return escena.scene_file_path.contains("/ExamenNivel3/") or escena.scene_file_path.contains("/examen/")

func _actualizar_visibilidad_segun_escena() -> void:
	if _toggle_btn != null:
		_toggle_btn.hide()
	if _panel != null:
		_panel.hide()
	_isOpen = false
	if manual_original != null:
		manual_original.visible = not _es_examen()

func _input(_event: InputEvent) -> void:
	pass
