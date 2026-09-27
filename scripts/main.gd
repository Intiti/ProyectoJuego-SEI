extends Node2D

var tutorialLayer: CanvasLayer = null
var tutorialLabel: Node = null

var _exploreTutorialLayer: CanvasLayer = null
var _exploreTutorialLabel: Node = null
var _exploreTutorialShown: bool = false
var _exitBlocked: bool = true

func _ready():
	_applyGlobalTheme()
	_showTutorialHint()
	_buildExitTrigger()
	_addManual()
	call_deferred("_setup")

func _addManual() -> void:
	var manual = load("res://scripts/manualUI.gd").new()
	add_child(manual)

func _setup() -> void:
	var dialogBox = get_tree().get_first_node_in_group("dialog_box")
	if dialogBox:
		dialogBox.cinematicDialogFinished.connect(_onCinematicDialogFinished)
	# Escuchar input para ocultar tutorial al abrir cualquier diálogo
	_watchFirstDialog()

func _applyGlobalTheme() -> void:
	var font = load("res://assets/MotionControl-Bold.otf")
	var theme = Theme.new()
	theme.default_font = font
	theme.default_font_size = 20
	get_tree().root.theme = theme

# ─── Tutorial inicial "pulsa E" ───────────────────────────────────────────────

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

# Espera a que abra el primer diálogo y oculta el tutorial
func _watchFirstDialog() -> void:
	while is_instance_valid(self):
		var dialogBox = get_tree().get_first_node_in_group("dialog_box")
		if dialogBox and dialogBox.isOpen:
			_hideTutorial()
			return
		await get_tree().process_frame

func _blinkLabel(label: Node) -> void:
	while is_instance_valid(label):
		var t = create_tween()
		t.tween_property(label, "modulate:a", 0.2, 0.6)
		t.tween_property(label, "modulate:a", 1.0, 0.6)
		await t.finished

func _hideTutorial() -> void:
	if is_instance_valid(tutorialLabel):
		tutorialLabel.queue_free()
		tutorialLabel = null
	if is_instance_valid(tutorialLayer):
		tutorialLayer.queue_free()
		tutorialLayer = null

# ─── Señal del dialogBox: se llama al cerrar cualquier outro (isCinematic) ────

func _onCinematicDialogFinished() -> void:
	# El outro del alcalde cerró — chequear si el NPC_E11 ya no necesita ayuda
	var npc = get_node_or_null("NPC_E11")
	if npc and not npc.needsHelp and not _exploreTutorialShown:
		_exploreTutorialShown = true
		_exitBlocked = false
		_showExploreTutorial()

# ─── Tutorial "Explora Villa Miaulemana" ──────────────────────────────────────

func _showExploreTutorial() -> void:
	_exploreTutorialLayer = CanvasLayer.new()
	_exploreTutorialLayer.layer = 5
	add_child(_exploreTutorialLayer)

	var lbl = RichTextLabel.new()
	lbl.bbcode_enabled = true
	lbl.text = "Ahora puedes explorar Villa Miaulemana libremente  [color=yellow]→[/color]"
	lbl.add_theme_font_size_override("normal_font_size", 28)
	lbl.add_theme_color_override("default_color", Color(1, 1, 1, 1))
	lbl.add_theme_constant_override("shadow_offset_x", 2)
	lbl.add_theme_constant_override("shadow_offset_y", 2)
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	lbl.fit_content = true
	lbl.scroll_active = false
	lbl.autowrap_mode = TextServer.AUTOWRAP_OFF
	lbl.anchor_left   = 0.5
	lbl.anchor_right  = 0.5
	lbl.anchor_top    = 1.0
	lbl.anchor_bottom = 1.0
	lbl.offset_left   = -480.0
	lbl.offset_right  = 480.0
	lbl.offset_top    = -80.0
	lbl.offset_bottom = -20.0
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	_exploreTutorialLayer.add_child(lbl)
	_exploreTutorialLabel = lbl
	_blinkLabel(_exploreTutorialLabel)

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
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/Villa1.tscn"))
