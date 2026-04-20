extends Button
class_name ScreenChangeButton

@export_file("*.tscn") var target_screen: String
@export var quit_after_transition_out := false

func _ready() -> void:
	if not target_screen:
		disabled = true
		return
	pressed.connect(_on_pressed)

func _on_pressed():
	if disabled:
		return
	if quit_after_transition_out:
		ScreenTransition.quit_after_transition_out = true
	ScreenTransition.auto_transition_threaded(target_screen)
	disabled = true
