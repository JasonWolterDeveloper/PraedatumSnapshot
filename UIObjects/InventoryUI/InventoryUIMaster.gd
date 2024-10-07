class_name InventoryUIMaster extends UIMenuMaster

const PLAYER_INVENTORY_SAVE_FILE = "player_inventory.txt"

var player_inventory_menu_packed_scene = preload("res://UIObjects/InventoryUI/InventoryMenuTemplates/PlayerInventoryUIMenu.tscn")
var loot_inventory_menu_packed_scene = preload("res://UIObjects/InventoryUI/InventoryMenuTemplates/LootInventoryUIMenu.tscn")
var currently_open_inventory_ui = null

# Variable added to stop the Interact key from just closing the inventory immediately
var menu_just_opened = true


func can_open_menu():
	if has_player():
		return super()


func open_player_inventory_menu():
	if can_open_menu():
		menu_open = true
		currently_open_inventory_ui = player_inventory_menu_packed_scene.instantiate()
		add_child(currently_open_inventory_ui)
		currently_open_inventory_ui.assign_inventory_ui_master(self)
		currently_open_inventory_ui.open_player_inventory(player.inventory)


func open_loot_inventory_menu(loot_storage):
	if can_open_menu():
		menu_open = true
		currently_open_inventory_ui = loot_inventory_menu_packed_scene.instantiate()
		add_child(currently_open_inventory_ui)
		currently_open_inventory_ui.assign_inventory_ui_master(self)
		currently_open_inventory_ui.open_loot_menu(player.inventory, loot_storage)


func close_inventory():
	menu_open = false
	remove_child(currently_open_inventory_ui)
	currently_open_inventory_ui.queue_free()
	currently_open_inventory_ui = null

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if accepting_input and Input.is_action_just_pressed("inventory"):
		if currently_open_inventory_ui != null:
			close_inventory()
		else:
			open_player_inventory_menu()
	# Since we can open loot inventories with interact, we want to be able to
	# close them with interact too
	if accepting_input and Input.is_action_just_pressed("interact") and not menu_just_opened:
		if currently_open_inventory_ui != null:
			close_inventory()
	if accepting_input and Input.is_action_just_pressed("ui_cancel"):
		if currently_open_inventory_ui and not currently_open_inventory_ui.item_detail_menu_control.is_open:
			close_inventory()
	if menu_open:
		menu_just_opened = false
	else:
		menu_just_opened = true

func save_storage_to_file(my_storage : Storage, file_path):
	var inventory_storage_file = FileAccess.open(file_path, FileAccess.WRITE)
	var storage_save_string = str(my_storage.generate_save_dictionary())
	inventory_storage_file.store_line(storage_save_string)
	inventory_storage_file.close()
	
func load_storage_from_file(my_storage : Storage, file_path):
	"""""
	var inventory_storage_file = FileAccess.open(file_path, FileAccess.READ)
	var storage_load_lines = inventory_storage_file.get_line()
	DebugMaster.log_debug("This is the line: " + storage_load_lines, DebugMaster.INVENTORY_DEBUG_CATEGORY)
	var my_storage_dictionary = Dictionary(storage_load_lines)
	"""
	
	var f = FileAccess.open(PLAYER_INVENTORY_SAVE_FILE, FileAccess.READ)
	var json_object = JSON.new()
	var file_text = f.get_as_text()
	DebugMaster.log_debug("This is the text: " + file_text, DebugMaster.INVENTORY_DEBUG_CATEGORY)
	var parse_err = json_object.parse(file_text)
	DebugMaster.log_debug("This is the error: " + str(json_object.get_error_message()), DebugMaster.INVENTORY_DEBUG_CATEGORY)
	my_storage.load_from_dictionary(json_object.get_data())
