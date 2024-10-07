extends InventoryUIObject

class_name ItemDomino

# ----- Control References ----- #
var equipped_aesthetics : Control

var placement_item_domino_scene = preload("res://UIObjects/InventoryUI/ItemDominos/PlacementItemDomino.tscn")

var placedZIndex = 5
var pickedUpZIndex = 10

@onready var grid = $ItemDominoGrid
@onready var quantity_text = $MarginContainer/QuantityText

# pickedUp is a variable that indicates that this ItemDomino has been picked up by a player using its
# inventoryUIManager
var picked_up = false

# Can Be Merged and can be transferred are both used by the inventoryUIManager to indicate that this item
# domino is picked up by the player and can currently be dropped to be merged or transferred into the hovered
# inventory. These variables are used because the visuals of this image should be changed based on whether it
# can be transferred or merged into a container
var canBeMerged = false
var canBeTransferred = false

var grid_position = Vector2(0, 0) : set = set_grid_position, get = get_grid_position

@onready var item_domino_image = $ItemDominoImageMargin/ItemDominoImage

var item : Item = null # preload("res://WARPrototypes/Items/TestItem.tscn").instance()


func _ready():
	generate_size_from_grid_squares()
	emit_signal("item_rect_changed")
	set_screen_position_from_inventory_grid_position()
	#center_item_domino_image()


func update_from_item():
	if item is QuantityItem or item.has_method("generate_quantity_string"):
		update_quantity_text_from_item(item)
		
	if item:
		equipped_aesthetics = Util.find_node_by_name(self, "EquippedAesthetics") # Need to call this here because the domino isn't guaranteed to be in a scene when generated
		if equipped_aesthetics:
			equipped_aesthetics.hide()
			if GameMaster.get_player():
				if GameMaster.get_player().get_equipped_item() == item and not picked_up:
					equipped_aesthetics.show()
		#grid_position = item.grid_position
		
		#grid_square_height = item.grid_square_height
		#grid_square_width = item.grid_square_width
		
		# We need to access the $ItemDominoImage directly here instead of using
		# a variable due to this Item domino not being in the scene yet, and 
		# and therefore our @onready functions haven't happened yet
		$ItemDominoImageMargin/ItemDominoImage.texture = item.inventory_image


func build_from_item(new_item = null):
	if new_item != null:
		item = new_item
		
	update_from_item()


func update_quantity_text_from_item(my_item : Item):
		if my_item.show_quantity_in_ui:
			# Necessary to use $ notation here instead of variable as it isn't
			# actually ready and assigned yet when this is called
			$MarginContainer/QuantityText.show()
			$MarginContainer/QuantityText.text = my_item.generate_quantity_string()
		else:
			$MarginContainer/QuantityText.hide()


func get_inventory_grid():
	return get_parent()


func set_screen_position_from_inventory_grid_position():
	if get_inventory_grid().has_method("position_item_domino"):
		get_inventory_grid().position_item_domino(self, grid_position)


func center_item_domino_image():
	var difference_in_x_size = size.x - item_domino_image.size.x
	var difference_in_y_size = size.y - item_domino_image.size.y
	
	var new_image_position = Vector2(item_domino_image.position.x + difference_in_x_size/2, item_domino_image.position.y + difference_in_y_size/2)
	item_domino_image.position = new_image_position


# makePlacementItemDomino() makes an item domino that the inventoryUIManager
# can use to indicate where this item domino is going to be placed
func make_placement_item_domino():
	var my_placement_domino : PlacementItemDomino = placement_item_domino_scene.instantiate()
	my_placement_domino.item = item
	my_placement_domino.generate_size_from_grid_squares()
	return my_placement_domino


func on_hover():
	hovered = true
	
	# If we are currently holding an item and dragging one around, we shouldn't be able to do anything with this
	# itemDomino
	if not get_invnetory_ui_menu() or  not get_invnetory_ui_menu().is_holding_item_domino():
		grid.on_hover()


func on_unhover():
	hovered = false
	
	grid.on_unhover()


func pick_up(the_inventory_ui_menu : InventoryUIMenu):
	grid.hide()
	quantity_text.hide()

	# We need to put this in a variable to be able to move the domino to it as
	# we won't be able to access it once we remove ourselves from our itemholder
	# inventory container
	# NOTE This is all being passed in from the inv now
	# var inventory_ui_menu = get_parent().get_parent() # getInventoryUIManager()
	
	if the_inventory_ui_menu:
		get_parent().remove_child(self)
		the_inventory_ui_menu.add_child(self) # Util.forceAddChild(inventory_ui_master, self)
	
	picked_up = true #setPickedUp(true)


func put_down():
	grid.show()
	reset_graphical_grid_pos()
	quantity_text.show()
	picked_up = false

	# If we aren't being picked up, then we certainly cannot be merged or 
	# transferred, so they should be set to false
	# setCanBeMerged(false)
	# setCanBeTransferred(false)


func reset_graphical_grid_pos():
	grid.set_position(Vector2(0, 0))


func _process(delta):
	# Checking hover to highlight backplate to indicate the hovering is
	# occuring
	#if item and item.stackable:
	#	quantityText.text = "x" + str(item.stack)
	if get_global_rect().has_point(get_global_mouse_position()):
		if get_invnetory_ui_menu():
			if not get_invnetory_ui_menu().item_detail_menu_control or not get_invnetory_ui_menu().item_detail_menu_control.is_open:
				on_hover()
		else:
			on_hover()
	else:
		on_unhover()


func get_invnetory_ui_menu():
	if get_parent().has_method("get_invnetory_ui_menu"):
		return get_parent().get_invnetory_ui_menu()
	return null


func set_grid_position(new_grid_position):
	if item != null:
		item.grid_position = new_grid_position
	else:
		grid_position = new_grid_position


func get_grid_position():
	if item != null:
		return item.grid_position
	else:
		return grid_position


func get_grid_square_width():
	if item != null:
		return item.grid_square_width
	else:
		return grid_square_width


func get_grid_square_height():
	if item != null:
		return item.grid_square_height
	else:
		return grid_square_height


"""

func getCanBeMerged():
	return canBeMerged

func setCanBeMerged(value):
	canBeMerged = value

func getCanBeTransferred():
	return canBeTransferred

func setCanBeTransferred(value):
	canBeTransferred = value

func updateQuantityText():
	var doesNothing = true

func onHover():
	hovered = true
	
	# If we are currently holding an item and dragging one around, we shouldn't be able to do anything with this
	# itemDomino
	if not getInventoryUIManager() or  not getInventoryUIManager().isHoldingItem():
		grid.onHover()
		
func onUnhover():
	hovered = false
	
	grid.onUnhover()

	#"" BLOCK COMMENT
	# If the inventoryContainerPanel is a loadout slot, then we don't want to show our backplate
	if inventoryContainerPanel.isLoadoutSlot():
		grid.hide()
	#""

func _process(delta):
	# Checking hover to highlight backplate to indicate the hovering is
	# occuring
	if item and item.stackable:
		quantityText.text = "x" + str(item.stack)
	if get_global_rect().has_point(get_global_mouse_position()):
		onHover()
	else:	
		onUnhover()
"""
