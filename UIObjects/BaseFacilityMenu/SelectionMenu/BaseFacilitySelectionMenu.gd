class_name BaseFacilitySelectionMenu extends Control


var base_facility_button_box : Container
var base_power_ui : BaseSolarPowerUI
@export var selection_button : PackedScene
@export var base_facility_menu_scene : PackedScene


func _ready():
	base_facility_button_box = Util.find_node_by_name(self, "BaseFacilitySelectionButtonVbox")
	base_power_ui = Util.find_node_by_name(self, "BaseSolarPowerUI")


func update():
	clear_existing_buttons()
	populate_buttons_from_master()
	base_power_ui.update()


func clear_existing_buttons():
	for my_child in base_facility_button_box.get_children():
		if my_child is Button:
			base_facility_button_box.remove_child(my_child)
			my_child.queue_free()


func open_menu_for_base_facility(base_facility : HomeBaseFacility):
	var base_facility_menu : BaseFacilityMenu = base_facility_menu_scene.instantiate()
	add_child(base_facility_menu) # Must be added to the scenetree before being built
	base_facility_menu.build_from_base_facility(base_facility)
	base_facility_menu.assign_base_facility_selection_menu(self)


func populate_buttons_from_master():
	var thisDoes = true
	for facility : HomeBaseFacility in HomeBaseFacilityMaster.home_base_facility_list:
		var new_button : Button = selection_button.instantiate()
		new_button.build_from_base_facility(facility)
		new_button.assign_selection_menu(self)
		base_facility_button_box.add_child(new_button)
