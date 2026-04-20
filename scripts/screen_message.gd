@tool
extends Label
class_name ScreenMessage

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	uppercase = true

	offset_top = -320

	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = mat
	z_index = RenderingServer.CANVAS_ITEM_Z_MAX - 31

	if Engine.is_editor_hint():
		return

	modulate.a = 0
	visible_ratio = 0

	var anim := create_tween()
	anim.set_trans(Tween.TRANS_CUBIC)
	anim.set_ease(Tween.EASE_OUT)
	anim.tween_property(self, "visible_ratio", 1, 0.25)
	anim.parallel().tween_property(self, "modulate:a", 1, 0.1)
	anim.tween_interval(2)
	anim.tween_property(self, "modulate:a", 0, 1)
	anim.finished.connect(queue_free)
