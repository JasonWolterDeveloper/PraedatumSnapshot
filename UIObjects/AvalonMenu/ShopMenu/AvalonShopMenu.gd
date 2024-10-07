class_name AvalonShopMenu extends Control

# ----- Control References ----- #
var shop_menu : ShopMenu



# ---------- Ready and Assignment Functions ---------- #


func _ready():
	shop_menu = Util.find_node_by_name(self, "ShopMenu")



# --------- Update Functions ---------- #


func update():
	var shop_facility : ShopFacility = HomeBaseFacilityMaster.get_facility_by_id("shop")
	
	if shop_facility:
		var current_shop : Shop = shop_facility.get_current_shop_for_level()
		shop_menu.open_shop(current_shop)
