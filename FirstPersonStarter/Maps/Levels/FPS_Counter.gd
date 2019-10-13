extends Label


export (bool) var enabled = true


func _process(_delta):
	if enabled:
		var frames = Engine.get_frames_per_second()
		text = "FPS: "
		text += str(frames)
		
		if frames >= 55:
			add_color_override("font_color", Color(0, 1, 0.1, 1))
		elif frames <= 25:
			add_color_override("font_color", Color(1, 0, 0, 1))
		else:
			add_color_override("font_color", Color(1, 1, 0, 1))
	else:
		text = ""
