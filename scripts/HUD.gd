extends CanvasLayer

class_name HUD

@onready var info_label: Label = $MarginContainer/VBoxContainer/InfoLabel
@onready var score_label: Label = $MarginContainer/VBoxContainer/ScoreLabel
@onready var lives_label: Label = $MarginContainer/VBoxContainer/LivesLabel

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    _update_score(GameState.score)
    _update_lives(GameState.lives)

    var score_callable := Callable(self, "_on_score_changed")
    if not GameState.score_changed.is_connected(score_callable):
        GameState.score_changed.connect(score_callable)

    var lives_callable := Callable(self, "_on_lives_changed")
    if not GameState.lives_changed.is_connected(lives_callable):
        GameState.lives_changed.connect(lives_callable)

func set_level_name(name: String) -> void:
    info_label.text = name

func _on_score_changed(new_score: int) -> void:
    _update_score(new_score)

func _on_lives_changed(new_lives: int) -> void:
    _update_lives(new_lives)

func _update_score(value: int) -> void:
    score_label.text = "Score: %03d" % max(value, 0)

func _update_lives(value: int) -> void:
    lives_label.text = "Lives: %d" % max(value, 0)
