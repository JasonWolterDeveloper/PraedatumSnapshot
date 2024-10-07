class_name WarriorStatusMenu extends Control

# ---------- Parent References ---------- #
var warrior_menu : WarriorMenu

# ----- Control References ----- #
var armour_bar : HealthBar
var health_bar : HealthBar
var mana_bar : HealthBar


func assign_warrior_menu(new_warrior_menu : WarriorMenu):
	warrior_menu = new_warrior_menu
	
	armour_bar = Util.find_node_by_name(self, "ArmourBar")
	health_bar = Util.find_node_by_name(self, "PlayerHealthBar")
	mana_bar = Util.find_node_by_name(self, "ManaBar")


func assign_player_and_warrior_recursive(node=self):
	for child in node.get_children():
		if child.has_method("assign_warrior"):
			child.assign_warrior(WarriorMaster.get_selected_warrior())
		if child.has_method("assign_player"):
			child.assign_player(GameMaster.get_player())
		assign_player_and_warrior_recursive(child)


func update():
	assign_player_and_warrior_recursive()

	if GameMaster.get_player():
		if armour_bar:
			if GameMaster.get_player().rpg_mechanics_master.armour:
				armour_bar.assign_stat(GameMaster.get_player().rpg_mechanics_master.armour.armour_points_stat)
			else:
				armour_bar.assign_stat(null)
		if health_bar:
			health_bar.assign_stat(GameMaster.get_player().rpg_mechanics_master.health)
		if mana_bar:
			mana_bar.assign_stat(GameMaster.get_player().rpg_mechanics_master.mana)
