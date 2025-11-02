extends CanvasLayer

class_name PauseMenu

signal resume_requested
signal quit_to_menu_requested

@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var volume_slider: HSlider = $Panel/VBoxContainer/VolumeContainer/VolumeControls/VolumeSlider
@onready var volume_value: Label = $Panel/VBoxContainer/VolumeContainer/VolumeControls/VolumeValue

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_WHEN_PAUSED
    GameState.master_volume_changed.connect(_on_master_volume_changed)
    volume_slider.value = GameState.master_volume
    _update_volume_label(GameState.master_volume)

func _on_resume_button_pressed() -> void:
    emit_signal("resume_requested")

func _on_quit_to_menu_button_pressed() -> void:
    emit_signal("quit_to_menu_requested")

func _on_volume_slider_value_changed(value: float) -> void:
    GameState.set_master_volume(value)
    _update_volume_label(value)

func _update_volume_label(value: float) -> void:
    volume_value.text = "%d%%" % int(value * 100)

func _on_master_volume_changed(value: float) -> void:
    if not is_equal_approx(volume_slider.value, value):
        volume_slider.value = value
        _update_volume_label(value)

func show_menu() -> void:
    visible = true
    resume_button.grab_focus()
