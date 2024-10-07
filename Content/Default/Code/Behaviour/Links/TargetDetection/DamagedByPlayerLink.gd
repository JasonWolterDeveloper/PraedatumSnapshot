class_name DamagedByPlayerLink extends Link

var new_target_character : Character
var has_been_attacked : bool = false


func is_triggered():
	if has_been_attacked:
		target_character = new_target_character
		can_see_target = true
		return true
	return false


func on_entry():
	super()
	new_target_character = null
	has_been_attacked = false


func on_exit():
	super()
	new_target_character = null
	has_been_attacked = false


func on_character_damaged(damage_event : DamageEvent):
	if damage_event.should_notify_ai_of_damager:
		if damage_event.damager_character:
			has_been_attacked = true
			new_target_character = damage_event.damager_character


func init():
	super()
	my_character.rpg_mechanics_master.damage_event_signal.connect(on_character_damaged)
