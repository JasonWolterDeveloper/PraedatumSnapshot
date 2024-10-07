class_name AreaOfEffectAbility extends CrowdControlAbility

@export var area_of_effect_scene : PackedScene

## spawn_at_aimpoint indicates that we should spawn the AoE at the player's aim point
## rather than at the player's position
@export var spawn_at_aimpoint : bool = false

## Indicates whether holding down the pressed button should spawn an AoE predictor
## or if it should immediately cast
@export var cast_on_pressed = false
# Casting indicates that we are trying to cast and we need a predictor spawned
var casting : bool = false

@export var area_of_effect_indicator_scene : PackedScene = null
@export var prediction_priority : int = 2

var ability_height = 0.1


func ability_pressed_effect():
	if cast_on_pressed:
		attempt_cast()
	else:
		attempt_start_casting()


func ability_released_effect():
	if casting:
		attempt_cast()
	casting = false


func attempt_start_casting():
	if check_sufficient_mana_to_cast():
		casting = true
	else:
		display_not_enough_mana_message()
	
	
func attempt_cast():
	if check_sufficient_mana_to_cast():
		spawn_area_of_effect()
	else:
		display_not_enough_mana_message()


func height_repalced_vector3(vector : Vector3) -> Vector3:
	return Vector3(vector.x, ability_height, vector.z)


func find_spawn_location() -> Vector3:
	if not spawn_at_aimpoint:
		return height_repalced_vector3(player.global_position)

	var aimpoint_pos : Vector3 = Util.los_collision_point_raycast(player.global_position, player.aiming_master.aim_point)
	return height_repalced_vector3(aimpoint_pos)


func spawn_area_of_effect() -> AreaOfEffect:
	pay_mana_cost()
	var area_of_effect = area_of_effect_scene.instantiate()
	var aoe_position = find_spawn_location()

	area_of_effect.set_center(aoe_position)
	area_of_effect.assign_origin_character(player)
	Util.get_level(player).add_child(area_of_effect)
	return area_of_effect


func display_prediction_indicator():
	AreaOfEffectPredictionMaster.request_area_of_effect_indicator(find_spawn_location(), prediction_priority, ability_id, null, area_of_effect_indicator_scene)


func on_deselected():
	super()
	# Need to stop casting if we swap to another ability to avoid disasterous results
	casting = false


## Does anything that should be handled every process frame for an RPGAbility
func ability_process(delta : float):
	if casting:
		display_prediction_indicator()
