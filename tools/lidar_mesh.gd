extends MeshInstance3D

var material := StandardMaterial3D.new()
var scanmesh := ArrayMesh.new()
var scanpoints := PackedVector3Array()
var scancursor := 0
var scancount := 0
var need_update := false

func set_limit(limit: int):
	scanpoints.resize(limit)

func clear():
	scancursor = 0
	scancount = 0
	need_update = false
	scanmesh.clear_surfaces()

func set_channel(channel: LidarChannel):
	if channel.haze:
		set_limit(32)
	layers = channel.visibility_mask
	material.albedo_color = Color.BLACK
	material.emission = channel.color

func record(world_point: Vector3):
	scancursor = wrapi(scancursor + 1, 0, scanpoints.size())
	scancount = mini(scancount + 1, scanpoints.size() - 1)
	scanpoints[scancursor] = world_point
	need_update = true

func _init() -> void:
	set_limit(1024)

func _ready() -> void:
	mesh = scanmesh
	top_level = true

	material.emission_enabled = true
	material.emission_energy_multiplier = 3
	material.point_size = 4
	material.distance_fade_mode = BaseMaterial3D.DISTANCE_FADE_PIXEL_DITHER
	#material.no_depth_test = true
	material.distance_fade_min_distance = 30
	material.distance_fade_max_distance = 15
	material.use_point_size = true
	material_override = material

func _physics_process(_delta: float) -> void:
	if need_update:
		need_update = false

		var arrays = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = scanpoints.slice(0, scancount)

		scanmesh.clear_surfaces()
		scanmesh.add_surface_from_arrays(Mesh.PRIMITIVE_POINTS, arrays)
