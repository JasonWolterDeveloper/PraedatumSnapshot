extends Control

class_name InventoryUIMenu

const ITEM_DOMINO_SCENE = preload("res://UIObjects/InventoryUI/ItemDominos/ItemDomino.tscn")

# The Item domino representing the pickedUpItem. This is the item that is currently being dragged around the
# screen by the player. If the player isn't dragging an item around the screen, this should be done
var picked_up_item_domino : ItemDomino = null

# placement item domino is used to indicate where the item domino will be dropped
# that the player is holding
var picked_up_placement_item_domino : PlacementItemDomino = null

var picked_up_item_domino_previous_position = null

# The item domino for the the item that the picked up item was split off from, if there was one
var picked_up_item_domino_origin_item_domino = null

# The inventory container that the picked up item comes from as well as the container panel for that inventory
var picked_up_item_inventory_container = null

@export var hovered_inventory_container:Node = null
var hovered_hotbar_slot : HotbarSlotControl = null
var hotbar : Hotbar

var hovered_item_to_interact_with = null

# Used to map different inventory containers to each other for default transfers in the menu for the
# shift left click interaction
var inventory_container_default_transfer_mapping : Dictionary = {}


# An Array of all of our item holder UI children
var item_holder_ui_objects : Array[ItemHolderUI] = []

# ----- Vars To Handle Single/Double Click ----- #
var time_since_last_click: float = 1.0
var double_click_threshold: float = 0.1  # Time in seconds within which the second click must occur


# ----- Vars to handle needing to drag slightly to pick up item domino ----- #
var drag_distance_to_pick_up : float = 3.0
var item_domino_to_pick_up : ItemDomino
var is_dragging : bool = false

# ----- Item Name Popup Vars ----- #
var prev_hovered_item_domino : ItemDomino
var hovered_item_domino_time : float = 0.0
const TIME_BEFORE_POPUP_NAME = 0.6	

# ----- Control References ----- #
var item_detail_menu_control : ItemDetailMenuControl
var item_popup_label : ItemPopupLabel

# ----- Settings ----- #
@export var drop_item_if_out_of_container : bool = false

# ----- Parent Reference ----- #
var inventory_ui_master : InventoryUIMaster



# ---------- Ready and Assignment Function ---------- #


func _ready():
	item_detail_menu_control = Util.find_node_by_name(self, "ItemDetailMenuControl")
	if item_detail_menu_control:
		item_detail_menu_control.assign_inventory_ui_menu(self)
	item_popup_label = Util.find_node_by_name(self, "ItemPopupLabel")
	hotbar = Util.find_node_by_name(self, "Hotbar")
	populate_item_holder_ui_objects_recursive()


func assign_inventory_ui_master(new_inventory_ui_master : InventoryUIMaster):
	inventory_ui_master = new_inventory_ui_master


func populate_item_holder_ui_objects_recursive(node = self):
	if node == self:
		item_holder_ui_objects.clear()
		
	for my_child in node.get_children():
		if my_child is ItemHolderUI:
			item_holder_ui_objects.append(my_child)
	
		populate_item_holder_ui_objects_recursive(my_child)


func update():
	for item_holder : ItemHolderUI in item_holder_ui_objects:
		item_holder.update()
	"""
	for my_child in get_children():
		if my_child is ItemHolderUI:
			my_child.update()
	"""


func update_item_dominos():
	for my_child in get_children():
		if my_child is ItemHolderUI:
			my_child.update_all_item_dominos()


func pick_up_item_domino(item_domino):
	set_picked_up_item_domino(item_domino)
	get_picked_up_item_domino().pick_up(self)
	
	DebugMaster.log_debug("Hey Good picking up the domino", DebugMaster.INVENTORY_DEBUG_CATEGORY)
	
	picked_up_item_inventory_container = get_hovered_inventory_container()
	picked_up_item_domino_previous_position = get_picked_up_item_domino().grid_position
	
	make_placement_item_domino()

	# We add the item domino as content ot the inventory manager so that we can see it being dragged aroud
	# Util.forceAddChild(self, get_picked_up_item_domino())


