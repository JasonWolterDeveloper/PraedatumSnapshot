class_name PathfindingMaster extends Node3D

## Abstracts the details of pathfinding and behaviour. To reduce likely CPU overhead, a single
## NavigationAgent2D is used for both character movement and navigation metadata 
## (e.g. is_target_reachable()). 

## Time in seconds between path updates. If a value lower than the physics frame time is provided
## (0.01667), then the path is updated every physics frame instead. 
@export var path_refresh_period:float = 0.5

@onready var nav_agent := $NavigationAgent3D
@onready var sound_nav_agent := $SoundNavAgent
var my_character:Character:
	get: 
		if not my_character:
			my_character = Util.get_character_parent(self)
		return my_character
	
# ------------------- Navigation metadata -------------------
@export var debug_log_paths:bool = false ## Enemy.pathfinding_debug_mode must be true. Logs paths
var debug_mode:bool: ## Set Enemy.pathfinding_debug_mode
	get: return my_character.pathfinding_debug_mode
var nav_done:bool: # Have we reached the target_pos?
	get: return nav_agent.is_navigation_finished()
var use_path_update_timer:bool = false
	
# ------------------- Concrete navigation data -------------------
var target_pos:Vector3 ## Pathfinding only on a single y height
	#set(val): target_pos = Vector3(val.x, 0, val.z) 
var next_nav_pos:Vector3
var previous_nav_pos:Vector3

# ----------------------------------------------------------------- BUILT-IN METHODS


func _ready():
	use_path_update_timer = path_refresh_period > get_physics_process_delta_time()
	if use_path_update_timer:
		$Timer.wait_time = path_refresh_period
		$Timer.start()
	
	nav_agent.debug_enabled = debug_mode
	target_pos = global_position # Setting target pos to our current position so that we don't try to navigate to (0, 0, 0) off the hop
	nav_agent.path_postprocessing = NavigationPathQueryParameters3D.PATH_POSTPROCESSING_CORRIDORFUNNEL
	call_deferred("init_nav_agent")


func _physics_process(delta):
	if not use_path_update_timer:
		update_path()
	if not nav_done:
		previous_nav_pos = next_nav_pos
		next_nav_pos = nav_agent.get_next_path_position() # Must be called every phys frame
		if debug_mode and debug_log_paths and not previous_nav_pos.is_equal_approx(next_nav_pos):
			DebugMaster.log_debug(str(my_character) + " - next path point: " + str(next_nav_pos), DebugMaster.AI_DEBUG_CATEGORY)


# ----------------------------------------------------------------- PUBLIC METHODS

# Update target pos is called when an enemy wants to navigate to a new position.
#
# new_target_pos is the new target position and ignore_path_refresh_timer indicates whether or not
# we should generate a new path right away if our target position is new
func update_target_pos(new_target_pos:Vector3, update_path_now:bool = false):
	if update_path_now and not target_pos.is_equal_approx(new_target_pos):
		target_pos = new_target_pos
		nav_agent.set_target_position(target_pos)
	else:
		target_pos = new_target_pos


# ----------------------------------------------------------------- PRIVATE METHODS


# Need to wait for the first phys frame for nav_agent to become active
func init_nav_agent():
	#TODO This whole thing is a bit cringe we might need to update it but I
	# will kludge for now - Jason
	if get_tree():
		await get_tree().physics_frame
		update_path()
	
	
# Timer callback: periodically create a new path with the same target
func update_path():
	nav_agent.set_target_position(target_pos)
