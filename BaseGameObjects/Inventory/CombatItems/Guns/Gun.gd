class_name Gun extends Weapon

# For playing sound effects, amoung other things
# Is used in conjunction with the low/critical ammo vars to indicate how "dry" the weapon is
# high = 3, low = 2, critical = 1, none = 0
signal fired(value:ammo_level)
signal alt_fired(value:ammo_level)

enum ammo_level {DRY, CRITICAL, LOW, HIGH}

const MAGAZINE_SAVE_KEY = "magazine"

# Firing Rates/Modes Vars.
@export var is_semi_auto:bool ## Also applies to burst weapons
@export var time_between_shots:float ## 0 = no-delay semi-auto. >0 = full auto
var modified_time_between_shots : float = 0

@export var shots_per_burst : int = 1
@export var time_between_burst_shots : float = 0.15
var modified_time_between_burst_shots : float = 0.15

# ----- Spread Data ----- #

const MAXIMUM_SPREAD = 1.99*PI

@export var base_spread := 0.05
@export var recoil_per_shot := 0.3
@export var recoil_recovery_per_second := 1.2
@export var maximum_recoil_spread := 0.8

@export var movement_spread_gain_per_second := 0.8
@export var movement_spread_recovery_per_second := 1.2
@export var maximum_movement_spread := 0.8
@export var maximum_walking_movement_spread := 0.4

# Current Spread Values
var recoil_spread : float = 0.0
var movement_spread : float = 0.0

@export var fire_ai_sound_range : float = 25.0

# ----- Aesthetic Information ----- #
@export var screen_shake_on_fire_amount : float = 0.05
@export var has_gunshot_screen_flash : bool = true
@export var gunshot_screen_flash_amount : float = 0.2
@export var gunshot_screen_flash_duration : float = 0.1

# Sound effect information. 
@export var low_ammo_amount:int = 2
@export var critical_ammo_amount:int = 1

var current_ammo_count:int = 0 :
	get: return get_current_ammo_count()
	set(ammo): set_current_ammo_count(ammo)
var max_ammo_count:int = 0 :
	get: return get_max_ammo_count()
	
# Variables for burst fire
var firing_burst : bool = false
var rounds_fired_in_burst : int = 0
var time_since_last_burst_shot : float = 0.0

# Variables for fire rate
var has_shot_since_last_trigger_pull = false
var time_since_last_shot = 0.0

var magazine : Magazine = null

@onready var reload_master = $ReloadMaster


func _ready():
	assign_magazine_from_children()


# If one of our direct children is a magazine we assign it as our current magazine
func assign_magazine_from_children():
	for my_child in get_children():
		if my_child is Magazine:
			magazine = my_child
			break


func handle_equipped(delta : float):
	time_since_last_shot += delta
	handle_weapon_trigger(delta)
	handle_burst(delta)
	handle_recoil_recovery(delta)
	handle_movement_spread(delta)



# ---------- Spread Functions ---------- #


func calculate_spread() -> float:
	return min(MAXIMUM_SPREAD, get_base_spread() + recoil_spread + movement_spread)


func handle_recoil(recoil_amount : float) -> void:
	RPGEventMaster.invoke_recoil_event(self, recoil_amount)


func handle_recoil_recovery(delta : float) -> void:
	RPGEventMaster.invoke_recoil_recovery_event(self, delta)


func handle_movement_spread(delta : float) -> void:
	if get_weapon_wielder():
		if get_weapon_wielder().is_moving():
			RPGEventMaster.invoke_movement_spread_event(self, delta)
		else:
			RPGEventMaster.invoke_movement_spread_recovery_event(self, delta)



# ---------- Other Equipped Handlers --------- #


func handle_weapon_trigger(delta):
	var can_fire_now := false
	
	if trigger_down:
		if not reload_master.is_reloading and current_ammo_count > 0:
			RPGEventMaster.invoke_rate_of_fire_event(self)
			can_fire_now = time_since_last_shot > modified_time_between_shots \
				and not (is_semi_auto and has_shot_since_last_trigger_pull) \
				and not firing_burst
			if can_fire_now:
				if is_burst_fire():
					start_burst()
				else:
					fire()
	else:
		has_shot_since_last_trigger_pull = false
		
		
		
# ---------- Reload Functions ---------- #


# Called whenever the reload key is pressed
func reload(attempt_ammo_type_change : bool = true):
	if magazine.can_refill_from_inventory(get_weapon_wielder().inventory) and magazine.needs_refilling():
		reload_master.reload()
	elif magazine.current_quantity == 0 and attempt_ammo_type_change:
		cycle_ammo_subtype()


