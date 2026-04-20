extends Node
class_name WaveChecker

@export var waves: Array[WaveSet]

signal alignment_changed(aligned: bool)

var was_aligned := false

func _ready() -> void:
	var timer := Timer.new()
	timer.autostart = true
	timer.timeout.connect(_check_alignment)
	_check_alignment()
	add_child(timer)

func _check_alignment():
	for wave in waves:
		if not wave.locked or not wave.is_aligned():
			if was_aligned:
				alignment_changed.emit(false)
			was_aligned = false
			return
	if not was_aligned:
		alignment_changed.emit(true)
	was_aligned = true
