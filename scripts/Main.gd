extends Node

class_name Main

@export var level_scene: PackedScene

@onready var level_container: Node = $LevelContainer
@onready var main_menu: MainMenu = $MainMenu

var current_level: Node

func _ready() -> void:
	if not main_menu:
		push_warning("MainMenu instance not found in Main scene.")
		return
	main_menu.start_requested.connect(_on_start_requested)
	main_menu.resume_requested.connect(_on_resume_requested)
	main_menu.quit_requested.connect(_on_quit_requested)
	_show_menu()

func _on_start_requested() -> void:
	start_new_game()

func _on_resume_requested() -> void:
	resume_game()

func _on_quit_requested() -> void:
	get_tree().quit()

func start_new_game() -> void:
	_clear_current_level()
	GameState.reset_progress()
	_spawn_level()

func resume_game() -> void:
	if not _has_level():
		return
	if current_level.get_parent() == null:
		level_container.add_child(current_level)
	_hide_menu()
	get_tree().paused = false

func restart_current_level() -> void:
	if not level_scene:
		return
	if _has_level():
		if current_level.get_parent() == level_container:
			level_container.remove_child(current_level)
		current_level.queue_free()
		current_level = null
	_spawn_level()

func return_to_menu(preserve_level: bool = true) -> void:
	get_tree().paused = false
	if _has_level() and current_level.get_parent() == level_container:
		level_container.remove_child(current_level)
	if not preserve_level and _has_level():
		current_level.queue_free()
		current_level = null
	_show_menu()

func _spawn_level() -> void:
	if not level_scene:
		push_warning("No level scene assigned to Main.")
		return
	current_level = level_scene.instantiate()
	level_container.add_child(current_level)
	_hide_menu()
	get_tree().paused = false

func _show_menu() -> void:
	if main_menu:
		main_menu.visible = true
		main_menu.set_resume_available(_has_level())
		main_menu.grab_default_focus()

func _hide_menu() -> void:
	if main_menu:
		main_menu.visible = false

func _clear_current_level() -> void:
	if not _has_level():
		return
	if current_level.get_parent() == level_container:
		level_container.remove_child(current_level)
	current_level.queue_free()
	current_level = null

func _has_level() -> bool:
	return is_instance_valid(current_level)
