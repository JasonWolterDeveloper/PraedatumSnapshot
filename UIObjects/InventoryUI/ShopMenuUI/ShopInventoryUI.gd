class_name ShopInventoryUI extends Control

@onready var item_entry_container = $ShopPanel/ScrollContainer/ItemEntryContainer

var shop_item_entry_buttons = []

# The actual shop item this container represents
var shop : Shop = null
var currently_selected_item_entry : ShopItemEntry = null

@export var shop_item_entry_button_scene : PackedScene

signal new_item_entry_selected


func build_from_shop(new_shop):
	shop = new_shop
	reset()
	create_buttons_from_shop_item_entries()


func update():
	update_shop_item_entry_buttons()


func update_shop_item_entry_buttons():
	for my_button in shop_item_entry_buttons:
		my_button.update()


func create_buttons_from_shop_item_entries():
	if shop:
		for my_item_entry in shop.get_item_entries():
			var new_item_entry_button : ShopItemEntryButton = shop_item_entry_button_scene.instantiate()
			item_entry_container.add_child(new_item_entry_button)
			new_item_entry_button.build_from_new_item_entry(my_item_entry)
			shop_item_entry_buttons.append(new_item_entry_button)
			new_item_entry_button.connect("item_entry_selected", on_item_entry_selected)


func reset():
	for my_item_entry_button in shop_item_entry_buttons:
		item_entry_container.remove_child(my_item_entry_button)
		my_item_entry_button.queue_free()
	shop_item_entry_buttons.clear()


func reset_selected_item_entry():
	currently_selected_item_entry = null


func on_item_entry_selected(new_item_entry : ShopItemEntry):
	currently_selected_item_entry = new_item_entry
	new_item_entry_selected.emit()
