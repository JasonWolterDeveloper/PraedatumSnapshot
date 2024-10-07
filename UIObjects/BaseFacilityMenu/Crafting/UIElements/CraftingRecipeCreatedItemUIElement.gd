class_name CraftingRecipeCraftedItemUIELement extends BoxContainer

# Required Model Object References
var crafting_recipe : CraftingRecipe
var crafting_item : Item
var crafting_item_quantity : int

# Control Elements we need access to
var item_image : TextureRect
var quantity_label : Label


func _ready():
	populate_control_references()


func assign_recipe_item_and_quantity(new_recipe : CraftingRecipe, new_item : Item, new_quantity : int):
	crafting_recipe = new_recipe
	crafting_item = new_item
	crafting_item_quantity = new_quantity
	update()


func update():
	update_label()
	update_item_image()


func update_label():
	var label_text = str(crafting_item_quantity)
	quantity_label.text = label_text


func update_item_image():
	item_image.texture = crafting_item.inventory_image


func populate_control_references():
	item_image = Util.find_node_by_name(self, "ItemImage")
	quantity_label = Util.find_node_by_name(self, "QuantityLabel")
