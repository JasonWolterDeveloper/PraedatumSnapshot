class_name TurretEnemy extends RangedEnemy

@onready var aiming_laser = $LookStuff/AimingMaster/TurretAimingLaser
@export var turret_gibs_scene : PackedScene

@export var turret_activated : bool = false
@export var turret_activation_time : float = 1.0
var current_activation_time : float = 0.0
var turret_is_activating = false


func activate_turret():
	current_activation_time = 0.0
	turret_is_activating = true
	aiming_laser.fade_laser_in(turret_activation_time)


func finish_turret_activation():
	turret_activated = true
	turret_is_activating = false


# Unlike activating the turret, deactivating is instant
func deactivate_turret():
	turret_activated = false
	turn_laser_off()


func attempt_aim_turret(aim_point : Vector3):
	if turret_activated:
		aiming_master.aim_point = aim_point


func attempt_fire():
	if turret_activated:
		super()


func turn_laser_off():
	aiming_laser.turn_laser_off()
	
	
func turn_laser_on():
	aiming_laser.turn_laser_on()


func update_aiming_laser(delta):
	var turret_gun_model : TurretGunModel = $LookStuff/TurretGunModel
	
	if turret_gun_model:
		aiming_laser.set_global_origin_position(turret_gun_model.get_laser_start_pos())

	if dead:
		turn_laser_off()


func on_death():
	var turret_gibs = turret_gibs_scene.instantiate()
	Util.force_add_child(Util.get_level(self), turret_gibs)
	turret_gibs.global_position = global_position
	turret_gibs.rotation = rotation
	turret_gibs.set_rotation_for_relevant_stuff($LookStuff.rotation)
	turret_gibs.apply_physics_gibs()
	
	super()


func handle_activation_process(delta):
	if turret_is_activating:
		current_activation_time += delta
		if current_activation_time >= turret_activation_time:
			finish_turret_activation()


func _physics_process(delta):
	super(delta)
	handle_activation_process(delta)
	update_aiming_laser(delta)
