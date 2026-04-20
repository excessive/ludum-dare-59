extends Area3D

@export var player_state: PlayerState
@export var external_trigger_mode := false

func _ready() -> void:
	if not external_trigger_mode:
		_reconnect()

func _reconnect():
	body_entered.connect(_on_body_entered, CONNECT_ONE_SHOT)

func _checkpoint(_message := "CHECKPOINT_REACHED"):
	if not player_state.checkpoint(self):
		return # already recorded
	print("checkpoint reached (%s)" % global_position)

	if _message:
		var msg = ScreenMessage.new()
		msg.text = _message
		add_child(msg)

func _on_body_entered(node: Node3D):
	if not node.is_in_group(&"player"):
		_reconnect()
		return
	_checkpoint()
