extends ItemHolder

class_name Storage

const ITEMS_SAVE_KEY = "items"

func load_items_from_array(items_array):
	for item_entry in items_array:
		load_item_from_item_entry(item_entry)


func load_from_dictionary(inventory_dictionary):
	load_items_from_array(inventory_dictionary[ITEMS_SAVE_KEY])


func generate_item_save_array():
	var item_save_array = []
	for my_item in get_items():
		item_save_array.append(my_item.generate_save_dictionary())
		
	return item_save_array


func generate_save_dictionary():
	var storage_save_dict = super()
	storage_save_dict[ITEMS_SAVE_KEY] = generate_item_save_array()

	return storage_save_dict


func get_items():
	var items = []
	for my_child in get_children():
		if my_child is Item:
			items.append(my_child)
	return items


func is_empty():
	return not get_items()


func clear():
	for item in get_items():
		item.queue_free()


# getAdjustedInventoryRect() takes an item and optionally a position for that
# item and returns a Rect2 whose origin is the item's position and whose size
# is equal to the inventory size of the given item
func generate_adjusted_inventory_rect(item : Item, item_position=null):
	# ItemDominos hold their own positions so we grab the position from the
	# domino here, if not given one
	if item_position == null:
		item_position = item.grid_position
	
	# Generate an inventory rectangle from the item_domino representing the space it takes
	# up in the grid based inventory system
	var inventory_rect = item.generate_inventory_rect()
	
	# If we have been given an item_position, we replace the inventory_rect's current position
	# with the given one. This could be necessary because the item_domino is currently picked
	# up and therefore its rect position is invalid.
	inventory_rect.position = Vector2(item_position)
		
	return inventory_rect


"""
# checkItemCollideGridSquare() takes an item, a location for that item, and an
# inventory grid square and returns true if the given grid square is inside the
# item
func checkItemCollideGridSquare(myItem, itemLocation, gridSquare):
	var newRect = getAdjustedInventoryRect(myItem, itemLocation)
	if newRect.collidepoint(gridSquare[0], gridSquare[1]):
		return true
	return false


# checkExistingItemCollideGridSquare() takes in an item that is in the inventory
# and a grid square and returns true if the item contains that grid square
func checkExistingItemCollideGridSquare(myItem, gridSquare):
	return checkItemCollideGridSquare(myItem, null, gridSquare)
"""

# checkItemCollideGridSquare() takes an item, a location for that item, and an
# inventory grid square and returns true if the given grid square is inside the
# item
func check_item_collide_grid_square(my_item, item_location, grid_square):
	var new_rect = generate_adjusted_inventory_rect(my_item, item_location)
	if new_rect.collidepoint(grid_square[0], grid_square[1]):
		return true
	return false


# checkExistingItemCollideGridSquare() takes in an item that is in the inventory
# and a grid square and returns true if the item contains that grid square
func check_existing_item_collide_grid_square(my_item, grid_square):
	return check_item_collide_grid_square(my_item, null, grid_square)


func check_rect_collision_with_existing_item(rect, existing_item):
	var existing_item_inventory_rect = generate_adjusted_inventory_rect(existing_item)
	
	if rect.intersects(existing_item_inventory_rect):
		return existing_item
	return null


# checkItemCollideExistingItem() takes in an item, the position the item is
# being inserted and an item that is already in the inventory and returns true
# if they would overlap
func check_new_item_collision_with_existing_item(new_item, item_position, existing_item):
	var new_item_inventory_rect = generate_adjusted_inventory_rect(new_item, item_position)
	var existing_item_inventory_rect = generate_adjusted_inventory_rect(existing_item)
	
	if new_item_inventory_rect.intersects(existing_item_inventory_rect):
		DebugMaster.log_debug(str(new_item) + "Colliding with " + str(existing_item) + "At " + str(item_position), DebugMaster.INVENTORY_DEBUG_CATEGORY)
		DebugMaster.log_debug(str(new_item) + "rect: " + str(new_item_inventory_rect) + "  " + str(existing_item) + "rect: " + str(existing_item_inventory_rect), DebugMaster.INVENTORY_DEBUG_CATEGORY)
		return true
	return false


