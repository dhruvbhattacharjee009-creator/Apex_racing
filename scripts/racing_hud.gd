extends CanvasLayer
class_name ApexRacingHUD

var player: Node3D
var race_time := 0.0
var on_restart: Callable
var speed_label: Label
var time_label: Label

func _ready() -> void:
	_build_hud()

func _process(_delta: float) -> void:
	if is_instance_valid(player) and speed_label:
		speed_label.text = "%03d km/h" % int(abs(player.get("speed_kmh")))
	if time_label:
		time_label.text = _format_time(race_time)

func _build_hud() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(root)

	speed_label = Label.new()
	speed_label.text = "000 km/h"
	speed_label.position = Vector2(28, 24)
	speed_label.add_theme_font_size_override("font_size", 34)
	speed_label.add_theme_color_override("font_color", Color.WHITE)
	root.add_child(speed_label)

	time_label = Label.new()
	time_label.text = "00:00.000"
	time_label.position = Vector2(30, 68)
	time_label.add_theme_font_size_override("font_size", 22)
	time_label.add_theme_color_override("font_color", Color(0.85, 0.91, 1.0))
	root.add_child(time_label)

	var title := Label.new()
	title.text = "APEX  /  TEST CIRCUIT"
	title.anchor_left = 1.0
	title.anchor_right = 1.0
	title.offset_left = -300
	title.offset_right = -24
	title.offset_top = 26
	title.offset_bottom = 60
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(0.9, 0.94, 1.0))
	root.add_child(title)

	_add_hold_button(root, "◀", "steer_left", Vector2(24, -150), Vector2(100, 100), false)
	_add_hold_button(root, "▶", "steer_right", Vector2(136, -150), Vector2(100, 100), false)
	_add_hold_button(root, "BRAKE", "brake", Vector2(-240, -150), Vector2(100, 100), true)
	_add_hold_button(root, "THROTTLE", "accelerate", Vector2(-128, -150), Vector2(128, 100), true)

	var restart := Button.new()
	restart.text = "RESTART"
	restart.anchor_left = 1.0
	restart.anchor_right = 1.0
	restart.offset_left = -130
	restart.offset_right = -24
	restart.offset_top = 76
	restart.offset_bottom = 120
	restart.add_theme_font_size_override("font_size", 15)
	restart.pressed.connect(_restart_pressed)
	root.add_child(restart)

func _add_hold_button(root: Control, caption: String, action: StringName, offset: Vector2, size: Vector2, right_side: bool) -> void:
	var button := Button.new()
	button.text = caption
	button.anchor_left = 1.0 if right_side else 0.0
	button.anchor_right = 1.0 if right_side else 0.0
	button.anchor_top = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = offset.x
	button.offset_right = offset.x + size.x
	button.offset_top = offset.y
	button.offset_bottom = offset.y + size.y
	button.add_theme_font_size_override("font_size", 17)
	button.modulate = Color(1.0, 1.0, 1.0, 0.88)
	button.button_down.connect(func() -> void: Input.action_press(action))
	button.button_up.connect(func() -> void: Input.action_release(action))
	root.add_child(button)

func _restart_pressed() -> void:
	if on_restart.is_valid():
		on_restart.call()

func _format_time(value: float) -> String:
	var minutes := int(value / 60.0)
	var seconds := fmod(value, 60.0)
	return "%02d:%06.3f" % [minutes, seconds]
