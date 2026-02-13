class_name Player extends Node2D

signal GameOver
signal player_attacked
@export var MaxHealth:int = 100
@export var Health:int = 100

@onready var PlayerSprite: AnimatedSprite2D = $AnimatedSprite2D

var FlashMaterial: ShaderMaterial

func _ready() -> void:
	#setup_white_flash_material()
	PlayerSprite.play("idle")

#func setup_white_flash_material() -> void:
	#var flash_shader := load("res://shaders/white_flash.gdshader") as Shader
	#if(flash_shader == null):
	#	return
	#FlashMaterial = ShaderMaterial.new()
	#FlashMaterial.shader = flash_shader
	#PlayerSprite.material = FlashMaterial

func play_attack_anim():
	PlayerSprite.play("attack")

func heal(heal:int):
	play_particle_heal()
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
	play_hit_flash()
	if(Health<0):
		PlayerSprite.play("ded")
	else:
		PlayerSprite.play("hurt")

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
	pass

func _on_animated_sprite_2d_animation_finished():
	if(PlayerSprite.animation == "ded"):
		PlayerSprite.pause()
		GameOver.emit()
	if(PlayerSprite.animation == "hurt"):
		PlayerSprite.play("idle")
	if(PlayerSprite.animation == "attack"):
		PlayerSprite.play("idle")
		player_attacked.emit()
	pass

func play_particle_heal():
	$Particles.visible = true
	$Particles.play("heal")

func _on_particles_animation_finished() -> void:
	$Particles.visible = false
	pass # Replace with function body.
