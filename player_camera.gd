extends Camera3D

@export_range(0.05, 1.0, 0.05) var mouse_sensitivity := 0.25
@export_range(0.05, 1.0, 0.05) var stick_sensitivity := 0.25

func is_captured() -> bool:
		return Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and get_viewport().get_window().has_focus()

func turn(v: Vector2):
	rotation_degrees.x = clampf(rotation_degrees.x - v.y, -89.99, 89.99)
	rotation_degrees.y -= v.x

func _input(event: InputEvent) -> void:
	if not is_captured():
		return
	if event is InputEventMouseMotion:
		#turn_ignore_timer = turn_ignore_time
		#orbit_speed_target = orbit_speed_mouse
		turn(event.relative * mouse_sensitivity)
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	var lookv := Input.get_vector(&"look_left", &"look_right", &"look_up", &"look_down")
	turn(lookv * delta * 60)
