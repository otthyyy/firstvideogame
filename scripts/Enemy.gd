extends CharacterBody2D

@export var patrol_distance: float = 200.0
@export var patrol_speed: float = 100.0
@export var gravity: float = 1500.0
@export var damage_amount: int = 1
@export var knockback_force: float = 300.0
@export var stomp_height_threshold: float = -50.0

var _start_position: Vector2
var _direction: int = 1
var _patrol_left_limit: float
var _patrol_right_limit: float

@onready var sprite: Node2D = $Sprite2D

func _ready() -> void:
    add_to_group("enemies")
    _start_position = global_position
    _patrol_left_limit = _start_position.x - patrol_distance / 2.0
    _patrol_right_limit = _start_position.x + patrol_distance / 2.0
    _flip_sprite()

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y = min(velocity.y + gravity * delta, 1000.0)
    
    velocity.x = _direction * patrol_speed
    
    if global_position.x <= _patrol_left_limit:
        _direction = 1
        _flip_sprite()
    elif global_position.x >= _patrol_right_limit:
        _direction = -1
        _flip_sprite()
    
    move_and_slide()
    
    if is_on_wall():
        _direction *= -1
        _flip_sprite()
    
    _check_player_collision()

func _flip_sprite() -> void:
    if sprite:
        sprite.scale.x = abs(sprite.scale.x) * _direction

func _check_player_collision() -> void:
    for i in range(get_slide_collision_count()):
        var collision := get_slide_collision(i)
        var collider := collision.get_collider()
        
        if collider and collider.is_in_group("player"):
            var collision_normal := collision.get_normal()
            var player := collider as CharacterBody2D
            if player and collision_normal.y > 0.5:
                _on_stomped(player)
            else:
                _damage_player(collider)

func _damage_player(player: Node2D) -> void:
    if player.has_method("take_damage"):
        var direction := (player.global_position - global_position).normalized()
        player.take_damage(damage_amount, direction * knockback_force)

func _on_stomped(_player: Node2D) -> void:
    queue_free()

func die() -> void:
    queue_free()
