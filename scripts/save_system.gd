extends Node

const SAVE_PATH := "user://save_data.cfg"
const SAVE_VERSION := 1

var data := {
	"version": SAVE_VERSION,
	"audio": {
		"master_volume": 100.0,
		"music_volume": 100.0,
		"sfx_volume": 100.0
	},
	"video": {
		"ui_scale": 1.0,
		"mute_in_background": false,
		"reduce_flashes": false
	},
	"progress": {
		"high_score": 0,
		"unlocks": []
	},
	"controls": {
		"ui_cancel": KEY_ESCAPE,
		"debug_toggle": KEY_F1
	}
}

func _ready() -> void:
	load_data()
	apply_controls()

func load_data() -> void:
	var cfg := ConfigFile.new()
	if(cfg.load(SAVE_PATH) != OK):
		save_data()
		return
	data["version"] = int(cfg.get_value("meta", "version", SAVE_VERSION))
	data["audio"]["master_volume"] = float(cfg.get_value("audio", "master_volume", data["audio"]["master_volume"]))
	data["audio"]["music_volume"] = float(cfg.get_value("audio", "music_volume", data["audio"]["music_volume"]))
	data["audio"]["sfx_volume"] = float(cfg.get_value("audio", "sfx_volume", data["audio"]["sfx_volume"]))
	data["video"]["ui_scale"] = float(cfg.get_value("video", "ui_scale", data["video"]["ui_scale"]))
	data["video"]["mute_in_background"] = bool(cfg.get_value("video", "mute_in_background", data["video"]["mute_in_background"]))
	data["video"]["reduce_flashes"] = bool(cfg.get_value("video", "reduce_flashes", data["video"]["reduce_flashes"]))
	data["progress"]["high_score"] = int(cfg.get_value("progress", "high_score", data["progress"]["high_score"]))
	data["progress"]["unlocks"] = cfg.get_value("progress", "unlocks", data["progress"]["unlocks"])
	for action_name in data["controls"].keys():
		data["controls"][action_name] = int(cfg.get_value("controls", action_name, data["controls"][action_name]))

func save_data() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("meta", "version", SAVE_VERSION)
	cfg.set_value("audio", "master_volume", data["audio"]["master_volume"])
	cfg.set_value("audio", "music_volume", data["audio"]["music_volume"])
	cfg.set_value("audio", "sfx_volume", data["audio"]["sfx_volume"])
	cfg.set_value("video", "ui_scale", data["video"]["ui_scale"])
	cfg.set_value("video", "mute_in_background", data["video"]["mute_in_background"])
	cfg.set_value("video", "reduce_flashes", data["video"]["reduce_flashes"])
	cfg.set_value("progress", "high_score", data["progress"]["high_score"])
	cfg.set_value("progress", "unlocks", data["progress"]["unlocks"])
	for action_name in data["controls"].keys():
		cfg.set_value("controls", action_name, data["controls"][action_name])
	cfg.save(SAVE_PATH)

func get_audio_value(key: String, default_value: float = 100.0) -> float:
	return float(data["audio"].get(key, default_value))

func set_audio_value(key: String, value: float) -> void:
	data["audio"][key] = clampf(value, 0.0, 100.0)
	save_data()

func set_high_score(score: int) -> void:
	if(score > int(data["progress"]["high_score"])):
		data["progress"]["high_score"] = score
		save_data()

func get_high_score() -> int:
	return int(data["progress"]["high_score"])

func set_action_key(action_name: String, keycode: Key) -> void:
	if(!data["controls"].has(action_name)):
		data["controls"][action_name] = keycode
	else:
		data["controls"][action_name] = keycode
	apply_action_binding(action_name, keycode)
	save_data()

func apply_controls() -> void:
	for action_name in data["controls"].keys():
		apply_action_binding(action_name, int(data["controls"][action_name]))

func apply_action_binding(action_name: String, keycode: Key) -> void:
	if(!InputMap.has_action(action_name)):
		InputMap.add_action(action_name)
	for ev in InputMap.action_get_events(action_name):
		if(ev is InputEventKey):
			InputMap.action_erase_event(action_name, ev)
	var input_event := InputEventKey.new()
	input_event.physical_keycode = keycode
	InputMap.action_add_event(action_name, input_event)
