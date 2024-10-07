extends ItemHolderUI

class_name StorageUI

# The actual storage item this container represents
var storage : Storage = null


func update():
	super()
	if storage:
		build_from_storage(storage)


func build_from_storage(new_storage):
	storage = new_storage
	generate_size_from_grid_squares()
	build_item_dominos_from_items()


func build_item_dominos_from_items():
	for item in storage.get_items():
		var new_item_domino = make_item_domino_from_item(item)
		Util.force_add_child(self, new_item_domino)


func make_item_domino_from_item(new_item : Item):
	var new_item_domino = ITEM_DOMINO_SCENE.instantiate()
	new_item_domino.build_from_item(new_item)
	return new_item_domino


func get_grid_square_width():
	if storage != null:
		return storage.grid_square_width
	else:
		return grid_square_width


func get_grid_square_height():
	if storage != null:
		return storage.grid_square_height
	else:
		return grid_square_height


func get_item_holder():
	return storage