## check_new_item_collision_with_rect is used to check if an item collides with an arbitrary rect
## We will use this for testing inserting arrays of inventory item
func check_new_item_collision_with_rect(new_item, item_position, rect):
	var new_item_inventory_rect = generate_adjusted_inventory_rect(new_item, item_position)
	if new_item_inventory_rect.intersects(rect):
		return true
	return false


## ditto check_new_item_collision_with_rect except we check a whole array with this function
func check_new_item_collision_with_rect_array(new_item, item_position, rect_array):
	for my_rect in rect_array:
		if check_new_item_collision_with_rect(new_item, item_position, my_rect):
			return true
	return false


# checkItemCollideExistingItem() takes in an item, the position the item is
# being inserted and an item that is already in the inventory and returns true
# if they would overlap
func find_new_item_collision_with_existing_item(new_item, item_position):
	var new_item_inventory_rect = generate_adjusted_inventory_rect(new_item, item_position)
	
	for existing_item in get_items():
		var existing_item_inventory_rect = generate_adjusted_inventory_rect(existing_item)
		
		if new_item_inventory_rect.intersects(existing_item_inventory_rect):
			return existing_item
	return null


func check_item_in_inventory_bounds(new_item, item_position):
	var inventory_rect = generate_adjusted_inventory_rect(new_item, item_position)
	
	if inventory_rect.position.x < 0 or inventory_rect.position.y < 0 or inventory_rect.end.x > grid_square_width or inventory_rect.end.y > grid_square_height:
		DebugMaster.log_debug(str(new_item) + "Is out of bounds at" + str(item_position), DebugMaster.INVENTORY_DEBUG_CATEGORY)
		return false
	return true


func check_rect_in_inventory_bounds(rect):
	if rect.position.x < 0 or rect.position.y < 0 or rect.end.x > grid_square_width or rect.end.y > grid_square_height:
		return false
	return true


func can_rect_fit(rect, pos):
	rect.position = pos
	
	if not check_rect_in_inventory_bounds(rect):
		return false
		
	for my_item in get_items():
		if check_rect_collision_with_existing_item(rect, my_item):
			return false
	return true


func can_fit(new_item, pos, collide_self=false):
	if not check_item_in_inventory_bounds(new_item, pos):
		return false

	for my_item in get_items():
		if not collide_self and new_item == my_item:
			continue
		if check_new_item_collision_with_existing_item(new_item, pos, my_item):
			return false
	return true


func can_fit_anywhere(new_item, collide_self=false):
	if find_stack_with_existing_item_no_leftovers(new_item):
		return true
	return find_fit_square(new_item) != null


func find_empty_squares(rect, start_square=Vector2(0,0)):
	var top_left_square = start_square
	var fit_square = null
	var found = false
	while not found:
		if can_rect_fit(rect, top_left_square):
			found = true
			fit_square = top_left_square
		else:
			if top_left_square[0] < grid_square_width:
				top_left_square = Vector2(top_left_square[0] + 1, top_left_square[1])
			elif top_left_square[1] < grid_square_height:
				top_left_square = Vector2(0, top_left_square[1] + 1)
			else:
				break
	return fit_square


## existing rects is a list of existing rects we want to check against for the fit square. This is
## mostly used for checking for array fits
func find_fit_square(new_item, start_square=Vector2(0, 0), existing_rects : Array = []):
	var top_left_square = start_square
	var fit_square = null
	var found = false
	while not found:
		if can_fit(new_item, top_left_square) and not check_new_item_collision_with_rect_array(new_item, top_left_square, existing_rects):
			found = true
			fit_square = top_left_square
		else:
			if top_left_square[0] < grid_square_width:
				top_left_square = Vector2(top_left_square[0] + 1, top_left_square[1])
			elif top_left_square[1] < grid_square_height:
				top_left_square = Vector2(0, top_left_square[1] + 1)
			else:
				break
	return fit_square


