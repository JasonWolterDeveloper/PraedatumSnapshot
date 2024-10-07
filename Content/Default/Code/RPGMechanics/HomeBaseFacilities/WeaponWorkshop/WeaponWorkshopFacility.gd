extends HomeBaseFacility

## Add CraftingCategory "DismantleCategory" if you'd like to list dismantle recipes

## Currently unused. Call in _ready() if desired
func add_dismantle_recipes():
	var category:CraftingCategory = Util.find_node_by_name(self, "DismantleCategory")
	
	assert(category)
	if category:
		# Manually add recipes to the provided category rather than auto-populate via CraftingCategory.populate_child_recipes() 
		for recipe:CraftingRecipe in DismantleMaster.recipe_dict.values():
			recipe.assign_parent_category(category)
			category.child_recipes.append(recipe)
