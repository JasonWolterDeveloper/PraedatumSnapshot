class_name PatrolPauseWaypointLink extends Link

var patrol : Patrol :
	get: return my_character.patrol

var has_reached_pause_waypoint = false


func is_triggered():
	return has_reached_pause_waypoint


func on_entry():
	has_reached_pause_waypoint = false


func on_exit():
	has_reached_pause_waypoint = false


func on_reach_pause_waypoint():
	has_reached_pause_waypoint = true


func init():
	if patrol:
		patrol.reached_pause_waypoint.connect(on_reach_pause_waypoint)
