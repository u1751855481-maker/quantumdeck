extends Node

const MUSIC_FADE_SECONDS: float = 1.25
const MENU_MUSIC_STREAM: AudioStream = preload("res://Assets/sfx/typingsfx.mp3")
const BATTLE_MUSIC_STREAM: AudioStream = preload("res://Assets/sfx/token.ogg")

var master_volume_percent: float = 100.0
var music_volume_percent: float = 100.0
var sfx_volume_percent: float = 100.0
var MusicPlayer: AudioStreamPlayer
var MusicFadeTween: Tween
var CurrentMusicTag: StringName = &""

func _ready() -> void:
	setup_music_player()
	load_settings()
	apply_all_buses()

func setup_music_player() -> void:
	MusicPlayer = AudioStreamPlayer.new()
	MusicPlayer.bus = "Music"
	MusicPlayer.name = "MusicPlayer"
	add_child(MusicPlayer)

func set_master_volume_percent(value: float) -> void:
	master_volume_percent = clampf(value, 0.0, 100.0)
	apply_bus_volume("Master", master_volume_percent)
	persist_audio()

func set_music_volume_percent(value: float) -> void:
	music_volume_percent = clampf(value, 0.0, 100.0)
	apply_bus_volume("Music", music_volume_percent)
	persist_audio()

func set_sfx_volume_percent(value: float) -> void:
	sfx_volume_percent = clampf(value, 0.0, 100.0)
	apply_bus_volume("SFX", sfx_volume_percent)
	persist_audio()

func apply_all_buses() -> void:
	apply_bus_volume("Master", master_volume_percent)
	apply_bus_volume("Music", music_volume_percent)
	apply_bus_volume("SFX", sfx_volume_percent)

func apply_bus_volume(bus_name: String, value_percent: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if(bus_index == -1):
		return
	if(value_percent <= 0.0):
		AudioServer.set_bus_volume_db(bus_index, -80.0)
	else:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value_percent / 100.0))

func play_menu_music(with_fade_in: bool = true) -> void:
	play_music_track(&"menu", MENU_MUSIC_STREAM, with_fade_in)

func play_battle_music(with_fade_in: bool = true) -> void:
	play_music_track(&"battle", BATTLE_MUSIC_STREAM, with_fade_in)

func stop_music(with_fade_out: bool = true) -> void:
	if(!MusicPlayer || !MusicPlayer.playing):
		CurrentMusicTag = &""
		return
	if(MusicFadeTween):
		MusicFadeTween.kill()
	if(with_fade_out):
		MusicFadeTween = create_tween()
		MusicFadeTween.tween_property(MusicPlayer, "volume_db", -80.0, MUSIC_FADE_SECONDS)
		MusicFadeTween.tween_callback(func() -> void:
			MusicPlayer.stop()
			CurrentMusicTag = &""
		)
	else:
		MusicPlayer.stop()
		CurrentMusicTag = &""

func play_music_track(track_tag: StringName, stream: AudioStream, with_fade_in: bool = true) -> void:
	if(!MusicPlayer || stream == null):
		return
	if(CurrentMusicTag == track_tag && MusicPlayer.playing):
		return
	if(MusicFadeTween):
		MusicFadeTween.kill()
	if(MusicPlayer.playing):
		MusicFadeTween = create_tween()
		MusicFadeTween.tween_property(MusicPlayer, "volume_db", -80.0, MUSIC_FADE_SECONDS)
		MusicFadeTween.tween_callback(func() -> void:
			apply_music_stream(stream, track_tag, with_fade_in)
		)
	else:
		apply_music_stream(stream, track_tag, with_fade_in)

func apply_music_stream(stream: AudioStream, track_tag: StringName, with_fade_in: bool) -> void:
	var stream_copy = stream.duplicate(true)
	if(stream_copy is AudioStreamMP3):
		stream_copy.loop = true
	elif(stream_copy is AudioStreamOggVorbis):
		stream_copy.loop = true
	MusicPlayer.stream = stream_copy
	if(with_fade_in):
		MusicPlayer.volume_db = -80.0
	else:
		MusicPlayer.volume_db = 0.0
	MusicPlayer.play()
	CurrentMusicTag = track_tag
	if(with_fade_in):
		MusicFadeTween = create_tween()
		MusicFadeTween.tween_property(MusicPlayer, "volume_db", 0.0, MUSIC_FADE_SECONDS)

func get_volume_icon() -> String:
	if(master_volume_percent <= 0.0):
		return "🔇"
	if(master_volume_percent < 50.0):
		return "🔉"
	return "🔊"

func load_settings() -> void:
	master_volume_percent = SaveSystem.get_audio_value("master_volume", 100.0)
	music_volume_percent = SaveSystem.get_audio_value("music_volume", 100.0)
	sfx_volume_percent = SaveSystem.get_audio_value("sfx_volume", 100.0)

func persist_audio() -> void:
	SaveSystem.set_audio_value("master_volume", master_volume_percent)
	SaveSystem.set_audio_value("music_volume", music_volume_percent)
	SaveSystem.set_audio_value("sfx_volume", sfx_volume_percent)
