extends Node2D

@export var TokenValue = "1"
@onready var TokenValueLabel = $Token_value/Token_value

# Called when the node enters the scene tree for the first time.
func _ready():
	hide_all_sprites()
	if(TokenValue=="1"):
		$Base_1.visible = true
	elif(TokenValue=="0"):
		$Base_2.visible = true
	else:
		$Base_a.visible = true
	pass # Replace with function body.
	
func change_value(value:String):
	if(value=="1"|| value =="0" ||value=="?"):
		TokenValue = value
		
func randomize_value():
	var randomizer = RandomNumberGenerator.new()
	var random_num = randomizer.randf_range(0,3)
	if(random_num<1):
		TokenValue = "0"
	elif(random_num<2):
		TokenValue = "1"
	else:
		TokenValue = "?"
		
func update_graphics():
	if(TokenValueLabel.get_text()!=TokenValue):
		hide_all_sprites()
		if(TokenValue=="1"):
			$Base_1.visible = true
		elif(TokenValue=="0"):
			$Base_2.visible = true
		else:
			$Base_a.visible = true
		TokenValueLabel.set_text(TokenValue)
		
func hide_all_sprites():
	$Base_1.visible = false
	$Base_2.visible = false
	$Base_a.visible = false
func get_value():
	return TokenValue
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	update_graphics()
	pass


func play_flip_to_value(new_value:String, duration: float = 0.35) -> void:
	if(new_value != "0" && new_value != "1" && new_value != "?"):
		return
	var flip_tween = get_tree().create_tween()
	flip_tween.tween_property(self, "scale:x", 0.0, duration * 0.5)
	flip_tween.tween_callback(func():
		change_value(new_value)
		update_graphics()
	)
	flip_tween.tween_property(self, "scale:x", 1.0, duration * 0.5)
	await flip_tween.finished
