extends Node

signal entry_added(entry: String)
signal entries_cleared

var entries: Array[String] = []
const MAX_ENTRIES := 100

func add_entry(entry: String) -> void:
	entries.push_back(entry)
	if(entries.size() > MAX_ENTRIES):
		entries.pop_front()
	entry_added.emit(entry)

func clear() -> void:
	entries.clear()
	entries_cleared.emit()

func get_entries() -> Array[String]:
	return entries.duplicate()
