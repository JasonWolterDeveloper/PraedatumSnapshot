class_name RPGStat extends Node

signal changed

const CURRENT_VALUE_SAVE_KEY = "current_value"

## A unique identifier for this particular stat so it can be referenced by RPGModifiers
## saves, and other stats from within the RPGMechanicsMaster
@export var stat_id : String = ""

var character : Character:
	get: return Util.get_character_parent(self)
	
var rpg_mechanics_master : RPGMechanicsMaster :
	get: return get_parent()
	
const ADDITIVE_MODIFIER_BASE_VALUE = 0.0
const MULTIPLICATIVE_MODIFIER_BASE_VALUE = 1.0
	
@export var base_value : float = 0
var additive_modifier : float = 0
var multiplicative_modifier : float = 1

@export var value:float = 0
@export var use_derived_value : bool = true

var min_value : float = 0
var max_value : float = 9999999999

@onready var self_scene = load(scene_file_path)


func _ready():
	pass


func reset_modifiers():
	additive_modifier = ADDITIVE_MODIFIER_BASE_VALUE
	multiplicative_modifier = MULTIPLICATIVE_MODIFIER_BASE_VALUE


func set_stat(amount):
	value = amount
	changed.emit()


func increase_stat(amount):
	value = value + amount
	value = min(get_max_value(), value)
	changed.emit()
	
	
func decrease_stat(amount):
	value = value - amount
	value = max(get_min_value(), value)
	changed.emit()


## Sets the stat to its maximum value
func restore_stat_to_max():
	value = get_max_value()
	changed.emit()


## Decreases a stat to a minimum of zero, and returns the amount to reduce the
## stat by left over if there is any
func decrease_stat_with_overflow(amount):
	if value >= amount:
		value -= amount
		changed.emit()
		return 0.0
	else:
		value = 0.0
		changed.emit()
		return amount - value


func multiplay_stat(amount):
	value = value * amount
	changed.emit()
	
	
func increase_stat_by_percentage(percentage):
	var multiply_amount = 1.0 + (percentage/100.0)
	multiplay_stat(multiply_amount)

	
func decrease_stat_by_percentage(percentage):
	var multiply_amount = 1.0 - (percentage/100.0)
	multiplay_stat(multiply_amount)


func make_derived_stat():
	var new_derived_stat = self_scene.instantiate()
	new_derived_stat.value = value
	return new_derived_stat


func apply_modifiers_to_self():
	if rpg_mechanics_master:
		# Generate RPG modifier list for stat passing self as the only parameter
		var modifiers = rpg_mechanics_master.generate_rpg_modifier_list_for_stat(self)
		
		# Loop through the array and call apply_stat on each element
		for modifier : RPGStatModifier in modifiers:
			modifier.apply_to_stat(self)


## recalculate_stat_value() is a function that loops through all of the RPGModifiers
## in our RPGMechanicsMaster, applies them to our additive and multiplicative multipliers
## as appropriate, and then updates our value from our base_value appropriately
func recalculate_stat_value():
	reset_modifiers()
	apply_modifiers_to_self()
	
	if use_derived_value:
		value = base_value * multiplicative_modifier + additive_modifier
		changed.emit()


## copy_base_values_to_stat() copies the base values of this stat to another stat
## for segmented stats this will include the base number of segments and value per
## segment as well. The primary use case for this function is repalcing the base stat
## values in the Player's RPGMechanicsMaster with the values that are saved in the custom
## warrior. This makes sure that when the player changes Warrior their stats are updated
## Appropriately. NOTE this is really the only place we should directly modify base_value
func copy_base_values_to_stat(stat : RPGStat) -> void:
	stat.base_value = base_value 
	stat.recalculate_stat_value()


func generate_save_dictionary():
	var save_dictionary = {}
	
	save_dictionary[SaveConstants.SCENE_PATH_SAVE_KEY] = scene_file_path
	save_dictionary[CURRENT_VALUE_SAVE_KEY] = value

	return save_dictionary


func load_from_dictionary(load_dictionary):
	value = load_dictionary[CURRENT_VALUE_SAVE_KEY]


func get_max_value():
	return max_value


func get_min_value():
	return min_value


func calculate_percent_full():
	return value/get_max_value() * 100.0


func check_is_full():
	return value == get_max_value()
