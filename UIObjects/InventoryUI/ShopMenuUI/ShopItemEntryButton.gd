class_name ShopItemEntryButton extends Control

# ----- Label Constants ----- #
const PRICE_PREFIX = "Price: "
const STOCK_PREFIX = "Stock: "
const SCRIP_SUFFIX = " Scrip"

# ----- Control References ----- #
@onready var item_image = $TextureButton/MarginContainer/ItemImage
@onready var price_text = $TextureButton/MarginContainer/PriceText
@onready var quantity_text = $TextureButton/MarginContainer/QuantityText
var display_name_text : Label

# ----- Model References ----- #
var item_entry : ShopItemEntry

# ----- Signals ----- #
signal item_entry_selected(item_entry : ShopItemEntry)


func _ready():
	display_name_text = Util.find_node_by_name(self, "DisplayNameText")


func build_from_new_item_entry(new_item_entry : ShopItemEntry):
	item_entry = new_item_entry
	update()


func update():
	item_image.texture = item_entry.item.inventory_image
	update_quantity_text_from_item_entry()
	update_price_text_from_item_entry()
	update_display_name_from_item_entry()
	

func update_quantity_text_from_item_entry():
	quantity_text.text = STOCK_PREFIX + item_entry.generate_quantity_text()


func update_price_text_from_item_entry():
	price_text.text = PRICE_PREFIX + item_entry.generate_price_text(1) # + SCRIP_SUFFIX


func update_display_name_from_item_entry():
	if display_name_text:
		display_name_text.text = item_entry.item.display_name
	

func on_press():
	item_entry_selected.emit(item_entry)
