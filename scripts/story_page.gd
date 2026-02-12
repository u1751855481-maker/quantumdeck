extends Control

signal page_finished

@export var StoryText: String = ""
@export var TypingSpeed: float = 0.03
@export var HoldDuration: float = 4.0

@onready var TextLabel: Label = $MarginContainer/VBox/TextLabel

var IsTyping: bool = false
var TextCompleted: bool = false
var SkipTypingRequested: bool = false
var ContinueRequested: bool = false

func _ready() -> void:
	TextLabel.text = ""
	await type_text()
	TextCompleted = true
	await wait_for_continue_or_timeout()
	page_finished.emit()

func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action_pressed("left_mouse") || event.is_action_pressed("ui_accept")):
		if(IsTyping):
			SkipTypingRequested = true
		elif(TextCompleted):
			ContinueRequested = true

func type_text() -> void:
	IsTyping = true
	SkipTypingRequested = false
	for i in StoryText.length():
		if(SkipTypingRequested):
			TextLabel.text = StoryText
			break
		TextLabel.text += StoryText.substr(i, 1)
		# $TypeSfx.play() # Sonido por letra (pendiente de asset/mezcla final)
		await get_tree().create_timer(TypingSpeed).timeout
	IsTyping = false

func wait_for_continue_or_timeout() -> void:
	ContinueRequested = false
	var elapsed := 0.0
	while(elapsed < HoldDuration):
		if(ContinueRequested):
			return
		var step
		step = min(0.1, HoldDuration - elapsed)
		await get_tree().create_timer(step).timeout
		elapsed += step
