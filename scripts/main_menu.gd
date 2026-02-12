extends Control

@export var GameplayDesignNames: PackedStringArray = ["Integrante Gameplay"]
@export var QiskitServerNames: PackedStringArray = ["Integrante Qiskit"]
@export var MenuDesignNames: PackedStringArray = ["Integrante Menús"]
@export var CodeDevelopmentNames: PackedStringArray = ["Integrante Código"]

@onready var CreditsPanel: PanelContainer = $CreditsPanel
@onready var GameplayNamesLabel: Label = $CreditsPanel/MarginContainer/CreditsVBox/GameplaySection/Names
@onready var QiskitNamesLabel: Label = $CreditsPanel/MarginContainer/CreditsVBox/QiskitSection/Names
@onready var MenuNamesLabel: Label = $CreditsPanel/MarginContainer/CreditsVBox/MenuSection/Names
@onready var CodeNamesLabel: Label = $CreditsPanel/MarginContainer/CreditsVBox/CodeSection/Names

func _ready() -> void:
	CreditsPanel.visible = false
	update_credits_labels()

func update_credits_labels() -> void:
	GameplayNamesLabel.text = "\n".join(GameplayDesignNames)
	QiskitNamesLabel.text = "\n".join(QiskitServerNames)
	MenuNamesLabel.text = "\n".join(MenuDesignNames)
	CodeNamesLabel.text = "\n".join(CodeDevelopmentNames)

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/deck_hand.tscn")

func _on_credits_button_pressed() -> void:
	CreditsPanel.visible = true

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
