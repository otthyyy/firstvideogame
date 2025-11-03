extends Control

class_name MainMenu

signal start_requested
signal resume_requested
signal quit_requested

@onready var start_button: Button = $CenterContainer/Panel/VBoxContainer/StartButton
@onready var resume_button: Button = $CenterContainer/Panel/VBoxContainer/ResumeButton
@onready var quit_button: Button = $CenterContainer/Panel/VBoxContainer/QuitButton
@onready var volume_slider: HSlider = $CenterContainer/Panel/VBoxContainer/VolumeContainer/VolumeControls/VolumeSlider
@onready var volume_value: Label = $CenterContainer/Panel/VBoxContainer/VolumeContainer/VolumeControls/VolumeValue

var _resume_available: bool = false

func _ready() -> void:
	GameState.master_volume_changed.connect(_on_master_volume_changed)
	volume_slider.value = GameState.master_volume
	_update_volume_label(GameState.master_volume)
	_update_resume_button()
	grab_default_focus()

func set_resume_available(value: bool) -> void:
	if _resume_available == value:
		return
	_resume_available = value
	_update_resume_button()

func grab_default_focus() -> void:
	if _resume_available and not resume_button.disabled:
		resume_button.grab_focus()
	else:
		start_button.grab_focus()

func _on_start_button_pressed() -> void:
	emit_signal("start_requested")

func _on_resume_button_pressed() -> void:
	emit_signal("resume_requested")

func _on_quit_button_pressed() -> void:
	emit_signal("quit_requested")

func _on_volume_slider_value_changed(value: float) -> void:
	GameState.set_master_volume(value)
	_update_volume_label(value)

func _update_volume_label(value: float) -> void:
	volume_value.text = "%d%%" % int(value * 100)

func _on_master_volume_changed(value: float) -> void:
	if not is_equal_approx(volume_slider.value, value):
		volume_slider.value = value
		_update_volume_label(value)

func _update_resume_button() -> void:
	resume_button.visible = _resume_available
	resume_button.disabled = not _resume_available
