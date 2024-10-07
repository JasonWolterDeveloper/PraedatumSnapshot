class_name Projectile extends CharacterBody3D

const THROW_TIME = 1.0

var thrown : bool = false
var thrower = false
var actually_thrown : bool = false
@export var projectile_gravity : float = 20
var real_projectile_velocity : Vector3 = Vector3(0, 0, 0)

var actual_throw_time = 0.0

var desired_throw_time:float = 0.0
var desired_throw_point:Vector3 = Vector3(0, 0, 0)

var bounced = false

var bounce_damping = 0.7

@export var maximum_throw_distance = 20

@onready var level = get_parent() # TODO: TEMPORARY USE OF GET_LEVEL
@onready var player = level.get_node("Player") # TODO: Temporary use of PLAYER


# Given the amount of time we want the throw to take, what our height is when we
# Initially start, our height when we land, and gravity, calculate our initial
# Y velocity
func calculate_required_initial_vertical_velocity(time:float, init_height:float, land_height:float, gravity:float):
	return (land_height - init_height + 0.5*(gravity * time * time))/time


# Given a starting position and an ending position, both Vector3's with an x and z component, but
# no y component, as well as a throw time, 	returns the initial horizontal velocity as a Vector3
# with an x and z component, but no y component, that the item needs to make it to the location
func calculate_required_initial_horizontal_velocity(start_pos:Vector3, end_pos:Vector3, time:float):
	var direction_vector = start_pos.direction_to(end_pos)
	var distance = start_pos.distance_to(end_pos)
	
	return direction_vector * (distance/time)
	
	
func calculate_remaining_throw_time(current_velocity:Vector3, current_height:float, final_height:float, gravity:float):
	var y_velocity = current_velocity.y
	# This is the quadratic equation I am losing my mind
	var time = (y_velocity + sqrt(pow(y_velocity, 2.0) - 4*(0.5*gravity)*(final_height-current_height)))/gravity
	# DebugMaster.log_debug("Time Remainig: " + str(time))
	return max(time, 0)
	
	
func recalculate_horizontal_velocity(current_position:Vector3, desired_position:Vector3, time:float):
	var current_position_2d = Vector3(current_position.x, 0, current_position.z)
	var desired_position_2d = Vector3(desired_position.x, 0, desired_position.z)
	return calculate_required_initial_horizontal_velocity(current_position_2d, desired_position_2d, time)
	
	
func throw(start_pos : Vector3, end_pos : Vector3):
	global_position = start_pos
	var current_height = global_position.y
	var final_height = 0.05
	var time = THROW_TIME
	desired_throw_time = time
	
	var start_horizontal_pos = Vector3(start_pos.x, 0, start_pos.z)
	var end_horizontal_pos = Vector3(end_pos.x, 0, end_pos.z)
	if start_horizontal_pos.distance_to(end_horizontal_pos) > maximum_throw_distance:
		end_horizontal_pos = start_horizontal_pos + start_horizontal_pos.direction_to(end_horizontal_pos) * maximum_throw_distance
	desired_throw_point = Vector3(end_horizontal_pos.x, final_height, end_horizontal_pos.z)
	
	var projectile_horizontal_velocity = calculate_required_initial_horizontal_velocity(start_horizontal_pos, end_horizontal_pos, time)
	real_projectile_velocity.x = projectile_horizontal_velocity.x
	real_projectile_velocity.z = projectile_horizontal_velocity.z
	real_projectile_velocity.y = calculate_required_initial_vertical_velocity(time, current_height, final_height, projectile_gravity)
	thrown = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("debug_1"):
		actually_thrown = true
		throw(player.global_position, level.game_world_mouse_position)


func _physics_process(delta) :
	if thrown and actually_thrown:
		simulate_throw_frame(delta)


func simulate_throw_frame(delta):
	actual_throw_time = actual_throw_time + delta
	var frame_velocity = real_projectile_velocity * delta
	var collision = move_and_collide(frame_velocity)
	
	if collision:
		if collision.get_collider().name == "Ground":
			actual_throw_time = 0.0
			real_projectile_velocity = Vector3(0, 0, 0)
			thrown = false
		else:
			var reflect = real_projectile_velocity.bounce(collision.get_normal())
			bounced = true
			real_projectile_velocity = reflect.normalized() * real_projectile_velocity.length() * (1.0 - bounce_damping)
	else:
		### Applying Gravity
		var new_vertical_velocity = real_projectile_velocity.y - (projectile_gravity * delta)
		real_projectile_velocity.y = new_vertical_velocity
		
		if not bounced:
			### Adjusting Horizontal Velocity to make up for Floating Point Precision Error
			var remaining_time = calculate_remaining_throw_time(real_projectile_velocity, global_position.y, desired_throw_point.y, projectile_gravity)
			var new_horizontal_velocity = recalculate_horizontal_velocity(global_position, desired_throw_point, remaining_time)
			
			real_projectile_velocity.x = new_horizontal_velocity.x
			real_projectile_velocity.z = new_horizontal_velocity.z


"""
extends RigidBody2D

class_name GrenadeProjectile

var fuze : Timer
var thrower : Character = null

var velocity : Vector2 = Vector2(0, 0)

var projectile_path = []
var traveling_along_path = false

var current_path_index = 0

var current_path_point : Vector2:
	get: return projectile_path[current_path_index]
var next_path_point : Vector2:
	get: return projectile_path[current_path_index + 1]
var at_last_path_point:
	get: return ((current_path_index + 1) >= len(projectile_path))
	
@export var explosion_scene : PackedScene
@export var fuze_time = 5.0
"""
""" Variables for slowing down the Projectile, "faking" physics
@export var time_to_slow_down = 0.5

var slowdown_started = false
var slowdown_rate = 0.0
"""
"""
func _ready():
	z_index = GraphicsConstants.THROWN_OBJECT_IN_AIR_INDEX

func throw_projectile(new_projectile_path, inital_velocity):
	assert(len(new_projectile_path) > 1)
	z_index = GraphicsConstants.THROWN_OBJECT_IN_AIR_INDEX
	
	projectile_path = new_projectile_path
	current_path_index = 0
	global_position = current_path_point
	angular_velocity = 10
	
	velocity = global_position.direction_to(next_path_point) * inital_velocity
	traveling_along_path = true
	
	start_fuze()
	
func start_fuze():
	fuze = Timer.new()
	fuze.timeout.connect(explode) 
	add_child(fuze) 
	fuze.wait_time = fuze_time
	fuze.start() 
	
func hit_ground():
	velocity = Vector2(0, 0)
	angular_velocity = 0
	traveling_along_path = false
	z_index = GraphicsConstants.THROWN_OBJECT_ON_GROUND_INDEX
	
func explode():
	var new_explosion = explosion_scene.instantiate()
	new_explosion.explosion_creator = thrower
	Util.force_add_child(Util.get_level(self), new_explosion)
	new_explosion.global_position = global_position
	queue_free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if traveling_along_path:
		var collision_info = move_and_collide(velocity * delta)
		
		if global_position.distance_to(next_path_point) < (velocity.length() * delta):
			global_position = next_path_point
			current_path_index += 1
			
			if at_last_path_point:
				hit_ground()
			else:
				velocity = global_position.direction_to(next_path_point) * velocity.length()
"""
