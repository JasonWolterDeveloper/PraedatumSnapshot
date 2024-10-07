class_name RPGProjectileAbility extends DamageAbility

@export var projectile_scene : PackedScene

@export var burst_amount : int = 1
@export var time_between_shots : float = 0.05
@export var full_auto : bool = false

var firing_burst : bool = false
var time_until_next_shot = 0
var shots_fired : int = 0


func ability_pressed_effect():
	if full_auto:
		if not check_sufficient_mana_to_cast():
			display_not_enough_mana_message()
		else:
			time_until_next_shot = 0
	else:
		attempt_start_burst()


func fire_projectile():
	var new_projectile : NonHitscanBullet = projectile_scene.instantiate()
  
	Util.get_level(player).add_child(new_projectile)
	
	var start_pos = player.get_non_hitscan_projectile_spawn_location()
	var direction = start_pos + player.aiming_master.look_direction_vector()
	
	new_projectile.fire_bullet(start_pos, direction, player)


func attempt_start_burst():
	if not firing_burst:
		if check_sufficient_mana_to_cast():
			pay_mana_cost()
			start_burst()
		else:
			display_not_enough_mana_message()


func start_burst():
	firing_burst = true
	time_until_next_shot = 0
	shots_fired = 0


func end_burst():
	firing_burst = false
	time_until_next_shot = 0
	shots_fired = 0


func handle_burst_fire(delta : float):
	if firing_burst:
		time_until_next_shot -= delta
		if time_until_next_shot <= 0:
			fire_projectile()
			time_until_next_shot = time_between_shots
			shots_fired += 1
			if shots_fired >= burst_amount:
				end_burst()


func handle_full_auto(delta : float):
	if pressed:
		if check_sufficient_mana_to_cast():
			time_until_next_shot -= delta
			if time_until_next_shot <= 0:
				pay_mana_cost()
				fire_projectile()
				time_until_next_shot = time_between_shots


## Does anything that should be handled every process frame for an RPGAbility
func ability_process(delta : float):
	if full_auto:
		handle_full_auto(delta)
	else:
		handle_burst_fire(delta)
