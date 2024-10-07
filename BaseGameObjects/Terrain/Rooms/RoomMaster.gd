class_name RoomMaster extends Node3D

var rooms : Array[Room] = []
var starting_room : Room
var exit_room : Room = null


func _ready():
	clear_rooms()
	populate_rooms()
	prepare_rooms()


func clear_rooms():
	rooms.clear()


func populate_rooms(node = self) -> void:
	for my_child in node.get_children():
		if my_child is Room:
			rooms.append(my_child)
		populate_rooms(my_child)


func find_starting_room() -> void:
	for my_room : Room in rooms:
		if my_room.starting_room:
			starting_room = my_room
			return
	# We have a serious problem if our starting room is null
	# assert(not starting_room == null)


func select_random_exit_room() -> void:
	var possible_exit_rooms = []
	for my_room : Room in rooms:
		if my_room.has_exit_spawn_point():
			possible_exit_rooms.append(my_room)
	if possible_exit_rooms:
		exit_room = Util.pick_random_array_element(possible_exit_rooms)
		
		
func handle_spawn_exit():
	if exit_room:
		if exit_room.exit_spawn_point:
			exit_room.exit_spawn_point.spawn_exit()


func prepare_rooms() -> void:
	find_starting_room()
	connect_rooms()
	fill_in_room_connectors()
	

func connect_rooms() -> void:
	# Loop through each room
	for room : Room in rooms:
		# DebugMaster.log_debug("We are looping: " + room.name )
		# Loop through each room_connector in the current room
		for room_connector : RoomConnector in room.room_connectors:
			# Try to hook the room connector up to a door
			room_connector.check_for_door(room)
			# Loop through each room again
			for other_room : Room in rooms:
				# Ignore the current room
				if other_room != room:
					# Loop through each room_connector in the other room
					for other_room_connector: RoomConnector in other_room.room_connectors:
						# Run check_physically_connected from the original room_connector element
						if room_connector.check_physically_connected(other_room_connector):
							# Run connect_to_room_connector from the original room_connector element to the current one
							room_connector.connect_to_room_connector(other_room_connector)
							# DebugMaster.log_debug("We are connecting: " + room.name + " " + other_room.name )


func fill_in_room_connectors() -> void:
	# Loop through each room
	for room : Room in rooms:
		# Loop through each room_connector in the current room
		for room_connector : RoomConnector in room.room_connectors:
			room_connector.fill_in_room_connector_if_not_filled_in()


func handle_room_spawns() -> void:
	for room : Room in rooms:
		room.handle_enemy_spawns()
		room.handle_loot_spawns()
	
	
func handle_level_exit_setup():
	select_random_exit_room()
	handle_spawn_exit()
	
