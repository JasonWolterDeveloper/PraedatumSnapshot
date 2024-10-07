class_name AimingMaster extends Node3D

# AimingManager is a class used to facilitate actors aiming/looking in all 
# manner of situations as well as to help determine the path of projectiles
# fired by the associated actor. Finally, the aiming manager can also help 
# display the crosshair in the hud

# A unit vector in the direction the aiming master is looking. I don't know why
# the negative z direction is the basic way that we look, but, it is what it is
const LOOK_DIRECTION = Vector3(0,0,-1)

var character : Character 

	
@export var should_look_in_movement_direction = false
	
@export var look_stuff : Node3D
	
var aim_point = Vector3(0, 0, 0)


# aimSpeed is the total amount of radians the user can turn in one second
@export var aim_speed = 8
## if aim_instant is true, we aim instantly
@export var aim_instant : bool = false
## Instantly snaps the look if you're close enough instead of lerping
@export var player_look_snap : bool


# Movement directions based on whether we should add or subtract to the angle to
# get the person to the desired angle
var ccw = -1.0
var cw = 1.0

const MIN_ROTATION = 0
const MAX_ROTATION = 2*PI


const MAX_SHOT_LENGTH = 10000


func _physics_process(delta):
	if should_look_in_movement_direction:
		look_in_movement_direction()
	if not character.rpg_mechanics_master.is_stunned():
		if not aim_instant:
			gradual_look(delta)
		else:
			instant_look()


func generate_random_point_in_spread_circle(spread : float):
	var min_distance_from_circle_center = 0
	var max_distance_from_circle_center = calculate_spread_circle_radius_for_spread(spread)
	
	var min_angle_from_circle_center = MIN_ROTATION
	var max_angle_from_circle_center = MAX_ROTATION
	
	var random_distance_from_spread_circle_center = randf_range(min_distance_from_circle_center, 
															max_distance_from_circle_center)
	var random_angle_from_circle_center = randf_range(min_angle_from_circle_center, 
													max_angle_from_circle_center)
													
	# Making a random vector with a length of our random distance and rotated
	# by our random angle
	var random_vector = Vector3(random_distance_from_spread_circle_center, 0, 0)
	random_vector = random_vector.rotated(Vector3.UP, random_angle_from_circle_center)
	
	return get_spread_circle_center() + random_vector


# Generates the overall trajectory of a shot given the current spread, accuracy
# and aim point. The trajectory is a vector in the direction of the shot at a
# distance of MAX_SHOT_LENGTH away from the target, to handle misses, etc.
func generate_shot_trajectory_with_spread(spread : float):
	var shot_point = generate_random_point_in_spread_circle(spread)
	
	# Currently based on the position of the aiming master node itself. May need
	# changing in the future
	var trajectory_direction_vector = global_position.direction_to(shot_point)
	var trajectory = trajectory_direction_vector * MAX_SHOT_LENGTH
	
	return trajectory


func get_spread_circle_center():
	return aim_point

	
func get_desired_look_angle():
	var aim_point_in_local_coordinate_system = character.to_local(aim_point)
	return atan2(-aim_point_in_local_coordinate_system.x, 
				 -aim_point_in_local_coordinate_system.z)


func instant_look():
	look_stuff.rotation.y = get_desired_look_angle()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func gradual_look(delta):
	# The total difference in Radians between our two desired facings
	var total_difference = get_difference_between_desired_and_current_look_angle()
	
	# Calculating the maximum amount we can turn this frame
	var max_turn_amount = aim_speed * delta
	
	if player_look_snap and max_turn_amount > total_difference:
		look_stuff.rotation.y = get_desired_look_angle()
	else:
		# Calculating the actual amount we want to turn. If totalDifference is
		# less than maxTurnAmount we only want to turn by that amount
		var turn_amount = min(max_turn_amount, total_difference)
	
		look_stuff.rotation.y = lerp_angle(look_stuff.rotation.y, get_desired_look_angle(), turn_amount)


#TODO - Sometimes this fucntion doesn't really work
func get_difference_between_desired_and_current_look_angle():
	var current_facing = look_stuff.rotation.y
	var desired_facing = get_desired_look_angle()
	
	# The total difference in Radians between our two desired facings
	return abs(current_facing - desired_facing)
	
	
