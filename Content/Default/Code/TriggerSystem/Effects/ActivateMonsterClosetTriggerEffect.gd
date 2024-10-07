class_name ActivateMonsterClosetTriggerEffect extends TriggerEffect


@export var monster_cloest_to_activate : MonsterClosetRoom


func activate_effect():
	if monster_cloest_to_activate:
		monster_cloest_to_activate.activate_monster_closet()
