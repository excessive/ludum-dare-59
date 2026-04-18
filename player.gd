extends CharacterBody3D

@export var walk_speed := 5.0
const JUMP_VELOCITY = 4.5

@onready var sensor := $sensor as Area3D
var current_channel: LidarChannel

func _ready() -> void:
	sensor.area_entered.connect(_on_area_entered)
	for node in get_tree().get_nodes_in_group(&"lose_trigger"):
		if node is Laser3D:
			node.collision_detected.connect(_on_laser_3d_collision_detected)

func _on_area_entered(area: Area3D):
	if not current_channel:
		return

	if (area.collision_layer & current_channel.collision_mask) == 0:
		return

	if area.is_in_group(&"lose_trigger"):
		print("you died")
		get_tree().call_deferred(&"reload_current_scene")
	if area.is_in_group(&"win_trigger"):
		print("you won but i have no win scene so do it again")
		get_tree().call_deferred(&"reload_current_scene")

func _on_lidar_channel_updated(channel: LidarChannel) -> void:
	collision_mask = channel.collision_mask
	collision_layer = channel.collision_mask
	current_channel = channel

func _physics_process(delta: float) -> void:
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
		get_tree().call_deferred(&"reload_current_scene")
