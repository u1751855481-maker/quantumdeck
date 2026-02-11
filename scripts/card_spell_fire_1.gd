@tool
extends CardSpell

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Card_Spell.MaxDamage = 50
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Card_Spell.update_graphics()
	pass
	
func highlight():
	$Card_Spell.highlight()
func unhighlight():
	$Card_Spell.unhighlight()
func get_card_name():
	return $Card_Spell.CardName
func get_current_size():
	return($Card_Spell.get_current_size())
func get_max_damage():
	return $Card_Spell.get_max_damage()
func set_animation_pos(pos:Vector2):
	$Card_Spell.set_animation_pos(pos)
	
func _on_card_spell_mouse_entered(_card: Card):
	mouse_entered.emit(self)
	
func _on_card_spell_mouse_exited(_card: Card):
	mouse_exited.emit(self)
	
func _on_card_spell_animation_ended():
	animation_ended.emit()
	
func get_can_be_interacted():
	return $Card_Spell.get_can_be_interacted()
	
func set_can_be_interacted(val: bool):
	$Card_Spell.CanBeInteracted = val

func _on_card_spell_card_entered_slot(card: Card,card_slot: CardSlot):
	card_entered_slot.emit(self,card_slot)

func _on_card_spell_card_exited_slot(card: Card, card_slot: CardSlot):
	card_exited_slot.emit(self,card_slot)