func insert_anywhere(item_to_be_inserted : Item):
	# We attempt to stack our item on other items first
	var has_been_completely_stacked = attempt_complete_stack(item_to_be_inserted)
	
	# If we can't completely stack our item, we find a fit square for it
	if not has_been_completely_stacked:
		var fit_square = find_fit_square(item_to_be_inserted)
		if fit_square != null:
			insert(item_to_be_inserted, fit_square)


# Attempts to stack our item_to_be_stacked into other items in this storage until
# there is no quantity of our item left. If there is none left, we return true
# otherwise we return false
func attempt_complete_stack(item_to_be_stacked : Item):
	var has_completely_stacked = false
	for my_item in get_items():
		if item_to_be_stacked.can_stack_with_item(my_item):
			if item_to_be_stacked.can_stack_with_item_no_leftovers(my_item):
				item_to_be_stacked.stack(my_item)
				has_completely_stacked = true
				break
			else:
				item_to_be_stacked.stack(my_item)
	changed.emit()
	return has_completely_stacked


func find_item_of_type(type):
	for my_item : Item in get_items():
		if is_instance_of(my_item, type):
			return my_item
	return null


func find_all_items_of_type(type):
	var item_list : Array[Item] = []
	for my_item : Item in get_items():
		if is_instance_of(my_item, type):
			item_list.append(my_item)
	return item_list


func find_item_with_id(item_id: String):
	for my_item : Item in get_items():
		if my_item.item_id == item_id:
			return my_item
	return null


func find_all_items_with_id(item_id : String):
	var item_list : Array[Item] = []
	for my_item : Item in get_items():
		if my_item.item_id == item_id:
			item_list.append(my_item)
	return item_list


func find_quantity_of_items_with_id(item_id : String) -> int:
	var total_quantity:int = 0
	var item_list = find_all_items_with_id(item_id)
	for my_item : Item in item_list:
		total_quantity += my_item.current_quantity
	
	return total_quantity


func remove_quantity_of_item_with_item_id(quantity : int, item_id : String):
	var item_array : Array[Item] = find_all_items_with_id(item_id)
	var removal_array : Array[Item] = []
	var quantity_left_to_remove = quantity
	
	for my_item : Item in item_array:
		if my_item.current_quantity <= quantity_left_to_remove:
			quantity_left_to_remove -= my_item.current_quantity
			removal_array.append(my_item)
		else:
			my_item.current_quantity -= quantity_left_to_remove
			quantity_left_to_remove = 0
	
	for my_item : Item in removal_array:
		remove(my_item)
		my_item.queue_free()


func can_interact(item : Item, item_position : Vector2):
	var overlap_item = find_new_item_collision_with_existing_item(item, item_position)
	
	# We should ignore ourselves when checking if we can interact
	if overlap_item and overlap_item != item:
		if item.can_interact_with_item(overlap_item):
			return overlap_item
	return false


func find_stack_with_existing_item_no_leftovers(new_item : Item):
	for my_item in get_items():
		if my_item.can_stack_with_item_no_leftovers(new_item):
			return my_item
	return null


func find_stack_with_existing_item(new_item : Item):
	for my_item in get_items():
		if new_item.can_stack_with_item(my_item):
			return my_item
	return null


func insert_item_array(item_array : Array[Item]):
	for my_item : Item in item_array:
		if can_fit_anywhere(my_item):
			insert_anywhere(my_item)
		else:
			return false
	return true


func does_item_array_fit(item_array : Array[Item]):
	# We keep track of the hypothetical rects an item would occupy if it was inserted to check for
	# collisions with other items in our array
	var existing_fit_rects : Array = []
	
	for my_item in item_array:
		var my_item_position = find_fit_square(my_item, Vector2(0, 0), existing_fit_rects)
		
		if my_item_position != null:
			existing_fit_rects.append(generate_adjusted_inventory_rect(my_item, my_item_position))
		else:
			return false
	
	return true


