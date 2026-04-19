extends AnimatableBody3D
class_name LidarTool

const LidarMesh = preload("res://scripts/lidar_mesh.gd")

@export var channels: Array[LidarChannel] = []
@export var alert_channels: Array[LidarChannel] = []

var current_channel := 0
@export_range(1, 25, 0.5) var lidar_range_active: float = 25.0
@export_range(1, 25, 0.5) var lidar_range_passive: float = 10.0
@export_range(1, 65536, 1, "prefer_slider") var lidar_max_count: int = 8192
@export_range(1, 100, 1, "prefer_slider") var lidar_ray_count_active: int = 15
@export_range(1, 100, 1, "prefer_slider") var lidar_ray_count_passive: int = 1
@export_range(1, 90, 0.5, "radians_as_degrees") var lidar_spread_active: float = PI/4
@export_range(1, 90, 0.5, "radians_as_degrees") var lidar_spread_passive: float = PI/2
@export_range(0, 1, 0.005) var lidar_drain_rate := 0.025
@export_range(0, 1, 0.005) var lidar_charge_rate := 0.05
@export_range(0, 10, 0.25) var lidar_charge_delay := 2.0
var lidar_charge := 1.0
var lidar_idle := 0.0

@export var sensor: Area3D
@export var player: PhysicsBody3D

signal charge_updated(level: float)
signal channel_updated(channel: LidarChannel)
signal channel_status_updated(channel: LidarChannel)

var meshes: Dictionary[LidarChannel, LidarMesh] = {}

func _ready() -> void:
	if channels.is_empty():
		return

	# register all the channels for UI, etc
	for channel in channels:
		var mesh := LidarMesh.new()
		add_child(mesh)
		meshes[channel] = mesh
		mesh.set_limit(lidar_max_count)
		mesh.set_channel(channel)
		mesh.global_position = Vector3.ZERO
		channel_status_updated.emit(channel)

	for channel in alert_channels:
		var mesh := LidarMesh.new()
		add_child(mesh)
		meshes[channel] = mesh
		mesh.set_limit(lidar_max_count)
		mesh.set_channel(channel)
		mesh.global_position = Vector3.ZERO

	current_channel = wrapi(current_channel, 0, channels.size())
	channel_updated.connect(_on_channel_changed)
	channel_updated.emit(channels[current_channel])

func _on_channel_changed(new_channel: LidarChannel):
	for channel in channels:
		var mesh := meshes[channel]
		mesh.hide()
	meshes[new_channel].show()
	#for mesh: LidarMesh in meshes.values():
		#mesh.clear()

func _record(channel: LidarChannel, pos: Vector3):
	meshes[channel].record(pos)

func _cycle_channel(offset: int) -> bool:
	var new_channel = wrapi(current_channel + offset, 0, channels.size())
	if channels[new_channel].blocked:
		#print("channel blocked, skipping")
		return false
	current_channel = new_channel
	channel_updated.emit(channels[current_channel])
	return true

func _try_cycle_channels(direction: int):
	for i in channels.size():
		if _cycle_channel((i+1) * signi(direction)):
			break

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"scan_channel_prev"):
		_try_cycle_channels(-1)
	if event.is_action_pressed(&"scan_channel_next"):
		_try_cycle_channels(1)

func _scan(channel: LidarChannel, active: bool):
	var dss := get_world_3d().direct_space_state
	var from := global_position
	var exclusions = [ get_rid() ]
	exclusions.append_array(get_collision_exceptions())
	var lidar_ray_count := lidar_ray_count_passive
	var lidar_spread := lidar_spread_passive
	var lidar_range := lidar_range_passive
	if active and not channel.haze:
		lidar_ray_count = lidar_ray_count_active
		lidar_spread = lidar_spread_active
		lidar_range = lidar_range_active
	elif channel.haze:
		lidar_ray_count = randi_range(0, lidar_ray_count)
		lidar_spread = PI
		lidar_range *= 4

	for i in lidar_ray_count:
		var r1 := randf_range(-lidar_spread/2, lidar_spread/2)
		var r2 := randf_range(0, TAU)
		var dir := global_basis.z.rotated(global_basis.y, r1).rotated(global_basis.z, r2)
		var to := from - dir * lidar_range
		var ray := PhysicsRayQueryParameters3D.create(from, to, channel.visibility_mask, exclusions)
		var hit := dss.intersect_ray(ray)
		if hit:
			var recpos: Vector3 = hit["position"]
			recpos += hit["normal"] * 0.01
			if channel.haze:
				recpos = from.lerp(recpos, 0.75).lerp(recpos, randf())
			_record(channel, recpos)
		elif channel.haze:
			var recpos := from.lerp(to, 0.25).lerp(to, randf())
			_record(channel, recpos)

func _check_channel_blocks():
	if not sensor:
		return

	var dss := get_world_3d().direct_space_state
	var exclusions := [
		get_rid(),
		player.get_rid()
	]

	for channel: LidarChannel in channels:
		var was_blocked = channel.blocked
		channel.blocked = false
		var offset := global_basis.z
		var ray_count := 16
		var ray_step := TAU/ray_count
		var ray_range := 2.5
		for i in ray_count:
			var from := global_position
			offset = offset.rotated(global_basis.y, ray_step)
			var to := from + offset * ray_range
			var rq := PhysicsRayQueryParameters3D.create(to, from, sensor.collision_mask, exclusions)
			rq.hit_from_inside = true
			rq.hit_back_faces = true
			var hit := dss.intersect_ray(rq)
			if hit:
				var body := hit["collider"] as Node3D
				if body is PhysicsBody3D or body is CSGShape3D:
					if (channel.collision_mask & body.collision_mask) != 0:
						#print("channel %s blocked by %s" % [channel, body])
						channel.blocked = true
						break

		if channel.blocked:
			if channel.blocked != was_blocked:
				channel_status_updated.emit(channel)
			continue

		var overlaps := sensor.get_overlapping_bodies()
		overlaps = overlaps.filter(func(body: Node3D):
			if body is not PhysicsBody3D and body is not CSGShape3D:
				return false
			if body is CharacterBody3D or body.is_in_group(&"player"):
				return false
			return (body.collision_mask & channel.collision_mask) != 0)
		for body in overlaps:
			#print("channel %s blocked by %s" % [channel, body])
			channel.blocked = true

		if channel.blocked != was_blocked:
			channel_status_updated.emit(channel)

func _scan_current(active: bool):
	_scan(channels[current_channel], active)
	for channel in alert_channels:
		_scan(channel, active)

func _physics_process(delta: float) -> void:
	if channels.is_empty():
		return
	current_channel = wrapi(current_channel, 0, channels.size())
	_check_channel_blocks()
	if Input.is_action_pressed(&"scan"):
		lidar_idle = 0
		if lidar_charge > 0:
			_scan_current(true)
			lidar_charge = maxf(0, lidar_charge - delta * lidar_drain_rate)
			charge_updated.emit(lidar_charge)
		pass
	else:
		_scan_current(false)
		lidar_idle = minf(lidar_charge_delay, lidar_idle + delta)
		if lidar_idle >= lidar_charge_delay:
			lidar_charge = minf(1, lidar_charge + delta * lidar_charge_rate)
			charge_updated.emit(lidar_charge)
