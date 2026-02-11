extends Node2D
@onready var Card1Scene: PackedScene = preload("res://scenes/cards/card_xgate.tscn")
@onready var Card2Scene: PackedScene = preload("res://scenes/cards/card_hgate.tscn") 
@onready var CardSwapGateScene: PackedScene = preload("res://scenes/cards/card_swap_gate.tscn")
@onready var CardControlledXGateScene: PackedScene = preload("res://scenes/cards/card_controlled_x_gate.tscn")
@onready var TokenScene: PackedScene = preload("res://scenes/token.tscn")
@onready var CardControlledXTargetScene: PackedScene = preload("res://scenes/cards/card_controlled_x_target.tscn")
@onready var QuanticPlayerHand: Hand = $CanvasLayer/Quantic_World/Hand
@onready var PlayerTokenArea: TokenArea 
@onready var QuanticPlayerBoard: Board = $CanvasLayer/Quantic_World/Board
@onready var HandCardTweenPos: Vector2
@onready var CardSpell1Scene: PackedScene = preload("res://scenes/cards/card_spell_fire_1.tscn")
@onready var PlayerHand: Hand = $CanvasLayer/World/Hand_Spells
@onready var PlayerBoard: BoardSpells = $CanvasLayer/World/Board_Spells
@onready var BattleManagerAux: BattleManager = $Battle_Manager
@onready var CardSpell2Scene: PackedScene = preload("res://scenes/cards/card_spell_heal.tscn")
var OutputCard: Card
var CurrentCard: Card
var CurrentSlot: CardSlot
var PHASE : String = "USUAL_DRAW"
var WORLD: String = "USUAL"
var SetTokenArea:int = 1
var IsGameOver: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerHand.add_card(CardSpell1Scene.instantiate())
	QuanticPlayerHand.add_card(Card1Scene.instantiate())
	QuanticPlayerHand.add_card(Card2Scene.instantiate())
	PlayerTokenArea = QuanticPlayerBoard.get_token_area()
	PlayerBoard.set_quantic_only(false)
	visualize_elements(PHASE)
	set_world(WORLD)
	$GameOverLayer.visible = false
	pass # Replace with function body.
func visualize_elements(phase:String):
	if(PHASE=="USUAL_DRAW"):
		hide_all_buttons()
		$Button.visible = true
		PlayerHand.CanInteract = false
		$Button.set_process(true)
	if(PHASE=="USUAL_PLAY"):
		PlayerHand.CanInteract = true
		hide_all_buttons()
	if(PHASE=="QUANTIC_DRAW"):
		QuanticPlayerHand.CanInteract = false
		hide_all_buttons()
		$Button3.visible = true
		$Button3.set_process(true)
	if(PHASE=="QUANTIC_PLAY"):
		QuanticPlayerHand.CanInteract = true
		hide_all_buttons()
		$Button4.visible = true
		$Button4.set_process(true)
	if(PHASE=="QUANTIC_RESOLVE"):
		hide_all_buttons()
		$Button5.visible = true
		$Button5.set_process(true)
	if(PHASE == "QUANTIC_MEASURE"):
		hide_all_buttons()
		$Button2.visible = true
		$Button2.set_process(true)
	pass
func hide_all_buttons():
		$Button.visible = false
		$Button.set_process(false)
		$Button2.visible = false
		$Button2.set_process(false)
		$Button3.visible = false
		$Button3.set_process(false)
		$Button4.visible = false
		$Button4.set_process(false)
		$Button5.visible = false
		$Button5.set_process(false)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	if(CurrentCard):
		var mouse = get_global_mouse_position()
		CurrentCard.set_position(Vector2(mouse.x - QuanticPlayerHand.HandRadius + CurrentCard.get_current_size()[0]/2,(mouse.y - QuanticPlayerHand.HandRadius*2 + CurrentCard.get_current_size()[1])))
	
		
