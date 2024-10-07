class_name ItemDetailMenuControl extends Control

# ----- Scene References ----- #
@export var ItemStatEntryControl : PackedScene

# ----- Model References ----- #

## item is the Item this menu is displaying
var item : Item

# ----- Control References ----- #
# Buttons
var equip_button : Button
var use_button : Button
var drop_button : Button
var close_button : Button
var dismantle_button:Button

# Labels
var display_name_label : Label
var description_label : RichTextLabel

# Other
var item_image : TextureRect
var stat_grid : Container
var item_detail_menu_panel : PanelContainer
var stat_vbox : Container

# Parent Control References
var inventory_ui_menu : InventoryUIMenu

# ----- Variables ----- #
var is_open : bool = false



# ---------- Ready and Assignment Functions --------- #


func _ready():
	# Button Assignments
	equip_button = Util.find_node_by_name(self, "EquipButton")
	drop_button = Util.find_node_by_name(self, "DropButton")
	close_button = Util.find_node_by_name(self, "CloseButton")
	use_button = Util.find_node_by_name(self, "UseButton")
	dismantle_button = Util.find_node_by_name(self, "DismantleButton")
	
	# Label Assignments
	display_name_label = Util.find_node_by_name(self, "DisplayNameLabel")
	description_label = Util.find_node_by_name(self, "DescriptionLabel")
	
	# Other Assignments
	item_image = Util.find_node_by_name(self, "ItemImage")
	item_detail_menu_panel = Util.find_node_by_name(self, "ItemDetailMenuPanel")
	stat_grid = Util.find_node_by_name(self, "StatGrid")
	stat_vbox = Util.find_node_by_name(self, "StatVbox")


func assign_inventory_ui_menu(new_inventory_ui_menu : InventoryUIMenu) -> void:
	inventory_ui_menu = new_inventory_ui_menu


func assign_item(new_item : Item):
	item = new_item
	update()
 
 
 
# ---------- Update Functions ----------- #


func update():
	update_item_image()
	
	update_equip_button()
	update_drop_button()
	update_use_button()
	update_dismantle_button()
	
	update_display_name_label()
	update_stat_grid()
	update_description_label()


func update_equip_button():
	if item and item.is_equippable() and player_inventory_has_item():
		equip_button.show()
	else:
		equip_button.hide()


func update_use_button():
	if item and item.can_use_from_inventory() and player_inventory_has_item():
		use_button.show()
	else:
		use_button.hide()


func update_drop_button():
	if item and player_inventory_has_item():
		drop_button.show()
	else:
		drop_button.hide()


func update_dismantle_button() -> void:
	if item and player_inventory_has_item() and DismantleMaster.recipe_exists(item):
		dismantle_button.show()
	else:
		dismantle_button.hide()

func update_item_image():
	if item:
		item_image.texture = item.inventory_image
	else:
		item_image.texture = null
 
 
func update_display_name_label():
	if item:
		display_name_label.text = item.display_name
	else:
		display_name_label.text = ""


func update_stat_grid():
	Util.delete_all_children(stat_grid)
	if is_instance_valid(item) and item.item_stat_entry_collection:
		stat_vbox.show()
		for item_stat_entry : ItemStatEntry in item.item_stat_entry_collection.stat_entry_array:
			var new_entry_control = ItemStatEntryControl.instantiate()
			stat_grid.add_child(new_entry_control)
			new_entry_control.assign_item_stat_entry(item_stat_entry)    
	else:
		stat_vbox.hide()
		

func update_description_label():
	if item:
		description_label.text = item.description
	else:
		description_label.text = ""
 

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
 
 
func drop_item():
	if player_inventory_has_item():
		get_player_inventory().drop_item(item)
		update_inventory_ui_menu()
		close()


func equip_item():
	if player_inventory_has_item():
		get_player_inventory().equip_item(item)
		update_inventory_ui_menu()


func use_item():
	if player_inventory_has_item():
		item.use_from_inventory()
		update_inventory_ui_menu()
		close()


func dismantle_item() -> void:
	if DismantleMaster.dismantle(item):
		update_inventory_ui_menu()
		close()
	else:
		OnScreenMessageMaster.display_message("Could not dismantle " + str(item))


func player_inventory_has_item():
	if item:
		var inventory : Inventory = get_player_inventory()
		var has_item = inventory .has_given_item(item)
		return has_item
	return false
		 
 
func get_player_inventory() -> Inventory:
	return GameMaster.get_player().inventory
