class_name DamageAbility extends RPGAbility


func can_equip_ability():
	for ability in warrior.ability_list:
		if ability is DamageAbility and ability.equipped:
			OnScreenMessageMaster.display_message("Cannot Equip More than One Damage Ability")
			return false
	return super()
