extends Control

@export var GameplayDesignNames: PackedStringArray = ["Nicolás González Rodríguez"]
@export var QiskitServerNames: PackedStringArray = ["José Manuel Pérez Suárez"]
@export var MenuDesignNames: PackedStringArray = ["Jack Alexander Cubas Gutiérrez"]
@export var CodeDevelopmentNames: PackedStringArray = ["Nicolás González Rodríguez","José Manuel Pérez Suárez"]

@onready var CreditsPanel: PanelContainer = $CreditsPanel
@onready var GameplayNamesLabel: Label = $CreditsPanel/MarginContainer/CreditsVBox/GameplaySection/Names
@onready var QiskitNamesLabel: Label = $CreditsPanel/MarginContainer/CreditsVBox/QiskitSection/Names
@onready var MenuNamesLabel: Label = $CreditsPanel/MarginContainer/CreditsVBox/MenuSection/Names
@onready var CodeNamesLabel: Label = $CreditsPanel/MarginContainer/CreditsVBox/CodeSection/Names

func _ready() -> void:
	GameState.set_state(GameState.State.MENU)
	CreditsPanel.visible = false
	update_credits_labels()

func update_credits_labels() -> void:
	GameplayNamesLabel.text = "\n".join(GameplayDesignNames)
	QiskitNamesLabel.text = "\n".join(QiskitServerNames)
	MenuNamesLabel.text = "\n".join(MenuDesignNames)
	CodeNamesLabel.text = "\n".join(CodeDevelopmentNames)

func _on_start_button_pressed() -> void:
	GameState.set_state(GameState.State.PLAYING)
	get_tree().change_scene_to_file("res://scenes/deck_hand.tscn")

func _on_credits_button_pressed() -> void:
	CreditsPanel.visible = true

func _on_history_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/story_sequence.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_back_button_pressed() -> void:
	CreditsPanel.visible = false


func _on_start_button_mouse_entered() -> void:
	$SFX/Hover.play()
	pass # Replace with function body.

func _on_credits_button_mouse_entered() -> void:
	$SFX/Hover.play()
	pass # Replace with function body.

func _on_exit_button_mouse_entered() -> void:
	$SFX/Hover.play()
	pass # Replace with function body.


func _on_back_button_mouse_entered() -> void:
	$SFX/Hover.play()
	pass # Replace with function body.


func _on_history_button_mouse_entered() -> void:
	$SFX/Hover.play()
