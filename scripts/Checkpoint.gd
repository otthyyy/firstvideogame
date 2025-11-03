extends Area2D

signal checkpoint_activated

@export var checkpoint_id: int = 0
@export var activation_color: Color = Color(0.2, 0.8, 0.2, 1)
@export var inactive_color: Color = Color(0.6, 0.6, 0.6, 1)

var _activated: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    _set_visual_state()

func _on_body_entered(body: Node2D) -> void:
    if _activated:
        return
    if not body.is_in_group("player"):
        return
    activate()

func activate() -> void:
    if _activated:
        return
    _activated = true
    GameState.set_checkpoint(global_position, checkpoint_id)
    _set_visual_state()
    if audio_player and audio_player.stream:
        audio_player.play()
    emit_signal("checkpoint_activated")

func _set_visual_state() -> void:
    if sprite:
        sprite.modulate = activation_color if _activated else inactive_color
