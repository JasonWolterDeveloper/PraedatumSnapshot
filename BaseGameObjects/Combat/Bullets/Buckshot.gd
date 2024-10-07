class_name Buckshot extends Bullet

const PELLET_ROTATION_AXIS = Vector3(0, 1, 0)

@export var pellet_scene : PackedScene

@export var number_of_pellets = 5

@export var spread = 0.005


func fire_bullet(new_real_start_pos : Vector3, new_visual_start_pos: Vector3, trajectory, gun:Gun=null, character:Character=null):
	origin_gun = gun
	origin_character = character
	
	real_start_pos = new_real_start_pos
	visual_start_pos = new_visual_start_pos
	global_position = real_start_pos
	
	for x in range(number_of_pellets):
		spawn_pellet(new_real_start_pos, new_visual_start_pos, trajectory)
	
	fired = true


func generate_new_trajectory_with_spread(new_start_pos, trajectory):
	var random_spread = randf_range(-spread, spread)
	var new_trajectory = trajectory.rotated(PELLET_ROTATION_AXIS, random_spread)
	return new_trajectory
	
	
func spawn_pellet(new_start_pos, new_visual_start_pos, trajectory):
	if pellet_scene:
		var new_pellet : Bullet = pellet_scene.instantiate()
		Util.get_level(self).add_child(new_pellet)
		var random_trajectory = generate_new_trajectory_with_spread(new_start_pos, trajectory)
		new_pellet.fire_bullet(new_start_pos, new_visual_start_pos, random_trajectory, origin_gun, origin_character)
