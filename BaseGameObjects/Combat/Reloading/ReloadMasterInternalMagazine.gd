class_name ReloadMasterInternalMagazine extends ReloadMaster

var reload_canceled = false

@export var rounds_per_reload : int = 1


# Called whenever the reload key is pressed
func reload():
	if not is_reloading:
		# We can't load another bullet if the mag is full
		if magazine.needs_refilling():
			attempt_start_reload()
	else:
		attempt_active_reload()


func finish_reload():
	if DifficultyMaster.easy_reload_mode:
		magazine.insert_rounds_from_inventory(inventory, rounds_per_reload)
	else:
		# Insert the mag we selected when we started the reload
		if magazine_selected_for_reload != null:
			weapon.insert_bullet(magazine_selected_for_reload)

	magazine_selected_for_reload = null
	is_reloading = false
	time_spent_reloading = 0.0
	reload_failed = false
	
	if not reload_canceled:
		if magazine.needs_refilling():
			attempt_start_reload()
	else:
		reload_canceled = false


# Attempt to find a mag to reload with, and start the reload if one is found
func attempt_start_reload():
	if DifficultyMaster.easy_reload_mode:
		if magazine.can_refill_from_inventory(inventory):
			is_reloading = true
			perfect_zone_pos = randf_range(perfect_zone_min_pos, 1.0 - perfect_zone_length)
	else:
		# Repacking automatically based on difficulty
		if DifficultyMaster.auto_mag_repack:
			for ammo_type in weapon.compatible_ammo_types:
				weapon.get_weapon_wielder().inventory.magazine_repack_for_ammo_type(ammo_type)
		
		find_reload_magazine()
		
		# If we've found a magazine, start reloading
		if magazine_selected_for_reload != null && magazine_selected_for_reload.current_quantity > 0:
			is_reloading = true
			perfect_zone_pos = randf_range(perfect_zone_min_pos, 1.0 - perfect_zone_length)


func _process(delta):
	super(delta)
	if is_reloading:
		if weapon.trigger_down:
			reload_canceled = true
