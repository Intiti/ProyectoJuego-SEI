extends Node

# ==========================================
# MGTS - SISTEMA DE AUDIO GLOBAL (DJManager)
# Buses: Master, Music, SFX
# ==========================================

var _music_players: Array[AudioStreamPlayer] = []
var _current_player_index: int = 0
var _current_track: String = ""
var _fade_tween: Tween = null

var _sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS: int = 6

var _sfx_streams: Dictionary = {}
var _ultimo_sfx_ms: Dictionary = {}
const COOLDOWN_SFX_MS: int = 55

var _silenciado: bool = false
var _volumen_musica: float = 0.8
var _volumen_sfx: float = 0.85

# Pistas musicales utilizando los archivos existentes del proyecto
const MUSIC_TRACKS: Dictionary = {
	"menu": "res://assets/audio/music/Main.mp3",
	"intro": "res://assets/audio/music/Intro.mp3",
	"villa": "res://assets/audio/music/Villa_Miaulemana.mp3",
	"laboratorio": "res://assets/audio/music/Core.mp3",
	"laboratorio_alt": "res://assets/audio/music/Intro.mp3",
	"examen": "res://assets/audio/music/Puzzle_Battle.mp3",
	"rescate": "res://assets/audio/music/Puzzle_Battle.mp3",
	"victoria": "res://assets/audio/music/Main.mp3"
}

# Ajustes de atmósfera (pitch y volumen base) para diferenciar contextos del Nivel 3
const MUSIC_SETTINGS: Dictionary = {
	"menu": {"pitch": 1.0, "db": -3.0},
	"intro": {"pitch": 1.0, "db": -3.0},
	"villa": {"pitch": 1.0, "db": -3.0},
	"laboratorio": {"pitch": 1.0, "db": -0.1},
	"laboratorio_alt": {"pitch": 0.86, "db": -4.0},
	"examen": {"pitch": 0.96, "db": -4.5},
	"rescate": {"pitch": 1.05, "db": -3.5},
	"victoria": {"pitch": 1.02, "db": -2.5}
}

const RUTA_SFX_TEXTO: String = "res://assets/audio/sfx/SND_TXT1.wav"


func _ready() -> void:
	_asegurar_buses_audio()

	# Dos reproductores de música para transiciones suaves (crossfade) sin solapamiento
	for i in range(2):
		var p := AudioStreamPlayer.new()
		p.bus = "Music"
		add_child(p)
		_music_players.append(p)

	# Pool de reproductores para efectos de sonido (SFX)
	for i in range(MAX_SFX_PLAYERS):
		var s := AudioStreamPlayer.new()
		s.bus = "SFX"
		add_child(s)
		_sfx_players.append(s)

	_inicializar_efectos_sonido()
	set_music_volume(_volumen_musica)
	set_sfx_volume(_volumen_sfx)

	# Detectar cambios de escena y botones automáticamente
	get_tree().node_added.connect(_al_agregar_nodo)
	call_deferred("_verificar_escena_actual")


func _asegurar_buses_audio() -> void:
	if AudioServer.get_bus_index("Music") == -1:
		var idx_music: int = AudioServer.bus_count
		AudioServer.add_bus(idx_music)
		AudioServer.set_bus_name(idx_music, "Music")
		AudioServer.set_bus_send(idx_music, "Master")

	if AudioServer.get_bus_index("SFX") == -1:
		var idx_sfx: int = AudioServer.bus_count
		AudioServer.add_bus(idx_sfx)
		AudioServer.set_bus_name(idx_sfx, "SFX")
		AudioServer.set_bus_send(idx_sfx, "Master")


