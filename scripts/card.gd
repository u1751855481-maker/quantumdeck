@tool
class_name Card extends Node2D

signal mouse_entered(card:Card)
signal mouse_exited(card:Card)
signal animation_ended()
signal card_entered_slot(card: Card,card_slot: CardSlot)
signal card_exited_slot(card:Card,card_slot: CardSlot)

@export var CardName: String = "Card name"
@export var CardDescription: String = "Card description"
@export var CardImage: Node2D

@export var CanBeInteracted: bool = true

@onready var CardNameLabel: Label = $Card_name/Card_name
@onready var CardDescriptionLabel: Label = $Card_description/Card_description

@onready var CardBase: Sprite2D = $Base

@onready var CardNameBanner: Sprite2D = $Base_name

@onready var CardFrame: Sprite2D = $Base_frame

#@onready var CardTween: Tween = create_tween()
func _ready():
	set_values(CardName,CardDescription)
	
func set_values(_name:String,_description:String):
	CardName = _name
	CardDescription = _description
	update_graphics()
func update_graphics():
	if(CardNameLabel.get_text()!=CardName):
		CardNameLabel.set_text(CardName)
	if(CardDescriptionLabel.get_text()!=CardDescription):
		CardDescriptionLabel.set_text(CardDescription)
		
func _process(delta):
	update_graphics()
	pass
	
func highlight():
	CardBase.set_modulate(Color(0.81, 0.956, 1.0, 1.0))
	CardNameBanner.set_modulate(Color(0.81, 0.956, 1.0, 1.0))
	CardFrame.set_modulate(Color(0.81, 0.956, 1.0, 1.0))
	
func unhighlight():
	CardBase.set_modulate(Color(1,1,1,1))
	CardNameBanner.set_modulate(Color(1, 1, 1, 1))
	CardFrame.set_modulate(Color(1, 1, 1, 1))
	
func _on_area_2d_mouse_entered():
	mouse_entered.emit(self)
	
func _on_area_2d_mouse_exited():
	mouse_exited.emit(self)
	
func get_current_size():
	return CardBase.get_rect().size
	
func set_animation_pos(pos:Vector2):
	var card_tween = get_tree().create_tween()
	CanBeInteracted = false
	var original_pos = get_position()
	var poss = -(global_position - pos)
	card_tween.tween_property(self,"position",poss,1)
	card_tween.tween_callback(reset_pos.bind(original_pos))
	
func reset_pos(pos: Vector2):
	position = pos
	animation_ended.emit()
	CanBeInteracted = true
	
func _on_card_area_area_entered(card_slot_area: CardSlotArea):
	card_entered_slot.emit(self,card_slot_area.get_parent())
	
func _on_card_area_area_exited(card_slot_area: CardSlotArea):
	card_exited_slot.emit(self,card_slot_area.get_parent())
