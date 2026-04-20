@tool
extends Resource
class_name WaveSet

const ALIGNMENT_THRESHOLD := 0.00001

@export var state: WaveParams
@export var target: WaveParams
var locked := false

func _init(_state := WaveParams.new(), _target := WaveParams.new()):
	state = _state
	target = _target

func is_aligned() -> bool:
	var err := absf(1.0 - target.wave_alignment(state))
	#print(err)
	return err < ALIGNMENT_THRESHOLD
