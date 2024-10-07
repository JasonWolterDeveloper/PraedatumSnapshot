extends Control

# ----- Model References ----- #
var player : Player

# ----- Control References ----- #
var armour_bar : HealthBar
var player_health_bar : HealthBar
var mana_bar : HealthBar



# ---------- Ready and Assignment Functions ---------- #


func _ready():
	armour_bar = Util.find_node_by_name(self, "ArmourBar")
	player_health_bar = Util.find_node_by_name(self, "PlayerHealthBar")
	mana_bar = Util.find_node_by_name(self, "ManaBar")


func assign_player(new_player : Player):
	player = new_player
	assign_player_recursive(new_player, self)
	player_health_bar.assign_stat(player.rpg_mechanics_master.health)
	mana_bar.assign_stat(player.rpg_mechanics_master.mana)
	
	
func assign_player_recursive(new_player : Player, node):
	for child in node.get_children():
		if child.has_method("assign_player"):
			child.assign_player(new_player)
		# Recursively call the function on the child node
		assign_player_recursive(new_player, child)



# ---------- Update Functions ----------- #


func _process(delta):
	if player:
		if player.rpg_mechanics_master.armour:
			armour_bar.assign_stat(player.rpg_mechanics_master.armour.armour_points_stat)
		else:
			armour_bar.assign_stat(null)
