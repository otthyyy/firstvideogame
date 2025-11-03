extends Area2D

@export var value: int = 1

var _collected: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    if animated_sprite:
        animated_sprite.play("idle")

func _on_body_entered(body: Node2D) -> void:
    if _collected:
        return
    if not body.is_in_group("player"):
        return
    _collect()

func _collect() -> void:
    _collected = true
    GameState.add_score(value)
    if collision_shape:
        collision_shape.set_deferred("disabled", true)
    set_deferred("monitoring", false)
    set_deferred("monitorable", false)
    if animated_sprite:
        animated_sprite.play("collected")
    if audio_player and audio_player.stream:
        audio_player.play()
        await audio_player.finished
    queue_free()
