class_name ItemPopupLabel extends Control

# ----- Model References ----- #

## item is the Item this menu is displaying
var item : Item

# ----- Control References ----- #
# Labels
var display_name_label : Label

# Parent Control References
var inventory_ui_menu : InventoryUIMenu

# ----- Variables ----- #
var is_open : bool = false



# ---------- Ready and Assignment Functions --------- #


func _ready():	
	# Label Assignments
	display_name_label = Util.find_node_by_name(self, "DisplayNameLabel")


func assign_inventory_ui_menu(new_inventory_ui_menu : InventoryUIMenu) -> void:
	inventory_ui_menu = new_inventory_ui_menu


func assign_item(new_item : Item):
	item = new_item
	update()
 
 
 
# ---------- Update Functions ----------- #


func update():
	update_display_name_label()
 
 
func update_display_name_label():
	if item:
		display_name_label.text = item.display_name
	else:
		display_name_label.text = ""


func update_inventory_ui_menu():
	if inventory_ui_menu:
		inventory_ui_menu.update()

 
 
 # ---------- Utility Functions ---------- #
 
 
func open():
	show()
	is_open = true
	 
	 
func close():
	hide()
	is_open = false
 
 
func get_player_inventory() -> Inventory:
	return GameMaster.get_player().inventory
