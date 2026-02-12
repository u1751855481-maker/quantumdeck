extends CanvasLayer

@onready var MenuContainer: Control = $MenuContainer
@onready var FadeRect: ColorRect = $FadeRect

var MenuRegistry := {
	"pause_menu": preload("res://scenes/pause_menu.tscn"),
	"combat_log_panel": preload("res://scenes/ui/combat_log_panel.tscn"),
	"debug_overlay": preload("res://scenes/ui/debug_overlay.tscn")
}

var OpenMenus := {}

func _ready() -> void:
	if(theme == null):
		theme = Theme.new()
	FadeRect.visible = false
	FadeRect.modulate.a = 0.0

func open_menu(menu_name: String) -> Node:
	if(OpenMenus.has(menu_name)):
		return OpenMenus[menu_name]
	if(!MenuRegistry.has(menu_name)):
		return null
	var menu := MenuRegistry[menu_name].instantiate()
	if(menu.has_signal("requested_close")):
		menu.connect("requested_close", _on_menu_requested_close.bind(menu_name))
	MenuContainer.add_child(menu)
	OpenMenus[menu_name] = menu
	return menu

func close_menu(menu_name: String) -> void:
	if(!OpenMenus.has(menu_name)):
		return
	var menu: Node = OpenMenus[menu_name]
	OpenMenus.erase(menu_name)
	menu.queue_free()

func get_menu(menu_name: String) -> Node:
	if(OpenMenus.has(menu_name)):
		return OpenMenus[menu_name]
	return null

func transition_to_scene(scene_path: String) -> void:
	await fade_in()
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	await fade_out()

func fade_in() -> void:
	FadeRect.visible = true
	var tween := create_tween()
	tween.tween_property(FadeRect, "modulate:a", 1.0, 0.2)
	await tween.finished

func fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(FadeRect, "modulate:a", 0.0, 0.2)
	await tween.finished
	FadeRect.visible = false

func _on_menu_requested_close(menu_name: String) -> void:
	close_menu(menu_name)
