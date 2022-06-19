extends KinematicBody
##################################
# new control code
##################################
export var max_speed = 50
# model faces backwards
export var acceleration = -0.6
export var pitch_speed = 1.5
export var roll_speed = 1.9
export var yaw_speed = 1.25  # Set lower for linked roll/yaw
export var input_response = 8.0

var velocity = Vector3.ZERO
var forward_speed = 0
var pitch_input = 0
var roll_input = 0
var yaw_input = 0

var is_drift = false


var horiz_speed = 0
var vert_speed = 0
##################################
# old control code
##################################
var MOUSE_SENSITIVITY = 0.05
var camera
var rotation_helper

func _ready():
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper

func get_input(delta):
	
	# capturing/freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode((Input.MOUSE_MODE_VISIBLE))

	# https://kidscancode.org/godot_recipes/3d/spaceship/
	if Input.is_action_pressed("throttle_up"):
		forward_speed = lerp(forward_speed,
			Input.get_action_strength("throttle_up")*100,
			acceleration * delta)
			
	if Input.is_action_pressed("throttle_down"):
		forward_speed = lerp(forward_speed,
			-Input.get_action_strength("throttle_down")*50,
			acceleration * delta)
			
	is_drift = Input.is_action_pressed("drift")
	

	pitch_input = lerp(pitch_input,
			Input.get_action_strength("pitch_down") - Input.get_action_strength("pitch_up"),
			input_response * delta)
			
	roll_input = lerp(roll_input,
			Input.get_action_strength("roll_left") - Input.get_action_strength("roll_right"),
			input_response * delta)
			
	yaw_input = lerp(yaw_input,
			Input.get_action_strength("yaw_left") - Input.get_action_strength("yaw_right"),
			input_response * delta)

	# saggital plane
	horiz_speed = lerp(horiz_speed,
			Input.get_action_strength("horiz_left")*50 - Input.get_action_strength("horiz_right")*50,
			input_response * delta)

	vert_speed = lerp(vert_speed,
			Input.get_action_strength("vert_up")*50 - Input.get_action_strength("vert_down")*50,
			input_response * delta)
	
	

func _physics_process(delta):
	get_input(delta)
	
	transform.basis = transform.basis.rotated(transform.basis.z, roll_input * roll_speed * delta)
	transform.basis = transform.basis.rotated(transform.basis.x, pitch_input * pitch_speed * delta)
	transform.basis = transform.basis.rotated(transform.basis.y, yaw_input * yaw_speed * delta)
	
	transform.basis = transform.basis.orthonormalized()

	if !is_drift:
		velocity = -transform.basis.z * forward_speed + transform.basis.y * vert_speed + transform.basis.x * horiz_speed
	
	
	
	$HUD/Panel/Gun_label.text= "Velocity:" + str(-1 * int(forward_speed * 10))
	
	move_and_collide(velocity * delta)
