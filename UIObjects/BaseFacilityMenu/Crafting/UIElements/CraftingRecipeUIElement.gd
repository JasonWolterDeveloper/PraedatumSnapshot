class_name CraftingRecipeUIElement extends BoxContainer

# Required PackedScenes for constructing UI Element
@export var crafting_item_cost_ui_scene : PackedScene
@export var crafting_item_result_ui_scene : PackedScene

# Required references to control elements
var recipe_cost_container : BoxContainer
var recipe_result_container : BoxContainer
var recipe_power_cost_element : CraftingRecipePowerCostUIElement

# Required references to model objects
var crafting_recipe : CraftingRecipe

# Required reference to parent object
var base_facility_menu : BaseFacilityMenu


func _ready():
	populate_required_ui_elements()


func assign_crafting_recipe(new_recipe : CraftingRecipe):
	crafting_recipe = new_recipe
	update()


func update():
	update_item_cost_elements()
	update_item_result_elements()
	update_recipe_power_cost_element()


func update_recipe_power_cost_element():
	if crafting_recipe.power_cost == 0:
		recipe_power_cost_element.hide()
	else:
		recipe_power_cost_element.assign_recipe(crafting_recipe)


func clear_existing_item_cost_elements():
	for my_child in recipe_cost_container.get_children():
		if my_child is CraftingRecipeItemCostUIElement:
				recipe_cost_container.remove_child(my_child)
				my_child.queue_free()


func populate_item_cost_elements():
	for my_item : Item in crafting_recipe.item_cost_dictionary.keys():
		var new_item_cost_ui : CraftingRecipeItemCostUIElement = crafting_item_cost_ui_scene.instantiate()
		var item_quantity : int = crafting_recipe.item_cost_dictionary[my_item]
		recipe_cost_container.add_child(new_item_cost_ui)
		new_item_cost_ui.assign_recipe_item_and_quantity(crafting_recipe, my_item, item_quantity)


func update_item_cost_elements():
	clear_existing_item_cost_elements()
	populate_item_cost_elements()


func clear_existing_item_result_elements():
	for my_child in recipe_result_container.get_children():
		if my_child is CraftingRecipeCraftedItemUIELement:
				recipe_result_container.remove_child(my_child)
				my_child.queue_free()


func populate_item_result_elements():
	for my_item : Item in crafting_recipe.crafted_item_dictionary.keys():
		var new_item_result_ui : CraftingRecipeCraftedItemUIELement = crafting_item_result_ui_scene.instantiate()
		var item_quantity : int = crafting_recipe.crafted_item_dictionary[my_item]
		recipe_result_container.add_child(new_item_result_ui) # Must be in node tree before update
		new_item_result_ui.assign_recipe_item_and_quantity(crafting_recipe, my_item, item_quantity)


func update_item_result_elements():
	clear_existing_item_result_elements()
	populate_item_result_elements()


func populate_required_ui_elements():
	recipe_cost_container = Util.find_node_by_name(self, "RecipeCostContainer")
	recipe_result_container = Util.find_node_by_name(self, "RecipeResultContainer")
	recipe_power_cost_element = Util.find_node_by_name(self, "RecipePowerCostElement")


func assign_base_facility_menu(new_menu : BaseFacilityMenu):
	base_facility_menu = new_menu


func _on_craft_button_pressed():
	crafting_recipe.craft()
	if base_facility_menu:
		base_facility_menu.update()


func disable_craft_button() -> void:
	$HBoxContainer/CraftButton.disabled = true
