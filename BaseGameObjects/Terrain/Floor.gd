class_name Floor extends StaticBody3D

const FLOOR_COLLISION_TILE_HEIGHT = 5

@export var floor_collision_tile_size_width : float = 10.0
@export var floor_collision_tile_size_length : float = 10.0

var floor_width_in_tiles : int
var floor_length_in_tiles : int

var left_over_width : float
var left_over_length : float

var total_width : float
var total_height : float


func _ready():
	calculate_floor_width_plus_leftover()
	calculate_floor_length_plus_leftover()
	reset_scale()
	build_and_position_all_tiles()


func calculate_floor_width_plus_leftover():
	total_width = scale.x
	floor_width_in_tiles = floor(total_width/floor_collision_tile_size_width)
	
	# Calculating how much won't get covered by standard sized tiles
	var total_tile_width = floor_collision_tile_size_width * floor_width_in_tiles
	left_over_width = total_width - total_tile_width
	
	if left_over_width != 0:
		floor_width_in_tiles += 1


func calculate_floor_length_plus_leftover():
	total_height = scale.z
	floor_length_in_tiles = floor(total_height/floor_collision_tile_size_length)
	
	# Calculating how much won't get covered by standard sized tiles
	var total_tile_length = floor_collision_tile_size_length * floor_length_in_tiles
	left_over_length = total_height - total_tile_length
	
	if left_over_length != 0:
		floor_length_in_tiles += 1


func build_and_position_all_tiles():
	for x in range(floor_width_in_tiles):
		for z in range(floor_length_in_tiles):
			var my_tile = build_tile(x, z)
			position_tile(my_tile, x, z)
			add_child(my_tile)


func position_tile(tile : CollisionShape3D, width_position : int, length_position : int):
	var tile_width = calculate_width_for_position(width_position)
	var tile_length = calculate_length_for_position(length_position)
	
	var x_position : float = tile_width/2.0 + (width_position * floor_collision_tile_size_width) - (total_width/2.0)
	var z_position : float = tile_length/2.0 + (length_position * floor_collision_tile_size_length) - (total_height/2.0)
	
	tile.position.x = x_position
	tile.position.z = z_position
	tile.position.y = -(FLOOR_COLLISION_TILE_HEIGHT/2.0)
	
	
func calculate_width_for_position(width_position):
	if width_position + 1 == floor_width_in_tiles && left_over_width != 0: # Adding 1 here for zero indexed
		return left_over_width
	return floor_collision_tile_size_width
	
	
func calculate_length_for_position(length_position):
	if length_position + 1 == floor_length_in_tiles && left_over_length != 0: # Adding 1 here for zero indexed
		return left_over_length
	return floor_collision_tile_size_length


func build_tile(width_position, length_position):
	var tile = create_new_collision_box()
	
	tile.shape.size.y = FLOOR_COLLISION_TILE_HEIGHT
	tile.shape.size.x = calculate_width_for_position(width_position)
	tile.shape.size.z = calculate_length_for_position(length_position)
		
	return tile


func create_new_collision_box():
	var new_collision_shape = CollisionShape3D.new()
	new_collision_shape.shape = BoxShape3D.new()
	return new_collision_shape


# we reset our scale by applying our scale to all of our children except our
# collision shape, then setting our scale to 1. This way we will avoid impacting
# our collision shape
func reset_scale():
	var my_scale = Vector3(scale)
	scale = Vector3(1, 1, 1)
	for my_child in get_children():
		if not my_child is CollisionShape3D:
			my_child.scale = my_scale
