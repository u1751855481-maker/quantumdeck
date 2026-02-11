class_name Player extends Node2D

signal GameOver
signal player_attacked
@export var MaxHealth:int = 100
@export var Health:int = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("idle")
	pass # Replace with function body.
	
func play_attack_anim():
	$AnimatedSprite2D.play("attack")

func heal(heal:int):
	if(Health + heal>MaxHealth):
		Health = MaxHealth
	else:
		Health = Health + heal

func play_heal_feedback():
	modulate = Color(0.65, 1.0, 0.65, 1.0)
	var heal_tween = get_tree().create_tween()
	heal_tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.25)
func damage(p_dmg:int):
	Health = Health - p_dmg
	if(Health<0):
		$AnimatedSprite2D.play("ded")
	else:
		$AnimatedSprite2D.play("hurt")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Healthbar.value = Health
	pass
	
func _on_animated_sprite_2d_animation_finished():
	if($AnimatedSprite2D.animation == "ded"):
		$AnimatedSprite2D.pause()
		GameOver.emit()
	if($AnimatedSprite2D.animation == "hurt"):
		$AnimatedSprite2D.play("idle")
	if($AnimatedSprite2D.animation == "attack"):
		$AnimatedSprite2D.play("idle")
		player_attacked.emit()
	pass # Replace with function body.
