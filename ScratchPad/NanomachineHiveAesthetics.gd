extends Node3D

const SHADER_PARAMETER_FADE_IN_NAME = "FadeIn"

@onready var nanite_swarm_mesh : MeshInstance3D = $NaniteSwarm
const SWARM_RADIUS_MAX = 1.0
const SWARM_RADIUS_MIN = 0.0

const SWARM_HEIGHT_MAX = 2.0
const SWARM_HEIGHT_MIN = 0.0


func get_nanite_swarm_shader_material():
	return nanite_swarm_mesh.mesh.surface_get_material(0)


func get_nanite_swarm_mesh() -> SphereMesh:
	return nanite_swarm_mesh.mesh	


func activate_nanomachines_timed(time : float):
	fade_in_swarm_shader(time)
	tween_up_swarm_radius(time)
	tween_up_swarm_height(time)
	

func deactivate_nanomachines_timed(time : float):
	fade_out_swarm_shader(time)
	tween_down_swarm_radius(time)
	tween_down_swarm_height(time)


func fade_in_swarm_shader(time : float):
	var current_value = 0.0 # get_nanite_swarm_shader_material().get_shader_parameter(SHADER_PARAMETER_FADE_IN_NAME)
	var desired_value = 1.0
	var tween = get_tree().create_tween()
	tween.tween_method(set_fade_in_value, current_value, desired_value, time)


func tween_up_swarm_radius(time : float):
	var current_value = SWARM_RADIUS_MIN # get_nanite_swarm_shader_material().get_shader_parameter(SHADER_PARAMETER_FADE_IN_NAME)
	var desired_value = SWARM_RADIUS_MAX
	var tween = get_tree().create_tween()
	tween.tween_method(set_swarm_radius, current_value, desired_value, time)


func tween_up_swarm_height(time : float):
	var current_value = SWARM_HEIGHT_MIN # get_nanite_swarm_shader_material().get_shader_parameter(SHADER_PARAMETER_FADE_IN_NAME)
	var desired_value = SWARM_HEIGHT_MAX
	var tween = get_tree().create_tween()
	tween.tween_method(set_swarm_height, current_value, desired_value, time)


func fade_out_swarm_shader(time : float):
	var current_value = 1.0 # get_nanite_swarm_shader_material().get_shader_parameter(SHADER_PARAMETER_FADE_IN_NAME)
	var desired_value = 0.0
	var tween = get_tree().create_tween()
	tween.tween_method(set_fade_in_value, current_value, desired_value, time)


func tween_down_swarm_radius(time : float):
	var current_value = SWARM_RADIUS_MAX # get_nanite_swarm_shader_material().get_shader_parameter(SHADER_PARAMETER_FADE_IN_NAME)
	var desired_value = SWARM_RADIUS_MIN
	var tween = get_tree().create_tween()
	tween.tween_method(set_swarm_radius, current_value, desired_value, time)


func tween_down_swarm_height(time : float):
	var current_value = SWARM_HEIGHT_MAX # get_nanite_swarm_shader_material().get_shader_parameter(SHADER_PARAMETER_FADE_IN_NAME)
	var desired_value = SWARM_HEIGHT_MIN
	var tween = get_tree().create_tween()
	tween.tween_method(set_swarm_height, current_value, desired_value, time)


func set_fade_in_value(val : float):
	var material : ShaderMaterial = get_nanite_swarm_shader_material()
	material.set_shader_parameter("FadeIn", val)
	

func set_swarm_radius(val : float):
	var sphere_mesh : SphereMesh = get_nanite_swarm_mesh()
	sphere_mesh.radius = val
	

func set_swarm_height(val : float):
	var sphere_mesh : SphereMesh = get_nanite_swarm_mesh()
	sphere_mesh.height = val
