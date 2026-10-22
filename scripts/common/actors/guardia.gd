extends CharacterBody2D

const WorldPromptScript = preload("res://scripts/common/ui/worldPrompt.gd")

@export var dialogFile: String = ""
@export var needsHelp: bool = true
@export var npcSprite: Texture2D
@export var solvedFlag: String = ""

var playerNearby: bool = false
var _prompt: Node2D = null

# --- Examen ---
var _examPool: Array = []      # rutas completas de los 6 JSONs
var _examPicked: Array = []    # 3 rutas elegidas aleatoriamente
var _examIndex: int = 0        # cuál ejercicio estamos resolviendo ahora
var _examMode: bool = false    # true cuando este NPC corre un examen
var _examOutroLines: Array = []
var _examPlayerScene: String = ""
var _examNpcScene: String = ""
var _examPickCount: int = 3

func _ready():
	add_to_group("npc")
	if npcSprite:
		$Sprite2D.texture = npcSprite

	if dialogFile != "" and GameData.isSolved(dialogFile):
		needsHelp = false

	if needsHelp:
		_createExclamation()

func _createExclamation():
	_prompt = WorldPromptScript.new()
	_prompt.setup(WorldPromptScript.Marker.EXCLAIM, "Hablar")
	# Centro del indicador sobre la cabeza del NPC (coordenadas locales)
	_prompt.position = Vector2(0, -115)
	add_child(_prompt)
	if playerNearby:
		_prompt.setNear(true)

func _removePrompt():
	if is_instance_valid(_prompt):
		_prompt.queue_free()
	_prompt = null

func _on_detection_body_entered(body):
	if body.is_in_group("player"):
		playerNearby = true
		if is_instance_valid(_prompt) and needsHelp:
			_prompt.setNear(true)

func _on_detection_body_exited(body):
	if body.is_in_group("player"):
		playerNearby = false
		if is_instance_valid(_prompt):
			_prompt.setNear(false)

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
		_removePrompt()
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
		_removePrompt()
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

	_examPickCount = pick
	_pickExercises()

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
		_openExamExercise()
	else:
		# Todos resueltos: mostrar outro del guardia
		needsHelp = false
		_removePrompt()
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

func startExam() -> void:
	_examIndex = 0
	_openExamExercise()

func restartExam() -> void:
	GameData.nivel1ExamReinicios += 1
	_pickExercises()
	_examIndex = 0
	_examMode = true
	var puzzle = get_tree().get_first_node_in_group("puzzle")
	if puzzle and puzzle.has_method("beginExamSession"):
		puzzle.beginExamSession()
	_openExamExercise()

func cancelExam() -> void:
	_examMode = false
	_examIndex = 0
	_examPicked = []

func _pickExercises() -> void:
	var indices = range(_examPool.size())
	indices.shuffle()
	_examPicked = []
	for i in range(min(_examPickCount, indices.size())):
		_examPicked.append(_examPool[indices[i]])

func _openExamExercise() -> void:
	var puzzle = get_tree().get_first_node_in_group("puzzle")
	var puzzleData = _loadPuzzleData(_examPicked[_examIndex])
	if puzzle and not puzzleData.is_empty():
		puzzle.open(puzzleData, self)

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
		puzzleData["exam_index"] = _examIndex
		puzzleData["exam_total"] = _examPicked.size()
		# Sin outro_lines: el examen usa onExamPuzzleFinished en su lugar
	return puzzleData
