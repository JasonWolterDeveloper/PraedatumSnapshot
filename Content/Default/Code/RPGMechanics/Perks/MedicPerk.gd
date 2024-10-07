class_name MedicPerk extends RPGPerk

@export var heal_percentage_increase = 25.0

func apply_perk_effect(rpg_event : RPGEvent):
	if rpg_event is HealEvent:
		if rpg_event.healer_character == character:
			rpg_event.heal_amount = increase_value_by_percentage(rpg_event.heal_amount, heal_percentage_increase)
