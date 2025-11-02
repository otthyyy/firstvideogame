extends Control

@onready var start_button: Button = $CenterContainer/Panel/VBoxContainer/StartButton
@onready var quit_button: Button = $CenterContainer/Panel/VBoxContainer/QuitButton
@onready var volume_slider: HSlider = $CenterContainer/Panel/VBoxContainer/VolumeContainer/VolumeControls/VolumeSlider
@onready var volume_value: Label = $CenterContainer/Panel/VBoxContainer/VolumeContainer/VolumeControls/VolumeValue

func _ready() -> void:
    GameState.master_volume_changed.connect(_on_master_volume_changed)
    volume_slider.value = GameState.master_volume
    _update_volume_label(GameState.master_volume)
    start_button.grab_focus()

func _on_start_button_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/Level1.tscn")

func _on_quit_button_pressed() -> void:
    get_tree().quit()

func _on_volume_slider_value_changed(value: float) -> void:
    GameState.set_master_volume(value)
    _update_volume_label(value)

func _update_volume_label(value: float) -> void:
    volume_value.text = "%d%%" % int(value * 100)

func _on_master_volume_changed(value: float) -> void:
    if not is_equal_approx(volume_slider.value, value):
        volume_slider.value = value
        _update_volume_label(value)
