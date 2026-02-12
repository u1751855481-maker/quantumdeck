class_name Enemy extends Node2D

signal Defeated
signal enemy_attacked
var Attacks = [2,8]

@export var level = 1
@export var MaxHealth:int = 100
@export var Health:int = 1	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("idle")
	pass # Replace with function body.
	
func play_attack_anim():
	$AnimatedSprite2D.play("attack")
	
func damage(dmg:int):
	Health = Health - dmg
	if(Health<0): 
		$AnimatedSprite2D.play("ded")
	else:
		$AnimatedSprite2D.play("hurt")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Healthbar.value = Health
	pass
	
func get_random_attack():
	return Attacks.pick_random() * level
	
func play_particle_fire():
	$Particles.visible = true
	$Particles.play("fire")
	
func play_ded_anim():
	$AnimatedSprite2D.play("ded")
	
func _on_particles_animation_finished() -> void:
	$Particles.visible = false

func _on_animated_sprite_2d_animation_finished():
	if($AnimatedSprite2D.animation == "ded"):
		$AnimatedSprite2D.pause()
		Defeated.emit()
	if($AnimatedSprite2D.animation == "hurt"):
		$AnimatedSprite2D.play("idle")
	if($AnimatedSprite2D.animation == "attack"):
		enemy_attacked.emit()
		$AnimatedSprite2D.play("idle")
	pass # Replace with function body.
	
func set_level(lvl:int):
	level = lvl
	
