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
var IsMeasureSequenceRunning: bool = false
const MEASURE_FLIP_DURATION: float = 0.35
const MEASURE_REVEAL_DELAY: float = 0.25

var PauseButton: Button
var PausePanel: PanelContainer
var PauseMainView: VBoxContainer
var PauseSettingsView: VBoxContainer
var PauseConfirmView: VBoxContainer
var PauseVolumeSlider: HSlider
var PauseVolumeLabel: Label
var IsPausePanelOpen: bool = false

const PAUSE_PANEL_HIDDEN_Y: float = -360.0
const PAUSE_PANEL_SHOWN_Y: float = 48.0
const PAUSE_PANEL_TWEEN_DURATION: float = 0.2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerHand.add_card(CardSpell1Scene.instantiate())
	play_sfx_draw_card()
	QuanticPlayerHand.add_card(Card1Scene.instantiate())
	play_sfx_draw_card()
	QuanticPlayerHand.add_card(Card2Scene.instantiate())
	play_sfx_draw_card()
	PlayerTokenArea = QuanticPlayerBoard.get_token_area()
	PlayerBoard.set_quantic_only(false)
	visualize_elements(PHASE)
	set_world(WORLD)
	$GameOverLayer.visible = false
	setup_pause_menu_ui()
	pass # Replace with function body.
func visualize_elements(phase:String):
	if(IsMeasureSequenceRunning):
		hide_all_buttons()
		PlayerHand.CanInteract = false
		QuanticPlayerHand.CanInteract = false
		return
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

func lock_all_player_input():
	IsMeasureSequenceRunning = true
	CurrentCard = null
	CurrentSlot = null
	hide_all_buttons()
	PlayerHand.CanInteract = false
	QuanticPlayerHand.CanInteract = false

func unlock_all_player_input():
	IsMeasureSequenceRunning = false

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
func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action_pressed("ui_cancel") && !IsGameOver):
		toggle_pause_panel()

func _process(delta: float):
	if(CurrentCard):
		var mouse = get_global_mouse_position()
		CurrentCard.set_position(Vector2(mouse.x - QuanticPlayerHand.HandRadius + CurrentCard.get_current_size()[0]/2,(mouse.y - QuanticPlayerHand.HandRadius*2 + CurrentCard.get_current_size()[1])))
	
		
func _on_button_pressed():
	if(IsMeasureSequenceRunning):
		return
	var CardSceneArray = [CardSpell1Scene,CardSpell2Scene]
	var card1 = CardSceneArray[randi_range(0,CardSceneArray.size()-1)].instantiate()
	PlayerHand.add_card(card1)
	play_sfx_draw_card()
	PHASE = "USUAL_PLAY"
	visualize_elements(PHASE)
	
func _on_button_2_pressed():
	if(IsMeasureSequenceRunning):
		return
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
	if(IsMeasureSequenceRunning):
		return
	PHASE = "QUANTIC_PLAY"
	var GateSceneArray = [Card1Scene,Card2Scene
	#,CardControlledXGateScene,
	#CardSwapGateScene
	]
	var card2 = GateSceneArray[randi_range(0,1)].instantiate()
	#Card2Scene.instantiate()
	QuanticPlayerHand.add_card(card2)
	play_sfx_draw_card()
	visualize_elements(PHASE)
	
func _on_button_4_pressed():
	if(IsMeasureSequenceRunning):
		return
	PHASE = "QUANTIC_RESOLVE"
	QuanticPlayerBoard.resolve_all_rows()
	visualize_elements(PHASE)
	
func _on_button_5_pressed():
	if(IsMeasureSequenceRunning):
		return
	PHASE = "QUANTIC_MEASURE"
	lock_all_player_input()
	await measure_result_tokens_with_flip()
	get_card_accuracy()
	#PlayerTokenArea.randomize_tokens()

func measure_result_tokens_with_flip() -> void:
	var result_area = QuanticPlayerBoard.get_result_area()
	var flip_tweens: Array[Tween] = []
	for i in QuanticPlayerBoard.get_result().size():
		var token = result_area.get_token_from_index(i)
		if(token && token.get_value() == "?"):
			var measured_value = "0"
			if(randi_range(0,1)==1):
				measured_value = "1"
			var flip_tween = token.play_flip_to_value(measured_value, MEASURE_FLIP_DURATION)
			if(flip_tween):
				flip_tweens.push_back(flip_tween)
	play_sfx_token_flip()
	for tween in flip_tweens:
		await tween.finished
	if(flip_tweens.size() > 0):
		await get_tree().create_timer(MEASURE_REVEAL_DELAY).timeout
	
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
		play_sfx_spell()
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
	play_sfx_enemy_hit()
