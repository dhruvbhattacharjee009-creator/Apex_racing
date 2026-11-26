extends CharacterBody3D
class_name ApexCarController

const ENGINE_ACCELERATION := 23.0
const BRAKE_ACCELERATION := 38.0
const MAX_SPEED := 58.0
const REVERSE_SPEED := 12.0
const LATERAL_GRIP := 7.5
const GRAVITY := 22.0

var speed_kmh := 0.0
var steering_input := 0.0
var throttle_input := 0.0
var brake_input := 0.0
var spawn_transform: Transform3D

func _ready() -> void:
	name = "PlayerCar"
	motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	floor_snap_length = 0.35
	floor_max_angle = deg_to_rad(48.0)
	_build_collision()
	_build_visual()
	spawn_transform = global_transform

func _physics_process(delta: float) -> void:
	throttle_input = Input.get_action_strength("accelerate")
	brake_input = Input.get_action_strength("brake")
	steering_input = Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")
	var forward := -global_transform.basis.z
	var right := global_transform.basis.x
	var forward_speed := velocity.dot(forward)
	if throttle_input > 0.0:
		velocity += forward * ENGINE_ACCELERATION * throttle_input * delta
	if brake_input > 0.0:
		if forward_speed > 1.0:
			velocity -= forward * min(BRAKE_ACCELERATION * brake_input * delta, forward_speed)
		else:
			velocity -= forward * ENGINE_ACCELERATION * 0.55 * brake_input * delta
	if Input.is_action_pressed("handbrake"):
		velocity -= right * velocity.dot(right) * min(12.0 * delta, 1.0)
	var steering_speed_factor := clamp(abs(forward_speed) / 12.0, 0.18, 1.0)
	var speed_limiter := 1.0 - clamp(abs(forward_speed) / MAX_SPEED, 0.0, 0.72)
	if abs(forward_speed) > 0.8:
		rotate_y(-steering_input * 1.75 * steering_speed_factor * speed_limiter * sign(forward_speed) * delta)
	forward = -global_transform.basis.z
	right = global_transform.basis.x
	var lateral_speed := velocity.dot(right)
	velocity -= right * lateral_speed * min(LATERAL_GRIP * delta, 0.92)
	var longitudinal_speed := velocity.dot(forward)
	if longitudinal_speed > MAX_SPEED:
		velocity -= forward * (longitudinal_speed - MAX_SPEED)
	if longitudinal_speed < -REVERSE_SPEED:
		velocity -= forward * (longitudinal_speed + REVERSE_SPEED)
	velocity -= velocity * min(0.32 * delta, 0.08)
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
	shape.size = Vector3(1.65, 0.85, 3.8)
	collision.shape = shape
	collision.position.y = 0.55
	add_child(collision)

func _build_visual() -> void:
	var body_material := StandardMaterial3D.new()
	body_material.albedo_color = Color(0.82, 0.035, 0.055)
	body_material.metallic = 0.45
	body_material.roughness = 0.28
	var dark_material := StandardMaterial3D.new()
	dark_material.albedo_color = Color(0.035, 0.045, 0.06)
	dark_material.metallic = 0.25
	var glass_material := StandardMaterial3D.new()
	glass_material.albedo_color = Color(0.08, 0.19, 0.25)
	glass_material.metallic = 0.55
	glass_material.roughness = 0.18

	var chassis := MeshInstance3D.new()
	var chassis_mesh := BoxMesh.new()
	chassis_mesh.size = Vector3(1.75, 0.48, 3.8)
	chassis.mesh = chassis_mesh
	chassis.position.y = 0.68
	chassis.material_override = body_material
	add_child(chassis)

	var nose := MeshInstance3D.new()
	var nose_mesh := BoxMesh.new()
	nose_mesh.size = Vector3(1.15, 0.22, 1.5)
	nose.mesh = nose_mesh
	nose.position = Vector3(0.0, 0.73, -2.25)
	nose.material_override = body_material
	add_child(nose)

	var cockpit := MeshInstance3D.new()
	var cockpit_mesh := BoxMesh.new()
	cockpit_mesh.size = Vector3(1.05, 0.42, 1.25)
	cockpit.mesh = cockpit_mesh
	cockpit.position = Vector3(0.0, 1.08, -0.15)
	cockpit.material_override = glass_material
	add_child(cockpit)

	for x in [-0.98, 0.98]:
		for z in [-1.22, 1.22]:
			var wheel := MeshInstance3D.new()
			var wheel_mesh := CylinderMesh.new()
			wheel_mesh.top_radius = 0.39
			wheel_mesh.bottom_radius = 0.39
			wheel_mesh.height = 0.28
			wheel_mesh.radial_segments = 16
			wheel.mesh = wheel_mesh
			wheel.rotation.z = PI / 2.0
			wheel.position = Vector3(x, 0.42, z)
			wheel.material_override = dark_material
			add_child(wheel)

	var rear_wing := MeshInstance3D.new()
	var wing_mesh := BoxMesh.new()
	wing_mesh.size = Vector3(2.0, 0.12, 0.42)
	rear_wing.mesh = wing_mesh
	rear_wing.position = Vector3(0.0, 1.1, 1.72)
	rear_wing.material_override = dark_material
	add_child(rear_wing)
