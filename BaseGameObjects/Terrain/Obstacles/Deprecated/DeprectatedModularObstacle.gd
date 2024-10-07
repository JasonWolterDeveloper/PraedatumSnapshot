class_name ModularObstacle extends Obstacle

@onready var collision_shape = $CollisionShape3D

@export var tile_size_in_meters = 1
@export var obstacle_segment_scene : PackedScene


func _ready():
	prepare_modular_obstacle()


func get_shape() -> BoxShape3D:
	return collision_shape.shape


func get_obstacle_length():
	return get_shape().size.x


func get_number_of_tiles():
	return get_obstacle_length()/tile_size_in_meters


func create_obstacle_segment():
	if obstacle_segment_scene:
		return obstacle_segment_scene.instantiate()


func calculate_half_length():
	return (tile_size_in_meters*get_obstacle_length())/2.0


func prepare_modular_obstacle():
	generate_all_obstacle_segments()


func generate_all_obstacle_segments():
	for x in range(get_number_of_tiles()):
		var new_obstacle_segment : Node3D = create_obstacle_segment()
		place_obstacle_segment(new_obstacle_segment, x)
		add_child(new_obstacle_segment)


# Where our first wall segment is placed. We will determine the location of all
# other wall segments from this position. Calculated by determine the maximum
# extent of the modular wall in the negative x direction, then taking away half
# of the length of a wall tile from that value to determine the middle point of
# the first segment
func calculate_first_obstacle_segment_position():
	var maximum_negative_x_extent = 0.0 - calculate_half_length()
	var half_tile_size = tile_size_in_meters/2.0
	return maximum_negative_x_extent + half_tile_size


# Placing the wall segment indicated by wall_segment_number (0 is the first segment,
# 1 is the second segment, etc.) based on the position of the first wall segment
# We do this by calculating the exact position of the first wall segment, and then adding
# wall segment tile lengths to the position based on which number wall_segment we are
# placing 
func place_obstacle_segment(obstacle_segment : Node3D, segment_idx : int):
	var first_obstacle_segment_position = calculate_first_obstacle_segment_position()
	var shift_value = segment_idx * tile_size_in_meters
	var final_x_position = first_obstacle_segment_position + shift_value
	
	obstacle_segment.position.x = final_x_position
	# Putting the wall_segment on the ground by lifting it up by tile size: - probably nothing
	# obstacle_segment.position.y = wall_tile_height_in_meters/2.0
	
	
"""
# Used to generate walls programatically	
func generate_wall_of_length(length: int) -> void:
	# Create a box mesh
	var new_mesh = BoxMesh.new()
	new_mesh.size.x = length
	new_mesh.size.y = 1
	new_mesh.size.z = wall_thickness
	
	# Assign the box mesh to the MeshInstance node
	mesh = new_mesh
	editor_mesh = new_mesh
"""