func quick_transfer_item_domino(item_domino):
	var origin_item_inventory_container = get_hovered_inventory_container()
	var origin_item_holder = origin_item_inventory_container.item_holder
	
	if inventory_container_default_transfer_mapping.has(origin_item_holder):
		var target_item_holder = inventory_container_default_transfer_mapping[origin_item_inventory_container.item_holder]
		var target_item = item_domino.item
		
		if target_item and target_item is Item and target_item_holder and target_item_holder is ItemHolder:
			transfer_anywhere_model_only(target_item, target_item_holder, origin_item_holder)


func make_placement_item_domino():
	picked_up_placement_item_domino = picked_up_item_domino.make_placement_item_domino()


func make_item_domino_from_item(new_item : Item):
	var new_item_domino = ITEM_DOMINO_SCENE.instantiate()
	new_item_domino.build_from_item(new_item)
	return new_item_domino


func position_placement_item_domino():
	var hovered_inventory_container = get_hovered_inventory_container()
	
	if hovered_inventory_container:
		Util.force_add_child(hovered_inventory_container, picked_up_placement_item_domino)
		
		hovered_inventory_container.position_item_domino(picked_up_placement_item_domino, get_picked_up_item_hovered_grid_position())
	else:
		if picked_up_placement_item_domino.get_parent():
			picked_up_placement_item_domino.get_parent().remove_child(picked_up_placement_item_domino)


# notifies the placement domino if we can currently place or merge our picked
# up item so that the placement domino can colour itself accordingly
func notify_placement_domino_status():
	if false: # checkPickedUpItemMerge():
		picked_up_placement_item_domino.notify_can_merge()
	elif check_picked_up_item_interact():
		picked_up_placement_item_domino.notify_can_interact()
	elif check_picked_up_item_fit():
		picked_up_placement_item_domino.notify_can_fit()
	else:
		picked_up_placement_item_domino.notify_invalid_position()


func position_picked_up_item_domino():
	var placement_position = MathUtil.get_rect_top_left_from_center(get_global_mouse_position(), picked_up_item_domino.size)
	picked_up_item_domino.global_position = placement_position


# checkPickedUpItemFit() returns true if the held item fits in the currently hovered inventory at the currently
# hovered grid position. If an inventory isn't hovered, or if there is no held object, this returns false
func check_picked_up_item_fit():
	if get_picked_up_item_domino() and get_hovered_inventory_container():
		var placement_position = get_picked_up_item_hovered_grid_position()
		return get_hovered_inventory_container().item_holder.can_fit(get_picked_up_item_domino().item, placement_position)


func check_picked_up_item_interact():
	if get_picked_up_item_domino() and get_hovered_inventory_container():
		var placement_position = get_picked_up_item_hovered_grid_position()
		return get_hovered_inventory_container().item_holder.can_interact(get_picked_up_item_domino().item, placement_position)


func transfer_anywhere(origin_container_panel, transfered_item_domino : ItemDomino, target_container_panel):
	# TODO - Implement this so that it can handle item_holders that are not storages, I.E. implement find_fit_square for generic
	# Item holders please
	var target_item_holder = target_container_panel.item_holder
	var target_item = transfered_item_domino.item
	var origin_item_holder = origin_container_panel.item_holder
	transfer_anywhere_model_only(target_item, target_item_holder, origin_item_holder)


func transfer_anywhere_model_only(target_item: Item, target_item_holder : ItemHolder, origin_item_holder: ItemHolder):
	if target_item_holder.can_fit_anywhere(target_item):
		target_item_holder.insert_anywhere(target_item)
		origin_item_holder.notify_changed()
	else:
		OnScreenMessageMaster.display_message("No Space for Item")
		
	update() # update the UI


func transfer(origin_container_panel, transfered_item_domino : ItemDomino, target_container_panel, transfer_position):
	# Actual Inventory Objects Handling
	origin_container_panel.item_holder.transfer(transfered_item_domino.item, target_container_panel.item_holder, transfer_position)
	
	# UI inventory Objects Handling
	Util.force_add_child(target_container_panel, transfered_item_domino)
	transfered_item_domino.set_screen_position_from_inventory_grid_position()


func transfer_picked_up_item_to_hovered_inventory():
	var transfer_position = get_picked_up_item_hovered_grid_position()
	transfer(get_picked_up_item_inventory_container(),
					get_picked_up_item_domino(),
					get_hovered_inventory_container(),
					transfer_position)


