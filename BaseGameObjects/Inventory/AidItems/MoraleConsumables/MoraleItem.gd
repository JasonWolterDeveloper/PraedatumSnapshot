class_name MoraleItem extends UtilityItem

@export var morale_buff_scene : PackedScene


func use_utility():
	super()
	attempt_to_apply_morale_buff()


func attempt_to_apply_morale_buff():
	var morale_buff_master : MoraleBuffMaster = get_wielder().rpg_mechanics_master.morale_buff_master
	
	if morale_buff_master:
		var morale_buff : MoraleBuff = morale_buff_scene.instantiate()
		if morale_buff_master.check_can_refresh_or_add_morale_buff(morale_buff):
			morale_buff_master.attempt_add_or_refresh_morale_buff(morale_buff)
			current_quantity -= 1
		else:
			OnScreenMessageMaster.display_message("No More Space for Morale Buffs")
