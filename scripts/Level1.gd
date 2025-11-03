extends Node2D

@export var level_name: String = "Level 1"
@export var level_width: int = 3072
@export var level_height: int = 720

@onready var pause_menu: PauseMenu = $PauseMenu
@onready var end_menu: CanvasLayer = $EndMenu
@onready var end_label: Label = $EndMenu/Panel/VBoxContainer/EndLabel
@onready var restart_button: Button = $EndMenu/Panel/VBoxContainer/RestartButton
@onready var hud: CanvasLayer = $HUD
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu.visible = false
	end_menu.visible = false
	end_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	pause_menu.resume_requested.connect(_on_resume_requested)
	pause_menu.quit_to_menu_requested.connect(_on_quit_to_menu_requested)
	
	if hud and hud.has_method("set_level_name"):
		hud.set_level_name(level_name)
	
	_setup_camera_limits()
	_connect_player()
	_connect_goal()

func _setup_camera_limits() -> void:
	if camera:
		camera.limit_left = 0
		camera.limit_top = 0
		camera.limit_right = level_width
		camera.limit_bottom = level_height

func _connect_player() -> void:
	var player_node := get_tree().get_first_node_in_group("player")
	if player_node:
		player_node.player_died.connect(_on_player_died)

func _connect_goal() -> void:
	var goal := get_tree().get_first_node_in_group("goal")
	if goal:
		goal.goal_reached.connect(_on_goal_reached)

func _on_player_died() -> void:
	GameState.lose_life()
	if GameState.lives <= 0:
		_show_end_menu("Game Over")
	else:
		get_tree().reload_current_scene()

func _on_goal_reached() -> void:
	_show_end_menu("Level Complete!")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not end_menu.visible:
		_toggle_pause()

func _toggle_pause() -> void:
	var tree := get_tree()
	tree.paused = not tree.paused
	pause_menu.visible = tree.paused
	if tree.paused:
		pause_menu.show_menu()

func _on_resume_requested() -> void:
	get_tree().paused = false
	pause_menu.visible = false

func _on_quit_to_menu_requested() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _show_end_menu(message: String) -> void:
	get_tree().paused = true
	hud.visible = false
	pause_menu.visible = false
	end_label.text = message
	end_menu.visible = true
	restart_button.grab_focus()

func _on_restart_button_pressed() -> void:
	GameState.reset_progress()
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_to_menu_from_end_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
