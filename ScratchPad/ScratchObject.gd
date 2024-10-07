extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent() and "is_ready" in get_parent() and get_parent().is_ready:
		on_level_ready()
		
func foo():
	print("This does foo")
	
func on_level_ready():
	print("Well I guess this node is now ready")

