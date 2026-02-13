class_name Score extends Node2D

@onready var LabelAux:Label = $LabelScore

@export var score = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$LabelScore.text = "0"
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func plus_score():
	score = score + 1
	$LabelScore.set_text(str(score))
