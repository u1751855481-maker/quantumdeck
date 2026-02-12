class_name BoardSpells extends Node2D

@onready var SlotScene: PackedScene = preload("res://scenes/card_slot.tscn")

var MaxNumCards: int = 4
var CardSlotsArray: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in MaxNumCards:
		var slot :CardSlot = SlotScene.instantiate()
		CardSlotsArray.push_back(slot)
		slot.position = Vector2(1800,150*i+250)
		add_child(slot)
	pass # Replace with function body.
func get_current_card_number():
	var num_cards = 0
	for card_slot in CardSlotsArray:
		if(card_slot.get_card_inside()):
			num_cards = num_cards + 1
	return num_cards
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_card_slots():
	return CardSlotsArray
	
func insert_card(card:Card):
	if (get_current_card_number() < MaxNumCards):
		CardSlotsArray[get_current_card_number()].set_card_inside(card)

func can_insert_card():
	if(get_current_card_number()>=MaxNumCards):
		return  false
	else: 
		return true
		
func set_quantic_only(val:bool):
	for slot in CardSlotsArray:
		slot.set_only_spells(val)
		
func clear_cards():
	for slot in CardSlotsArray:
		slot.remove_card_inside()
