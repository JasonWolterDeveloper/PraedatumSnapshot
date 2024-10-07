class_name TurretTargetDetectedLink extends Link

var potential_target_list : Array[Character] = []


func is_triggered() -> bool:
	var potential_target:Player = check_line_of_sight_to_potential_targets()
	var saw_our_target:bool = false
	
	if potential_target:
		saw_our_target = potential_target == target_character
		my_character.ai_memory.can_see_target = saw_our_target
	return saw_our_target


func check_line_of_sight_to_potential_targets():
	for potential_target in potential_target_list:
		if my_character.check_los_to_character(potential_target, 0x3):
			return potential_target
	return null


func _on_detection_range_body_entered(body):
	if body is Player:
		potential_target_list.append(body)


func _on_detection_range_body_exited(body):
	Util.delete_object_from_array(potential_target_list, body)
