class_name GunDroneEnemy extends RangedEnemy
 
@export var gibs_scene : PackedScene
@onready var security_guard_target_detected_bark : BarkType = $SecurityGuardTargetDetectedBark
@onready var drone_model := $LookStuff/GunDroneModel

func _process(delta):
	super(delta)


func fire_bullet():
	super()
	drone_model.play_weapon_aesthetics()


func on_death():
	var gibs = gibs_scene.instantiate()
	Util.force_add_child(Util.get_level(self), gibs)
	gibs.global_position = global_position
	gibs.rotation = $LookStuff.rotation
	gibs.apply_physics_gibs()
	
	super()


## For duck typing
func target_detected_bark() -> void:#87d4f5
	security_guard_target_detected_bark.emit_bark()
