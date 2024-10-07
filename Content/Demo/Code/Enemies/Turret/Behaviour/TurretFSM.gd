extends StateMachine

# Doesn't move and fires at enemies it sees. Currently also fires at enemies it does
# not see

# States:
@onready var turret_ranged_engage_fsm : TurretRangedEngageFSM = $TurretRangedEngageFSM
@onready var passive_scan_state:TurretPassiveScanState = $TurretPassiveScanState
@onready var active_scan_state:TurretActiveScanState = $TurretActiveScanState

# Links:
@onready var target_detected:Link = $TurretTargetDetectedLink
@onready var suppression_timeout_link : SuppressionTimeoutLink = $SuppressionTimeoutLink
@onready var active_scan_timeout:Link = $TimeoutLink
@onready var target_reacquired = $TurretTargetReacquiredLink
@onready var damaged_by_player_link:DamagedByPlayerLink = $DamagedByPlayerLink
@onready var target_seen_link:TargetSeenLink = $TargetSeenLink


# Connect states and links according to your FSM diagram here and any additional setup
func init():
	super()
	
	# Attach destination states to links:
	target_seen_link.next_state = turret_ranged_engage_fsm
	target_reacquired.next_state = turret_ranged_engage_fsm
	active_scan_timeout.next_state = passive_scan_state
	damaged_by_player_link.next_state = turret_ranged_engage_fsm
	suppression_timeout_link.next_state = active_scan_state

	# Attach links to source states:
	passive_scan_state.links.append(target_seen_link)
	passive_scan_state.links.append(damaged_by_player_link)
	
	active_scan_state.links.append(target_seen_link)
	active_scan_state.links.append(active_scan_timeout)
	active_scan_state.links.append(target_reacquired)
	active_scan_state.links.append(damaged_by_player_link)
	
	turret_ranged_engage_fsm.links.append(suppression_timeout_link)
