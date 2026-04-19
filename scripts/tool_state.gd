extends Resource
class_name ToolState

var blocked := 0.0

func block():
	blocked = 2.0/Engine.physics_ticks_per_second

func is_blocked():
	return blocked > 0

func update(delta: float):
	blocked = maxf(0, blocked - delta)
