extends Node2D

var introDialogLines = [
	{"speaker": "Jugador", "text": "¡PANKO!  ¡¿PANKO DÓNDE ESTÁS?!"},
	{"speaker": "Jugador", "text": "¿Dónde se metió este gato ahora? ¡PANKOO!"},
]

@onready var fadeRect = $FadeLayer/FadeRect
@onready var dialogBox = $DialogBox

const TutorialHintScript = preload("res://scripts/common/ui/tutorialHint.gd")
const ScoreHudScript = preload("res://scripts/common/ui/scoreHud.gd")
const ExitMarkerScript = preload("res://scripts/common/ui/exitMarker.gd")

# Texto de la flecha de salida (hacia Intro2)
const EXIT_LABEL := "Seguir"
var exitMarker = null

# Tutorial de movimiento: se queda en pantalla todo el nivel (no se cierra solo)
var hint = null

func _ready():
	_applyGlobalTheme()
	fadeRect.color = Color(0, 0, 0, 1)
	_blockPlayer()
	add_child(ScoreHudScript.new())
	_buildExitMarker()
	dialogBox.cinematicDialogFinished.connect(_onIntroDialogFinished)
	# ── Música de la intro (crossfade desde la del menú) ──────────────────
	DJManager.playMusic("intro")
	_fadeIn()

func _applyGlobalTheme() -> void:
	var font = load("res://assets/fonts/MotionControl-Bold.otf")
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
	dialogBox.openDirect(introDialogLines, "res://scenes/common/actors/Player.tscn")

func _onIntroDialogFinished():
	_showTutorialHint()
	if is_instance_valid(exitMarker):
		exitMarker.setActive(true)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(true)

# ─── Flecha de salida (borde derecho → Intro2) ───────────────────────────────
# Empieza escondida; aparece cuando termina el diálogo y el jugador ya puede moverse.

func _buildExitMarker() -> void:
	exitMarker = ExitMarkerScript.new()
	exitMarker.setup(ExitMarkerScript.Side.RIGHT, EXIT_LABEL, false)
	add_child(exitMarker)

# ─── Tutorial de movimiento ──────────────────────────────────────────────────
# Siempre visible, con las dos indicaciones (moverse y saltar).

func _showTutorialHint():
	hint = TutorialHintScript.new()
	hint.setup(_hintText())
	add_child(hint)

func _hintText() -> String:
	var moveTxt = "Moverte:  %s %s  o  %s %s" % [
		TutorialHintScript.key("←"), TutorialHintScript.key("→"),
		TutorialHintScript.key("A"), TutorialHintScript.key("D")]
	var jumpTxt = "Saltar:  %s  o  %s" % [TutorialHintScript.key("ESPACIO"), TutorialHintScript.key("W")]
	return moveTxt + "      " + jumpTxt

func _on_exit_trigger_body_entered(body):
	if not body.is_in_group("player"):
		return
	get_tree().call_deferred("change_scene_to_file", "res://scenes/nivel_0/Intro2.tscn")