func _al_agregar_nodo(nodo: Node) -> void:
	if nodo == get_tree().current_scene:
		call_deferred("_verificar_escena_actual")

	if nodo is BaseButton:
		var boton := nodo as BaseButton
		if not boton.pressed.is_connected(_al_presionar_boton_global):
			boton.pressed.connect(_al_presionar_boton_global)

	if nodo.name == "DialogoUI" and nodo is CanvasLayer:
		var capa := nodo as CanvasLayer
		if not capa.visibility_changed.is_connected(_al_cambiar_visibilidad_dialogo.bind(capa)):
			capa.visibility_changed.connect(_al_cambiar_visibilidad_dialogo.bind(capa))

	if nodo.name == "VentanaEjercicio" and nodo is CanvasItem:
		var ve := nodo as CanvasItem
		if not ve.visibility_changed.is_connected(_al_cambiar_visibilidad_ejercicio.bind(ve)):
			ve.visibility_changed.connect(_al_cambiar_visibilidad_ejercicio.bind(ve))

	if nodo.name == "VentanaCompletado" and nodo is CanvasItem:
		var vc := nodo as CanvasItem
		if not vc.visibility_changed.is_connected(_al_cambiar_visibilidad_completado.bind(vc)):
			vc.visibility_changed.connect(_al_cambiar_visibilidad_completado.bind(vc))

	if nodo.has_signal("iniciar_ejercicio"):
		if not nodo.is_connected("iniciar_ejercicio", _al_habilitar_consola):
			nodo.connect("iniciar_ejercicio", _al_habilitar_consola)


func _al_cambiar_visibilidad_dialogo(capa: CanvasLayer) -> void:
	if capa != null and capa.visible:
		play_sfx("npc")
		play_sfx("dialogo")


func _al_cambiar_visibilidad_ejercicio(ve: CanvasItem) -> void:
	if ve != null and ve.visible:
		play_sfx("consola")


func _al_cambiar_visibilidad_completado(vc: CanvasItem) -> void:
	if vc != null and vc.visible:
		play_sfx("ejercicio_completado")


func _al_habilitar_consola() -> void:
	play_sfx("consola")


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		var escena: Node = get_tree().current_scene
		if escena != null:
			var dialogo_ui: CanvasLayer = escena.get_node_or_null("DialogoUI") as CanvasLayer
			if dialogo_ui != null and dialogo_ui.visible:
				play_sfx("dialogo")


func _al_presionar_boton_global() -> void:
	play_sfx("boton")


func _verificar_escena_actual() -> void:
	var escena: Node = get_tree().current_scene
	if escena == null:
		return

	var ruta: String = escena.scene_file_path
	if ruta == "":
		return

	if ruta.contains("scenes/Nivel_3/"):
		if ruta.ends_with("Final.tscn"):
			play_music("victoria")
		elif ruta.contains("10Cámara de Rescat"):
			play_music("rescate")
		else:
			play_music("laboratorio")
	elif ruta.contains("scenes/ExamenNivel3/"):
		play_music("examen")
	elif ruta.ends_with("Menu.tscn"):
		play_music("menu")


# ==========================================
# MÚSICA AMBIENTAL CON TRANSICIÓN SUAVE
# ==========================================

func play_music(track_name: String, fade_duration: float = 0.8) -> void:
	if _current_track == track_name:
		var actual: AudioStreamPlayer = _music_players[_current_player_index]
		if actual != null and actual.playing:
			return

	var path: String = MUSIC_TRACKS.get(track_name, "")
	var clave_ajustes: String = track_name
	if (path == "" or not ResourceLoader.exists(path)) and MUSIC_TRACKS.has(track_name + "_alt"):
		clave_ajustes = track_name + "_alt"
		path = MUSIC_TRACKS[clave_ajustes]
	if path == "" or not ResourceLoader.exists(path):
		push_warning("DJManager: pista no encontrada: " + track_name)
		return

	var stream: AudioStream = load(path)
	if stream == null:
		return

	# Asegurar loop en pistas MP3
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true

	var ajustes: Dictionary = MUSIC_SETTINGS.get(clave_ajustes, {"pitch": 1.0, "db": -3.0})
	var pitch_objetivo: float = float(ajustes.get("pitch", 1.0))
	var db_objetivo: float = float(ajustes.get("db", -3.0))

	var prev_player: AudioStreamPlayer = _music_players[_current_player_index]
	_current_player_index = (_current_player_index + 1) % _music_players.size()
	var next_player: AudioStreamPlayer = _music_players[_current_player_index]

	_current_track = track_name

	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()

	next_player.stream = stream
	next_player.pitch_scale = pitch_objetivo

	if fade_duration > 0.0 and prev_player.playing:
		next_player.volume_db = -36.0
		next_player.play()
		_fade_tween = create_tween().set_parallel(true)
		_fade_tween.tween_property(next_player, "volume_db", db_objetivo, fade_duration)
		_fade_tween.tween_property(prev_player, "volume_db", -40.0, fade_duration)
		_fade_tween.chain().tween_callback(prev_player.stop)
	else:
		prev_player.stop()
		next_player.volume_db = db_objetivo
		next_player.play()


