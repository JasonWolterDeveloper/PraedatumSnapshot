class_name SellMenuUI extends Control

@onready var price_component : Label = $VBoxContainer/PriceText
@onready var error_message : Label = $VBoxContainer/ErrorMessage
@onready var item_image : TextureRect = $VBoxContainer/ItemBackground/MarginContainer/ItemImage

var display_name_label : Label 
var quantity_text : Label

var shop : Shop
var destination_inventory : Inventory
var item: Item

signal successful_sale


# ---------- Ready and Assignment Functions ---------- #


func _ready():
	display_name_label = Util.find_node_by_name(self, "DisplayNameLabel")
	quantity_text = Util.find_node_by_name(self, "QuantityText")


func assign_shop(new_shop : Shop):
	shop = new_shop


func assign_destination_inventory(inventory : Inventory):
	destination_inventory = inventory



# --------- Update Functions ---------- #


func clear_sell_item():
	item = null
	reset()


func reset():
	reset_price_component()
	reset_item_image()
	reset_error_message()


func reset_price_component():
	price_component.text = "Price: N/A"


func reset_item_image():
	item_image.texture = null


func reset_error_message():
	error_message.hide()
	error_message.text = ""


func build_from_new_item(new_item : Item):
	item = new_item
	update_from_item()


func update_from_item():
	item_image.texture = item.inventory_image
	update_price_component(item)
	update_display_name(item)
	update_quantity_text(item)
	reset_error_message()


func handle_sell():
	if item:
		var error = shop.sell(item, destination_inventory)
		if not error:
			error_message.hide()
			clear_sell_item()
			successful_sale.emit()
		else:
			error_message.text = "Error: " + str(error)
			error_message.show()     
			
  
  
func update_price_component(item : Item):
	if item:
		var price_text = shop.generate_price_text(item)
		var final_price_text = "Price: " + str(price_text) + " Scrip"
		price_component.text = final_price_text


func update_display_name(item : Item):
	if item and display_name_label:
		display_name_label.text = item.display_name


func update_quantity_text(item : Item):
	if item and quantity_text:
		if item.show_quantity_in_ui:
			quantity_text.text = str(item.current_quantity)
		else:
			quantity_text.text = ""
