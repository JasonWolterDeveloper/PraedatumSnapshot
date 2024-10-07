class_name MeleeWeapon extends Weapon

const ENEMY_COLLISION_LAYER_VALUE = 20 # Includes both enemies and hitbox layers

# ----- Melee Weapon Statistic Variables ----- #
## This will be equal to half the size of the arc as it is both negative and positive
@export var melee_arc : float = PI/2
@export var melee_damage : float = 7.0
@onready var melee_range : Area3D =  $MeleeRange

# ----- Cooldown Time for Melee Attack ----- #
@export var melee_recovery_time : float = 0.5
var current_melee_recovery_time :float = 0.5

# ----- Tracking Melee Attack Time Variables ----- #
@export var time_from_start_melee_attack_to_damage : float = 0.1
var current_melee_attack_time : float = 0.0
var ongoing_melee_attack : bool = false

# ----- Aesthetic Variables ----- #
@export var successful_impact_particle_scene : PackedScene



# ----------- Equipped Handlers ---------- #


func handle_equipped(delta : float):
	handle_melee_cooldown(delta)
	handle_ongoing_melee_attack(delta)


func handle_melee_cooldown(delta : float):
	if current_melee_recovery_time <= melee_recovery_time:
		current_melee_recovery_time += delta


func handle_ongoing_melee_attack(delta : float):
	if ongoing_melee_attack:
		if current_melee_attack_time <= time_from_start_melee_attack_to_damage:
			current_melee_attack_time += delta
		else:
			melee_attack_deal_damage()
			stop_melee_attack()



# ------------ Check For Hits Functions ----------- #


func check_point_in_melee_arc(point: Vector3):
	return get_weapon_wielder().aiming_master.point_in_given_vision_cone_angle(point, melee_arc)


func check_los_to_target(my_hit_object : Node3D):
	return Util.check_los_to_object(get_weapon_wielder(), my_hit_object)


func check_hit(my_hit_object):
	return check_los_to_target(my_hit_object) and check_point_in_melee_arc(my_hit_object.global_position)


func check_for_hits() -> Array:
	var hit_objects : Array = []
	for my_body in melee_range.get_overlapping_bodies():
		if my_body is hitbox and not my_body.get_character() == get_weapon_wielder():
			if check_hit(my_body):
				hit_objects.append(my_body)
	return hit_objects



# ---------- Handle Hits Functions ---------- #


func handle_basic_hit(my_hitbox: hitbox):
	my_hitbox.deal_damage_to_character(melee_damage, get_weapon_wielder())
	handle_hit_aesthetics(my_hitbox)


func handle_hit_aesthetics(my_hitbox: hitbox):
	if get_weapon_wielder():
		var hit_result = Util.los_collision_point_raycast_full_result(get_weapon_wielder().global_position, my_hitbox.global_position, ENEMY_COLLISION_LAYER_VALUE)
		
		if successful_impact_particle_scene:
			var impact_particles : ImpactParticleEffect = successful_impact_particle_scene.instantiate()
			GameMaster.get_level().add_child(impact_particles)
			
			var normal = Vector3.ZERO
			
			if hit_result:
				DebugMaster.log_debug(hit_result.collider)
				impact_particles.global_position = hit_result.position
				normal = impact_particles.to_global(hit_result.normal)
			
			var normal_zero_y = Vector3(normal.x, 0.0, normal.z)
			impact_particles.emit_particles_direction(normal_zero_y)



# ----------- Melee Attack Functions ---------- #


func attempt_melee_attack():
	if can_melee_attack():
		start_melee_atack()


func start_melee_atack():
	ongoing_melee_attack = true
	current_melee_attack_time = 0.0
	play_swing_animation()


func melee_attack_deal_damage():
	var hit_objects : Array = check_for_hits()
	if not hit_objects.is_empty():
		for my_hit_object in hit_objects:
			handle_basic_hit(my_hit_object)
	current_melee_recovery_time = 0.0


func stop_melee_attack():
	ongoing_melee_attack = false
	current_melee_attack_time = 0.0


func can_melee_attack():
	return not ongoing_melee_attack and current_melee_recovery_time >= melee_recovery_time



# ---------- Animation/Aesthetic Functions ---------- #


func play_swing_animation():
	var player_model : PlayerModel = GameMaster.get_player().player_model
	player_model.play_melee_swing()



# ---------- Trigger Functions ----------- #


func on_use_item_pressed():
	super()
	attempt_melee_attack()
