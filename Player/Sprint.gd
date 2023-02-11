extends Node


@export_node_path("MovementController") var controller_path := NodePath("../")
@onready var controller: MovementController = get_node(controller_path)

@export_node_path("Node3D") var head_path := NodePath("../Head")
@onready var cam: Camera3D = get_node(head_path).cam

@export var sprint_speed := 16
@export var fov_multiplier := 1.05
@onready var normal_speed: int = controller.speed
@onready var normal_fov: float = cam.fov


# Called every physics tick. 'delta' is constant
func _physics_process(delta: float) -> void:
	if can_sprint():
		controller.speed = sprint_speed
		cam.set_fov(lerp(cam.fov, normal_fov * fov_multiplier, delta * 8))
	else:
		controller.speed = normal_speed
		cam.set_fov(lerp(cam.fov, normal_fov, delta * 8))


func can_sprint() -> bool:
	return (controller.is_on_floor() and Input.is_action_pressed(&"sprint") 
			and controller.input_axis.x >= 0.5)
