extends Node

class_name RPGPerk

var character : Character:
	get: return Util.get_character_parent(self)

# The apply order variable determines in what order perks are applied to RPGEvents
# This is to ensure consistent behaviour between additive and multiplicative perks
# Lower apply_order Perks go first

# Example: A damage buff that increases damage by 10% with an apply_order of 0
# and a damage buff that increases damage by 10 with an apply_order of 1
# applied to a damageEvent that does 20 damage would increase to 32 damage
@export var apply_order = 0

# This variable should be true for perks that can only be applied once to events
# this helps us get around situations such as:

# where a character has a perk that increases healing capabilities when they are
# the healer, but they are also the character being healed, leading to a double 
# application
@export var only_apply_once = true

@export var activatable = false
@export var maximum_number_of_uses : int = 1
@export var remaining_uses : int = 1

# For displaying the perk in the UI, should be populated by the PerkTreeEntry
var perk_graphic : Texture


static func apply_order_sort(a : RPGPerk, b : RPGPerk):
	if a.apply_order < b.apply_order:
		return true
	return false
	
	
# activate_if_possible is a helper function that should not change between different
# perks that checks if we have any remaining uses for a perk, calls activate_perk if we
# do, which actually performs the perk action, then deducts one use from the remaining
# uses
func activate_if_possible():
	if remaining_uses > 0 and activation_conditions():
		activate()
		remaining_uses -= 1
		
		
# Any other conditions that need to be true to activate the perk should be
# checked here
func activation_conditions() -> bool:
	return true
	
	
# Actually does what activating the perk is supposed to do
func activate():
	pass
	

func apply_perk(rpg_event : RPGEvent):
	if not only_apply_once or not rpg_event.has_applied_perk(self):
		rpg_event.add_applied_perk(self)
		apply_perk_effect(rpg_event)
	
	
func apply_perk_effect(rpg_event : RPGEvent):
	return
	
	
# The following are helper functions for adjusting values inside of RPGEvents:
func increase_value(value, amount):
	return value + amount
	
	
func decrease_value(value, amount):
	return value - amount
	
	
func multiply_value(value, amount):
	return value * amount
	
	
func increase_value_by_percentage(value, percentage):
	var multiply_amount = 1.0 + (percentage/100.0)
	return multiply_value(value, multiply_amount)
	
	
func decrease_value_by_percentage(value, percentage):
	var multiply_amount = 1.0 - (percentage/100.0)
	return multiply_value(value, multiply_amount)
