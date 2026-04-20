@tool
extends Resource
class_name WaveParams

@export_range(-1, 1, 0.25) var offset := 0.0
@export_range(-1, 1, 0.25) var phase := 0.0
@export_range(-1, 1, 0.25) var gain := 0.0
@export_range(8, 128, 8) var frequency := 24.0
@export_range(0, 1, 0.01) var alignment := 1.0
@export_range(-1, 1, 0.05) var drift := -0.75

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
	# make sure *NOT* to correctly line up the phase, or +/- 1 phase will make the alignment check "fail"
	# despite the waves being in sync
	return lerpf(noise_val, sin(t * frequency - phase * (PI - PI/8)) * (1.0 + gain) - offset, clampf(alignment, 0, 1))

func domain_scale(target: Vector2, samples: int) -> Vector2:
	return Vector2(target.x / samples, target.y / 2)

static func wave_dot(a: WaveParams, b: WaveParams) -> float:
	var dp := 0.0
	dp += (1.0 + a.offset) * (1.0 + b.offset)
	dp += (1.0 + a.phase) * (1.0 + b.phase)
	dp += (1.0 + a.gain) * (1.0 + b.gain)
	dp += (a.frequency / 440.0) * (b.frequency / 440.0)
	#dp += a.alignment * b.alignment # ignore
	dp += a.drift * b.drift
	return dp

func wave_alignment(other: WaveParams) -> float:
	var norma := absf(wave_dot(self, self))
	var normb := absf(wave_dot(other, other))
	var norm := maxf(norma, normb)
	#print(norm)
	if not norm:
		return 0.0
	return absf(wave_dot(self, other)) / norm
