extends Control

@onready var Content: Control = $Content
@onready var FadeRect: ColorRect = $FadeRect

var StoryPages: Array[PackedScene] = [
	preload("res://scenes/story_page_1.tscn"),
	preload("res://scenes/story_page_2.tscn"),
	preload("res://scenes/story_page_3.tscn"),
	preload("res://scenes/story_page_4.tscn")
]

func _ready() -> void:
	FadeRect.color.a = 1.0
	await fade_to(0.0)
	for page_scene in StoryPages:
		var page := page_scene.instantiate()
		Content.add_child(page)
		await page.page_finished
		await fade_to(1.0)
		page.queue_free()
		await get_tree().process_frame
		await fade_to(0.0)
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func fade_to(alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(FadeRect, "color:a", alpha, 0.35)
	await tween.finished
