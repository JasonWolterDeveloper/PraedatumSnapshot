class_name Scrip extends QuantityItem


func interact_with_item(item: Item):
	if item is Scrip:
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
	if item is Scrip:
		return not item.is_full()
	return super(item)
