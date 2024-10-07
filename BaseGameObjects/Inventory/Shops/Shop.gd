class_name Shop extends Node3D

const NOT_ENOUGH_SPACE_CODE = "You do not have space in your inventory for this sale"
const SHOP_WONT_BUY_CODE = "The shop will not buy this item"

@export var shop_buy_mark_up : float = 1.1
@export var shop_sell_mark_down : float = 0.9

# Exported grid width and height
@export var grid_square_width:int = 10
@export var grid_square_height:int = 10

## Indicates whether or not this shop will buy items at all
@export var will_buy_items : bool = false

# Used for Calculation
@onready var base_scrip : Scrip = $BaseScrip
var scrip_scene = preload("res://Content/Default/Code/Items/Scrip.tscn")


func _ready():
	if not base_scrip:
		base_scrip = scrip_scene.instantiate()
		add_child(base_scrip)


func handle_open_store():
	update_item_entry_markup()


func update_item_entry_markup():
	for item_entry in get_item_entries():
		item_entry.mark_up = shop_buy_mark_up


func generate_price_text(item : Item):
	return str(calculate_sell_price(item))


func calculate_sell_price(item : Item):
	return round(item.default_price * item.current_quantity * shop_sell_mark_down)
	

func calculate_number_of_stacks_to_generate_for_quantity(quantity : int):
	return ceil((quantity*1.0)/(base_scrip.max_quantity *1.0))


func get_item_entries():
	var item_entry_array = []
	for my_child in get_children():
		if my_child is ShopItemEntry:
			item_entry_array.append(my_child)
	return item_entry_array


# Function to generate scrip array
func generate_scrip_array(quantity : int) -> Array[Item]:
	var scrip_array : Array[Item] = []
	var quantity_remaining = quantity
	
	var number_of_stacks_to_generate = calculate_number_of_stacks_to_generate_for_quantity(quantity)
	for x in range(number_of_stacks_to_generate):
		var new_stack : Scrip = base_scrip.duplicate(7)
		
		if new_stack.max_quantity >= quantity_remaining:
			new_stack.current_quantity = quantity_remaining
		else:
			new_stack.current_quantity = new_stack.max_quantity
			
		scrip_array.append(new_stack)
		quantity_remaining -= new_stack.current_quantity
		
	return scrip_array


func error_when_selling(item : Item, inventory : Inventory, scrip_array : Array[Item]):
	if not shop_will_buy(item):
		return SHOP_WONT_BUY_CODE
	elif not inventory.does_item_array_fit(scrip_array):
		return NOT_ENOUGH_SPACE_CODE
	return ""
	

func take_item_from_inventory(item : Item, inventory : Inventory):
	inventory.remove_item(item)


func transfer_items_to_inventory(inventory : Inventory, item_array : Array[Item]):
	inventory.insert_item_array(item_array)


func sell(item: Item, inventory: Inventory):
	var price : int = calculate_sell_price(item)
	var item_array : Array[Item] = generate_scrip_array(price)
	var selling_error : String = error_when_selling(item, inventory, item_array)
	
	if selling_error:
		return selling_error
		
	take_item_from_inventory(item, inventory)
	transfer_items_to_inventory(inventory, item_array)
	
	return ""


# Function for the shop to buy items
func shop_will_buy(item: Item) -> bool:
	if item is Scrip:
		return false
	return will_buy_items


func open_shop_menu() -> void:
	var level : Level = GameMaster.get_level()
	var universal_menu_master : UniversalMenuMaster = level.universal_menu_master
	
	universal_menu_master.get_shop_menu_master().open_shop(self)
	
