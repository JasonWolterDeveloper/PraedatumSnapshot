class_name WarriorMenu extends Control

# ---------- Required Model References ---------- #
var warrior : Warrior

# ---------- Required UIElement References ---------- #
var warrior_ability_menu : WarriorAbilityMenu
var warrior_status_menu : WarriorStatusMenu
var warrior_ability_description_menu : WarriorAbilityDescriptionMenu
var warrior_select_menu : WarriorSelectMenu

# ---------- Required UI Scenes ---------- #


func _ready():
	warrior_ability_menu = Util.find_node_by_name(self, "WarriorAbilityMenu")
	warrior_status_menu = Util.find_node_by_name(self, "WarriorStatusMenu")
	warrior_select_menu = Util.find_node_by_name(self, "WarriorSelectMenu")
	warrior_ability_description_menu = Util.find_node_by_name(self, "WarriorAbilityDescriptionMenu")
	assign_to_submenus()


func assign_to_submenus():
	warrior_ability_menu.assign_warrior_menu(self)
	warrior_status_menu.assign_warrior_menu(self)
	warrior_ability_description_menu.assign_warrior_menu(self)
	warrior_select_menu.assign_warrior_menu(self)


func update():
	assign_warrior(WarriorMaster.get_selected_warrior())


func on_warrior_changed():
	update()


func assign_warrior(new_warrior : Warrior):
	warrior = new_warrior
	warrior_ability_menu.assign_warrior(warrior)
	warrior_status_menu.update()
	
	
func show_description_for_ability(ability : RPGAbility):
	warrior_ability_description_menu.assign_ability(ability)
	
	
func on_equipped_abilities_changed():
	warrior_status_menu.update()
	
