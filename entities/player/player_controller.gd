extends KinematicBody

###################-VARIABLES-####################

# Camera
export(float) var mouse_sensitivity = 10.0
export(NodePath) var head_path
export(NodePath) var cam_path
export(float) var FOV = 80.0
var mouse_axis := Vector2()
onready var head: Spatial = get_node(head_path)
onready var cam: Camera = get_node(cam_path)
# Move
var velocity := Vector3()
var direction := Vector3()
var mvarray: Array = [false, false, false, false] # FW, BW, L, R
var can_sprint := true
var sprinting := false
# Walk
const FLOOR_NORMAL: Vector3 = Vector3(0, 1, 0)
export(float) var gravity = 30.0
export(int) var walk_speed = 10
export(int) var sprint_speed = 16
export(int) var acceleration = 8
export(int) var deacceleration = 10
export(int) var jump_height = 10
var grounded: bool
# Fly
export(int) var fly_speed = 10
export(int) var fly_accel = 4
var flying := false
# Slopes
export(float) var floor_max_angle = 45

##################################################

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cam.fov = FOV


# Called every frame. 'delta' is the elapsed time since the previous frame
func _process(_delta: float) -> void:
	camera_rotation()


# Called every physics tick. 'delta' is constant
func _physics_process(delta: float) -> void:
	if flying:
		fly(delta)
	else:
		walk(delta)


# Called when there is an input event
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_axis = event.relative


func walk(delta: float) -> void:
	# Input
	mvarray = [false, false, false, false]
	direction = Vector3()
	var aim: Basis = get_global_transform().basis
	if Input.is_action_pressed("move_forward"):
		direction -= aim.z
		mvarray[0] = true
	if Input.is_action_pressed("move_backward"):
		direction += aim.z
		mvarray[1] = true
	if Input.is_action_pressed("move_left"):
		direction -= aim.x
		mvarray[2] = true
	if Input.is_action_pressed("move_right"):
		direction += aim.x
		mvarray[3] = true
	direction.y = 0
	direction = direction.normalized()
	
	# Grounded or Not
	var _snap: Vector3
	grounded = is_on_floor()
	
	# Jump
	if grounded:
		_snap = Vector3(0, -1, 0)
		if Input.is_action_just_pressed("move_jump"):
			_snap = Vector3(0, 0, 0)
			velocity.y = jump_height
	
	# Apply Gravity
	velocity.y += -gravity * delta
	
	# Sprint
	var _speed: int
	if (Input.is_action_pressed("move_sprint") and can_sprint 
			and mvarray[0] == true and mvarray[1] != true):
		_speed = sprint_speed
		cam.set_fov(lerp(cam.fov, FOV * 1.05, delta * 8))
		sprinting = true
	else:
		_speed = walk_speed
		cam.set_fov(lerp(cam.fov, FOV, delta * 8))
		sprinting = false
	
	# Acceleration and Deacceleration
	# where would the player go
	var _temp_vel: Vector3 = velocity
	_temp_vel.y = 0
	var _target: Vector3 = direction * _speed
	var _temp_accel: int
	if direction.dot(_temp_vel) > 0:
		_temp_accel = acceleration 
	else:
		_temp_accel = deacceleration
	# interpolation
	_temp_vel = _temp_vel.linear_interpolate(_target, _temp_accel * delta)
	velocity.x = _temp_vel.x
	velocity.z = _temp_vel.z
	# clamping
	if direction.dot(velocity) == 0:
		var _vel_clamp := 0.25
		if velocity.x < _vel_clamp and velocity.x > -_vel_clamp:
			velocity.x = 0
		if velocity.z < _vel_clamp and velocity.z > -_vel_clamp:
			velocity.z = 0
	
	# Move
	velocity.y = move_and_slide_with_snap(velocity, _snap, FLOOR_NORMAL, 
			true, 4, deg2rad(floor_max_angle)).y


func fly(delta: float) -> void:
	grounded = false
	
	# Input
	direction = Vector3()
	var aim = head.get_global_transform().basis
	if Input.is_action_pressed("move_forward"):
		direction -= aim.z
	if Input.is_action_pressed("move_backward"):
		direction += aim.z
	if Input.is_action_pressed("move_left"):
		direction -= aim.x
	if Input.is_action_pressed("move_right"):
		direction += aim.x
	direction = direction.normalized()
	
	# Acceleration and Deacceleration
	var target: Vector3 = direction * fly_speed
	velocity = velocity.linear_interpolate(target, fly_accel * delta)
	
	# Move
	velocity = move_and_slide(velocity)


func camera_rotation() -> void:
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return
	if mouse_axis.length() > 0:
		var _smoothness := 80
		# Get mouse delta
		var horizontal: float = -(mouse_axis.x * mouse_sensitivity) / _smoothness
		var vertical: float = -(mouse_axis.y * mouse_sensitivity) / _smoothness
		
		mouse_axis = Vector2()
		
		rotate_y(deg2rad(horizontal))
		head.rotate_x(deg2rad(vertical))
		
		# Clamp mouse rotation
		var temp_rot: Vector3 = head.rotation_degrees
		temp_rot.x = clamp(temp_rot.x, -90, 90)
		head.rotation_degrees = temp_rot
