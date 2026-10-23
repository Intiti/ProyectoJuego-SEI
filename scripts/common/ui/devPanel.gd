extends VBoxContainer

const LEVEL1_SCENE := "res://scenes/nivel_1/Main.tscn"
const LEVEL2_SCENE := "res://scenes/nivel_2/1SenderoDeLasHuellas.tscn"
const LEVEL3_SCENE := "res://scenes/Nivel_3/1Entrada del Laboratorio.tscn"
const MARGIN := 16.0
const FormularioAliasScript := preload("res://scripts/common/ui/formularioAlias.gd")

func _ready() -> void:
	anchor_left = 1.0
	anchor_top = 1.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_left = -MARGIN
	offset_top = -MARGIN
	offset_right = -MARGIN
	offset_bottom = -MARGIN
	grow_horizontal = Control.GROW_DIRECTION_BEGIN
	grow_vertical = Control.GROW_DIRECTION_BEGIN
	add_theme_constant_override("separation", 4)
	_addTag()
	_addButton("Omitir intro", _onSkipPressed)
	_addButton("Saltar a nivel 2", _onLevel2Pressed)
	_addButton("Saltar a nivel 3", _onLevel3Pressed)

func _addTag() -> void:
	var tag := Label.new()
	tag.text = "DEV"
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tag.add_theme_font_size_override("font_size", 12)
	tag.add_theme_color_override("font_color", Color(1.0, 0.78, 0.35, 0.7))
	add_child(tag)

func _addButton(label: String, handler: Callable) -> void:
	var button := Button.new()
	button.text = label
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(150, 28)
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75, 0.8))
	button.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))
	button.add_theme_stylebox_override("normal", _makeStyle(Color(0, 0, 0, 0.25)))
	button.add_theme_stylebox_override("hover", _makeStyle(Color(1, 1, 1, 0.12)))
	button.add_theme_stylebox_override("pressed", _makeStyle(Color(1, 1, 1, 0.2)))
	button.pressed.connect(handler)
	add_child(button)

func _makeStyle(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(6)
	style.set_border_width_all(1)
	style.border_color = Color(1, 1, 1, 0.15)
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	return style

func _onSkipPressed() -> void:
	GameData.assignAlias(FormularioAliasScript.generateAlias())
	get_tree().change_scene_to_file(LEVEL1_SCENE)

func _onLevel2Pressed() -> void:
	GameData.assignAlias(FormularioAliasScript.generateAlias())
	get_tree().change_scene_to_file(LEVEL2_SCENE)

func _onLevel3Pressed() -> void:
	GameData.assignAlias(FormularioAliasScript.generateAlias())
	get_tree().change_scene_to_file(LEVEL3_SCENE)
