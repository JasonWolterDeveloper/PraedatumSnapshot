class_name OlReliable extends Gun

## A semi-auto full-power (laser) battle rifle. The alt-fire charges the gun in several successive
## levels, the number of which is dictated by the sizes of the @exported arrays (MUST match in size).
## Firing while charged applies the currently fulfilled level's buffs & debuffs; releasing alt fire 
## immediately resets charge to 0.

@export var charge_durations:Array[float] ## The number of seconds to reach each level
@export var charge_damage_mults:Array[float] ## The damage multiplier applied to each level
@export var charge_ammo_usage:Array[int] ## The ammo consumtion of each level's charged shot
@export var charge_recoil_mults:Array[float] ## The recoil multiplier applied to each level

var charge_times:Array[float] # Max charge time (in seconds) per charge level
var charge_levels:int
var curr_charge_time:float = 0 # In seconds
var curr_charge_lvl:int # Starting from 1
var curr_dmg_mult:float = 1

func _ready():
	super._ready()
	
	# All arrays must match in size:
	assert(charge_durations.size() == charge_damage_mults.size())
	assert(charge_damage_mults.size() == charge_ammo_usage.size())
	assert(charge_ammo_usage.size() == charge_recoil_mults.size())
	charge_levels = charge_durations.size()
	
	for i in charge_levels:
		charge_times.append(MathUtil.array_sum(charge_durations, 0, i))


## Override
func handle_equipped(delta):
	if not get_weapon_wielder().controller.can_control(): # Do not charge when in menus, stunned, etc.
		alt_fire_down = false
		use_custom_crosshair = false
		curr_charge_time = 0
	else:
		if alt_fire_down and not has_shot_since_last_trigger_pull \
			and current_ammo_count >= charge_ammo_usage[0]: # Charging
			use_custom_crosshair = true
			curr_charge_time += delta
			curr_charge_time = min(curr_charge_time, charge_times[charge_levels-1])
			
			# Clamp charge time based on our current ammo:
			if current_ammo_count < charge_ammo_usage[charge_levels - 1]: 
				var ammo_req_met:bool = false
				var index:int = charge_levels - 2
				while index > 0 or not ammo_req_met:
					if current_ammo_count >= charge_ammo_usage[index]:
						ammo_req_met = true
						curr_charge_time = min(curr_charge_time, charge_times[index])
					index -= 1
		else: # Not charging
			use_custom_crosshair = false
			curr_charge_time = 0
		
		super.handle_equipped(delta)


## Override
## Do we fire a normal shot or a charged shot?
func fire():
	var charge_time_met := false # Only need to check time, since ammo is checked in handle_equipped()
	var array_index:int
	curr_dmg_mult = 1.0 # Default damage multiplier
	
	if alt_fire_down:
		array_index = charge_levels - 1
		
		while not charge_time_met and array_index >= 0: 
			
			charge_time_met = curr_charge_time >= charge_times[array_index]
			if charge_time_met:
				curr_charge_lvl = array_index + 1
				charged_fire()
				
				DebugMaster.log_debug(str(self) + " fired charged shot lvl " + str(array_index+1) 
				+ " (" + str(charge_damage_mults[array_index]) + "x dmg, " + \
				str(charge_ammo_usage[array_index]) + " ammo)")
				
			array_index -= 1

	if not alt_fire_down or not charge_time_met:
		super.fire()
		curr_charge_lvl = 0


func generate_bullet() -> Bullet:
	var bullet = super()
	bullet.damage *= curr_dmg_mult
	return bullet


## Weapon-specific version of super.fire()
func charged_fire():
	var charged_recoil_per_shot:float = recoil_per_shot * charge_recoil_mults[curr_charge_lvl-1]
	
	has_shot_since_last_trigger_pull = true
	time_since_last_shot = 0.0
	
	curr_dmg_mult = charge_damage_mults[curr_charge_lvl-1]
	current_ammo_count -= charge_ammo_usage[curr_charge_lvl-1]

	# Generate the data such as collisions and bullet endpoint for the actual 
	# shot we just took
	var trajectory = get_aiming_master().generate_shot_trajectory_with_spread(calculate_spread())
	handle_recoil(charged_recoil_per_shot)
	
	generate_and_fire_bullet(trajectory)
	generate_firing_noise()


func calculate_current_charge_level():
	var charge_req_met := false # Do we have the ammo + charge time necessary?
	var array_index :int = charge_levels - 1
	
	while not charge_req_met and array_index >= 0: 
		
		charge_req_met = curr_charge_time >= MathUtil.array_sum(charge_durations, 0, array_index) \
			and current_ammo_count >= charge_ammo_usage[array_index]
		if charge_req_met:
			return array_index + 1
		array_index -= 1
	return array_index
