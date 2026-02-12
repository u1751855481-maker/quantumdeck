extends Control

signal requested_close
signal requested_reload_scene
signal requested_give_spell
signal requested_force_enemy_attack
signal requested_force_defeat

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action_pressed("debug_toggle")):
		visible = !visible

func _on_close_button_pressed() -> void:
	visible = false
	requested_close.emit()

func _on_reload_button_pressed() -> void:
	requested_reload_scene.emit()

func _on_give_spell_button_pressed() -> void:
	requested_give_spell.emit()

func _on_enemy_attack_button_pressed() -> void:
	requested_force_enemy_attack.emit()

func _on_defeat_button_pressed() -> void:
	requested_force_defeat.emit()
