class_name AimingLaser extends RayCast3D

@onready var beam_mesh = $BeamMesh
@onready var point_mesh = $PointMesh
@onready var animation_player = $AnimationPlayer

@export var should_reset_to_los_height : bool = true


func reset_to_los_height():
	global_position.y = PhysicsConstants.LOS_HEIGHT


func _process(delta):
	if should_reset_to_los_height:
		reset_to_los_height()
	var cast_point
	force_raycast_update()
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
		
		point_mesh.show()
		point_mesh.position.y = cast_point.y
		point_mesh.rotation = get_collision_normal()
	else:
		cast_point = target_position
		
		point_mesh.hide()
		
	beam_mesh.mesh.height = cast_point.y
	beam_mesh.position.y = cast_point.y/2
	
	
func set_global_origin_position(global_origin_position : Vector3):
	global_position = global_origin_position


func fade_laser_in(laser_fade_time : float):
	show()
	if animation_player:
		animation_player.play("Fade In Laser")
		animation_player.speed_scale = animation_player.get_current_animation_length()/laser_fade_time
		
	

func turn_laser_off():
	hide()
	
	
func turn_laser_on():
	show()
