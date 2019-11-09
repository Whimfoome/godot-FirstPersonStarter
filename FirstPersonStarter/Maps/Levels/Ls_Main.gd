extends Spatial

################################################## Close your game faster by clicking 'Esc'
#-----------------LEVEL--SCRIPT------------------# Change mouse mode by clicking 'Shift + F1'
##################################################

export var fast_close: bool = true
var mouse_mode: String = "CAPTURED"

##################################################

func _ready() -> void:
	if fast_close:
		print("Fast Close Enabled in the 'Ls_Main' Script")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and fast_close:
		get_tree().quit() # Quits the game
	
	if event.is_action_pressed("mouse_input") and fast_close:
		match mouse_mode: # Switch statement in GDScript
			"CAPTURED":
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				mouse_mode = "VISIBLE"
			"VISIBLE":
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				mouse_mode = "CAPTURED"
