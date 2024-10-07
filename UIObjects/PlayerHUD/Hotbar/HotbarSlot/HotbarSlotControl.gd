class_name HotbarSlotControl extends PanelContainer

# References
var hot_bar_slot :HotbarSlot = null
var hot_bar_slot_index: int = -1
var item_image: TextureRect = null
var slot_index_label: Label = null
var selected_aesthetics : Control = null
var highlight_aesthetics : Control = null



# ---------- Ready and Assignment Functions ---------- #


func _ready():
	item_image = Util.find_node_by_name(self, "ItemImage")
	slot_index_label = Util.find_node_by_name(self, "SlotIndexLabel")
	selected_aesthetics = Util.find_node_by_name(self, "SelectedAesthetics")
	highlight_aesthetics = Util.find_node_by_name(self, "HighlightAesthetics")


# Function to assign a hot bar slot and update the control
func assign_hot_bar_slot(new_hot_bar_slot : HotbarSlot) -> void:
	if hot_bar_slot:
		hot_bar_slot.hot_bar_changed.disconnect(update)
	hot_bar_slot = new_hot_bar_slot
	hot_bar_slot.hot_bar_changed.connect(update)
	
	update()



# ---------- Update Functions ---------- #


func update_selected_aesthetics():
	if hot_bar_slot:
		if hot_bar_slot.is_equipped:
			selected_aesthetics.show()
		else:
			selected_aesthetics.hide()


func update_item_image():
	if hot_bar_slot:
		if hot_bar_slot.item:
			item_image.texture = hot_bar_slot.item.inventory_image
			return
	item_image.texture = null


func update_slot_index_label():
	if hot_bar_slot:
		var new_idx = hot_bar_slot.slot_idx + 1
		
		if new_idx > 9:
			slot_index_label.text = '0'
		else:
			slot_index_label.text = str(new_idx)
		return
	slot_index_label.text = ""


# Function to update the item image and slot index
func update():
	update_item_image()
	update_slot_index_label()
	update_selected_aesthetics()



# ---------- Notify Functions -------- #


func notify_highlighted():
	highlight_aesthetics.show()


func notify_not_highlighted():
	highlight_aesthetics.hide()
