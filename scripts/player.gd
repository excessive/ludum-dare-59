extends CharacterBody3D

@export_file_path("*.tscn") var reboot_scene: String
@export var walk_speed := 5.0
const JUMP_VELOCITY = 4.5

@export var tool_state: ToolState
@onready var sensor := $sensor as Area3D
var current_channel: LidarChannel

@export var player_state: PlayerState

func _ready() -> void:
	Hoarder.keep_loaded(player_state)

	sensor.area_entered.connect(_on_area_entered)
	for node in get_tree().get_nodes_in_group(&"lose_trigger"):
		if node is Laser3D:
			node.collision_detected.connect(_on_laser_3d_collision_detected)

	respawn.connect(_on_respawn)
	call_deferred(&"_on_respawn", global_transform)

signal respawn(respawn_target: Transform3D)

func _on_respawn(respawn_target: Transform3D):
	if !is_inside_tree():
		return
	if not player_state.checkpoints_visited.is_empty():
		var checkpoint = get_node_or_null(player_state.latest_checkpoint_path)
		if checkpoint is Node3D:
			global_position = checkpoint.global_position
			global_basis = checkpoint.global_basis.orthonormalized()
		else:
			global_position = player_state.latest_checkpoint_position
			global_basis = Basis.IDENTITY
		print("respawn %s (%s)" % [global_position, checkpoint])
	else:
		global_transform = respawn_target
	reset_physics_interpolation()
	velocity *= 0

func _on_area_entered(area: Area3D):
	if not current_channel:
		return

	if (area.collision_layer & current_channel.collision_mask) == 0:
		return

	if area.is_in_group(&"lose_trigger"):
		print("you died")
		player_state.death_count += 1
		_reboot()
	if area.is_in_group(&"win_trigger"):
		print("you won but i have no win scene so do it again")
		print("completion time %ss (%d resets %d deaths, %d oobs)" % [
			player_state.game_time,
			player_state.reset_count,
			player_state.death_count,
			player_state.oob_count,
		])
		player_state.reset()
		_reboot()

func _reboot() -> void:
	await get_tree().process_frame
	get_tree().change_scene_to_file(reboot_scene)

func _on_lidar_channel_updated(channel: LidarChannel) -> void:
	collision_mask = channel.collision_mask
	collision_layer = channel.collision_mask
	current_channel = channel

func _physics_process(delta: float) -> void:
	player_state.update(delta)
	tool_state.update(delta)

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var cam := get_viewport().get_camera_3d()
	if not cam:
		return

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (cam.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * walk_speed
		velocity.z = direction.z * walk_speed
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)
		velocity.z = move_toward(velocity.z, 0, walk_speed)

	move_and_slide()

func _on_laser_3d_collision_detected(_collision_result: LaserResult) -> void:
	if _collision_result.collider == self:
		print("you died")
		_reboot()
