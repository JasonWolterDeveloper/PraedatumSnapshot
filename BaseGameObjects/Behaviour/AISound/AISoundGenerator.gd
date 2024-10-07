class_name AISoundGenerator extends Area3D

var first_sound_path_point : Vector3 = Vector3(0, 0, 0)


func make_ai_sound(sound_range : float):
	for body in get_overlapping_bodies():
		if body is Enemy:
			if check_enemy_heard_sound(sound_range, body):
				notify_enemy_heard_sound(body)



# ---------- Handle Enemy Heard Sound ---------- #


func notify_enemy_heard_sound(enemy : Enemy):
	enemy.notify_heard_sound(global_position)



# ---------- Enemy Heard Sound Check Functions ---------- #



func check_enemy_heard_sound(sound_range : float, enemy : Enemy):
	if enemy_heard_sound_coarse_check(sound_range, enemy):
		return enemy_heard_sound_fine_check(sound_range, enemy)
	return false


## Check if the enemy is within range of the sound without regard for obstacles
func enemy_heard_sound_coarse_check(sound_range : float, enemy: Enemy) -> bool:
	return global_position.distance_to(enemy.global_position) < sound_range


func enemy_heard_sound_fine_check(sound_range : float, enemy : Enemy) -> bool:
	generate_enemy_path_to_sound(enemy)
	return check_path_length_against_sound_range(sound_range, enemy)
	var path = enemy.generate_path(global_position)
	var path_length : float = path.calculate_length()
	var path_final_point : Vector3 = path.get_final_point()
	var distance_from_path_end_to_sound : float = global_position.distance_to(path_final_point)
	
	var total_distance : float = path_length + distance_from_path_end_to_sound
	return total_distance < sound_range



# ---------- Enemy Sound Pathfinding Functions ---------- #


func generate_enemy_path_to_sound(enemy : Enemy):
	var pathfinding_master : PathfindingMaster = enemy.pathfinding_master
	var sound_nav_agent : NavigationAgent3D = pathfinding_master.sound_nav_agent
	
	sound_nav_agent.target_position = global_position
	
	# Calling this to update pathfinding
	first_sound_path_point = sound_nav_agent.get_next_path_position()


func check_path_length_against_sound_range(sound_range : float, enemy : Enemy):
	var pathfinding_master : PathfindingMaster = enemy.pathfinding_master
	var sound_nav_agent : NavigationAgent3D = pathfinding_master.sound_nav_agent
	
	if not sound_nav_agent.is_target_reachable():
		return false
	
	var total_distance : float = 0.0
	var path : PackedVector3Array = sound_nav_agent.get_current_navigation_path()
	var current_point = first_sound_path_point
	
	for path_point in path:
		total_distance += current_point.distance_to(path_point)
		
		if total_distance >= sound_range:
			return false
		
		current_point = path_point
	
	total_distance += current_point.distance_to(sound_nav_agent.target_position)
	
	if total_distance >= sound_range:
		return false
	
	return true



# --------- Testing Material ---------- #


func test_emit_sound_1():
	make_ai_sound(10.0)


func test_emit_sound_2():
	make_ai_sound(100.0)


func test_emit_sound_3():
	make_ai_sound(5.0)

"""
func _process(delta):
	if Input.is_action_just_pressed("debug_1"):
		test_emit_sound_1()
	if Input.is_action_just_pressed("debug_2"):
		test_emit_sound_2()
	if Input.is_action_just_pressed("debug_3"):
		test_emit_sound_3()
"""
