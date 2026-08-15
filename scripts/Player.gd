extends CharacterBody2D

const speed = 200.0
const gravity = 900.0
const jumpForce = -400.0

func _ready():
	add_to_group("player")
	setGlobalFontSize(25)

func setGlobalFontSize(newSize: int):
	var globalTheme = get_tree().root.theme
	if not globalTheme:
		globalTheme = Theme.new()
		get_tree().root.theme = globalTheme
	globalTheme.default_font_size = newSize

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	var dir = Input.get_axis("ui_left", "ui_right")
	velocity.x = dir * speed

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jumpForce

	move_and_slide()
