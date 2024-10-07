class_name PatrolMoveState extends MoveState

## Navigate towards next patrol waypoint
var patrol : Patrol :
	get : return my_character.patrol


# Pathfind towards our target every physics frame
func on_active(phys_delta) -> bool:
	assert(patrol, str(self) + "-PatrolMoveState.on_active(): Enemy.patrol not set")
	if patrol:
		movement_target = patrol.get_current_waypoint_position()
	super(phys_delta)

	if is_visiting_movement_target():
		patrol.next_waypoint()

	return false # Continuous routine

