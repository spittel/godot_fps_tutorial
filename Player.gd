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

var old_forward_speed = 0

##################################
# old control code
##################################
var MOUSE_SENSITIVITY = 0.05
var camera
var rotation_helper
#var dir = Vector3()
var vel = Vector3()

const MAX_SPEED = 30
const ACCEL = 3
const DEACCELL = 0.5
const MAX_SLOPE_ANGLE = 100

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
			
#		old_forward_speed = lerp(old_forward_speed, max_speed, acceleration * delta)
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

	
	# Godot FPS tutorial
#	var input_movement_vector = Vector3()
#
#	if Input.is_action_pressed("movement_left"):
#		input_movement_vector.x -=1
#	if Input.is_action_pressed("movement_right"):
#		input_movement_vector.x +=1
#	# Ascend/descend
#	if Input.is_action_pressed("movement_jump"):
#		input_movement_vector.z +=1
#	if Input.is_action_pressed("movement_descend"):
#		input_movement_vector.z -=1
#
#	input_movement_vector = input_movement_vector.normalized()

#	dir = Vector3()
#	var cam_xform = camera.get_global_transform()
	# Basis vectors are already normalized
#	dir += -cam_xform.basis.z * input_movement_vector.y
#	dir += cam_xform.basis.x * input_movement_vector.x
#	dir += cam_xform.basis.y * input_movement_vector.z
		


func _physics_process(delta):
	get_input(delta)
	
	transform.basis = transform.basis.rotated(transform.basis.z, roll_input * roll_speed * delta)
	transform.basis = transform.basis.rotated(transform.basis.x, pitch_input * pitch_speed * delta)
	transform.basis = transform.basis.rotated(transform.basis.y, yaw_input * yaw_speed * delta)
	
	transform.basis = transform.basis.orthonormalized()

	if !is_drift:
		velocity = -transform.basis.z * forward_speed
	
	$HUD/Panel/Gun_label.text= "Velocity:" + str(-1 * int(forward_speed * 10))
	
	move_and_collide(velocity * delta)
	
#	process_movement(delta)


#func process_movement(delta):
#	var newVel = vel
#
#	var target = dir
#
#	target *= MAX_SPEED
#
#	newVel = newVel.linear_interpolate(target, calculate_acceleration(newVel) * delta)
#
#	vel = move_and_slide(newVel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
#
#func calculate_acceleration(newVel):
#	if dir.dot(newVel) > 0:
#		return ACCEL
#	else:
#		return DEACCELL



#extends KinematicBody
#
#


##var MOUSE_SENSITIVITY = 0.05
#
#func _ready():
#	camera = $Rotation_Helper/Camera
#	rotation_helper = $Rotation_Helper
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#
#func _physics_process(delta):
#	process_input(delta)
#	process_movement(delta)
#
#
#func process_input(delta):
#	if Input.is_action_pressed("movement_forward"):
#		input_movement_vector.y +=1
#	if Input.is_action_pressed("movement_backward"):
#		input_movement_vector.y -=1
#
#
#
#
#func _input(event):
#	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
#		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
#		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
#
#		var camera_rot = rotation_helper.rotation_degrees
#		camera_rot.x = clamp(camera_rot.x, -70, 70)
#		rotation_helper.rotation_degrees = camera_rot
