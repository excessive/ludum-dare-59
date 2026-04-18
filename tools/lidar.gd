extends AnimatableBody3D
class_name LidarTool

const LidarMesh = preload("res://tools/lidar_mesh.gd")

@export var channels: Array[LidarChannel] = []
var current_channel := 0
@export_range(1, 25, 0.5) var lidar_range: float = 15.0
@export_range(1, 100, 1, "prefer_slider") var lidar_ray_count: int = 10
@export_range(1, 65536, 1, "prefer_slider") var lidar_max_count: int = 16384
@export_range(1, 90, 0.5, "radians_as_degrees") var lidar_spread: float = PI/4
@export_range(0, 1, 0.005) var lidar_drain_rate := 0.025
@export_range(0, 1, 0.005) var lidar_charge_rate := 0.05
@export_range(0, 10, 0.25) var lidar_charge_delay := 2.0
var lidar_charge := 1.0
var lidar_idle := 0.0

var mesh := LidarMesh.new()

signal charge_updated(level: float)

func _ready() -> void:
	add_child(mesh)
	mesh.set_limit(lidar_max_count)
	mesh.global_position = Vector3.ZERO

	if channels.is_empty():
		return
	current_channel = wrapi(current_channel, 0, channels.size())
	mesh.change_channel(channels[current_channel])

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"scan_channel_prev"):
		current_channel = wrapi(current_channel - 1, 0, channels.size())
		mesh.change_channel(channels[current_channel])
	if event.is_action_pressed(&"scan_channel_next"):
		current_channel = wrapi(current_channel + 1, 0, channels.size())
		mesh.change_channel(channels[current_channel])

func _scan():
	var channel := channels[current_channel]
	var dss := get_world_3d().direct_space_state
	var from := global_position
	var exclusions = [ get_rid() ]
	exclusions.append_array(get_collision_exceptions())
	for i in lidar_ray_count:
		var r1 := randf_range(-lidar_spread/2, lidar_spread/2)
		var r2 := randf_range(0, TAU)
		var dir := global_basis.z.rotated(global_basis.y, r1).rotated(global_basis.z, r2)
		var to := from - dir * lidar_range
		var ray := PhysicsRayQueryParameters3D.create(from, to, channel.visibility_mask, exclusions)
		var hit := dss.intersect_ray(ray)
		if hit:
			mesh.record(hit["position"])

func _physics_process(delta: float) -> void:
	if channels.is_empty():
		return

	current_channel = wrapi(current_channel, 0, channels.size())
	if Input.is_action_pressed(&"scan_forward"):
		lidar_idle = 0
		if lidar_charge > 0:
			_scan()
			lidar_charge = maxf(0, lidar_charge - delta * lidar_drain_rate)
			charge_updated.emit(lidar_charge)
		pass
	else:
		lidar_idle = minf(lidar_charge_delay, lidar_idle + delta)
		if lidar_idle >= lidar_charge_delay:
			lidar_charge = minf(1, lidar_charge + delta * lidar_charge_rate)
			charge_updated.emit(lidar_charge)
