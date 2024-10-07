class_name Armour extends Item

## Class for holding and consequently damaging ArmourSegments. They are analogous to plate carriers. 
## Instance any number of ArmourSegments as child nodes to use. Segments are damaged in order of 
## descending indices

@export var damage_absorbtion:float ## The percentage of damage taken by armour (0.0 - 1.0)

var armour_points_stat : ArmourPointsStat


func _ready():
	assert(damage_absorbtion >= 0.0 and damage_absorbtion <= 1.0)
	init_armour_points_stat()
	assert(armour_points_stat != null)


## Searchs for armour points stat child and assigns it when found
## NOTE armour must have an associated armour points stat
func init_armour_points_stat() -> void:
	for child in get_children():
		if child is ArmourPointsStat:
			armour_points_stat = child
			break


## Damages the segments in order. Returns "overflow damage": damage that cannot be absorbed
func take_damage(damage_value:float) -> float:
	return armour_points_stat.decrease_stat_with_overflow(damage_value)


## Attempts to refill a non-full armour shard. Returns whether refill was a success or failure
func refill() -> bool:
	const REFILL_ERROR_MESSAGE = "Armour Full"
	var shard_used:bool = armour_points_stat.fill_next_missing_segment()
	
	if not shard_used:
		OnScreenMessageMaster.display_message(REFILL_ERROR_MESSAGE)
	return shard_used


func is_full() -> bool:
	return armour_points_stat.check_is_full()
	
	
func generate_save_dictionary():
	var save_dictionary = super()
	
	save_dictionary[armour_points_stat.stat_id] = armour_points_stat.generate_save_dictionary()

	return save_dictionary


func load_from_dictionary(load_dictionary):
	super(load_dictionary)
	init_armour_points_stat()
	if armour_points_stat.stat_id in load_dictionary:
		armour_points_stat.load_from_dictionary(load_dictionary[armour_points_stat.stat_id])
