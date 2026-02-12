class_name Enemy extends Node2D

signal Defeated
signal enemy_attacked
var Attacks = [2,8]

@export var level = 1
@export var MaxHealth:int = 100
@export var Health:int = 1
@export var BaseRotationSpeed: float = 1.8

var IsDying: bool = false

func _ready() -> void:
	$AnimatedSprite2D.modulate.a = 1.0
	$Healthbar.modulate.a = 1.0
	if(has_node("BASE")):
		$BASE.modulate.a = 1.0
	$AnimatedSprite2D.play("idle")

func play_attack_anim():
	play_attack_shake()
	$AnimatedSprite2D.play("attack")

func play_attack_shake() -> void:
	var start_pos := position
	var tween := create_tween()
	tween.tween_property(self, "position", start_pos + Vector2(-20, 0), 0.06)
	tween.tween_property(self, "position", start_pos, 0.08)

func damage(dmg:int):
	if(IsDying):
		return
	Health = Health - dmg
	if(Health <= 0):
		Health = 0
		$AnimatedSprite2D.play("ded")
	else:
		$AnimatedSprite2D.play("hurt")

func _process(delta: float) -> void:
	$Healthbar.value = Health
	if(has_node("BASE")):
		$BASE.rotation += BaseRotationSpeed * delta

func get_random_attack():
	return Attacks.pick_random() * level

func play_particle_fire():
	$Particles.visible = true
	$Particles.play("fire")

func play_ded_anim():
	if(IsDying):
		return
	$AnimatedSprite2D.play("ded")

func _on_particles_animation_finished() -> void:
	$Particles.visible = false

func _on_animated_sprite_2d_animation_finished():
	if($AnimatedSprite2D.animation == "ded"):
		if(IsDying):
			return
		IsDying = true
		await play_death_feedback()
		$AnimatedSprite2D.pause()
		Defeated.emit()
	if($AnimatedSprite2D.animation == "hurt"):
		$AnimatedSprite2D.play("idle")
	if($AnimatedSprite2D.animation == "attack"):
		enemy_attacked.emit()
		$AnimatedSprite2D.play("idle")

func play_death_feedback() -> void:
	var start_pos := position
	var shake := create_tween()
	shake.tween_property(self, "position", start_pos + Vector2(-16, 0), 0.05)
	shake.tween_property(self, "position", start_pos + Vector2(16, 0), 0.05)
	shake.tween_property(self, "position", start_pos + Vector2(-10, 0), 0.04)
	shake.tween_property(self, "position", start_pos, 0.05)
	await shake.finished
	var fade := create_tween()
	fade.parallel().tween_property($AnimatedSprite2D, "modulate:a", 0.0, 0.3)
	fade.parallel().tween_property($Healthbar, "modulate:a", 0.0, 0.3)
	if(has_node("BASE")):
		fade.parallel().tween_property($BASE, "modulate:a", 0.0, 0.3)
	await fade.finished

func set_level(lvl:int):
	level = lvl
