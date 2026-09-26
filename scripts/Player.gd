extends CharacterBody2D

const speed = 300.0
const gravity = 900.0
const jumpForce = -400.0

@onready var sprite = $Sprite2D

func _ready():
	add_to_group("player")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	var dir = Input.get_axis("ui_left", "ui_right")
	velocity.x = dir * speed

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jumpForce

	move_and_slide()
	_updateAnimation(dir)

func _updateAnimation(dir: float):
	if not is_on_floor():
		sprite.play("jump")
	elif dir != 0:
		sprite.play("run")
		sprite.flip_h = dir < 0
	else:
		sprite.play("default")
