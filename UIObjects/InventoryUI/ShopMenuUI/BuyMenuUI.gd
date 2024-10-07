class_name BuyMenuUI extends Control

@onready var buy_quantity_input : SpinBox = $VBoxContainer/HBoxContainer/ValueInputSpinBox
@onready var price_component : Label = $VBoxContainer/PriceText
@onready var item_image : TextureRect = $VBoxContainer/ItemBackground/MarginContainer/ItemImage
@onready var error_message : Label = $VBoxContainer/ErrorMessage
@onready var buy_button : Button = $VBoxContainer/BuyButton
@onready var stock_remaining_text : Label = $VBoxContainer/StockRemainingText

var display_name_label : Label 

var destination_inventory : Inventory
var item_entry : ShopItemEntry

signal he_bought


func _ready():
	display_name_label = Util.find_node_by_name(self, "DisplayNameLabel")
	item_image = Util.find_node_by_name(self, "ItemImage")


func assign_destination_inventory(inventory : Inventory):
	destination_inventory = inventory


func build_from_new_item_entry(new_item_entry : ShopItemEntry):
	reset_values()
	item_entry = new_item_entry
	update_from_item_entry()


func update_from_item_entry():
	item_image.texture = item_entry.item.inventory_image
	update_max_quantity_from_item_entry()
	update_stock_remaining_text()
	update_price_component(get_quantity())
	update_display_name(item_entry.item)


func reset_values():
	buy_quantity_input.value = 1
	error_message.text = ""
	error_message.hide()
	

func update_max_quantity_from_item_entry():
	if item_entry:
		buy_quantity_input.max_value = item_entry.stock_quantity
		buy_quantity_input.value = min(buy_quantity_input.max_value, buy_quantity_input.value)

		if item_entry.stock_quantity <= 0:
			buy_quantity_input.min_value = 0
			buy_button.disabled = true
			buy_quantity_input.value = 0
		else:
			buy_quantity_input.min_value = 1
			buy_button.disabled = false


func update_stock_remaining_text():
	if item_entry:
		stock_remaining_text.text = "Stock Remaining: " + item_entry.generate_quantity_text()


func on_buy_quantity_input_change(new_value : float):
	update_from_item_entry()


func handle_buy():
	if item_entry:
		var error = item_entry.buy(destination_inventory, get_quantity())
		if not error:
			error_message.hide()
		else:
			error_message.text = "Error: " + str(error)
			error_message.show()     
		
		update_from_item_entry()
		he_bought.emit()
  
  
func update_price_component(quantity):
	if item_entry:
		var price_text = item_entry.generate_price_text(quantity)
		var final_price_text = "Price: " + str(price_text) + " Scrip"
		price_component.text = final_price_text


func update_display_name(item : Item):
	if item and display_name_label:
		display_name_label.text = item.display_name


func get_quantity():
	return int(buy_quantity_input.value)
