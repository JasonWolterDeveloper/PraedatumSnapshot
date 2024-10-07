class_name BaseFacilityMenu extends Control

const CURRENT_LEVEL_PREFIX = "Current Level: "
const CENTER_BB_CODE_PREFIX = "[center]"
const CENTER_BB_CODE_SUFFIX = "[/center]"

var base_facility_selection_menu : BaseFacilitySelectionMenu

var base_facility : HomeBaseFacility

# PackedScenes requried for building the UI
@export var recipe_ui_scene : PackedScene

# UI Elements we need references to
var facility_name : Label
var level_ui : BaseFacilityLevelUIElement
var description_label : RichTextLabel
var upgrade_container : Container
var upgrade_recipe_ui : UpgradeRecipeUI
var use_button : Button
var crafting_container : Container
var crafting_recipe_container : Container
var crafting_category_control : CraftingCategoryControl


func _ready():
	populate_ui_elements()
	

func populate_ui_elements():
	facility_name = Util.find_node_by_name(self, "FacilityName")
	level_ui = Util.find_node_by_name(self, "BaseFacililtyLevelUIElement")
	description_label = Util.find_node_by_name(self, "DescriptionLabel")
	upgrade_container = Util.find_node_by_name(self, "UpgradeContainer")
	upgrade_recipe_ui = Util.find_node_by_name(self, "UpgradeRecipeUI")
	use_button = Util.find_node_by_name(self, "UseButton")
	crafting_container = Util.find_node_by_name(self, "CraftingContainer")
	crafting_recipe_container = Util.find_node_by_name(self, "CraftingRecipeContainer")
	crafting_category_control = Util.find_node_by_name(self, "CraftingCategoryControl")


func assign_base_facility_selection_menu(new_menu : BaseFacilitySelectionMenu):
	base_facility_selection_menu = new_menu


func close():
	get_parent().remove_child(self)
	queue_free()


func build_from_base_facility(new_facility : HomeBaseFacility):
	base_facility = new_facility
	
	level_ui.assign_base_facility(base_facility)
	crafting_category_control.assign_base_facility_menu(self)
	
	if base_facility.top_level_crafting_category != null:
		crafting_category_control.show()
		crafting_category_control.assign_crafting_category(base_facility.top_level_crafting_category)
	else:
		crafting_category_control.hide()

	update()


func update():
	build_facility_name_label()
	build_description_label()
	update_upgrade_info()
	update_use_button()
	level_ui.update()
	if base_facility_selection_menu:
		base_facility_selection_menu.update()
	crafting_category_control.update()


func update_upgrade_info():
	if base_facility.can_upgrade():
		upgrade_container.show()
		upgrade_recipe_ui.assign_crafting_recipe(base_facility.get_upgrade_recipe_for_next_level())
		upgrade_recipe_ui.assign_base_facility_menu(self)
	else:
		upgrade_container.hide()


func update_use_button():
	if base_facility.is_usable_facility:
		use_button.show()
		use_button.disabled = !base_facility.can_use_facility()
	else:
		use_button.hide()


func build_facility_name_label():
	facility_name.text = base_facility.display_name


func build_description_label():
	var constructed_text = CENTER_BB_CODE_PREFIX + base_facility.description + CENTER_BB_CODE_SUFFIX
	
	description_label.text = constructed_text


func clear_existing_recipe_menu():
	for my_child in crafting_recipe_container.get_children():
		if my_child is CraftingRecipeUIElement:
			crafting_recipe_container.remove_child(my_child)
			my_child.queue_free()


func _on_exit_button_pressed():
	close()


func _on_back_button_pressed():
	close()


func _on_use_button_pressed():
	base_facility.use_facility()
	update()
