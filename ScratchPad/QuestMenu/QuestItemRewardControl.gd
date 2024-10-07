class_name QuestItemRewardControl extends PanelContainer

# ----- Control Refs ----- #
var item_image : TextureRect
var quantity_label : Label

# ----- Model Refs ----- #
var item : Item

# ----- Tracking Vars ----- #
var current_quantity : int



# ---------- Ready and Assignment Functions ---------- #


func _ready():
	item_image = Util.find_node_by_name(self, "ItemImage")
	quantity_label = Util.find_node_by_name(self, "QuantityLabel")


func assign_item(new_item : Item):
	item = new_item
	update()


# ---------- Update Functions ---------- #


func update():
	if item:
		item_image.texture = item.inventory_image
		current_quantity = item.current_quantity
		quantity_label.text = str(current_quantity)


func add_quantity_from_item(new_item : Item):
	current_quantity += new_item.current_quantity
	quantity_label.text = str(current_quantity)
	

func get_item_id() -> String:
	if item:
		return item.item_id
	return ""
