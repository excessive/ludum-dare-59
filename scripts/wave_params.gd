@tool
extends Resource
class_name WaveParams

@export_range(-1, 1, 0.01) var offset := 0.0
@export_range(0, TAU, 0.01) var phase := 0.0
@export_range(-1, 1, 0.01) var gain := 0.0
@export_range(1, 440, 0.5) var frequency := 24.0
@export_range(0, 1, 0.01) var alignment := 1.0
@export_range(-1, 1, 0.01) var drift := -0.75

func _init(
	_offset := offset,
	_phase := phase,
	_gain := gain,
	_frequency := frequency,
	_alignment := alignment,
	_drift := drift,
) -> void:
	offset = _offset
	phase = _phase
	gain = _gain
	frequency = _frequency
	alignment = _alignment
	drift = _drift

func evaluate(t: float) -> float:
	var noise_val := randfn(0, 1)
	return lerpf(noise_val, sin(t * frequency - phase) * (1.0 + gain) - offset, clampf(alignment, 0, 1))

func domain_scale(target: Vector2, samples: int) -> Vector2:
	return Vector2(target.x / samples, target.y / 2)

static func wave_dot(a: WaveParams, b: WaveParams) -> float:
	var dp := 0.0
	dp += a.offset * b.offset
	dp += a.phase * b.phase
	dp += a.gain * b.gain
	dp += (a.frequency / 440) * (b.frequency / 440)
	#dp += a.alignment * b.alignment # ignore
	dp += a.drift * b.drift
	return dp

func wave_alignment(other: WaveParams) -> float:
	var norm := wave_dot(self, self)
	if not norm:
		return 0.0
	return wave_dot(self, other) / norm
