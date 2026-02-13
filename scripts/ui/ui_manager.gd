extends CanvasLayer

@onready var MenuContainer: Control = $MenuContainer
@onready var FadeRect: ColorRect = $FadeRect

var MenuRegistry: Dictionary = {
	"pause_menu": preload("res://scenes/pause_menu.tscn"),
	"debug_overlay": preload("res://scenes/ui/debug_overlay.tscn")
}

var OpenMenus: Dictionary = {}

func _ready() -> void:
	if(MenuContainer.theme == null):
		MenuContainer.theme = Theme.new()
	FadeRect.visible = false
	FadeRect.modulate.a = 0.0

func open_menu(menu_name: String) -> Node:
	if(OpenMenus.has(menu_name)):
		return OpenMenus[menu_name]
	if(!MenuRegistry.has(menu_name)):
		return null
	var menu_scene: PackedScene = MenuRegistry[menu_name]
	var menu: Node = menu_scene.instantiate()
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
	var tree := get_tree()
	if(tree == null):
		return
	await fade_in()
	tree.change_scene_to_file(scene_path)

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
