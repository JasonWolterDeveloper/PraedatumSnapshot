class_name CraftingCategoryControl
extends Control

@export var greyed_out_colour:Color = Color(1.0, 1.0, 1.0, 0.4)## To indicate an unavailable recipe

# ----- Required Scenes ----- #
@export var crafting_category_button_scene: PackedScene
@export var recipe_ui_scene: PackedScene

# ----- Model variables ----- #
var crafting_category: CraftingCategory

# ----- Control variables ----- #
var base_facility_menu: BaseFacilityMenu
var back_to_top_button: Button
var back_button: Button
var recipe_container: Control
var crafting_category_button_container: Container


func _ready() -> void:
	back_to_top_button = Util.find_node_by_name(self, "BackToTopButton")
	back_button = Util.find_node_by_name(self, "BackButton")
	recipe_container = Util.find_node_by_name(self, "RecipeContainer")
	crafting_category_button_container = Util.find_node_by_name(self, "CraftingCategoryButtonContainer")


#---------- Assignment and Update functions ----------#


func assign_base_facility_menu(new_menu: BaseFacilityMenu):
	base_facility_menu = new_menu


# Function to assign a new category to crafting_category
func assign_crafting_category(new_category: CraftingCategory) -> void:
	crafting_category = new_category
	update()


func update() -> void:
	update_back_to_top_button_visibility()
	update_back_button_visibility()
	clear_crafting_category_buttons()
	clear_all_crafting_recipe_ui_elements()
	populate_crafting_recipes()
	populate_category_buttons()


func populate_category_buttons() -> void:
	if crafting_category:
		for my_category: CraftingCategory in crafting_category.child_categories:
			var new_category_button: CraftingCategoryButton = crafting_category_button_scene.instantiate()
			crafting_category_button_container.add_child(new_category_button)
			new_category_button.assign_crafting_category(my_category)
			new_category_button.category_selected.connect(on_crafting_category_button_press)


func populate_crafting_recipes() -> void:
	if crafting_category:
		for my_crafting_recipe: CraftingRecipe in crafting_category.child_recipes:
			var new_crafting_recipe_ui: CraftingRecipeUIElement = recipe_ui_scene.instantiate()
			recipe_container.add_child(new_crafting_recipe_ui)
			new_crafting_recipe_ui.assign_crafting_recipe(my_crafting_recipe)
			new_crafting_recipe_ui.assign_base_facility_menu(base_facility_menu)
			if not my_crafting_recipe.check_base_facility_high_enough_level():
				new_crafting_recipe_ui.modulate = greyed_out_colour
				new_crafting_recipe_ui.disable_craft_button()


# Function to update the visibility of the BackToTopButton
func update_back_to_top_button_visibility() -> void:
	if crafting_category and crafting_category.is_top_level():
		back_to_top_button.hide()
	else:
		back_to_top_button.show()


# Function to update the visibility of the BackButton
func update_back_button_visibility() -> void:
	if crafting_category and crafting_category.parent_category != null:
		back_button.show()
	else:
		back_button.hide()


# Helper function to recursively clear buttons of type CraftingCategoryButton
func clear_crafting_category_buttons(node: Node = self) -> void:
	# Check if the current node is of the type CraftingCategoryButton
	if node is CraftingCategoryButton:
		# Remove and free the node
		node.queue_free()
	else:
		# If the node has children, recursively check its children
		for child in node.get_children():
			clear_crafting_category_buttons(child)


# Helper function to recursively clear nodes of type CraftingRecipeUIElement
func clear_all_crafting_recipe_ui_elements(node: Node = self) -> void:
	# Check if the current node is of type CraftingRecipeUIElement
	if node is CraftingRecipeUIElement:
		# Remove and free the node
		node.queue_free()
	else:
		# If the node has children, recursively check its children
		for child in node.get_children():
			clear_all_crafting_recipe_ui_elements(child)



# ---------- Button Press Functions ---------- #


func on_crafting_category_button_press(new_crafting_category: CraftingCategory) -> void:
	assign_crafting_category(new_crafting_category)


func _on_back_to_top_button_press() -> void:
	if crafting_category:
		assign_crafting_category(crafting_category.find_top_level_category())


func _on_back_button_press() -> void:
	if crafting_category and crafting_category.parent_category:
		assign_crafting_category(crafting_category.parent_category)
