extends Area

# The Player has Physics Collision Layer set to: Objects (Layer 1) and Player (Layer 2).
# Ladder Area has Physics Collision Mask set to: Player (Layer 2), which means that it will detect Players.
# 
# *You can use Groups or Classes too, but I prefer this method*
# Learn more on this GDQuest's video: https://www.youtube.com/watch?v=UZu8NwlkXcU

func _on_body_entered(body: PhysicsBody) -> void:
	body.flying = true


func _on_body_exited(body: PhysicsBody) -> void:
	body.flying = false
