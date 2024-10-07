class_name LootObject extends InteractableObject

@export var storage : Storage

@export var loot_table : LootTable
@export var auto_spawn_loot = true
@export var loot_tables : Array[LootTable] = []

@export var empty_aesthetics : Node3D
@export var not_empty_aesthetics : Node3D



# -------- Ready and Assignment Functions -------- #


func _ready():
	allow_if_activated = true # Loot Items should allow if activated, just in case you forget
	fill_from_children()
	if auto_spawn_loot:
		fill_from_loot_table()
	
	if storage:
		storage.changed.connect(handle_storage_changed)
	
	update_aesthetics()


func fill_from_children():
	for my_child in get_children():
		if my_child is Item:
			storage.insert_anywhere(my_child)


func fill_from_loot_table():
	# find_loot_tables()
	if loot_tables:
		for my_loot_table in loot_tables:
			fill_from_single_loot_table(my_loot_table)
	elif loot_table:
		fill_from_single_loot_table(loot_table)


func fill_from_single_loot_table(fill_loot_table : LootTable):
	var loot_array : Array[Item] = fill_loot_table.roll_loot_table_for_item_array()
	for my_item in loot_array:
		if my_item:
			storage.insert_anywhere(my_item)



# -------- Use Functions --------- #


func activate(activator):
	super(activator)
	get_level().get_inventory_ui_master().open_loot_inventory_menu(storage)


func handle_storage_changed():
	update_aesthetics()



# --------- Aesthetics --------- #


func show_empty_aesthetics():
	if empty_aesthetics:
		empty_aesthetics.show()
	if not_empty_aesthetics:
		not_empty_aesthetics.hide()


func show_non_empty_aesthetics():
	if empty_aesthetics:
		empty_aesthetics.hide()
	if not_empty_aesthetics:
		not_empty_aesthetics.show()


func update_aesthetics():
	super()
	if storage.is_empty():
		show_empty_aesthetics()
	else:
		show_non_empty_aesthetics()

"""
func find_loot_tables():
	loot_tables.clear()
	for my_child in get_children():
		if my_child is LootTable:
			loot_tables.append(my_child)
"""
