extends Node2D

signal level_completed

@export var level_columns: int = 40
@export var tile_size: int = 32
@export var ground_row: int = 20

@onready var tile_map: TileMap = $TileMap
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var goal: Area2D = $Goal
@onready var completion_label: Label = $UI/Label

func _ready() -> void:
    _build_level()
    _configure_camera_limits()
    goal.goal_reached.connect(_on_goal_reached)

func _build_level() -> void:
    tile_map.clear()
    for x in range(level_columns):
        tile_map.set_cell(0, Vector2i(x, ground_row), 0, Vector2i(0, 0))
        tile_map.set_cell(0, Vector2i(x, ground_row + 1), 0, Vector2i(1, 0))

    var platforms := [
        { "start": Vector2i(6, 16), "length": 5 },
        { "start": Vector2i(13, 14), "length": 4 },
        { "start": Vector2i(21, 12), "length": 6 },
        { "start": Vector2i(30, 15), "length": 5 }
    ]

    for platform in platforms:
        var origin: Vector2i = platform["start"]
        var length: int = platform["length"]
        for i in range(length):
            tile_map.set_cell(0, origin + Vector2i(i, 0), 0, Vector2i(0, 0))

func _configure_camera_limits() -> void:
    var width := level_columns * tile_size
    var height := (ground_row + 3) * tile_size
    camera.limit_left = 0
    camera.limit_right = width
    camera.limit_top = 0
    camera.limit_bottom = height

func _on_goal_reached() -> void:
    if completion_label.visible:
        return
    completion_label.visible = true
    level_completed.emit()
    player.set_physics_process(false)
    player.velocity = Vector2.ZERO
