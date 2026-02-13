@tool
extends Card
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	pass # Replace with function body.
	
func _process(delta: float) -> void:
	pass
	
func highlight():
	$Card.highlight()
	
func unhighlight():
	$Card.unhighlight()

func get_card_name():
	return $Card.CardName
	
func get_current_size():
	return($Card.get_current_size())

func set_animation_pos(pos:Vector2):
	$Card.set_animation_pos(pos)
	
func _on_card_mouse_entered(_card: Card):
	mouse_entered.emit(self)
	
func _on_card_mouse_exited(_card: Card):
	mouse_exited.emit(self)
	
func _on_card_animation_ended():
	animation_ended.emit()
	
func get_can_be_interacted():
	return $Card.CanBeInteracted
	
func set_can_be_interacted(val: bool):
	$Card.CanBeInteracted = val

func _on_card_card_entered_slot(card: Card,card_slot: CardSlot):
	card_entered_slot.emit(self,card_slot)

func _on_card_card_exited_slot(card: Card, card_slot: CardSlot):
	card_exited_slot.emit(self,card_slot)
