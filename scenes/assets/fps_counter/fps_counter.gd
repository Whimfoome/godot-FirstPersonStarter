extends Label

##################################################

export var enabled := true

##################################################

func _process(_delta: float) -> void:
	if enabled:
		var frames: float = Engine.get_frames_per_second()
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
