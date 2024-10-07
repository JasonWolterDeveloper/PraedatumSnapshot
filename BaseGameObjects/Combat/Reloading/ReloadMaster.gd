class_name ReloadMaster extends Node3D

# Signals used for playing sound effects. Remember to connect them to Gun.SoundEffectMaster.play():
signal mag_ejected
signal mag_inserted
signal mag_inserted_perfect
signal mag_insert_failed ## Not currently used

var weapon : Gun : 
	get: return get_parent()
var inventory : Inventory :
	get: return weapon.get_weapon_wielder().inventory
	
@export var max_reload_time:float = 1 ## Seconds
## Arc length as a proportion of max_reload_time
@export var perfect_zone_length:float = 0.15
## Where the arc appears along a cicle, as a proportion of max_reload_time
@export var perfect_zone_min_pos:float = 0.25
## The Maximum extent of where a perfect zone could appear along a circle
@export var perfect_zone_max_pos:float = 1.0

# Variables for reload tracking
var is_reloading:bool = false
var time_spent_reloading:float = 0.0
var perfect_zone_pos:float # Current position of the perfect zone as a proportion of max_reload_time
var reload_failed:bool = false

# Modified stats from reload event
var modified_max_reload_time : float = 1
var modified_perfect_zone_length : float = 0.15
var modified_perfect_zone_min_pos : float = 0.25
var modified_perfect_zone_max_pos : float = 1.0

var magazine : Magazine :
	get: return weapon.magazine
	set(mag): weapon.magazine = mag
	
var magazine_selected_for_reload : Magazine = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if weapon.is_equipped():
		handle_reloading(delta)


func handle_reloading(delta):
	# Accept mag inserts near the end of the perfect zone as a proportion of max_reload_time
	var late_forgiveness := 0.02
	
	if is_reloading:
		time_spent_reloading += delta
		
		if not reload_failed: # Too late
			reload_failed = time_spent_reloading > modified_max_reload_time \
					* (perfect_zone_pos + modified_perfect_zone_length + late_forgiveness)
		
		if time_spent_reloading >= modified_max_reload_time: # Reload timed out
			mag_inserted.emit()
			finish_reload()


# Called whenever the reload key is pressed
func reload():
	if not is_reloading:
		if DifficultyMaster.easy_reload_mode:
			attempt_start_reload()
		else:
			if weapon.has_magazine_loaded(): # Eject
				weapon.eject_mag()
			else: # If Magazine ejected, we attempt to start a reload
				attempt_start_reload()
	else:
		attempt_active_reload()


# Searches the character's inventory for the compatible magazine with the most
# bullets currently inside of it and returns it if it exists
func find_reload_magazine():
	magazine_selected_for_reload = null # resetting the selected mag
	var item_list = weapon.get_weapon_wielder().inventory.get_items()
	
	for my_item in item_list:
		if my_item is Magazine:
			if my_item.is_compatible_with_gun(weapon):
				if magazine_selected_for_reload == null:
					magazine_selected_for_reload = my_item
				elif magazine_selected_for_reload.current_quantity < my_item.current_quantity:
					magazine_selected_for_reload = my_item 


# Attempt to find a mag to reload with, and start the reload if one is found
# Note that we only attempt to find a magazine when easy reload mode is off,
# Otherwise we just try to refill our current magaizne
func attempt_start_reload():
	if DifficultyMaster.easy_reload_mode:
		if magazine.can_refill_from_inventory(inventory):
			mag_ejected.emit()
			RPGEventMaster.invoke_reload_event(self)
			is_reloading = true
			perfect_zone_pos = randf_range(perfect_zone_min_pos, 1.0 - modified_perfect_zone_length)
	else:
		# Repacking automatically based on difficulty
		if DifficultyMaster.auto_mag_repack:
			for ammo_type in weapon.compatible_ammo_types:
				weapon.get_weapon_wielder().inventory.magazine_repack_for_ammo_type(ammo_type)
		
		find_reload_magazine()
		
		# If we've found a magazine, start reloading
		if magazine_selected_for_reload != null:
			mag_ejected.emit()
			is_reloading = true
			perfect_zone_pos = randf_range(perfect_zone_min_pos, 1.0 - modified_perfect_zone_length)


# Manual reload attempted
func attempt_active_reload():
	if not reload_failed: # Only get one chance!
		reload_failed = time_spent_reloading < (modified_max_reload_time * perfect_zone_pos) # Too soon
		if reload_failed:
			mag_insert_failed.emit()
		else:
			mag_inserted_perfect.emit()
			finish_reload()


func finish_reload():
	if DifficultyMaster.easy_reload_mode:
		weapon.magazine.refill_from_inventory(inventory)
	else:
		# Insert the mag we selected when we started the reload
		if magazine_selected_for_reload != null:
			weapon.insert_mag(magazine_selected_for_reload)
		
	magazine_selected_for_reload = null
	is_reloading = false
	time_spent_reloading = 0.0
	reload_failed = false


func get_reload_progress() -> float:
	return (time_spent_reloading/modified_max_reload_time)*100.0
