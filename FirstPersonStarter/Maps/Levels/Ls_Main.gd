extends Spatial

################################################## Close your game faster by clicking 'Esc'
#-----------------LEVEL--SCRIPT------------------# Change mouse mode by clicking 'Shift + F1'
##################################################

export (bool) var fast_close = true
var mouse_mode: String = "CAPTURED"

##################################################

func _ready():
	if fast_close:
		print("Fast Close Enabled in the 'Ls_Main' Script")


func _input(event):
	if event.is_action_pressed("ui_cancel") and fast_close:
		get_tree().quit() #QUITS THE GAME
	
	if event.is_action_pressed("mouse_input") and fast_close:
		match mouse_mode: #SWITCH STATEMENT IN GDSCRIPT
			"CAPTURED":
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				mouse_mode = "VISIBLE"
			"VISIBLE":
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				mouse_mode = "CAPTURED"