# Looks in the direction of movement by setting the aim_point to a point in the
# direction where the character is moving
func look_in_movement_direction():
	# We only want to look where we are going if we are actually going somewhere
	if character.velocity:
		const LOOK_VECTOR_DIST:float = 10.0 # [m]
		
		var character_velocity_no_y_component = Vector3(character.velocity.x, 0, character.velocity.z)
		var local_movement_direction_point = character_velocity_no_y_component.normalized() * LOOK_VECTOR_DIST
		var global_movement_direction_point = character.global_position + local_movement_direction_point
		
		aim_point = global_movement_direction_point


func calculate_spread_circle_radius_for_spread(spread : float):
	var vector_to_spread_circle_center = get_spread_circle_center() - global_position

	# space magic
	return vector_to_spread_circle_center.length() * tan(spread/2)


# Takes a global point and a maximum angle of a vision cone and returns true
# if that point is within the given angle of the current look direction in local
# space. This only checks the angle, it does not check other circumstances like
# distance, or collisions. This function converts angles to 2D space to make the
# comparison
func point_in_given_vision_cone_angle(global_point : Vector3, angle : float):
	var local_coordinates = to_local(global_point)
	var target_point_2D = Vector2(local_coordinates.x, local_coordinates.z)
	var origin_point_2D = Vector2(LOOK_DIRECTION.x, LOOK_DIRECTION.z)
	
	var angle_to_target_point = (origin_point_2D.angle_to(target_point_2D))
	
	return abs(angle_to_target_point) <= abs(angle)


func look_direction_vector():
	return character.global_position.direction_to(aim_point)


## look_straight_forward sets our desired aim point to a point right in front of
## us so we stop looking around. This essentially "resets" the aiming master in a
## sense
func look_straight_forward():
	var new_aim_point = to_global(LOOK_DIRECTION)
	aim_point = new_aim_point


# Necessary setter for duck-typing
func set_my_character(new_character:Character):
	character = new_character


