class_name LostAndFoundStorage extends Storage

func _ready():
	# Since we only ever should have one stash, it is fine to assign it to the 
	# global inveotry master singleton on ready
	assign_to_inventory_master()
	

func assign_to_inventory_master():
	InventoryMaster.assign_lost_and_found(self)
