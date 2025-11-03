extends Node2D

@export var level_columns: int = 40
@export var tile_size: int = 32
@export var ground_row: int = 20
@export var ground_support_depth: int = 1
@export var platform_definitions: Array = [
    {"start": Vector2i(6, 16), "length": 5},
    {"start": Vector2i(13, 14), "length": 4},
    {"start": Vector2i(21, 12), "length": 6},
    {"start": Vector2i(30, 15), "length": 5},
]

@onready var tile_map: TileMap = $TileMap
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var pause_menu: PauseMenu = $PauseMenu
@onready var end_menu: CanvasLayer = $EndMenu
@onready var end_label: Label = $EndMenu/Panel/VBoxContainer/EndLabel
@onready var restart_button: Button = $EndMenu/Panel/VBoxContainer/RestartButton
@onready var hud: CanvasLayer = $HUD
@onready var score_label: Label = $HUD/MarginContainer/VBoxContainer/ScoreLabel
@onready var lives_label: Label = $HUD/MarginContainer/VBoxContainer/LivesLabel
@onready var goal_area: Area2D = $Goal

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    pause_menu.visible = false
    end_menu.visible = false
    end_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
    pause_menu.resume_requested.connect(_on_resume_requested)
    pause_menu.quit_to_menu_requested.connect(_on_quit_to_menu_requested)
    
    var score_callable := Callable(self, "_on_score_changed")
    if not GameState.score_changed.is_connected(score_callable):
        GameState.score_changed.connect(score_callable)
    var lives_callable := Callable(self, "_on_lives_changed")
    if not GameState.lives_changed.is_connected(lives_callable):
        GameState.lives_changed.connect(lives_callable)
    _update_ui()
    
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

func _update_ui() -> void:
    score_label.text = "Score: %d" % GameState.score
    lives_label.text = "Lives: %d" % GameState.lives

func _on_score_changed(_new_score: int) -> void:
    _update_ui()

func _on_lives_changed(_new_lives: int) -> void:
    _update_ui()

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
