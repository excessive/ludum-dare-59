class_name LidarChannel
extends Resource

@export_flags_3d_physics var collision_mask := 0
@export_flags_3d_physics var visibility_mask := 0
@export_color_no_alpha var color := Color.WHITE
var blocked := false

func _init(_colmask: int = 0, _vismask: int = 0, _color := Color.WHITE):
	collision_mask = _colmask
	visibility_mask = _vismask
	color = _color
