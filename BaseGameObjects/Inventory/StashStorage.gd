extends Storage

class_name StashStorage


func _ready():
	# Since we only ever should have one stash, it is fine to assign it to the 
	# global inveotry master singleton on ready
	assign_to_inventory_master()
	

func assign_to_inventory_master():
	InventoryMaster.assign_stash(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
