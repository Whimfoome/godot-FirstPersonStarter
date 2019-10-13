extends KinematicBody

"""
Original code from Jeremy Bullock: https://www.youtube.com/watch?v=Etpq-d5af6M&list=PLTZoMpB5Z4aD-rCpluXsQjkGYgUGUZNIV
He explains the code very well, so if you have any questions, just head up to his channel.
Modified by me.
"""

# Camera
export (float) var mouse_sensitivity = 10
export (NodePath) var head_path
onready var head = get_node(head_path)
export (NodePath) var cam_path
onready var cam = get_node(cam_path)
export (float) var FOV = 90
var axis = Vector2()
# Move
var velocity = Vector3()
var direction = Vector3()
var mvarray = [false, false, false, false] # FW, BW, L, R
var can_sprint = true
var sprinting = false
# Walk
export var gravity = 30
export var walk_speed = 10
export var sprint_speed = 16
export var acceleration = 4
export var deacceleration = 6
export var jump_height = 10
var grounded = false
# Fly
export var fly_speed = 10
export var fly_accel = 4
var flying = false
# Slope
export (NodePath) var slope_ray_path
onready var slope_ray = get_node(slope_ray_path)

##################################################

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cam.fov = FOV


func _physics_process(delta):
	CameraRotation(delta)
	
	if flying:
		Fly(delta)
	else:
		Walk(delta)


func _input(event):
	if event is InputEventMouseMotion:
		axis = event.relative


func Walk(delta):
	# Input
	mvarray = [false, false, false, false]
	direction = Vector3()
	var aim = get_global_transform().basis
	if Input.is_action_pressed("moveForward"):
		direction -= aim.z
		mvarray[0] = true
	if Input.is_action_pressed("moveBackward"):
		direction += aim.z
		mvarray[1] = true
	if Input.is_action_pressed("moveLeft"):
		direction -= aim.x
		mvarray[2] = true
	if Input.is_action_pressed("moveRight"):
		direction += aim.x
		mvarray[3] = true
	direction.y = 0
	direction = direction.normalized()
	
	# Grounded or Not and Slope Ray
	if is_on_floor():
		grounded = true
	elif !slope_ray.is_colliding():
		grounded = false
	if grounded and !is_on_floor():
		var pull_down = Vector3(0, -0.1, 0)
		pull_down = move_and_collide(pull_down)
	
	# Jump
	if grounded and Input.is_action_just_pressed("moveJump"):
		velocity.y = jump_height
		grounded = false
	
	# Apply Gravity
	velocity.y += -gravity * delta
	
	# Sprint
	var speed
	if Input.is_action_pressed("moveSprint") && can_sprint && mvarray[0] == true && mvarray[1] != true:
		speed = sprint_speed
		cam.set_fov(lerp(cam.fov, FOV * 1.05, delta * 8))
		sprinting = true
	else:
		speed = walk_speed
		cam.set_fov(lerp(cam.fov, FOV, delta * 8))
		sprinting = false
	
	# Acceleration and Deacceleration
	var temp_vel = velocity
	temp_vel.y = 0
	var target = direction * speed
	var tem_accel
	if direction.dot(temp_vel) > 0:
		tem_accel = acceleration 
	else:
		tem_accel = deacceleration
	temp_vel = temp_vel.linear_interpolate(target, tem_accel * delta)
	velocity.x = temp_vel.x
	velocity.z = temp_vel.z
	
	# Move
	velocity = move_and_slide(velocity, Vector3(0, 1, 0), true)


func Fly(delta):
	# Input
	direction = Vector3()
	var aim = head.get_global_transform().basis
	if Input.is_action_pressed("moveForward"):
		direction -= aim.z
	if Input.is_action_pressed("moveBackward"):
		direction += aim.z
	if Input.is_action_pressed("moveLeft"):
		direction -= aim.x
	if Input.is_action_pressed("moveRight"):
		direction += aim.x
	direction = direction.normalized()
	
	# Acceleration and Deacceleration
	var target = direction * fly_speed
	velocity = velocity.linear_interpolate(target, fly_accel * delta)
	
	# Move
	velocity = move_and_slide(velocity)


func CameraRotation(delta):
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return
	if axis.length() > 0:
		var mouse_x = -axis.x * mouse_sensitivity * delta
		var mouse_y = -axis.y * mouse_sensitivity * delta
		
		axis = Vector2()
		
		rotate_y(deg2rad(mouse_x))
		
		head.rotate_x(deg2rad(mouse_y))
		
		var temp_rot = head.rotation_degrees
		temp_rot.x = clamp(temp_rot.x, -90, 90)
		head.rotation_degrees = temp_rot
