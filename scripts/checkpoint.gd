extends Area3D

@export var player_state: PlayerState
var anim: Tween
@onready var label: Label = $Label
@export var external_trigger_mode := false

func _ready() -> void:
	if not external_trigger_mode:
		_reconnect()

func _reconnect():
	body_entered.connect(_on_body_entered, CONNECT_ONE_SHOT)

func _checkpoint():
	if not player_state.checkpoint(self):
		return # already recorded
	print("checkpoint reached (%s)" % global_position)
	label.show()
	label.modulate.a = 0
	label.visible_ratio = 0
	# this shouldn't actually happen but i am paranoid
	if anim and anim.is_valid():
		anim.kill()
	anim = create_tween()
	anim.set_trans(Tween.TRANS_CUBIC)
	anim.set_ease(Tween.EASE_OUT)
	anim.tween_property(label, "visible_ratio", 1, 0.25)
	anim.parallel().tween_property(label, "modulate:a", 1, 0.1)
	anim.tween_interval(2)
	anim.tween_property(label, "modulate:a", 0, 1)

func _on_body_entered(node: Node3D):
	if not node.is_in_group(&"player"):
		_reconnect()
		return
	_checkpoint()
