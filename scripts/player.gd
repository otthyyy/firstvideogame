extends CharacterBody2D

@export var speed: float = 220.0
@export var jump_velocity: float = -420.0
@export var fall_gravity_multiplier: float = 1.2

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
    add_to_group("player")

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y += gravity * fall_gravity_multiplier * delta if velocity.y > 0.0 else gravity * delta
    else:
        velocity.y = max(velocity.y, 0.0)

    var direction := Input.get_axis("ui_left", "ui_right")
    if direction == 0:
        velocity.x = move_toward(velocity.x, 0.0, speed * 2.0 * delta)
    else:
        velocity.x = direction * speed

    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = jump_velocity

    move_and_slide()

    if direction != 0:
        $Sprite2D.flip_h = direction < 0
