extends Node2D

# ==========================================
# MGTS - NIVEL 2: CONTROLADOR BASE DE ESCENA DEL BOSQUE
# ==========================================

const ScoreHudScript = preload("res://scripts/common/ui/scoreHud.gd")
const FaderScript = preload("res://scripts/common/ui/sceneFader.gd")

func _ready() -> void:
	_applyGlobalTheme()
	FaderScript.fadeIn(self, 0.8)
	
	# Asegurar que el HUD de puntuación esté activo
	if not get_node_or_null("ScoreHUD"):
		var hud = ScoreHudScript.new()
		hud.name = "ScoreHUD"
		add_child(hud)
	
	# Música mística del bosque
	var dj = get_node_or_null("/root/DJManager")
	if dj and dj.has_method("playMusic"):
		dj.playMusic("bosque")
	
	# Calibrar alineación y altura del personaje con el suelo
	call_deferred("_alinear_personaje_al_suelo")

func _alinear_personaje_al_suelo() -> void:
	var player = get_node_or_null("Player") as CharacterBody2D
	var suelo = get_node_or_null("Suelo") as StaticBody2D
	
	if player and suelo:
		var superficie_suelo_y = suelo.global_position.y
		var col_suelo = suelo.get_node_or_null("CollisionShape2D")
		if col_suelo and col_suelo.shape is RectangleShape2D:
			superficie_suelo_y -= (col_suelo.shape.size.y / 2.0)
		
		var col_player = player.get_node_or_null("CollisionShape2D")
		var offset_pies = 32.0
		if col_player and col_player.shape is RectangleShape2D:
			offset_pies = (col_player.shape.size.y / 2.0)
		
		var posicion_optima_y = superficie_suelo_y - offset_pies
		
		# Si el personaje fue instanciado flotando en el aire (fuera del suelo)
		if abs(player.global_position.y - posicion_optima_y) > 15.0:
			player.global_position.y = posicion_optima_y
			player.velocity = Vector2.ZERO
			print("Nivel2Base: Altura inicial del personaje corregida. Apoyado sobre el suelo en Y = ", posicion_optima_y)

func _applyGlobalTheme() -> void:
	var font = load("res://assets/fonts/MotionControl-Bold.otf")
	if font:
		var theme = Theme.new()
		theme.default_font = font
		theme.default_font_size = 20
		get_tree().root.theme = theme
