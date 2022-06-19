extends KinematicBody
##################################
# new control code
##################################
export var max_speed = 50
export var acceleration = 0.6
export var pitch_speed = 1.5
export var roll_speed = 1.9
export var yaw_speed = 1.25  # Set lower for linked roll/yaw
export var input_response = 8.0

var velocity = Vector3.ZERO

var forward_speed = 0
var horiz_speed = 0
var vert_speed = 0

var pitch_input = 0
var roll_input = 0
var yaw_input = 0

var is_drift = false

const SAGGITAL_MULTIPLIER = 50

var MOUSE_SENSITIVITY = 0.05
var camera
var rotation_helper

var thrusters = preload("res://assets/sounds/main_thrusters.mp3")
var sagittal = preload("res://assets/sounds/sagittal_thrusters.mp3")


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

	handle_thrust(delta)
			
	pitch_input = lerp(pitch_input,
			Input.get_action_strength("pitch_up") - Input.get_action_strength("pitch_down"),
			input_response * delta)
			
	roll_input = lerp(roll_input,
			Input.get_action_strength("roll_left") - Input.get_action_strength("roll_right"),
			input_response * delta)
			
	yaw_input = lerp(yaw_input,
			Input.get_action_strength("yaw_left") - Input.get_action_strength("yaw_right"),
			input_response * delta)

	handle_saggital_thrust(delta)
	
	
func handle_thrust(delta):
	if Input.is_action_pressed("throttle_up"):
		forward_speed = lerp(forward_speed,
			Input.get_action_strength("throttle_up")*100,
			acceleration * delta)
			
		if !$MainThrusterSound.is_playing():
			$MainThrusterSound.stream = thrusters
			$MainThrusterSound.play()

	if Input.is_action_just_released("throttle_up"):
		$MainThrusterSound.stop()
		
	if Input.is_action_pressed("throttle_down"):
		forward_speed = lerp(forward_speed,
			-Input.get_action_strength("throttle_down")*50,
			acceleration * delta)
			
	if(forward_speed > max_speed):
		forward_speed = max_speed
			
	is_drift = Input.is_action_pressed("drift")
		

func handle_saggital_thrust(delta):
	var horiz_input = Input.get_action_strength("horiz_right") * SAGGITAL_MULTIPLIER  - Input.get_action_strength("horiz_left") * SAGGITAL_MULTIPLIER
	horiz_speed = lerp(horiz_speed, horiz_input, input_response * delta)

	var vert_input = Input.get_action_strength("vert_up") * SAGGITAL_MULTIPLIER - Input.get_action_strength("vert_down") * SAGGITAL_MULTIPLIER
	vert_speed = lerp(vert_speed, vert_input, input_response * delta)

	if(horiz_input != 0 || vert_input !=0):
		if !$SaggitalThrusterSound.is_playing():
			$SaggitalThrusterSound.stream = sagittal
			$SaggitalThrusterSound.play()
	else:
		if $SaggitalThrusterSound.is_playing():
			$SaggitalThrusterSound.stop()


func _physics_process(delta):
	get_input(delta)
	
	transform.basis = transform.basis.rotated(transform.basis.z, roll_input * roll_speed * delta)
	transform.basis = transform.basis.rotated(transform.basis.x, pitch_input * pitch_speed * delta)
	transform.basis = transform.basis.rotated(transform.basis.y, yaw_input * yaw_speed * delta)
	
	transform.basis = transform.basis.orthonormalized()

	if !is_drift:
		velocity = transform.basis.z * -forward_speed + transform.basis.y * vert_speed + transform.basis.x * horiz_speed

	
	$HUD/Panel/Gun_label.text= "Velocity:" + str(int(forward_speed))
	
	move_and_collide(velocity * delta)
