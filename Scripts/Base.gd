extends Node2D

func _on_Area2D_body_entered( body ):
	if body is KinematicBody2D:
		if body.get_meta("is_defender"):
			print("OUCH!")
			body.drop(self)
