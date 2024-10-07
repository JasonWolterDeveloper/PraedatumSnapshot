class_name ShopFacility extends HomeBaseFacility

@export var shop_per_level : Array[Shop] = []


func get_current_shop_for_level():
	return shop_per_level[current_upgrade_level]
