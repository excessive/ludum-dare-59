extends OmniLight3D
class_name FlickeringOmniLight3D

@export var pattern: String = "mmamammmmammamamaaamammma"
@export var speed: float = 10.0  # frames per second
@export var max_energy: float = 2.0  # maximum brightness
@export var offset: float = 0.0
@export var random_offset: float = 0.0

var _time := 0.0
var _frame := 0

func _ready() -> void:
	_time = offset + randf_range(0, random_offset)

func _process(delta: float) -> void:
	if pattern.is_empty():
		return

	_time += delta
	var interval := 1.0 / speed
	var limit = 100
	while _time >= interval and limit > 0:
		limit -= 1
		_time = _time - interval
		_frame = (_frame + 1) % pattern.length()
		var char = pattern[_frame]
		var value = clamp(char.unicode_at(0) - 'a'.unicode_at(0), 0, 25)
		self.omni_attenuation = max_energy * (value / 25.0)
