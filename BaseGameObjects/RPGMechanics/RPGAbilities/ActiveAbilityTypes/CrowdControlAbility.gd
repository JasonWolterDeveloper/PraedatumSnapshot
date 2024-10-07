class_name CrowdControlAbility extends RPGAbility


func can_equip_ability():
	for ability in warrior.ability_list:
		if ability is CrowdControlAbility and ability.equipped:
			OnScreenMessageMaster.display_message("Cannot Equip More than One Crowd Control Ability")
			return false
	return super()
