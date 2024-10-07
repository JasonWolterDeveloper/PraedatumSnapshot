class_name Room extends Node3D

const NAV_AGENT_RADIUS = 1.0

var characters_in_room : Array[Character] = []
@onready var terrain = $Terrain
@export var display_name : String = ''

var room_connectors : Array[RoomConnector] = []

@export var door_scene : PackedScene
@export var wall_scene : PackedScene

@export var difficulty_level : int = 1
@export var starting_room = false
# True if the difficulty level should increase in this room. Typically false
# for hallways and closets, and true otherwise.
@export var increase_difficulty_level = true
@export var enemy_spawn_table : SpawnTable
@export var loot_spawn_table : SpawnTable

@export var exit_spawn_point : ExitSpawnPoint = null

var unused_enemy_spawn_points : Array[SpawnPoint] = []
var unused_loot_spawn_points : Array[SpawnPoint] = []


func _ready():
	$Area.collision_layer = CollisionLayers.no_collision
	var nav_mesh = NavigationMesh.new()
	nav_mesh.agent_radius = NAV_AGENT_RADIUS
	terrain.navigation_mesh = nav_mesh
	terrain.bake_navigation_mesh(false)
	find_room_connectors(self)
	
	
func find_room_connectors(node):
	# Loop through all children of the current node
	for child in node.get_children():
		# Check if the child is of type RoomConnector
		if child is RoomConnector:
			# If yes, append it to the roomconnectors array
			room_connectors.append(child)
			child.home_room = self
		# Recursively call this function to search through the children of the current child node
		find_room_connectors(child)


func handle_enemy_spawns():
	populate_unused_enemy_spawn_points()
	if enemy_spawn_table:
		var enemy_spawn_array = Util.pick_random_array_element(enemy_spawn_table.spawns_by_difficulty_level[difficulty_level])
		for my_enemy_string in enemy_spawn_array:
			spawn_single_enemy(enemy_spawn_table.get_packed_scene_from_spawn_string(my_enemy_string))


func spawn_single_enemy(enemy_scene : PackedScene):
	if unused_enemy_spawn_points:
		var spawn_point : SpawnPoint = Util.pick_random_array_element(unused_enemy_spawn_points)
		spawn_point.spawn(enemy_scene)
		Util.delete_object_from_array(unused_enemy_spawn_points, spawn_point)


func populate_unused_enemy_spawn_points():
	for my_child in $EnemySpawners.get_children():
		if my_child is SpawnPoint:
			unused_enemy_spawn_points.append(my_child)


func handle_loot_spawns():
	populate_unused_loot_spawn_points()
	if loot_spawn_table:
		var loot_spawn_array = Util.pick_random_array_element(loot_spawn_table.spawns_by_difficulty_level[difficulty_level])
		for my_loot_string in loot_spawn_array:
			spawn_single_loot_item(loot_spawn_table.get_packed_scene_from_spawn_string(my_loot_string))


func spawn_single_loot_item(loot_scene : PackedScene):
	if unused_enemy_spawn_points:
		var spawn_point : SpawnPoint = Util.pick_random_array_element(unused_loot_spawn_points)
		spawn_point.spawn(loot_scene)
		Util.delete_object_from_array(unused_loot_spawn_points, spawn_point)


func populate_unused_loot_spawn_points():
	for my_child in $LootSpawners.get_children():
		if my_child is SpawnPoint:
			unused_loot_spawn_points.append(my_child)



# ---------- Room Connectivity Functions ---------- #


func find_room_connector_for_room(room : Room):
	for room_connector : RoomConnector in room_connectors:
		if room_connector.connected_room == room:
			return room_connector
	return null


func has_open_connection_to_room(room: Room):
	var room_connector : RoomConnector = find_room_connector_for_room(room)
	if room_connector:
		return room_connector.check_connection_open()
	return false


func has_exit_spawn_point():
	return exit_spawn_point != null


func _on_area_body_entered(body):
	if body is Character:
		body.entered_room(self)
		characters_in_room.append(body)


func _on_area_body_exited(body):
	if body is Character:
		body.exited_room(self)
		characters_in_room.remove_at(characters_in_room.find(body))
