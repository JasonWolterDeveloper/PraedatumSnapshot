class_name Player extends Character

@onready var attack_raycast = $AttackRayCast

@onready var explosive_charge_prediction_master : ExplosiveChargePredicitonMaster = $ExplosiveChargePredictionMaster

@onready var inventory : Inventory = $Inventory
	
@onready var controller : PlayerController = $PlayerController

@onready var camera : Camera3D = $CameraGimbal/InnerGimbal/Camera3D

@onready var interaction_raycast : RayCast3D = $LookStuff/InteractionRaycast
# The interactable object we would interact with right now based on raycast
var current_interactable_object : InteractableObject
# The Interactable Object we are holding down the button to interact with
var hold_interaction_object  : InteractableObject
@onready var ghost_interaction_area : Area3D = $InteractionGhostArea

@onready var player_model : PlayerModel = $LookStuff/PlayerModel
@onready var aiming_laser: AimingLaser = $LookStuff/AimingLaser
@onready var should_turn_off_laser_raycast : RayCast3D = $LookStuff/ShouldTurnOffLaserRaycast
@onready var ai_sound_generator : AISoundGenerator = $AISoundGenerator
## Used to indicate what enemy should display their health, name, title etc
@onready var enemy_info_display_area : Area3D = $EnemyInfoDisplayArea
# Keeping track of the enemy we displayed our info for in the last frame
var previous_enemy_info_displayed : Enemy = null


var non_hitscan_projectile_spawn_marker : Marker3D

@export var disable_control : bool = false
	
var is_aiming_down_sight = false

var prev_weapon = null

func _ready():
	super()
	update_model_weapon()
	WarriorMaster.assign_player(self)
	
	# We will only ever have one player at a time so we assign ourselves to the 
	# game master here
	GameMaster.assign_player(self)
	if disable_control:
		controller.disabled = true
	non_hitscan_projectile_spawn_marker = Util.find_node_by_name(self, "NonHitscanProjectileSpawnMarker")
	
	# Calling this here because it can't be updated properly before we assign ourselves
	# to the game master
	# TODO - Change this to be better
	inventory.update_inventory_size()


func get_non_hitscan_projectile_spawn_location():
	return non_hitscan_projectile_spawn_marker.global_position
	
	
func on_death():
	super()
	inventory.clear()
	# get_level().return_to_hub_level()


func get_aiming_master():
	return aiming_master
	
	
func allow_input():
	return not dead


# ---------- PLAYER CONTROL SIGNAL FUNCTIONS ---------- #
	
func set_aim_point(new_aim_point):
	if not stunned:
		aiming_master.aim_point = new_aim_point
	
	
func reset_directional_movement():
	movement_master.reset_directional_movement()
	movement_master.walking = false


func walk():
	movement_master.walking = true
	
	
func move_left():
	if not stunned:
		movement_master.move_left()
	
	
func move_right():
	if not stunned:
		movement_master.move_right()
	
	
func move_up():
	if not stunned:
		movement_master.move_up()
	
	
func move_down():
	if not stunned:
		movement_master.move_down()


func on_press_damage_ability_button():
	WarriorMaster.press_damage_ability()


func on_release_damage_ability_button():
	WarriorMaster.release_damage_ability()


func on_press_crowd_control_ability_button():
	WarriorMaster.press_crowd_control_ability()


func on_release_crowd_control_ability_button():
	WarriorMaster.release_crowd_control_ability()


func on_press_buff_ability_button():
	WarriorMaster.press_buff_ability()


func on_release_buff_ability_button():
	WarriorMaster.release_buff_ability()


func on_press_movement_ability_button():
	WarriorMaster.press_movement_ability()


func on_release_movement_ability_button():
	WarriorMaster.release_movement_ability()


func press_use_equipped_item():
	if not stunned:
		if get_equipped_item() is Item:
			get_equipped_item().on_use_item_pressed()
	
	
func release_use_equipped_item():
	if get_equipped_item() is Item:
		get_equipped_item().on_use_item_released()
	
	
func press_alt_use_item():
	if not stunned:
		if get_equipped_item() is Item:
			get_equipped_item().on_alt_use_item_pressed()
	
	
func release_alt_use_item():
	if get_equipped_item() is Item:
		get_equipped_item().on_alt_use_item_released()
	
	
func reload_weapon():
	if not stunned:
		if get_equipped_item() is Gun:
			get_equipped_item().reload()


func swap_ammo_subtype():
	if not stunned:
		if get_equipped_item() is Gun:
			get_equipped_item().cycle_ammo_subtype()
		
		
func is_reloading():
	if not stunned:
		if get_equipped_item() is Gun:
			return get_equipped_item().is_reloading()

"""
func use_utility():
	if not stunned:
		if utility_item:
			if utility_item is ExplosiveChargeUtilityItem and utility_item.can_place_charge():
				explosive_charge_prediction_master.simulate_explosion_from_explosive_charge_item(utility_item, utility_item.find_placement_position())


func release_utility():
	if not stunned:
		if utility_item:
			if utility_item is ExplosiveChargeUtilityItem:
					if utility_item.can_place_charge():
						utility_item.place_explosive_charge()
"""


func attempt_interaction():
	if not stunned:
		if current_interactable_object:
			current_interactable_object.attempt_interaction(self)
			
			if current_interactable_object.hold_use:
				hold_interaction_object = current_interactable_object


func release_interaction():
	if is_instance_valid(hold_interaction_object):
		hold_interaction_object.notify_no_longer_being_held()


func update_ongoing_interaction(delta : float) -> void:
	if Input.is_action_pressed("interact"):
		if is_instance_valid(hold_interaction_object) and current_interactable_object == hold_interaction_object:
			hold_interaction_object.notify_has_been_held(delta)
		elif is_instance_valid(hold_interaction_object) and current_interactable_object != hold_interaction_object:
			hold_interaction_object.notify_no_longer_being_held()


