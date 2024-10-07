class_name Door extends InteractableObject

@onready var sprite = $AnimatedSprite2D
@onready var collision_shape = $StaticBody2D/CollisionShape2D
@onready var navigation = $NavigationRegion2D

@export var destroyable : bool = true
@export var explosion_resistance : int = 1

var is_open = false
var is_opening = false
var is_closing = false
var is_destroyed = false


"""
@onready var right_side_bomb_rotation = $RightSide.rotation
@onready var left_side_bomb_rotation = $LeftSide.rotation
"""

@onready var inner_bomb_position = $InnerBombPosition
@onready var outer_bomb_position = $OuterBombPosition

@onready var left_door = $LeftDoor
@onready var right_door = $RightDoor

@onready var left_open_position = $LeftOpenPosition
@onready var right_open_position = $RightOpenPosition
@onready var left_close_position = $LeftClosePosition
@onready var right_close_position = $RightClosePosition

@export var close_time = 1.0
@export var open_time = 1.0
@export var open_nav_region : NavigationRegion3D

@export var locked : bool = false
## key_codes is an array of different string key codes for
## which the corresponding key is capable of unlocking the door
@export var key_codes : Array[String] = []
@export var lock_level : int = 0

@export var unlock_prompt_text : String = "Unlock Door"

## force_locked_override forces a door to be locked in a way that cannot be
## unlocked by a key or any normal player means. This is typically to force doors
## locked by a trigger for boss battles or cinematics etc.
var force_locked_override = false

const DOOR_OUTER_SIDE = "outer"
const DOOR_INNER_SIDE = "inner"

func _ready():
	pass


func close_door():
	if not is_destroyed:
		var door_close_tween = create_tween()
		door_close_tween.set_parallel(true)
		
		door_close_tween.tween_property(left_door, "position", left_close_position.position, close_time)
		door_close_tween.tween_property(right_door, "position", right_close_position.position, close_time)
		door_close_tween.set_parallel(false)
		door_close_tween.tween_callback(on_door_opening_finished)
		is_closing = true
		is_open = false
		
		if open_nav_region:
			open_nav_region.enabled = false
		# navigation.enabled = false


func open_door():
	if not is_destroyed:
		var door_open_tween = create_tween()
		door_open_tween.set_parallel(true)
		
		door_open_tween.tween_property(left_door, "position", left_open_position.position, open_time)
		door_open_tween.tween_property(right_door, "position", right_open_position.position, open_time)
		door_open_tween.set_parallel(false)
		door_open_tween.tween_callback(on_door_opening_finished)
		is_opening = true
		is_open = true
		
		if open_nav_region:
			open_nav_region.enabled = true
		# navigation.enabled = true


func on_door_opening_finished():
	is_opening = false
	is_closing = false


func toggle_door():
	if is_open:
		close_door()
	else:
		open_door()


func destroy_door():
	is_destroyed = true
	is_open = true
	# TODO - Change this to make the two doors destroyed rather than delete
	left_door.queue_free()
	right_door.queue_free()

	if open_nav_region:
		open_nav_region.enabled = true
	# collision_shape.disabled = true
	# navigation.enabled = true


func can_activate(activator : Character):
	if force_locked_override:
		return false
	if is_opening_or_closing():
		return false
	if is_destroyed:
		return false
	if is_open:
		return false # By Default we stop the player from closing doors
	if locked:
		return find_key_from_character(activator) != null
	return super(activator)


func is_opening_or_closing():
	return is_opening or is_closing


func activate(activator : Character):
	super(activator)
	if force_locked_override:
		pass # We do nothing. This will be updated to show an on screen message at somepoint
	elif locked:
		var key : DoorKeyItem = find_key_from_character(activator)
		if key:
			key.use_key_on_door(self)
	else:
		toggle_door()


func unlock_door_with_key(key : DoorKeyItem):
	unlock_door()


func key_can_unlock_door(key : DoorKeyItem):
	return key.key_code in key_codes


func find_key_from_character(character : Character) -> DoorKeyItem:
	var inventory : Inventory = character.inventory
	
	var key_options = inventory.find_all_items_of_type_in_storage(DoorKeyItem)
	
	for my_key : DoorKeyItem in key_options:
		if key_can_unlock_door(my_key):
			return my_key
	
	return null


func attempt_to_destroy_by_explosion(explosion: Explosion):
	if destroyable and not is_destroyed:
		if explosion.door_damage_strength >= explosion_resistance:
			destroy_door()


func unlock_door():
	locked = false


func lock_door():
	locked = true


func force_locked():
	force_locked_override = true
	

func clear_force_locked():
	force_locked_override = false


func what_side_is_bomb_planter_on(bomb_planter : Character):
	var bomb_planter_global_position = bomb_planter.global_position
	var bomb_planet_local_position = to_local(bomb_planter_global_position)
	if bomb_planet_local_position.z > 0:
		return DOOR_OUTER_SIDE
	return DOOR_INNER_SIDE


func generate_interaction_prompt():
	if locked:
		return unlock_prompt_text
	return super()