func _on_button_pressed():
	var CardSceneArray = [CardSpell1Scene,CardSpell2Scene]
	var card1 = CardSceneArray[randi_range(0,CardSceneArray.size()-1)].instantiate()
	PlayerHand.add_card(card1)
	PHASE = "USUAL_PLAY"
	visualize_elements(PHASE)
	
func _on_button_2_pressed():
	PHASE = "QUANTIC_DRAW"
	if(SetTokenArea==1):
		set_token_area()
		SetTokenArea = 2
	else:
		PlayerTokenArea.randomize_tokens()
	WORLD = "QUANTIC"
	QuanticPlayerBoard.clear_all_results()
	QuanticPlayerBoard.clear_all_gates()
	set_world(WORLD)
	visualize_elements(PHASE)
	
func _on_button_3_pressed():
	PHASE = "QUANTIC_PLAY"
	var GateSceneArray = [Card1Scene,Card2Scene
	#,CardControlledXGateScene,
	#CardSwapGateScene
	]
	var card2 = GateSceneArray[randi_range(0,1)].instantiate()
	#Card2Scene.instantiate()
	QuanticPlayerHand.add_card(card2)
	visualize_elements(PHASE)
	
func _on_button_4_pressed():
	PHASE = "QUANTIC_RESOLVE"
	QuanticPlayerBoard.resolve_all_rows()
	visualize_elements(PHASE)
	
func _on_button_5_pressed():
	PHASE = "QUANTIC_MEASURE"
	QuanticPlayerBoard.measure_all_results()
	get_card_accuracy()
	#PlayerTokenArea.randomize_tokens()

func get_card_accuracy():
	var damage = 0
	var heal = 0
	for slot in PlayerBoard.get_card_slots():
		if(slot.get_card_inside()):
			var card = slot.get_card_inside()
			var card_power = get_card_power(card)
			if(card.is_heal_spell()):
				heal = heal + card_power
			else:
				damage = damage + card_power
	WORLD = "USUAL"
	set_world(WORLD)
	if(heal > 0):
		show_combat_text("Heal +" + str(heal), Color(0.65, 1.0, 0.65, 1.0))
		BattleManagerAux.resolve_player_heal(heal)
	if(damage > 0):
		show_combat_text("Ataque -" + str(damage), Color(1, 0.55, 0.45, 1))
		BattleManagerAux.resolve_player_attack(damage)
	elif(heal > 0):
		resolve_enemy_attack()

func get_card_power(card: CardSpell) -> int:
	var accuracy = 1
	var card_target: String = str(card.get_target_qubits())
	var board_result: Array = QuanticPlayerBoard.get_result()
	var compare_length = mini(board_result.size(), card_target.length())
	for i in compare_length:
		if(str(board_result[i]) == card_target.substr(i, 1)):
			accuracy = accuracy + 1
	var base_power = card.get_base_power()
	if(accuracy == 2):
		return int(base_power * 0.25)
	if(accuracy == 3):
		return int(base_power * 0.5)
	if(accuracy >= 4):
		return int(base_power)
	return 1

func show_combat_text(text:String, color:Color = Color(1,1,1,1)):
	$CombatLog.text = text
	$CombatLog.modulate = color
func resolve_enemy_attack():
	BattleManagerAux.resolve_enemy_attack()
func set_token_area():
	for i in 3:
		var token = TokenScene.instantiate()
		PlayerTokenArea.add_token(token)
		#PlayerTokenArea.randomize_tokens()
		
func _on_hand_release_card():
	if(CurrentCard):
		if(CurrentSlot && !CurrentSlot.only_spells && CurrentSlot.CardInside==null && PHASE=="QUANTIC_PLAY"):
			CurrentCard.unhighlight()
			CurrentSlot.set_card_inside(CurrentCard)
			QuanticPlayerHand.remove_the_card(CurrentCard)
			if(CurrentCard.get_card_name() == "ControlledX"):
				PHASE = "CUANTIC_INSERT_OUTPUT"
				OutputCard = CardControlledXTargetScene.instantiate()
				highlight_target_rows(CurrentSlot)
				CurrentCard.set_target(OutputCard)
			if(CurrentCard.get_card_name() == "Swap gate"):
				PHASE = "CUANTIC_INSERT_OUTPUT"
				OutputCard = CardSwapGateScene.instantiate()
				highlight_target_rows(CurrentSlot)
				CurrentCard.set_target(OutputCard)
				OutputCard.set_target(CurrentCard)
			CurrentSlot = null
		else:
			CurrentCard.set_animation_pos(HandCardTweenPos)
	CurrentCard = null

