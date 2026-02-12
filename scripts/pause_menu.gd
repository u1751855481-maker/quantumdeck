extends Control

signal requested_close
signal requested_open_settings
signal requested_back
signal pause_opened
signal pause_closed
signal exit_to_menu_requested

@onready var ToggleButton: Button = $PauseToggleButton
@onready var PausePanel: PanelContainer = $PausePanel
@onready var MainView: VBoxContainer = $PausePanel/Margin/Root/MainView
@onready var SettingsView: VBoxContainer = $PausePanel/Margin/Root/SettingsView
@onready var ConfirmView: VBoxContainer = $PausePanel/Margin/Root/ConfirmView
@onready var VolumeLabel: Label = $PausePanel/Margin/Root/SettingsView/VolumeLabel
@onready var VolumeSlider: HSlider = $PausePanel/Margin/Root/SettingsView/VolumeSlider
@onready var PausedLabel: Label = $PausedLabel

const PANEL_HIDDEN_Y: float = -360.0
const PANEL_VISIBLE_Y: float = 48.0
const PANEL_TWEEN_DURATION: float = 0.2

var IsOpen: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	ToggleButton.process_mode = Node.PROCESS_MODE_ALWAYS
	PausePanel.process_mode = Node.PROCESS_MODE_ALWAYS
	PausePanel.position.y = PANEL_HIDDEN_Y
	VolumeSlider.value = AudioSettings.master_volume_percent
	PausedLabel.visible = false
	update_volume_label()

func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action_pressed("ui_cancel")):
		toggle()

func toggle() -> void:
	if(IsOpen):
		close_pause()
	else:
		open_pause()

func open_pause() -> void:
	if(IsOpen || !GameState.can_pause()):
		return
	IsOpen = true
	get_tree().paused = true
	GameState.set_state(GameState.State.PAUSED)
	show_view("main")
	animate_panel(PANEL_VISIBLE_Y)
	PausedLabel.visible = true
	pause_opened.emit()

func close_pause() -> void:
	if(!IsOpen):
		return
	IsOpen = false
	get_tree().paused = false
	if(!GameState.is_game_over()):
		GameState.set_state(GameState.State.PLAYING)
	show_view("main")
	animate_panel(PANEL_HIDDEN_Y)
	PausedLabel.visible = false
	pause_closed.emit()

func set_pause_enabled(enabled: bool) -> void:
	ToggleButton.visible = enabled
	if(!enabled):
		close_pause()

func show_view(view_name: String) -> void:
	MainView.visible = view_name == "main"
	SettingsView.visible = view_name == "settings"
	ConfirmView.visible = view_name == "confirm"

func animate_panel(target_y: float) -> void:
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(PausePanel, "position:y", target_y, PANEL_TWEEN_DURATION)

func update_volume_label() -> void:
	VolumeLabel.text = AudioSettings.get_volume_icon() + " Volumen: " + str(int(round(AudioSettings.master_volume_percent))) + "%"

func _on_pause_toggle_button_pressed() -> void:
	toggle()

func _on_resume_button_pressed() -> void:
	close_pause()

func _on_settings_button_pressed() -> void:
	show_view("settings")
	requested_open_settings.emit()

func _on_settings_back_button_pressed() -> void:
	show_view("main")
	requested_back.emit()

func _on_main_menu_button_pressed() -> void:
	show_view("confirm")

func _on_confirm_no_button_pressed() -> void:
	show_view("main")

func _on_confirm_yes_button_pressed() -> void:
	close_pause()
	exit_to_menu_requested.emit()

func _on_volume_slider_value_changed(value: float) -> void:
	AudioSettings.set_master_volume_percent(value)
	update_volume_label()
