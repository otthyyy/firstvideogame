extends CanvasLayer

class_name HUD

@onready var _score_label: Label = %ScoreLabel
@onready var _lives_label: Label = %LivesLabel

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    _connect_signals()
    _update_labels()

func _connect_signals() -> void:
    var score_callable := Callable(self, "_on_score_changed")
    if not GameState.score_changed.is_connected(score_callable):
        GameState.score_changed.connect(score_callable)
    var lives_callable := Callable(self, "_on_lives_changed")
    if not GameState.lives_changed.is_connected(lives_callable):
        GameState.lives_changed.connect(lives_callable)

func _on_score_changed(_new_score: int) -> void:
    _update_labels()

func _on_lives_changed(_new_lives: int) -> void:
    _update_labels()

func _update_labels() -> void:
    _score_label.text = "Score: %03d" % GameState.score
    _lives_label.text = "Lives: %d" % GameState.lives
