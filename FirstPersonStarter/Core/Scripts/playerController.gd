extends KinematicBody

"""
Original code from Jeremy Bullock: https://www.youtube.com/watch?v=Etpq-d5af6M&list=PLTZoMpB5Z4aD-rCpluXsQjkGYgUGUZNIV
He explains the code very well, so if you have any questions, just head up to his channel.
Modified by me.
"""

#camera vars
export (float) var mouseSensitivity = 10
#
export (NodePath) var HeadPath
onready var Head = get_node(HeadPath)
#
var Axis = Vector2()
#moving vars
var velocity = Vector3()
var direction = Vector3()
#walk vars
export var gravity = 30
export var walkSpeed = 10
var canSprint = true
export var sprintSpeed = 16
export var acceleration = 4
export var deacceleration = 6
#jump vars
export var jumpHeight = 10
var hasContact = false
#fly vars
export var flySpeed = 10
export var flyAcceleration = 4
var flying = false
#slope vars
export (NodePath) var slopeRayPath
onready var slopeRay = get_node(slopeRayPath)

##################################################

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	CameraRotation(delta)
	
	if flying:
		Fly(delta)
	else:
		Walk(delta)


func _input(event):
	if event is InputEventMouseMotion:
		Axis = event.relative


func Walk(delta):
	#Resets the direction of the player
	direction = Vector3()
	#Gets the rotation of the direction
	var aim = get_global_transform().basis
	#Checks Input and changes direction
	if Input.is_action_pressed("moveForward"):
		direction -= aim.z
	if Input.is_action_pressed("moveBackward"):
		direction += aim.z
	if Input.is_action_pressed("moveLeft"):
		direction -= aim.x
	if Input.is_action_pressed("moveRight"):
		direction += aim.x
	direction.y = 0
	direction = direction.normalized()
	
	if (is_on_floor()):
		hasContact = true
	else:
		if !(slopeRay.is_colliding()):
			hasContact = false
	
	if (hasContact and !is_on_floor()):
		var pullDown = Vector3(0, -1, 0)
		pullDown = move_and_collide(pullDown)
	
	velocity.y += -gravity * delta
	
	var tempVelocity = velocity
	tempVelocity.y = 0
	
	var speed
	if Input.is_action_pressed("moveSprint") and canSprint:
		speed = sprintSpeed
	else:
		speed = walkSpeed
	
	#Where would the player go at max speed
	var target = direction * speed
	var tempAcceleration
	if direction.dot(tempVelocity) > 0:
		tempAcceleration = acceleration 
	else:
		tempAcceleration = deacceleration
	
	#Calculates a portion of distance to go
	tempVelocity = tempVelocity.linear_interpolate(target, tempAcceleration * delta)
	velocity.x = tempVelocity.x
	velocity.z = tempVelocity.z
	
	if hasContact and Input.is_action_just_pressed("moveJump"):
		velocity.y = jumpHeight
		hasContact = false
	
	#move
	velocity = move_and_slide(velocity, Vector3(0, 1, 0), true)


func Fly(delta):
	#Resets the direction of the player
	direction = Vector3()
	#Gets the rotation of the head
	var aim = Head.get_global_transform().basis
	#Checks Input and changes direction
	if Input.is_action_pressed("moveForward"):
		direction -= aim.z
	if Input.is_action_pressed("moveBackward"):
		direction += aim.z
	if Input.is_action_pressed("moveLeft"):
		direction -= aim.x
	if Input.is_action_pressed("moveRight"):
		direction += aim.x
	direction = direction.normalized()
	#Where would the player go at max speed
	var target = direction * flySpeed
	#Calculates a portion of distance to go
	velocity = velocity.linear_interpolate(target, flyAcceleration * delta)
	#move
	velocity = move_and_slide(velocity)


func CameraRotation(delta):
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return
	if Axis.length() > 0:
		var mouseX = -Axis.x * mouseSensitivity * delta
		var mouseY = -Axis.y * mouseSensitivity * delta
		
		Axis = Vector2()
		
		rotate_y(deg2rad(mouseX))
		
		Head.rotate_x(deg2rad(mouseY))
		
		var temp_rot = Head.rotation_degrees
		temp_rot.x = clamp(temp_rot.x, -90, 90)
		Head.rotation_degrees = temp_rot