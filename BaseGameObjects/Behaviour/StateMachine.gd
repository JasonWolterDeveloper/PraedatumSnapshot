class_name StateMachine extends State

## DOCUMENTATION
## See res://Documentation/Behaviour.md for class overview and usage

## ABSTRACT CLASS
## A StateMachine is itself a State and can thus be nested under a parent StateMachine. Override
## apply_custom_properties() if using Enemy.custom_ai_properties to create a FSM variant. Override 
## init() to link child states together. Optionally override pre_update() to perform operations 
## before each FSM update, such as updating child states' instance variables. 

# Meta vars
@export var reset_on_exit:bool = true ## Should we reset to initial_state upon exiting ourselves?
var debug_mode:bool ## Logs a "path" from the root State/StateMachine to the current State
var previous_debug_message:String

# Concrete vars
var current_state:State
var initial_state:State ## Use Enemy.initial_state_name, do not set StateMachine.initial_state directly

# FSM Variant/Customization set in Enemy, NOT HERE
var initial_state_name:StringName ## Used to populates initial_state. Is OVERRIDEN if Enemy.patrol exists 
var custom_properties:Dictionary ## Typically used in extended class' init() [property_name:String, property_value]


# -------------------------------------------------------- PUBLIC METHODS 


## Calls the appropriate method: on_entry, on_exit, or on_active to execute actions
## on_entry and on_active are recursively called top-down; on_exit called bottom-up
func update(phys_delta) -> bool:
	var done := false
	var done_on_active := false
	var current_debug_message:String 
	
	assert(initial_state)
	if not current_state:
		current_state = initial_state

	if debug_mode and is_root:
		current_debug_message = my_character.name + " FSM: " + str(self)
		if current_debug_message != previous_debug_message:
			DebugMaster.log_debug(current_debug_message, DebugMaster.AI_DEBUG_CATEGORY)
			previous_debug_message = current_debug_message
	
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
					if debug_mode and link.debug_mode:
						DebugMaster.log_debug("    " + str(link), DebugMaster.AI_DEBUG_CATEGORY)
					begin_exit()
			
		# Run on_active() then update our FSM. Determine if we should exit:
		done_on_active = on_active(phys_delta)
		if current_state and current_state.update(phys_delta):
			current_state = current_state.next_state
		if pending_exit or done_on_active:
			current_status = Status.ENDING
			
	if current_status == Status.ENDING: 
		# Call our FSM's on_exit(), then our own. Are we done exiting or is there more to do?
		if current_state:
			current_state.begin_exit()
			done = current_state.update(phys_delta) 
		done = done and on_exit(phys_delta) 
		
		# Reset state:
		if done: 
			pending_exit = false
			current_status = Status.STARTING
			if reset_on_exit:
				current_state = initial_state

	return done


func _to_string():
	return name + " -> " + (str(current_state) if self is StateMachine else "")


## Connect states and links according to your FSM diagram here
func init() -> void:
	super()
	populate_initial_state()

	# Manually refresh data if our initial state needs it:
	my_character.ai_memory.can_see_target = (initial_state is RangedAttackState) or \
		(initial_state is MeleeAttackState)
	if initial_state is PursuitState:
		my_character.ai_memory.update_target_position()
	
	# States:
	# var state_one = $StateOne
	# var state_two = $StateTwo
	# ...
	
	# Links:
	# var link_alpha = $LinkBeta
	# var link_beta = $LinkAlpha
	# ...
	
	# Attach destination states to links:
	# link_alpha.next_state = state_two
	# link_beta.next_state = state_one
	# ...
	
	# Attach links to source states:
	# state_one.links.append(link_alpha)
	# state_two.links.append(link_beta)
	# ...
	
	# Set initial state (only if Enemy.initial_state_name is not set):
	# initial_state = state_one
	
	# OPTIONAL - address any custom_properties, if they exist
	pass


# -------------------------------------------------------- PRIVATE METHODS


## Sets initial_state according to the name provided in Enemy. If no name is provided, it defaults to
## the first child State. 
func populate_initial_state() -> void:
	if my_character.patrol:
		for child in get_children():
			if child is PatrolFSM:
				initial_state = child
				if debug_mode:
					DebugMaster.log_debug(str(self) + " StateMachine.init(): ignoring Enemy.initial_state_name in favour of Enemy.patrol")
				break
	elif initial_state_name:
		for child in get_children():
			if child is State and child.name == initial_state_name:
				initial_state = child
				break
		assert(initial_state, str(self) + " StateMachine.init(): Enemy.initial_state_name does not match any child States")
	
	if not initial_state: # Fallback: use first State
		for child in get_children():
			if child is State:
				initial_state = child
				if debug_mode:
					DebugMaster.log_debug(str(self) + " StateMachine.init(): no Enemy.initial_state_name provided, using " + str(child), DebugMaster.AI_DEBUG_CATEGORY)
				break