"""

func getPickedUpItemCanMerge():
	return pickedUpItemCanMerge

func setPickedUpItemCanMerge(value):
	pickedUpItemCanMerge = value

func getPickedUpItemCanFit():
	return pickedUpItemCanFit

func setPickedUpItemCanFit(value):
	pickedUpItemCanFit = value

func isInventoryUIManagerHoveredContainer():
	if getInventoryUIManager():
		return getInventoryUIManager().getHoveredItemHolderUI() == self

func isLoadoutSlot():
	return representsLoadoutSlot

func getInstantTransferDestination():
	return instantTransferDestination

func setInstantTransferDestination(destination):
	instantTransferDestination = destination

func getInventoryUIManager():
	return get_parent().getInventoryUIManager()

func getItemHolder():
	return itemHolder

func createDominoForItem(item):
	var itemposition = getItemHolder().getItemLocation(item)

	# We only want to create a domino for an item if it is actually in the container we're representing
	if itemLocation != null:
		var theItemDomino = itemDominoScene.instance()
		Util.forceAddChild(self, theItemDomino)
		theItemDomino.set_owner(self)
		theItemDomino.setItem(item)

		# Positioning the domino in this container panel
		positionItemDomino(theItemDomino, itemLocation)
		
		return theItemDomino
	return null

# findItemDominoForItem() returns the item domino for the given item if there is an item domino for the item in this
# container, and none otherwise
func findItemDominoForItem(item):
	for myChild in get_children():
		if myChild.has_method("getItem"):
			if myChild.getItem() == item:
				return myChild
	return null

# addVisualizationForItem() creates and adds the item domino for a single item to this container panel.
func addVisualizationForItem(item):
	var itemDomino = createDominoForItem(item)

# removeVisualizationForItem(item) checks if there is an item domino for this item in this panel and removes it if
# it exists
func removeVisualizationForItem(item):
	var itemDomino = findItemDominoForItem(item)

	if itemDomino:
		remove_child(itemDomino)

# Creates and positions ItemDominoes for every item in the inventory this panel is visualizing, and adds them to
# this panels contents. Does NOT remove the original contents
func populateItemDominoes():
	for myItem in getItemHolder().getItems():
		addVisualizationForItem(myItem)

# resetPickedUpItemStatus() resets the information on whether or not the item picked up by the player in the
# inventoryUIManager can be either transferred or merged into this container
func resetPickedUpItemStatus():
	setPickedUpItemCanFit(false)
	setPickedUpItemCanMerge(false)

# updatePickedUpItemStatus() checks the inventoryUIManager to see if we are the currently hovered Panel, and, if
# we are, updates this panel indicating whether or not the player is holding an item that can be transferred to this
# panel or merged into another item in this panel. We check this because our graphics may change based on the
# information
func updatePickedUpItemStatus():
	if isInventoryUIManagerHoveredContainer():
		setPickedUpItemCanFit(getInventoryUIManager().checkPickedUpItemFit())
		setPickedUpItemCanMerge(getInventoryUIManager().checkPickedUpItemMerge())
	else:
		resetPickedUpItemStatus()
	
func updateGridSquaresFromItemHolder():
	gridSquareWidth = itemHolder.getGridSquareWidth()
	gridSquareHeight = itemHolder.getGridSquareHeight()
	
func setItemHolder(myItemHolder):
	itemHolder = myItemHolder
	updateToMatchItemHolder()

# updateToMatchContainer() should be called every time the inventory container that this panel is meant to visaulize
# is changed. This fully resets this panel and readds all of the item dominos to it to reflect the new state of the
# inventory container
func updateToMatchItemHolder():
	updateGridSquaresFromItemHolder()
	setSizeFromGridSquares()
	# removing all dominoes we are currently tracking - NO LONGER DOING THIS
	# removeAllItemDominos()
	# adding all the dominoes we SHOULD be tracking

	populateItemDominoes()
	
func getItemDominoAtMouse():
	return getItemDominoAtPos(get_global_mouse_position())
	
func getItemDominoAtPos(pos):
	for myChild in get_children():
		if myChild.is_class(CustomClassConstants.ITEM_DOMINO_CLASS_NAME):
			if myChild.get_global_rect().has_point(pos):
				return myChild
	return null
	
func is_class(type): 
	return type == CustomClassConstants.INVENTORY_CONTAINER_ITEM_HOLDER_CLASS_NAME or .is_class(type)
	
func get_class():
	return CustomClassConstants.INVENTORY_CONTAINER_ITEM_HOLDER_CLASS_NAME

	
	
	
	
extends ItemHolder

# The inventory class is used by all game objects that need to contain items
class_name Inventory

# Contains a list of items as keys, with the values being the [x,y] coordinated in the inventory of the item's
# top lefthand corner
var itemLocationDictionary = {}

# The number of gridSquareHeight and gridSquareWidth displayed in the UI for this inventory
var gridSquareWidth = 8
var gridSquareHeight = 10

# The amount of money that the inventory has. This will be used exclusively for the player... maybe
var money = 0  # persist

func _ready():
	for myChild in get_children():
		if myChild.is_class(CustomClassConstants.ITEM_CLASS_NAME):
			insertAnywhere(myChild)

# clear() removes all of the items including those in loadout slots from the inventory
func clear():
	itemLocationDictionary = {}

func isEmpty():
	for myKey in getItemLocationDictionary():
		if getItemLocationDictionary()[myKey] != null:
			return false

	return true

# getDataType() returns the dataType string for saving this object to a SaveString statement
func getDataType():
	return SaveStringTokens.inventoryObjectDataEntryType

func incrementMoney(newMoney):
	money = money + newMoney

# gets all of the items in this inventory as a list
func getItemNameList():
	return getItemLocationDictionary().keys()

# checkMerge(newItem, pos) returns true if there's an item colliding with the item at the given position that the
# item can merge with
func checkMerge(newItem, pos):
	for myItem in getItems():
		if myItem == newItem:
			continue
		if checkItemCollideExistingItem(newItem, pos, myItem) and myItem.checkCanStack(newItem):
			# Even if the item can stack, if its full, we shouldn't try to merge
			if not myItem.isFull():
				return myItem
	return null

func insert(newItem, pos):
	# Adding the item as a child of this inventory object if it is not already
	if get_node(newItem.name) == null or get_node(newItem.name) != newItem:
		Util.forceAddChild(self, newItem)
	getItemLocationDictionary()[newItem.name] = pos

func remove(myItem):
	if getItemLocationDictionary().has(myItem.name):
		getItemLocationDictionary().erase(myItem.name)
		
		# Removing the child as well
		remove_child(get_node(myItem.name))

### INV ###
func findFitSquare(theItem, startPt=Vector2(0, 0)):
	var topLeftSquare = startPt
	var fitSquare = null
	var found = false
	while not found:
		if canFit(theItem, topLeftSquare):
			found = true
			fitSquare = topLeftSquare
		else:
			if topLeftSquare[0] < gridSquareWidth:
				topLeftSquare = Vector2(topLeftSquare[0] + 1, topLeftSquare[1])
			elif topLeftSquare[1] < gridSquareHeight:
				topLeftSquare = Vector2(0, topLeftSquare[1] + 1)
			else:
				break
	return fitSquare
	# return fitSquare

func insertAnywhere(o):
	var fitSquare = findFitSquare(o)
	insert(o, fitSquare)

func getItemAtGridSquare(gridSquare):
	for myItem in getItems():
		if checkExistingItemCollideGridSquare(myItem, gridSquare):
			return myItem
	return null

# checkHasItem(checkItem, number) returns true if have enough of a certain item in this inventory. checkItem is an
# item object of the type we are checking, and 'number' is how many of it we need
func checkHasItem(checkItem, number=1):
	# The number of checkItem items we've found in our inventory
	var numberOfItemWeHave = 0
	for myItem in getItems():
		if checkItem.qualifiesAsThisItem(myItem):
			numberOfItemWeHave = numberOfItemWeHave + myItem.getStack()
			if numberOfItemWeHave >= number:
				return true
	if numberOfItemWeHave >= number:
		return true
	return false

# deductItem(checkItem, number) Checks through all the item in the list, trying to remove a certain amount of a
# certain kind of item from the inventory. checkItem is an item object of the type we are trying to remove. 'number'
# is the number we are trying to remove
func deductItem(checkItem, number=1):
	var amountToDeduct = number

	# We loop through all items in the item dictionary not only to find the item we need, but also to check multiple
	# stacks for the item if necessary
	for myItem in getItems():
		if checkItem.qualifiesAsThisItem(myItem):

			# Determining the difference between the amount of items we need to deduct and the amount of items in
			# this stack
			var theDifference = amountToDeduct - myItem.stack

			# If there are more items in the stack than we need to deduct, simply take the amount to deduct away
			# from the stack
			if theDifference < 0:
				myItem.deduct(amountToDeduct)
				amountToDeduct = 0
			# If there are equal to or more items to deduct than there are in the stack, we remove the stack
			# entirely and adjust the number to deduct accordingly
			else:
				remove(myItem)
				amountToDeduct = amountToDeduct - myItem.stack

			# If we don't need to deduct any more items, we return true
			if amountToDeduct <= 0:
				return true
	# If amount to deduct is greater than 0, we return false
	return false

# getItemLocation returns the the top left location of the item in this inventory's grid system. If the item is not
# in this inventory, this returns null
func getItemLocation(item):
	# The item dictionary is a dictionary with all of the items in this inventory as keys, and their grid
	# locations as values. Therefore, the value assigned to this particular key if it exists, is the location for
	# our item
	if item.name in getItemLocationDictionary():
		return getItemLocationDictionary()[item.name]
	return null
	
# getHolder returns the object that this inventory "belongs" to. If this 
# inventory is an actor's inventory, it returns the actor, if this belongs to
# a loot crate, it returns the loot crate
func getHolder():
	return get_owner()
	
# Because we keep the item locations in the itemLocationDict as Vector2s, we 
# need a special function to save the itemLocationDictionary to file
func makeItemLocationSaveDict():
	var itemLocationSaveDict = {}
	for myKey in getItemLocationDictionary():
		itemLocationSaveDict[myKey] = var2str(getItemLocationDictionary()[myKey])
	return itemLocationSaveDict
	
# Because we keep the item locations in the itemLocationDict as Vector2s, we 
# need a special function to load the itemLocationDictionary from file
func loadItemLocationDict(saveDict):
	# resetting the itemLocationDictionary
	setItemLocationDictionary({})
	for myKey in saveDict:
		getItemLocationDictionary()[myKey] = str2var(saveDict[myKey])
	
func makeSaveDict():
	var saveDict = {
		SaveLoadConsts.fileNameSaveDictKey : get_filename(),
		"money" : money,
	}

	# Custom_Dev_Lines_Start
	
	saveDict["itemLocationDictionary"] = makeItemLocationSaveDict()
	
	# Saving each individual inventory item
	for myItemName in getItemNameList():
		var itemToSave = get_node(myItemName)
		saveDict[myItemName] = itemToSave.makeSaveDict()
	
	# Custom_Dev_Lines_End

	return saveDict

func loadFromSaveDict(saveDict):
	money = saveDict["money"]


	# Custom_Dev_Lines_Start
	loadItemLocationDict(saveDict["itemLocationDictionary"])
	
	# Loading each individual item from file. Note that if the item already 
	# exists, we shoul delete it. Also note that we must do this AFTER loading
	# the itemLocationDictinary as that is where we get our item names
	for myItemName in getItemNameList():
		if get_node(myItemName):
			remove_child(get_node(myItemName))
			
		var newItem = SaveLoadUtil.instanceNodeFromSaveDict(saveDict[myItemName])
		newItem.name = myItemName
		Util.forceAddChild(self, newItem)
		newItem.loadFromSaveDict(saveDict[myItemName])
		
	# Custom_Dev_Lines_End


##### Getters and Setters #####


func getItemLocationDictionary():
	return itemLocationDictionary

func setItemLocationDictionary(val):
	itemLocationDictionary = val

func getGridSquareWidth():
	return gridSquareWidth
	
func setGridSquareWidth(val):
	gridSquareWidth = val

func getGridSquareHeight():
	return gridSquareHeight

func setGridSquareHeight(val):
	gridSquareHeight = val

func getMoney():
	return money

func setMoney(newMoney):
	money = newMoney


func getModel():
	return Util.getModel(self)
"""
