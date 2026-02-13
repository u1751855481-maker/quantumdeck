class_name BattleManager extends Node2D

signal player_attacked
signal enemy_attacked
signal enemy_defeated
signal player_healed(heal_amount: int)
signal player_defeated(final_score: int)
@onready var EnemyScene: PackedScene = preload("res://scenes/enemy.tscn")
@onready var PlayerAux:Player = $Player
@onready var EnemyAux:Enemy = $Enemy
@onready var ScoreAux:Score = $Score

var e_lvl = 1
var p_dmg
var e_dmg
var p_heal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func resolve_player_attack(dmg:int):
	p_dmg = dmg
	PlayerAux.play_attack_anim()

func resolve_player_heal(heal_amount:int):
	p_heal = heal_amount
	PlayerAux.heal(heal_amount)
	PlayerAux.play_heal_feedback()
	player_healed.emit(heal_amount)
	
func resolve_enemy_attack():
	if(EnemyAux.Health>0):
		e_dmg = EnemyAux.get_random_attack()
		EnemyAux.play_attack_anim()
	else:
		EnemyAux.play_ded_anim()
	
func _on_player_player_attacked():
	EnemyAux.damage(p_dmg)
	EnemyAux.play_particle_fire()
	player_attacked.emit()
	pass # Replace with function body.

func _on_enemy_enemy_attacked() -> void:
	PlayerAux.damage(e_dmg)
	if(PlayerAux.Health <= 0):
		player_defeated.emit(ScoreAux.score)
		return
	enemy_attacked.emit()
	pass
func _on_enemy_defeated():
	ScoreAux.plus_score()
	var pos = EnemyAux.position
	remove_child(EnemyAux)
	EnemyAux = EnemyScene.instantiate()
	e_lvl = e_lvl + 1
	EnemyAux.set_level(e_lvl)
	add_child(EnemyAux)
	EnemyAux.position = pos
	EnemyAux.connect("Defeated",_on_enemy_defeated)
	EnemyAux.connect("enemy_attacked",_on_enemy_enemy_attacked)
	enemy_defeated.emit()
	pass # Replace with function body.
