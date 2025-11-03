extends Node2D

@export var level_columns: int = 50
@export var tile_size: int = 32
@export var ground_row: int = 22
@export var ground_support_depth: int = 1
@export var platform_definitions: Array = [
    {"start": Vector2i(8, 18), "length": 4},
    {"start": Vector2i(15, 16), "length": 3},
    {"start": Vector2i(22, 14), "length": 5},
    {"start": Vector2i(30, 16), "length": 4},
    {"start": Vector2i(38, 13), "length": 6},
]

@onready var tile_map: TileMap = $TileMap
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var pause_menu: PauseMenu = $PauseMenu
@onready var end_menu: CanvasLayer = $EndMenu
@onready var end_label: Label = $EndMenu/Panel/VBoxContainer/EndLabel
@onready var score_summary_label: Label = $EndMenu/Panel/VBoxContainer/ScoreSummary
@onready var restart_button: Button = $EndMenu/Panel/VBoxContainer/RestartButton
@onready var next_button: Button = $EndMenu/Panel/VBoxContainer/NextButton
@onready var quit_to_menu_button: Button = $EndMenu/Panel/VBoxContainer/QuitToMenuButton
@onready var hud: HUD = $HUD
@onready var goal_area: Area2D = $Goal

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    pause_menu.visible = false
    end_menu.visible = false
    end_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
    pause_menu.resume_requested.connect(_on_resume_requested)
    pause_menu.quit_to_menu_requested.connect(_on_quit_to_menu_requested)
    
    GameState.set_spawn_position(player.global_position)
    
    _build_level()
    _configure_camera_limits()
    _connect_player()
    _connect_goal()

func _connect_player() -> void:
    if player and player.has_signal("player_died"):
        var callable := Callable(self, "_on_player_died")
        if not player.is_connected("player_died", callable):
            player.connect("player_died", callable)

func _connect_goal() -> void:
    if goal_area and goal_area.has_signal("goal_reached"):
        var callable := Callable(self, "_on_goal_reached")
        if not goal_area.is_connected("goal_reached", callable):
            goal_area.connect("goal_reached", callable)

func _on_player_died() -> void:
    var remaining_lives := GameState.damage(1)
    if remaining_lives <= 0:
        _show_end_menu("Game Over")
    else:
        _respawn_player()

func _on_goal_reached() -> void:
    _show_end_menu("Level 2 Complete!", true)

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

func _show_end_menu(message: String, is_level_complete: bool = false) -> void:
    var tree := get_tree()
    tree.paused = true
    hud.visible = false
    pause_menu.visible = false
    end_label.text = message
    score_summary_label.text = "Score: %03d" % GameState.score
    end_menu.visible = true
    next_button.visible = false
    restart_button.grab_focus()

func _on_restart_button_pressed() -> void:
    GameState.reset_progress()
    get_tree().paused = false
    get_tree().reload_current_scene()

func _on_quit_to_menu_from_end_pressed() -> void:
    GameState.reset_progress()
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_next_button_pressed() -> void:
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _build_level() -> void:
    if not tile_map:
        return
    tile_map.clear()
    for x in range(level_columns):
        tile_map.set_cell(0, Vector2i(x, ground_row), 0, Vector2i(0, 0))
        for y in range(ground_support_depth):
            tile_map.set_cell(0, Vector2i(x, ground_row + 1 + y), 0, Vector2i(1, 0))
    
    for platform in platform_definitions:
        var origin: Vector2i = platform.get("start", Vector2i.ZERO)
        var length: int = platform.get("length", 3)
        for i in range(length):
            tile_map.set_cell(0, origin + Vector2i(i, 0), 0, Vector2i(0, 0))

func _configure_camera_limits() -> void:
    if not camera:
        return
    var width := level_columns * tile_size
    var height := (ground_row + ground_support_depth + 4) * tile_size
    camera.limit_left = 0
    camera.limit_right = width
    camera.limit_top = 0
    camera.limit_bottom = height
    camera.position_smoothing_enabled = true
    camera.position_smoothing_speed = 8.0

func _respawn_player() -> void:
    var respawn_position := GameState.get_respawn_position()
    if player and player.has_method("respawn_at"):
        player.respawn_at(respawn_position)
    hud.visible = true
