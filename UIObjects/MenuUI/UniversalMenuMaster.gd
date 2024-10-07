class_name UniversalMenuMaster extends Node

var menu_list : Array[UIMenuMaster] = []
var quest_ui_menu_master : QuestUIMenuMaster


func _ready():
	quest_ui_menu_master = Util.find_node_by_name(self, "QuestUIMenuMaster")
	populate_menu_list()
	

func populate_menu_list():
	menu_list.clear()
	for child in get_children():
		if child is UIMenuMaster:
			menu_list.append(child)


# Function to check if any menus are open
func are_menus_open() -> bool:
	for my_menu in menu_list:
		if my_menu.is_menu_open():
			return true
	return false
	
	
# some nodes need direct access to the inventory UI Master
func get_inventory_ui_master():
	return $InventoryUIMaster


func get_shop_menu_master() -> ShopMenuMaster:
	return $ShopMenuMaster


func assign_player(player : Player):
	for my_menu in menu_list:
		my_menu.assign_player(player)


func set_accepting_input(value: bool):
	for my_menu in menu_list:
		my_menu.set_accepting_input(value)


func assign_level(level : Level):
	for my_menu in menu_list:
		my_menu.assign_level(level)
