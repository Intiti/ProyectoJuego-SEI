extends CharacterBody2D

@export var dialogFile: String = ""
@export var needsHelp: bool = true
@export var npcSprite: Texture2D
@export var solvedFlag: String = ""

var playerNearby: bool = false
var _exclamLabel: Label = null

# --- Examen ---
var _examPool: Array = []      # rutas completas de los 6 JSONs
var _examPicked: Array = []    # 3 rutas elegidas aleatoriamente
var _examIndex: int = 0        # cuál ejercicio estamos resolviendo ahora
var _examMode: bool = false    # true cuando este NPC corre un examen
var _examOutroLines: Array = []
var _examPlayerScene: String = ""
var _examNpcScene: String = ""

func _ready():
	add_to_group("npc")
	if npcSprite:
		$Sprite2D.texture = npcSprite

	if dialogFile != "" and GameData.isSolved(dialogFile):
		needsHelp = false

	if needsHelp:
		_createExclamation()

func _createExclamation():
	_exclamLabel = Label.new()
	_exclamLabel.text = "!"
	_exclamLabel.add_theme_font_size_override("font_size", 80)
	_exclamLabel.add_theme_color_override("font_color", Color(1, 0, 0, 1))
	_exclamLabel.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	_exclamLabel.add_theme_constant_override("shadow_offset_x", 3)
	_exclamLabel.add_theme_constant_override("shadow_offset_y", 3)
	_exclamLabel.position = Vector2(-16, -155)
	add_child(_exclamLabel)
	_floatExclam()

func _floatExclam():
	if not is_instance_valid(_exclamLabel):
		return
	var baseY: float = _exclamLabel.position.y
	while is_instance_valid(_exclamLabel):
		var t = create_tween()
		t.tween_property(_exclamLabel, "position:y", baseY - 12.0, 0.5).set_trans(Tween.TRANS_SINE)
		t.tween_property(_exclamLabel, "position:y", baseY, 0.5).set_trans(Tween.TRANS_SINE)
		await t.finished

func _on_detection_body_entered(body):
	if body.is_in_group("player"):
		playerNearby = true

func _on_detection_body_exited(body):
	if body.is_in_group("player"):
		playerNearby = false

func _unhandled_input(event):
	if not needsHelp:
		return
	if not playerNearby:
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_E or event.physical_keycode == KEY_E or event.is_action("interact"):
		get_viewport().set_input_as_handled()
		tryStartDialog()

func onPuzzleSolved():
	# Si no estamos en modo examen, comportamiento normal
	if not _examMode:
		needsHelp = false
		if is_instance_valid(_exclamLabel):
			_exclamLabel.queue_free()
			_exclamLabel = null
		if dialogFile != "":
			GameData.markSolved(dialogFile)
		if solvedFlag != "" and GameData.get(solvedFlag) != null:
			GameData.set(solvedFlag, true)
		return

	# Modo examen: avanzar al siguiente ejercicio
	_examIndex += 1
	if _examIndex >= _examPicked.size():
		# Examen completado
		_examMode = false
		needsHelp = false
		if is_instance_valid(_exclamLabel):
			_exclamLabel.queue_free()
			_exclamLabel = null
		if dialogFile != "":
			GameData.markSolved(dialogFile)
		if solvedFlag != "" and GameData.get(solvedFlag) != null:
			GameData.set(solvedFlag, true)
		# El outro del examen se abre en onExamPuzzleFinished después de la celebración

func tryStartDialog():
	if not playerNearby or not needsHelp:
		return
	if dialogFile == "":
		push_error("NPC '" + name + "' no tiene dialogFile asignado.")
		return
	var dialogBox = get_tree().get_first_node_in_group("dialog_box")
	if not dialogBox or dialogBox.isOpen:
		return
	var puzzle = get_tree().get_first_node_in_group("puzzle")
	if puzzle and puzzle.isOpen:
		return

	# Leer el JSON del guardia para detectar si tiene campo "exam"
	var file = FileAccess.open(dialogFile, FileAccess.READ)
	if not file:
		push_error("No se pudo abrir: " + dialogFile)
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()

	if parsed.has("exam"):
		_initExam(parsed, dialogBox)
	else:
		dialogBox.openWithNpc(dialogFile, self)

