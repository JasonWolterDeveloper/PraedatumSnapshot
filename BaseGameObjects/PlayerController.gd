class_name PlayerController extends Node3D

var universal_menu_master : UniversalMenuMaster = null
var crosshair_cursor = preload("res://UIObjects/Assets/Crosshair/Crosshair.png")
	
var level : Level = null

# If this is disabled, the player cannot control themselves
var disabled = false
	
signal set_aim_point
	
signal reset_movement

signal move_left
signal move_right
signal move_up
signal move_down

# ----- Weapon Signals ----- #

signal press_use_item
signal release_use_item

signal press_alt_use_item
signal release_alt_use_item

signal reload_weapon

# ----- Inventory and Hotbar Signals ----- #

signal swap_to_weapon_slot_1
signal swap_to_weapon_slot_2
signal swap_utility_item

signal swap_ammo_subtype

signal use_utility_item
signal release_utility_item
signal use_utility_alt

signal attemptInteraction
signal release_interaction

signal equip_hotbar_slot(index : int)

# ----- Ability Use Signals ----- #
signal press_damage_ability_button
signal release_damage_ability_button

signal press_crowd_control_ability_button
signal release_crowd_control_ability_button

signal press_buff_ability_button
signal release_buff_ability_button

signal press_movement_ability_button
signal release_movement_ability_button

signal walk_button


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	handle_movement(delta) # We should always handle movement
	if can_control():
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		# Input.set_custom_mouse_cursor(crosshair_cursor)
		handle_aiming(delta)
		handle_weapons(delta)
		handle_utility_items(delta)
		handle_inventory(delta)
		handle_rpg_mechanics(delta)
		handle_interaction(delta)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		# Input.set_custom_mouse_cursor(null)


func can_control() -> bool:
	return not (disabled or universal_menu_master.are_menus_open())


func handle_rpg_mechanics(delta):
	# Handling input for the damage ability
	if Input.is_action_just_pressed("use_damage_ability"):
		press_damage_ability_button.emit()
	if Input.is_action_just_released("use_damage_ability"):
		release_damage_ability_button.emit()

	# Handling input for the crowd control ability
	if Input.is_action_just_pressed("use_crowd_control_ability"):
		press_crowd_control_ability_button.emit()
	if Input.is_action_just_released("use_crowd_control_ability"):
		release_crowd_control_ability_button.emit()

	# Handling input for the buff ability
	if Input.is_action_just_pressed("use_buff_ability"):
		press_buff_ability_button.emit()
	if Input.is_action_just_released("use_buff_ability"):
		release_buff_ability_button.emit()

	# Handling input for the movement ability
	if Input.is_action_just_pressed("use_movement_ability"):
		press_movement_ability_button.emit()
	if Input.is_action_just_released("use_movement_ability"):
		release_movement_ability_button.emit()


func handle_aiming(delta):
	if not universal_menu_master.are_menus_open():
		if level:
			set_aim_point.emit(level.game_world_mouse_position)


func handle_movement(delta):
	reset_movement.emit()
	if can_control():
		if Input.is_action_pressed("move_left"):
			move_left.emit()
		if Input.is_action_pressed("move_right"):
			move_right.emit()
		if Input.is_action_pressed("move_up"):
			move_up.emit()
		if Input.is_action_pressed("move_down"):
			move_down.emit()
		if Input.is_action_pressed("walk_button"):
			walk_button.emit()


func handle_weapons(delta):
	if not universal_menu_master.are_menus_open():
		if Input.is_action_just_pressed("attack"):
			press_use_item.emit()
		if Input.is_action_just_released("attack"):
			release_use_item.emit()
		if Input.is_action_just_pressed("alt_fire"):
			press_alt_use_item.emit()
		if Input.is_action_just_released("alt_fire"):
			release_alt_use_item.emit()
		if Input.is_action_just_pressed("reload"):
			reload_weapon.emit()
		if Input.is_action_just_pressed("swap_ammo_subtype"):
			DebugMaster.log_debug("Controller is working")
			swap_ammo_subtype.emit()
	else:
		release_use_item.emit()
		release_alt_use_item.emit()
			
	"""
	if Input.is_action_just_pressed("aim_down_sight"):
		is_aiming_down_sight = true
		# max_speed = 150
		
	if Input.is_action_just_released("aim_down_sight"):
		is_aiming_down_sight = false
		# max_speed = 450
	"""


func handle_interaction(delta):
	if Input.is_action_just_pressed("interact"):
		attemptInteraction.emit()
	if Input.is_action_just_released("interact"):
		release_interaction.emit()


func handle_utility_items(delta):
	if not universal_menu_master.are_menus_open():
		if Input.is_action_just_pressed("use_utility"):
			use_utility_item.emit()
			
		if Input.is_action_just_released("use_utility"):
			release_utility_item.emit()
			
		if Input.is_action_just_pressed("use_utility_alt"):
			use_utility_alt.emit()


func handle_inventory(delta):
		if not universal_menu_master.are_menus_open():
			if Input.is_action_just_pressed("weapon_slot_1"):
				swap_to_weapon_slot_1.emit()
			if Input.is_action_just_pressed("weapon_slot_2"):
				swap_to_weapon_slot_2.emit()
			if Input.is_action_just_pressed("utility_swap"):
				swap_utility_item.emit()
			handle_hotbar_slots(delta)


func handle_hotbar_slots(delta):
	if not universal_menu_master.are_menus_open():
		if Input.is_action_just_pressed("hotbar_slot_0"):
			equip_hotbar_slot.emit(9)
		if Input.is_action_just_pressed("hotbar_slot_1"):
			equip_hotbar_slot.emit(0)
		if Input.is_action_just_pressed("hotbar_slot_2"):
			equip_hotbar_slot.emit(1)
		if Input.is_action_just_pressed("hotbar_slot_3"):
			equip_hotbar_slot.emit(2)
		if Input.is_action_just_pressed("hotbar_slot_4"):
			equip_hotbar_slot.emit(3)
		if Input.is_action_just_pressed("hotbar_slot_5"):
			equip_hotbar_slot.emit(4)
		if Input.is_action_just_pressed("hotbar_slot_6"):
			equip_hotbar_slot.emit(5)
		if Input.is_action_just_pressed("hotbar_slot_7"):
			equip_hotbar_slot.emit(6)
		if Input.is_action_just_pressed("hotbar_slot_8"):
			equip_hotbar_slot.emit(7)
		if Input.is_action_just_pressed("hotbar_slot_9"):
			equip_hotbar_slot.emit(8)
