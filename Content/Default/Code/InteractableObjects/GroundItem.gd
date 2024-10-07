extends InteractableObject

class_name GroundItem

var item : Item = null
var item_3d_model : Node3D = null

@export var loot_table : LootTable
@export var auto_spawn_loot = true

@onready var default_3d_model = $MeshInstance3D


func _ready():
	for my_child in get_children():
		if my_child is Item:
			setup_from_item(my_child)
	if auto_spawn_loot:
		var new_loot_table = find_loot_table()
		if new_loot_table:
				loot_table = new_loot_table
		if loot_table:
			fill_from_loot_table()


func find_loot_table():
	for my_child in get_children():
		if my_child is LootTable:
			return my_child


func setup_from_item(new_item):
	Util.force_add_child(self, new_item)
	item = new_item
	item_3d_model = item.generate_ground_3d_model()
	if item_3d_model:
		Util.force_add_child(self, item_3d_model)
		if default_3d_model:
			default_3d_model.hide()
	else:
		item_3d_model = default_3d_model


func activate(activator):
	super(activator)
	if item:
		if activator.inventory.can_fit_anywhere(item):
			# IMPORTANT: We must generate the display message before inserting the item, otherwise
			# it will cause the item's current quantity to be ZERO
			OnScreenMessageMaster.display_message(item.generate_pickup_message()) 
			activator.inventory.insert_anywhere(item)
			queue_free()


func generate_interaction_prompt():
	if item:
		return "Pick Up " + item.display_name
	return ""


func generate_interaction_prompt_subtext():
	if item and item.show_quantity_in_ui:
		return "Quantity: " + str(item.current_quantity)
	return ""


func fill_from_loot_table():
	if loot_table:
		var loot_item : Item = loot_table.roll_loot_table_for_item()
		setup_from_item(loot_item)
