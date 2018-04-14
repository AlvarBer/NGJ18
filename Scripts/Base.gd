extends Node2D

var total_pieces = 3
var pieces = 0


func get_pivot():
	return get_node("Pivot%d" % pieces).position

func _on_Area2D_body_entered( body ):
	if body is KinematicBody2D:
		if body.get_meta("is_defender"):
			if body.has_collectible():
				body.drop(self)
				pieces += 1
				
				if pieces == total_pieces:
					get_parent().get_parent().base_completed()
