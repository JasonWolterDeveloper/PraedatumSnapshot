class_name HasItemConditionEvaluator extends ConditionEvaluator

# Exported variables
@export var item_id: String = ""
@export var item_quantity: int = 1
@export var include_inventory: bool = true
@export var include_stash: bool = true


# Evaluate function
func evaluate() -> bool:
	var total_number = 0
	
	if include_inventory and InventoryMaster.get_player_inventory():
		total_number += InventoryMaster.get_player_inventory().find_quantity_of_items_with_id(item_id)
	if include_stash and InventoryMaster.get_player_stash():
		total_number += InventoryMaster.get_player_stash().find_quantity_of_items_with_id(item_id)
	
	if total_number >= item_quantity:
		return super()
	
	# If neither condition is met, return false
	return evaluate_false()