func stop_music(fade_duration: float = 0.5) -> void:
	_current_track = ""
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()

	for p in _music_players:
		if p.playing:
			if fade_duration > 0.0:
				var t := create_tween()
				t.tween_property(p, "volume_db", -40.0, fade_duration)
				t.tween_callback(p.stop)
			else:
				p.stop()


# ==========================================
# EFECTOS DE SONIDO (SFX)
# ==========================================

func play_sfx(sfx_name: String, pitch_variation: float = 0.04) -> void:
	if _silenciado:
		return

	var ahora: int = Time.get_ticks_msec()
	var ultimo: int = int(_ultimo_sfx_ms.get(sfx_name, 0))
	if ahora - ultimo < COOLDOWN_SFX_MS:
		return
	_ultimo_sfx_ms[sfx_name] = ahora

	if not _sfx_streams.has(sfx_name):
		return

	var stream: AudioStream = _sfx_streams[sfx_name]
	if stream == null:
		return

	var reproductor: AudioStreamPlayer = null
	for s in _sfx_players:
		if not s.playing:
			reproductor = s
			break
	if reproductor == null:
		reproductor = _sfx_players[0]

	reproductor.stream = stream
	reproductor.volume_db = _obtener_volumen_base_sfx(sfx_name)
	if pitch_variation > 0.0:
		reproductor.pitch_scale = randf_range(1.0 - pitch_variation, 1.0 + pitch_variation)
	else:
		reproductor.pitch_scale = 1.0
	reproductor.play()


func _obtener_volumen_base_sfx(sfx_name: String) -> float:
	match sfx_name:
		"dialogo":
			return -7.0
		"boton", "bloque_colocar", "bloque_quitar":
			return -6.0
		"incorrecto", "examen_reprobado":
			return -4.5
		_:
			return -4.0


func _inicializar_efectos_sonido() -> void:
	# Reutilizar el recurso existente SND_TXT1.wav para diálogo
	if ResourceLoader.exists(RUTA_SFX_TEXTO):
		_sfx_streams["dialogo"] = load(RUTA_SFX_TEXTO)
	else:
		_sfx_streams["dialogo"] = _generar_tono_secuencia([580.0], [0.04], 0.25)

	# Síntesis retro pixel-art (PCM 16-bit) para todos los eventos de interacción
	_sfx_streams["boton"] = _generar_tono_secuencia([520.0, 680.0], [0.03, 0.04], 0.25)
	_sfx_streams["ui_abrir"] = _generar_tono_secuencia([360.0, 540.0, 720.0], [0.04, 0.04, 0.06], 0.28)
	_sfx_streams["ui_cerrar"] = _generar_tono_secuencia([680.0, 480.0, 320.0], [0.04, 0.04, 0.06], 0.25)
	_sfx_streams["npc"] = _generar_tono_secuencia([440.0, 660.0], [0.05, 0.07], 0.30)
	_sfx_streams["bloque_colocar"] = _generar_tono_secuencia([480.0, 740.0], [0.035, 0.05], 0.28)
	_sfx_streams["bloque_quitar"] = _generar_tono_secuencia([620.0, 410.0], [0.035, 0.05], 0.25)
	_sfx_streams["ejecutar"] = _generar_tono_secuencia([400.0, 500.0, 640.0], [0.04, 0.04, 0.06], 0.30)
	_sfx_streams["correcto"] = _generar_tono_secuencia([523.25, 659.25, 783.99, 1046.5], [0.06, 0.06, 0.06, 0.14], 0.35)
	_sfx_streams["incorrecto"] = _generar_tono_secuencia([260.0, 195.0], [0.10, 0.16], 0.35)
	_sfx_streams["ejercicio_completado"] = _generar_tono_secuencia([523.25, 659.25, 783.99, 1046.5, 1318.5], [0.07, 0.07, 0.07, 0.09, 0.18], 0.36)
	_sfx_streams["insignia"] = _generar_tono_secuencia([659.25, 880.0, 1174.66, 1318.5], [0.06, 0.06, 0.08, 0.16], 0.34)
	_sfx_streams["puerta"] = _generar_tono_secuencia([220.0, 330.0, 440.0, 587.33], [0.06, 0.06, 0.06, 0.12], 0.32)
	_sfx_streams["consola"] = _generar_tono_secuencia([600.0, 800.0, 1000.0], [0.035, 0.035, 0.06], 0.28)
	_sfx_streams["examen_aprobado"] = _generar_tono_secuencia([523.25, 659.25, 783.99, 1046.5, 1174.66, 1567.98], [0.07, 0.07, 0.07, 0.08, 0.08, 0.22], 0.38)
	_sfx_streams["examen_reprobado"] = _generar_tono_secuencia([349.23, 311.13, 277.18, 233.08], [0.10, 0.10, 0.10, 0.22], 0.35)
	_sfx_streams["rescate_panko"] = _generar_tono_secuencia([587.33, 740.0, 880.0, 1174.66, 1480.0], [0.07, 0.07, 0.08, 0.10, 0.24], 0.38)


