extends Control

@export var player : Player
@export var stash_storage : StashStorage
@export var lost_and_found_storage : LostAndFoundStorage

@onready var stash_menu : StashMenu = $MarginContainer/TabContainer/Stash
@onready var base_facility_menu : BaseFacilitySelectionMenu = $"MarginContainer/TabContainer/Base Facilities"

var warrior_menu : WarriorMenu
var avalon_shop_menu : AvalonShopMenu
var lost_and_found_menu : LostAndFoundUIMenuMaster
var tab_container : TabContainer


func _ready():
	warrior_menu = Util.find_node_by_name(self, "WarriorMenu")
	avalon_shop_menu = Util.find_node_by_name(self, "Ye Auld Shoppe")
	lost_and_found_menu = Util.find_node_by_name(self, "Lost And Found")
	tab_container = Util.find_node_by_name(self, "TabContainer")


func prepare_avalon_menu():
	stash_menu.prepare_ui(player, stash_storage)
	lost_and_found_menu.open_lost_and_found_menu(player.inventory, lost_and_found_storage)


func update_all():
	stash_menu.update()
	base_facility_menu.update()
	warrior_menu.update()


"""
func _on_tab_container_tab_changed(tab):
	if tab == 0:
		stash_menu.update()
	elif tab == 2:
		avalon_shop_menu.update()
	elif tab == 4:
		base_facility_menu.update()
	else:
		if warrior_menu:
			warrior_menu.update()
"""


func quit():
	GameMaster.get_level().handle_quit()
	get_tree().quit()


func _on_tab_container_tab_selected(tab):
	if tab_container:
		if tab_container.get_tab_control(tab).has_method("update"):
			tab_container.get_tab_control(tab).update()
