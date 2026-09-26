extends Node2D

const letterSpeed = 0.04

var dialogLines = [
	{"speaker": "Jugador", "text": "¡PANKO!!"},
	{"speaker": "Jugador", "text": "¡PANKOO!!"},
]

var currentLine = 0
var isTyping = false
var fullText = ""

@onready var fadeRect = $FadeRect
@onready var panel = $DialogLayer/Panel
@onready var speakerLabel = $DialogLayer/Panel/SpeakerLabel
@onready var dialogLabel = $DialogLayer/Panel/DialogLabel
@onready var continueHint = $DialogLayer/Panel/ContinueHint

func _ready():
	_applyGlobalTheme()
	panel.visible = false
	fadeRect.color = Color(0, 0, 0, 1)
	_fadeIn()

func _applyGlobalTheme() -> void:
	var font = load("res://assets/MotionControl-Bold.otf")
	var globalTheme = Theme.new()
	globalTheme.default_font = font
	globalTheme.default_font_size = 20
	get_tree().root.theme = globalTheme

func _fadeIn():
	var tween = create_tween()
	tween.tween_property(fadeRect, "color", Color(0, 0, 0, 0), 2.0)
	tween.tween_callback(_startDialog)

func _startDialog():
	panel.visible = true
	_showLine()

func _showLine():
	var lineData = dialogLines[currentLine]
	speakerLabel.text = lineData["speaker"]
	fullText = lineData["text"]
	continueHint.visible = false
	dialogLabel.text = ""
	isTyping = true
	_typeText()

func _typeText():
	for i in fullText.length():
		if not isTyping:
			break
		dialogLabel.text = fullText.substr(0, i + 1)
		await get_tree().create_timer(letterSpeed).timeout
	dialogLabel.text = fullText
	isTyping = false
	continueHint.visible = true

func _input(event):
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if not event.is_action("interact"):
		return
	get_viewport().set_input_as_handled()
	if isTyping:
		isTyping = false
	else:
		_nextLine()

func _nextLine():
	currentLine += 1
	if currentLine >= dialogLines.size():
		_endCinematic()
	else:
		_showLine()

func _endCinematic():
	panel.visible = false
	var tween = create_tween()
	tween.tween_property(fadeRect, "color", Color(0, 0, 0, 1), 1.0)
	tween.tween_callback(_goToMain)

func _goToMain():
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
