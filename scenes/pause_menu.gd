extends Control

func _on_continue_pressed() -> void:
	hide()
	get_tree().paused = false

	await get_tree().process_frame
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _ready() -> void:
	visibility_changed.connect(func():
		get_tree().paused = is_visible_in_tree()
	)

func _exit_tree() -> void:
	get_tree().paused = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		visible = not visible
		if not visible:
			await get_tree().process_frame
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
