class_name RangedEnemy extends Enemy

@onready var bullet_start_pos = $LookStuff/BulletOrigin

@export var time_between_shots_turret : float = 0.12
@export var bullet_scene : PackedScene
@export var spread = 0.03

@export var shots_per_burst : int= 1
@export var time_between_burst_shots : float = 0.0

## Indicates how close we need to be to aiming at our target to start shooting
@export var aim_tolerance_to_fire : float = 15.0
var firing_burst = false
var time_since_last_burst_shot = 0.0
var shots_fired_this_burst = 0

var time_since_last_fired : float = 0.0


func generate_random_shot_direction_from_direction(direction: Vector3):
	var random_spread = randf_range(-spread, spread)
	var new_random_vector = direction.rotated(Vector3.UP, random_spread)
	return new_random_vector


func update_fire_rate(delta):
	time_since_last_fired += delta


func _physics_process(delta):
	handle_burst(delta)
	update_fire_rate(delta)
	

func can_fire():
	var aim_tolerance_check = aiming_master.point_in_given_vision_cone_angle(aiming_master.aim_point, aim_tolerance_to_fire)
	var stun_check = not stunned
	return aim_tolerance_check and stun_check
		


func attempt_fire():
	if can_fire():
		if time_since_last_fired > time_between_shots_turret:
			time_since_last_fired = 0
			fire_bullet()
			
			if shots_per_burst > 1:
				start_burst()


func start_burst():
	firing_burst = true
	time_since_last_burst_shot = 0.0
	
	# Setting shots fired to one since we should have already fired one shot
	shots_fired_this_burst = 1
	

func end_burst():
	firing_burst = false
	

func handle_burst(delta : float):
	if firing_burst:
		time_since_last_burst_shot += delta
		if time_since_last_burst_shot >= time_between_burst_shots:
			fire_bullet()
			time_since_last_burst_shot = 0.0
			
			shots_fired_this_burst += 1
			
			if shots_fired_this_burst >= shots_per_burst:
				end_burst()


func fire_bullet():
	var bullet_direction = $LookStuff.to_global(Vector3(0, 0, -5))
	
	var new_bullet : NonHitscanBullet = bullet_scene.instantiate()
	Util.force_add_child(get_level(), new_bullet)
	
	var random_direction = generate_random_shot_direction_from_direction(bullet_direction)
	
	new_bullet.fire_bullet(bullet_start_pos.global_position, random_direction, self)


## Simple LOS check: does not factor in attack range
func can_attack_target(target:Character = target_character):
	return not stunned and check_los_to_character(target)


func get_level():
	return Util.get_level(self)


# Tells the AimingMaster we're a melee enemy
func is_unarmed():
	return true
