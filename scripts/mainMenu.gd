extends Control

func _ready():
	_applyGlobalTheme()

func _applyGlobalTheme() -> void:
	var font = load("res://assets/MotionControl-Bold.otf")
	var globalTheme = Theme.new()
	globalTheme.default_font = font
	globalTheme.default_font_size = 20
	get_tree().root.theme = globalTheme

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Intro.tscn")
