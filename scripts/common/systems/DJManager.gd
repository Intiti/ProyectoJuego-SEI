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
