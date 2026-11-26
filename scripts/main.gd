extends Node3D

const TrackBuilder = preload("res://scripts/track_builder.gd")
const CarController = preload("res://scripts/car_controller.gd")
const FollowCamera = preload("res://scripts/follow_camera.gd")
const RacingHUD = preload("res://scripts/racing_hud.gd")
const CarCatalog = preload("res://scripts/car_catalog.gd")

var player: CharacterBody3D
var hud: CanvasLayer
var race_time := 0.0
var selected_car_index := 0

func _ready() -> void:
	_setup_input_map()
	_create_environment()
	var track := TrackBuilder.new()
	add_child(track)
	track.build()
	player = CarController.new()
	player.position = Vector3(65.0, 0.0, -6.0)
	player.rotation.y = PI
	add_child(player)
	player.apply_car_profile(CarCatalog.CARS[selected_car_index])
	var camera := Camera3D.new()
	camera.name = "ChaseCamera"
	camera.current = true
	camera.fov = 72.0
	camera.set_script(FollowCamera)
	camera.set("target", player)
	player.add_child(camera)
	hud = RacingHUD.new()
	add_child(hud)
	hud.set("player", player)
	hud.set("on_restart", Callable(self, "_restart_race"))
	hud.set("on_next_car", Callable(self, "_next_car"))
	hud.set("selected_car_name", str(CarCatalog.CARS[selected_car_index].get("name", "APEX GP-01")))

func _physics_process(delta: float) -> void:
	race_time += delta
	if is_instance_valid(hud):
		hud.set("race_time", race_time)

func _create_environment() -> void:
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.43, 0.66, 0.82)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.72, 0.78, 0.86)
	environment.ambient_light_energy = 0.8
	world.environment = environment
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52.0, -28.0, 0.0)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	add_child(sun)

	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(320.0, 260.0)
	ground.mesh = plane
	ground.position.y = -0.42
	var grass := StandardMaterial3D.new()
	grass.albedo_color = Color(0.12, 0.27, 0.17)
	grass.roughness = 1.0
	ground.material_override = grass
	add_child(ground)

	var ground_body := StaticBody3D.new()
	ground_body.position.y = -0.55
	var ground_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(320.0, 0.3, 260.0)
	ground_shape.shape = box
	ground_body.add_child(ground_shape)
	add_child(ground_body)

func _setup_input_map() -> void:
	_add_key_action("accelerate", KEY_W)
	_add_key_action("accelerate", KEY_UP)
	_add_key_action("brake", KEY_S)
	_add_key_action("brake", KEY_DOWN)
	_add_key_action("steer_left", KEY_A)
	_add_key_action("steer_left", KEY_LEFT)
	_add_key_action("steer_right", KEY_D)
	_add_key_action("steer_right", KEY_RIGHT)
	_add_key_action("handbrake", KEY_SPACE)
	_add_key_action("restart", KEY_R)

func _add_key_action(action: StringName, key: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var event := InputEventKey.new()
	event.physical_keycode = key
	InputMap.action_add_event(action, event)

func _next_car() -> void:
	selected_car_index = (selected_car_index + 1) % CarCatalog.CARS.size()
	var profile: Dictionary = CarCatalog.CARS[selected_car_index]
	if is_instance_valid(player):
		player.apply_car_profile(profile)
		player.reset_car()
	if is_instance_valid(hud):
		hud.set("selected_car_name", str(profile.get("name", "APEX CAR")))

func _restart_race() -> void:
	if is_instance_valid(player):
		player.reset_car()
	race_time = 0.0
	if is_instance_valid(hud):
		hud.set("race_time", race_time)
