extends Node

class_name AudioManager

var _music_player: AudioStreamPlayer
var _active_sfx_players: Array[AudioStreamPlayer] = []

func _ready() -> void:
    _music_player = AudioStreamPlayer.new()
    _music_player.bus = "Music"
    _music_player.autoplay = false
    add_child(_music_player)

func play_music(stream: AudioStream, loop: bool = true, from_position: float = 0.0) -> void:
    if not stream:
        return
    if _music_player.stream == stream and _music_player.playing:
        return
    _music_player.stop()
    _music_player.stream = stream
    _music_player.loop = loop
    _music_player.play(from_position)

func stop_music() -> void:
    if _music_player.playing:
        _music_player.stop()

func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
    if not stream:
        return
    var player := AudioStreamPlayer.new()
    player.bus = "SFX"
    player.stream = stream
    player.volume_db = volume_db
    add_child(player)
    _active_sfx_players.append(player)
    player.finished.connect(_on_sfx_finished.bind(player))
    player.play()

func set_music_volume(value: float) -> void:
    var bus := AudioServer.get_bus_index("Music")
    if bus == -1:
        return
    AudioServer.set_bus_volume_db(bus, linear_to_db(clamp(value, 0.0, 1.0)))

func set_sfx_volume(value: float) -> void:
    var bus := AudioServer.get_bus_index("SFX")
    if bus == -1:
        return
    AudioServer.set_bus_volume_db(bus, linear_to_db(clamp(value, 0.0, 1.0)))

func _on_sfx_finished(player: AudioStreamPlayer) -> void:
    if player in _active_sfx_players:
        _active_sfx_players.erase(player)
    player.queue_free()
