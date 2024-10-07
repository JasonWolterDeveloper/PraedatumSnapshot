class_name DamageEventModifier extends RPGEventModifier

@export var additive_modifier : float = 0
@export var multiplicative_modifier : float = 0


func apply_to_event(event : RPGEvent):
	var damage_event = event as DamageEvent
	damage_event.damage_additive_modifier += additive_modifier
	damage_event.damage_multiplicative_modifier += multiplicative_modifier