"""
# getShotPoint() returns a random point inside of the spread circle. This is 
# used to generate a random direction for our bullet
func getShotPoint():
	# To get a random point in the circle, the point should be between 0 and the
	# circle's radius in distance away from the center
	var minDistanceFromCircleCenter = 0
	var maxDistanceFromCircleCenter = getSpreadCircleRadius()
	
	# To get a random point in the circle, the vector from the center to to that
	# point should be between 0 and 2PI radians rotated from the center
	var minAngleFromCircleCenter = 0
	var maxAngleFromCircleCenter = 2*PI
	
	# Getting random values in our ranges
	var randomDistanceFromCircleCenter = rand_range(minDistanceFromCircleCenter, maxDistanceFromCircleCenter)
	var randomAngleFromCircleCenter = rand_range(minAngleFromCircleCenter, maxAngleFromCircleCenter)
	
	# Making a random vector with a length of our random distance and rotated
		# by our random angle
	var randomVector = Vector2(randomDistanceFromCircleCenter, 0)
	randomVector = randomVector.rotated(randomAngleFromCircleCenter)
	
	# Adding our random vector to our center to get the point
	return getSpreadCircleCenter() + randomVector
	
# returns the center of the spread circle. This will either be the actual aim
# position, or, if the position is too close, a new position that is the minimum
# distance away
func getSpreadCircleCenter():
	var aimVector = aimPoint - getActor().position
	
	# We get a unit vector of the aim vector so that we can ensure the spread
	# circle is at least a minimum distance away
	var unitAimVector = aimVector.normalized()
	
	# We first set the spread circle distance to the Min value of the aimVector
	# length and the weapon's max range. This is to make sure the spread circle
	# is never further away from the actor than the weapon's max range
	var spreadCircleDistance = min(aimVector.length(), getWeapon().getRange())
	
	# We then set the spreadCircleDistance to the maximum of its current value
	# and the minimumSpreadCircleDistance. This is because we don't want the
	# spread circle to be any closer than minimumSpreadCircleDistance
	spreadCircleDistance = max(spreadCircleDistance, minimumSpreadCircleDistance)
	
	# We set the length of the spread circle center vector to the calculated
	# spread circle distance
	var spreadCircleCenterVector = unitAimVector * spreadCircleDistance
	
	return getActor().position + spreadCircleCenterVector
	
func getSpreadCircleRadius():
	var vectorToSpreadCircleCenter = getSpreadCircleCenter() - getActor().position
	return vectorToSpreadCircleCenter.length() * tan(getSpread()/2)
	
# incrementMovementInaccuracy does all the work necessary to increment movement
# inaccuracy given the actor has moved for "delta" seconds. This function will
# fail if the actor does not have a weapon equipped
func incrementMovementInaccuracy(delta):
	var inaccuracyEvent = movementInaccuracyEventScene.instance()
	inaccuracyEvent.setupMovementInaccuracyEvent(getActor(), getWeapon(), delta)
	inaccuracyEvent.execute()

# decrementMovementInaccuracy does all the work necessary to recover from
# movement inaccuracy given the actor has moved for "delta" seconds. This 
# function will fail if the actor does not have a weapon equipped
func decrementMovementInaccuracy(delta):
	var recoveryEvent = movementInaccuracyRecoveryEventScene.instance()
	recoveryEvent.setupMovementInaccuracyRecoveryEvent(getActor(), getWeapon(), delta)
	recoveryEvent.execute()
	
# calculateMovementInaccuracy checks if the actor is currently moving and then
# adds the appropriate amount of movement accuracy if they are, and subtracts 
# the appropriate amount if they are not
func calculateMovementInaccuracy(delta):
	if getWeapon():
		if get_parent().getPhysicsManager().isMoving():
			incrementMovementInaccuracy(delta)
		else:
			decrementMovementInaccuracy(delta)
	else: # If we don't have a weapon we don't have any movement inaccuracy
		movementInaccuracy = 0.0
		
# applyRecoil is used by weapon objects to apply recoil to the actor when they
# fire a shot. This function adds the recoil to the total recoil inaccuracy, but
# makes sure total recoil accuracy doesn't exceed the maximum
func applyRecoil(amount):
	recoilInaccuracy = min(recoilInaccuracy + amount, getWeapon().getMaximumRecoilInaccuracy())

# recoverRecoilInaccuracy calculates how much recoil inaccuracy should recover
# over the amount of seconds given by delta. This should be called every frame
# as the actor should always be passively recovering from recoil
func recoverRecoilInaccuracy(delta):
	if getWeapon():
		var recoveryEvent = recoilRecoveryEventScene.instance()
		recoveryEvent.setupRecoilRecoveryEvent(getActor(), getWeapon(), delta)
		recoveryEvent.execute()
	else:
		# If we have no weapon, set our recoil inaccuracy to 0
		recoilInaccuracy = 0.0
		
# getMovementInaccuracy returns the amount of inaccuracy in the currently 
# equipped weapon that is caused by the character moving. Every weapon has a
# minimum movement inaccuracy and a maximum movement inaccuracy, the minimum
# being the inaccuracy when at a stand still.
func getMovementInaccuracy():
	return movementInaccuracy
	
func setMovementInaccuracy(value):
	movementInaccuracy = value
	
func setRecoilInaccuracy(value):
	recoilInaccuracy = value
	
func getRecoilInaccuracy():
	return recoilInaccuracy
	
func getSpread():
	if getWeapon():
		var accuracyEvent = accuracyEventScene.instance()
		accuracyEvent.setupAccuracyEvent(getActor(), getWeapon())
		return accuracyEvent.execute()
	else:
		# if we have no weapon our spread is 0
		return 0

func lookAtAimPoint(delta):
	gradualAim(delta)
	
# returns a unit vector in the direction that the actor is facing
func getFacingVector():
	return Vector2(1, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func gradualAim(delta):
	# The total difference in Radians between our two desired facings
	var totalDifference = getDifferenceBetweenCurrentAndDesiredFacing()
	
	# Handling the case where we turn clockwise
	if totalDifference > 0:
		# Calculating the maximum amount we can turn this frame
		var maxTurnAmount = aimSpeed * delta * cw
		
		# Calculating the actual amount we want to turn. If totalDifference is
		# less than maxTurnAmount we only want to turn by that amount
		var turnAmount = min(maxTurnAmount, totalDifference)
		
		getActor().rotation = getActor().rotation + turnAmount
		
	# Handling the CCW case
	elif totalDifference < 0:
				# Calculating the maximum amount we can turn this frame
		var maxTurnAmount = aimSpeed * delta * ccw
		
		# Calculating the actual amount we want to turn. If totalDifference is
		# less than maxTurnAmount we only want to turn by that amount. Note that
		# we use max here instead of min because we are dealing with negatives
		var turnAmount = max(maxTurnAmount, totalDifference)
		
		getActor().rotation = getActor().rotation + turnAmount
		
func getDifferenceBetweenCurrentAndDesiredFacing():
	var currentFacing = getFacingVector()
	var desiredFacing = getActor().to_local(getAimPoint())
	
	# The total difference in Radians between our two desired facings
	return currentFacing.angle_to(desiredFacing)

"""
