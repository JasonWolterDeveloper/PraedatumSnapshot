class_name DivineProtectionEventModifier extends RPGEventModifier


func apply_to_event(event : RPGEvent):
	if event is DamageEvent:
		if event.damaged_character == character:
			event.immune_to_damage = true
