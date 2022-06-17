extends KinematicBody

const MAX_SPEED = 30
const ACCEL = 10
const DEACCELL = 1
const MAX_SLOPE_ANGLE = 100

var vel = Vector3()
var dir = Vector3()
var roll_right = false
var roll_left = false
var camera
var rotation_helper

var MOUSE_SENSITIVITY = 0.05

func _ready():
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	
	
func process_input(delta):

	dir = Vector3()
	roll_right = false
	roll_left = false

	var cam_xform = camera.get_global_transform()
	var input_movement_vector = Vector3()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y +=1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -=1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -=1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x +=1
	# Ascend/descend
	if Input.is_action_pressed("movement_jump"):
		input_movement_vector.z +=1
	if Input.is_action_pressed("movement_descend"):
		input_movement_vector.z -=1

	if Input.is_action_pressed("movement_roll_right"):
		roll_right = true
	if Input.is_action_pressed("movement_roll_left"):
		roll_left = true

	input_movement_vector = input_movement_vector.normalized()

	# Basis vectors are already normalized
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	dir += cam_xform.basis.y * input_movement_vector.z
			
	# capturing/freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode((Input.MOUSE_MODE_VISIBLE))

func process_movement(delta):
	var newVel = vel

	var target = dir
	
	target *= MAX_SPEED
	
	newVel = newVel.linear_interpolate(target, calculate_acceleration(newVel) * delta)
	
	vel = move_and_slide(newVel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
	
	if(roll_left):
		rotate(Vector3(0, 0, 1), -.05)
	if(roll_right):
		rotate(Vector3(0, 0, 1), .05)
	
func calculate_acceleration(newVel):
	if dir.dot(newVel) > 0:
		return ACCEL
	else:
		return DEACCELL
	
func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
		
		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot
