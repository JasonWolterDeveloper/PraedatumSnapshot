## Global Class for managing the UI during boss battles
extends Control

@onready var boss_health_bar : BossUIHealthBar = $BossUIHealthBar


func start_boss_fight(boss_enemy : Character):
	boss_health_bar.set_my_character(boss_enemy)
	boss_health_bar.display()


func end_boss_fight(boss_enemy : Character):
	boss_health_bar.undisplay()
