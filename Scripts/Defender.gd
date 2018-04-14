extends "res://Scripts/Player.gd"


var collectible

func _ready():
	self.set_meta("is_defender", true)

func _physics_process(delta):
	# Laura changes
	if Input.is_action_pressed("ui_select"):
		force_drop()

func pick(col):
	if not self.collectible:
		self.collectible = col
		self.collectible.get_parent().remove_child(self.collectible)
		$PickPivot.add_child(self.collectible)
		self.collectible.position = Vector2()

func has_collectible():
	if self.collectible:
		return true
	return false

func drop(base):
	if self.collectible:
		$PickPivot.remove_child(self.collectible)
		base.add_child(self.collectible)
		self.collectible.position = base.get_pivot()
		self.collectible = null

func force_drop():
	if self.collectible:
		$PickPivot.remove_child(self.collectible)
		get_parent().get_node("Map").add_child(self.collectible)
		self.collectible.position = self.position - (self.bounce_direction * 64)
		self.collectible.enable_me()
		self.collectible = null

func on_push(speed, velocity):
	.on_push(speed, velocity)
	self.force_drop()