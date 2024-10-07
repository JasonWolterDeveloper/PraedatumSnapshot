class_name EnemyInfoDisplay extends Sprite3D

var character : Character
@onready var health_bar = $SubViewport/VBoxContainer/HealthBar
@onready var name_label = $SubViewport/VBoxContainer/PanelContainer/MarginContainer/NameLabel


func _ready():
	hide()


func set_my_character(new_character : Character):
	character = new_character
	health_bar.assign_stat(new_character.rpg_mechanics_master.health)
	name_label.text = character.display_name
	
