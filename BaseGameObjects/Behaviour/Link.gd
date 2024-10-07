class_name Link extends Node3D

## DOCUMENTATION
## See res://Documentation/Behaviour.md for class overview and usage

## ABSTRACT CLASS
## Contains a library of conditional tests. Extend this class and override is_triggered() to 
## perform any number of these tests before returning a boolean. Generally, Links determine 
## visibility of the player and should therefore use target_character.global_position rather than
## AIMemory.target_last_known_position.

@export var debug_mode:bool = false ## StateMachine.debug_mode must ALSO be true
@export var triggered_bark_name:StringName ## Function name of the bark to be played in my_character. 
@export var use_attack_state_delay:bool = false ## Sets AIMemory.use_attack_state_delay

var my_character:Character # The NPC being controlled; is the same for the entire Behaviour tree
var target_character:Character:
	get: return my_character.ai_memory.target_character
	set(value): my_character.ai_memory.target_character = value
var can_see_target:bool:
	set(value): my_character.ai_memory.can_see_target = value # Typically set by Link.is_triggered()
var pathfinding_master:PathfindingMaster:
	get:
		return my_character.pathfinding_master
var link_properties:Dictionary:
	get: return my_character.ai_properties.link_properties
	set(value): assert(false) # To be set in Character.ai_properties
var next_state:State
var triggered:bool:
	get: 
		triggered = is_triggered()
		if triggered:
			my_character.ai_memory.use_attack_state_delay = use_attack_state_delay
			if triggered_bark_name and my_character.has_method(triggered_bark_name):
				my_character.call(triggered_bark_name)
		return triggered
	
# A one-shot timer that only starts once used for 2 consecutive physics frames: 
var timer_last_use:float = 0 # When timer_active() was last called; seconds since engine start
var timer_started:bool = false
@onready var timer:Timer = Timer.new()

# ----------------------------------------------- BUILT-IN METHODS

func _ready():
	timer.one_shot = true
	timer.wait_time = 1 # Fallback; set this somewhere else (likely in your concrete Link or StateMachine._ready())
	add_child(timer)

# ----------------------------------------------- PUBLIC METHODS

## Called to initialize the Link. Should be called in StateMachine.init() by the FSM that
## owns this link. Used to setup anything that may not work with _ready, like
## information from the character or state machine
func init():
	pass


## Called when a state this link is associated with becomes active. Unlike State.on_entry(), is 
## one-shot (i.e. only executed once)
func on_entry() -> void:
	assert(next_state, "Link._ready(): next_state cannot be null")
	timer.stop()


## Called when a state this link is associated with becomes inactive. Unlike State.on_exit(), is 
## one-shot (i.e. only executed once)
func on_exit() -> void:
	timer.stop()
	timer_started = false

# ----------------------------------------------- PRIVATE METHODS: CONDITIONAL TESTS

## Necessary setter for duck-typing
func set_my_character(new_character:Character):
	my_character = new_character


## Did we reach our destination?
func navigation_done() -> bool:
	return pathfinding_master.nav_done
	

## Remember to set timer.wait_time somewhere (likely in your concrete Link or StateMachine._ready())
## If the timer is active (see timer_active()), has it stopped? Otherwise, start it
func timer_expired() -> bool:
	if not timer_started:
		timer.start()
		timer_started = true
	else:
		if timer.is_stopped():
			timer_started = false
			return true
	return false


# @Override
func _to_string():
	return "--[ " + name + " ]-->"

# ----------------------------------------------- PRIVATE METHODS

## ABSTRACT FUNCTION
## Use inline func triggered for public access, NOT is_triggered()
## Have all our conditional tests been met? Can we proceed to the next state?
func is_triggered() -> bool:
	return false


func get_parent_state():
	if get_parent() is State:
		return get_parent()
	return null


## True if called for at least 2 consecutive phys frames. False if X frames have passed with being called
func timer_active() -> bool:
	const INACTIVE_THERESHOLD:int = 2 # Number of physics frames 
	var current_time:float = Time.get_ticks_msec() / 1000.0 # Time since engine started [sec]
	var is_active:bool
	
	is_active = (current_time - timer_last_use) < (INACTIVE_THERESHOLD * get_physics_process_delta_time())
	timer_last_use = current_time

	return is_active
