class_name SecurityBotEnemy extends RangedEnemy
 
@export var gibs_scene : PackedScene
@onready var security_guard_target_detected_bark : BarkType = $SecurityGuardTargetDetectedBark


func _process(delta):
	super(delta)
	
	if velocity.length() > 0:
		$AnimationPlayer.play("moving")
	else:
		$AnimationPlayer.play("reset")


func on_death():
	var gibs = gibs_scene.instantiate()
	Util.force_add_child(Util.get_level(self), gibs)
	gibs.global_position = global_position
	gibs.rotation = $LookStuff.rotation
	gibs.apply_physics_gibs()
	
	super()


## For duck typing
func target_detected_bark() -> void:
	security_guard_target_detected_bark.emit_bark()
