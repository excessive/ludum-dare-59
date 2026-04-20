extends Node
class_name AutoReleaseMouse

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
