class_name WarriorAbilityButton extends Control

# ---------- Parent References ---------- #
var warrior_ability_menu : WarriorAbilityMenu

# ----- Necessary Model Variables ----- #
var ability : RPGAbility

# ----- UI Element References ----- #
var ability_name_label : Label
var point_cost_label : Label
var ability_button : Button
var equipped_indicator : Control
var unequipped_indicator : Control


func _ready():
	ability_name_label = Util.find_node_by_name(self, "AbilityNameLabel")
	point_cost_label = Util.find_node_by_name(self, "PointCostLabel")
	ability_button = Util.find_node_by_name(self, "AbilityButton")
	equipped_indicator = Util.find_node_by_name(self, "EquippedIndicator")
	unequipped_indicator = Util.find_node_by_name(self, "UnequippedIndicator")


func update():
	ability_name_label.text = ability.display_name
	point_cost_label.text = str(ability.ability_point_cost)
	if ability.equipped:
		equipped_indicator.show()
		unequipped_indicator.hide()
	else:
		equipped_indicator.hide()
		unequipped_indicator.show()



# ---------- Assignment Functions ---------- #


func assign_ability(new_ability: RPGAbility):
	ability = new_ability
	update()


func assign_warrior_ability_menu(new_warrior_ability_menu : WarriorAbilityMenu):
	warrior_ability_menu = new_warrior_ability_menu



# ---------- Button Functions ---------- #


func _on_button_pressed():
	if ability.equipped:
		ability.attempt_unequip_ability()
	else:
		ability.attempt_equip_ability()
	on_equipped_abilities_changed()
   

func on_hover():
	show_description_for_ability()



# ---------- Bubble Up Functions ---------- #
		
		
func show_description_for_ability():
	if warrior_ability_menu:
		warrior_ability_menu.show_description_for_ability(ability)


func on_equipped_abilities_changed():
	update()
	if warrior_ability_menu:
		warrior_ability_menu.on_equipped_abilities_changed()
