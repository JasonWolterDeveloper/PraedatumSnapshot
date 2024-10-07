class_name ShopMenu extends Control

# ----- Control Refs -----#
@onready var buy_menu : BuyMenuUI
@onready var sell_menu : SellMenuUI
@onready var shop_inventory_ui : ShopInventoryUI
@onready var player_shop_inventory_ui : PlayerShopInventoryUI
var close_shop_button : Button
var shop_menu_master : ShopMenuMaster

# ----- Model Refs ----- #
var shop : Shop
var player : Player

# ----- Tracking Variables ----- #
# var is_open : bool = false

# ----- Configurable Variables -----#
## Used for instances such as in the hub level where you don't want to close
## the shoppe
@export var hide_close_shop_menu : bool = false



# --------- Ready and Assignment Functions ---------- #


func _ready():
	buy_menu = Util.find_node_by_name(self, "BuyMenuUI")
	sell_menu = Util.find_node_by_name(self, "SellMenuUI")
	shop_inventory_ui = Util.find_node_by_name(self, "ShopInventoryUI")
	player_shop_inventory_ui = Util.find_node_by_name(self, "PlayerShopInventoryUI")
	close_shop_button = Util.find_node_by_name(self, "CloseShopButton")
	
	if hide_close_shop_menu:
		close_shop_button.hide()


func assign_shop(new_shop : Shop):
	shop = new_shop
	shop_inventory_ui.build_from_shop(new_shop)
	sell_menu.assign_shop(shop)


func assign_player(new_player : Player):
	player = new_player
	buy_menu.assign_destination_inventory(player.inventory)
	sell_menu.assign_destination_inventory(player.inventory)
	player_shop_inventory_ui.build_from_storage(player.inventory.main_storage)


func _on_buy_menu_ui_he_bought():
	shop_inventory_ui.update()
	player_shop_inventory_ui.update()


func _on_shop_inventory_ui_new_item_entry_selected():
	buy_menu.build_from_new_item_entry(shop_inventory_ui.currently_selected_item_entry)
	buy_menu.show()
	sell_menu.hide()


func on_select_item_to_sell(item : Item):
	buy_menu.hide()
	sell_menu.show()
	sell_menu.build_from_new_item(item)
	

func _on_sell_menu_ui_successful_sale():
	sell_menu.hide()
	player_shop_inventory_ui.update()


func open_shop(new_shop : Shop):
	new_shop.handle_open_store()
	assign_shop(new_shop)
	assign_player(GameMaster.get_player())
	player_shop_inventory_ui.update()


func close_shop():
	hide()
	buy_menu.hide()


func on_quit_button_clicked():
	close_shop()
	if shop_menu_master:
		shop_menu_master.close_shop()


func _process(delta):
	if Input.is_action_just_pressed("ui_click"):
		if player_shop_inventory_ui.hovered_item_domino:
			## TODO - This is scary and I don't know why we still have invalid Item Dominos in our
			## shoppe menu, but occasionally it happens
			## UPDATE - This was PROBABLY caused by the Inventory not being properly updated when
			## swapping tabs in the Avalon Menu but I am STILL SCARED
			if is_instance_valid(player_shop_inventory_ui.hovered_item_domino.item):
				on_select_item_to_sell(player_shop_inventory_ui.hovered_item_domino.item)
