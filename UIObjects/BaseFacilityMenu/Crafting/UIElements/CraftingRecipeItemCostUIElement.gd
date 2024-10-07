class_name CraftingRecipeItemCostUIElement extends BoxContainer

const COST_CHARACTER_SEPARATOR = "/"

# Required Model Object References

var crafting_recipe : CraftingRecipe
var crafting_item : Item
var crafting_item_quantity : int

# Control Elements we need access to
var item_image : TextureRect
var quantity_label : Label
var enough_quantity_indicator : Control
var not_enough_quantity_indicator : Control


func _ready():
	populate_control_references()


func assign_recipe_item_and_quantity(new_recipe : CraftingRecipe, new_item : Item, new_quantity : int):
	crafting_recipe = new_recipe
	crafting_item = new_item
	crafting_item_quantity = new_quantity
	update()


func update():
	update_quantity_information()
	update_item_image()


func update_quantity_information():
	var total_owned_quantity = crafting_recipe.get_total_owned_quantity_of_item(crafting_item.item_id)
	if total_owned_quantity >= crafting_item_quantity:
		show_enough_quantity()
	else:
		show_not_enough_quantity()
	update_label(total_owned_quantity)
	

func update_label(owned_quantity):
	var label_text = str(owned_quantity) + COST_CHARACTER_SEPARATOR + str(crafting_item_quantity)
	quantity_label.text = label_text
	

func show_not_enough_quantity():
	enough_quantity_indicator.hide()
	not_enough_quantity_indicator.show()


func show_enough_quantity():
	enough_quantity_indicator.show()
	not_enough_quantity_indicator.hide()


func update_item_image():
	item_image.texture = crafting_item.inventory_image


func populate_control_references():
	item_image = Util.find_node_by_name(self, "ItemImage")
	quantity_label = Util.find_node_by_name(self, "QuantityLabel")
	enough_quantity_indicator = Util.find_node_by_name(self, "EnoughQuantityIndicator")
	not_enough_quantity_indicator = Util.find_node_by_name(self, "NotEnoughQuantityIndicator")
