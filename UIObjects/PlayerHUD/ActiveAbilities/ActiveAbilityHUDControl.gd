class_name ActiveAbilityHUDControl extends Control


# ----- Control References ----- #
var movement_ability_control: ActiveAbilityControl
var damage_ability_control: ActiveAbilityControl
var crowd_control_ability_control: ActiveAbilityControl
var buff_ability_control: ActiveAbilityControl

# ----- Model References ----- #
var player : Player



# --------- Ready and Assignment Functions --------- #


func _ready():
	movement_ability_control = Util.find_node_by_name(self, "MovementAbilityControl")
	damage_ability_control = Util.find_node_by_name(self, "DamageAbilityControl")
	crowd_control_ability_control = Util.find_node_by_name(self, "CrowdControlAbilityControl")
	buff_ability_control = Util.find_node_by_name(self, "BuffAbilityControl")


func assign_player(new_player : Player):
	player = new_player
	assign_abilities()


func assign_abilities():
	movement_ability_control.assign_ability(WarriorMaster.get_selected_warrior().equipped_movement_ability)
	damage_ability_control.assign_ability(WarriorMaster.get_selected_warrior().equipped_damage_ability)
	crowd_control_ability_control.assign_ability(WarriorMaster.get_selected_warrior().equipped_crowd_control_ability)
	buff_ability_control.assign_ability(WarriorMaster.get_selected_warrior().equipped_buff_ability)
