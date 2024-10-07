extends AimingLaser

@export var aim_location : Marker3D


func _process(delta):
	var cast_point = to_local(aim_location.global_position)
		
	beam_mesh.mesh.height = cast_point.y
	beam_mesh.position.y = cast_point.y/2
	point_mesh.position.y = cast_point.y
