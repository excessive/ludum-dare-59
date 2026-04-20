extends Control

@export var player_state: PlayerState

func _on_new_pressed() -> void:
	player_state.reset()

func _ready() -> void:
	if not player_state.checkpoints_visited.is_empty() or player_state.game_time > 0:
		%continue.disabled = false
