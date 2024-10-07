extends Panel

class_name EquipmentCard

@onready var equipment_image : TextureRect = $MarginContainer/EquipmentImage

func build_from_equipment(equipment:Item):
	if equipment == null:
		equipment_image.texture = null
	else:
		equipment_image.texture = equipment.inventory_image
