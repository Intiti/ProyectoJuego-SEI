extends Node2D

const TutorialHintScript = preload("res://scripts/common/ui/tutorialHint.gd")
const ScoreHudScript = preload("res://scripts/common/ui/scoreHud.gd")
const ExitMarkerScript = preload("res://scripts/common/ui/exitMarker.gd")

# Texto de la flecha de salida (hacia Villa1)
const EXIT_LABEL := "A la Villa"
var _exitMarker = null

var hint = null              # tutorial "habla con el alcalde"
var _exploreHint = null      # tutorial "explora la villa"
var _exploreTutorialShown: bool = false
var _exitBlocked: bool = true

func _ready():
	_applyGlobalTheme()
	add_child(ScoreHudScript.new())
	_showTutorialHint()
	_buildExitTrigger()
	_buildExitMarker()
	call_deferred("_setup")
	# ── Música de la villa (plaza/mapa principal) ──────────────────────────
	DJManager.playMusic("villa")

func _setup() -> void:
	var dialogBox = get_tree().get_first_node_in_group("dialog_box")
	if dialogBox:
		dialogBox.cinematicDialogFinished.connect(_onCinematicDialogFinished)
	# Escuchar input para ocultar tutorial al abrir cualquier diálogo
	_watchFirstDialog()

func _applyGlobalTheme() -> void:
	var font = load("res://assets/fonts/MotionControl-Bold.otf")
	var theme = Theme.new()
	theme.default_font = font
	theme.default_font_size = 20
	get_tree().root.theme = theme

# ─── Tutorial inicial: hablar con el alcalde ─────────────────────────────────
# Dice QUÉ hacer (acercarse al NPC marcado) y CON QUÉ tecla. El NPC muestra
# además su propia tecla [E] cuando el jugador está cerca.

func _showTutorialHint() -> void:
	hint = TutorialHintScript.new()
	hint.setup("Acércate al alcalde  (%s)  y pulsa  %s  para hablar" % [
		TutorialHintScript.bang(), TutorialHintScript.key("E")])
	add_child(hint)

# Espera a que abra el primer diálogo y oculta el tutorial
func _watchFirstDialog() -> void:
	while is_instance_valid(self):
		var dialogBox = get_tree().get_first_node_in_group("dialog_box")
		if dialogBox and dialogBox.isOpen:
			_hideTutorial()
			return
		await get_tree().process_frame

func _hideTutorial() -> void:
	if is_instance_valid(hint):
		hint.dismiss()
	hint = null

# ─── Señal del dialogBox: se llama al cerrar cualquier outro (isCinematic) ────

func _onCinematicDialogFinished() -> void:
	# El outro del alcalde cerró — chequear si el NPC_E11 ya no necesita ayuda
	var npc = get_node_or_null("NPC_E11")
	if npc and not npc.needsHelp and not _exploreTutorialShown:
		_exploreTutorialShown = true
		_exitBlocked = false
		if is_instance_valid(_exitMarker):
			_exitMarker.setActive(true)   # recién ahora se puede pasar a Villa1
		_showExploreTutorial()

# ─── Tutorial "Explora Villa Miaulemana" ──────────────────────────────────────

func _showExploreTutorial() -> void:
	_exploreHint = TutorialHintScript.new()
	_exploreHint.setup("Ahora puedes explorar Villa Miaulemana  [color=yellow]→[/color]")
	add_child(_exploreHint)
	# Se retira solo después de unos segundos
	_exploreHint.dismiss(7.0)

# ─── Flecha de salida hacia Villa1 ───────────────────────────────────────────
# Escondida hasta que el jugador habla con el alcalde (misma condición que
# _exitBlocked = false).

func _buildExitMarker() -> void:
	_exitMarker = ExitMarkerScript.new()
	_exitMarker.setup(ExitMarkerScript.Side.RIGHT, EXIT_LABEL, not _exitBlocked)
	add_child(_exitMarker)

# ─── Trigger de salida hacia Villa1 ──────────────────────────────────────────

func _buildExitTrigger() -> void:
	var exitArea = Area2D.new()
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(32, 400)
	shape.shape = rect
	exitArea.add_child(shape)
	exitArea.position = Vector2(1136, 400)
	add_child(exitArea)
	exitArea.body_entered.connect(_on_exit_body_entered)

func _on_exit_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if _exitBlocked:
		return
	_goToVilla1()

func _goToVilla1() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)

	var fadeLayer = CanvasLayer.new()
	fadeLayer.layer = 10
	add_child(fadeLayer)
	var fadeRect = ColorRect.new()
	fadeRect.anchor_right = 1.0
	fadeRect.anchor_bottom = 1.0
	fadeRect.color = Color(0, 0, 0, 0)
	fadeLayer.add_child(fadeRect)

	var tween = create_tween()
	tween.tween_property(fadeRect, "color", Color(0, 0, 0, 1), 0.8)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/nivel_1/Villa1.tscn"))
