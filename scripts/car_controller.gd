extends CharacterBody3D
class_name ApexCarController

const BASE_ACCELERATION := 23.0
const BRAKE_ACCELERATION := 38.0
const BASE_MAX_SPEED := 58.0
const REVERSE_SPEED := 12.0
const BASE_LATERAL_GRIP := 7.5
const GRAVITY := 22.0

var speed_kmh: float = 0.0
var steering_input: float = 0.0
var throttle_input: float = 0.0
var brake_input: float = 0.0
var spawn_transform: Transform3D
var car_profile: Dictionary = {}
var max_speed: float = BASE_MAX_SPEED
var engine_acceleration: float = BASE_ACCELERATION
var lateral_grip: float = BASE_LATERAL_GRIP
var visual_root: Node3D

func _ready() -> void:
	name = "PlayerCar"
	motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	floor_snap_length = 0.35
	floor_max_angle = deg_to_rad(48.0)
	_build_collision()
	apply_car_profile({"name": "APEX GP-01", "style": "formula", "paint": "#D71920", "accent": "#F4F4F4"})
	spawn_transform = global_transform

func apply_car_profile(profile: Dictionary) -> void:
	car_profile = profile.duplicate(true)
	max_speed = float(profile.get("top_speed", BASE_MAX_SPEED))
	engine_acceleration = float(profile.get("acceleration", BASE_ACCELERATION))
	lateral_grip = float(profile.get("grip", BASE_LATERAL_GRIP))
	if is_instance_valid(visual_root):
		visual_root.queue_free()
	visual_root = Node3D.new()
	visual_root.name = "CarVisuals"
	add_child(visual_root)
	_build_visual()

func _physics_process(delta: float) -> void:
	throttle_input = Input.get_action_strength("accelerate")
	brake_input = Input.get_action_strength("brake")
	steering_input = Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")
	var forward := -global_transform.basis.z
	var right := global_transform.basis.x
	var forward_speed: float = velocity.dot(forward)
	if throttle_input > 0.0:
		velocity += forward * engine_acceleration * throttle_input * delta
	if brake_input > 0.0:
		if forward_speed > 1.0:
			velocity -= forward * minf(BRAKE_ACCELERATION * brake_input * delta, forward_speed)
		else:
			velocity -= forward * engine_acceleration * 0.55 * brake_input * delta
	if Input.is_action_pressed("handbrake"):
		velocity -= right * velocity.dot(right) * minf(12.0 * delta, 1.0)
	var steering_speed_factor: float = clampf(absf(forward_speed) / 12.0, 0.18, 1.0)
	var speed_limiter: float = 1.0 - clampf(absf(forward_speed) / max_speed, 0.0, 0.72)
	if absf(forward_speed) > 0.8:
		rotate_y(-steering_input * 1.75 * steering_speed_factor * speed_limiter * signf(forward_speed) * delta)
	forward = -global_transform.basis.z
	right = global_transform.basis.x
	var lateral_speed: float = velocity.dot(right)
	velocity -= right * lateral_speed * minf(lateral_grip * delta, 0.92)
	var longitudinal_speed: float = velocity.dot(forward)
	if longitudinal_speed > max_speed:
		velocity -= forward * (longitudinal_speed - max_speed)
	if longitudinal_speed < -REVERSE_SPEED:
		velocity -= forward * (longitudinal_speed + REVERSE_SPEED)
	velocity -= velocity * minf(0.32 * delta, 0.08)
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = -0.15
	move_and_slide()
	speed_kmh = velocity.dot(-global_transform.basis.z) * 3.6
	if global_position.y < -8.0:
		reset_car()

func reset_car() -> void:
	global_transform = spawn_transform
	velocity = Vector3.ZERO
	speed_kmh = 0.0

func _build_collision() -> void:
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.8, 0.9, 4.0)
	collision.shape = shape
	collision.position.y = 0.55
	add_child(collision)

func _material(hex: String, metallic: float = 0.25) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color.from_string(hex, Color.WHITE)
	material.metallic = metallic
	material.roughness = 0.3
	return material

func _box(size: Vector3, pos: Vector3, material: Material, parent: Node3D = null) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	item.mesh = mesh
	item.position = pos
	item.material_override = material
	(parent if parent != null else visual_root).add_child(item)
	return item

