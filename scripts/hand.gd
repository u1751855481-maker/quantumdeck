@tool
class_name Hand extends Node2D

signal click_card(card:Card)
signal release_card()

signal card_entered_slot(card:Card,card_slot:CardSlot)
signal card_exited_slot(card:Card,card_slot:CardSlot)

@export var HandRadius: int = 1000
@export var AngleLimit: float = 25
@export var MaxCardSpread: float = 5
@onready var CollisionShape: CollisionShape2D = $CollisionShape2D

var HandCards: Array = []
var Highlighted: Array = []
var HighlightIndex: int = -1
var CurrentSelectedCard: int = -1
var CanInteract: bool = true

func add_card(card:Node2D):
	HandCards.push_back(card)
	add_child(card)
	card.mouse_entered.connect(handle_card_entered)
	card.mouse_exited.connect(handle_card_exited)
	card.animation_ended.connect(reposition_cards)
	card.card_entered_slot.connect(handle_card_entered_slot)
	card.card_exited_slot.connect(handle_card_exited_slot)
	reposition_cards()
	
func remove_card(index:int)-> Node2D:
	var card = HandCards[index]
	HandCards.remove_at(index)
	remove_child(card)
	Highlighted.remove_at(Highlighted.find(card))
	reposition_cards()
	CurrentSelectedCard = -1
	return card
func remove_the_card(card:Card)-> Card:
	HandCards.erase(card)
	#remove_child(card)
	Highlighted.erase(card)
	reposition_cards()
	CurrentSelectedCard = -1
	return card
func reposition_cards():
	var CardSpread = min(AngleLimit/HandCards.size(), MaxCardSpread)
	var StartAngle = -(CardSpread * (HandCards.size()-1))/2-90
	for card in HandCards:
		card_transform_update(card,StartAngle)
		StartAngle += CardSpread
		
func get_card_position(angle:float):
	var x: float = HandRadius * cos(deg_to_rad(angle))
	var y: float = HandRadius * sin(deg_to_rad(angle))
	return Vector2(int(x),int(y))
	
# Called when the node enters the scene tree for the first time.
func card_transform_update(card:Node2D,angle:float):
	card.set_position(get_card_position(angle))
	#card.set_rotation(deg_to_rad(angle+90))
func handle_card_entered(card:Card):
	Highlighted.push_back(card)
func handle_card_entered_slot(card:Card,card_slot:CardSlot):
	card_entered_slot.emit(card,card_slot)
func handle_card_exited_slot(card:Card,card_slot:CardSlot):
	card_exited_slot.emit(card,card_slot)
func handle_card_exited(card:Card):
	Highlighted.remove_at(Highlighted.find(card))

func _ready() -> void:
	pass # Replace with function body.
	
func _input(event):
	if(CanInteract):
		if(event.is_action_pressed("left_mouse") && CurrentSelectedCard>=0 && HandCards[CurrentSelectedCard].get_can_be_interacted()):
			var card = HandCards.get(CurrentSelectedCard)
			click_card.emit(card,card.global_position)
		elif(event.is_action_released("left_mouse")):
			release_card.emit()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for card in HandCards:
		CurrentSelectedCard = -1
		card.unhighlight()
		card.set_z_index(1)
		
	if(!Highlighted.is_empty()):
		var highest_highlighted_index: int = -1
		for card in Highlighted:
			var highlighted_index = HandCards.find(card)
			if(highlighted_index>highest_highlighted_index):
				highest_highlighted_index = highlighted_index
		if(highest_highlighted_index>=0 && highest_highlighted_index<HandCards.size()):
			if(CanInteract):
				HandCards[highest_highlighted_index].highlight()
			CurrentSelectedCard = highest_highlighted_index
			HandCards[highest_highlighted_index].set_z_index(2)
	if(HighlightIndex>=0 && HighlightIndex<HandCards.size()):
		HandCards[HighlightIndex].highlight()
		
	if ((CollisionShape.shape as CircleShape2D).radius != HandRadius):
		(CollisionShape.shape as CircleShape2D).set_radius(HandRadius)
	pass