func _generar_tono_secuencia(frecuencias: Array, duraciones: Array, amplitud: float = 0.3) -> AudioStreamWAV:
	var mix_rate: int = 22050
	var bytes := PackedByteArray()

	for idx in range(frecuencias.size()):
		var freq: float = float(frecuencias[idx])
		var dur: float = float(duraciones[idx])
		var total_muestras: int = max(1, int(mix_rate * dur))

		for m in range(total_muestras):
			var t: float = float(m) / float(mix_rate)
			var progreso: float = float(m) / float(total_muestras)
			var envolvente: float = 1.0
			if progreso < 0.08:
				envolvente = progreso / 0.08
			elif progreso > 0.75:
				envolvente = max(0.0, (1.0 - progreso) / 0.25)

			# Onda híbrida (cuadrada suave + senoidal) estilo retro pixel-art
			var senoidal: float = sin(TAU * freq * t)
			var cuadrada: float = 1.0 if senoidal >= 0.0 else -1.0
			var muestra_float: float = ((0.6 * senoidal) + (0.4 * cuadrada)) * amplitud * envolvente
			var valor_pcm: int = clampi(int(muestra_float * 32767.0), -32768, 32767)

			bytes.append(valor_pcm & 0xFF)
			bytes.append((valor_pcm >> 8) & 0xFF)

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = mix_rate
	wav.stereo = false
	wav.data = bytes
	return wav


# ==========================================
# CONTROL DE VOLUMEN Y SILENCIO
# ==========================================

func set_music_volume(linear_val: float) -> void:
	_volumen_musica = clampf(linear_val, 0.0, 1.0)
	_asegurar_buses_audio()
	var idx: int = AudioServer.get_bus_index("Music")
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, linear_to_db(max(_volumen_musica, 0.0001)))
		AudioServer.set_bus_mute(idx, _silenciado or _volumen_musica <= 0.001)


func set_sfx_volume(linear_val: float) -> void:
	_volumen_sfx = clampf(linear_val, 0.0, 1.0)
	_asegurar_buses_audio()
	var idx: int = AudioServer.get_bus_index("SFX")
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, linear_to_db(max(_volumen_sfx, 0.0001)))
		AudioServer.set_bus_mute(idx, _silenciado or _volumen_sfx <= 0.001)


func get_music_volume() -> float:
	return _volumen_musica


func get_sfx_volume() -> float:
	return _volumen_sfx


func set_mute(silenciar: bool) -> void:
	_silenciado = silenciar
	_asegurar_buses_audio()
	var master_idx: int = AudioServer.get_bus_index("Master")
	if master_idx != -1:
		AudioServer.set_bus_mute(master_idx, _silenciado)
	set_music_volume(_volumen_musica)
	set_sfx_volume(_volumen_sfx)


func toggle_mute() -> bool:
	set_mute(not _silenciado)
	return _silenciado


func is_muted() -> bool:
	return _silenciado


# Alias camelCase para compatibilidad con scripts de Nivel 0 y Nivel 1 (ej. mainMenu.gd)
func playMusic(track_name: String, fade_duration: float = 0.8) -> void:
	play_music(track_name, fade_duration)


func stopMusic(fade_duration: float = 0.5) -> void:
	stop_music(fade_duration)


func setMusicVolume(linear_val: float) -> void:
	set_music_volume(linear_val)


func setSfxVolume(linear_val: float) -> void:
	set_sfx_volume(linear_val)


func playSfx(sfx_name: String, pitch_variation: float = 0.04) -> void:
	play_sfx(sfx_name, pitch_variation)
