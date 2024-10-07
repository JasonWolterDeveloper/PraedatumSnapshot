class_name State extends Node3D

## DOCUMENTATION
## See res://Documentation/Behaviour.md for class overview and usage

## ABSTRACT CLASS
## The base class of a state machine. Extend to a concrete class, add Actions as child nodes and use
## them in on_entry(), on_exit(), and on_active(). Generally, States should use 
## AIMemory.target_last_known_position rather than target_character.global_position directly. 

enum Status {STARTING, RUNNING, ENDING}

var ai_disabled : bool = false

@onready var current_status := Status.STARTING
@onready var pending_exit := false

var links:Array
var next_state:State
var is_root := false # Root State/StateMachine of the behaviour
var my_character:Character # The NPC being controlled; is the same for the entire Behaviour tree

var target_character:Character:
	get: return my_character.ai_memory.target_character
	set(value): assert(false) # To be set at Enemy.ai_memory by Enemy or a parent
var target_last_known_position:Vector3:
	get: return my_character.ai_memory.target_last_known_position
	set(value): assert(false) # To be set by Enemy.ai_memory itself
var can_see_target:bool:
	get: return my_character.ai_memory.can_see_target
	set(value): assert(false) # To be set at Link.triggered()
var state_properties:Dictionary:
	get: return my_character.ai_properties.state_properties
	set(value): assert(false) # To be set in Character.ai_properties


# -------------------------------------------------------- BUILD-IN METHODS


## Only the root FSM is updated every physics frame
func _physics_process(delta):
	if is_root and not ai_disabled:
		update(delta)

# -------------------------------------------------------- PUBLIC METHODS 

## ABSTRACT
func init() -> void:
	pass


func set_my_character(new_character:Character):
	assert(new_character)
	my_character = new_character


## Flags the state to begin exiting next update()
func begin_exit():
	pending_exit = true


## Calls the appropriate method: on_entry, on_exit, or on_active. Where the update() recursion ends:
## no FSM to update
func update(phys_delta) -> bool:
	# Just run on_entry(). RUNNING below takes care of calling our FSM's on_entry():
	if current_status == Status.STARTING: 
		if on_entry(phys_delta):
			current_status = Status.RUNNING
			
	if current_status == Status.RUNNING: 
		# Check for triggered links:
		if not pending_exit:
			for link in links:
				if link.triggered:
					next_state = link.next_state
					if my_character.behaviour_debug_mode and link.debug_mode:
						DebugMaster.log_debug("    " + str(link), DebugMaster.AI_DEBUG_CATEGORY)
					begin_exit()
		# Run on_active() and determine if we should exit:
		if pending_exit or on_active(phys_delta):
			current_status = Status.ENDING
			
	if current_status == Status.ENDING: 
		# Reset this state if we are done exiting:
		if on_exit(phys_delta): 
			pending_exit = false
			current_status = Status.STARTING
			return true

	return false


# @Override
func _to_string():
	return name + ""

# -------------------------------------------------------- PRIVATE METHODS


## VIRTUAL METHOD
## Returns true once ready to transition to the next routine
func on_entry(phys_delta) -> bool:
	for my_link : Link in links:
		my_link.on_entry()
	return true


## VIRTUAL METHOD
## Returns true once ready to transition to the next routine
func on_exit(phys_delta) -> bool:
	for my_link : Link in links:
		my_link.on_exit()
	return true


## ABSTRACT METHOD 
## Returns true once ready to transition to the next routine
## Only really needs to be implemented for simple States (i.e. not StateMachines). Returning a default
## of false means "continually perform these actions until one of our Links or our parent FSM tells us
## to exit. 
func on_active(phys_delta) -> bool:
	return false
