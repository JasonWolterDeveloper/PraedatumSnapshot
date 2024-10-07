extends NinePatchRect

class_name UtilityCard

@onready var utility_image : TextureRect = $MarginContainer/UtilityImage

func build_from_utility(utility : UtilityItem):
	if utility == null:
		utility_image.texture = null
	else:
		utility_image.texture = utility.inventory_image
	
