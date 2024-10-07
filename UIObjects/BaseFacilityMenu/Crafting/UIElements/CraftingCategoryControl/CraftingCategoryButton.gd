class_name CraftingCategoryButton extends Button

# ----- Control References ----- #

# ----- Model References ----- #
var crafting_category : CraftingCategory

# ----- Signals ----- #
signal category_selected(category : CraftingCategory)



# --------- Ready and Assignment Functions --------- #


func assign_crafting_category(new_category : CraftingCategory):
	crafting_category = new_category
	text = crafting_category.display_name


func _on_pressed() -> void:
	category_selected.emit(crafting_category)
