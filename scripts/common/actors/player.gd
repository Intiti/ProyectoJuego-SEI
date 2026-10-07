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

	# Flechas (ui_left/ui_right) + A/D
	var dir = Input.get_axis("ui_left", "ui_right")
	if dir == 0.0:
		dir = float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A))
	velocity.x = dir * speed

	# Salto: ui_accept (espacio/enter) + W
	var jumpPressed = Input.is_action_just_pressed("ui_accept") or _wJustPressed()
	if jumpPressed and is_on_floor():
		velocity.y = jumpForce

	move_and_slide()
	_updateAnimation(dir)

# Detecta el flanco de subida de W (Input.is_action_just_pressed no aplica a teclas sueltas)
var _wWasDown := false
func _wJustPressed() -> bool:
	var down = Input.is_physical_key_pressed(KEY_W)
	var just = down and not _wWasDown
	_wWasDown = down
	return just

func _updateAnimation(dir: float):
	if not is_on_floor():
		# Si la animación de salto no está corriendo, la iniciamos.
		# Si ya terminó, pause=true la congela en el último frame.
		if sprite.animation != "jump":
			sprite.play("jump")
		elif not sprite.is_playing():
			sprite.pause()
	elif dir != 0:
		sprite.play("run")
		sprite.flip_h = dir < 0
	else:
		sprite.play("default")
