@tool
extends Resource
class_name PlayerState

var checkpoints_visited: Dictionary = {}
var waves_synced: Dictionary = {}

var latest_checkpoint_path: NodePath = ""
# fallback
var latest_checkpoint_position := Vector3.ZERO

var reset_count: int = 0
var death_count: int = 0
var oob_count: int = 0

var game_time: float = 0

func checkpoint(node: Node3D) -> bool:
	latest_checkpoint_path = node.get_path()
	latest_checkpoint_position = node.global_position
	if not checkpoints_visited.has(latest_checkpoint_path):
		checkpoints_visited[latest_checkpoint_path] = true
		print("new checkpoint recorded")
		return true
	return false

func wavesync(wave: WaveSet) -> bool:
	if not waves_synced.has(wave.resource_scene_unique_id):
		Hoarder.keep_loaded(wave)
		waves_synced[wave.resource_scene_unique_id] = true
		print("sync recorded")
		return true
	return false

func update(delta: float):
	game_time += delta

func reset():
	waves_synced.clear()
	checkpoints_visited.clear()
	latest_checkpoint_path = ""
	latest_checkpoint_position = Vector3.ZERO
	reset_count = 0
	death_count = 0
	oob_count = 0
	game_time = 0
