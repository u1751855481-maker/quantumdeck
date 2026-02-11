@tool
class_name CardSpell extends Card

@onready var CardTargetValueLabel: Label = $Target_value_text

@export var TargetQubits: String
@export_enum("damage", "heal") var SpellType: String = "damage"

var MaxDamage

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func update_graphics():
	$Card.set_values(CardName,CardDescription)
	$Card.update_graphics()
	if(CardTargetValueLabel.get_text()!=TargetQubits):
		CardTargetValueLabel.set_text(TargetQubits)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_graphics()
	pass
	
func highlight():
	$Target_value.set_modulate(Color(0.81, 0.956, 1.0, 1.0))
	$Card.highlight()
func unhighlight():
	$Target_value.set_modulate(Color(1.0, 1.0, 1.0, 1.0))
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
func get_max_damage():
	return MaxDamage
func get_target_qubits():
	return TargetQubits

func get_spell_type():
	return SpellType

func is_heal_spell() -> bool:
	return SpellType == "heal"
