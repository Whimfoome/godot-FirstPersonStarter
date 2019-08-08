extends Spatial

##################################################
#-----------------LEVEL--SCRIPT------------------#
##################################################

export (bool) var fastClose = true
var mouse_mode: String = "CAPTURED"

##################################################

func _ready():
	if fastClose:
		print("Fast Close Enabled in the 'Ls_Main' Script")


func _input(event):
	if event.is_action_pressed("ui_cancel") and fastClose:
		get_tree().quit() #QUITS THE GAME
	
	if event.is_action_pressed("mouse_input") and fastClose:
		match mouse_mode: #SWITCH STATEMENT IN GDSCRIPT
			"CAPTURED":
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				mouse_mode = "VISIBLE"
			"VISIBLE":
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				mouse_mode = "CAPTURED"