# If the item is dropped, but nothing interesting can be done with it, it is returned to its previous state. If a
# whole stack of items has been picked up, it is returned to the original position it was in before it was picked up
# or, if it was split from another object, it is merged back into that object
func return_item():
	if true:
		Util.force_add_child(picked_up_item_inventory_container, picked_up_item_domino)
		picked_up_item_domino.set_screen_position_from_inventory_grid_position()
	""" - Merging behaviour CURRENTLY UNUSED
	else:
		merge(getPickedUpItemInventoryContainer(),
					getPickedUpItemDomino(),
					getPickedUpItemInventoryContainer(),
					getPickedUpItemDominoOriginItemDomino())
	"""
	
func put_down_item_domino():
	# First off, we can only drop an item if we have picked one up, so we check if we have first
	if get_picked_up_item_domino():
		# itemPlaced is used to indicate that the itemDomino has been fully moved to another container. If it hasn't
		# it will have to be moved back to its original position in its original container
		var item_placed = false
		
		# If we are hovering a hotbar slot with the item domino, we want to try to put it in that hotbar
		# slot
		if hovered_hotbar_slot:
			hovered_hotbar_slot.hot_bar_slot.attempt_assign_item(get_picked_up_item_domino().item)

		# If we are currently hovering an inventory container, we attempt to place or merge our item into that
		# inventory container
		elif get_hovered_inventory_container():
			# The merge item domino is the item domino for an item that the picked up item could be merged with if
			# it were dropped at the position it is currently hovering. If there is no item there to merge with,
			# this will be null

			"""
			var mergeItemDomino = checkPickedUpItemMerge()

			# If we found an item to merge with, we attempt to merge our item with it
			if mergeItemDomino:
				mergePickedUpItemToHoveredInventory(mergeItemDomino)

				# If we merged out item with the other item completely such that there is no quantity left in our
				# original item stack, then we consider our item placed, and therefore do not have to return it
				# to its original position
				if getPickedUpItem().isEmpty():
					itemPlaced = true
			"""
			if false:
				DebugMaster.log_debug("No Merging Available Yet", DebugMaster.INVENTORY_DEBUG_CATEGORY)

			# If we don't have an item to merge with, we check if the item domino will fit into the inventory at
			# the actual position we're being held at. If it does fit, we move it there
			elif check_picked_up_item_fit():
				transfer_picked_up_item_to_hovered_inventory()

				# Notify the item that it has been put down inside of the hovered inventory container panel
				get_picked_up_item_domino().put_down()

				item_placed = true
			elif check_picked_up_item_interact():
				var item_to_interact_with = check_picked_up_item_interact()
				item_placed = get_picked_up_item_domino().item.interact_with_item(item_to_interact_with)
				if item_placed:
					get_picked_up_item_domino().put_down()
					picked_up_item_domino.queue_free()
					
		elif drop_item_if_out_of_container:
			if GameMaster.get_player():
				GameMaster.get_player().inventory.drop_item(get_picked_up_item_domino().item)
				get_picked_up_item_domino().put_down()
				picked_up_item_domino.queue_free()
				item_placed = true
			
		if not item_placed:
			# If we haven't found a new place for the item domino, return it to its original inventory
			return_item()

			# Notify the item that it has been put back inside of the inventory container panel it came from
			picked_up_item_domino.put_down()
		
		# If we have completely merged this item domino into another, we should 
		# get rid of it
		"""
		if picked_up_item_domino.getItem().isEmpty():
			pickedUpItemDomino.queue_free()
		"""
		picked_up_item_domino = null
		
		# Getting rid of the placement item domino completely
		picked_up_placement_item_domino.queue_free()
		picked_up_placement_item_domino = null
		
		# Updating all of our item dominos just in case quantities changed
		# Now we update everything just in case
	update()


func attempt_open_detail_menu_for_hovered_item_domino():
	if get_hovered_item_domino() and item_detail_menu_control:
		item_detail_menu_control.assign_item(get_hovered_item_domino().item)
		item_detail_menu_control.open()


func handle_double_click():
	attempt_open_detail_menu_for_hovered_item_domino()


func handle_single_click():
	if Input.is_action_pressed("ui_shift_modifier"):
		if get_hovered_item_domino():
			quick_transfer_item_domino(get_hovered_item_domino())
	else:
		if get_hovered_item_domino():
			pick_up_item_domino(get_hovered_item_domino())


