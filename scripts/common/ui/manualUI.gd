extends "res://scripts/common/compat/ManualNivel3Actual.gd"
# El manual del Nivel 3 conserva su código y sus rutas públicas originales.
const ManualOriginal = preload("res://scripts/common/compat/ManualOriginal.gd")
var manual_original: CanvasLayer = null

func _ready() -> void:
	super._ready()
	manual_original = ManualOriginal.new()
	manual_original.name = "ManualOriginal"
	add_child(manual_original)
	_actualizar_visibilidad_segun_escena()

func _es_nivel3() -> bool:
	var escena := get_tree().current_scene
	if escena == null:
		return false
	return escena.scene_file_path.contains("/Nivel_3/") or escena.scene_file_path.contains("/ExamenNivel3/")

func _actualizar_visibilidad_segun_escena() -> void:
	if _es_nivel3():
		if manual_original != null:
			manual_original.visible = false
		super._actualizar_visibilidad_segun_escena()
	else:
		if _toggle_btn != null:
			_toggle_btn.hide()
		if _panel != null:
			_panel.hide()
		_isOpen = false
		if manual_original != null:
			manual_original.visible = true

func _input(event: InputEvent) -> void:
	if _es_nivel3():
		super._input(event)
