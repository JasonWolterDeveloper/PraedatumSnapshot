class_name MeleeFSM extends StateMachine

# "Stupidly" rushes towards the target character then attacks once in-range

var patrol : Patrol :
	get: return my_character.patrol

# States
@onready var patrol_state_machine : PatrolFSM = $PatrolFSM
@onready var melee_attack_state : MeleeAttackState = $MeleeAttackState
@onready var pursuit_state : PursuitState = $PursuitState
@onready var target_just_lost_state : TargetJustLostState = $TargetJustLostState
@onready var move_state:MoveState = $MoveState
@onready var wander_state : WanderState = $WanderState
@onready var guard_state : GuardState = $GuardState

# Links
@onready var target_heard_link : TargetHeardLink = $TargetHeardLink
@onready var target_seen_link : TargetSeenLink = $TargetSeenLink
@onready var sixth_sense_link : SixthSenseLink = $SixthSenseLink
@onready var damaged_by_player_link : DamagedByPlayerLink = $DamagedByPlayerLink
@onready var lost_target_los_link : NoTargetLOSLink = $NoTargetLOSLink
@onready var destination_reached_link:DestinationReachedLink = $DestinationReachedLink
@onready var pursuit_timeout_link : TimeoutLink = $PursuitTimeoutLink
@onready var target_just_lost_timeout_link : TimeoutLink = $TargetJustLostTimeoutLink
@onready var destination_reached_link2:DestinationReachedLink = $DestinationReachedLink2

# "Aggressive" State links
@onready var target_heard_link2 : TargetHeardLink = $TargetHeardLink2
@onready var target_seen_link2:TargetSeenLink = $TargetSeenLink2
@onready var sixth_sense_link2 : SixthSenseLink = $SixthSenseLink2
@onready var damaged_by_player_link2 : DamagedByPlayerLink = $DamagedByPlayerLink2

# Connect states and links according to your FSM diagram here
func init():
	super()
	
	# Attach destination states to links:
	target_seen_link.next_state = melee_attack_state
	sixth_sense_link.next_state = melee_attack_state
	damaged_by_player_link.next_state = melee_attack_state
	target_seen_link2.next_state = melee_attack_state
	sixth_sense_link2.next_state = melee_attack_state
	damaged_by_player_link2.next_state = melee_attack_state
	
	target_heard_link.next_state = pursuit_state
	target_heard_link2.next_state = pursuit_state
	lost_target_los_link.next_state = pursuit_state
	destination_reached_link.next_state = target_just_lost_state
	pursuit_timeout_link.next_state = target_just_lost_state
	target_just_lost_timeout_link.next_state = move_state
	destination_reached_link2.next_state = wander_state
	
	if initial_state == guard_state:
		destination_reached_link2.next_state = guard_state
	
	if patrol:
		destination_reached_link2.next_state = patrol_state_machine
	
	# Attach links to source states:
	patrol_state_machine.links.append(target_heard_link)
	patrol_state_machine.links.append(target_seen_link)
	patrol_state_machine.links.append(damaged_by_player_link)
	patrol_state_machine.links.append(sixth_sense_link)
	
	melee_attack_state.links.append(lost_target_los_link)
	
	pursuit_state.links.append(target_heard_link2)
	pursuit_state.links.append(destination_reached_link)
	pursuit_state.links.append(pursuit_timeout_link)
	pursuit_state.links.append(target_seen_link2)
	pursuit_state.links.append(sixth_sense_link2)
	pursuit_state.links.append(damaged_by_player_link2)
	
	target_just_lost_state.links.append(target_heard_link)
	target_just_lost_state.links.append(target_just_lost_timeout_link)
	target_just_lost_state.links.append(target_seen_link)
	target_just_lost_state.links.append(sixth_sense_link)
	target_just_lost_state.links.append(damaged_by_player_link)
	
	move_state.links.append(target_heard_link)
	move_state.links.append(destination_reached_link2)
	move_state.links.append(target_seen_link)
	move_state.links.append(sixth_sense_link)
	move_state.links.append(damaged_by_player_link)

	wander_state.links.append(target_heard_link)
	wander_state.links.append(target_seen_link)
	wander_state.links.append(sixth_sense_link)
	wander_state.links.append(damaged_by_player_link)
	
	guard_state.links.append(target_heard_link)
	guard_state.links.append(target_seen_link)
	guard_state.links.append(damaged_by_player_link)
	guard_state.links.append(sixth_sense_link)
	
	
	# Any additional setup:
	move_state.movement_target = my_character.ai_memory.initial_position
