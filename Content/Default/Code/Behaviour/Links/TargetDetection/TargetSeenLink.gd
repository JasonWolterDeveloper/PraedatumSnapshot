class_name TargetSeenLink extends Link

## For "advanced" vision checking using a rough check followed by a fine check. 

var potential_target_list : Array[Character] = []

@export var uses_vision_cone = true
## This will be equal to half the size of the angle of the vision cone
@export var vision_cone_angle = PI/2

@export var detection_range : float = 12
@onready var collision_shape : CollisionShape3D = $DetectionRange/CollisionShape3D
@onready var detection_range_area : Area3D = $DetectionRange

# Default collision mask layers should be layer 1 and 2. 1 + 2 = 3
@export var collision_mask_for_raycast = 3


func _ready():
	super()
	collision_shape.shape.radius = detection_range


## Did we pass the coarse & fine checks for seeing target_character?
func is_triggered() -> bool:
	var potential_target:Player = check_los_to_potential_targets()
	var saw_our_target:bool = false
	
	if potential_target:
		saw_our_target = potential_target == target_character
		my_character.ai_memory.can_see_target = saw_our_target
	return saw_our_target


func check_los_to_potential_targets() -> Player:
	for potential_target in potential_target_list:
		if uses_vision_cone and not my_character.aiming_master.point_in_given_vision_cone_angle(potential_target.global_position, vision_cone_angle):
			break
		if my_character.check_los_to_character(potential_target, collision_mask_for_raycast):
			return potential_target
	return null


func _on_detection_range_body_entered(body):
	if body is Player:
		potential_target_list.append(body)


func _on_detection_range_body_exited(body):
	Util.delete_object_from_array(potential_target_list, body)
