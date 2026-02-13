extends Control
@export var SpawnInterval: float = 0.2
@export var ParticleLifetime: float = 3.0
@export var MaxParticles: int = 45
@export var ParticleSize: float = 4.0

var ParticleTextures: Array[Texture2D] = [
	preload("res://Assets/particle1.png"),
	preload("res://Assets/particle2.png"),
	preload("res://Assets/particle3.png"),
	preload("res://Assets/particle4.png")
]

var Running: bool = true

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	call_deferred("spawn_loop")

func spawn_loop() -> void:
	while(Running):
		if(get_child_count() < MaxParticles):
			spawn_particle()
		await get_tree().create_timer(SpawnInterval).timeout

func spawn_particle() -> void:
	if(ParticleTextures.is_empty()):
		return
	var p := TextureRect.new()
	p.texture = ParticleTextures[randi_range(0, ParticleTextures.size() - 1)]
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	p.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var particle_size := randf_range(20.0, 64.0) * ParticleSize
	p.custom_minimum_size = Vector2(particle_size, particle_size)
	var viewport_size := get_viewport_rect().size
	p.position = Vector2(randf_range(0.0, max(0.0, viewport_size.x - particle_size)), randf_range(0.0, max(0.0, viewport_size.y - particle_size)))
	p.modulate = Color(1, 1, 1, randf_range(0.45, 0.9))
	add_child(p)
	var target := p.position + Vector2(randf_range(-80, 80), randf_range(-120, 120))
	var tween := create_tween()
	tween.parallel().tween_property(p, "position", target, ParticleLifetime)
	tween.parallel().tween_property(p, "modulate:a", 0.0, ParticleLifetime)
	tween.finished.connect(func():
		if(is_instance_valid(p)):
			p.queue_free()
	)

func _exit_tree() -> void:
	Running = false
