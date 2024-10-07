class_name MovementMaster extends Node3D

## MovementMaster is a component that facilitates character movement (translation & rotation).

@export var can_move : bool = true
var max_speed : float:
	get: return my_character.rpg_mechanics_master.movement_speed.value


var stunned : bool:
	get: return my_character.rpg_mechanics_master.is_stunned()


## Walking is set by other objects and is used by the player exclusively to indicate
## we should be walking and not running. It is checked, each frame, used to set the speed_limit.
var walking : bool = false
const WALKING_SPEED_MODIFIER = 0.5

# Cardinal Direction based Movement Used for player controls
var left_movement = 0
var right_movement = 0
var up_movement = 0
var down_movement = 0

var direction = Vector3()
var gravity_vec = Vector3.DOWN
var movement = Vector3()

const ACCELERATION_DEFAULT = 10
@export var acceleration = ACCELERATION_DEFAULT
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var my_character:Character
var player : Player 
@export var should_move_outside_of_player_range : bool = false
const MOVEMENT_RANGE_TO_PLAYER = 100.0


@export var should_use_directional_movement = false

# Desired position is used if we are moving positionally rather than directionally
var desired_position

# Sets a limit on our max speed. If our speed_limit is higher than our max speed
# this does nothing 
var has_speed_limit : bool = false
var speed_limit : float  = 1.0


func _physics_process(delta):
	if should_use_directional_movement:
		handle_walking()
		handle_directional_movement()
	
		# make it move
		my_character.velocity = my_character.velocity.lerp(direction * get_desired_possible_move_speed(), acceleration * delta)
		my_character.velocity.y = 0
		
	else:
		handle_positional_movement(delta)


	if check_can_move():
		my_character.velocity = my_character.velocity + gravity_vec * gravity
		my_character.move_and_slide()


func get_desired_possible_move_speed():
	if has_speed_limit:
		return min(max_speed, speed_limit)
	else:
		return max_speed
	

func clear_speed_limit():
	has_speed_limit = false
	speed_limit = max_speed
	
	
func set_speed_limit(new_speed_limit : float):
	has_speed_limit = true
	speed_limit = new_speed_limit


func check_can_move():
	if my_character is Enemy:
		if my_character.ai_disabled:
			return false
	if not player:
		player = GameMaster.get_player()
	else:
		if not should_move_outside_of_player_range and my_character.global_position.distance_to(player.global_position) > MOVEMENT_RANGE_TO_PLAYER:
			return false
	return can_move and not stunned


# ----------------------------------------------------- PUBLIC METHODS


# Move in a provided (unit vector) direction
func move_in_direction(direction:Vector3):
	my_character.velocity = direction.normalized() * get_desired_possible_move_speed()


# Move towards a point. If we are close enough to move to the point in one
# frame, or directly on the point, we stop
func move_to_point(destination : Vector3):
	desired_position = destination


# Move along a provided vector, overriding max_speed
func move_along(new_velocity:Vector3):
	my_character.velocity = new_velocity
	
	
func reset_directional_movement():
	right_movement = 0
	left_movement = 0
	up_movement = 0
	down_movement = 0
	
	
func move_left():
	left_movement = 1
	
	
func move_right():
	right_movement = 1
	
	
func move_up():
	up_movement = 1
	
	
func move_down():
	down_movement = 1
	
	
func is_moving():
	return direction.length() > 0


# ----------------------------------------------------- PRIVATE METHODS

# Necessary setter for duck-typing
func set_my_character(new_character:Character):
	my_character = new_character


func handle_walking():
	if walking:
		set_speed_limit(max_speed * WALKING_SPEED_MODIFIER)
	else:
		clear_speed_limit()
	
	
func handle_directional_movement():
	direction = Vector3.ZERO
	var h_rot = global_transform.basis.get_euler().y
	var f_input = down_movement - up_movement
	var h_input = right_movement - left_movement
	direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	
	
func handle_positional_movement(delta):
	if desired_position != null:
		if my_character.global_position.distance_to(desired_position) < delta * get_desired_possible_move_speed():
			my_character.global_position = desired_position
			my_character.velocity = Vector3.ZERO
		else:
			move_in_direction(my_character.global_position.direction_to(desired_position))
		# Resetting Desired Position so that it needs to be set in every frame we want to move
		desired_position = null
	else:
		my_character.velocity = Vector3.ZERO
