extends Node2D

@onready var pause_menu: PauseMenu = $PauseMenu
@onready var end_menu: CanvasLayer = $EndMenu
@onready var end_label: Label = $EndMenu/Panel/VBoxContainer/EndLabel
@onready var restart_button: Button = $EndMenu/Panel/VBoxContainer/RestartButton
@onready var hud: CanvasLayer = $HUD

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    pause_menu.visible = false
    end_menu.visible = false
    end_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
    pause_menu.resume_requested.connect(_on_resume_requested)
    pause_menu.quit_to_menu_requested.connect(_on_quit_to_menu_requested)

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

func _on_complete_button_pressed() -> void:
    _show_end_menu("Level Complete!")

func _on_game_over_button_pressed() -> void:
    _show_end_menu("Game Over")

func _show_end_menu(message: String) -> void:
    get_tree().paused = true
    hud.visible = false
    pause_menu.visible = false
    end_label.text = message
    end_menu.visible = true
    restart_button.grab_focus()

func _on_restart_button_pressed() -> void:
    get_tree().paused = false
    get_tree().reload_current_scene()

func _on_quit_to_menu_from_end_pressed() -> void:
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
