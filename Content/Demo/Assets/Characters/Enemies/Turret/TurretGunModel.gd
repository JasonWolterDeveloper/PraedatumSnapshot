class_name TurretGunModel extends Node3D

@onready var laser_start_pos_marker : Marker3D = $LaserStartPos

func get_laser_start_pos() -> Vector3:
	return laser_start_pos_marker.global_position
