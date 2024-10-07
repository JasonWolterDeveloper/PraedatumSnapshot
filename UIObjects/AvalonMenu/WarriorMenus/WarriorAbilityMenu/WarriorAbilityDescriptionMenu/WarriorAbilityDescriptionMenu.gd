class_name WarriorAbilityDescriptionMenu extends Control

# ---------- Constants ---------- #
const NONE_LABEL_TEXT = "None"


# ---------- Parent References ---------- #
var warrior_menu : WarriorMenu


# ---------- Required Model References ---------- #
var ability : RPGAbility

# ---------- Required UIElement References ---------- #
var name_label : Label
var point_cost_label : Label
var mana_cost_label : Label
var cooldown_label : Label
var description_label : RichTextLabel

# ---------- Required UI Scenes ---------- #


func _ready():
	name_label = Util.find_node_by_name(self, "NameLabel")
	point_cost_label = Util.find_node_by_name(self, "PointCostLabel")
	mana_cost_label = Util.find_node_by_name(self, "ManaCostLabel")
	description_label = Util.find_node_by_name(self, "DescriptionLabel")
	cooldown_label = Util.find_node_by_name(self, "CooldownLabel")



# ---------- Update Functions UI ---------- #


func update():
	update_name_label()
	update_description_label()
	update_point_cost_label()
	update_mana_cost_label()
	update_cooldown_label()


func update_name_label():
	name_label.text = str(ability.display_name)


func update_description_label():
	description_label.text = str(ability.description)


func update_point_cost_label():
	point_cost_label.text = str(ability.ability_point_cost)


func update_mana_cost_label():
	if ability.mana_cost <= 0:
		mana_cost_label.text = str(NONE_LABEL_TEXT)
	else:
		mana_cost_label.text = str(ability.mana_cost)
		
		
func update_cooldown_label():
	if ability.cooldown <= 0:
		cooldown_label.text = str(NONE_LABEL_TEXT)
	else:
		cooldown_label.text = str(ability.cooldown)



# ---------- Assignment Functions ---------- #   
   
	 
func assign_warrior_menu(new_warrior_menu : WarriorMenu):
	warrior_menu = new_warrior_menu


func assign_ability(new_ability : RPGAbility):
	ability = new_ability
	update()
