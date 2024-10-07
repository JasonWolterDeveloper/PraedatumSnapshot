extends Button


var base_facility_selection_menu
var base_facility : HomeBaseFacility


func assign_selection_menu(menu):
	base_facility_selection_menu = menu


func build_from_base_facility(new_facility : HomeBaseFacility):
	base_facility = new_facility
	text = base_facility.display_name


func _on_pressed():
	base_facility_selection_menu.open_menu_for_base_facility(base_facility)
