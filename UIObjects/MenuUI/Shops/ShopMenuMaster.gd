class_name ShopMenuMaster extends UIMenuMaster

@onready var shop_menu : ShopMenu = $ShopMenu


func _ready():
	shop_menu.shop_menu_master = self


# Function to check if the menu can be opened
func can_open_menu() -> bool:
	return true


func open_menu():
	menu_open = true
	shop_menu.show()


func close_menu():
	menu_open = false
	shop_menu.hide()


func open_shop(shop : Shop):
	shop_menu.open_shop(shop)
	open_menu()


func close_shop():
	shop_menu.close_shop()
	close_menu()


func _process(delta : float) -> void:
	if menu_open:
		if Input.is_action_just_pressed("ui_cancel"):
			close_shop()
