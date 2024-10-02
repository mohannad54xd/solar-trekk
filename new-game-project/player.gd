extends RigidBody3D

var mouse_sens := 0.001
var twist_input := 0.0
var pitch_input := 0.0

@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")

	# Apply central force based on input
	apply_central_force(twist_pivot.basis * input * 1200.0 * delta)

	# Check if the left mouse button is pressed to toggle mouse mode
	if Input.is_action_just_pressed("BUTTON_LEFT"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Rotate camera based on input
	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)

	# Clamp the pitch rotation to prevent unnatural camera movement
	pitch_pivot.rotation.x = clamp(
		pitch_pivot.rotation.x,
		deg_to_rad(-30),  # Limit how far the player can look down
		deg_to_rad(30)    # Limit how far the player can look up
	)

	# Reset inputs after applying rotation
	twist_input = 0.0
	pitch_input = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Apply mouse movement for camera control
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -event.relative.x * mouse_sens
			pitch_input = -event.relative.y * mouse_sens
