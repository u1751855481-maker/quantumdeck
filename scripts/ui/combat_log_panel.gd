extends Control

signal requested_close

@onready var TextOutput: RichTextLabel = $Panel/Margin/VBox/Scroll/Output

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	CombatLog.entry_added.connect(_on_combat_log_entry_added)
	CombatLog.entries_cleared.connect(_on_combat_log_entries_cleared)
	rebuild_log()

func rebuild_log() -> void:
	TextOutput.text = ""
	for entry in CombatLog.get_entries():
		TextOutput.text += entry + "\n"
	TextOutput.scroll_to_line(max(TextOutput.get_line_count() - 1, 0))

func _on_combat_log_entry_added(entry: String) -> void:
	TextOutput.text += entry + "\n"
	TextOutput.scroll_to_line(max(TextOutput.get_line_count() - 1, 0))

func _on_combat_log_entries_cleared() -> void:
	TextOutput.text = ""

func _on_clear_button_pressed() -> void:
	CombatLog.clear()

func _on_close_button_pressed() -> void:
	requested_close.emit()
