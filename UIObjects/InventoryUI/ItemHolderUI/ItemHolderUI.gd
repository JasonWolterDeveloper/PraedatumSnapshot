extends InventoryUIObject

# ItemHolderUI visually represent a a single grid based inventory
# container in WAR's grid based inventory system. Including, potentially, a 
# loadout slot
class_name ItemHolderUI

@onready var inventory_grid = $InventoryGrid
const ITEM_DOMINO_SCENE = preload("res://UIObjects/InventoryUI/ItemDominos/ItemDomino.tscn")

var inventory_save_lcation = ("res://inventory.txt")

var test_inventory_dictionary = {
	[0,0] : "res://TestObjects/InventoryTest/SpaceAKMagazineItem.tscn",
	[1,0] : "res://TestObjects/InventoryTest/SpaceAK47.tscn",
	[0,3] : "res://TestObjects/InventoryTest/SpaceAK47.tscn"
}

# This is is the ContainerPanel that this ContainerPanel will send its items to by default if you do an
# instant transfer
var instantTransferDestination = null

# Loadout slot containers need to be treated in special ways by both the InventoryUIManager and by ItemDominos
var representsLoadoutSlot = false

# indicates the item being held by the inventoryUIManager can be merged into an item in this inventory. Used to
# change the visual style of this panel to indicate the merge is possible
var pickedUpItemCanMerge = false

# indicates the item being held by the inventoryUIManager can be merged into empty space in this inventory. Used
# to change the visual style of this panel to indicate the transfer is possible
var pickedUpItemCanFit = false

# The actual item_holder object this container represents
var item_holder = null : get = get_item_holder

func _ready():
	pass


func update():
	reset_ui()


func reset_ui():
	clean_up_all_item_dominios()


func clean_up_all_item_dominios():
	var child_clean_up_list = []
	for child in get_children():
		if child is ItemDomino:
			child_clean_up_list.append(child)
	for child in child_clean_up_list:
		remove_child(child)
		child.queue_free()


func position_item_domino(item_domino, grid_square=null):
	if grid_square != null:
		item_domino.position = calculate_pixel_position_from_grid_position(grid_square)


func update_all_item_dominos():
	for my_child in get_children():
		if my_child is ItemDomino:
			my_child.update_from_item()


# returns the exact pixel position of the top left hand corner of the given grid square in this panel's coordinate
# system
func calculate_pixel_position_from_grid_position(grid_position):
	var pixel_position_X = (grid_position.x * grid_square_size) + 3#(border_size+6)/2
	var pixel_position_Y = (grid_position.y * grid_square_size) + 3#(border_size+6)/2
	var pixel_position = Vector2(pixel_position_X, pixel_position_Y)
	return pixel_position


func get_item_domino_at_mouse():
	return get_item_domino_at_pos(get_global_mouse_position())
	

func get_item_domino_at_pos(pos):
	for my_child in get_children():
		if my_child is ItemDomino:
			if my_child.get_global_rect().has_point(pos):
				return my_child
	return null


# getRoundedXGridSquareFromPoint(point) returns the x grid line that point is closest to
func get_rounded_x_grid_square_from_point(point):
	# We then simply divide each point by the grid square size to determine what grid square they are in
	var x_grid_coordinate = float(point.x) / float(grid_square_size)

	x_grid_coordinate = round(x_grid_coordinate)

	return int(x_grid_coordinate)


# getXGridSquareFromPoint() returns the x coordinate of the gridsquare the point is within
func get_x_grid_square_from_point(point):
	# We then simply divide each point by the grid square size to determine what grid square they are in
	return int(point.x/grid_square_size)


# getRoundedYGridSquareFromPoint(point) returns the y grid line that point is closest to
func get_rounded_y_grid_square_from_point(point):
	# We then simply divide each point by the grid square size to determine what grid square they are in
	var y_grid_coordinate = float(point.y) / float(grid_square_size)

	y_grid_coordinate = round(y_grid_coordinate)

	return int(y_grid_coordinate)


# getYGridSquareFromPoint() returns the y coordinate of the gridsquare the point is within
func get_y_grid_square_from_point(point):
	# We then simply divide each point by the grid square size to determine what grid square they are in
	return int(point.y/grid_square_size)


# getGridSquareFromPoint(point) returns the grid square the point is currently in
func get_grid_square_from_point(point):
	return Vector2(get_x_grid_square_from_point(point), get_y_grid_square_from_point(point))


func get_grid_square_from_mouse():
	return get_grid_square_from_point(get_local_mouse_position())


# getRoundedGridSquareFromPoint(pt) returns the closest grid square intersection to the point
func get_rounded_grid_square_from_point(pt):
	return Vector2(get_rounded_x_grid_square_from_point(pt), get_rounded_y_grid_square_from_point(pt))


func get_rounded_grid_square_from_mouse():
	return get_rounded_grid_square_from_point(get_local_mouse_position())


func get_item_holder():
	return item_holder


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
	var itemLocation = getItemHolder().getItemLocation(item)

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
