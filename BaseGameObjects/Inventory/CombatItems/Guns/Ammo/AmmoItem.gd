class_name AmmoItem extends QuantityItem

# Ammo Type is a string used to check if this ammo can be used in a particular
# gun/magazine
@export var ammo_type : String 
@export var ammo_sub_type : String = "STRD"


func fits_in_magazine(mag : Magazine):
	return ammo_type == mag.ammo_type.ammo_type


func is_same_ammo_type(ammo: AmmoItem):
	return ammo_type == ammo.ammo_type


func is_same_ammo_sub_type(ammo : AmmoItem):
	return ammo_sub_type == ammo.ammo_sub_type


func interact_with_item(item: Item):
	if item is AmmoItem:
		if can_interact_with_item(item):
			return stack(item)
		return false
	else:
		return super(item)


func can_interact_with_item(item: Item):
	if can_stack_with_item(item):
		return true
	return super(item)  


func can_stack_with_item(item : Item):
	if item is AmmoItem:
		return is_same_ammo_type(item) and is_same_ammo_sub_type(item) and not item.is_full()
	return super(item)
