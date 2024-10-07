class_name ProjectileTrajectoryPredictor extends Node3D

var trajectory_path_piece_scene : PackedScene = preload("res://BaseGameObjects/Combat/Projectiles/TrajectoryPathPiece.tscn")

@export var minimum_point_distance = 0.2


func simulate_throw(simulation_projectile : Projectile, start_pos : Vector3, end_pos : Vector3) -> Vector3:
	simulation_projectile.throw(start_pos, end_pos)
	
	var throw_resolution = 30
	var delta = simulation_projectile.THROW_TIME/throw_resolution
	clear_simulated_throw()
	
	var last_added_point : Vector3
	
	for x in range(0, throw_resolution+1):
		simulation_projectile.simulate_throw_frame(delta)
		if last_added_point == null or x == throw_resolution or last_added_point.distance_to(simulation_projectile.global_position) > minimum_point_distance:
			last_added_point = simulation_projectile.global_position

			var new_trajectory_path_piece : Node3D = trajectory_path_piece_scene.instantiate()
			$PathPieces.add_child(new_trajectory_path_piece)
			
			new_trajectory_path_piece.look_at(simulation_projectile.real_projectile_velocity)
			new_trajectory_path_piece.global_position = simulation_projectile.global_position

	return last_added_point


func clear_simulated_throw():
	for n in $PathPieces.get_children():
		$PathPieces.remove_child(n)
		n.queue_free()
