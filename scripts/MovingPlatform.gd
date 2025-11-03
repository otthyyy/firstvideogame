extends AnimatableBody2D

@export var start_position: Vector2 = Vector2.ZERO
@export var end_position: Vector2 = Vector2(200, 0)
@export var duration: float = 4.0
@export var wait_time: float = 1.0

var _time: float = 0.0
var _is_waiting: bool = false
var _wait_timer: float = 0.0
var _direction: int = 1

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
    if start_position == Vector2.ZERO:
        start_position = global_position
    global_position = start_position

func _physics_process(delta: float) -> void:
    if _is_waiting:
        _wait_timer -= delta
        if _wait_timer <= 0:
            _is_waiting = false
            _direction *= -1
            _time = 0.0
        return
    
    _time += delta / duration
    
    if _time >= 1.0:
        _time = 1.0
        _is_waiting = true
        _wait_timer = wait_time
    
    var progress := _time if _direction == 1 else 1.0 - _time
    var target_position := start_position.lerp(end_position, progress)
    var velocity := (target_position - global_position) / delta
    
    global_position = target_position
