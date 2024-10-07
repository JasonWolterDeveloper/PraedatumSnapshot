class_name AreaOfEffect extends Area3D

@export var affects_player : bool = false
@export var affects_enemies : bool = true

@export var periodic : bool = false
@export var period_time : float = 1.0
var current_period_time = 0.0

@export var instant : bool = true
var first_frame_handled : bool = false
var instant_effect_handled : bool = false

@export var duration : float = 1.0
var current_duration = 0.0

## status_effect_scene is the status effect that should be applied to affected characters in the 
## area of effect. If it is null, no status_effect will be applied
@export var status_effect_scene : PackedScene

## track_origin_character_position will constantly update our center to the origin character every physics
## frame if set to true
@export var track_origin_character_position : bool = false
var origin_character : Character
@export var damage : float = 0.0


func _ready():
	if affects_enemies:
		MathUtil.add_collision_mask_bit(self, CollisionLayers.enemy_layer)
	if affects_player:
		MathUtil.add_collision_mask_bit(self, CollisionLayers.player_layer)



# ---------- Assignment Functions ---------- #


func assign_origin_character(character : Character) -> void:
	origin_character = character


func set_center(pos : Vector3):
	global_position = pos



# ---------- Applying Actual Effect Functions ---------- #


func apply_effect_to_character(character: Character):
	if status_effect_scene:
		var status_effect : RPGStatusEffect = status_effect_scene.instantiate()
		character.rpg_mechanics_master.add_or_refresh_status_effect(status_effect)
	
	if damage > 0:
		RPGEventMaster.invoke_damage_event(damage, character, origin_character)


func apply_effect_to_affected_characters():
	var affected_characters : Array[Character] = find_affected_characters()
	for character : Character in affected_characters:
		apply_effect_to_character(character)


func find_affected_characters() -> Array[Character]:
	var affected_characters : Array[Character] = []
	var overlapping_bodies = get_overlapping_bodies()
	
	for my_body in get_overlapping_bodies():
		if my_body is Player and affects_player:
			affected_characters.append(my_body)
		if my_body is Enemy and affects_enemies:
			affected_characters.append(my_body)

	return affected_characters



# ---------- Per Frame Handler Functions ---------- #


func handle_instant():
	if instant and not instant_effect_handled:
		instant_effect_handled = true
		apply_effect_to_affected_characters()


func handle_duration(delta : float):
	current_duration += delta
	
	if current_duration >= duration:
		queue_free()


func handle_periodic(delta : float):
	if periodic:
		current_period_time += delta
		
		if current_period_time >= period_time:
			apply_effect_to_affected_characters()
			current_period_time = 0.0


func handle_origin_character_tracking(delta : float):
	if track_origin_character_position and is_instance_valid(origin_character):
		set_center(origin_character.global_position)


func _physics_process(delta):
	if not first_frame_handled:
		first_frame_handled = true
	else:
		handle_instant()
		handle_periodic(delta)
		handle_duration(delta)
		handle_origin_character_tracking(delta)
