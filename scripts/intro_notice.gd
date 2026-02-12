extends Control

@export var NoticeText: String = "AVISO: Este juego contiene efectos visuales y sonidos."
@export var NoticeDuration: float = 2.5
@onready var NoticeLabel: Label = $CenterContainer/NoticeLabel
var SkipRequested: bool = false

func _ready() -> void:
	NoticeLabel.text = NoticeText
	set_process_input(true)
	await get_tree().create_timer(NoticeDuration).timeout
	if(SkipRequested):
		return
	get_tree().change_scene_to_file("res://scenes/story_sequence.tscn")

func _input(event: InputEvent) -> void:
	if(SkipRequested):
		return
	if(event.is_action_pressed("left_mouse") || event.is_action_pressed("ui_accept") || event.is_action_pressed("ui_cancel")):
		SkipRequested = true
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
