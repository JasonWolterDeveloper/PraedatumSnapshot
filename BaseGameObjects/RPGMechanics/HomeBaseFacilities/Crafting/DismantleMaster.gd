extends Node

## A simple singleton that dismantles items into parts. Add Crafingrecipe_dict as children of this node.
## Dismantle Craftingrecipe_dict are assumed to only have ONE cost: one instance of an item. BaseFacility
## power requirements are ignored. 

var recipe_dict:Dictionary ## [item_id, CraftingRecipe]

# --------------------------------------------------- BUILT-IN METHODS

func _ready():
	populate_recipe_list()

# --------------------------------------------------- PUBLIC METHODS

## Probably not needed
#func add_recipe(new_recipe:CraftingRecipe) -> void:
	#assert(new_recipe.item_cost_dictionary.size == 1 and new_recipe.power_cost == 0)
	#recipe_dict[new_recipe.item_cost_dictionary.keys()[0].item_id] = new_recipe # Assume the item is the only cost
	#add_child(new_recipe)


## Simple helper function which checks if a dismantle recipe exists for the provided item
func recipe_exists(item:Item) -> bool:
	return recipe_dict.has(item.item_id)


## Returns true if we can dismantle the provided item given the recipe both exists and its requirements
## are met (e.g. base facility level). 
## enum destination {STASH, INVENTORY}
func dismantle(item:Item, destination:int = 1) -> bool:
	var matching_recipe = recipe_dict[item.item_id]
	
	if matching_recipe:
		return matching_recipe.craft(destination)
	return false

# --------------------------------------------------- PRIVATE METHODS

## Populates the recipe dict based on our child nodes
func populate_recipe_list(node : Node = self) -> void:
	for child in node.get_children():
		if child is CraftingRecipe:
			recipe_dict[child.item_cost_dictionary.keys()[0].item_id] = child
		populate_recipe_list(child)
