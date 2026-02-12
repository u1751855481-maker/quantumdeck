extends Control

signal requested_close

@onready var TextOutput: RichTextLabel = $Panel/Margin/VBox/Scroll/Output

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	CombatLog.entry_added.connect(_on_combat_log_entry_added)
	CombatLog.entries_cleared.connect(_on_combat_log_entries_cleared)
	rebuild_log()

func rebuild_log() -> void:
	TextOutput.clear()
	for entry in CombatLog.get_entries():
		TextOutput.append_text(entry + "\n")
	TextOutput.scroll_to_line(TextOutput.get_line_count())

func _on_combat_log_entry_added(entry: String) -> void:
	TextOutput.append_text(entry + "\n")
	TextOutput.scroll_to_line(TextOutput.get_line_count())

func _on_combat_log_entries_cleared() -> void:
	TextOutput.clear()

func _on_clear_button_pressed() -> void:
	CombatLog.clear()

func _on_close_button_pressed() -> void:
	requested_close.emit()
