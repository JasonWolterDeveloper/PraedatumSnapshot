class_name ArcOfEffect extends AreaOfEffect

@export var arc_angle : float
var arc_direction : Vector3

@export var track_origin_character_direction : bool = false



# ---------- Assignment Functions ---------- #


# Direction should be global
func set_direction(new_direction : Vector3) -> void:
	arc_direction = new_direction
	# visually looking in the direction
	look_at(global_position + arc_direction)



# ---------- Applying Actual Effect Functions ---------- #


func find_affected_characters() -> Array[Character]:
	# First we get a list of all of the characters that would be affected if this was a simple AoE
	var affected_characters : Array[Character] = super()
	
	# Then check if each affected character is within the arc and remove it otherwise
	var chars_to_remove : Array[Character] = []
	for character : Character in affected_characters:
		var pos1 = global_position
		var pos2 = character.global_position
		
		if not is_within_arc(pos1, pos2, arc_direction, arc_angle):
			chars_to_remove.append(character)
	for character : Character in chars_to_remove:
		Util.delete_object_from_array(affected_characters, character)

	return affected_characters
	

func is_within_arc(position1: Vector3, position2: Vector3, direction: Vector3, angle: float) -> bool:
	# Calculate the vector from position1 to position2
	var to_position2 = position2 - position1
	
	# Normalize direction and to_position2
	direction = direction.normalized()
	to_position2 = to_position2.normalized()
	
	# Calculate the angle between the direction and the vector to position2
	var dot_product = direction.dot(to_position2)
	
	# Clamp dot product to avoid floating point issues outside the valid range for acos
	dot_product = clamp(dot_product, -1.0, 1.0)
	
	# Calculate the angle in radians between the direction and the to_position2 vector
	var angle_radians = acos(dot_product)
	
	# Convert the angle to degrees
	var angle_degrees = rad_to_deg(angle_radians)
	
	# Check if the angle is within the specified spread
	return angle_degrees <= angle



# ---------- Process Updates ---------- #
func handle_origin_character_tracking(delta : float):
	super(delta)
	if track_origin_character_direction and is_instance_valid(origin_character):
		set_direction(origin_character.aiming_master.look_direction_vector())
