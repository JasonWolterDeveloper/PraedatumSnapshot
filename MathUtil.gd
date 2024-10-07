extends Node

const cw45 = PI/4
const cw90 = PI/2
const cw180 = PI

const ccw45 = -PI/4
const ccw90 = -PI/2
const ccw180 = -PI

const percentDivisor = 100.0


func roundUp(my_number):
	return int(ceil(my_number))


func roundDown(my_number):
	return int(floor(my_number))


func is_even(my_number):
	return (my_number % 2 == 0)


func is_odd(my_number):
	return not is_even(my_number)


func get_rect_top_left_from_center(rect_center, rect_size):
	return Vector2(rect_center.x - rect_size.x/2, rect_center.y - rect_size.y/2)


## Sums numeric array elements only
func array_sum(the_array:Array, first:int = 0, last:int = the_array.size()-1):
	var result = 0
	
	for i in range(first, last + 1):
		if the_array[i] is int or the_array[i] is float:
			result += the_array[i] 
			
	return result


func normalize_angle(angle):
	var two_pi = 2.0 * PI
	while angle < 0.0:
		angle += two_pi
	while angle >= two_pi:
		angle -= two_pi
	return angle


## generate_point_at_LOS_height takes a global Vector3 and sets its y component,
## its height, to the height of our LOS
func generate_point_at_LOS_height(point : Vector3):
	return Vector3(point.x, PhysicsConstants.LOS_HEIGHT, point.z)


# Function to add a collision layer bit to a node
func add_collision_layer_bit(node, layer_number: int) -> void:
	var bit : int = layer_number - 1
	# Check if the bit is within the valid range (0-31)
	if bit < 0 or bit > 31:
		push_error("Bit must be between 0 and 31.")
		return
	
	var shifted_bit = 1 << bit
	DebugMaster.log_debug("This is my Shifted Bit: " + str(shifted_bit))

	# Add the bit to the collision layer
	node.collision_layer |= shifted_bit
	
	DebugMaster.log_debug("This is my Collision Layer: " + str(node.collision_layer))


# Function to add a collision mask bit to a node
func add_collision_mask_bit(node, layer_number: int) -> void:
	var bit : int = layer_number - 1
	# Check if the bit is within the valid range (0-31)
	if bit < 0 or bit > 31:
		push_error("Bit must be between 0 and 31.")
		return
	
	var shifted_bit = 1 << bit

	# Add the bit to the collision mask
	node.collision_mask |= shifted_bit


# Function to remove a collision layer bit from a node
func remove_collision_layer_bit(node, layer_number: int) -> void:
	var bit : int = layer_number - 1
	# Check if the bit is within the valid range (0-31)
	if bit < 0 or bit > 31:
		push_error("Bit must be between 0 and 31.")
		return
	
	var shifted_bit = 1 << bit

	# remove the bit from the collision layer
	node.collision_layer &= ~(shifted_bit)


# Function to remove a collision mask bit from a node
func remove_collision_mask_bit(node, layer_number: int) -> void:
	var bit : int = layer_number - 1
	# Check if the bit is within the valid range (0-31)
	if bit < 0 or bit > 31:
		push_error("Bit must be between 0 and 31.")
		return
	
	var shifted_bit = 1 << bit

	# remove the bit from the collision mask
	node.collision_mask &= ~(shifted_bit)


func distance_to_no_y_component(point1 : Vector3, point2 : Vector3) -> float:
	var point1_no_y = Vector3(point1.x, 0, point1.z)
	var point2_no_y = Vector3(point2.x, 0, point2.z)
	return point1_no_y.distance_to(point2_no_y)
