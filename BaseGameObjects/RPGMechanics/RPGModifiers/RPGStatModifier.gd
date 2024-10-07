class_name RPGStatModifier extends Resource

@export var stat_id: String
@export var value: float

## Check this if the value is a multiplier instead of additive.
@export var is_multiplicative: bool

## Check this if this should modify the number of segments in a segmented stat rather than the value
## of a stat directly
@export var is_number_of_segments: bool = false

## Check this if this should modify the value per segment in a segmented stat rather than the value
## of a stat directly
@export var is_value_per_segment: bool = false


func apply_to_stat(stat : RPGStat):
	if is_number_of_segments:
		if stat is RPGSegmentedStat:
			if is_multiplicative:
				stat.number_of_segments_multiplicative_modifier += value
			else:
				stat.number_of_segments_additive_modifier += value
	elif is_value_per_segment:
		if stat is RPGSegmentedStat:
			if is_multiplicative:
				stat.value_per_segment_multiplicative_modifier += value
			else:
				stat.value_per_segment_additive_modifier += value
	else:
		if is_multiplicative:
			stat.multiplicative_modifier += value
		else:
			stat.additive_modifier += value