func set_token_area():
	for i in 3:
		var token = TokenScene.instantiate()
		PlayerTokenArea.add_token(token)
		#PlayerTokenArea.randomize_tokens()
		
func _on_hand_release_card():
	if(IsMeasureSequenceRunning):
		return
	if(CurrentCard):
		if(CurrentSlot && !CurrentSlot.only_spells && CurrentSlot.CardInside==null && PHASE=="QUANTIC_PLAY"):
			CurrentCard.unhighlight()
			CurrentSlot.set_card_inside(CurrentCard)
			QuanticPlayerHand.remove_the_card(CurrentCard)
			play_sfx_drop_card()
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
	play_sfx_pick_card()
	if(IsMeasureSequenceRunning):
		return
	CurrentCard = card
	HandCardTweenPos = pos
	
func _on_hand_card_exited_slot(card: Card, card_slot: CardSlot):
	if(CurrentCard == card):
		CurrentSlot = null
		
func _on_hand_card_entered_slot(card: Card,card_slot:CardSlot):
	if(CurrentCard == card):
		CurrentSlot = card_slot

func _on_board_click_slot(slot: CardSlot):
	if(IsMeasureSequenceRunning):
		return
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
	if(IsMeasureSequenceRunning):
		return
	if(PlayerBoard.can_insert_card()):
		play_sfx_drop_card()
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
	play_sfx_explosion()
	resolve_enemy_attack()
	pass # Replace with function body.

func _on_battle_manager_player_healed(heal_amount: int):
	play_sfx_heal()
	show_combat_text("Curación aplicada: +" + str(heal_amount), Color(0.65, 1.0, 0.65, 1.0))

func _on_battle_manager_enemy_attacked():
	play_sfx_player_damage()
	unlock_all_player_input()
	PHASE = "USUAL_DRAW"
	PlayerBoard.clear_cards()
	show_combat_text("El enemigo ataca", Color(1, 0.75, 0.75, 1))
	visualize_elements(PHASE)
	pass # Replace with function body.

func _on_battle_manager_enemy_defeated():
	play_sfx_splat()
	unlock_all_player_input()
	PHASE = "USUAL_DRAW"
	PlayerBoard.clear_cards()
	show_combat_text("¡Enemigo derrotado!", Color(1, 0.95, 0.55, 1))
	visualize_elements(PHASE)
	pass # Replace with function body.

func _on_battle_manager_player_defeated(final_score: int):
	play_sfx_splat()
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
	unlock_all_player_input()
	get_tree().reload_current_scene()

func play_sfx_draw_card() -> void:
	$SFX/Draw.play()
	pass

func play_sfx_heal() -> void:
	$SFX/Heal.play()
	pass

func play_sfx_spell() -> void:
	$SFX/Spell.play()
	pass

func play_sfx_player_damage() -> void:
	$SFX/Damage.play()
	pass

func play_sfx_explosion():
	$SFX/Explosion.play()
	
func play_sfx_enemy_hit():
	$SFX/Enemy_Hit.play()
	
func play_sfx_pick_card():
	$SFX/Pick_Card.play()

func play_sfx_drop_card():
	$SFX/Drop_Card.play()

func play_sfx_token_flip():
	$SFX/Token_Flip.play()

func play_sfx_splat():
	$SFX/Splat.play()