func handle_click(delta):
	time_since_last_click += delta
	# We don't want to handle clicks if our overlay menu is open
	if not item_detail_menu_control or item_detail_menu_control.is_open == false:
		if Input.is_action_just_pressed("ui_click"):
			if time_since_last_click <= double_click_threshold:
				handle_double_click()
			else:
				handle_single_click()
	if Input.is_action_just_released("ui_click"):
		handle_release_click(delta)


func handle_release_click(delta):
	time_since_last_click = 0.0
	if get_picked_up_item_domino():
		put_down_item_domino()


func _process(delta):
	if is_visible_in_tree():
		update_hovered_inventory_container()
		update_hovered_hotbar_slot()
		
		handle_click(delta)
		
		handle_name_popup(delta)
		
		if picked_up_item_domino:
			position_picked_up_item_domino()
			
			# Handling Placement Item Domino positioning and status
			position_placement_item_domino()
			notify_placement_domino_status()
		
		# initializing hotbar if need be
		if hotbar and not hotbar.player and GameMaster.get_player():
			hotbar.assign_player(GameMaster.get_player())
		
		if Input.is_action_just_pressed("ui_cancel"):
			if item_detail_menu_control.is_open:
				item_detail_menu_control.close()
			elif inventory_ui_master:
				inventory_ui_master.close_inventory()


# --------- Item Name Popup Functions ---------- #

func handle_name_popup(delta : float) -> void:
	if is_instance_valid(item_popup_label):
		var hovered_item_domino : ItemDomino = get_hovered_item_domino()
		if prev_hovered_item_domino != hovered_item_domino:
			close_item_popup_label()
			hovered_item_domino_time = 0.0
		elif not item_popup_label.is_open:
			hovered_item_domino_time += delta        
			if hovered_item_domino_time >= TIME_BEFORE_POPUP_NAME:
				attempt_open_item_popup_label()
				
		prev_hovered_item_domino = hovered_item_domino
		

func attempt_open_item_popup_label():
	var hovered_item_domino = get_hovered_item_domino()
	if is_instance_valid(hovered_item_domino):
		item_popup_label.assign_item(hovered_item_domino.item)
		item_popup_label.global_position = get_global_mouse_position()
		item_popup_label.open()
	  
  
func close_item_popup_label():
	if item_popup_label:
		item_popup_label.close()



# ---------- Inventory Container Update Functions --------- #

func update_hovered_inventory_container():
	for child in get_children():
		var child_inventory_container = recursive_hovered_inventory_container_search(child)
		if child_inventory_container:
			hovered_inventory_container = child_inventory_container
			return
	hovered_inventory_container = null


# recursiveHoveredInventoryContainerGet takes a child of this InventoryUIManager
# and checks if it is an inventory container. If it is, it returns it. If not
# we run this function on all of the children of this container to see if they
# are or have an InventoryContainer. If there are None, this is null
func recursive_hovered_inventory_container_search(child):
	if child is ItemHolderUI:
		if child.get_global_rect().has_point(get_global_mouse_position()):
			return child
	else:
		for grand_child in child.get_children():
			var grand_child_result = recursive_hovered_inventory_container_search(grand_child)
			if grand_child_result:
				return grand_child_result
	return null


func update_hovered_hotbar_slot():
	if hovered_hotbar_slot:
		hovered_hotbar_slot.notify_not_highlighted()
	for child in get_children():
		var child_inventory_container = recursive_hovered_hot_bar_search(child)
		if child_inventory_container:
			hovered_hotbar_slot = child_inventory_container
			if get_picked_up_item_domino():
				hovered_hotbar_slot.notify_highlighted()
			return
	hovered_hotbar_slot = null


# recursive_hobered_hot_bar_slot takes a child of this InventoryUIManager
# and checks if it is an inventory container. If it is, it returns it. If not
# we run this function on all of the children of this container to see if they
# are or have an InventoryContainer. If there are None, this is null
func recursive_hovered_hot_bar_search(child):
	if child is HotbarSlotControl:
		if child.get_global_rect().has_point(get_global_mouse_position()):
			return child
	else:
		for grand_child in child.get_children():
			var grand_child_result = recursive_hovered_hot_bar_search(grand_child)
			if grand_child_result:
				return grand_child_result
	return null


