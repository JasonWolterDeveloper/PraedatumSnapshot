extends Control

# ----- Required Control References ----- #
var ammo_type_label : Label

# ----- Required Model References ----- #
var player : Player


func _ready():
	ammo_type_label = Util.find_node_by_name(self, "AmmoTypeLabel")


func assign_player(new_player : Player):
	player = new_player


func update():
	hide()
	
	if player:
		if player.get_equipped_item() is Gun:
			ammo_type_label.text = str(player.get_equipped_item().magazine.selected_ammo_subtype)
			show()


func _process(delta):
	update()
