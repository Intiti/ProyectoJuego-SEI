extends Node

# ─────────────────────────────────────────────────────────────────────────────
#  DJManager — maneja bleeps de diálogo Y música de fondo con crossfade
#
#  Uso desde cualquier escena:
#      DJManager.playMusic("menu")    → música del menú principal
#      DJManager.playMusic("intro")   → música de la intro
#      DJManager.playMusic("villa")   → música de la villa / exploración
#
#  El DJ es Autoload → siempre está vivo entre cambios de escena.
#  Rutas de audio esperadas (ajusta según tu proyecto):
#      res://assets/audio/MUS_Menu.ogg
#      res://assets/audio/MUS_Intro.ogg
#      res://assets/audio/MUS_Villa.ogg
# ─────────────────────────────────────────────────────────────────────────────

# ── Configuración ─────────────────────────────────────────────────────────────

const MUSIC_TRACKS: Dictionary = {
	"menu":  "res://assets/audio/music/Main.mp3",
	"intro": "res://assets/audio/music/Intro.mp3",
	"villa": "res://assets/audio/music/Villa_Miaulemana.mp3",
}

const FADE_DURATION := 1.2   # segundos de crossfade
const MUSIC_VOLUME  := -14.0 # dB de volumen normal para la música (antes -6; bajado para no tapar los bleeps)

# ── Estado interno ─────────────────────────────────────────────────────────────

var _currentTrack: String = ""

# Dos players para crossfade A↔B
var _playerA: AudioStreamPlayer
var _playerB: AudioStreamPlayer
var _activePlayer: AudioStreamPlayer   # el que suena ahora
var _inactivePlayer: AudioStreamPlayer # el que va a entrar

var _fadeTween: Tween = null

const SFX_PATHS: Dictionary = {
	"fanfare": "res://assets/audio/sfx/completed-lesson.mp3",
	"error": "res://assets/audio/sfx/wrong.mp3",
	"correct": "res://assets/audio/sfx/correct.mp3",
	"streak": "res://assets/audio/sfx/5-correct-answers.mp3",
}

const SFX_START_OFFSET: Dictionary = {
	"fanfare": 0.14,
	"error": 0.4,
	"correct": 0.25,
	"streak": 0.64,
}
const SFX_EXTENSIONS: Array = ["ogg", "wav", "mp3"]
const SFX_VOLUME_DB: Dictionary = {
	"fanfare": -4.0,
	"error": -6.0,
	"correct": -8.0,
}
const SFX_POOL_SIZE := 8

const STREAK_START := 3
const STREAK_PITCH_SEMITONES: Array = [0, 2, 4, 5, 7, 9, 11, 12]
const STREAK_VOLUME_BASE := -10.0
const STREAK_VOLUME_STEP := 1.0
const STREAK_VOLUME_MAX := -3.0

var _sfxPool: Array[AudioStreamPlayer] = []
var _sfxCache: Dictionary = {}
var _sfxNext: int = 0

# ── Bleep de diálogo ──────────────────────────────────────────────────────────

var _bleepPlayer: AudioStreamPlayer
var _bleepStream: AudioStream

# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	# Crear los dos players de música
	_playerA = _makePlayer()
	_playerB = _makePlayer()
	_activePlayer   = _playerA
	_inactivePlayer = _playerB

	# Player de bleep
	_bleepPlayer = AudioStreamPlayer.new()
	add_child(_bleepPlayer)
	_bleepStream = load("res://assets/audio/sfx/SND_TXT1.wav")
	if _bleepStream:
		_bleepPlayer.stream = _bleepStream
	_bleepPlayer.volume_db = -6.0
	_buildSfxPool()


func _makePlayer() -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = "Music"          # bus "Music" en tu AudioServer (o "Master" si no tienes)
	p.volume_db = -80.0      # silencioso hasta que le toque sonar
	add_child(p)
	return p


# ─────────────────────────────────────────────────────────────────────────────
#  API pública
# ─────────────────────────────────────────────────────────────────────────────

