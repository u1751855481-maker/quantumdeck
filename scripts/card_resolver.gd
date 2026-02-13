class_name CardResolver extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func resolve(token_value:String,card:Card):
	var token_result: String
	if(card.get_card_name() == "X Gate"):
		if(token_value == "1"):
			token_result = "0"
		elif(token_value == "0"):
			token_result = "1"
		elif(token_value == "?"):
			token_result = "?"
	if(card.get_card_name() == "H Gate"):
		token_result = "?"		
	if(card.get_card_name() == "Target X"):
		for card_transformation in card.get_card_transformations():
			token_value = resolve(token_value,card_transformation)
		token_result = token_value
	if(card.get_card_name()== "Swap gate"):
		token_result = card.get_output_value()
	return token_result
func resolve_controlled_x(token_value:String,controlled_x_card:Card,slot_array:Array):
	var card_array : Array = []
	for slot in slot_array:
		if(slot.get_card_inside()):
			card_array.push_back(slot.get_card_inside())	
	var controlled_x_card_array: Array = []
	if(card_array.size()>0):
		for card in card_array:
			if(card!=controlled_x_card):
				controlled_x_card_array.push_back(card)
			else:
				controlled_x_card.get_target().set_card_transformations(controlled_x_card_array)
				break
func resolve_swap_gate(token_value:String,swap_gate_card:SwapGate,slot_array:Array):
	var card_array: Array = []
	var output_value: String
	output_value = token_value
	for slot in slot_array:
		if(slot.get_card_inside()):
			card_array.push_back(slot.get_card_inside())
	if(card_array.size()>0):
		for card in card_array:
			if(card!=swap_gate_card):
				if(card.get_card_name()!="ControlledX"):
					output_value = resolve(output_value,card)
			else:
				swap_gate_card.get_target().set_output_value(output_value)
				break
