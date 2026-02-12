extends Control

signal requested_close

@onready var TextOutput: RichTextLabel = $Panel/Margin/VBox/Scroll/Output
@onready var CombatLogState: Node = get_node_or_null("/root/CombatLog")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if(CombatLogState == null):
		TextOutput.text = "Combat log no disponible"
		return
	CombatLogState.entry_added.connect(_on_combat_log_entry_added)
	CombatLogState.entries_cleared.connect(_on_combat_log_entries_cleared)
	rebuild_log()

func rebuild_log() -> void:
	TextOutput.text = ""
	if(CombatLogState == null):
		return
	for entry in CombatLogState.get_entries():
		TextOutput.text += entry + "\n"
	TextOutput.scroll_to_line(max(TextOutput.get_line_count() - 1, 0))

func _on_combat_log_entry_added(entry: String) -> void:
	TextOutput.text += entry + "\n"
	TextOutput.scroll_to_line(max(TextOutput.get_line_count() - 1, 0))

func _on_combat_log_entries_cleared() -> void:
	TextOutput.text = ""

func _on_clear_button_pressed() -> void:
	if(CombatLogState):
		CombatLogState.clear()

func _on_close_button_pressed() -> void:
	requested_close.emit()
