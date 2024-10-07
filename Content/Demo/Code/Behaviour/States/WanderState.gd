class_name WanderState extends State


# Variables
# wander_center moved to AI Memory
# var wander_center: Vector3
var wander_target: Vector3
@export var wander_max_distance_from_center: float = 3.0
@export var wander_max_length: float = 3.0
@export var wander_min_length: float = 1.0
@export var min_time_between_wanders: float = 2.0
@export var max_time_between_wanders: float = 8.0

# how far we should stay from collisions
@export var collision_avoidance_radius = 1.0
#@onready var collision_avoidance_raycast = $CollisionAvoidanceRaycast

var time_since_last_wander: float
# mandatory_re_wander_time forces an AI to wander again even if it hasn't reached
# it's destination if the timer gets this low
var mandatory_re_wander_time = -10.0

var left_wander_range = false


# Constants
const TOLERANCE: float = 0.1


func _ready():
	time_since_last_wander = randf_range(min_time_between_wanders, max_time_between_wanders)
	mandatory_re_wander_time = mandatory_re_wander_time - max_time_between_wanders


func on_entry(delta: float) -> bool:
	super(delta)
	# Resetting the wander center on enter causes bad behaviour
	# wander_center = my_character.global_position
	return true # One-shot routine


func on_active(delta: float):
	super(delta)
	
	if not "sentry" in my_character or not my_character.sentry:
		if not wander_target:
			start_wander()

		time_since_last_wander -= delta
			
		if MathUtil.distance_to_no_y_component(my_character.global_position, wander_target) <= TOLERANCE:
			if time_since_last_wander <= 0:
				start_wander()

		if MathUtil.distance_to_no_y_component(my_character.global_position, wander_target) > TOLERANCE:
			my_character.movement_master.move_to_point(wander_target)
		
		if time_since_last_wander <= mandatory_re_wander_time:
			start_wander()

	return false


func start_wander():
	time_since_last_wander = randf_range(min_time_between_wanders, max_time_between_wanders)
	wander_target = generate_wander_position()


func generate_wander_position():
	var wander_point : Vector3
	wander_point = generate_random_wander_position_circle_only()
	return wander_point
	
	# TODO - This code didn't work so I switched to just moving to random points within a circle
	# Simple do not place an AI too close to a wall or obstacle if it is wandering
	"""
	# If we left the wander range during a previous wander, we want to wander back on
	# towards the center of our wander circle
	if left_wander_range:
		var wander_direction = my_character.global_position.direction_to(get_wander_center())
		var wander_length = wander_max_length
		var wander_vector = wander_direction * wander_length
		wander_point = my_character.global_position + wander_vector
	else:
		wander_point = generate_random_wander_position()
		
	# detect if we would run into terrain to hit the wander position and... don't do that
	wander_point = avoid_collisions_for_wander_point(wander_point)

	return wander_point
	"""


## generate_random_wander_position_circle_only() returns a random point within the wander circle
## At a minimum length of wander min length and a maximum distance of max length. This is very
## simple, but seems to produce realistic enough behaviour if you are generous with where you place
## wandering enemies in the level
func generate_random_wander_position_circle_only():
	var random_direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	var random_length = randf_range(wander_min_length, wander_max_length)
	var random_wander_vector = random_direction * random_length
	var wander_position = get_wander_center() + random_wander_vector
	
	return wander_position


func get_wander_center():
	return my_character.ai_memory.wander_center


"""

# NOTE - This function is generating points that are massively further away from the wander point
# Resulting in very odd behaviour
func avoid_collisions_for_wander_point(wander_point: Vector3):
	#collision_avoidance_raycast.global_position = my_character.global_position
	var direction_to_wander_point = my_character.global_position.direction_to(wander_point)
	var length_to_wander_point = my_character.global_position.distance_to(wander_point)
	var wander_point_with_collision_avoidance_radius = direction_to_wander_point*(length_to_wander_point + collision_avoidance_radius)
	var collision_point:Vector3 = Util.los_collision_point_raycast(my_character.global_position, wander_point_with_collision_avoidance_radius, 0x5, [my_character])
	#collision_avoidance_raycast.target_position = wander_point_with_collision_avoidance_radius
	#collision_avoidance_raycast.force_raycast_update()
	
	#if collision_avoidance_raycast.get_collider():
		#var collision_position = collision_avoidance_raycast.get_collision_point()
	if collision_point != wander_point_with_collision_avoidance_radius:
		var distance_to_collision_point = my_character.global_position.distance_to(collision_point)
		var new_length_to_wander_point = distance_to_collision_point - collision_avoidance_radius
		var new_wander_point = my_character.global_position + (direction_to_wander_point * new_length_to_wander_point)
		return new_wander_point
		
	return wander_point

#NOTE - This function will occasionally result in generating a point that our AI never actually
# Reaches, resulting in the wanderers no longer moving
func generate_random_wander_position():
	var random_direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	var random_length = randf_range(wander_min_length, wander_max_length)
	var random_wander_vector = random_direction * random_length
	var wander_position = my_character.global_position + random_wander_vector
	
	var distance_from_wander_position_to_center = wander_position.distance_to(get_wander_center())
	if distance_from_wander_position_to_center > wander_max_distance_from_center:
		# Moving the new wander point back towards the center if need be
		var direction = wander_position.direction_to(get_wander_center())
		var length = distance_from_wander_position_to_center - wander_max_distance_from_center
		var vector_back_to_center = direction * length
		wander_position = get_wander_center() + vector_back_to_center
		left_wander_range = true

	return wander_position

"""
