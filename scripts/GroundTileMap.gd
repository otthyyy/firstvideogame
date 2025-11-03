extends TileMap

# Configuration for automatically generated ground tiles
@export var ground_y: int = 10
@export var ground_half_width: int = 20
@export var platform_definitions: Array = [
    {"start": Vector2i(-6, 6), "length": 5},
    {"start": Vector2i(4, 4), "length": 4}
]
@export var origin: Vector2i = Vector2i.ZERO

func _ready() -> void:
    # Ensure a TileSet is assigned; fall back to the default if missing.
    if tile_set == null:
        tile_set = load("res://tilesets/GroundTileset.tres")
    _generate_layout()

func _generate_layout() -> void:
    # Clear existing tiles before generating the layout
    clear()

    # Create the main ground strip
    for x in range(-ground_half_width, ground_half_width + 1):
        set_cell(0, origin + Vector2i(x, ground_y), 0, Vector2i.ZERO)

    # Spawn additional floating platforms
    for definition in platform_definitions:
        var start: Vector2i = definition.get("start", Vector2i.ZERO)
        var length: int = definition.get("length", 3)
        for offset in range(length):
            set_cell(0, origin + start + Vector2i(offset, 0), 0, Vector2i.ZERO)
