class_name Patrol extends Node3D

signal reached_pause_waypoint

enum available_patrol_types{CIRCULAR, LINEAR}
enum available_patrol_directions{FORWARDS, BACKWARDS}

@export var patrol_type = available_patrol_types.CIRCULAR
var waypoints : Array[PatrolWaypoint] = []

var current_patrol_direction = available_patrol_directions.FORWARDS
var current_patrol_waypoint_idx : int = 0


func _ready():
	find_all_waypoints()


func find_all_waypoints():
	waypoints.clear()
	for my_child in get_children():
		if my_child is PatrolWaypoint:
			waypoints.append(my_child)


func get_current_waypoint():
	return waypoints[current_patrol_waypoint_idx]


# Increments waypoint_idx to the next waypoint
func next_waypoint():
	if current_patrol_direction == available_patrol_directions.FORWARDS:
		current_patrol_waypoint_idx += 1
		
		if current_patrol_waypoint_idx >= len(waypoints):
			if patrol_type == available_patrol_types.CIRCULAR:
				current_patrol_waypoint_idx = get_first_waypoint_idx()
			elif patrol_type == available_patrol_types.LINEAR:
				current_patrol_direction = available_patrol_directions.BACKWARDS
				current_patrol_waypoint_idx -= 2
	else:
		current_patrol_waypoint_idx -= 1
		
		if current_patrol_waypoint_idx < 0:
			if patrol_type == available_patrol_types.CIRCULAR:
				current_patrol_waypoint_idx = get_last_waypoint_idx()
			elif patrol_type == available_patrol_types.LINEAR:
				current_patrol_direction = available_patrol_directions.FORWARDS
				current_patrol_waypoint_idx += 2
				
	if waypoints[current_patrol_waypoint_idx].pause_at_waypoint:
		reached_pause_waypoint.emit()


func get_current_waypoint_position():
	return waypoints[current_patrol_waypoint_idx].global_position


func get_first_waypoint_idx():
	return 0


func get_last_waypoint_idx():
	return waypoints.size() - 1
