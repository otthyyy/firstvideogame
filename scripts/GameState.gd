extends Node

signal master_volume_changed(value: float)
signal music_volume_changed(value: float)
signal sfx_volume_changed(value: float)
signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal checkpoint_updated(position: Vector2)

const SETTINGS_FILE := "user://settings.cfg"
const SETTINGS_SECTION := "audio"
const SETTINGS_KEY_MASTER := "master_volume"
const SETTINGS_KEY_MUSIC := "music_volume"
const SETTINGS_KEY_SFX := "sfx_volume"

var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 1.0
var score: int = 0
var lives: int = 3
var last_checkpoint_position: Vector2 = Vector2.ZERO
var last_checkpoint_id: int = -1
var spawn_position: Vector2 = Vector2.ZERO

var audio: AudioManager

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    _setup_audio_manager()
    load_settings()
    apply_volume()
    emit_signal("master_volume_changed", master_volume)
    emit_signal("music_volume_changed", music_volume)
    emit_signal("sfx_volume_changed", sfx_volume)
    emit_signal("score_changed", score)
    emit_signal("lives_changed", lives)
    emit_signal("checkpoint_updated", get_respawn_position())

func _setup_audio_manager() -> void:
    audio = AudioManager.new()
    add_child(audio)

func reset_progress() -> void:
    score = 0
    lives = 3
    last_checkpoint_id = -1
    last_checkpoint_position = spawn_position
    emit_signal("score_changed", score)
    emit_signal("lives_changed", lives)
    emit_signal("checkpoint_updated", get_respawn_position())

func add_score(amount: int) -> void:
    if amount == 0:
        return
    score = max(score + amount, 0)
    emit_signal("score_changed", score)

func damage(amount: int) -> int:
    if amount <= 0:
        return lives
    lives = max(lives - amount, 0)
    emit_signal("lives_changed", lives)
    return lives

func lose_life() -> void:
    damage(1)

func set_checkpoint(position: Vector2, checkpoint_id: int = -1) -> void:
    last_checkpoint_position = position
    last_checkpoint_id = checkpoint_id
    emit_signal("checkpoint_updated", position)

func get_respawn_position() -> Vector2:
    if last_checkpoint_id >= 0:
        return last_checkpoint_position
    return spawn_position

func set_spawn_position(position: Vector2) -> void:
    spawn_position = position
    if last_checkpoint_id < 0:
        last_checkpoint_position = position
        emit_signal("checkpoint_updated", position)

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
        master_volume = float(config.get_value(SETTINGS_SECTION, SETTINGS_KEY_MASTER, master_volume))
        music_volume = float(config.get_value(SETTINGS_SECTION, SETTINGS_KEY_MUSIC, music_volume))
        sfx_volume = float(config.get_value(SETTINGS_SECTION, SETTINGS_KEY_SFX, sfx_volume))
    else:
        master_volume = 1.0
        music_volume = 0.8
        sfx_volume = 1.0

func save_settings() -> void:
    var config := ConfigFile.new()
    config.set_value(SETTINGS_SECTION, SETTINGS_KEY_MASTER, master_volume)
    config.set_value(SETTINGS_SECTION, SETTINGS_KEY_MUSIC, music_volume)
    config.set_value(SETTINGS_SECTION, SETTINGS_KEY_SFX, sfx_volume)
    config.save(SETTINGS_FILE)

func apply_volume() -> void:
    var master_bus := AudioServer.get_bus_index("Master")
    if master_bus != -1:
        if master_volume <= 0.0:
            AudioServer.set_bus_volume_db(master_bus, -80.0)
            AudioServer.set_bus_mute(master_bus, true)
        else:
            AudioServer.set_bus_mute(master_bus, false)
            AudioServer.set_bus_volume_db(master_bus, linear_to_db(master_volume))
    if audio:
        audio.set_music_volume(music_volume)
        audio.set_sfx_volume(sfx_volume)
