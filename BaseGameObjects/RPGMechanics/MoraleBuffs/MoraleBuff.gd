class_name MoraleBuff extends Node

# ----- Save Constants ----- #
const CURRENT_DURATION_SAVE_KEY = "current_duration"
const MODIFIED_DURATION_SAVE_KEY = "modified_duration"

# ----- Parent/Owner References ----- #
var morale_buff_master : MoraleBuffMaster

# ---- Basic Exported Information ----- #
@export var rpg_stat_modifiers: Array[RPGStatModifier]
@export var rpg_event_modifiers: Array[RPGEventModifier]
@export var base_duration: float
@export var id: String
@export var ui_image: Texture

# ----- Inventory Size Informations ----- #
# @export var impacts_inventory_width : bool = false
@export var inventory_width_increase : int = 0

# ----- Update Tracking Variables ----- #
var current_duration: float = 0.0
var modified_duration: float = 0.0 # Need modified total duration for UI



# ---------- Ready and Assignment Functions ---------- #


## Morale Buffs are not currently actually being added as children, so we cannot use their ready
## or process functions
func assign_morale_buff_master(new_morale_buff_master : MoraleBuffMaster):
	morale_buff_master = new_morale_buff_master



# --------- Update Functions --------- #


# Function to update current_duration
func update_duration(delta: float) -> void:
	current_duration -= delta


# Function to check if the duration has expired and delete the node if it has
func check_expiry() -> void:
	if current_duration < 0:
		morale_buff_master.remove_morale_buff(self)
		queue_free()


# Update function that takes delta and runs both update_duration and check_expiry
func update(delta: float) -> void:
	update_duration(delta)
	check_expiry()



# --------- Saving Loading Functions ---------#


func generate_save_dictionary() -> Dictionary:
	var save_dictionary = {}
	
	save_dictionary[SaveConstants.SCENE_PATH_SAVE_KEY] = scene_file_path
	
	save_dictionary[CURRENT_DURATION_SAVE_KEY] = current_duration
	save_dictionary[MODIFIED_DURATION_SAVE_KEY] = modified_duration

	return save_dictionary


func load_from_dictionary(load_dictionary : Dictionary) -> void:
	if load_dictionary.has(CURRENT_DURATION_SAVE_KEY):
		current_duration = load_dictionary[CURRENT_DURATION_SAVE_KEY]
	if load_dictionary.has(MODIFIED_DURATION_SAVE_KEY):
		modified_duration = load_dictionary[MODIFIED_DURATION_SAVE_KEY]



# ---------- Getters and Setters ---------- #


func set_current_duration(duration : float) -> void:
	current_duration = duration


func get_percent_time_left() -> float:
	return 100.0 * float(current_duration/modified_duration)
