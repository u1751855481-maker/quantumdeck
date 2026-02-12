class_name CardSlot extends Node2D
signal click_slot(slot:CardSlot)
var CardInside : Card
var selected = false
var highlighted = false
var only_spells = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	pass

func _input(event):
	if(selected && event.is_action_pressed("left_mouse")):
		click_slot.emit(self)	
func set_card_inside(card: Card):
	if(CardInside):
		remove_child(CardInside)
	if(card.get_parent()):
		card.get_parent().remove_child(card)
	add_child(card)
	CardInside = card
	CardInside.global_position = global_position
func remove_card_inside():
	remove_child(CardInside)
	CardInside = null
func get_card_inside():
	return CardInside
func _on_card_slot_area_mouse_exited():
	selected = false
	
func _on_card_slot_area_mouse_entered():
	selected = true
func get_only_spells():
	return only_spells
func set_only_spells(value:bool):
	only_spells = value
	$Card_Slot_Area/Sprite2D.visible = false
func unhighlight():
	$Card_Slot_Area/CollisionShape2D.debug_color = Color(1.0, 0.941, 0.843, 1.0)
	highlighted = false
func highlight():
	$Card_Slot_Area/CollisionShape2D.debug_color = Color(1.0, 1.0, 1.0, 1.0)
	highlighted = true

func get_highlighted():
	return highlighted
