class_name RoomConnector extends Node3D

var home_room : Room = null
var connected_room : Room = null
var connected_room_connector : RoomConnector = null

@export var door_scene_override : PackedScene = null
@export var door_scene_priority : int = 0

@export var wall_scene_override : PackedScene = null
@export var connector_length = 0

var door_or_wall_spawned = false

@onready var door_position : Marker3D = $DoorPosition

## existing_door is a variable used to indicate that a door already exists in the
## level editor. We will check this when asked to call fill_in_room_connector_if_not_filled_in
## and, if a door already exists, we won't fill the connector in
@export var door : Door


func _ready():
	pass
	
	
func fill_in_room_connector_if_not_filled_in() -> void:
	# Checking if we have an existing door in the editor before trying to spawn
	# our door or wall
	if door:
		door_or_wall_spawned = true
	if connected_room_connector:
		if connected_room_connector.door:
			door = connected_room_connector.door
			door_or_wall_spawned = true
	
	if not door_or_wall_spawned:
		make_door_or_wall()


func make_door_or_wall() -> void:
	# Check if connected_room_connector is not null
	if connected_room_connector != null:
		# Compare door_scene_priority values
		if door_scene_priority >= connected_room_connector.door_scene_priority:
			# Instantiate scene from our own door_scene
			var door_scene_instance = get_door_scene().instantiate()
			# Add the door_scene_instance as a child of ourselves
			add_child(door_scene_instance)
			door_scene_instance.position = door_position.position
			door = door_scene_instance
		else:
			# Instantiate scene from connected_room_connector's door_scene
			var door_scene_instance = connected_room_connector.get_door_scene().instantiate()
			# Add the door_scene_instance as a child of ourselves
			add_child(door_scene_instance)
			door_scene_instance.position = door_position.position
			door = door_scene_instance
		# Set door_or_wall_spawned boolean value to true for both ourselves and connected_room_connector
		door_or_wall_spawned = true
		connected_room_connector.door_or_wall_spawned = true
	else:
			# Instantiate scene from get_wall_scene()
		var wall_scene_instance = get_wall_scene().instantiate()
		# Call generate_wall_of_length on the new scene
		wall_scene_instance.generate_wall_of_length(connector_length)
		# Add the wall_scene_instance as a child of ourselves
		add_child(wall_scene_instance)
		# Set door_or_wall_spawned boolean value to true for ourselves
		door_or_wall_spawned = true


func check_connection_open():
	if door:
		return door.is_open
	return true


func get_connected_room_connector() -> RoomConnector:
	if connected_room:
		for room_connector : RoomConnector in connected_room.room_connectors:
			if room_connector.connected_room == home_room:
				return room_connector
	return null


func get_door_scene() -> PackedScene:
	if door_scene_override:
		return door_scene_override
	elif home_room:
		return home_room.door_type
	return null
	
	
func get_wall_scene() -> PackedScene:
	if wall_scene_override:
		return wall_scene_override
	elif home_room:
		return home_room.wall_scene
	return null
	
	
func check_connected(other_room_connector : RoomConnector):
	var connected = (connected_room == other_room_connector.home_room and 
	connected_room_connector == other_room_connector and 
	other_room_connector.connected_room == home_room
	and other_room_connector.connected_room_connector == self)
	
	return connected
	
	
func connect_to_room_connector(other_room_connector : RoomConnector):
	connected_room = other_room_connector.home_room
	connected_room_connector = other_room_connector
	
	other_room_connector.connected_room = home_room
	other_room_connector.connected_room_connector = self
	
	
# Returns true if the global positions of these two connections are the same
func check_physically_connected(other_connector : RoomConnector):
	return other_connector.door_position.global_position.is_equal_approx(door_position.global_position)


# A function to check for a pre-existing door. Will loop through all children of the room recursively
# checking if they are doors, and checking if their global position is equal to our door position
# assigning them as our door if they are
func check_for_door(node : Node = home_room):
	if node and not door:
		if node is Door:
			if node.global_position.is_equal_approx(door_position.global_position):
				door = node
		for child in node.get_children():
			check_for_door(child)
