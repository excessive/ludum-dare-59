extends Control

@export var force_mode := Input.MOUSE_MODE_MAX

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if force_mode != Input.MOUSE_MODE_MAX:
		get_window().mouse_exited.connect(func(): Input.mouse_mode = Input.MOUSE_MODE_VISIBLE)
		get_window().mouse_entered.connect(func(): if get_window().has_focus(): capture())
		capture()

func capture():
	if get_viewport().get_window().has_focus() and not get_tree().paused and force_mode == Input.MOUSE_MODE_MAX:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		release()

func release():
	if force_mode != Input.MOUSE_MODE_MAX:
		Input.mouse_mode = force_mode
		return
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _input(event: InputEvent) -> void:
	if event is not InputEventKey:
		return

	if event.is_pressed() and event.keycode == KEY_ESCAPE: # or event.is_action_pressed(&"system_menu"):
		release()
		return

	if event.keycode == KEY_ALT:
		if event.pressed:
			release()
		else:
			capture()

func _gui_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return

	if event.button_index == MOUSE_BUTTON_LEFT:
		capture()

func _process(_delta: float) -> void:
	if get_tree().paused:
		release()
