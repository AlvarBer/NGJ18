extends Node2D




func _on_Area2D_body_entered( body ):
	if body is KinematicBody2D:
		if body.get_meta("is_defender"):
			var can_pick = get_parent().get_parent().is_running()
			if can_pick:
				$Area2D/CollisionShape2D.disabled = true
				body.pick(self)

func enable_me():
	$Area2D/CollisionShape2D.disabled = false