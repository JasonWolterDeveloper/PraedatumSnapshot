## RPGSegmentedStat is an abstract class used to represent stats that
## are divided into distinct segments such as Health or Mana
class_name RPGSegmentedStat extends RPGStat

const NUMBER_OF_SEGMENTS_SAVE_KEY = "number_of_segments"
const VALUE_PER_SEGMENT_SAVE_KEY = "value_per_segment"

@export var base_number_of_segments : int = 1
var number_of_segments : int = 1
var number_of_segments_additive_modifier : int = 0
var number_of_segments_multiplicative_modifier : int = 1

@export var base_value_per_segment : float = 1.0
var value_per_segment : float = 25
var value_per_segment_additive_modifier : float = 0
var value_per_segment_multiplicative_modifier : float = 1


func _ready():
	# We CANNOT have a derived value if we are a segmented Stat
	use_derived_value = false
	# Doing extremely basic setup here # TODO - See if this can be removed and replaced 
	# with an initial Derivation
	number_of_segments = base_number_of_segments
	value_per_segment = base_value_per_segment


func reset_modifiers():
	super()
	number_of_segments_additive_modifier = ADDITIVE_MODIFIER_BASE_VALUE
	number_of_segments_multiplicative_modifier = MULTIPLICATIVE_MODIFIER_BASE_VALUE
	
	value_per_segment_additive_modifier = ADDITIVE_MODIFIER_BASE_VALUE
	value_per_segment_multiplicative_modifier = MULTIPLICATIVE_MODIFIER_BASE_VALUE


## Used for UI stuff mostly
func calculate_segment_percent_full(segment_idx : int) -> float:
	if segment_idx >= number_of_segments:
		return 0.0

	# Calculate the start and end value for the specified segment
	var segment_start_value : float = float(segment_idx * value_per_segment)
	var segment_end_value: float = float(segment_start_value + value_per_segment)

	# Calculate the filled value within the segment
	var filled_value_in_segment : float = min(value, segment_end_value) - segment_start_value
	if filled_value_in_segment < 0:
		filled_value_in_segment = 0

	# Calculate the percentage full for the segment
	var percentage_full : float = (filled_value_in_segment / value_per_segment) * 100.0

	return percentage_full


# Function to find the next segment that is missing health and fill it
func fill_next_missing_segment() -> bool:
	for segment_index in range(number_of_segments):
		# Calculate the start and end value for the current segment
		var segment_start_value = segment_index * value_per_segment
		var segment_end_value = segment_start_value + value_per_segment
		
		# Check if the current segment is not completely filled
		if value < segment_end_value:
			# Calculate the additional value needed to fill the current segment
			var additional_value_needed = segment_end_value - value
			
			# Add the additional value to the total value to fill the current segment
			value += additional_value_needed
			
			# Ensure the value does not exceed the total capacity
			value = min(value, number_of_segments * value_per_segment)
			changed.emit()
			return true
	return false


func get_max_value():
	return number_of_segments * value_per_segment


func copy_base_values_to_stat(stat : RPGStat) -> void:
	if stat is RPGSegmentedStat:
		stat.base_number_of_segments  = base_number_of_segments
		stat.base_value_per_segment = base_value_per_segment
	super(stat)


## recalculate_stat_value() is a function that loops through all of the RPGModifiers
## in our RPGMechanicsMaster, applies them to our additive and multiplicative multipliers
## as appropriate, and then updates our value from our base_value appropriately
func recalculate_stat_value():
	super()
	
	number_of_segments = base_number_of_segments * number_of_segments_multiplicative_modifier + number_of_segments_additive_modifier
	value_per_segment = base_value_per_segment * value_per_segment_multiplicative_modifier + value_per_segment_additive_modifier
	
	changed.emit()
