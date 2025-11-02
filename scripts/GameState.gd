extends Node

signal master_volume_changed(value: float)
signal score_changed(new_score: int)
signal lives_changed(new_lives: int)

const SETTINGS_FILE := "user://settings.cfg"
const SETTINGS_SECTION := "audio"
const SETTINGS_KEY := "master_volume"

var master_volume: float = 1.0
var score: int = 0
var lives: int = 3

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    load_settings()
    apply_volume()
    emit_signal("master_volume_changed", master_volume)
    emit_signal("score_changed", score)
    emit_signal("lives_changed", lives)

func reset_progress() -> void:
    score = 0
    lives = 3
    emit_signal("score_changed", score)
    emit_signal("lives_changed", lives)

func add_score(amount: int) -> void:
    if amount == 0:
        return
    score = max(score + amount, 0)
    emit_signal("score_changed", score)

func lose_life() -> void:
    lives = max(lives - 1, 0)
    emit_signal("lives_changed", lives)

func set_master_volume(value: float) -> void:
    value = clamp(value, 0.0, 1.0)
    if is_equal_approx(master_volume, value):
        return
    master_volume = value
    apply_volume()
    save_settings()
    emit_signal("master_volume_changed", master_volume)

func load_settings() -> void:
    var config := ConfigFile.new()
    var err := config.load(SETTINGS_FILE)
    if err == OK:
        master_volume = float(config.get_value(SETTINGS_SECTION, SETTINGS_KEY, master_volume))
    else:
        master_volume = 1.0

func save_settings() -> void:
    var config := ConfigFile.new()
    config.set_value(SETTINGS_SECTION, SETTINGS_KEY, master_volume)
    config.save(SETTINGS_FILE)

func apply_volume() -> void:
    var master_bus := AudioServer.get_bus_index("Master")
    if master_bus == -1:
        return
    if master_volume <= 0.0:
        AudioServer.set_bus_volume_db(master_bus, -80.0)
        AudioServer.set_bus_mute(master_bus, true)
    else:
        AudioServer.set_bus_mute(master_bus, false)
        AudioServer.set_bus_volume_db(master_bus, linear_to_db(master_volume))
