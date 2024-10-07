class_name TurretRangedEngageFSM extends StateMachine

# Doesn't move and fires at enemies it sees. Currently also fires at enemies it does
# not see


# States:
@onready var engage_state:TurretEngageState = $TurretEngageState
@onready var suppression_state:TurretSuppressionState = $TurretSuppressionState

# Links:
@onready var target_lost_link : TurretTargetLostLink = $TurretTargetLostLink
@onready var target_reacquired_link : TurretTargetReaquiredLink = $TurretTargetReacquiredLink


# Connect states and links according to your FSM diagram here and any additional setup
func init():
	super()
	
	# Attach destination states to links:
	target_lost_link.next_state = suppression_state
	target_reacquired_link.next_state = engage_state

	# Attach links to source states:
	engage_state.links.append(target_lost_link)
	suppression_state.links.append(target_reacquired_link)
	
	# Set initial state:
	initial_state = engage_state
