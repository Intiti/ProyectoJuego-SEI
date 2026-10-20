extends "res://scripts/common/compat/AudioNivel3Actual.gd"
# Adaptador: el motor actual se conserva para Nivel 3 y el original para el resto.
const AudioOriginal = preload("res://scripts/common/compat/AudioOriginal.gd")
var audio_original: Node = null

func _ready() -> void:
	audio_original = AudioOriginal.new()
	audio_original.name = "AudioOriginal"
	add_child(audio_original)
	super._ready()
	get_tree().scene_changed.connect(_verificar_escena_actual)

func _es_nivel3() -> bool:
	var escena := get_tree().current_scene
	if escena == null:
		return false
	var ruta: String = escena.scene_file_path
	return ruta.contains("/Nivel_3/") or ruta.contains("/ExamenNivel3/")

func _detener_audio_original() -> void:
	if audio_original == null:
		return
	var tween = audio_original.get("_fadeTween")
	if tween != null and tween.is_valid():
		tween.kill()
	for clave in ["_playerA", "_playerB", "_bleepPlayer"]:
		var player = audio_original.get(clave)
		if player != null:
			player.stop()
	for player in audio_original.get("_sfxPool"):
		player.stop()
	audio_original.set("_currentTrack", "")

func _verificar_escena_actual() -> void:
	if _es_nivel3():
		_detener_audio_original()
		set_music_volume(_volumen_musica)
		set_sfx_volume(_volumen_sfx)
		super._verificar_escena_actual()
	else:
		super.stop_music(0.0)
		for player in _sfx_players:
			player.stop()

func _input(event: InputEvent) -> void:
	if _es_nivel3():
		super._input(event)

func _al_presionar_boton_global() -> void:
	if _es_nivel3():
		super._al_presionar_boton_global()

func play_music(track_name: String, fade_duration: float = 0.8) -> void:
	if _es_nivel3():
		_detener_audio_original()
		super.play_music(track_name, fade_duration)
	else:
		playMusic(track_name, fade_duration)

func play_sfx(sfx_name: String, pitch_variation: float = 0.04) -> void:
	if _es_nivel3():
		super.play_sfx(sfx_name, pitch_variation)

func playMusic(track_name: String, fade_duration: float = 0.8) -> void:
	if _es_nivel3():
		play_music(track_name, fade_duration)
	else:
		super.stop_music(0.0)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), 0.0)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), 0.0)
		audio_original.playMusic(track_name)

func stopMusic(fade_duration: float = 0.5) -> void:
	if _es_nivel3():
		super.stopMusic(fade_duration)
	else:
		audio_original.stopMusic()

func currentTrack() -> String:
	return _current_track if _es_nivel3() else str(audio_original.currentTrack())

func playDialogBleep() -> void:
	audio_original.playDialogBleep()

func playDialogBleepPitched(basePitch: float) -> void:
	audio_original.playDialogBleepPitched(basePitch)

func playFanfare() -> void:
	audio_original.playFanfare()

func playError() -> void:
	audio_original.playError()

func playCorrect() -> void:
	audio_original.playCorrect()

func playStreak(streak: int) -> void:
	audio_original.playStreak(streak)
