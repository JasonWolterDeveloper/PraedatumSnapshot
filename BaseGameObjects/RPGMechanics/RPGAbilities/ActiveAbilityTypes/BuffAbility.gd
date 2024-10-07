class_name BuffAbility extends RPGAbility

@export var status_effect_scene : PackedScene


func can_equip_ability():
	for ability in warrior.ability_list:
		if ability is BuffAbility and ability.equipped:
			OnScreenMessageMaster.display_message("Cannot Equip More than One Buff Ability")
			return false
	return super()


func cast():
	var status_effect : RPGStatusEffect = status_effect_scene.instantiate()
	player.rpg_mechanics_master.add_status_effect(status_effect)
	
	pay_mana_cost()
	start_cooldown()


func attempt_cast():
	if check_sufficient_mana_to_cast():
		if not check_cooldown():
			cast()
		else:
			display_cooldown_message()
	else:
		display_not_enough_mana_message()


func ability_pressed_effect():
	attempt_cast()
