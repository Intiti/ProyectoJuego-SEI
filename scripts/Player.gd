extends CharacterBody2D

const SPEED = 200.0
const GRAVITY = 900.0
const JUMP_FORCE = -400.0

func _ready():
	# necesario para que NPC y DialogBox puedan encontrarlo
	add_to_group("player")

func _physics_process(delta):
	# gravedad
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# movimiento horizontal
	var dir = Input.get_axis("ui_left", "ui_right")
	velocity.x = dir * SPEED

	# salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE

	move_and_slide()
