extends Control

@onready var Content: Control = $Content
@onready var FadeRect: ColorRect = $FadeRect

var SkipRequested: bool = false

var StoryPages: Array[PackedScene] = [
	preload("res://scenes/story_page_1.tscn"),
	preload("res://scenes/story_page_2.tscn"),
	preload("res://scenes/story_page_3.tscn"),
	preload("res://scenes/story_page_4.tscn"),
	preload("res://scenes/story_page_5.tscn"),
	preload("res://scenes/story_page_end.tscn")
]

func _ready() -> void:
	set_process_input(true)
	FadeRect.color.a = 1.0
	await fade_to(0.0)
	if(SkipRequested):
		return
	for page_index in StoryPages.size():
		if(SkipRequested):
			return
		if(page_index == 1):
			AudioSettings.play_menu_music()
		var page_scene = StoryPages[page_index]
		var page := page_scene.instantiate()
		Content.add_child(page)
		await page.page_finished
		if(SkipRequested):
			return
		await fade_to(1.0)
		page.queue_free()
		await get_tree().process_frame
		await fade_to(0.0)
	AudioSettings.stop_music()
	await get_tree().create_timer(AudioSettings.MUSIC_FADE_SECONDS).timeout
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _input(event: InputEvent) -> void:
	if(SkipRequested):
		return
	if(
		event.is_action_pressed("left_mouse")
		|| event.is_action_pressed("ui_accept")
		|| event.is_action_pressed("ui_cancel")
	):
		SkipRequested = true
		AudioSettings.stop_music(false)
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func fade_to(alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(FadeRect, "color:a", alpha, 0.35)
	await tween.finished
