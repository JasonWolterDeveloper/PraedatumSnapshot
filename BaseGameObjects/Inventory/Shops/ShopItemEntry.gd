class_name ShopItemEntry extends Node3D

var item : Item
@export var stock_quantity : int = 1
@export var originial_stock_quantity : int = 1
@export var custom_price : int = -1

## Markup
## markup variable is set by the store that owns this item entry
## do NOT modify manually. use custom price instead for price
## override
var mark_up : float = 1.0

const NOT_ENOUGH_SCRIP_CODE = "You do not have enough Scrip for this purchase"
const NOT_ENOUGH_SPACE_CODE = "You do not have space in your inventory for this purchase"
const NOT_ENOUGH_STOCK_CODE = "The Shop does not have enough stock for this purchase"


func _ready():
	find_item()
	

func is_using_custom_price():
	return custom_price > 0


func calculate_price(quantity : int = 1):
	if is_using_custom_price():
		return round(custom_price * quantity)
	else:
		return round(item.default_price * quantity * mark_up)


func generate_quantity_text():
	return str(stock_quantity)


func generate_price_text(buy_quantity : int):
	return str(calculate_price(buy_quantity))


func find_item():
	for child in get_children():
		if child is Item:
			item = child


func calculate_number_of_stacks_to_generate_for_quantity(item_quantity : int):
	return ceil((item_quantity*1.0)/(item.max_quantity *1.0))


func generate_purchased_item_array(item_quantity : int):
	var quantity_remaining = item_quantity
	var number_of_stacks_to_generate = calculate_number_of_stacks_to_generate_for_quantity(item_quantity)
	var purchased_item_array : Array[Item] = []
	for x in range(number_of_stacks_to_generate):
		var new_stack : Item = item.duplicate(7)
		
		if new_stack.max_quantity >= quantity_remaining:
			new_stack.current_quantity = quantity_remaining
		else:
			new_stack.current_quantity = new_stack.max_quantity
			
		purchased_item_array.append(new_stack)
		quantity_remaining -= new_stack.current_quantity
		
	return purchased_item_array


func error_when_buying(quantity: int, inventory : Inventory, price : int, item_array : Array[Item]):
	if quantity > stock_quantity:
		return NOT_ENOUGH_STOCK_CODE
	elif not inventory.has_enough_scrip(price):
		return NOT_ENOUGH_SCRIP_CODE
	elif not inventory.does_item_array_fit(item_array, true):
		return NOT_ENOUGH_SPACE_CODE
	return ""


func take_money_from_inventory(inventory : Inventory, price : int):
	inventory.remove_quantity_of_item_type(price, Scrip)
	

func transfer_items_to_inventory(inventory : Inventory, item_array : Array[Item]):
	inventory.insert_item_array(item_array, true)


func decrement_stock(quantity : int):
	stock_quantity -= quantity


func buy(inventory : Inventory, quantity : int = 1):
	var price : int = calculate_price(quantity)
	var item_array : Array[Item] = generate_purchased_item_array(quantity)
	var buying_error : String = error_when_buying(quantity, inventory, price, item_array)
	
	if buying_error:
		return buying_error
		
	take_money_from_inventory(inventory, price)
	decrement_stock(quantity)
	transfer_items_to_inventory(inventory, item_array)
	
	return ""
