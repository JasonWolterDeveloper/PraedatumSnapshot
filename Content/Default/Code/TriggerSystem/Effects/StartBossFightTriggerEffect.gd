class_name  StartBossFightTriggerEffect extends TriggerEffect

@export var enemy : Enemy


func activate_effect():
	if enemy:
		BossUIMaster.start_boss_fight(enemy)
