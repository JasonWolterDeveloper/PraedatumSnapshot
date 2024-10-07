extends StateMachine

# "Stupidly" rushes towards the target character then attacks once in-range

var patrol : Patrol :
	get: return my_character.patrol
	
var target : Character

# States
@onready var zombie_fsm : StateMachine = $ZombieFSM
@onready var foreman_call_in_state : ForemanCallInState = $ForemanCallInState

# Links
@onready var time_to_call_in_link : TimeoutLink = $TimeToCallInTimeoutLink
@onready var call_in_ended_link : TimeoutLink = $CallInEndedTimeoutLink


# Connect states and links according to your FSM diagram here and any additional setup
func init():
	super()
	
	# Attach destination states to links:
	time_to_call_in_link.next_state = foreman_call_in_state
	call_in_ended_link.next_state = zombie_fsm

	# Attach links to source states:
	zombie_fsm.links.append(time_to_call_in_link)
	foreman_call_in_state.links.append(call_in_ended_link)
	zombie_fsm.initial_state_name = "PersistentMeleeAttackState"
	
	# Set initial state:
	initial_state = zombie_fsm
