## CraftingCategory is a purely aesthetic class used to sort crafting recipes into categories
## for the player
class_name  CraftingCategory extends Node

# ----- Exported Variables ----- #
@export var display_name = ""
@export var category_id = ""

# ----- Parent Variables ----- #
var parent_category : CraftingCategory = null

# ------ Child Variables ----- #
var child_categories : Array[CraftingCategory] = []
var child_recipes : Array[CraftingRecipe] = []



# ---------- Ready and Assignment Variables --------- #


func _ready():
	populate_child_categories()
	populate_child_recipes()


func assign_parent_category(new_parent_category : CraftingCategory) -> void:
	parent_category = new_parent_category


func populate_child_categories():
	for child in get_children():
		if child is CraftingCategory:
			child.assign_parent_category(self)
			child_categories.append(child)
 
 
func populate_child_recipes():
	for child in get_children():
		if child is CraftingRecipe:
			child.assign_parent_category(self)
			child_recipes.append(child)



# ---------- Helper Functions ---------- #


## contains_unlocked_recipe returns true if this category or any child category contains
## unlocked recipes. Used to hide categories in the UI if we have no unlocked recipes in the
## category
func contains_unlocked_recipe() -> bool:
	for recipe : CraftingRecipe in child_recipes:
		if recipe.check_base_facility_high_enough_level():
			return true
	for category : CraftingCategory in child_categories:
		if category.contains_unlocked_recipe():
			return true
	return false


func is_top_level():
	return parent_category == null


func find_top_level_category(category : CraftingCategory = self):
	if category.is_top_level():
		return category
	return find_top_level_category(category.parent_category)
