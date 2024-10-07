class_name ModularWall extends MeshInstance3D

# used for the collision shape
const PHYSICAL_WALL_HEIGHT = 10

@onready var editor_mesh : BoxMesh = self.mesh

@onready var collision_shape : CollisionShape3D = $StaticBody3D/CollisionShape3D

@export var wall_thickness = 0.1

@export var wall_tile_size_in_meters : int = 1
@export var wall_tile_height_in_meters : int = 1
var total_wall_segments

@export var primary_wall_segment : PackedScene
var primary_wall_segment_weight

@export var generate_end_caps : bool = true
@export var wall_end_cap : PackedScene

@export var debug = false
# We want to have multiple wall segments we can use to construct a wall, and
# to construct our wall from these segments randomly. To do this we have a
# set of packed scenes which are our  secondary segments, and weights for the percent
# chance we spawn that secondary wall segment type.
@export var secondary_wall_segments : Array[PackedScene] = []
@export var secondary_wall_segment_weights : Array[float] = []

func _ready():
	assert(primary_wall_segment != null)
	assert(wall_end_cap != null)
	assert(len(secondary_wall_segments) == len(secondary_wall_segment_weights))
	prepare_modular_wall()
	generate_collision_shape()
	delete_editor_mesh()
	
	
func generate_collision_shape():
	var new_collision_shape = BoxShape3D.new()
	new_collision_shape.size = editor_mesh.size
	new_collision_shape.size.y = PHYSICAL_WALL_HEIGHT
	collision_shape.shape = new_collision_shape
	
	
func delete_editor_mesh():
	mesh = null


func prepare_modular_wall():
	generate_primary_wall_segment_weight()
	generate_total_wall_segments_value()
	
	generate_all_wall_segments()
	
	if generate_end_caps:
		generate_and_place_wall_end_caps()
	
	
func generate_all_wall_segments():
	for x in range(total_wall_segments):
		var new_wall_segment : Node3D = generate_random_wall_segment()
		place_wall_segment(new_wall_segment, x)
		add_child(new_wall_segment)
	
	
func generate_primary_wall_segment_weight():
	var total_secondary_wall_segment_weight = 0
	for x in secondary_wall_segment_weights:
		total_secondary_wall_segment_weight += x
	assert(total_secondary_wall_segment_weight < 1)
	primary_wall_segment_weight = 1 - total_secondary_wall_segment_weight
	
	
func generate_random_wall_segment():
	var random_value = randf_range(0, 1.0)
	var current_probability_value = 0.0
	
	for idx in range(len(secondary_wall_segments)):
		current_probability_value += secondary_wall_segment_weights[idx]
		if random_value < current_probability_value:
			return secondary_wall_segments[idx].instantiate()
	return primary_wall_segment.instantiate()
	
	
func generate_and_place_wall_end_caps():
	var maximum_left_extent = 0.0 - calculate_half_length()
	var maximum_right_extent = calculate_half_length()
	var end_cap_height = wall_tile_height_in_meters/2.0
	
	var left_wall_end_cap : Node3D = wall_end_cap.instantiate()
	left_wall_end_cap.position.x = maximum_left_extent
	left_wall_end_cap.position.y = end_cap_height
	add_child(left_wall_end_cap)
	
	var right_wall_end_cap : Node3D = wall_end_cap.instantiate()
	right_wall_end_cap.position.x = maximum_right_extent
	right_wall_end_cap.position.y = end_cap_height
	add_child(right_wall_end_cap)
	

# We use the x length of our mesh here because we originally tried to use scaling
# to make this work, but scaling meshed up StaticBody3Ds and collisionShapes.
# Changing the mesh directly works though, so its a convenient way to determine the
# total length of the modular wall
func get_wall_length():
	return editor_mesh.size.x
	
	
# How many wall segments we should have in our modular wall. Calculated by
# dividing our scale in the x-axis by the wall_tile_size_in_meters
func generate_total_wall_segments_value():
	total_wall_segments = get_wall_length()/wall_tile_size_in_meters
	
	
func calculate_half_length():
	return get_wall_length()/2.0
	
	
# Where our first wall segment is placed. We will determine the location of all
# other wall segments from this position. Calculated by determine the maximum
# extent of the modular wall in the negative x direction, then taking away half
# of the length of a wall tile from that value to determine the middle point of
# the first segment
func calculate_first_wall_segment_position():
	var maximum_negative_x_extent = 0.0 - calculate_half_length()
	var half_wall_tile_size = wall_tile_size_in_meters/2.0
	return maximum_negative_x_extent + half_wall_tile_size
	

# Placing the wall segment indicated by wall_segment_number (0 is the first segment,
# 1 is the second segment, etc.) based on the position of the first wall segment
# We do this by calculating the exact position of the first wall segment, and then adding
# wall segment tile lengths to the position based on which number wall_segment we are
# placing 
func place_wall_segment(wall_segment : Node3D, wall_segment_number : int):
	var first_wall_segment_position = calculate_first_wall_segment_position()
	var shift_value = wall_segment_number * wall_tile_size_in_meters
	var final_x_position = first_wall_segment_position + shift_value
	
	wall_segment.position.x = final_x_position
	# Putting the wall_segment on the ground by lifting it up by tile size:
	wall_segment.position.y = wall_tile_height_in_meters/2.0
	
	if debug:
		DebugMaster.log_debug("Segment Number:" + str(wall_segment_number) + "Shift Value " + str(shift_value))
		DebugMaster.log_debug("x Position: " + str(final_x_position) + "Y Position" + str( wall_tile_height_in_meters/2.0))
	
	
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
	
