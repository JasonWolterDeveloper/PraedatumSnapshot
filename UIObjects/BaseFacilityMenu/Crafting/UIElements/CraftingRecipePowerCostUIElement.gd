class_name CraftingRecipePowerCostUIElement extends BoxContainer

const COST_CHARACTER_SEPARATOR = "/"

# Required Model Object References

var crafting_recipe : CraftingRecipe

# Control Elements we need access to
var quantity_label : Label
var enough_quantity_indicator : Control
var not_enough_quantity_indicator : Control


func _ready():
	populate_control_references()


func assign_recipe(new_recipe : CraftingRecipe):
	crafting_recipe = new_recipe
	update()


func update():
	update_quantity_information()


func update_quantity_information():
	var total_owned_quantity = PersistentDataTome.get_current_solar_power()
	if total_owned_quantity >= crafting_recipe.power_cost:
		show_enough_quantity()
	else:
		show_not_enough_quantity()
	update_label(total_owned_quantity)
	

func update_label(owned_quantity):
	var label_text = str(owned_quantity) + COST_CHARACTER_SEPARATOR + str(crafting_recipe.power_cost)
	quantity_label.text = label_text
	

func show_not_enough_quantity():
	enough_quantity_indicator.hide()
	not_enough_quantity_indicator.show()


func show_enough_quantity():
	enough_quantity_indicator.show()
	not_enough_quantity_indicator.hide()


func populate_control_references():
	quantity_label = Util.find_node_by_name(self, "QuantityLabel")
	enough_quantity_indicator = Util.find_node_by_name(self, "EnoughQuantityIndicator")
	not_enough_quantity_indicator = Util.find_node_by_name(self, "NotEnoughQuantityIndicator")
