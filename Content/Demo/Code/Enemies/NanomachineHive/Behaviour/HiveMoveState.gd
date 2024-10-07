class_name HiveMoveState extends MoveState

## HiveMoveState is the MoveState implementation particularly for hive
## Notably, it switches off the nano machines if they are turned on because 
## any transition out of attacking states must transition through the move state 


func on_entry(phys_delta) -> bool:
	super(phys_delta)
	if my_character.has_method("deactivate_nanomachines"):
		my_character.deactivate_nanomachines()
	return true # One-shot routine