# Eject the Current Magazine
func eject_mag():
	if has_magazine_loaded():
		if get_weapon_wielder().inventory.can_fit_anywhere(magazine):
			get_weapon_wielder().inventory.insert_anywhere(magazine)
		else:
			get_weapon_wielder().inventory.drop_item(magazine)
		magazine = null


# Insert an arbitrary magazine
func insert_mag(mag: Magazine):
	Util.force_add_child(self, mag)
	magazine = mag


func unload_magazine():
	if magazine.current_quantity > 0:
		var ammo_item_scene : PackedScene = magazine.ammo_type.get_item_scene_for_subtype(magazine.selected_ammo_subtype)
		
		var quantity_to_add_to_items : int = magazine.current_quantity
		
		while quantity_to_add_to_items > 0:
			var ammo_item : AmmoItem = ammo_item_scene.instantiate()
			var quantity_to_put_in_ammo_item : int = min(ammo_item.max_quantity, quantity_to_add_to_items)
			
			ammo_item.current_quantity = quantity_to_put_in_ammo_item
			quantity_to_add_to_items -= quantity_to_put_in_ammo_item
			
			if get_weapon_wielder().inventory.can_fit_anywhere(ammo_item):
				get_weapon_wielder().inventory.insert_anywhere(ammo_item)
			else:
				get_weapon_wielder().inventory.drop_item(ammo_item)

		magazine.current_quantity = 0


func cycle_ammo_subtype():
	if not is_reloading():
		var current_subtype : String = magazine.selected_ammo_subtype
		var original_subtype : String = current_subtype
		var tried_subtypes : Array[String] = [current_subtype]
		
		var searching_for_new_subtype : bool = true
		var found_new_subtype_with_ammo : bool = false
		
		# TODO REEEEE WHILE LOOP REEEEE REMOVE
		while searching_for_new_subtype:
			current_subtype = magazine.ammo_type.cycle_subtype(current_subtype)
			
			if current_subtype in tried_subtypes:
				searching_for_new_subtype = false
				break
			
			magazine.selected_ammo_subtype = current_subtype
			
			if magazine.can_refill_from_inventory(get_weapon_wielder().inventory):
				found_new_subtype_with_ammo = true
				searching_for_new_subtype = false
				break
		
		if found_new_subtype_with_ammo:
			# TODO NOTE - Very Kludgey, but we need to change our magazine BACK to the original sub
			# type to unload, then SWITCH AGAIN to our new subtype to unload. This is because we are
			# making use of magazine's can_refill_from_inventory function
			magazine.selected_ammo_subtype = original_subtype
			unload_magazine()
			magazine.selected_ammo_subtype = current_subtype
			reload(false)
		else:
			magazine.selected_ammo_subtype = original_subtype
			



# ---------- Firing and Bullet Functions ----------#


func fire():
	fired.emit(get_current_ammo_level())
	has_shot_since_last_trigger_pull = true
	time_since_last_shot = 0.0
	
	handle_ammo_consumption()
	
	# Generate the data such as collisions and bullet endpoint for the actual 
	# shot we just took
	var trajectory = get_aiming_master().generate_shot_trajectory_with_spread(calculate_spread())
	handle_recoil(recoil_per_shot)
	
	generate_and_fire_bullet(trajectory)
	generate_firing_noise()
	handle_basic_shot_aesthetics()


func handle_ammo_consumption(amount : int = 1):
	current_ammo_count -= amount


func generate_bullet() -> Bullet:
	if magazine:
		var new_bullet = magazine.generate_bullet()
		return new_bullet
	return null


func fire_bullet(bullet : Bullet, trajectory : Vector3):
	var real_start_pos = get_weapon_wielder().get_real_bullet_start_pos()
	GameMaster.get_level().add_child(bullet)
	bullet.fire_bullet(real_start_pos, get_weapon_wielder().get_bullet_start_pos(), trajectory, self, get_weapon_wielder())


func generate_and_fire_bullet(trajectory : Vector3):
	var bullet : Bullet = generate_bullet()
	if bullet:
		fire_bullet(bullet, trajectory)


func generate_firing_noise():
	get_weapon_wielder().generate_ai_sound(fire_ai_sound_range)



# ---------- Aesthetic Functions ----------#


func handle_basic_shot_aesthetics():
	play_muzzle_flash()
	
	ScreenShakeMaster.request_screen_shake(screen_shake_on_fire_amount)
	VignetteMaster.request_gunshot_vignette(gunshot_screen_flash_amount, gunshot_screen_flash_duration)
	

