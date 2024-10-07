class_name RPGAbility extends Node

## Indicates that this passively modifies a stat. Must be checked to passively modify a stat even
## if we have stat modifiers. An ability can be both active and passive
@export var is_passive: bool = false

## Indicates that an ability can be actively used in game. Must be checked for an ability to be 
## usable. An ability can be both active and passive
@export var is_active: bool = false

@export var rpg_stat_modifiers : Array[RPGStatModifier] = []
@export var rpg_event_modifiers : Array[RPGEventModifier] = []

@export var mana_cost : float = 0.0

@export var cooldown: float = 0.0
var is_in_cooldown : bool = false
var cool_down_current_time : float = 0.0

@export var ability_id: String = ""
@export var ability_point_cost : int = 1

@export var display_name : String = ""
@export_multiline var description : String = ""
@export var not_enough_mana_message : String = "Insufficient Mana"

# indicates whether or not the ability is equipped
@export var equipped : bool = false

# Indicates whether or not we have pressed down the ability button with this as the active ability
# This will allow us to do a few things, such as showing the impact prediction UI if this is for an
# AoE ability. In situations where the ability gets activated when the button is released instead of
# on pressed, this variable will help us deal with situations where the player presses the ability
# button, then swaps selected abilities, then releases the button
var pressed : bool = false

# We should have access to the player as we need to know a lot of information about the player
# such as where their position is and where they are aiming
var player : Player

# It is important to have rpg_mechanics_master reference so we can check mana costs etc. if we are
# a usable ability
var rpg_mechanics_master: RPGMechanicsMaster

# We should have a reference to our own Warrior
var warrior : Warrior


func assign_rpg_mechanics_master(new_rpg_mechanics_master: RPGMechanicsMaster):
	rpg_mechanics_master = new_rpg_mechanics_master


func assign_warrior(new_warrior : Warrior):
	warrior = new_warrior


func assign_player(new_player : Player):
	player = new_player



# ---------- Equip Functions---------- #


func attempt_equip_ability():
	if can_equip_ability():
		warrior.equip_ability(self)


func attempt_unequip_ability():
	warrior.unequip_ability(self)


func can_equip_ability():
	if warrior:
		if warrior.get_available_ability_points() >= ability_point_cost:
			return true
		else:
			OnScreenMessageMaster.display_message("Not enough ability points to equip " + str(display_name))
			return false
	return false 



# ---------- Selection Functions---------- #


func on_selected():
	OnScreenMessageMaster.display_message("Selected " + str(display_name))
	pass


func on_deselected():
	pressed = false



# ---------- Active Ability Functions---------- #


# Function called when an ability key is pressed. Should NOT be overridden
func on_ability_pressed():
	if player != null:
		pressed = true
		ability_pressed_effect()


# Function called when an ability key is released. Should NOT be overridden
func on_ability_released():
	# We should ONLY call our ability released effect if we have previously pressed
	# the ability button with this ability selected
	if player != null and pressed:
		pressed = false
		ability_released_effect()


# Effect function for when the ability key is pressed. Should be overridden
func ability_pressed_effect():
	pass


# Effect function for when the ability key is released. Should be overridden
func ability_released_effect():
	pass


func pay_mana_cost():
	RPGEventMaster.invoke_pay_mana_cost_event(mana_cost)


func check_sufficient_mana_to_cast():
	if player != null and player.rpg_mechanics_master.mana.value >= mana_cost:
		return true
	return false


func display_not_enough_mana_message():
	OnScreenMessageMaster.display_message(not_enough_mana_message)


# --------- Cooldown Functions ---------- #


func start_cooldown() -> void:
	is_in_cooldown = true
	cool_down_current_time = cooldown


func end_cooldown() -> void:
	is_in_cooldown = false
	cool_down_current_time = 0.0


func check_cooldown() -> bool:
	return is_in_cooldown


func handle_cooldown(delta : float) -> void:
	if is_in_cooldown:
		cool_down_current_time -= delta
		
		if cool_down_current_time <= 0:
			end_cooldown()


func display_cooldown_message():
	OnScreenMessageMaster.display_message(str(display_name) + " is on cooldown")


func calculate_cooldown_percentage() -> float:
	# Ensure that the cooldown is not zero to avoid division by zero
	if cooldown <= 0:
		return 0.0

	# Calculate the percentage left
	var percentage_left: float = (1.0 - (cool_down_current_time / cooldown)) * 100.0

	# Ensure the percentage is within the range [0, 100]
	return clamp(percentage_left, 0.0, 100.0)



# ---------- Ability Process Functions---------- #


## Does anything that should be handled every process frame for an RPGAbility
func ability_process(delta : float) -> void:
	handle_cooldown(delta)
