## AreaOfEffectPredictionMaster is a global singleton that provides predictions for Player's
## AreaOfEffect abilities and attacks. These can be things like RPGAbility Spells or weapons
## like Grenades and grenade launchers. The singleton can only show one predictor per frame so
## objects that request prediction have the option of providing a priority value to the singleton.
## For example, a grenade launcher prediction indicator that shows any time the launcher is
## equipped should have a lower priority than an actively casting spell. The singleton also has the
## ability for its prediction indicator to be overridden by another scene to display custom UI information
## when needed
extends Node3D

var area_of_effect_indicator: AreaOfEffectIndicator
@export var default_area_of_effect_indicator_scene : PackedScene

@onready var projectile_trajectory_predictor : ProjectileTrajectoryPredictor = $ProjectileTrajectoryPredictor

# Reducing our AOE radius by a constant amount to avoid making the player
# feel cheated by an oversized radius indicator
const AOE_RADIUS_MARGIN = 0.1

# The height at which the physical AOE mesh is displayed
const AOE_INDICATOR_HEIGHT = 0.1

# The information from the current heighest priority request
const LOWEST_PRIORITY = -9999999
var has_request : bool = false
var priority : int = LOWEST_PRIORITY
var area_of_effect_position : Vector3 = Vector3(0, 0, 0)
# request_id is used to identify requests as coming from the same weapon or RPGAbility so that we
# don't recreate the Area Of Effect Indicator completely if the request is coming from the same place
var request_id : String = ""
var previous_request_id = null
var override_radius = null
var override_effect_indicator_scene : PackedScene = null
var requires_trajectory : bool = false

# Trajectory data
var projectile : Projectile = null
var trajectory_start_pos : Vector3 = Vector3(0, 0, 0)
var trajectory_end_pos : Vector3 = Vector3(0, 0, 0)


func request_area_of_effect_indicator(new_position : Vector3, new_priority : int, new_request_id : String, new_override_radius=null, new_override_scene : PackedScene =null):
	if not has_request or new_priority > priority:
		has_request = true
		priority = new_priority
		area_of_effect_position = new_position
		override_radius = new_override_radius
		override_effect_indicator_scene = new_override_scene
		
		# If we're requesting a raw AoE indicator we don't need trajectory
		requires_trajectory = false


func request_projectile_trajectory(new_projectile : Projectile, new_start_pos : Vector3, new_end_pos : Vector3, new_priority : int, new_request_id : String, new_override_radius=null, new_override_scene : PackedScene =null):
	if not has_request or new_priority > priority:
		has_request = true
		priority = new_priority
		area_of_effect_position = new_end_pos
		override_radius = new_override_radius
		override_effect_indicator_scene = new_override_scene
		
		requires_trajectory = true
		projectile = new_projectile
		trajectory_start_pos = new_start_pos
		trajectory_end_pos = new_end_pos
		


# Done at the end of every physics frame so that people always need to request prediction
func reset_request_data():
	has_request = false
	priority = LOWEST_PRIORITY
	area_of_effect_position = Vector3(0, 0, 0)
	override_effect_indicator_scene = null
	requires_trajectory = false


func destroy_area_of_effect_indicator():
	if is_instance_valid(area_of_effect_indicator):
		remove_child(area_of_effect_indicator)
		area_of_effect_indicator.queue_free()
		area_of_effect_indicator = null


func create_area_of_effect_indicator():
	if override_effect_indicator_scene:
		area_of_effect_indicator = override_effect_indicator_scene.instantiate()
	else:
		area_of_effect_indicator = default_area_of_effect_indicator_scene.instantiate()
	add_child(area_of_effect_indicator)


func check_need_new_aoe_indicator():
	if not is_instance_valid(area_of_effect_indicator):
		return true
	elif request_id != previous_request_id:
		return true
	return false


func handle_if_we_require_new_area_of_effect_indicator():
	if check_need_new_aoe_indicator():
		destroy_area_of_effect_indicator()
		create_area_of_effect_indicator()


func handle_area_of_effect_indicator_geometry():
	if area_of_effect_indicator:
		if override_radius:
			area_of_effect_indicator.radius = override_radius
		area_of_effect_indicator.global_position = Vector3(area_of_effect_position.x, AOE_INDICATOR_HEIGHT, area_of_effect_position.z)
		area_of_effect_indicator.generate_indicator()
		area_of_effect_indicator.show()


func handle_area_of_effect_indicator():
	handle_if_we_require_new_area_of_effect_indicator()
	handle_area_of_effect_indicator_geometry()


func handle_trajectory_prediction():
	if projectile:
		Util.force_add_child(GameMaster.get_level(), projectile)
		projectile.global_position = trajectory_start_pos
		
		#TODO - Thisi s somewhat hingeless
		if projectile is GrenadeProjectile and not override_radius:
			override_radius = projectile.explosion.radius
		
		projectile_trajectory_predictor.show()
		area_of_effect_position = projectile_trajectory_predictor.simulate_throw(projectile, trajectory_start_pos, trajectory_end_pos)
		GameMaster.get_level().remove_child(projectile)
		projectile.queue_free()


func handle_no_trajectory():
	projectile_trajectory_predictor.clear_simulated_throw()
	projectile_trajectory_predictor.hide()
	

func handle_trajectory():
	if requires_trajectory:
		handle_trajectory_prediction()
	else:
		handle_no_trajectory()


func handle_no_request():
	previous_request_id = null
	handle_no_trajectory()
	destroy_area_of_effect_indicator()


func handle_has_request():
	if requires_trajectory:
		handle_trajectory()
	handle_area_of_effect_indicator()
	previous_request_id = request_id


func handle_request():
	if has_request:
		handle_has_request()
	else:
		handle_no_request()


func _process(delta: float) -> void:
	handle_request()
	reset_request_data()


""" Stuff For Trajectory - Ignore for now
func simulate_throw_from_grenade_item(grenade_item : GrenadeItem, start_pos : Vector3, end_pos : Vector3):
	var simulated_projectile : GrenadeProjectile = grenade_item.generate_grenade_projectile()
	Util.force_add_child(get_level(), simulated_projectile)
	simulated_projectile.global_position = start_pos
	
	var final_position = trajectory_predictor.simulate_throw(simulated_projectile, start_pos, end_pos)
	
	setup_radius_from_simulated_grenade_projectile(simulated_projectile, final_position)
	
	get_level().remove_child(simulated_projectile)
	simulated_projectile.queue_free()
"""