## Cambia la música con crossfade suave.
## trackKey: "menu" | "intro" | "villa"   (o cualquier clave de MUSIC_TRACKS)
func playMusic(trackKey: String) -> void:
	if trackKey == _currentTrack:
		return   # ya está sonando, no hacer nada

	if not MUSIC_TRACKS.has(trackKey):
		push_warning("DJManager: clave de música desconocida '%s'" % trackKey)
		return

	var path: String = MUSIC_TRACKS[trackKey]
	var stream = load(path)
	if not stream:
		push_warning("DJManager: no se pudo cargar '%s'" % path)
		return

	_currentTrack = trackKey

	# Preparar el player inactivo con la nueva pista
	_inactivePlayer.stream = stream
	_inactivePlayer.stream.loop = true   # loop infinito
	_inactivePlayer.volume_db = -80.0
	_inactivePlayer.play()

	# Cancelar cualquier fade previo en curso
	if _fadeTween and _fadeTween.is_valid():
		_fadeTween.kill()

	# Crossfade: el activo baja, el inactivo sube
	_fadeTween = create_tween()
	_fadeTween.set_parallel(true)
	_fadeTween.tween_property(_activePlayer,   "volume_db", -80.0,        FADE_DURATION)
	_fadeTween.tween_property(_inactivePlayer, "volume_db", MUSIC_VOLUME, FADE_DURATION)

	# Al terminar el fade, detener el que bajó y hacer el swap
	_fadeTween.set_parallel(false)
	var old_active := _activePlayer
	_fadeTween.tween_callback(func():
		old_active.stop()
	)

	# Intercambiar roles
	var tmp := _activePlayer
	_activePlayer   = _inactivePlayer
	_inactivePlayer = tmp


## Detiene la música con fade-out.
func stopMusic() -> void:
	_currentTrack = ""
	if _fadeTween and _fadeTween.is_valid():
		_fadeTween.kill()
	_fadeTween = create_tween()
	_fadeTween.tween_property(_activePlayer, "volume_db", -80.0, FADE_DURATION)
	_fadeTween.tween_callback(func(): _activePlayer.stop())


## Devuelve la clave de la pista que está sonando ahora ("" si ninguna).
func currentTrack() -> String:
	return _currentTrack


# ─────────────────────────────────────────────────────────────────────────────
#  Bleeps de diálogo (igual que antes)
# ─────────────────────────────────────────────────────────────────────────────

func playDialogBleep() -> void:
	if not _bleepStream:
		return
	_bleepPlayer.pitch_scale = randf_range(0.85, 1.15)
	_bleepPlayer.play()


func playDialogBleepPitched(basePitch: float) -> void:
	if not _bleepStream:
		return
	_bleepPlayer.pitch_scale = basePitch + randf_range(-0.08, 0.08)
	_bleepPlayer.play()


func _buildSfxPool() -> void:
	var busName: String = "SFX" if AudioServer.get_bus_index("SFX") != -1 else "Master"
	for i in SFX_POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = busName
		add_child(p)
		_sfxPool.append(p)


func _getSfx(key: String) -> AudioStream:
	if _sfxCache.has(key):
		return _sfxCache[key]
	var stream: AudioStream = null
	if SFX_PATHS.has(key):
		var basePath: String = SFX_PATHS[key]
		if ResourceLoader.exists(basePath):
			stream = load(basePath)
		else:
			for ext in SFX_EXTENSIONS:
				var path: String = "%s.%s" % [basePath, ext]
				if ResourceLoader.exists(path):
					stream = load(path)
					break
	_sfxCache[key] = stream
	return stream

func _freeSfxPlayer() -> AudioStreamPlayer:
	for p in _sfxPool:
		if not p.playing:
			return p
	var stolen: AudioStreamPlayer = _sfxPool[_sfxNext]
	_sfxNext = (_sfxNext + 1) % _sfxPool.size()
	return stolen


func playSfx(key: String, volumeDb: float = 0.0, pitch: float = 1.0) -> void:
	var stream: AudioStream = _getSfx(key)
	if stream == null or _sfxPool.is_empty():
		return
	var player: AudioStreamPlayer = _freeSfxPlayer()
	player.stream = stream
	player.volume_db = volumeDb
	player.pitch_scale = pitch
	player.play(float(SFX_START_OFFSET.get(key, 0.0)))

func playFanfare() -> void:
	playSfx("fanfare", SFX_VOLUME_DB["fanfare"])


func playError() -> void:
	playSfx("error", SFX_VOLUME_DB["error"])


func playCorrect() -> void:
	playSfx("correct", SFX_VOLUME_DB["correct"])


func playStreak(streak: int) -> void:
	var step: int = clampi(streak - STREAK_START, 0, STREAK_PITCH_SEMITONES.size() - 1)
	var pitch: float = pow(2.0, float(STREAK_PITCH_SEMITONES[step]) / 12.0)
	var volume: float = minf(STREAK_VOLUME_BASE + STREAK_VOLUME_STEP * float(step), STREAK_VOLUME_MAX)
	playSfx("streak", volume, pitch)
