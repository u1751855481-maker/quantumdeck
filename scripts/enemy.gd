class_name Enemy extends Node2D

signal Defeated
signal enemy_attacked
var Attacks = [2,8]

@export var level = 1
@export var MaxHealth:int = 100
@export var Health:int = 100
@export var BaseRotationSpeed: float = 1.8

@onready var EnemySprite: AnimatedSprite2D = $AnimatedSprite2D

var IsDying: bool = false
var FlashMaterial: ShaderMaterial

func _ready() -> void:
	setup_white_flash_material()
	EnemySprite.modulate.a = 1.0
	$Healthbar.modulate.a = 1.0
	if(has_node("BASE")):
		$BASE.modulate.a = 1.0
	EnemySprite.play("idle")

func setup_white_flash_material() -> void:
	var flash_shader := load("res://shaders/white_flash.gdshader") as Shader
	if(flash_shader == null):
		return
	FlashMaterial = ShaderMaterial.new()
	FlashMaterial.shader = flash_shader
	EnemySprite.material = FlashMaterial

func play_attack_anim():
	play_attack_shake()
	EnemySprite.play("attack")

func play_attack_shake() -> void:
	var start_pos := position
	var tween := create_tween()
	tween.tween_property(self, "position", start_pos + Vector2(-20, 0), 0.06)
	tween.tween_property(self, "position", start_pos, 0.08)

func damage(dmg:int):
	if(IsDying):
		return
	Health = Health - dmg
	play_hit_flash()
	if(Health <= 0):
		Health = 0
		EnemySprite.play("ded")
	else:
		EnemySprite.play("hurt")

func play_hit_flash() -> void:
	if(FlashMaterial == null):
		return
	FlashMaterial.set_shader_parameter("flash_strength", 1.0)
	var tween := create_tween()
	tween.tween_method(_set_flash_strength, 1.0, 0.0, 0.12)

func _set_flash_strength(value: float) -> void:
	if(FlashMaterial):
		FlashMaterial.set_shader_parameter("flash_strength", value)

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
	EnemySprite.play("ded")

func _on_particles_animation_finished() -> void:
	$Particles.visible = false

func _on_animated_sprite_2d_animation_finished():
	if(EnemySprite.animation == "ded"):
		if(IsDying):
			return
		IsDying = true
		await play_death_feedback()
		EnemySprite.pause()
		Defeated.emit()
	if(EnemySprite.animation == "hurt"):
		EnemySprite.play("idle")
	if(EnemySprite.animation == "attack"):
		enemy_attacked.emit()
		EnemySprite.play("idle")

func play_death_feedback() -> void:
	var start_pos := position
	var shake := create_tween()
	shake.tween_property(self, "position", start_pos + Vector2(-16, 0), 0.05)
	shake.tween_property(self, "position", start_pos + Vector2(16, 0), 0.05)
	shake.tween_property(self, "position", start_pos + Vector2(-10, 0), 0.04)
	shake.tween_property(self, "position", start_pos, 0.05)
	await shake.finished
	var fade := create_tween()
	fade.parallel().tween_property(EnemySprite, "modulate:a", 0.0, 0.3)
	fade.parallel().tween_property($Healthbar, "modulate:a", 0.0, 0.3)
	if(has_node("BASE")):
		fade.parallel().tween_property($BASE, "modulate:a", 0.0, 0.3)
	await fade.finished

func set_level(lvl:int):
	level = lvl
