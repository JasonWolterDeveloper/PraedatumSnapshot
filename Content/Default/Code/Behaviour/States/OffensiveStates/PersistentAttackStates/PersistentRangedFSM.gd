class_name PersistentRangedFSM extends StateMachine

## "Stupidly" rushes towards the target character then attacks once in-range

var pursue_after_suppression:bool:
	get:
		if state_properties.has("pursue_after_suppression"):
			return state_properties["pursue_after_suppression"]
		return false


# States
@onready var ranged_attack_state : RangedAttackState = $RangedAttackState
@onready var suppression_state:SuppressionState = $SuppressionState
@onready var pursuit_state : PersistentPursuitState = $PersistentPursuitState

# Links
@onready var lost_target_los_link : NoTargetLOSLink = $NoTargetLOSLink
@onready var suppression_timeout_link:TimeoutLink = $SuppressionTimeoutLink

# "Aggressive" State links with no attack delay
@onready var target_seen_link2:TargetSeenLink = $TargetSeenLink2


# Connect states and links according to your FSM diagram here and any additional setup
func init():
	super()
	
	target_seen_link2.next_state = ranged_attack_state
	lost_target_los_link.next_state = suppression_state
	suppression_timeout_link.next_state = pursuit_state
	
	# Attach links to source states:
	ranged_attack_state.links.append(lost_target_los_link)

	suppression_state.links.append(suppression_timeout_link)
	suppression_state.links.append(target_seen_link2)

	pursuit_state.links.append(target_seen_link2)
