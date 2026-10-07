extends Node2D

var introDialogLines = [
	{"speaker": "Jugador", "text": "¡PANKO!  ¡¿PANKO DÓNDE ESTÁS?!"},
	{"speaker": "Jugador", "text": "¿Dónde se metió este gato ahora? ¡PANKOO!"},
]

@onready var fadeRect = $FadeLayer/FadeRect
@onready var dialogBox = $DialogBox

const TutorialHintScript = preload("res://scripts/common/ui/tutorialHint.gd")

# Tutorial de movimiento: se completa solo cuando el jugador realmente se mueve
# y salta. Así el mensaje desaparece al aprender, no se queda parpadeando.
const MOVE_DISTANCE := 150.0   # px que debe recorrer para contar como "ya se movió"
const JUMP_GRACE    := 6.0     # s que esperamos el salto antes de cerrar igual
const GO_RIGHT_TEXT := "[color=yellow]Sigue hacia la derecha  →[/color]"

var hint = null
var _tutorialActive := false
var _startX := 0.0
var _moved := false
var _jumped := false

func _ready():
	_applyGlobalTheme()
	fadeRect.color = Color(0, 0, 0, 1)
	_blockPlayer()
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
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(true)

# ─── Tutorial de movimiento ──────────────────────────────────────────────────

func _showTutorialHint():
	hint = TutorialHintScript.new()
	hint.setup(_hintText())
	add_child(hint)

	var player = get_tree().get_first_node_in_group("player")
	if player:
		_startX = player.global_position.x
	_tutorialActive = true

# Siempre UNA sola línea. Va quitando lo que el jugador ya hizo:
#   nada hecho     → "Moverte: ... | Saltar: ..."
#   ya se movió    → solo "Saltar: ..."
#   ya saltó       → solo "Moverte: ..."
#   ambos          → "Sigue hacia la derecha →"
func _hintText() -> String:
	var moveTxt = "Moverte:  %s %s  o  %s %s" % [
		TutorialHintScript.key("←"), TutorialHintScript.key("→"),
		TutorialHintScript.key("A"), TutorialHintScript.key("D")]
	var jumpTxt = "Saltar:  %s  o  %s" % [TutorialHintScript.key("ESPACIO"), TutorialHintScript.key("W")]
	if _moved and _jumped:
		return GO_RIGHT_TEXT
	if _moved:
		return jumpTxt
	if _jumped:
		return moveTxt
	return moveTxt + "      " + jumpTxt

func _process(_delta):
	if not _tutorialActive:
		return
	var player = get_tree().get_first_node_in_group("player")
	if not player or not player.is_physics_processing():
		return

	var changed := false
	if not _moved and absf(player.global_position.x - _startX) > MOVE_DISTANCE:
		_moved = true
		changed = true
		# Si no salta, cerramos igual tras unos segundos para no estorbar
		get_tree().create_timer(JUMP_GRACE).timeout.connect(_finishTutorial)
	if not _jumped and player.velocity.y < -50.0:
		_jumped = true
		changed = true
	if changed and is_instance_valid(hint):
		hint.setText(_hintText())
		hint.flash()   # destello: acción completada
	if _moved and _jumped:
		_finishTutorial()

func _finishTutorial():
	if not _tutorialActive:
		return
	_tutorialActive = false
	if is_instance_valid(hint):
		hint.setText(GO_RIGHT_TEXT)
		hint.flash()
		hint.dismiss(3.0)

func _on_exit_trigger_body_entered(body):
	if not body.is_in_group("player"):
		return
	get_tree().call_deferred("change_scene_to_file", "res://scenes/nivel_0/Intro2.tscn")