func _build_visual() -> void:
	var paint := _material(str(car_profile.get("paint", "#D71920")), 0.48)
	var accent := _material(str(car_profile.get("accent", "#F4F4F4")), 0.32)
	var dark := _material("#10151D", 0.18)
	var glass := _material("#18384B", 0.62)
	var rubber := _material("#17191D", 0.0)
	var is_gt3 := str(car_profile.get("style", "formula")) == "gt3"

	if is_gt3:
		_build_gt3_body(paint, accent, dark, glass)
		_build_wheels(rubber, 1.08, 1.42, 0.43, 0.34)
	else:
		_build_formula_body(paint, accent, dark, glass)
		_build_wheels(rubber, 0.91, 1.25, 0.39, 0.27)

func _build_formula_body(paint: Material, accent: Material, dark: Material, glass: Material) -> void:
	_box(Vector3(1.28, 0.38, 3.35), Vector3(0.0, 0.66, 0.05), paint)
	_box(Vector3(0.72, 0.20, 1.65), Vector3(0.0, 0.68, -2.05), paint)
	_box(Vector3(0.82, 0.22, 0.86), Vector3(0.0, 0.83, -0.35), glass)
	_box(Vector3(0.18, 0.10, 2.5), Vector3(0.0, 0.89, -0.15), accent)
	_box(Vector3(2.25, 0.13, 0.48), Vector3(0.0, 0.43, -2.35), dark)
	_box(Vector3(2.05, 0.12, 0.42), Vector3(0.0, 1.10, 1.73), dark)
	_box(Vector3(1.72, 0.10, 0.34), Vector3(0.0, 0.95, 1.70), accent)
	_box(Vector3(0.16, 0.48, 0.14), Vector3(-0.55, 0.79, 1.52), dark)
	_box(Vector3(0.16, 0.48, 0.14), Vector3(0.55, 0.79, 1.52), dark)

func _build_gt3_body(paint: Material, accent: Material, dark: Material, glass: Material) -> void:
	_box(Vector3(2.02, 0.52, 4.05), Vector3(0.0, 0.72, 0.0), paint)
	_box(Vector3(1.46, 0.52, 1.55), Vector3(0.0, 1.12, -0.25), glass)
	_box(Vector3(1.92, 0.18, 1.15), Vector3(0.0, 0.97, -1.55), paint)
	_box(Vector3(1.92, 0.18, 0.95), Vector3(0.0, 0.97, 1.45), paint)
	_box(Vector3(2.18, 0.18, 0.42), Vector3(0.0, 1.25, 1.93), dark)
	_box(Vector3(0.14, 0.48, 0.14), Vector3(-0.72, 0.99, 1.73), dark)
	_box(Vector3(0.14, 0.48, 0.14), Vector3(0.72, 0.99, 1.73), dark)
	_box(Vector3(1.55, 0.09, 0.16), Vector3(0.0, 0.91, -2.05), accent)
	_box(Vector3(0.12, 0.12, 0.58), Vector3(-0.78, 0.79, -1.82), accent)
	_box(Vector3(0.12, 0.12, 0.58), Vector3(0.78, 0.79, -1.82), accent)
	_box(Vector3(1.45, 0.08, 0.15), Vector3(0.0, 1.39, 1.92), accent)

func _build_wheels(rubber: Material, x_offset: float, z_offset: float, radius: float, width: float) -> void:
	for x in [-x_offset, x_offset]:
		for z in [-z_offset, z_offset]:
			var wheel := MeshInstance3D.new()
			var mesh := CylinderMesh.new()
			mesh.top_radius = radius
			mesh.bottom_radius = radius
			mesh.height = width
			mesh.radial_segments = 20
			wheel.mesh = mesh
			wheel.rotation.z = PI / 2.0
			wheel.position = Vector3(x, 0.43, z)
			wheel.material_override = rubber
			visual_root.add_child(wheel)
			var hub := MeshInstance3D.new()
			var hub_mesh := CylinderMesh.new()
			hub_mesh.top_radius = radius * 0.38
			hub_mesh.bottom_radius = radius * 0.38
			hub_mesh.height = width + 0.015
			hub_mesh.radial_segments = 16
			hub.mesh = hub_mesh
			hub.rotation.z = PI / 2.0
			hub.position = Vector3(x, 0.43, z)
			hub.material_override = _material("#AEB8C2", 0.72)
			visual_root.add_child(hub)
