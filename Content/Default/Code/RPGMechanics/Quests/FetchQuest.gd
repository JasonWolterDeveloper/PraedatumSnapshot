class_name FetchQuest extends Quest

@export var quest_cost : Dictionary


func complete():
	pay_quest_cost()
	super()


func pay_quest_cost() -> void:
	for item_id : String in quest_cost.keys():
		var quantity : int = quest_cost[item_id]
		InventoryMaster.remove_quantity_of_item_with_item_id_from_player_inventory_and_stash(quantity, item_id)
