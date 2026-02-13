class_name ResultArea extends Node2D

@onready var CollisionShape: CollisionShape2D = $CollisionShape2D
var TokenArray: Array = []
# Called when the node enters the scene tree for the first time.
func add_token(token:Node2D):
	TokenArray.push_back(token)
	add_child(token)
	reposition_tokens()
func get_token_position(index:int):
	var x = (CollisionShape.shape as RectangleShape2D).size[0]/2 + CollisionShape.get_position().x
	var y = (CollisionShape.shape as RectangleShape2D).size[1]/4 * index + 150
	return Vector2(int(x),int(y))
func clear_tokens():
	for token in TokenArray:
		remove_child(token)
	TokenArray = []
func reposition_tokens():
	for token in TokenArray:
		token.set_position(get_token_position(TokenArray.find(token)))
func _ready() -> void:
	pass # Replace with function body.
	
func get_token_from_index(index:int):
	if(TokenArray.size()>index):
		return TokenArray[index]
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
