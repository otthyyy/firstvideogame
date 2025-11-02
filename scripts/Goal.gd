extends Area2D

signal goal_reached

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if not body.is_in_group("player"):
        return
    set_deferred("monitoring", false)
    set_deferred("monitorable", false)
    emit_signal("goal_reached")
