extends Node

var master_volume_percent: float = 100.0
var music_volume_percent: float = 100.0
var sfx_volume_percent: float = 100.0

func _ready() -> void:
	load_settings()
	apply_all_buses()

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