func attempt_equip_hotbar_slot_by_index(index : int):
	inventory.attempt_equip_hotbar_slot_by_index(index)


func update_model_animation(delta):
	var velocity_to_set = Vector3.ZERO
	if velocity.length() > 1:
		velocity_to_set = velocity.normalized()
	player_model.set_movement_direction(to_global(velocity_to_set))


func update_player_model_pose_from_equipped_item() -> void:
	if get_equipped_item():
		if get_equipped_item().player_pose == "pistol":
			player_model.enter_pistol_state()
		elif get_equipped_item().player_pose == "rifle":
			player_model.enter_rifle_state()
		elif get_equipped_item().player_pose == "melee":
			player_model.enter_melee_state()
		else:
			player_model.enter_unarmed_state()
	else:
		player_model.enter_unarmed_state()


func update_model_weapon() -> void:
	if get_equipped_item() and get_equipped_item() is Weapon:
		if get_equipped_item() != prev_weapon:
			prev_weapon = get_equipped_item()
			if get_equipped_item().weapon_model_scene:
				var new_weapon_model : WeaponModel = get_equipped_item().weapon_model_scene.instantiate()
				player_model.add_weapon_mesh(new_weapon_model, get_equipped_item().player_pose)
				new_weapon_model.assign_weapon(get_equipped_item())
			else:
				player_model.remove_weapon_mesh()
	else:
		prev_weapon = null
		player_model.remove_weapon_mesh()


func check_aiming_laser_colliding_with_wall():
	should_turn_off_laser_raycast.global_position.y = PhysicsConstants.LOS_HEIGHT
	var cast_point = should_turn_off_laser_raycast.to_local(aiming_laser.global_position)
	should_turn_off_laser_raycast.target_position = cast_point
   
	should_turn_off_laser_raycast.force_raycast_update()
	var hit_object = should_turn_off_laser_raycast.get_collider()
	
	if hit_object != null:
		return true
	return false
	
		
func update_aiming_laser(delta):
	var weapon_model : WeaponModel = player_model.get_weapon_mesh()
	
	if weapon_model and get_equipped_item() is Gun:		
		aiming_laser.set_global_origin_position(weapon_model.get_laser_start_position())
		if check_aiming_laser_colliding_with_wall():
			aiming_laser.turn_laser_off()
		else:
			aiming_laser.turn_laser_on()
	else:
		aiming_laser.turn_laser_off()


func get_bullet_start_pos():
	var weapon_model : WeaponModel = player_model.get_weapon_mesh()
	
	if weapon_model:
		return weapon_model.get_bullet_start_position()
	else:
		return $LookStuff/BulletOrigin.global_position


func get_real_bullet_start_pos():
	return $LookStuff/BulletOrigin.global_position
		
		
func update_interactable_object_from_raycast(delta):
	current_interactable_object = null # Reset old value
	
	var collision_object = interaction_raycast.get_collider()
	if collision_object:
		if collision_object is InteractableObject:
			collision_object.on_selected_interaction_object_for_activator(self)
			current_interactable_object = collision_object


func update_interaction_ghosts_from_area():
	for my_body in ghost_interaction_area.get_overlapping_bodies():
		if my_body is InteractableObject:
			my_body.on_enter_interaction_ghost_area_for_activator(self)
  

"""
func handle_update_explosive_charge_predicition_master():
	if utility_item and utility_item is ExplosiveChargeUtilityItem:
		if utility_item.can_place_charge() and Input.is_action_pressed("use_utility"):
			explosive_charge_prediction_master.simulate_explosion_from_explosive_charge_item(utility_item, utility_item.find_placement_position())
			return
		if utility_item.charge_to_detonate:
			explosive_charge_prediction_master.simulate_explosion_from_placed_explosive_charge(utility_item.charge_to_detonate)
			return
	explosive_charge_prediction_master.clear_all_simulated_explosions()
"""


func generate_ai_sound(sound_range : float):
	ai_sound_generator.make_ai_sound(sound_range)


func _process(delta):
	update_aiming_laser(delta)
	if get_equipped_item():
		get_equipped_item().handle_equipped(delta)
	update_player_model_pose_from_equipped_item()
	update_model_weapon()
	update_interactable_object_from_raycast(delta)
	update_interaction_ghosts_from_area()
	update_enemy_info_display()
	update_ongoing_interaction(delta)


func _physics_process(delta):
	update_model_animation(delta)
	if allow_input():
		pass



# --------- Enemy Info Display --------- #


func enemy_info_update_position():
	enemy_info_display_area.global_position = aiming_master.aim_point


func update_enemy_info_display():
	enemy_info_update_position()
	
	var closest_distance = null
	var current_closest_enemy : Enemy = null
	
	for body in enemy_info_display_area.get_overlapping_bodies():
		if body is Enemy:
			var distance = body.global_position.distance_to(enemy_info_display_area.global_position)
			if (closest_distance == null or distance < closest_distance):
				closest_distance = distance
				current_closest_enemy = body
				
	if is_instance_valid(previous_enemy_info_displayed):
		previous_enemy_info_displayed.hide_info_display()
	 
	if is_instance_valid(current_closest_enemy):
		current_closest_enemy.show_info_display()
		previous_enemy_info_displayed = current_closest_enemy



# --------- Getters ---------- #

# @Override
func get_armour() -> Armour:
	if inventory:
		return inventory.get_armour()
	return null


func get_backpack() -> Backpack:
	if inventory:
		return inventory.get_backpack()
	return null


func get_equipped_item() -> Item:
	if inventory and is_instance_valid(inventory.equipped_item):
		return inventory.equipped_item
	else:
		return null
