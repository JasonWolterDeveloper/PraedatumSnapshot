class_name PistolReloadEventModifier extends RPGEventModifier


## RPGEventModifier modifies a particular event in soem way, for example, increasing
## damage in a damage event if the player is shooting at an enemy they are particularly
## good at destroying

@export var modification_amount : float = 0.5


# This is an entirely abstract function, it must be overriden for every RPGEventModifier
# We decided to do this because each RPGEventModifier is going to be too bespoke to make
# a generic class for
func apply_to_event(event : RPGEvent):
	super(event)
	if event is ReloadEvent:
		if event.reload_master.weapon.rpg_tags.has_tag("pistol"):
			event.reload_time_multiplicative_modifier -= modification_amount
			event.perfect_zone_length_multiplicative_modifier += modification_amount
