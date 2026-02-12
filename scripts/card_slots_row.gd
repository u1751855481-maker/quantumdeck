class_name CardSlotsRow extends Node2D

signal click_slot(slot:CardSlot)

@onready var SlotScene: PackedScene = preload("res://scenes/card_slot.tscn")

@export var SlotNum: int = 4

var Slots: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in SlotNum:
		var slot = SlotScene.instantiate()
		slot.position = Vector2(250*i,0)
		Slots.push_back(slot)
		insert_slot(slot)
		add_child(slot)
	pass # Replace with function body.

func insert_slot(slot:CardSlot):
	slot.click_slot.connect(handle_click_slot)
	
func handle_click_slot(slot:CardSlot):
	click_slot.emit(slot)
	
func get_slots():
	return Slots
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	pass
func highlight_free_slots():
	for slot in Slots:
		if(!slot.get_card_inside()):
			slot.highlight()
func unhighlight_all_slots():
	for slot in Slots:
		slot.unhighlight()
		
func get_slot_num():
	return SlotNum
	
func set_slot_num(slot_num:int):
	SlotNum = slot_num
func clear_all_cards():
	for slot in Slots:
		slot.remove_card_inside()
