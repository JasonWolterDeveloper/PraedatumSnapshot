class_name DestinationReachedLink extends Link

## An admittedly hacky way of determing if our Enemy has reached their 
## MoveState.movement_target, accounting for visiting tolerance. Signal callback
## is connected in MoveState.init()

var destination_reached:bool = false


func is_triggered() -> bool:
	return destination_reached


func on_exit() -> void:
	super()
	destination_reached = false


## Signal callback for MoveState.is_visiting_destination
func set_destination_reached(value:bool):
	destination_reached = value
