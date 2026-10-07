extends Node2D

const ScoreHudScript = preload("res://scripts/common/ui/scoreHud.gd")
const FaderScript = preload("res://scripts/common/ui/sceneFader.gd")
const ExitMarkerScript = preload("res://scripts/common/ui/exitMarker.gd")

# Texto de las flechas de los bordes (se puede salir por izquierda y derecha)
const EXIT_LABEL := "Salir"

const SPAWN_LEFT_X  := 80.0
const SPAWN_RIGHT_X := 1070.0
const SPAWN_Y       := 570.0

func _ready():
	_applyGlobalTheme()
	_positionPlayer()
	_fadeIn()
	_buildExitTriggers()
	add_child(ScoreHudScript.new())
	_buildExitMarkers()

func _applyGlobalTheme() -> void:
	var font = load("res://assets/fonts/MotionControl-Bold.otf")
	var theme = Theme.new()
	theme.default_font = font
	theme.default_font_size = 20
	get_tree().root.theme = theme

func _positionPlayer() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var x = SPAWN_RIGHT_X if GameData.spawnSide == "right" else SPAWN_LEFT_X
	player.position = Vector2(x, SPAWN_Y)

func _fadeIn() -> void:
	FaderScript.fadeIn(self, 0.8)

# Flechas "Salir" en ambos bordes
func _buildExitMarkers() -> void:
	for s in [ExitMarkerScript.Side.LEFT, ExitMarkerScript.Side.RIGHT]:
		var m = ExitMarkerScript.new()
		m.setup(s, EXIT_LABEL)
		add_child(m)

# ─── Triggers de salida (ambos lados → vuelve a Villa1 frente a la panadería) ─

func _buildExitTriggers() -> void:
	# Salida izquierda
	_makeExitArea(Vector2(16, 400))
	# Salida derecha
	_makeExitArea(Vector2(1136, 400))

func _makeExitArea(pos: Vector2) -> void:
	var exitArea = Area2D.new()
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(32, 400)
	shape.shape = rect
	exitArea.add_child(shape)
	exitArea.position = pos
	add_child(exitArea)
	exitArea.body_entered.connect(_on_exit_body_entered)

func _on_exit_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	_goToVilla1()

func _goToVilla1() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)

	# Siempre spawnear frente a la panadería en Villa1
	GameData.spawnSide = "panaderia"

	FaderScript.fadeOutAndChange(self, "res://scenes/nivel_1/Villa1.tscn", 0.8)