func _initExam(parsed: Dictionary, dialogBox: Node) -> void:
	var examData: Dictionary = parsed["exam"]
	var pool: Array = examData.get("pool", [])
	var pick: int = examData.get("pick", 3)
	var baseDir: String = dialogFile.get_base_dir()  # "res://dialogs" o la carpeta real

	# Construir rutas absolutas para cada ejercicio del pool
	_examPool = []
	for p in pool:
		# Si la ruta ya es absoluta (empieza con res://) úsala tal cual
		if p.begins_with("res://"):
			_examPool.append(p)
		else:
			_examPool.append(baseDir + "/" + p)

	# Elegir 'pick' ejercicios aleatoriamente sin repetición
	var indices = range(_examPool.size())
	indices.shuffle()
	_examPicked = []
	for i in range(min(pick, indices.size())):
		_examPicked.append(_examPool[indices[i]])

	_examIndex = 0
	_examMode = true

	# Iniciar una nueva sesión: las 3 vidas se mantienen entre los 3 ejercicios.
	var puzzle = get_tree().get_first_node_in_group("puzzle")
	if puzzle and puzzle.has_method("beginExamSession"):
		puzzle.beginExamSession()
	_examOutroLines = parsed.get("outro_lines", [])
	_examPlayerScene = parsed.get("player_scene", "")
	_examNpcScene = parsed.get("npc_scene", "")

	# Abrir el diálogo de introducción del guardia (sin puzzle)
	# Construimos un parsed temporal sin "exam" ni "puzzle" para que dialogBox
	# solo muestre las lines y cierre; luego lanzamos el primer ejercicio.
	dialogBox.openWithNpcExam(parsed, self)

# Llamado desde puzzleManager cuando termina la celebración del ejercicio de examen
# (en lugar del outro normal). Lanza el siguiente ejercicio o el outro final.
func onExamPuzzleFinished() -> void:
	# El ejercicio que acaba de terminar ya fue resuelto correctamente.
	# Avanzamos el índice ANTES de cargar el siguiente para no repetirlo.
	_examIndex += 1

	if _examIndex < _examPicked.size():
		# Hay más ejercicios — cargar el siguiente directamente
		var puzzle = get_tree().get_first_node_in_group("puzzle")
		var nextPuzzleData = _loadPuzzleData(_examPicked[_examIndex])
		if puzzle and nextPuzzleData:
			puzzle.open(nextPuzzleData, self)
	else:
		# Todos resueltos: mostrar outro del guardia
		needsHelp = false
		if is_instance_valid(_exclamLabel):
			_exclamLabel.queue_free()
			_exclamLabel = null
		if dialogFile != "":
			GameData.markSolved(dialogFile)
		if solvedFlag != "" and GameData.get(solvedFlag) != null:
			GameData.set(solvedFlag, true)

		var puzzle = get_tree().get_first_node_in_group("puzzle")
		if puzzle and puzzle.has_method("endExamSession"):
			puzzle.endExamSession()

		var dialogBox = get_tree().get_first_node_in_group("dialog_box")
		if dialogBox and _examOutroLines.size() > 0:
			var savedTexture: Texture2D = dialogBox._npcPortraitTexture
			dialogBox.openDirect(_examOutroLines, _examPlayerScene, _examNpcScene, true, savedTexture)
		_examOutroLines = []

func _loadPuzzleData(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Exam: no se pudo abrir ejercicio: " + path)
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	var puzzleData: Dictionary = parsed.get("puzzle", {})
	# Inyectar contexto de examen y escenas
	if not puzzleData.is_empty():
		puzzleData["npc_scene"] = _examNpcScene
		puzzleData["player_scene"] = _examPlayerScene
		puzzleData["exam_mode"] = true   # ← activa sistema de vidas en puzzleManager
		# Sin outro_lines: el examen usa onExamPuzzleFinished en su lugar
	return puzzleData
