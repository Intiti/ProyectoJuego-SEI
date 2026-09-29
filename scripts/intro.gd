extends Node2D

var introDialogLines = [
	{"speaker": "Jugador", "text": "¡PANKO!  ¡¿PANKO DÓNDE ESTÁS?!"},
	{"speaker": "Jugador", "text": "¿Dónde se metió este gato ahora? ¡PANKOO!"},
]

@onready var fadeRect = $FadeLayer/FadeRect
@onready var dialogBox = $DialogBox

var tutorialLabel: Label = null
var tutorialLayer: CanvasLayer = null

func _ready():
	_applyGlobalTheme()
	fadeRect.color = Color(0, 0, 0, 1)
	_blockPlayer()
	dialogBox.cinematicDialogFinished.connect(_onIntroDialogFinished)
	# ── Música de la intro (crossfade desde la del menú) ──────────────────
	DJManager.playMusic("intro")
	_fadeIn()

func _applyGlobalTheme() -> void:
	var font = load("res://assets/MotionControl-Bold.otf")
	var globalTheme = Theme.new()
	globalTheme.default_font = font
	globalTheme.default_font_size = 20
	get_tree().root.theme = globalTheme

func _blockPlayer():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)

func _fadeIn():
	var tween = create_tween()
	tween.tween_property(fadeRect, "color", Color(0, 0, 0, 0), 2.0)
	tween.tween_callback(_startDialog)

func _startDialog():
	dialogBox.openDirect(introDialogLines, "res://scenes/Player.tscn")

func _onIntroDialogFinished():
	_showTutorialHint()
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(true)

# ─── Tutorial "usa <- y -> para moverte" ─────────────────────────────────────

func _showTutorialHint():
	tutorialLayer = CanvasLayer.new()
	tutorialLayer.layer = 5
	add_child(tutorialLayer)

	tutorialLabel = Label.new()
	tutorialLabel.text = "Usa  ←  y  →  para moverte"
	tutorialLabel.add_theme_font_size_override("font_size", 32)
	tutorialLabel.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	tutorialLabel.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	tutorialLabel.add_theme_constant_override("shadow_offset_x", 2)
	tutorialLabel.add_theme_constant_override("shadow_offset_y", 2)

	tutorialLabel.anchor_left   = 0.5
	tutorialLabel.anchor_right  = 0.5
	tutorialLabel.anchor_top    = 1.0
	tutorialLabel.anchor_bottom = 1.0
	tutorialLabel.offset_left   = -250.0
	tutorialLabel.offset_right  = 250.0
	tutorialLabel.offset_top    = -60.0
	tutorialLabel.offset_bottom = -20.0
	tutorialLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	tutorialLayer.add_child(tutorialLabel)
	_blinkLabel(tutorialLabel)

func _blinkLabel(label: Label):
	while is_instance_valid(label):
		var t = create_tween()
		t.tween_property(label, "modulate:a", 0.2, 0.6)
		t.tween_property(label, "modulate:a", 1.0, 0.6)
		await t.finished

func _on_exit_trigger_body_entered(body):
	if not body.is_in_group("player"):
		return
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Intro2.tscn")
