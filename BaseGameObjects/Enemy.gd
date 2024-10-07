class_name Enemy extends Character

## A virtual class for all enemies

signal heard_sound(position:Vector3)

const LOOT_OBJECT_SCENE = preload("res://ScratchPad/LootDrops/LootDropRigidBody.tscn")

@export var should_auto_adjust_y_position : bool = true
const NO_FALL_THROUGH_FLOOR_Y = 3

# Meta AI vars:
@export var ai_disabled:bool = false
@export var behaviour_debug_mode:bool = false
@export var pathfinding_debug_mode:bool = false
@export var ai_properties:AIProperties

# Concrete AI vars:
@export var sentry:bool = false ## Indicates we should remain still in wander state
## Unique name of the State this enemy's behaviour defaults to. Take care when using this, as a 
## StateMachine which starts "in the middle" may not behave as expected due to out-of-date vars.
## Is IGNORED if a patrol object is set. 
@export var initial_state_name:StringName 
@export var patrol : Patrol

# Aesthetic Vars
@export var info_display : EnemyInfoDisplay = null

# Other vars:
@export var awarded_experience_points : float = 10
@export var loot_tables : Array[LootTable] = []
@export var loot_spawn_height : float = 1.0
@export var spawn_ticket_cost : int = 1


# A reference to the ground item scene to be used for loot drops
var ground_item_scene = preload("res://Content/Default/Code/InteractableObjects/GroundItem.tscn")
var player_damaged_aesthetic_effect : PlayerDamagedAestheticEffect
var behaviour:State
var target_character:Character:
	get: return ai_memory.target_character
	set(value): ai_memory.target_character = value
var target_last_known_position:Vector3:
	get: return ai_memory.target_last_known_position
	set(val): assert(false, "Set in AIMemory, NOT HERE")

@onready var pathfinding_master : PathfindingMaster = $PathfindingMaster
@onready var melee_area : Area3D = $MeleeArea
@onready var ai_memory : AIMemory = $AIMemory


# --------------------------------------------------------- BUILT-IN METHODS

func _ready():
	super._ready()


	if should_auto_adjust_y_position:
		# Setting our Y position here so we don't fall through the floor
		global_position.y = NO_FALL_THROUGH_FLOOR_Y

	
	# Setting up our damage aesthetic_effect
	find_player_damaged_aesthetic_effect()
	
	assert(ai_memory)
	if ai_memory:
		ai_memory.initial_position = global_position
		ai_memory.wander_center = global_position
		heard_sound.connect(ai_memory.on_target_heard)
	
	# Behaviour setup:
	for child in get_children():
		if child is StateMachine:
			behaviour = child
			behaviour.is_root = true
			behaviour.ai_disabled = ai_disabled
			behaviour.debug_mode = behaviour_debug_mode
			behaviour.initial_state_name = initial_state_name
		if child is PathfindingMaster:
			child.debug_mode = pathfinding_debug_mode


# --------------------------------------------------------- PUBLIC METHODS

# Called when a character dies. May be extended by characters who have special
# functions on death, such as the player.
func on_death():
	RPGEventMaster.invoke_enemy_death_event(self)
	drop_loot()
	# We call super second because it deletes us
	super()


# --------- Loot Methods ---------- #

func drop_loot():
	if loot_tables:
		for my_loot_table in loot_tables:
			drop_loot_from_loot_table(my_loot_table)


func drop_loot_from_loot_table(loot_table : LootTable):
	var loot_array : Array[Item] = loot_table.roll_loot_table_for_item_array()
	for my_item in loot_array:
		drop_loot_item(my_item)


func drop_loot_item(item : Item):
	var loot : = LOOT_OBJECT_SCENE.instantiate()
	loot.setup_loot_item(item)
	loot.global_position = Vector3(global_position.x, loot_spawn_height, global_position.z)
	loot.assign_camera(GameMaster.get_level().camera)
	loot.launch_in_random_direction()
	GameMaster.get_level().add_child(loot)


# Signal callback function.
# Generate a path for the movement_target, then move along it. Is in this .gd script since it 
# references both MovementMaster AND PathfindingMaster.
func navigate_enemy(movement_target:Vector3, ignore_path_refresh_timer : bool):
	var nav_pos:Vector3
	
	# Move to the next path node at max speed:
	pathfinding_master.update_target_pos(movement_target, ignore_path_refresh_timer)
	nav_pos = pathfinding_master.next_nav_pos 
	
	movement_master.move_to_point(nav_pos)


func show_info_display():
	if is_instance_valid(info_display):
		info_display.show()


func hide_info_display():
	if is_instance_valid(info_display):
		info_display.hide()


## VIRTUAL
## Returns true only if the enemy can attack at all
func can_attack():
	return true


## VIRTUAL
## Returns true if the enemy is capable of attacking a particular Character
func can_attack_target(target : Character):
	return can_attack()


func get_spawn_ticket_cost():
	return spawn_ticket_cost


## drop_item if given a packed scene for an item will create a ground_item underneath
## this enemy
func drop_item_from_scene(item_scene : PackedScene):
	var new_item : Item = item_scene.instantiate()
	var ground_item : GroundItem = ground_item_scene.instantiate()
	ground_item.add_child(new_item)
	Util.get_level(self).add_child(ground_item)
	ground_item.global_position = global_position
	ground_item.global_position.y = 0.1
	ground_item.global_rotation = global_rotation
	ground_item.assign_camera(Util.get_level(self).camera)


func enable_ai():
	ai_disabled = false
	behaviour.ai_disabled = false


func disable_ai():
	ai_disabled = true
	behaviour.ai_disabled = true


## A simple wrapper for Util.check_los_to_object()
func check_los_to_character(other_character:Character = ai_memory.target_character, collision_mask:int = 0x3) -> bool:
	assert(other_character)
	if other_character:
		return Util.check_los_to_object(self, other_character, collision_mask)
	return false


func notify_heard_sound(sound_position : Vector3):
	# DebugMaster.log_debug("I heard a sound at: " + str(sound_position))
	heard_sound.emit(sound_position)


# --------------------------------------------------------- PRIVATE METHODS

# Immediately stops character movement and sets pathfinding to done
func stop_navigation():
	movement_master.move_along(Vector3.ZERO)
	pathfinding_master.target_pos = global_position


func find_player_damaged_aesthetic_effect():
	for my_child in get_children():
		if my_child is PlayerDamagedAestheticEffect:
			player_damaged_aesthetic_effect = my_child
			break
