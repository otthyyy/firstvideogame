extends Area2D

@export var coin_value: int = 10

var _collected: bool = false

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if _collected:
        return
    if body.is_in_group("player"):
        collect()

func collect() -> void:
    _collected = true
    set_deferred("monitoring", false)
    set_deferred("monitorable", false)
    GameState.add_score(coin_value)
    visible = false
    if audio_player and audio_player.stream:
        audio_player.play()
        await audio_player.finished
    queue_free()
