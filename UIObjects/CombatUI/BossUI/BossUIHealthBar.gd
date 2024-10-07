class_name BossUIHealthBar extends Control

var character : Character
@onready var boss_name_label : Label = $VBoxContainer/Label
var health_bar : HealthBar


func _ready():
	health_bar = Util.find_node_by_name(self, "HealthBar")
	

func set_my_character(new_character : Character):
	character = new_character
	update_boss_name()
	
	health_bar.assign_stat(character.rpg_mechanics_master.health)


func update_boss_name():
	if character:
		boss_name_label.text = character.display_name

func display():
	show()


func undisplay():
	hide()
