extends Control

signal page_finished

@export var StoryText: String = ""
@export var TypingSpeed: float = 0.03
@export var HoldDuration: float = 4.0

@onready var TextLabel: Label = $MarginContainer/VBox/TextLabel

func _ready() -> void:
	TextLabel.text = ""
	await type_text()
	await get_tree().create_timer(HoldDuration).timeout
	page_finished.emit()

func type_text() -> void:
	for i in StoryText.length():
		TextLabel.text += StoryText.substr(i, 1)
		# $TypeSfx.play() # Sonido por letra (pendiente de asset/mezcla final)
		await get_tree().create_timer(TypingSpeed).timeout
