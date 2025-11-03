extends Area2D

@export var damage_amount: int = 1
@export var knockback_force: float = 200.0

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if not body.is_in_group("player"):
        return
    if body.has_method("take_damage"):
        var direction := (body.global_position - global_position).normalized()
        body.take_damage(damage_amount, direction * knockback_force)
