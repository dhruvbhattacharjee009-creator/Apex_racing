extends Camera3D

var target: Node3D
var follow_offset := Vector3(0.0, 5.2, 10.5)

func _ready() -> void:
	current = true
	set_process(true)

func _process(delta: float) -> void:
	if not is_instance_valid(target):
		return
	var desired := target.global_transform * Transform3D(Basis.IDENTITY, follow_offset)
	global_position = global_position.lerp(desired.origin, 1.0 - exp(-5.5 * delta))
	look_at(target.global_position + Vector3.UP * 0.85, Vector3.UP)
