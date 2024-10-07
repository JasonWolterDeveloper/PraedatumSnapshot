class_name RestoreOverTimeItem extends UtilityItem

@export var restoration_status_effect_scene : PackedScene

func apply_to_character(character : Character):
	var restoration_status_effect = restoration_status_effect_scene.instantiate()
	character.rpg_mechanics_master.add_status_effect(restoration_status_effect)
	

func use_on_self():
	apply_to_character(item_owner)
  
  
func use_utility():
	super()
	use_on_self()
	current_quantity -= 1