func get_hovered_inventory_container():
	return hovered_inventory_container


func map_storage_container_ui_by_name(ui_node_name : String, storage : Storage):
	var storage_ui = Util.find_node_by_name(self, ui_node_name)
	if storage_ui != null and storage_ui is StorageUI:
		storage_ui.build_from_storage(storage)
		
		
func map_loadout_slot_ui_by_name(ui_node_name : String, loadout_slot: LoadoutSlot):
	var loadout_slot_ui = Util.find_node_by_name(self, ui_node_name)
	if loadout_slot_ui != null and loadout_slot_ui is LoadoutSlotUI:
		loadout_slot_ui.build_from_loadout_slot(loadout_slot)

# getHeldItemHoveredGridposition() returns the top left hand corner of the held item domino given the grid square
# that is currently hovered. This can be different than the hovered grid square because the hovered gridsquare
# should be approximately the center of the item and not the top left hand corner. returns null if there is no
# hovered inventory or picked up object
func get_picked_up_item_hovered_grid_position():
	# TODO - Update get_hovered_inventory_container so that the currently hovered inventory container is updated
	# ONCE PER FRAME. I encountered an issue where get_hovered_inventory_container had a value up here, but later on
	# in the function it was NULL
	if get_picked_up_item_domino() and get_hovered_inventory_container():
		# If the number of x grid squares in an item is odd, then the horizontal center of the object is a grid
		# square. Otherwise, it is a grid intersection. This is similar for y grid squares and the vertical center
		var center_square = [0, 0]
		if MathUtil.is_even(get_picked_up_item_domino().get_grid_square_width()):
			center_square[0] = get_hovered_closest_grid_intersection()[0]
		else:
			center_square[0] = get_hovered_inventory_grid_square()[0]
			
		if MathUtil.is_even(get_picked_up_item_domino().get_grid_square_height()):
			center_square[1] = get_hovered_closest_grid_intersection()[1]
		else:
			center_square[1] = get_hovered_inventory_grid_square()[1]
		
		var center_square_vector = Vector2(center_square[0], center_square[1])
		return get_picked_up_item_domino().item.calculate_grid_location_from_center(center_square_vector)
	return null


func get_hovered_item_domino():
	var hovered_inventory_containment_panel = get_hovered_inventory_container()
	
	if hovered_inventory_containment_panel:
		return hovered_inventory_containment_panel.get_item_domino_at_mouse()


func get_hovered_inventory_grid_square():
	if get_hovered_inventory_container():
		return get_hovered_inventory_container().get_grid_square_from_mouse()
	return null


func get_hovered_closest_grid_intersection():
	if get_hovered_inventory_container():
		return get_hovered_inventory_container().get_rounded_grid_square_from_mouse()
	return null


func get_picked_up_item_domino():
	return picked_up_item_domino


func set_picked_up_item_domino(item_domino):
	picked_up_item_domino = item_domino


func get_picked_up_item_inventory_container():
	return picked_up_item_inventory_container


func is_holding_item_domino():
	return get_picked_up_item_domino() != null


func get_inventory_ui_menu():
	return self


