extends Node3D
class_name ApexTrackBuilder

const SEGMENTS := 112
const RADIUS_X := 65.0
const RADIUS_Z := 42.0
const ROAD_WIDTH := 13.0

func build() -> void:
	name = "APEX_Test_Circuit"
	_build_road_mesh()
	_build_track_collisions()
	_build_barriers()
	_build_start_finish()

func _centerline(t: float) -> Vector3:
	return Vector3(RADIUS_X * cos(t), 0.0, RADIUS_Z * sin(t))

func _build_road_mesh() -> void:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var indices := PackedInt32Array()
	var half_width := ROAD_WIDTH * 0.5
	for i in range(SEGMENTS + 1):
		var t := TAU * float(i) / float(SEGMENTS)
		var point := _centerline(t)
		var tangent := (_centerline(t + 0.01) - _centerline(t - 0.01)).normalized()
		var side := Vector3(-tangent.z, 0.0, tangent.x)
		vertices.append(point + side * half_width + Vector3.UP * 0.12)
		vertices.append(point - side * half_width + Vector3.UP * 0.12)
		normals.append(Vector3.UP)
		normals.append(Vector3.UP)
	for i in range(SEGMENTS):
		var a := i * 2
		var b := a + 1
		var c := a + 2
		var d := a + 3
		indices.append_array(PackedInt32Array([a, b, c, b, d, c]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var road := MeshInstance3D.new()
	road.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.105, 0.115, 0.13)
	material.roughness = 0.94
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	road.material_override = material
	add_child(road)

func _build_track_collisions() -> void:
	for i in range(SEGMENTS):
		var t0 := TAU * float(i) / float(SEGMENTS)
		var t1 := TAU * float(i + 1) / float(SEGMENTS)
		var p0 := _centerline(t0)
		var p1 := _centerline(t1)
		var midpoint := (p0 + p1) * 0.5
		var direction := (p1 - p0).normalized()
		var length := p0.distance_to(p1) + 0.35
		var road_body := StaticBody3D.new()
		road_body.position = midpoint
		road_body.rotation.y = atan2(-direction.x, -direction.z)
		var road_shape := CollisionShape3D.new()
		var road_box := BoxShape3D.new()
		road_box.size = Vector3(ROAD_WIDTH, 0.32, length)
		road_shape.shape = road_box
		road_shape.position.y = -0.04
		road_body.add_child(road_shape)
		add_child(road_body)

func _build_barriers() -> void:
	var half_width := ROAD_WIDTH * 0.5 + 1.0
	var barrier_materials: Array[Material] = []
	for color in [Color(0.82, 0.84, 0.86), Color(0.85, 0.08, 0.07)]:
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		barrier_materials.append(material)
	for side_sign in [-1.0, 1.0]:
		for i in range(SEGMENTS):
			var t0 := TAU * float(i) / float(SEGMENTS)
			var t1 := TAU * float(i + 1) / float(SEGMENTS)
			var p0 := _centerline(t0)
			var p1 := _centerline(t1)
			var midpoint := (p0 + p1) * 0.5
			var direction := (p1 - p0).normalized()
			var side := Vector3(-direction.z, 0.0, direction.x)
			var barrier := StaticBody3D.new()
			barrier.position = midpoint + side * half_width * side_sign + Vector3.UP * 0.72
			barrier.rotation.y = atan2(-direction.x, -direction.z)
			var shape_node := CollisionShape3D.new()
			var shape := BoxShape3D.new()
			shape.size = Vector3(0.65, 1.45, p0.distance_to(p1) + 0.5)
			shape_node.shape = shape
			barrier.add_child(shape_node)
			add_child(barrier)
			var visual := MeshInstance3D.new()
			var mesh := BoxMesh.new()
			mesh.size = shape.size
			visual.mesh = mesh
			visual.material_override = barrier_materials[i % 2]
			barrier.add_child(visual)

func _build_start_finish() -> void:
	var line := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(ROAD_WIDTH - 0.8, 0.025, 0.9)
	line.mesh = mesh
	line.position = Vector3(RADIUS_X, 0.29, 0.0)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.92, 0.92, 0.92)
	line.material_override = material
	add_child(line)
