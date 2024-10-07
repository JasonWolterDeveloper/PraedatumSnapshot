extends Level

@onready var animation_player = $AnimationPlayer


func _process(delta: float) -> void:
	super(delta)
	if Input.is_action_just_pressed("debug_2"):
		animation_player.play("Movement")
