class_name EjectionPort extends Marker3D

## Instatiate this class as a child node of a weapon model scene. 

@export var casing_scene:PackedScene ## Scene of the spent casing to be ejected from the gun
## Offset in radians (y-axis) applied to align the casing parallel with the gun. 
## Varies depending on casing model orientation
@export var casing_rotation_offset:float
@export var initial_linear_velocity:Vector3 = Vector3(12, 0, 6) ## m/s
@export var initial_angular_velocity:Vector3 = Vector3(0, -4*PI, 0) ## 3D rotation in rad/s
@export var linear_velocity_variance:Vector3 = Vector3(0, 0, 0.5) ## +/- randomness as a proportion of initial_linear_velocity
@export var angular_velocity_variance:Vector3 = Vector3(0, 0.5, 0) ## +/- randomness as a proportion of initial_angular_velocity

@onready var linear_velocity := initial_linear_velocity
@onready var angular_velocity := initial_angular_velocity


## Instantiates a new casing and launches it a semi-randomized velocity and spin.  
func spawn_casing() -> void:
	var new_linear_velocity:Vector3
	var new_angular_velocity:Vector3
	var new_casing:SpentRound
	var new_y_rotation:float
	
	assert(casing_scene)
	if casing_scene:
		new_casing = casing_scene.instantiate()
		Util.get_level(self).add_child(new_casing)

		new_y_rotation = global_rotation.y + casing_rotation_offset
		new_linear_velocity = randomize_vector(initial_linear_velocity, linear_velocity_variance)
		new_linear_velocity = new_linear_velocity.rotated(Vector3.UP, new_y_rotation)
		new_angular_velocity = randomize_vector(initial_angular_velocity, angular_velocity_variance)
		
		new_casing.global_position = global_position
		new_casing.global_rotation = Vector3(0, new_y_rotation, 0)
		new_casing.set_linear_velocity(new_linear_velocity)
		new_casing.set_angular_velocity(new_angular_velocity)


## Adds/subtracts a random proportion (up to a specified limit) of a vector to/from itself
func randomize_vector(reference_vector:Vector3, variance:Vector3 = Vector3.ZERO) -> Vector3:
	var result := Vector3()
	
	for i in 3:
		result[i] = reference_vector[i] * (1 + randf_range(-variance[i], variance[i]))
	
	return result
