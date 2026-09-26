extends Node2D

var tutorialLabel: Node = null
var tutorialLayer: CanvasLayer = null

func _ready():
	_applyGlobalTheme()
	_showTutorialHint()
	_watchDialogBox()

func _applyGlobalTheme() -> void:
	var font = load("res://assets/MotionControl-Bold.otf")
	var theme = Theme.new()
	theme.default_font = font
	theme.default_font_size = 20
	get_tree().root.theme = theme

func _showTutorialHint() -> void:
	tutorialLayer = CanvasLayer.new()
	tutorialLayer.layer = 5
	add_child(tutorialLayer)

	var richLabel = RichTextLabel.new()
	richLabel.bbcode_enabled = true
	richLabel.text = "Pulsa  E  para interactuar con NPCs marcados ([color=red]![/color])"
	richLabel.add_theme_font_size_override("normal_font_size", 32)
	richLabel.add_theme_font_size_override("bold_font_size", 32)
	richLabel.add_theme_color_override("default_color", Color(1, 1, 1, 1))
	richLabel.add_theme_constant_override("shadow_offset_x", 2)
	richLabel.add_theme_constant_override("shadow_offset_y", 2)
	richLabel.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	richLabel.fit_content = true
	richLabel.scroll_active = false
	richLabel.autowrap_mode = TextServer.AUTOWRAP_OFF
	richLabel.anchor_left   = 0.5
	richLabel.anchor_right  = 0.5
	richLabel.anchor_top    = 1.0
	richLabel.anchor_bottom = 1.0
	richLabel.offset_left   = -420.0
	richLabel.offset_right  = 420.0
	richLabel.offset_top    = -80.0
	richLabel.offset_bottom = -20.0
	richLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	tutorialLayer.add_child(richLabel)
	tutorialLabel = richLabel
	_blinkLabel(tutorialLabel)

func _blinkLabel(label: Node) -> void:
	while is_instance_valid(label):
		var t = create_tween()
		t.tween_property(label, "modulate:a", 0.2, 0.6)
		t.tween_property(label, "modulate:a", 1.0, 0.6)
		await t.finished

func _watchDialogBox() -> void:
	while is_instance_valid(self):
		var dialogBox = get_tree().get_first_node_in_group("dialog_box")
		if dialogBox and dialogBox.isOpen:
			_hideTutorial()
			return
		await get_tree().process_frame

func _hideTutorial() -> void:
	if is_instance_valid(tutorialLabel):
		tutorialLabel.queue_free()
		tutorialLabel = null
	if is_instance_valid(tutorialLayer):
		tutorialLayer.queue_free()
		tutorialLayer = null
