class_name HealEvent extends RPGEvent

# ----- Parameters ----- #
var healer_character : Character = null
var healed_character : Character = null
var heal_amount : float = 0

# ----- Modifiers ----- #
var heal_multiplicative_modifier : float = 1.0
var heal_additive_modifier : float = 0.0


func invoke_event():
	if healed_character != null:
		healed_character.rpg_mechanics_master.apply_event_modifiers_to_event(self)
		if healer_character != null:
			healer_character.rpg_mechanics_master.apply_event_modifiers_to_event(self)
		healed_character.rpg_mechanics_master.health.increase_stat(heal_amount)
	super()
