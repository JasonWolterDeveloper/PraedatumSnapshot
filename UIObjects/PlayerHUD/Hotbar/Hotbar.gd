class_name Hotbar extends Control

# ----- Model Refs ----- #
var player : Player


# ----- Control Refs ----- #
var hot_bar_slot_controls : Array[HotbarSlotControl] = []
var hot_bar_slot_container : Container



# ---------- Ready and Assignment Functions ---------- #


func _ready():
	hot_bar_slot_container = Util.find_node_by_name(self, "HotbarSlotContainer")
	find_hot_bar_slot_controls()


func find_hot_bar_slot_controls():
	if hot_bar_slot_container:
		for my_child in hot_bar_slot_container.get_children():
			if my_child is HotbarSlotControl:
				hot_bar_slot_controls.append(my_child)


func assign_player(new_player : Player):
	player = new_player
	build_from_player_inventory()



# --------- Build/Update functions ---------- #


func build_from_player_inventory():
	if player and player.inventory:
		var current_index = 0
		for hot_bar_slot_control : HotbarSlotControl in hot_bar_slot_controls:
			var hot_bar_slot : HotbarSlot = player.inventory.get_hotbar_slot_by_index(current_index)
			if hot_bar_slot:
				hot_bar_slot_control.assign_hot_bar_slot(hot_bar_slot)
			current_index += 1