func _on_hand_click_card(card: Card,pos: Vector2):
	CurrentCard = card
	HandCardTweenPos = pos
	
func _on_hand_card_exited_slot(card: Card, card_slot: CardSlot):
	if(CurrentCard == card):
		CurrentSlot = null
		
func _on_hand_card_entered_slot(card: Card,card_slot:CardSlot):
	if(CurrentCard == card):
		CurrentSlot = card_slot

func _on_board_click_slot(slot: CardSlot):
	if(PHASE=="CUANTIC_INSERT_OUTPUT"):
		if(slot.get_highlighted()):
			slot.set_card_inside(OutputCard)
			OutputCard = null
			PHASE = "CUANTIC_PLAY"
			QuanticPlayerBoard.unhighlight_all_slots()
func highlight_target_rows(slot: CardSlot):
	QuanticPlayerBoard.highlight_target_rows(slot)
	
func set_world(WORLD):
	var is_usual_world = WORLD == "USUAL"
	$CanvasLayer/Quantic_World.visible = !is_usual_world
	$CanvasLayer/Quantic_World.set_process(!is_usual_world)
	$CanvasLayer/World/Hand_Spells.visible = is_usual_world
	$CanvasLayer/World/Hand_Spells.set_process(is_usual_world)
	$Battle_Manager/Player.visible = is_usual_world
	$Battle_Manager/Enemy.visible = is_usual_world



func _on_hand_spells_click_card(card: Card,pos:Vector2):
	if(PlayerBoard.can_insert_card()):
		PlayerBoard.insert_card(PlayerHand.remove_the_card(card))
		card.unhighlight()
		PHASE = "QUANTIC_DRAW"
	if(SetTokenArea==1):
		set_token_area()
		SetTokenArea = 2
	else:
		PlayerTokenArea.randomize_tokens()
	WORLD = "QUANTIC"
	QuanticPlayerBoard.clear_all_results()
	QuanticPlayerBoard.clear_all_gates()
	set_world(WORLD)
	visualize_elements(PHASE)


func _on_battle_manager_player_attacked():
	resolve_enemy_attack()
	pass # Replace with function body.

func _on_battle_manager_player_healed(heal_amount: int):
	show_combat_text("Curación aplicada: +" + str(heal_amount), Color(0.65, 1.0, 0.65, 1.0))

func _on_battle_manager_enemy_attacked():
	PHASE = "USUAL_DRAW"
	PlayerBoard.clear_cards()
	show_combat_text("El enemigo ataca", Color(1, 0.75, 0.75, 1))
	visualize_elements(PHASE)
	pass # Replace with function body.

func _on_battle_manager_enemy_defeated():
	PHASE = "USUAL_DRAW"
	PlayerBoard.clear_cards()
	show_combat_text("¡Enemigo derrotado!", Color(1, 0.95, 0.55, 1))
	visualize_elements(PHASE)
	pass # Replace with function body.

func _on_battle_manager_player_defeated(final_score: int):
	if(IsGameOver):
		return
	IsGameOver = true
	show_combat_text("Derrota", Color(1, 0.5, 0.5, 1))
	$GameOverLayer/Panel/FinalScore.text = "Score: " + str(final_score)
	$GameOverLayer.visible = true
	PlayerHand.CanInteract = false
	QuanticPlayerHand.CanInteract = false
	hide_all_buttons()

func _on_restart_button_pressed():
	get_tree().reload_current_scene()
