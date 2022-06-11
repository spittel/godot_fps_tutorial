extends KinematicBody

const GRAVITY = -24.8
var vel = Vector3()
const MAX_SPEED = 20
const JUMP_SPEED = 18
const ACCEL = 4.5

var dir = Vector3()

const DEACCELL = 16
const MAX_SLOPE_ANGLE = 40

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
	# walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()
	var input_movement_vector = Vector2()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y +=1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -=1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -=1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x +=1

	input_movement_vector = input_movement_vector.normalized()

	# Basis vectors are already normalized
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	

	# using local vectors , see https://docs.godotengine.org/en/3.2/tutorials/3d/fps_tutorial/part_one.html
#	var node = $Rotation_Helper
#
#	if Input.is_action_pressed("movement_forward"):
#		node.translate(node.global_transform.basis.z.normalized())
#	if Input.is_action_pressed("movement_backward"):
#		node.translate(-node.global_transform.basis.z.normalized())
#	if Input.is_action_pressed("movement_left"):
#		node.translate(node.global_transform.basis.x.normalized())
#	if Input.is_action_pressed("movement_right"):
#		node.translate(-node.global_transform.basis.x.normalized())
	
	# Jumping
#	if is_on_floor():
	if Input.is_action_just_pressed("movement_jump"):
		vel.y = JUMP_SPEED

	if Input.is_action_just_pressed("movement_descend"):
		vel.y = -JUMP_SPEED
			
	# capturing/freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode((Input.MOUSE_MODE_VISIBLE))
			

	
func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	# decel but can hover
	if(vel.y > 0):
		vel.y += delta * -DEACCELL

	if(vel.y < 0):
		vel.y += delta * DEACCELL


	# deal with overshot on decel
	if((vel.y < 0 and vel.y > -1) or 
	(vel.y > 0 and vel.y < 1)):
		vel.y = 0;
	
	
	var hvel = vel
	hvel.y = 0
	
	var target = dir
	target *= MAX_SPEED
	
	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCELL
		
	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
	
func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
		
		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot
	

