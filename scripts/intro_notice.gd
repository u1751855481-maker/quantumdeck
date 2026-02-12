extends Control

@export var NoticeText: String = "AVISO: Este juego contiene efectos visuales y sonidos."
@export var NoticeDuration: float = 2.5
@onready var NoticeLabel: Label = $CenterContainer/NoticeLabel

func _ready() -> void:
	NoticeLabel.text = NoticeText
	await get_tree().create_timer(NoticeDuration).timeout
	get_tree().change_scene_to_file("res://scenes/story_sequence.tscn")