## Override if your gun's model has more than one ejection port. Must be explicitly called by your 
## weapon implementation somewhere, as not all weapons cycle the same
func eject_round():
	var ejection_ports = get_ejection_ports()
	
	if ejection_ports.size() > 0:
		ejection_ports[0].spawn_casing()


func play_muzzle_flash():
	var weapon_model = get_weapon_model()
	if weapon_model:
		weapon_model.play_muzzle_flash()



# ---------- Burst Fire Functions -------- #


func is_burst_fire():
	return shots_per_burst > 1


func start_burst():
	RPGEventMaster.invoke_rate_of_fire_event(self)
	time_since_last_burst_shot = modified_time_between_burst_shots
	rounds_fired_in_burst = 0
	firing_burst = true


func end_burst():
	time_since_last_burst_shot = 0
	rounds_fired_in_burst = 0
	firing_burst = false


func handle_burst(delta):
	if firing_burst:
		if current_ammo_count <= 0:
			end_burst()
		else:
			time_since_last_burst_shot += delta
			RPGEventMaster.invoke_rate_of_fire_event(self)
			if time_since_last_burst_shot >= modified_time_between_burst_shots:
				fire()
				time_since_last_burst_shot = 0
				rounds_fired_in_burst += 1
				if rounds_fired_in_burst >= shots_per_burst:
					end_burst()



# --------- Equipped Item Use Functions --------- #



func on_use_item_pressed():
	super()
	pull_trigger()


func on_use_item_released():
	super()
	release_trigger()


func on_alt_use_item_pressed():
	super()
	pull_alt_fire()


func on_alt_use_item_released():
	super()
	release_alt_fire()



# --------- Other Functions --------- #


func get_aiming_master() -> AimingMaster:
	return get_weapon_wielder().aiming_master


# generate_quantity_string() generates a string that is used to display the 
# quantity of this item in the inventory menu
func generate_quantity_string():
	return str(current_ammo_count)


func load_from_dictionary(load_dictionary):
	super(load_dictionary)
	
	if SaveLoadUtil.check_save_key_exists(load_dictionary, MAGAZINE_SAVE_KEY):
		assign_magazine_from_children()
		if magazine:
			magazine.load_from_dictionary(load_dictionary[MAGAZINE_SAVE_KEY])
		else:
			var saved_magazine = SaveLoadUtil.load_object_from_object_entry(load_dictionary[MAGAZINE_SAVE_KEY])
			if saved_magazine:
				insert_mag(saved_magazine)


func generate_save_dictionary():
	var save_dictionary = super()
	if not has_magazine_loaded():
		save_dictionary[MAGAZINE_SAVE_KEY] = null
	else:
		save_dictionary[MAGAZINE_SAVE_KEY] = magazine.generate_save_dictionary()
	
	return save_dictionary


func is_mag_full():
	return get_current_ammo_count() == get_max_ammo_count()


func has_magazine_loaded():
	return magazine != null


func is_reloading():
	return reload_master.is_reloading


# Virtual function
func get_recoil_per_shot() -> float:
	return recoil_per_shot 


func get_current_ammo_count():
	if magazine == null:
		return 0
	return magazine.current_quantity


func set_current_ammo_count(ammo):
	if magazine != null:
		magazine.current_quantity = ammo


func get_max_ammo_count():
	if magazine == null:
		return 0
	return magazine.max_quantity


func get_base_spread():
	return base_spread


func get_weapon_model() -> WeaponModel:
	return Util.get_player(self).player_model.get_weapon_mesh()


## Finds the gun mesh instance, and returns the ejection port object. This function may return null
## so make sure the invoker will HANDLE NULL RETURNS
func get_ejection_ports() -> Array[EjectionPort]:
	var result:Array[EjectionPort]
	var weapon_model : WeaponModel = get_weapon_model()
	
	if weapon_model:
		result = weapon_model.get_ejection_ports()
	return result


## @Override
func pull_trigger():
	super()
	if current_ammo_count <= 0:
		fired.emit(ammo_level.DRY)


## @Override
func pull_alt_fire():
	super()
	alt_fired.emit(get_current_ammo_level())


## Used in conjunction with sending fired and alt_fired signals
func get_current_ammo_level() -> ammo_level:
	assert(max_ammo_count > 0)
	var current_ammo_level := ammo_level.DRY 
	
	if max_ammo_count > 0 and current_ammo_count > 0:
		if current_ammo_count <= critical_ammo_amount:
			current_ammo_level = ammo_level.CRITICAL
		elif current_ammo_count <= low_ammo_amount:
			current_ammo_level = ammo_level.LOW
		else:
			current_ammo_level = ammo_level.HIGH
	
	return current_ammo_level
