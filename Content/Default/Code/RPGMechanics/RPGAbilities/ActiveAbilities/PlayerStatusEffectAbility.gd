class_name PlayerStatusEffectAbility extends RPGAbility

@export var status_effect_scene : PackedScene


func cast():
	var status_effect : RPGStatusEffect = status_effect_scene.instantiate()
	player.rpg_mechanics_master.add_status_effect(status_effect)
	
	pay_mana_cost()


func attempt_cast():
	if check_sufficient_mana_to_cast():
		cast()
	else:
		display_not_enough_mana_message()


func ability_pressed_effect():
	attempt_cast()
