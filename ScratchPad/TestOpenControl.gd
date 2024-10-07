extends PanelContainer

func _ready() -> void:
	# Set the initial scale to 0 on the X axis
	scale.x = 0
	
func _process(delta: float) -> void:
	# Check if the "1" key is pressed
	if Input.is_action_just_pressed("debug_1"):
		var tween = get_tree().create_tween()
		# Start the tweening process
		tween.tween_property(self, "scale:x", 1, 0.2)
