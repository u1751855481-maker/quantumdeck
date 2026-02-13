class_name Board extends Node2D
signal click_slot(slot:CardSlot)
@onready var TokenAreaScene: PackedScene = preload("res://scenes/token_area.tscn")
@onready var TokenScene: PackedScene = preload("res://scenes/token.tscn")
@onready var ResultAreaScene: PackedScene = preload("res://scenes/result_area.tscn")
@onready var CardSlotsRowScene: PackedScene = preload("res://scenes/card_slots_row.tscn")
@onready var CardResolverScene: PackedScene = preload("res://scenes/card_resolver.tscn")
@onready var QuanticServerScene: PackedScene = preload("res://quantic_server/quantic_server.tscn")
@onready var CardResolverAux: CardResolver = CardResolverScene.instantiate()
@onready var ResultAreaAux: ResultArea = ResultAreaScene.instantiate()
@onready var TokenAreaAux: TokenArea = TokenAreaScene.instantiate()
var QuanticServerAux: QuanticServer
var server_available: bool = false

var CardSlotsRowNum = 3
var CardSlotsRowArray: Array = []
# Called when the node enters the scene tree for the first time.

func _ready():
	QuanticServerAux = QuanticServerScene.instantiate()
	add_child(QuanticServerAux)
	QuanticServerAux.wakeup_completed.connect(_on_server_wakeup_completed)
	QuanticServerAux.wake_up_server()
	add_child(TokenAreaAux)
	add_child(ResultAreaAux)

	for i in CardSlotsRowNum:
		var card_slots_row = CardSlotsRowScene.instantiate()
		card_slots_row.click_slot.connect(handle_click_slot_row)
		card_slots_row.position = TokenAreaAux.get_token_position(i) + Vector2(250,0)
		CardSlotsRowArray.push_back(card_slots_row)
		add_child(card_slots_row)
	ResultAreaAux.position = TokenAreaAux.position + Vector2(250*(CardSlotsRowArray[0].get_slot_num()+1),0)
func handle_click_slot_row(slot:CardSlot):
	click_slot.emit(slot)
	
func get_token_area():
	return TokenAreaAux

func get_result_area() -> ResultArea:
	return ResultAreaAux
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_server_wakeup_completed(available: bool) -> void:
	server_available = available
	if server_available:
		print("[Board] Servidor cuántico disponible tras wake-up.")
	else:
		print("[Board] Wake-up fallido. Se usará fallback local.")
	
func resolve_row(index:int):
	if(TokenAreaAux.get_token_from_index(index)):
		var token_value = TokenAreaAux.get_token_from_index(index).get_value()
		if(token_value):
			var card_slots_row = CardSlotsRowArray[index]
			for slot in card_slots_row.get_slots():
				if(slot.get_card_inside()):
					if(slot.get_card_inside().get_card_name()=="ControlledX"):
						CardResolverAux.resolve_controlled_x(token_value,slot.get_card_inside(),card_slots_row.get_slots())
					else:
						token_value = CardResolverAux.resolve(token_value,slot.get_card_inside())
			return token_value
			
func resolve_all_rows_dependencies():
	for i in CardSlotsRowNum:
		resolve_row_dependencies_controledX(i)
	for i in CardSlotsRowNum:
		resolve_row_dependencies_swap_gate(i)
		
func resolve_row_dependencies_controledX(index:int):
	if(TokenAreaAux.get_token_from_index(index)):
		var token_value = TokenAreaAux.get_token_from_index(index).get_value()
		var card_slots_row = CardSlotsRowArray[index]
		for slot in card_slots_row.get_slots():
			if(slot.get_card_inside()):
				if(slot.get_card_inside().get_card_name()=="ControlledX"):
					CardResolverAux.resolve_controlled_x(token_value,slot.get_card_inside(),card_slots_row.get_slots())
func resolve_row_dependencies_swap_gate(index:int):
	if(TokenAreaAux.get_token_from_index(index)):
		var token_value = TokenAreaAux.get_token_from_index(index).get_value()
		var card_slots_row = CardSlotsRowArray[index]
		for slot in card_slots_row.get_slots():
			if(slot.get_card_inside()):
				if(slot.get_card_inside().get_card_name()=="Swap gate"):
					CardResolverAux.resolve_swap_gate(token_value,slot.get_card_inside(),card_slots_row.get_slots())
func resolve_all_rows():
	resolve_all_rows_dependencies()
	var result_row
	for i in CardSlotsRowNum:
		result_row = resolve_row(i)
		var token = TokenScene.instantiate()
		if(result_row):
			token.change_value(result_row)
			ResultAreaAux.add_token(token)
func clear_all_results():
	ResultAreaAux.clear_tokens()
func clear_all_gates():
	for card_row in CardSlotsRowArray:
		card_row.clear_all_cards()
func highlight_target_rows(slot:CardSlot):
	for slots_row in CardSlotsRowArray:
		var slot_array = slots_row.get_slots()
		if(!slot_array.has(slot)):
			slots_row.highlight_free_slots()
			
func unhighlight_all_slots():
	for slots_row in CardSlotsRowArray:
		slots_row.unhighlight_all_slots()
		
func set_quantic_only(val:bool):
	for slot_row in CardSlotsRowArray:
		var slots = slot_row.get_slots()
		for slot in slots:
			slot.set_only_spells(val)
			
func measure_all_results():
	for i in CardSlotsRowNum:
		var token = ResultAreaAux.get_token_from_index(i)
		#QuanticServerAux.aplicar_hadamard()
		if(token.get_value()=="?"):
			if(randi_range(0,1)==1):
				token.change_value("1")
			else:
				token.change_value("0")
func get_result():
	var res: Array = []
	for i in CardSlotsRowNum:
		var token = ResultAreaAux.get_token_from_index(i)
		res.push_back(token.get_value())
	return res

func measure_unknown_token(index: int) -> String:
	if !server_available:
		print("[Board] Medición local por wake-up fallido (fila %d)." % index)
		return _random_measurement()
	if index < 0 or index >= CardSlotsRowArray.size():
		return _random_measurement()
	var operations = _build_operations_for_row(index)
	QuanticServerAux.request_measurement(operations, "?")
	var response = await QuanticServerAux.measurement_completed
	var success: bool = response[0]
	var measured_value: String = response[1]
	if !success:
		print("[Board] Medición remota fallida, fallback local (fila %d)." % index)
		return _random_measurement()
	return measured_value

func _build_operations_for_row(index: int) -> Array:
	var operations: Array = []
	var row = CardSlotsRowArray[index]
	for slot in row.get_slots():
		var card = slot.get_card_inside()
		if card == null:
			continue
		var gate_name: String = _map_card_to_gate(card.get_card_name())
		if gate_name == "":
			continue
		operations.push_back({
			"gate": gate_name,
			"targets": [0]
		})
	return operations

func _map_card_to_gate(card_name: String) -> String:
	if card_name == "H Gate":
		return "h"
	if card_name == "X Gate":
		return "x"
	if card_name == "ControlledX":
		return "cx"
	if card_name == "Swap gate":
		return "swap"
	return ""

func _random_measurement() -> String:
	if randi_range(0, 1) == 1:
		return "1"
	return "0"
