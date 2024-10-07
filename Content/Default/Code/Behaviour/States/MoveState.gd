class_name MoveState extends State

## Navigate toward the set target position. movement_target must be set by a 
## parent state or by the state itself if extending

signal is_visiting_destination(value:bool)

# The distance we need to be from the movement_target to be considered 
# visiting it
@export var visiting_point_tolerance:float = 0.1

var movement_target:Vector3
## Force update the path the first phys frame; using a flag since we don't want to move in on_entry()
var path_initialized:bool = false 


# Pathfind towards our target every physics frame
func on_active(phys_delta) -> bool:
	assert(movement_target)
	super(phys_delta)
	my_character.aiming_master.should_look_in_movement_direction = true
	do_navigation(not path_initialized) # Update path based on timer to save CPU
	path_initialized = true
	return false # Continuous routine


func on_exit(phys_delta) -> bool:
	super(phys_delta)
	path_initialized = false
	return true


func do_navigation(immediately_update_path:bool) -> void:
	assert(movement_target)
	if movement_target and not is_visiting_movement_target():
		my_character.navigate_enemy(movement_target, immediately_update_path)


func is_visiting_movement_target():
	var movement_target_no_y_component = Vector3(movement_target.x, my_character.global_position.y, movement_target.z)
	var is_visiting:bool = my_character.global_position.distance_to(movement_target_no_y_component) <= visiting_point_tolerance
	is_visiting_destination.emit(is_visiting)
	
	return is_visiting


func init():
	super()
	for link in links:
		if link is DestinationReachedLink:
			is_visiting_destination.connect(link.set_destination_reached)
