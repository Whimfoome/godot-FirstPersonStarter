extends KinematicBody

"""
Original code from Jeremy Bullock: https://www.youtube.com/watch?v=Etpq-d5af6M&list=PLTZoMpB5Z4aD-rCpluXsQjkGYgUGUZNIV
He explains the code very well, so if you have any questions, just head up to his channel.
Modified by me.
"""

# Camera
export var mouse_sensitivity: float = 10.0
export var head_path: NodePath
onready var head: Spatial = get_node(head_path)
export var cam_path: NodePath
onready var cam: Camera = get_node(cam_path)
export var FOV: float = 90.0
var axis: Vector2 = Vector2()
# Move
var velocity: Vector3 = Vector3()
var direction: Vector3 = Vector3()
var mvarray: Array = [false, false, false, false] # FW, BW, L, R
var can_sprint: bool = true
var sprinting: bool = false
# Walk
export var gravity: float = 30.0
export var walk_speed: int = 10
export var sprint_speed: int = 16
export var acceleration: int = 6
export var deacceleration: int = 8
export var jump_height: int = 10
var grounded: bool = false
# Fly
export var fly_speed: int = 10
export var fly_accel: int = 4
var flying: bool = false
# Slope
export var slope_ray_path: NodePath
onready var slope_ray: RayCast = get_node(slope_ray_path)

##################################################

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cam.fov = FOV


func _physics_process(delta: float) -> void:
	camera_rotation(delta)
	
	if flying:
		fly(delta)
	else:
		walk(delta)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		axis = event.relative


func walk(delta: float) -> void:
	# Input
	mvarray = [false, false, false, false]
	direction = Vector3()
	var aim: Basis = get_global_transform().basis
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
		var _collision: KinematicCollision  = move_and_collide(Vector3(0, -0.1, 0))
	
	# Jump
	if grounded and Input.is_action_just_pressed("moveJump"):
		velocity.y = jump_height
		grounded = false
	
	# Apply Gravity
	velocity.y += -gravity * delta
	
	# Sprint
	var speed: int
	if Input.is_action_pressed("moveSprint") && can_sprint && mvarray[0] == true && mvarray[1] != true:
		speed = sprint_speed
		cam.set_fov(lerp(cam.fov, FOV * 1.05, delta * 8))
		sprinting = true
	else:
		speed = walk_speed
		cam.set_fov(lerp(cam.fov, FOV, delta * 8))
		sprinting = false
	
	# Acceleration and Deacceleration
	var temp_vel: Vector3 = velocity
	temp_vel.y = 0
	var target: Vector3 = direction * speed
	var temp_accel: int
	if direction.dot(temp_vel) > 0:
		temp_accel = acceleration 
	else:
		temp_accel = deacceleration
	temp_vel = temp_vel.linear_interpolate(target, temp_accel * delta)
	velocity.x = temp_vel.x
	velocity.z = temp_vel.z
	
	# Move
	velocity = move_and_slide(velocity, Vector3(0, 1, 0), true)


func fly(delta: float) -> void:
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
	var target: Vector3 = direction * fly_speed
	velocity = velocity.linear_interpolate(target, fly_accel * delta)
	
	# Move
	velocity = move_and_slide(velocity)


func camera_rotation(delta: float) -> void:
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return
	if axis.length() > 0:
		var mouse_x: float = -axis.x * mouse_sensitivity * delta
		var mouse_y: float = -axis.y * mouse_sensitivity * delta
		
		axis = Vector2()
		
		rotate_y(deg2rad(mouse_x))
		
		head.rotate_x(deg2rad(mouse_y))
		
		var temp_rot: Vector3 = head.rotation_degrees
		temp_rot.x = clamp(temp_rot.x, -90, 90)
		head.rotation_degrees = temp_rot
