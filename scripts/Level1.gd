extends Node2D

@onready var pause_menu: PauseMenu = $PauseMenu
@onready var end_menu: CanvasLayer = $EndMenu
@onready var end_label: Label = $EndMenu/Panel/VBoxContainer/EndLabel
@onready var restart_button: Button = $EndMenu/Panel/VBoxContainer/RestartButton
@onready var hud: CanvasLayer = $HUD
@onready var score_label: Label = $HUD/MarginContainer/VBoxContainer/ScoreLabel
@onready var lives_label: Label = $HUD/MarginContainer/VBoxContainer/LivesLabel

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
    
    _connect_player()
    _connect_goal()

func _connect_player() -> void:
    var player := get_tree().get_first_node_in_group("player")
    if player:
        player.player_died.connect(_on_player_died)

func _connect_goal() -> void:
    var goal := get_tree().get_first_node_in_group("goal")
    if goal:
        goal.goal_reached.connect(_on_goal_reached)

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
