extends Node

const SETTINGS_PATH := "user://settings.cfg"
const SECTION_AUDIO := "audio"
const KEY_MASTER_VOLUME := "master_volume"

var master_volume_percent: float = 100.0

func _ready() -> void:
	load_settings()
	apply_master_volume()

func set_master_volume_percent(value: float) -> void:
	master_volume_percent = clampf(value, 0.0, 100.0)
	apply_master_volume()
	save_settings()

func apply_master_volume() -> void:
	var master_index := AudioServer.get_bus_index("Master")
	if(master_index == -1):
		return
	if(master_volume_percent <= 0.0):
		AudioServer.set_bus_volume_db(master_index, -80.0)
	else:
		AudioServer.set_bus_volume_db(master_index, linear_to_db(master_volume_percent / 100.0))

func get_volume_icon() -> String:
	if(master_volume_percent <= 0.0):
		return "🔇"
	if(master_volume_percent < 50.0):
		return "🔉"
	return "🔊"

func load_settings() -> void:
	var config := ConfigFile.new()
	if(config.load(SETTINGS_PATH) == OK):
		master_volume_percent = float(config.get_value(SECTION_AUDIO, KEY_MASTER_VOLUME, 100.0))
	master_volume_percent = clampf(master_volume_percent, 0.0, 100.0)

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value(SECTION_AUDIO, KEY_MASTER_VOLUME, master_volume_percent)
	config.save(SETTINGS_PATH)
