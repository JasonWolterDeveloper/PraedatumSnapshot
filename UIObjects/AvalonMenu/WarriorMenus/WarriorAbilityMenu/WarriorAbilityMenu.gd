class_name WarriorAbilityMenu extends Control

# ---------- Parent References ---------- #
var warrior_menu : WarriorMenu

# ---------- Required Model References ---------- #
var warrior : Warrior

# ---------- Required UIElement References ---------- #
var ability_button_container : Container

var damage_ability_button_container: Container
var crowd_control_ability_button_container: Container
var buff_ability_button_container: Container
var movement_ability_button_container: Container

# ---------- Required UI Scenes ---------- #
@export var ability_button_scene : PackedScene


func _ready():
	ability_button_container = Util.find_node_by_name(self, "AbilityButtonContainer")
	
	damage_ability_button_container = Util.find_node_by_name(self, "DamageAbilityButtonContainer")
	crowd_control_ability_button_container = Util.find_node_by_name(self, "CrowdControlAbilityButtonContainer")
	buff_ability_button_container = Util.find_node_by_name(self, "BuffAbilityButtonContainer")
	movement_ability_button_container = Util.find_node_by_name(self, "MovementAbilityButtonContainer")



# ---------- Ability Button Setup ---------- #


# Function to clean up WarriorAbilityButton children
func clear_existing_ability_buttons_for_container(container: Container) -> void:
	if container:
		for child in container.get_children():
			if child is WarriorAbilityButton:
				container.remove_child(child)
				child.queue_free()


func clear_existing_ability_buttons():
	clear_existing_ability_buttons_for_container(ability_button_container)
	
	clear_existing_ability_buttons_for_container(damage_ability_button_container)
	clear_existing_ability_buttons_for_container(crowd_control_ability_button_container)
	clear_existing_ability_buttons_for_container(buff_ability_button_container)
	clear_existing_ability_buttons_for_container(movement_ability_button_container)
   

func populate_ability_buttons_from_warrior():
	if warrior:
		for ability : RPGAbility in warrior.ability_list:
			var ability_button =  ability_button_scene.instantiate()
			
			if ability is DamageAbility:
				damage_ability_button_container.add_child(ability_button)
			elif ability is CrowdControlAbility:
				crowd_control_ability_button_container.add_child(ability_button)
			elif ability is BuffAbility:
				buff_ability_button_container.add_child(ability_button)
			elif ability is MovementAbility:
				movement_ability_button_container.add_child(ability_button)
			else:
				ability_button_container.add_child(ability_button)
				
			ability_button.assign_ability(ability) 
			ability_button.assign_warrior_ability_menu(self)
  


# ---------- Assignment Functions ---------- #
  
	
func assign_warrior(new_warrior : Warrior):
	warrior = new_warrior
	
	clear_existing_ability_buttons()
	populate_ability_buttons_from_warrior()


func assign_warrior_menu(new_warrior_menu : WarriorMenu):
	warrior_menu = new_warrior_menu



# ---------- Bubble Up/Down Functions ---------- # 


func show_description_for_ability(ability : RPGAbility):
	if warrior_menu:
		warrior_menu.show_description_for_ability(ability)


func on_equipped_abilities_changed():
	if warrior_menu:
		warrior_menu.on_equipped_abilities_changed()
