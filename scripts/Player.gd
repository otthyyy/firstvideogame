extends CharacterBody2D

# Movement parameters
@export var speed: float = 300.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

# Jump parameters
@export var jump_velocity: float = -500.0
@export var jump_release_multiplier: float = 0.5
@export var gravity: float = 1500.0
@export var max_fall_speed: float = 1000.0

# Coyote time: grace period after leaving a platform to still jump
@export var coyote_time: float = 0.1
var coyote_timer: float = 0.0

# Jump buffer: grace period to buffer jump input before landing
@export var jump_buffer_time: float = 0.1
var jump_buffer_timer: float = 0.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
    # Initialize sprite direction
    animated_sprite.play("idle")

func _physics_process(delta: float) -> void:
    # Get input direction
    var input_direction: float = Input.get_axis("move_left", "move_right")
    
    # Apply gravity
    if not is_on_floor():
        velocity.y = min(velocity.y + gravity * delta, max_fall_speed)
        # Decrease coyote timer when in air
        coyote_timer -= delta
    else:
        # Reset coyote timer when on ground
        coyote_timer = coyote_time
    
    # Handle horizontal movement with acceleration and deceleration
    if input_direction != 0:
        # Accelerate towards target speed
        velocity.x = move_toward(velocity.x, input_direction * speed, acceleration * delta)
    else:
        # Apply friction when no input
        velocity.x = move_toward(velocity.x, 0, friction * delta)
    
    # Handle jump buffer timer
    if Input.is_action_just_pressed("jump"):
        jump_buffer_timer = jump_buffer_time
    
    if jump_buffer_timer > 0:
        jump_buffer_timer -= delta
    
    # Handle jump with coyote time and jump buffer
    if jump_buffer_timer > 0 and coyote_timer > 0:
        velocity.y = jump_velocity
        coyote_timer = 0.0
        jump_buffer_timer = 0.0
    
    # Variable jump height: release jump early for shorter jump
    if Input.is_action_just_released("jump") and velocity.y < 0:
        velocity.y *= jump_release_multiplier
    
    # Move the character
    move_and_slide()
    
    # Update animations
    update_animations(input_direction)

func update_animations(input_direction: float) -> void:
    # Flip sprite based on movement direction
    if input_direction != 0:
        animated_sprite.flip_h = input_direction < 0
    
    # Set animation based on state
    if not is_on_floor():
        animated_sprite.play("jump")
    elif input_direction != 0:
        animated_sprite.play("run")
    else:
        animated_sprite.play("idle")
