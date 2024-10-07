class_name UpgradeMaterialItem extends QuantityItem

func _ready():
	super()
	assert(item_type == item_types.UPGRADE)