func setup_pause_menu_ui() -> void:
	var pause_layer := CanvasLayer.new()
	pause_layer.layer = 20
	pause_layer.name = "PauseMenuLayer"
	pause_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(pause_layer)

	PauseButton = Button.new()
	PauseButton.text = "⚙"
	PauseButton.custom_minimum_size = Vector2(44, 44)
	PauseButton.position = Vector2(16, 12)
	PauseButton.process_mode = Node.PROCESS_MODE_ALWAYS
	PauseButton.pressed.connect(_on_pause_button_pressed)
	pause_layer.add_child(PauseButton)

	PausePanel = PanelContainer.new()
	PausePanel.custom_minimum_size = Vector2(320, 300)
	PausePanel.position = Vector2(16, PAUSE_PANEL_HIDDEN_Y)
	PausePanel.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_layer.add_child(PausePanel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	PausePanel.add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	margin.add_child(root)

	var title := Label.new()
	title.text = "Pausa"
	root.add_child(title)

	PauseMainView = VBoxContainer.new()
	PauseMainView.add_theme_constant_override("separation", 6)
	root.add_child(PauseMainView)

	var resume_button := Button.new()
	resume_button.text = "Reanudar"
	resume_button.pressed.connect(_on_resume_button_pressed)
	PauseMainView.add_child(resume_button)

	var settings_button := Button.new()
	settings_button.text = "Ajustes"
	settings_button.pressed.connect(_on_settings_button_pressed)
	PauseMainView.add_child(settings_button)

	var menu_button := Button.new()
	menu_button.text = "Salir al menú principal"
	menu_button.pressed.connect(_on_main_menu_button_pressed)
	PauseMainView.add_child(menu_button)

	PauseSettingsView = VBoxContainer.new()
	PauseSettingsView.visible = false
	PauseSettingsView.add_theme_constant_override("separation", 6)
	root.add_child(PauseSettingsView)

	var settings_title := Label.new()
	settings_title.text = "Ajustes"
	PauseSettingsView.add_child(settings_title)

	PauseVolumeLabel = Label.new()
	PauseSettingsView.add_child(PauseVolumeLabel)

	PauseVolumeSlider = HSlider.new()
	PauseVolumeSlider.min_value = 0
	PauseVolumeSlider.max_value = 100
	PauseVolumeSlider.step = 1
	PauseVolumeSlider.value_changed.connect(_on_volume_slider_changed)
	PauseSettingsView.add_child(PauseVolumeSlider)

	var back_button := Button.new()
	back_button.text = "Atrás"
	back_button.pressed.connect(_on_settings_back_button_pressed)
	PauseSettingsView.add_child(back_button)

	PauseConfirmView = VBoxContainer.new()
	PauseConfirmView.visible = false
	PauseConfirmView.add_theme_constant_override("separation", 6)
	root.add_child(PauseConfirmView)

	var confirm_label := Label.new()
	confirm_label.text = "¿Seguro que quieres salir al menú?"
	PauseConfirmView.add_child(confirm_label)

	var confirm_yes := Button.new()
	confirm_yes.text = "Sí, salir"
	confirm_yes.pressed.connect(_on_confirm_exit_yes_pressed)
	PauseConfirmView.add_child(confirm_yes)

	var confirm_no := Button.new()
	confirm_no.text = "No, volver"
	confirm_no.pressed.connect(_on_confirm_exit_no_pressed)
	PauseConfirmView.add_child(confirm_no)

	PauseVolumeSlider.value = AudioSettings.master_volume_percent
	update_volume_label()

func show_pause_view(view_name: String) -> void:
	PauseMainView.visible = view_name == "main"
	PauseSettingsView.visible = view_name == "settings"
	PauseConfirmView.visible = view_name == "confirm"

func toggle_pause_panel() -> void:
	if(IsPausePanelOpen):
		close_pause_panel()
	else:
		open_pause_panel()

func open_pause_panel() -> void:
	if(IsGameOver):
		return
	IsPausePanelOpen = true
	get_tree().paused = true
	show_pause_view("main")
	animate_pause_panel(PAUSE_PANEL_SHOWN_Y)

func close_pause_panel() -> void:
	IsPausePanelOpen = false
	get_tree().paused = false
	show_pause_view("main")
	animate_pause_panel(PAUSE_PANEL_HIDDEN_Y)

func animate_pause_panel(target_y: float) -> void:
	if(!PausePanel):
		return
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(PausePanel, "position:y", target_y, PAUSE_PANEL_TWEEN_DURATION)

func update_volume_label() -> void:
	if(!PauseVolumeLabel):
		return
	PauseVolumeLabel.text = AudioSettings.get_volume_icon() + " Volumen: " + str(int(round(AudioSettings.master_volume_percent))) + "%"

func _on_pause_button_pressed() -> void:
	toggle_pause_panel()

func _on_resume_button_pressed() -> void:
	close_pause_panel()

func _on_settings_button_pressed() -> void:
	show_pause_view("settings")

func _on_main_menu_button_pressed() -> void:
	show_pause_view("confirm")

func _on_settings_back_button_pressed() -> void:
	show_pause_view("main")

func _on_confirm_exit_yes_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_confirm_exit_no_pressed() -> void:
	show_pause_view("main")

func _on_volume_slider_changed(value: float) -> void:
	AudioSettings.set_master_volume_percent(value)
	update_volume_label()