"""

func merge(originContainerPanel, transferedItemDomino, targetContainerPanel, targetItemDomino):
	# Doing the actual model merge
	originContainerPanel.getItemHolder().merge(transferedItemDomino.getItem(),
													targetContainerPanel.getItemHolder(),
													targetItemDomino.getItem())

	transferedItemDomino.updateQuantityText()
	targetItemDomino.updateQuantityText()

func transferAnywhere(originContainerPanel, transferedItemDomino, targetContainerPanel, amount=1):
	var fitSquare = targetContainerPanel.getItemHolder().findFitSquare(transferedItemDomino.getItem())
	if fitSquare:
		var dominoToTransfer = transferedItemDomino
		if amount != null and amount <= transferedItemDomino.getMaxQuantity():
			dominoToTransfer = splitItemDomino(transferedItemDomino, amount, originContainerPanel)

		transfer(originContainerPanel, dominoToTransfer, targetContainerPanel, fitSquare)

# splitItemDomino(itemDomino, amount, originInventoryContainerPanel), takes in an itemDomino, an amount, and the
# container panel that itemDomino came from and splits the item contained by the item domino into two stacks, the
# new stack having the quantity given by amount. An item domino is made for this new inventory stack and returned
# If the amount is greater than the amount given in the itemDomino, the itemDomino is removed
func splitItemDomino(itemDomino, amount, originInventoryContainerPanel):
	var newItem = itemDomino.getItem().split(amount)
	var newItemDomino = makeItemDominoForItem(newItem)

	itemDomino.updateQuantityText()
	newItemDomino.updateQuantityText()

	if itemDomino.getItem().isEmpty():
		originInventoryContainerPanel.removeItemDomino(itemDomino)

	# We prepare for render here because otherwise the new ItemDomino might be picked up by the inventoryUIManager
	# and therefore lose its size before being prepared to render and be smaller
	newItemDomino.prepareForRender()
	return newItemDomino

func makeItemDominoForItem(item):
	var newItemDomino = itemDominoScene.instance()
	newItemDomino.setItem(item)
	return newItemDomino

# informs the pickedUpItemDomino whether it can be successfully transfered or merged to the currently hovered
# inventoryContainerPanel. This is done because the visuals of the ItemDomino change based on whether or not it
# can currently be transfered or merged into the hovered panel
func updatePickedUpItemDominoTransferStatus():
	getPickedUpItemDomino().setCanBeMerged(checkPickedUpItemMerge())
	getPickedUpItemDomino().setCanBeTransferred(checkPickedUpItemFit())

# checkPickedUpItemMerge() returns the itemDomino the picked up item domino should merge with if it should merge and
# null otherwise
func checkPickedUpItemMerge():
	if getPickedUpItemDomino() and isHoveringAnInventoryContainer():
		var locationToCheck = getPickedUpItemHoveredGridLocation()
		var mergeItem = getHoveredInventoryContainer().getItemHolder().checkMerge(getPickedUpItem(),
																							locationToCheck)
		if mergeItem != null:
			return getHoveredInventoryContainer().findItemDominoForItem(mergeItem)
		return null

func mergePickedUpItemToHoveredInventory(mergeItemDomino):
	merge(getPickedUpItemInventoryContainer(),
				getPickedUpItemDomino(),
				getHoveredInventoryContainer(),
				mergeItemDomino)

func pickUpSplitItem(itemDomino, amount):
	# If the amount is greater than or equal to the amount in the stack, we simply pick up the stack like normal
	if amount >= itemDomino.getItem().getQuantity():
		pickUpItem(itemDomino)
	else:
		# Otherwise we split the amount away from the given itemDomino, make a new itemDomino for the split stack,
		# and pick that up
		var newItemDomino = splitItemDomino(itemDomino, amount, getHoveredInventoryContainer())
		newItemDomino.setClicked(true)
		pickUpItem(newItemDomino)
		setPickedUpItemDominoOriginItemDomino(itemDomino)

# Used when the itemDomino is ctrl clicked to instantly move it to another inventory without dragging
func instantTransferItem(itemDomino):
	transferAnywhere(getHoveredInventoryContainer(),
							itemDomino,
							getHoveredInventoryContainer().getInstantTransferDestination())
							
					

func getInventoryUIManager():
	return self

func hasPickedUpItem():
	return getPickedUpItemDomino() != null

func getPickedUpItem():
	return getPickedUpItemDomino().getItem()

func setPickedUpItemInventoryContainerPanel(invContainer):
	pickedUpItemInventoryContainerPanel = invContainer

func getPickedUpItemDominoPreviousLocation():
	return pickedUpItemDominoPreviousLocation

func setPickedUpItemDominoPreviousLocation(location):
	pickedUpItemDominoPreviousLocation = location

func getPickedUpItemDominoOriginItemDomino():
	return pickedUpItemDominoOriginItemDomino

func setPickedUpItemDominoOriginItemDomino(domino):
	pickedUpItemDominoOriginItemDomino = domino

# Returns true if we have picked up a whole item stack instead of splitting off a partial stack. Will be useful
# for facilitating transfers, merges, etc.
func pickedUpFullStack():
	return not pickedUpSplitStack()

# returns true if the item we are currently holding is the result of being split off of another item
func pickedUpSplitStack():
	return getPickedUpItemDominoOriginItemDomino() != null

func isHoveringAnInventoryContainer():
	return getHoveredInventoryContainer() != null
	
"""
