extends Node2D




func _on_Area2D_body_entered( body ):
	if body is KinematicBody2D:
		if body.get_meta("is_defender"):
			print("AY!")
			$Area2D/CollisionShape2D.disabled = true
			body.pick(self)
