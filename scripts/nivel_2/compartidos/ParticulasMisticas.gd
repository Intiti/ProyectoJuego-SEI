extends Node2D

# ==========================================
# MGTS - NIVEL 2: AMBIENTE Y LUCES MÍSTICAS
# Partículas flotantes de maná y luciérnagas
# ==========================================

const CANTIDAD := 35
var orbes: Array[Dictionary] = []

func _ready() -> void:
	z_index = 2
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	for i in range(CANTIDAD):
		orbes.append({
			"pos": Vector2(rng.randf_range(50, 1950), rng.randf_range(150, 600)),
			"vel": Vector2(rng.randf_range(-15, 15), rng.randf_range(-10, 10)),
			"rad": rng.randf_range(2.0, 5.0),
			"color": Color(rng.randf_range(0.2, 0.9), rng.randf_range(0.8, 1.0), rng.randf_range(0.7, 1.0), 0.75),
			"fase": rng.randf_range(0.0, TAU),
			"velocidad_fase": rng.randf_range(1.5, 3.5)
		})

func _process(delta: float) -> void:
	for orbe in orbes:
		orbe.pos += orbe.vel * delta
		orbe.fase += orbe.velocidad_fase * delta
		if orbe.pos.x < 0: orbe.pos.x = 2000
		if orbe.pos.x > 2000: orbe.pos.x = 0
		if orbe.pos.y < 100: orbe.pos.y = 620
		if orbe.pos.y > 620: orbe.pos.y = 100
	queue_redraw()

func _draw() -> void:
	for orbe in orbes:
		var brillo = (sin(orbe.fase) + 1.0) * 0.5
		var col = orbe.color
		col.a = 0.25 + brillo * 0.65
		# Halo exterior
		draw_circle(orbe.pos, orbe.rad * 2.2, Color(col.r, col.g, col.b, col.a * 0.3))
		# Núcleo brillante
		draw_circle(orbe.pos, orbe.rad, col)
		draw_circle(orbe.pos, orbe.rad * 0.4, Color.WHITE)
