class_name PatrolFSM extends StateMachine

# States
@onready var patrol_wait_state : PatrolWaitState = $PatrolWaitState
@onready var patrol_move_state : PatrolMoveState = $PatrolMoveState

# Links
@onready var patrol_pause_waypoint_link : PatrolPauseWaypointLink = $PatrolPauseWaypointLink
@onready var timeout_link = $TimeoutLink

@export var has_speed_limit : bool = false
@export var speed_limit : float = 1.0


# Connect states and links according to your FSM diagram here and any additional setup
func init():
	super()
	# Attach destination states to links:
	timeout_link.next_state = patrol_move_state
	patrol_pause_waypoint_link.next_state = patrol_wait_state
	
	# Attach links to source states:
	patrol_move_state.links.append(patrol_pause_waypoint_link)
	patrol_wait_state.links.append(timeout_link)
	
	# Set initial state:
	initial_state = patrol_move_state
	
	# Any additional setup:
	# (Mostly) keeps NPCs out of sync. Ideally set TimeoutLink.duration in the inspector window:
	# timeout_link2.duration = randi_range(timeout_link2.duration, int(timeout_link2.duration * 1.5))


func on_entry(phys_delta) -> bool:
	super(phys_delta)
	if has_speed_limit:
		my_character.movement_master.set_speed_limit(speed_limit)
	return true # One-shot routine


func on_exit(phys_delta) -> bool:
	super(phys_delta)
	if has_speed_limit:
		my_character.movement_master.clear_speed_limit()
	return true # One-shot routine
